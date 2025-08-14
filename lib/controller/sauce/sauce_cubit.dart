import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:uuid/uuid.dart';
import '../../data/index.dart';
import '../recipe/recipe_cubit.dart';
import '../../model/index.dart';
import '../../service/sauce_cost_service.dart';
import 'sauce_state.dart';

class SauceCubit extends Cubit<SauceState> {
  final SauceRepository _sauceRepository;
  final IngredientRepository _ingredientRepository;
  final SauceCostService _sauceCostService;
  final Uuid _uuid = const Uuid();

  SauceCubit({
    required SauceRepository sauceRepository,
    required IngredientRepository ingredientRepository,
    required SauceCostService sauceCostService,
  }) : _sauceRepository = sauceRepository,
       _ingredientRepository = ingredientRepository,
       _sauceCostService = sauceCostService,
       super(const SauceInitial());

  Future<void> loadSauces() async {
    try {
      emit(const SauceLoading());
      final sauces = await _sauceRepository.getAllSauces();
      if (sauces.isEmpty) {
        emit(const SauceEmpty());
      } else {
        emit(SauceLoaded(sauces: sauces));
      }
    } catch (e) {
      emit(SauceError('소스 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  Future<void> addSauce({
    required String name,
    String description = '',
    String? imagePath,
  }) async {
    try {
      emit(const SauceLoading());
      final sauce = Sauce(
        id: _uuid.v4(),
        name: name,
        description: description,
        totalWeight: 0,
        totalCost: 0,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );
      await _sauceRepository.insertSauce(sauce);
      final sauces = await _sauceRepository.getAllSauces();
      emit(SauceAdded(sauce: sauce, sauces: sauces));
      // Analytics: 소스 추가 카운트 증가
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: 'sauce_add',
          parameters: {'count': 1},
        );
      } catch (_) {}
    } catch (e) {
      emit(SauceError('소스 추가에 실패했습니다: $e'));
    }
  }

  Future<void> updateSauce(Sauce sauce) async {
    try {
      emit(const SauceLoading());
      await _sauceRepository.updateSauce(sauce);
      final sauces = await _sauceRepository.getAllSauces();
      // 소스 변경이 레시피 원가에 영향 → 해당 소스를 사용하는 레시피 재계산
      try {
        final recipeRepo = RecipeRepository();
        final affectedRecipeIds = await recipeRepo.getRecipeIdsBySauce(
          sauce.id,
        );
        final recipeCubit = RecipeCubit(
          recipeRepository: recipeRepo,
          ingredientRepository: _ingredientRepository,
          unitRepository: UnitRepository(),
          tagRepository: TagRepository(),
        );
        for (final rid in affectedRecipeIds) {
          await recipeCubit.recalculateRecipeCost(rid);
        }
      } catch (_) {}
      emit(SauceUpdatedState(sauce: sauce, sauces: sauces));
    } catch (e) {
      emit(SauceError('소스 수정에 실패했습니다: $e'));
    }
  }

  Future<void> deleteSauce(String sauceId) async {
    try {
      emit(const SauceLoading());
      await _sauceRepository.deleteSauce(sauceId);
      final sauces = await _sauceRepository.getAllSauces();
      // 레시피에서 해당 소스 삭제 및 재계산
      try {
        final recipeRepo = RecipeRepository();
        await recipeRepo.removeRecipeSaucesBySauceId(sauceId);
        final recipes = await recipeRepo.getAllRecipes();
        final recipeCubit = RecipeCubit(
          recipeRepository: recipeRepo,
          ingredientRepository: _ingredientRepository,
          unitRepository: UnitRepository(),
          tagRepository: TagRepository(),
        );
        for (final r in recipes) {
          await recipeCubit.recalculateRecipeCost(r.id);
        }
      } catch (_) {}
      emit(SauceDeleted(sauceId: sauceId, sauces: sauces));
    } catch (e) {
      emit(SauceError('소스 삭제에 실패했습니다: $e'));
    }
  }

  // UI에서 사용: 특정 소스의 구성 재료 조회
  Future<List<SauceIngredient>> getIngredientsForSauce(String sauceId) {
    return _sauceRepository.getIngredientsForSauce(sauceId);
  }

  Future<void> addIngredientToSauce({
    required String sauceId,
    required String ingredientId,
    required double amount,
    required String unitId,
  }) async {
    try {
      emit(const SauceLoading());
      final ingredient = await _ingredientRepository.getIngredientById(
        ingredientId,
      );
      if (ingredient == null) {
        emit(const SauceError('재료를 찾을 수 없습니다.'));
        return;
      }

      final item = SauceIngredient(
        id: _uuid.v4(),
        sauceId: sauceId,
        ingredientId: ingredientId,
        amount: amount,
        unitId: unitId,
      );
      await _sauceRepository.addIngredientToSauce(item);

      // 소스 총원가/중량 재계산 후 저장
      await _sauceCostService.recomputeAndSaveSauce(sauceId);

      // 해당 소스를 사용하는 레시피 재계산
      try {
        final recipeRepo = RecipeRepository();
        final affectedRecipeIds = await recipeRepo.getRecipeIdsBySauce(sauceId);
        final recipeCubit = RecipeCubit(
          recipeRepository: recipeRepo,
          ingredientRepository: _ingredientRepository,
          unitRepository: UnitRepository(),
          tagRepository: TagRepository(),
        );
        for (final rid in affectedRecipeIds) {
          await recipeCubit.recalculateRecipeCost(rid);
        }
      } catch (_) {}
      final sauces = await _sauceRepository.getAllSauces();
      emit(SauceLoaded(sauces: sauces));
    } catch (e) {
      emit(SauceError('소스에 재료 추가에 실패했습니다: $e'));
    }
  }

  Future<void> removeIngredientFromSauce({
    required String sauceId,
    required String ingredientId,
  }) async {
    try {
      emit(const SauceLoading());
      await _sauceRepository.removeIngredientFromSauce(sauceId, ingredientId);
      await _sauceCostService.recomputeAndSaveSauce(sauceId);
      // 해당 소스를 사용하는 레시피 재계산
      try {
        final recipeRepo = RecipeRepository();
        final affectedRecipeIds = await recipeRepo.getRecipeIdsBySauce(sauceId);
        final recipeCubit = RecipeCubit(
          recipeRepository: recipeRepo,
          ingredientRepository: _ingredientRepository,
          unitRepository: UnitRepository(),
          tagRepository: TagRepository(),
        );
        for (final rid in affectedRecipeIds) {
          await recipeCubit.recalculateRecipeCost(rid);
        }
      } catch (_) {}
      final sauces = await _sauceRepository.getAllSauces();
      emit(SauceLoaded(sauces: sauces));
    } catch (e) {
      emit(SauceError('소스에서 재료 제거에 실패했습니다: $e'));
    }
  }

  Future<void> removeSauceIngredientById({
    required String sauceId,
    required String sauceIngredientId,
  }) async {
    try {
      emit(const SauceLoading());
      await _sauceRepository.removeSauceIngredientById(sauceIngredientId);
      await _sauceCostService.recomputeAndSaveSauce(sauceId);
      // 해당 소스를 사용하는 레시피 재계산
      try {
        final recipeRepo = RecipeRepository();
        final affectedRecipeIds = await recipeRepo.getRecipeIdsBySauce(sauceId);
        final recipeCubit = RecipeCubit(
          recipeRepository: recipeRepo,
          ingredientRepository: _ingredientRepository,
          unitRepository: UnitRepository(),
          tagRepository: TagRepository(),
        );
        for (final rid in affectedRecipeIds) {
          await recipeCubit.recalculateRecipeCost(rid);
        }
      } catch (_) {}
      final sauces = await _sauceRepository.getAllSauces();
      emit(SauceLoaded(sauces: sauces));
    } catch (e) {
      emit(SauceError('소스에서 재료 제거에 실패했습니다: $e'));
    }
  }

  Future<void> updateSauceIngredient({
    required String sauceId,
    required String ingredientId,
    double? amount,
    String? unitId,
  }) async {
    try {
      emit(const SauceLoading());
      await _sauceRepository.updateSauceIngredient(
        sauceId,
        ingredientId,
        amount: amount,
        unitId: unitId,
      );
      await _sauceCostService.recomputeAndSaveSauce(sauceId);
      // 해당 소스를 사용하는 레시피 재계산
      try {
        final recipeRepo = RecipeRepository();
        final affectedRecipeIds = await recipeRepo.getRecipeIdsBySauce(sauceId);
        final recipeCubit = RecipeCubit(
          recipeRepository: recipeRepo,
          ingredientRepository: _ingredientRepository,
          unitRepository: UnitRepository(),
          tagRepository: TagRepository(),
        );
        for (final rid in affectedRecipeIds) {
          await recipeCubit.recalculateRecipeCost(rid);
        }
      } catch (_) {}
      final sauces = await _sauceRepository.getAllSauces();
      emit(SauceLoaded(sauces: sauces));
    } catch (e) {
      emit(SauceError('소스 구성 재료 수정에 실패했습니다: $e'));
    }
  }
}
