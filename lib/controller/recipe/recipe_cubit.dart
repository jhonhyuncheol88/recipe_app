import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../data/index.dart';
import '../../model/index.dart';
import '../../model/recipe_ingredient.dart';
import '../../service/recipe_cost_service.dart';
import '../../service/sauce_cost_service.dart';
import '../../service/ai_sales_analysis_service.dart';
import 'recipe_state.dart';
import '../../util/unit_converter.dart' as uc;
import 'package:uuid/uuid.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeRepository _recipeRepository;
  final IngredientRepository _ingredientRepository;
  final UnitRepository _unitRepository;
  final TagRepository _tagRepository;
  final SauceRepository _sauceRepository = SauceRepository();
  final AiRecipeRepository _aiRecipeRepository = AiRecipeRepository();
  late final SauceCostService _sauceCostService;
  late final RecipeCostService _recipeCostService;
  late final AiSalesAnalysisService _aiSalesAnalysisService;
  final Uuid _uuid = const Uuid();

  RecipeCubit({
    required RecipeRepository recipeRepository,
    required IngredientRepository ingredientRepository,
    required UnitRepository unitRepository,
    required TagRepository tagRepository,
  }) : _recipeRepository = recipeRepository,
       _ingredientRepository = ingredientRepository,
       _unitRepository = unitRepository,
       _tagRepository = tagRepository,
       super(const RecipeInitial()) {
    _sauceCostService = SauceCostService(
      sauceRepository: _sauceRepository,
      ingredientRepository: _ingredientRepository,
    );
    _recipeCostService = RecipeCostService(
      recipeRepository: _recipeRepository,
      sauceRepository: _sauceRepository,
      sauceCostService: _sauceCostService,
    );
    _aiSalesAnalysisService = AiSalesAnalysisService();
  }

  // 레시피 목록 로드
  Future<void> loadRecipes() async {
    try {
      emit(const RecipeLoading());
      final recipes = await _recipeRepository.getAllRecipes();

      if (recipes.isEmpty) {
        emit(const RecipeEmpty());
      } else {
        final stats = await _recipeRepository.getRecipeStats();
        emit(RecipeLoaded(recipes: recipes, stats: stats));
      }
    } catch (e) {
      emit(RecipeError('레시피 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  // 레시피 추가
  Future<void> addRecipe({
    required String name,
    required String description,
    required double outputAmount,
    required String outputUnit,
    String? imagePath,
    List<String> tagIds = const [],
    List<RecipeIngredient> ingredients = const [],
    List<RecipeSauce> sauces = const [],
  }) async {
    try {
      emit(const RecipeLoading());

      final String recipeId = _uuid.v4();
      final recipe = Recipe(
        id: recipeId,
        name: name,
        description: description,
        outputAmount: outputAmount,
        outputUnit: outputUnit,
        totalCost: 0.0,
        imagePath: imagePath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ingredients: ingredients
            .map((ingredient) => ingredient.copyWith(recipeId: recipeId))
            .toList(),
        tagIds: tagIds,
      );

      await _recipeRepository.insertRecipe(recipe);

      // 소스 관계 추가
      for (final s in sauces) {
        final entry = RecipeSauce(
          id: _uuid.v4(),
          recipeId: recipeId,
          sauceId: s.sauceId,
          amount: s.amount,
          unitId: s.unitId,
        );
        await _recipeRepository.addSauceToRecipe(recipeId, entry);
      }

      // 총원가 재계산 (재료 + 소스)
      await _recalculateRecipeCost(recipeId);

      // 태그 사용 횟수 증가
      for (final tagId in tagIds) {
        await _tagRepository.incrementTagUsage(tagId);
      }

      final recipes = await _recipeRepository.getAllRecipes();

      final created = recipes.firstWhere(
        (r) => r.id == recipeId,
        orElse: () => recipe,
      );
      emit(RecipeAdded(recipe: created, recipes: recipes));

      // Analytics: 레시피 추가 카운트 증가
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: 'recipe_add',
          parameters: {'count': 1},
        );
      } catch (_) {}
    } catch (e) {
      emit(RecipeError('레시피 추가에 실패했습니다: $e'));
    }
  }

  // 레시피 업데이트
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      emit(const RecipeLoading());

      // 기존 레시피 정보 조회
      final existingRecipe = await _recipeRepository.getRecipeById(recipe.id);
      if (existingRecipe == null) {
        emit(const RecipeError('수정할 레시피를 찾을 수 없습니다.'));
        return;
      }

      // 레시피 기본 정보 업데이트
      await _recipeRepository.updateRecipe(recipe);

      // 기존 재료 관계를 새로운 것으로 교체
      // 각 재료를 개별적으로 업데이트하거나 추가
      for (final ingredient in recipe.ingredients) {
        try {
          // 기존 재료가 있는지 확인하고 업데이트, 없으면 추가
          await _recipeRepository.addIngredientToRecipe(recipe.id, ingredient);
        } catch (e) {
          // 재료 추가 실패 시 로그만 남기고 계속 진행
          print('재료 추가 실패: ${ingredient.ingredientId}, 오류: $e');
        }
      }

      // 소스 관계는 별도로 관리되므로 여기서는 제거하지 않음
      // 소스 추가/제거는 별도 메서드로 처리

      // 레시피 원가 재계산
      await _recalculateRecipeCost(recipe.id);

      // 업데이트된 레시피 정보 조회
      final updatedRecipe = await _recipeRepository.getRecipeById(recipe.id);
      final recipes = await _recipeRepository.getAllRecipes();

      if (updatedRecipe != null) {
        emit(RecipeUpdated(recipe: updatedRecipe, recipes: recipes));
      } else {
        emit(RecipeUpdated(recipe: recipe, recipes: recipes));
      }
    } catch (e) {
      emit(RecipeError('레시피 수정에 실패했습니다: $e'));
    }
  }

  // 레시피 삭제
  Future<void> deleteRecipe(String id) async {
    try {
      emit(const RecipeLoading());

      // 삭제 전에 태그 정보 가져오기
      final recipe = await _recipeRepository.getRecipeById(id);
      if (recipe != null) {
        // 태그 사용 횟수 감소
        for (final tagId in recipe.tagIds) {
          await _tagRepository.decrementTagUsage(tagId);
        }
      }

      await _recipeRepository.deleteRecipe(id);
      final recipes = await _recipeRepository.getAllRecipes();

      emit(RecipeDeleted(deletedId: id, recipes: recipes));
    } catch (e) {
      emit(RecipeError('레시피 삭제에 실패했습니다: $e'));
    }
  }

  // 레시피 검색
  Future<void> searchRecipes(String query) async {
    try {
      if (query.isEmpty) {
        await loadRecipes();
        return;
      }

      emit(const RecipeLoading());
      final recipes = await _recipeRepository.searchRecipesByName(query);

      if (recipes.isEmpty) {
        emit(const RecipeEmpty());
      } else {
        emit(RecipeSearchResult(recipes: recipes, query: query));
      }
    } catch (e) {
      emit(RecipeError('레시피 검색에 실패했습니다: $e'));
    }
  }

  // 태그별 필터링
  Future<void> filterRecipesByTag(String tagId) async {
    try {
      emit(const RecipeLoading());
      final recipeIds = await _tagRepository.getRecipeIdsByTag(tagId);

      if (recipeIds.isEmpty) {
        emit(const RecipeEmpty());
      } else {
        final recipes = <Recipe>[];
        for (final id in recipeIds) {
          final recipe = await _recipeRepository.getRecipeById(id);
          if (recipe != null) {
            recipes.add(recipe);
          }
        }

        emit(RecipeFilteredByTag(recipes: recipes, tagId: tagId));
      }
    } catch (e) {
      emit(RecipeError('태그별 필터링에 실패했습니다: $e'));
    }
  }

  // 여러 태그로 필터링
  Future<void> filterRecipesByTags(List<String> tagIds) async {
    try {
      emit(const RecipeLoading());

      if (tagIds.isEmpty) {
        await loadRecipes();
        return;
      }

      final allRecipes = await _recipeRepository.getAllRecipes();
      final filteredRecipes = allRecipes.where((recipe) {
        return tagIds.every((tagId) => recipe.tagIds.contains(tagId));
      }).toList();

      if (filteredRecipes.isEmpty) {
        emit(const RecipeEmpty());
      } else {
        emit(RecipeFilteredByTags(recipes: filteredRecipes, tagIds: tagIds));
      }
    } catch (e) {
      emit(RecipeError('태그 필터링에 실패했습니다: $e'));
    }
  }

  // 레시피에 태그 추가
  Future<void> addTagToRecipe(String recipeId, String tagId) async {
    try {
      emit(const RecipeLoading());

      await _tagRepository.addTagToRecipe(recipeId, tagId);
      final recipes = await _recipeRepository.getAllRecipes();

      emit(
        TagAddedToRecipe(recipeId: recipeId, tagId: tagId, recipes: recipes),
      );
    } catch (e) {
      emit(RecipeError('태그 추가에 실패했습니다: $e'));
    }
  }

  // 레시피에서 태그 제거
  Future<void> removeTagFromRecipe(String recipeId, String tagId) async {
    try {
      emit(const RecipeLoading());

      await _tagRepository.removeTagFromRecipe(recipeId, tagId);
      final recipes = await _recipeRepository.getAllRecipes();

      emit(
        TagRemovedFromRecipe(
          recipeId: recipeId,
          tagId: tagId,
          recipes: recipes,
        ),
      );
    } catch (e) {
      emit(RecipeError('태그 제거에 실패했습니다: $e'));
    }
  }

  // 레시피 태그 업데이트
  Future<void> updateRecipeTags(String recipeId, List<String> tagIds) async {
    try {
      emit(const RecipeLoading());

      final recipe = await _recipeRepository.getRecipeById(recipeId);
      if (recipe != null) {
        final updatedRecipe = recipe.updateTags(tagIds);
        await _recipeRepository.updateRecipe(updatedRecipe);

        final recipes = await _recipeRepository.getAllRecipes();

        emit(
          RecipeTagsUpdated(
            recipeId: recipeId,
            tagIds: tagIds,
            recipes: recipes,
          ),
        );
      }
    } catch (e) {
      emit(RecipeError('태그 업데이트에 실패했습니다: $e'));
    }
  }

  // 레시피에 재료 추가
  Future<void> addIngredientToRecipe({
    required String recipeId,
    required String ingredientId,
    required double amount,
    required String unitId,
  }) async {
    try {
      emit(const RecipeLoading());

      // 재료 정보 조회
      final ingredient = await _ingredientRepository.getIngredientById(
        ingredientId,
      );
      if (ingredient == null) {
        emit(const RecipeError('재료를 찾을 수 없습니다.'));
        return;
      }

      // 단위 정보 조회
      final unit = await _unitRepository.getUnitById(unitId);
      if (unit == null) {
        emit(const RecipeError('단위를 찾을 수 없습니다.'));
        return;
      }

      // 원가 계산
      final calculatedCost = await _calculateIngredientCost(
        ingredient,
        amount,
        unit,
      );

      final recipeIngredient = RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipeId,
        ingredientId: ingredientId,
        amount: amount,
        unitId: unitId,
        calculatedCost: calculatedCost,
      );

      await _recipeRepository.addIngredientToRecipe(recipeId, recipeIngredient);

      // 레시피 원가 재계산
      await _recalculateRecipeCost(recipeId);

      final recipes = await _recipeRepository.getAllRecipes();
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipeId);

      emit(
        IngredientAddedToRecipe(
          recipe: updatedRecipe,
          ingredient: recipeIngredient,
          recipes: recipes,
        ),
      );
    } catch (e) {
      emit(RecipeError('재료 추가에 실패했습니다: $e'));
    }
  }

  // 레시피에서 재료 제거
  Future<void> removeIngredientFromRecipe({
    required String recipeId,
    required String ingredientId,
  }) async {
    try {
      emit(const RecipeLoading());

      await _recipeRepository.removeIngredientFromRecipe(
        recipeId,
        ingredientId,
      );

      // 레시피 원가 재계산
      await _recalculateRecipeCost(recipeId);

      final recipes = await _recipeRepository.getAllRecipes();
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipeId);

      emit(
        IngredientRemovedFromRecipe(
          recipe: updatedRecipe,
          removedIngredientId: ingredientId,
          recipes: recipes,
        ),
      );
    } catch (e) {
      emit(RecipeError('재료 제거에 실패했습니다: $e'));
    }
  }

  // 레시피 재료 수량 업데이트
  Future<void> updateRecipeIngredientAmount({
    required String recipeId,
    required String ingredientId,
    required double newAmount,
  }) async {
    try {
      emit(const RecipeLoading());

      // 재료 정보 조회
      final ingredient = await _ingredientRepository.getIngredientById(
        ingredientId,
      );
      if (ingredient == null) {
        emit(const RecipeError('재료를 찾을 수 없습니다.'));
        return;
      }

      // 레시피 정보 조회
      final recipe = await _recipeRepository.getRecipeById(recipeId);
      if (recipe == null) {
        emit(const RecipeError('레시피를 찾을 수 없습니다.'));
        return;
      }

      // 재료의 단위 정보 조회
      final recipeIngredient = recipe.ingredients.firstWhere(
        (ri) => ri.ingredientId == ingredientId,
      );
      final unit = await _unitRepository.getUnitById(recipeIngredient.unitId);
      if (unit == null) {
        emit(const RecipeError('단위를 찾을 수 없습니다.'));
        return;
      }

      // 새로운 원가 계산
      final newCalculatedCost = await _calculateIngredientCost(
        ingredient,
        newAmount,
        unit,
      );

      await _recipeRepository.updateRecipeIngredientAmount(
        recipeId,
        ingredientId,
        newAmount,
        newCalculatedCost,
      );

      // 레시피 원가 재계산
      await _recalculateRecipeCost(recipeId);

      final recipes = await _recipeRepository.getAllRecipes();
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipeId);

      emit(
        RecipeIngredientAmountUpdated(
          recipe: updatedRecipe,
          ingredientId: ingredientId,
          newAmount: newAmount,
          newCalculatedCost: newCalculatedCost,
          recipes: recipes,
        ),
      );
    } catch (e) {
      emit(RecipeError('재료 수량 업데이트에 실패했습니다: $e'));
    }
  }

  // 레시피에 소스 추가
  Future<void> addSauceToRecipe({
    required String recipeId,
    required String sauceId,
    required double amount,
    required String unitId,
  }) async {
    try {
      emit(const RecipeLoading());
      final recipeSauce = RecipeSauce(
        id: _uuid.v4(),
        recipeId: recipeId,
        sauceId: sauceId,
        amount: amount,
        unitId: unitId,
      );
      await _recipeRepository.addSauceToRecipe(recipeId, recipeSauce);
      await _recalculateRecipeCost(recipeId);

      final recipes = await _recipeRepository.getAllRecipes();
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipeId);
      emit(RecipeUpdated(recipe: updatedRecipe, recipes: recipes));
    } catch (e) {
      emit(RecipeError('레시피에 소스 추가에 실패했습니다: $e'));
    }
  }

  // 레시피에서 소스 제거
  Future<void> removeSauceFromRecipe({
    required String recipeId,
    required String sauceId,
  }) async {
    try {
      emit(const RecipeLoading());
      await _recipeRepository.removeSauceFromRecipe(recipeId, sauceId);
      await _recalculateRecipeCost(recipeId);

      final recipes = await _recipeRepository.getAllRecipes();
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipeId);
      emit(RecipeUpdated(recipe: updatedRecipe, recipes: recipes));
    } catch (e) {
      emit(RecipeError('레시피에서 소스 제거에 실패했습니다: $e'));
    }
  }

  // 레시피 소스 사용량 업데이트
  Future<void> updateRecipeSauceAmount({
    required String recipeId,
    required String sauceId,
    required double newAmount,
  }) async {
    try {
      emit(const RecipeLoading());
      await _recipeRepository.updateRecipeSauceAmount(
        recipeId,
        sauceId,
        newAmount,
      );
      await _recalculateRecipeCost(recipeId);

      final recipes = await _recipeRepository.getAllRecipes();
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipeId);
      emit(RecipeUpdated(recipe: updatedRecipe, recipes: recipes));
    } catch (e) {
      emit(RecipeError('레시피 소스 수량 업데이트에 실패했습니다: $e'));
    }
  }

  // 레시피 소스 단위 변경
  Future<void> updateRecipeSauceUnit({
    required String recipeId,
    required String sauceId,
    required String newUnitId,
  }) async {
    try {
      emit(const RecipeLoading());
      await _recipeRepository.updateRecipeSauceUnit(
        recipeId,
        sauceId,
        newUnitId,
      );
      await _recalculateRecipeCost(recipeId);

      final recipes = await _recipeRepository.getAllRecipes();
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipeId);
      emit(RecipeUpdated(recipe: updatedRecipe, recipes: recipes));
    } catch (e) {
      emit(RecipeError('레시피 소스 단위 변경에 실패했습니다: $e'));
    }
  }

  // 레시피 재료 단위/수량 업데이트 (단위 변경 반영)
  Future<void> updateRecipeIngredientUnitAndAmount({
    required String recipeId,
    required String ingredientId,
    required String newUnitId,
    required double newAmount,
  }) async {
    try {
      emit(const RecipeLoading());
      // 재료 단가 계산을 위해 구매단위 기준 단가 계산
      final ingredient = await _ingredientRepository.getIngredientById(
        ingredientId,
      );
      if (ingredient == null) {
        emit(const RecipeError('재료를 찾을 수 없습니다.'));
        return;
      }
      // 구매단위 → 기본단위 단가
      final purchaseBase = uc.UnitConverter.toBaseUnit(
        ingredient.purchaseAmount,
        ingredient.purchaseUnitId,
      );
      final unitPrice = ingredient.purchasePrice / purchaseBase;
      final usageBase = uc.UnitConverter.toBaseUnit(newAmount, newUnitId);
      final newCalculatedCost = unitPrice * usageBase;

      // DB 반영: amount, unit, calculated_cost
      await _recipeRepository.updateRecipeIngredientAmount(
        recipeId,
        ingredientId,
        newAmount,
        newCalculatedCost,
      );
      await _recipeRepository.updateRecipeIngredientUnit(
        recipeId,
        ingredientId,
        newUnitId,
        newCalculatedCost,
      );

      await _recalculateRecipeCost(recipeId);

      final recipes = await _recipeRepository.getAllRecipes();
      final updatedRecipe = recipes.firstWhere((r) => r.id == recipeId);
      emit(RecipeUpdated(recipe: updatedRecipe, recipes: recipes));
    } catch (e) {
      emit(RecipeError('재료 단위/수량 업데이트에 실패했습니다: $e'));
    }
  }

  // 원가별 레시피 정렬
  Future<void> sortRecipesByCost({bool ascending = true}) async {
    try {
      emit(const RecipeLoading());
      final recipes = await _recipeRepository.getRecipesByCost(
        ascending: ascending,
      );

      if (recipes.isEmpty) {
        emit(const RecipeEmpty());
      } else {
        emit(RecipesSortedByCost(recipes: recipes, ascending: ascending));
      }
    } catch (e) {
      emit(RecipeError('레시피 정렬에 실패했습니다: $e'));
    }
  }

  // 최근 레시피 조회
  Future<void> loadRecentRecipes({int limit = 10}) async {
    try {
      emit(const RecipeLoading());
      final recipes = await _recipeRepository.getRecentRecipes(limit: limit);

      if (recipes.isEmpty) {
        emit(const RecipeEmpty());
      } else {
        emit(RecentRecipesLoaded(recipes: recipes, limit: limit));
      }
    } catch (e) {
      emit(RecipeError('최근 레시피 조회에 실패했습니다: $e'));
    }
  }

  // 특정 재료를 사용하는 레시피 조회
  Future<void> loadRecipesByIngredient(String ingredientId) async {
    try {
      emit(const RecipeLoading());
      final recipes = await _recipeRepository.getRecipesByIngredient(
        ingredientId,
      );

      if (recipes.isEmpty) {
        emit(const RecipeEmpty());
      } else {
        emit(
          RecipesByIngredientLoaded(
            recipes: recipes,
            ingredientId: ingredientId,
          ),
        );
      }
    } catch (e) {
      emit(RecipeError('재료별 레시피 조회에 실패했습니다: $e'));
    }
  }

  // 레시피 통계 로드
  Future<void> loadRecipeStats() async {
    try {
      emit(const RecipeLoading());
      final stats = await _recipeRepository.getRecipeStats();
      emit(RecipeStatsLoaded(stats: stats));
    } catch (e) {
      emit(RecipeError('통계 로드에 실패했습니다: $e'));
    }
  }

  // 레시피 원가 재계산
  Future<void> recalculateRecipeCost(String recipeId) async {
    try {
      emit(const RecipeLoading());
      await _recalculateRecipeCost(recipeId);

      final recipes = await _recipeRepository.getAllRecipes();
      final recipe = recipes.firstWhere((r) => r.id == recipeId);

      emit(
        RecipeCostRecalculated(
          recipe: recipe,
          newTotalCost: recipe.totalCost,
          recipes: recipes,
        ),
      );
    } catch (e) {
      emit(RecipeError('원가 재계산에 실패했습니다: $e'));
    }
  }

  // 레시피 새로고침
  Future<void> refreshRecipes() async {
    await loadRecipes();
  }

  // AI 레시피 저장
  Future<void> saveAiRecipe(
    Map<String, dynamic> aiRecipeData,
    List<String> sourceIngredients,
  ) async {
    try {
      emit(const RecipeLoading());

      final aiRecipe = AiRecipe(
        id: _uuid.v4(),
        recipeName: aiRecipeData['recipe_name'] ?? '',
        description: aiRecipeData['description'] ?? '',
        cuisineType: aiRecipeData['cuisine_type'],
        servings: aiRecipeData['servings'] ?? 0,
        prepTimeMinutes: aiRecipeData['prep_time_minutes'] ?? 0,
        cookTimeMinutes: aiRecipeData['cook_time_minutes'] ?? 0,
        totalTimeMinutes: aiRecipeData['total_time_minutes'] ?? 0,
        difficulty: aiRecipeData['difficulty'] ?? 'Beginner',
        ingredients: List<Map<String, dynamic>>.from(
          aiRecipeData['ingredients'] ?? [],
        ),
        instructions: List<String>.from(aiRecipeData['instructions'] ?? []),
        tips: aiRecipeData['tips'] != null
            ? List<String>.from(aiRecipeData['tips'])
            : null,
        nutritionalInfo: aiRecipeData['nutritional_info_per_serving'],
        estimatedCost: (aiRecipeData['estimated_cost']?['amount'] ?? 0.0)
            .toDouble(),
        tags: List<String>.from(aiRecipeData['tags'] ?? []),
        creativityScore: aiRecipeData['creativity_score'],
        generatedAt: DateTime.now(),
        sourceIngredients: sourceIngredients,
        aiModel: 'gemini-2.0-flash-exp',
        promptVersion: '1.0',
      );

      await _aiRecipeRepository.insertAiRecipe(aiRecipe);

      emit(AiRecipeSaved(aiRecipe: aiRecipe));
    } catch (e) {
      emit(RecipeError('AI 레시피 저장에 실패했습니다: $e'));
    }
  }

  // AI 레시피를 일반 레시피로 변환
  Future<void> convertAiRecipeToRecipe(String aiRecipeId) async {
    try {
      emit(const RecipeLoading());

      final aiRecipe = await _aiRecipeRepository.getAiRecipeById(aiRecipeId);
      if (aiRecipe == null) {
        emit(const RecipeError('AI 레시피를 찾을 수 없습니다.'));
        return;
      }

      // AI 레시피를 일반 레시피 데이터로 변환
      final recipeData = aiRecipe.toRecipeData();

      // 일반 레시피로 추가
      await addRecipe(
        name: recipeData['name'],
        description: recipeData['description'],
        outputAmount: recipeData['outputAmount'],
        outputUnit: recipeData['outputUnit'],
        tagIds: recipeData['tagIds'],
        ingredients: [], // 재료는 별도로 추가해야 함
      );

      // AI 레시피를 변환됨으로 표시
      final recipes = await _recipeRepository.getAllRecipes();
      final latestRecipe = recipes.first;
      await _aiRecipeRepository.markAsConverted(aiRecipeId, latestRecipe.id);

      emit(AiRecipeConverted(aiRecipe: aiRecipe, recipe: latestRecipe));
    } catch (e) {
      emit(RecipeError('AI 레시피 변환에 실패했습니다: $e'));
    }
  }

  // AI 레시피 목록 조회
  Future<void> loadAiRecipes() async {
    try {
      emit(const RecipeLoading());

      final aiRecipes = await _aiRecipeRepository.getAllAiRecipes();

      if (aiRecipes.isEmpty) {
        emit(const AiRecipesEmpty());
      } else {
        emit(AiRecipesLoaded(aiRecipes: aiRecipes));
      }
    } catch (e) {
      emit(RecipeError('AI 레시피 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  // AI 레시피 검색
  Future<void> searchAiRecipes(String query) async {
    try {
      if (query.isEmpty) {
        await loadAiRecipes();
        return;
      }

      emit(const RecipeLoading());
      final aiRecipes = await _aiRecipeRepository.searchAiRecipes(query);

      if (aiRecipes.isEmpty) {
        emit(const AiRecipesEmpty());
      } else {
        emit(AiRecipesSearchResult(aiRecipes: aiRecipes, query: query));
      }
    } catch (e) {
      emit(RecipeError('AI 레시피 검색에 실패했습니다: $e'));
    }
  }

  // AI 레시피 통계 로드
  Future<void> loadAiRecipeStats() async {
    try {
      emit(const RecipeLoading());
      final stats = await _aiRecipeRepository.getAiRecipeStats();
      emit(AiRecipeStatsLoaded(stats: stats));
    } catch (e) {
      emit(RecipeError('AI 레시피 통계 로드에 실패했습니다: $e'));
    }
  }

  // AI 레시피 삭제
  Future<void> deleteAiRecipe(String aiRecipeId) async {
    try {
      emit(const RecipeLoading());

      await _aiRecipeRepository.deleteAiRecipe(aiRecipeId);
      final aiRecipes = await _aiRecipeRepository.getAllAiRecipes();

      if (aiRecipes.isEmpty) {
        emit(const AiRecipesEmpty());
      } else {
        emit(AiRecipesLoaded(aiRecipes: aiRecipes));
      }
    } catch (e) {
      emit(RecipeError('AI 레시피 삭제에 실패했습니다: $e'));
    }
  }

  // AI 레시피 상세 정보 조회
  Future<AiRecipe?> getAiRecipeDetail(String aiRecipeId) async {
    try {
      final aiRecipe = await _aiRecipeRepository.getAiRecipeById(aiRecipeId);
      return aiRecipe;
    } catch (e) {
      emit(RecipeError('AI 레시피 상세 정보를 불러오는데 실패했습니다: $e'));
      return null;
    }
  }

  // AI 판매 분석 수행
  Future<Map<String, dynamic>?> performAiSalesAnalysis(
    String recipeId, {
    String? userQuery,
    String? userLanguage,
  }) async {
    try {
      // 🔴 수정: AI 분석 중에도 기존 레시피 상태 유지
      // emit(const RecipeLoading()); // 제거

      // 레시피 정보 조회
      final recipe = await _recipeRepository.getRecipeById(recipeId);
      if (recipe == null) {
        emit(const RecipeError('레시피를 찾을 수 없습니다.'));
        return null;
      }

      // 레시피에 사용된 재료들의 상세 정보 조회
      final ingredients = <Ingredient>[];
      for (final recipeIngredient in recipe.ingredients) {
        final ingredient = await _ingredientRepository.getIngredientById(
          recipeIngredient.ingredientId,
        );
        if (ingredient != null) {
          ingredients.add(ingredient);
        }
      }

      // AI 판매 분석 수행
      final analysisResult = await _aiSalesAnalysisService.analyzeRecipeSales(
        recipe,
        ingredients,
        userQuery: userQuery,
        userLanguage: userLanguage,
      );

      // Analytics: AI 분석 사용 카운트 증가
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: 'ai_sales_analysis',
          parameters: {'recipe_id': recipeId},
        );
      } catch (_) {}

      return analysisResult;
    } catch (e) {
      emit(RecipeError('AI 판매 분석에 실패했습니다: $e'));
      return null;
    }
  }

  // 재료 원가 계산 (내부 메서드)
  Future<double> _calculateIngredientCost(
    Ingredient ingredient,
    double amount,
    Unit unit,
  ) async {
    // 재료의 구매 단위 정보 조회
    final purchaseUnit = await _unitRepository.getUnitById(
      ingredient.purchaseUnitId,
    );
    if (purchaseUnit == null) {
      throw Exception('구매 단위를 찾을 수 없습니다.');
    }

    // 기본 단위당 가격 계산
    final pricePerBaseUnit = ingredient.getPricePerBaseUnit(
      purchaseUnit.conversionFactor,
    );

    // 레시피에서 사용하는 수량을 기본 단위로 변환
    final baseAmount = amount * unit.conversionFactor;

    // 계산된 원가
    return pricePerBaseUnit * baseAmount;
  }

  // 레시피 총 원가 재계산 (내부 메서드)
  Future<void> _recalculateRecipeCost(String recipeId) async {
    final recipe = await _recipeRepository.getRecipeById(recipeId);
    if (recipe == null) return;
    final totalCost = await _recipeCostService.computeRecipeTotalCost(recipe);
    final updatedRecipe = recipe.copyWith(
      totalCost: totalCost,
      updatedAt: DateTime.now(),
    );

    await _recipeRepository.updateRecipe(updatedRecipe);
  }
}
