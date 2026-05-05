import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../data/index.dart';
import '../../model/index.dart';

import '../../service/recipe_cost_service.dart';
import '../../service/sauce_cost_service.dart';
import '../../service/ai_sales_analysis_service.dart';
import '../../service/in_app_review_service.dart';
import 'recipe_state.dart';
import '../../util/unit_converter.dart' as uc;

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
  static final Logger _log = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      lineLength: 100,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  RecipeCubit({
    required RecipeRepository recipeRepository,
    required IngredientRepository ingredientRepository,
    required UnitRepository unitRepository,
    required TagRepository tagRepository,
  })  : _recipeRepository = recipeRepository,
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

  RecipeRepository get recipeRepo => _recipeRepository;

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
    double sellPrice = 0,
    List<String> tagIds = const [],
    List<RecipeIngredient> ingredients = const [],
    List<RecipeSauce> sauces = const [],
  }) async {
    try {
      _log.i(
        '[addRecipe] 시작 name=$name sellPrice=$sellPrice '
        'ingredients=${ingredients.length} sauces=${sauces.length}',
      );
      emit(const RecipeLoading());

      final String recipeId = _uuid.v4();
      // RecipeIngredient.id 는 PRIMARY KEY 라 반드시 고유값 필요. 폼에서 빈 문자열이
      // 들어오면 ConflictAlgorithm.replace 로 모두 덮어쓰여 1개만 남는 버그가 있어
      // 여기서 일괄 부여한다.
      final ingredientsWithIds = ingredients.map((ing) {
        final hasId = ing.id.isNotEmpty;
        return ing.copyWith(
          id: hasId ? ing.id : _uuid.v4(),
          recipeId: recipeId,
        );
      }).toList();
      final recipe = Recipe(
        id: recipeId,
        name: name,
        description: description,
        outputAmount: outputAmount,
        outputUnit: outputUnit,
        totalCost: 0.0,
        sellPrice: sellPrice,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ingredients: ingredientsWithIds,
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
      _log.i(
        '[addRecipe] 완료 id=$recipeId totalCost=${created.totalCost} '
        'sellPrice=${created.sellPrice} → emit RecipeAdded',
      );
      emit(RecipeAdded(recipe: created, recipes: recipes));

      // Analytics: 레시피 추가 카운트 증가
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: 'recipe_add',
          parameters: {'count': 1},
        );
      } catch (_) {}
      // 레시피 생성 시점에 OS 인앱 리뷰 다이얼로그 요청.
      // canRequestReview 가 사용자 거부/완료 상태면 스킵하고, 표시 빈도는 OS rate limit 에 위임.
      unawaited(InAppReviewService().requestReview());
    } catch (e, st) {
      _log.e('[addRecipe] 실패', error: e, stackTrace: st);
      emit(RecipeError('레시피 추가에 실패했습니다: $e'));
    }
  }

  // 레시피 업데이트
  Future<void> updateRecipe(Recipe recipe) async {
    try {
      _log.i(
        '[updateRecipe] 시작 id=${recipe.id} name=${recipe.name} '
        'sellPrice=${recipe.sellPrice} totalCost=${recipe.totalCost} '
        'ingredients=${recipe.ingredients.length} sauces=${recipe.sauces.length}',
      );
      emit(const RecipeLoading());

      // 기존 레시피 정보 조회
      final existingRecipe = await _recipeRepository.getRecipeById(recipe.id);
      if (existingRecipe == null) {
        _log.w('[updateRecipe] 대상 없음 id=${recipe.id}');
        emit(const RecipeError('수정할 레시피를 찾을 수 없습니다.'));
        return;
      }
      _log.d(
        '[updateRecipe] 기존값 sellPrice=${existingRecipe.sellPrice} '
        'totalCost=${existingRecipe.totalCost}',
      );

      // RecipeIngredient.id / RecipeSauce.id 가 PRIMARY KEY 라 비어 있으면 중복
      // 충돌(ConflictAlgorithm.replace)로 1행만 남는 버그가 있어 여기서 보장.
      final normalizedIngredients = recipe.ingredients.map((ing) {
        return ing.copyWith(
          id: ing.id.isNotEmpty ? ing.id : _uuid.v4(),
          recipeId: recipe.id,
        );
      }).toList();
      final normalizedSauces = recipe.sauces.map((s) {
        return s.copyWith(
          id: s.id.isNotEmpty ? s.id : _uuid.v4(),
          recipeId: recipe.id,
        );
      }).toList();
      final normalizedRecipe = recipe.copyWith(
        ingredients: normalizedIngredients,
        sauces: normalizedSauces,
      );

      // 레시피 본체 + 재료/소스 관계 일괄 업데이트 (repo 가 트랜잭션 내에서
      // recipe_ingredients / recipe_sauces 를 delete-and-reinsert).
      _log.d('[updateRecipe] repo.updateRecipe 호출 (1차)');
      await _recipeRepository.updateRecipe(normalizedRecipe);

      // 레시피 원가 재계산
      _log.d('[updateRecipe] _recalculateRecipeCost 호출');
      await _recalculateRecipeCost(recipe.id);

      // 업데이트된 레시피 정보 조회
      final updatedRecipe = await _recipeRepository.getRecipeById(recipe.id);
      final recipes = await _recipeRepository.getAllRecipes();

      if (updatedRecipe != null) {
        _log.i(
          '[updateRecipe] 완료 id=${updatedRecipe.id} '
          'sellPrice=${updatedRecipe.sellPrice} totalCost=${updatedRecipe.totalCost} '
          '→ emit RecipeUpdated',
        );
        emit(RecipeUpdated(recipe: updatedRecipe, recipes: recipes));
      } else {
        _log.w('[updateRecipe] 재조회 실패 normalizedRecipe 로 emit');
        emit(RecipeUpdated(recipe: normalizedRecipe, recipes: recipes));
      }
    } catch (e, st) {
      _log.e('[updateRecipe] 실패', error: e, stackTrace: st);
      emit(RecipeError('레시피 수정에 실패했습니다: $e'));
    }
  }

  // 레시피 삭제
  Future<void> deleteRecipe(String id) async {
    try {
      _log.i('[deleteRecipe] 시작 id=$id');
      emit(const RecipeLoading());

      // 삭제 전에 태그 정보 가져오기
      final recipe = await _recipeRepository.getRecipeById(id);
      if (recipe != null) {
        _log.d(
          '[deleteRecipe] 대상 name=${recipe.name} tagIds=${recipe.tagIds}',
        );
        // 태그 사용 횟수 감소
        for (final tagId in recipe.tagIds) {
          await _tagRepository.decrementTagUsage(tagId);
        }
      } else {
        _log.w('[deleteRecipe] 대상 없음 (이미 삭제됐을 수 있음)');
      }

      await _recipeRepository.deleteRecipe(id);
      final recipes = await _recipeRepository.getAllRecipes();

      _log.i(
        '[deleteRecipe] 완료 id=$id 남은레시피=${recipes.length} '
        '→ emit RecipeDeleted',
      );
      emit(RecipeDeleted(deletedId: id, recipes: recipes));
    } catch (e, st) {
      _log.e('[deleteRecipe] 실패 id=$id', error: e, stackTrace: st);
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

  /// 재료 변경 후 영향받는 레시피들 원가 재계산 + 목록 emit.
  ///
  /// IngredientCubit 에서 재료 가격이 변경되면 호출됨. 직접 재료를 쓰는 레시피
  /// + 그 재료를 쓰는 소스를 포함한 레시피까지 모두 재계산해서 한 번에 emit.
  /// 재료 마스터 가격 변동에 따른 cascade 이므로 마진율 유지를 위해 sellPrice
  /// 도 자동 조정한다.
  Future<void> refreshAffectedByIngredient(String ingredientId) async {
    try {
      _log.i('[refreshAffectedByIngredient] 시작 ingredientId=$ingredientId');
      // 직접 재료를 쓰는 레시피들 — recipe_ingredients.calculated_cost 캐시를
      // 현재 마스터 단가로 먼저 갱신해야 totalCost 계산이 최신값을 반영함.
      final direct = await _recipeRepository.getRecipesByIngredient(
        ingredientId,
      );
      _log.d(
        '[refreshAffectedByIngredient] 직접 영향 레시피=${direct.length}',
      );
      for (final r in direct) {
        // _recalculateRecipeCost 내부에서 _refreshRecipeIngredientCosts 자동 호출.
        await _recalculateRecipeCost(r.id, autoAdjustSellPrice: true);
      }
      // 소스 경유로 영향받는 레시피들도 처리해야 하지만, 소스의 totalCost 가
      // 미리 갱신돼 있어야 의미가 있음 → SauceCubit 가 먼저 갱신한 뒤 호출하는
      // 흐름을 권장. 추가로, 모든 레시피를 한 번 더 recalc 해서 안전하게 동기화.
      final all = await _recipeRepository.getAllRecipes();
      for (final r in all) {
        await _recalculateRecipeCost(r.id, autoAdjustSellPrice: true);
      }
      final recipes = await _recipeRepository.getAllRecipes();
      _log.i(
        '[refreshAffectedByIngredient] 완료 전체레시피=${recipes.length} '
        '→ emit RecipeLoaded',
      );
      emit(RecipeLoaded(recipes: recipes));
    } catch (e, st) {
      _log.e('[refreshAffectedByIngredient] 실패', error: e, stackTrace: st);
      // refresh 실패는 critical 이 아니므로 silent.
    }
  }

  /// 해당 레시피의 모든 재료 행의 calculated_cost 를 현재 재료 마스터 단가
  /// 기준으로 다시 계산해 DB 에 반영한다. 재료 마스터 가격 변동 cascade 시
  /// 캐시된 값이 stale 해서 totalCost 가 갱신되지 않는 문제를 해결.
  Future<void> _refreshRecipeIngredientCosts(String recipeId) async {
    final recipe = await _recipeRepository.getRecipeById(recipeId);
    if (recipe == null) return;
    for (final item in recipe.ingredients) {
      final ingredient = await _ingredientRepository.getIngredientById(
        item.ingredientId,
      );
      if (ingredient == null) continue;
      final unit = await _unitRepository.getUnitById(item.unitId);
      if (unit == null) continue;
      final newCost =
          await _calculateIngredientCost(ingredient, item.amount, unit);
      await _recipeRepository.updateRecipeIngredientAmount(
        recipeId,
        item.ingredientId,
        item.amount,
        newCost,
      );
    }
  }

  /// 소스 변경 후 영향받는 레시피들 원가 재계산 + 목록 emit.
  /// 소스 원가 변동에 따른 cascade 이므로 마진율 유지를 위해 sellPrice 도
  /// 자동 조정한다.
  Future<void> refreshAffectedBySauce(String sauceId) async {
    try {
      final all = await _recipeRepository.getAllRecipes();
      for (final r in all) {
        if (r.sauces.any((rs) => rs.sauceId == sauceId)) {
          await _recalculateRecipeCost(r.id, autoAdjustSellPrice: true);
        }
      }
      final recipes = await _recipeRepository.getAllRecipes();
      emit(RecipeLoaded(recipes: recipes));
    } catch (_) {}
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
        estimatedCost:
            (aiRecipeData['estimated_cost']?['amount'] ?? 0.0).toDouble(),
        tags: List<String>.from(aiRecipeData['tags'] ?? []),
        creativityScore: aiRecipeData['creativity_score'],
        generatedAt: DateTime.now(),
        sourceIngredients: sourceIngredients,
        aiModel: 'gemini-3-flash-preview',
        promptVersion: '1.0',
      );

      await _aiRecipeRepository.insertAiRecipe(aiRecipe);

      emit(AiRecipeSaved(aiRecipe: aiRecipe));
    } catch (e) {
      emit(RecipeError('AI 레시피 저장에 실패했습니다: $e'));
    }
  }

  // AI 레시피를 일반 레시피로 변환
  Future<bool> convertAiRecipeToRecipe(
    dynamic aiRecipeOrId, [
    List<Map<String, dynamic>>? selectedIngredients,
  ]) async {
    try {
      emit(const RecipeLoading());

      AiRecipe? aiRecipe;
      String aiRecipeId;

      if (aiRecipeOrId is String) {
        aiRecipeId = aiRecipeOrId;
        aiRecipe = await _aiRecipeRepository.getAiRecipeById(aiRecipeId);
      } else if (aiRecipeOrId is AiRecipe) {
        aiRecipe = aiRecipeOrId;
        aiRecipeId = aiRecipe.id;
      } else {
        emit(const RecipeError('잘못된 매개변수 타입입니다.'));
        return false;
      }

      if (aiRecipe == null) {
        emit(const RecipeError('AI 레시피를 찾을 수 없습니다.'));
        return false;
      }

      // AI 레시피를 일반 레시피 데이터로 변환
      final recipeData = aiRecipe.toRecipeData();

      // 일반 레시피로 추가
      final String recipeId = _uuid.v4();
      final recipe = Recipe(
        id: recipeId,
        name: recipeData['name'],
        description: recipeData['description'],
        outputAmount: recipeData['outputAmount'],
        outputUnit: recipeData['outputUnit'],
        totalCost: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ingredients: [], // 아래에서 추가
        tagIds: List<String>.from(recipeData['tagIds'] ?? []),
      );

      await _recipeRepository.insertRecipe(recipe);

      // 재료 추가
      final List<Map<String, dynamic>> ingredientsToUse =
          selectedIngredients ?? recipeData['ingredients'];

      for (final ingredient in ingredientsToUse) {
        if (ingredient['ingredientId'] != null) {
          // 이미 매칭된 재료가 있는 경우
          await addIngredientToRecipe(
            recipeId: recipeId,
            ingredientId: ingredient['ingredientId'],
            amount: (ingredient['amount'] ?? 0.0).toDouble(),
            unitId: ingredient['unitId'] ?? 'g', // 기본 단위
          );
        }
      }

      // AI 레시피를 변환됨으로 표시
      final recipes = await _recipeRepository.getAllRecipes();
      final latestRecipe = recipes.firstWhere((r) => r.id == recipeId);
      await _aiRecipeRepository.markAsConverted(aiRecipeId, latestRecipe.id);

      emit(AiRecipeConverted(
        aiRecipe: aiRecipe,
        recipe: latestRecipe,
        recipes: recipes,
      ));

      return true;
    } catch (e) {
      emit(RecipeError('AI 레시피 변환에 실패했습니다: $e'));
      return false;
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
  //
  // [autoAdjustSellPrice] 가 true 면 마진율(=sellPrice/cost 비율) 유지를 위해
  // sellPrice 도 비례 조정한다. 재료/소스 마스터 변경으로 인한 cascade 흐름에서만
  // true 로 호출하고, 사용자가 명시적으로 sellPrice 를 입력하는 폼 흐름에서는
  // false(기본값) 로 둔다.
  Future<void> _recalculateRecipeCost(
    String recipeId, {
    bool autoAdjustSellPrice = false,
  }) async {
    // 항상 recipe_ingredients.calculated_cost 캐시를 현재 마스터 단가 기준으로
    // 먼저 갱신. 폼이 calculated_cost=0 으로 보내거나 마스터 가격이 바뀐 경우에도
    // totalCost 가 정확하게 합산되도록 보장.
    await _refreshRecipeIngredientCosts(recipeId);

    final recipe = await _recipeRepository.getRecipeById(recipeId);
    if (recipe == null) {
      _log.w('[_recalculateRecipeCost] 레시피 없음 id=$recipeId');
      return;
    }
    final oldCost = recipe.totalCost;
    final oldSellPrice = recipe.sellPrice;
    final totalCost = await _recipeCostService.computeRecipeTotalCost(recipe);

    double newSellPrice = oldSellPrice;
    if (autoAdjustSellPrice &&
        oldCost > 0 &&
        oldSellPrice > 0 &&
        oldCost != totalCost) {
      newSellPrice = oldSellPrice * (totalCost / oldCost);
    }

    _log.d(
      '[_recalculateRecipeCost] id=$recipeId oldCost=$oldCost→$totalCost '
      'oldSellPrice=$oldSellPrice→$newSellPrice '
      '(autoAdjust=$autoAdjustSellPrice)',
    );

    final updatedRecipe = recipe.copyWith(
      totalCost: totalCost,
      sellPrice: newSellPrice,
      updatedAt: DateTime.now(),
    );

    await _recipeRepository.updateRecipe(updatedRecipe);
  }
}
