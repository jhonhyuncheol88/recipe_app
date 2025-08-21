import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:uuid/uuid.dart';
import '../../data/index.dart';
import '../recipe/recipe_cubit.dart';
import '../../model/index.dart';
import '../../model/ocr_result.dart';
import '../notification/expiry_notification_cubit.dart';

import 'ingredient_state.dart';

class IngredientCubit extends Cubit<IngredientState> {
  final IngredientRepository _ingredientRepository;
  final TagRepository _tagRepository;
  final Uuid _uuid = const Uuid();
  final ExpiryNotificationCubit? _expiryNotificationCubit;

  IngredientCubit({
    required IngredientRepository ingredientRepository,
    required TagRepository tagRepository,
    ExpiryNotificationCubit? expiryNotificationCubit,
  }) : _ingredientRepository = ingredientRepository,
       _tagRepository = tagRepository,
       _expiryNotificationCubit = expiryNotificationCubit,
       super(const IngredientInitial());

  // 재료 목록 로드
  Future<void> loadIngredients() async {
    try {
      developer.log('재료 목록 로드 시작', name: 'IngredientCubit');
      emit(const IngredientLoading());
      final ingredients = await _ingredientRepository.getAllIngredients();
      developer.log(
        '재료 목록 로드 완료: ${ingredients.length}개',
        name: 'IngredientCubit',
      );

      if (ingredients.isEmpty) {
        emit(const IngredientEmpty());
      } else {
        emit(IngredientLoaded(ingredients: ingredients));
      }
    } catch (e) {
      developer.log('재료 목록 로드 실패: $e', name: 'IngredientCubit');
      emit(IngredientError('재료 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  // 재료 추가
  Future<void> addIngredient({
    required String name,
    required double purchasePrice,
    required double purchaseAmount,
    required String purchaseUnitId,
    DateTime? expiryDate,
    List<String> tagIds = const [],
  }) async {
    try {
      developer.log('재료 추가 시작', name: 'IngredientCubit');
      developer.log(
        '입력 데이터: name=$name, price=$purchasePrice, amount=$purchaseAmount, unit=$purchaseUnitId',
        name: 'IngredientCubit',
      );

      emit(const IngredientLoading());

      final ingredient = Ingredient(
        id: _uuid.v4(),
        name: name,
        purchasePrice: purchasePrice,
        purchaseAmount: purchaseAmount,
        purchaseUnitId: purchaseUnitId,
        expiryDate: expiryDate,
        createdAt: DateTime.now(),
        tagIds: tagIds,
      );

      developer.log(
        'Ingredient 객체 생성 완료: ${ingredient.toJson()}',
        name: 'IngredientCubit',
      );

      await _ingredientRepository.insertIngredient(ingredient);

      // 태그 사용 횟수 증가
      for (final tagId in tagIds) {
        try {
          developer.log('태그 사용 횟수 증가: $tagId', name: 'IngredientCubit');
          await _tagRepository.incrementTagUsage(tagId);
        } catch (e) {
          // 태그가 존재하지 않을 수 있음, 무시
          developer.log('태그 사용 횟수 증가 실패: $e', name: 'IngredientCubit');
        }
      }

      developer.log('재료 목록 다시 로드 시작 (유통기한 순으로 정렬)', name: 'IngredientCubit');
      final ingredients = await _ingredientRepository.getAllIngredients();

      // 유통기한 순 정렬 확인을 위한 로그
      if (ingredients.isNotEmpty) {
        final withExpiry = ingredients
            .where((i) => i.expiryDate != null)
            .toList();
        final withoutExpiry = ingredients
            .where((i) => i.expiryDate == null)
            .toList();

        if (withExpiry.isNotEmpty) {
          developer.log(
            '첫 번째 재료 (유통기한 있음): ${withExpiry.first.name} - ${withExpiry.first.expiryDate}',
            name: 'IngredientCubit',
          );
        }
        if (withoutExpiry.isNotEmpty) {
          developer.log(
            '마지막 재료 (유통기한 없음): ${withoutExpiry.last.name}',
            name: 'IngredientCubit',
          );
        }

        developer.log(
          '재료 목록 로드 완료: ${ingredients.length}개 (유통기한 있음: ${withExpiry.length}개, 유통기한 없음: ${withoutExpiry.length}개)',
          name: 'IngredientCubit',
        );
      }

      emit(IngredientLoaded(ingredients: ingredients));
      // 재료 추가 후 알림 스케줄 갱신 (유통기한이 있는 항목 대상)
      try {
        if (ingredient.expiryDate != null &&
            _expiryNotificationCubit?.notificationsEnabled == true) {
          await _expiryNotificationCubit!.loadExpiryNotifications();
        }
      } catch (_) {}
      // Analytics: 재료 추가 카운트 증가
      try {
        await FirebaseAnalytics.instance.logEvent(
          name: 'ingredient_add',
          parameters: {'count': 1},
        );
      } catch (_) {}
      developer.log('재료 추가 완료', name: 'IngredientCubit');
    } catch (e) {
      developer.log('재료 추가 실패: $e', name: 'IngredientCubit');
      emit(IngredientError('재료 추가에 실패했습니다: $e'));
    }
  }

  // 재료 업데이트
  Future<void> updateIngredient(Ingredient ingredient) async {
    try {
      emit(const IngredientLoading());

      await _ingredientRepository.updateIngredient(ingredient);
      developer.log('재료 수정 후 목록 다시 로드 (유통기한 순으로 정렬)', name: 'IngredientCubit');
      final ingredients = await _ingredientRepository.getAllIngredients();

      // 재료 변경이 소스/레시피 비용에 영향 → 관련 레시피들 재계산
      try {
        final recipeRepo = RecipeRepository();
        final recipeCubit = RecipeCubit(
          recipeRepository: recipeRepo,
          ingredientRepository: _ingredientRepository,
          unitRepository: UnitRepository(),
          tagRepository: _tagRepository,
        );
        final affectedRecipes = await recipeRepo.getRecipesByIngredient(
          ingredient.id,
        );
        for (final r in affectedRecipes) {
          await recipeCubit.recalculateRecipeCost(r.id);
        }
      } catch (_) {}

      emit(IngredientLoaded(ingredients: ingredients));
      // 재료 수정 후 알림 스케줄 갱신 (유통기한 변경 가능)
      try {
        if (ingredient.expiryDate != null &&
            _expiryNotificationCubit?.notificationsEnabled == true) {
          await _expiryNotificationCubit!.loadExpiryNotifications();
        }
      } catch (_) {}
    } catch (e) {
      emit(IngredientError('재료 수정에 실패했습니다: $e'));
    }
  }

  // 재료 삭제
  Future<void> deleteIngredient(String id) async {
    try {
      emit(const IngredientLoading());

      // 삭제 전에 태그 정보 가져오기
      final ingredient = await _ingredientRepository.getIngredientById(id);
      if (ingredient != null) {
        // 태그 사용 횟수 감소
        for (final tagId in ingredient.tagIds) {
          try {
            await _tagRepository.decrementTagUsage(tagId);
          } catch (e) {
            // 태그가 존재하지 않을 수 있음, 무시
            developer.log('태그 사용 횟수 감소 실패: $e', name: 'IngredientCubit');
          }
        }
      }

      await _ingredientRepository.deleteIngredient(id);

      // 관련 레시피에서 해당 재료 항목 제거 후 재계산
      try {
        final recipeRepo = RecipeRepository();
        await recipeRepo.removeRecipeIngredientsByIngredientId(id);
        final recipes = await recipeRepo.getAllRecipes();
        final recipeCubit = RecipeCubit(
          recipeRepository: recipeRepo,
          ingredientRepository: _ingredientRepository,
          unitRepository: UnitRepository(),
          tagRepository: _tagRepository,
        );
        for (final r in recipes) {
          await recipeCubit.recalculateRecipeCost(r.id);
        }
      } catch (_) {}

      developer.log('재료 삭제 후 목록 다시 로드 (유통기한 순으로 정렬)', name: 'IngredientCubit');
      final ingredients = await _ingredientRepository.getAllIngredients();
      emit(IngredientLoaded(ingredients: ingredients));
      // 재료 삭제 후 알림 스케줄 갱신
      try {
        if (_expiryNotificationCubit?.notificationsEnabled == true) {
          await _expiryNotificationCubit!.loadExpiryNotifications();
        }
      } catch (_) {}
    } catch (e) {
      emit(IngredientError('재료 삭제에 실패했습니다: $e'));
    }
  }

  // 재료 검색
  Future<void> searchIngredients(String query) async {
    try {
      if (query.isEmpty) {
        await loadIngredients();
        return;
      }

      emit(const IngredientLoading());
      final ingredients = await _ingredientRepository.searchIngredientsByName(
        query,
      );

      if (ingredients.isEmpty) {
        emit(const IngredientEmpty());
      } else {
        emit(IngredientLoaded(ingredients: ingredients));
      }
    } catch (e) {
      emit(IngredientError('재료 검색에 실패했습니다: $e'));
    }
  }

  // 유통기한 상태별 필터링
  Future<void> filterIngredientsByExpiryStatus(ExpiryStatus status) async {
    try {
      emit(const IngredientLoading());
      final ingredients = await _ingredientRepository
          .getIngredientsByExpiryStatus(status);

      if (ingredients.isEmpty) {
        emit(const IngredientEmpty());
      } else {
        emit(IngredientLoaded(ingredients: ingredients));
      }
    } catch (e) {
      emit(IngredientError('재료 필터링에 실패했습니다: $e'));
    }
  }

  // 태그별 필터링
  Future<void> filterIngredientsByTag(String tagId) async {
    try {
      emit(const IngredientLoading());
      final ingredientIds = await _tagRepository.getIngredientIdsByTag(tagId);

      if (ingredientIds.isEmpty) {
        emit(const IngredientEmpty());
      } else {
        final ingredients = <Ingredient>[];
        for (final id in ingredientIds) {
          try {
            final ingredient = await _ingredientRepository.getIngredientById(
              id,
            );
            if (ingredient != null) {
              ingredients.add(ingredient);
            }
          } catch (e) {
            // 개별 재료 조회 실패 시 무시
            developer.log('재료 조회 실패: $e', name: 'IngredientCubit');
          }
        }

        if (ingredients.isEmpty) {
          emit(const IngredientEmpty());
        } else {
          emit(IngredientLoaded(ingredients: ingredients));
        }
      }
    } catch (e) {
      emit(IngredientError('태그별 필터링에 실패했습니다: $e'));
    }
  }

  // 여러 태그로 필터링
  Future<void> filterIngredientsByTags(List<String> tagIds) async {
    try {
      emit(const IngredientLoading());

      if (tagIds.isEmpty) {
        await loadIngredients();
        return;
      }

      final allIngredients = await _ingredientRepository.getAllIngredients();
      final filteredIngredients = allIngredients.where((ingredient) {
        return tagIds.every((tagId) => ingredient.tagIds.contains(tagId));
      }).toList();

      if (filteredIngredients.isEmpty) {
        emit(const IngredientEmpty());
      } else {
        emit(IngredientLoaded(ingredients: filteredIngredients));
      }
    } catch (e) {
      emit(IngredientError('태그 필터링에 실패했습니다: $e'));
    }
  }

  // 재료에 태그 추가
  Future<void> addTagToIngredient(String ingredientId, String tagId) async {
    try {
      emit(const IngredientLoading());

      await _tagRepository.addTagToIngredient(ingredientId, tagId);
      final ingredients = await _ingredientRepository.getAllIngredients();

      emit(IngredientLoaded(ingredients: ingredients));
    } catch (e) {
      emit(IngredientError('태그 추가에 실패했습니다: $e'));
    }
  }

  // 재료에서 태그 제거
  Future<void> removeTagFromIngredient(
    String ingredientId,
    String tagId,
  ) async {
    try {
      emit(const IngredientLoading());

      await _tagRepository.removeTagFromIngredient(ingredientId, tagId);
      final ingredients = await _ingredientRepository.getAllIngredients();

      emit(IngredientLoaded(ingredients: ingredients));
    } catch (e) {
      emit(IngredientError('태그 제거에 실패했습니다: $e'));
    }
  }

  // 재료 태그 업데이트
  Future<void> updateIngredientTags(
    String ingredientId,
    List<String> tagIds,
  ) async {
    try {
      emit(const IngredientLoading());

      final ingredient = await _ingredientRepository.getIngredientById(
        ingredientId,
      );
      if (ingredient != null) {
        final updatedIngredient = ingredient.updateTags(tagIds);
        await _ingredientRepository.updateIngredient(updatedIngredient);

        final ingredients = await _ingredientRepository.getAllIngredients();

        emit(IngredientLoaded(ingredients: ingredients));
      }
    } catch (e) {
      emit(IngredientError('태그 업데이트에 실패했습니다: $e'));
    }
  }

  // 유통기한이 임박한 재료 조회
  Future<void> loadExpiringIngredients({int days = 7}) async {
    try {
      emit(const IngredientLoading());
      final ingredients = await _ingredientRepository.getExpiringIngredients(
        days: days,
      );

      if (ingredients.isEmpty) {
        emit(const IngredientEmpty());
      } else {
        emit(IngredientLoaded(ingredients: ingredients));
      }
    } catch (e) {
      emit(IngredientError('임박한 재료 조회에 실패했습니다: $e'));
    }
  }

  // 만료된 재료 조회
  Future<void> loadExpiredIngredients() async {
    try {
      emit(const IngredientLoading());
      final ingredients = await _ingredientRepository.getExpiredIngredients();

      if (ingredients.isEmpty) {
        emit(const IngredientEmpty());
      } else {
        emit(IngredientLoaded(ingredients: ingredients));
      }
    } catch (e) {
      emit(IngredientError('만료된 재료 조회에 실패했습니다: $e'));
    }
  }

  // 재료 새로고침
  Future<void> refreshIngredients() async {
    await loadIngredients();
  }

  // OCR 결과로부터 재료들 추가
  Future<void> addIngredientsFromOcr(List<ScannedItem> scannedItems) async {
    try {
      emit(const IngredientLoading());

      for (final item in scannedItems) {
        if (item.isValid &&
            item.name.isNotEmpty &&
            item.price != null &&
            item.price! > 0) {
          try {
            final ingredient = Ingredient(
              id: _uuid.v4(),
              name: item.name,
              purchasePrice: item.price ?? 0.0,
              purchaseAmount: item.quantity ?? 1.0,
              purchaseUnitId: item.unit ?? '개', // 기본값, 사용자가 수정 가능
              createdAt: DateTime.now(),
            );

            await _ingredientRepository.insertIngredient(ingredient);
          } catch (e) {
            // 개별 재료 추가 실패 시 무시
            developer.log('재료 추가 실패: $e', name: 'IngredientCubit');
          }
        }
      }

      final ingredients = await _ingredientRepository.getAllIngredients();
      emit(IngredientLoaded(ingredients: ingredients));
    } catch (e) {
      emit(IngredientError('OCR 결과 처리에 실패했습니다: $e'));
    }
  }

  // Gemini 분석 결과로부터 재료들을 일괄 추가
  Future<void> addIngredientsFromGeminiAnalysis(
    List<Map<String, dynamic>> geminiIngredients,
  ) async {
    try {
      emit(const IngredientLoading());
      int successCount = 0;

      for (final ingredientData in geminiIngredients) {
        try {
          final name = ingredientData['name'] as String? ?? '';
          final suggestedPrice =
              ingredientData['suggested_price'] as double? ?? 0.0;
          final suggestedAmount =
              ingredientData['suggested_amount'] as double? ?? 0.0;
          final suggestedUnit =
              ingredientData['suggested_unit'] as String? ?? '개';
          final category = ingredientData['category'] as String? ?? '기타';

          if (name.isNotEmpty && suggestedPrice > 0 && suggestedAmount > 0) {
            final ingredient = Ingredient(
              id: _uuid.v4(),
              name: name,
              purchasePrice: suggestedPrice,
              purchaseAmount: suggestedAmount,
              purchaseUnitId: suggestedUnit,
              createdAt: DateTime.now(),
              tagIds: [], // 기본값, 사용자가 나중에 설정 가능
            );

            await _ingredientRepository.insertIngredient(ingredient);
            successCount++;
          }
        } catch (e) {
          // 개별 재료 추가 실패 시 무시
          developer.log('Gemini 재료 추가 실패: $e', name: 'IngredientCubit');
        }
      }

      if (successCount > 0) {
        final ingredients = await _ingredientRepository.getAllIngredients();
        emit(IngredientLoaded(ingredients: ingredients));
        developer.log(
          'Gemini 분석 결과로 $successCount개 재료 추가 완료',
          name: 'IngredientCubit',
        );
      } else {
        emit(IngredientError('추가할 수 있는 재료가 없습니다.'));
      }
    } catch (e) {
      emit(IngredientError('Gemini 분석 결과 처리에 실패했습니다: $e'));
    }
  }

  // 누락된 재료들을 일괄 추가 페이지로 전달하기 위한 데이터 준비
  List<Map<String, dynamic>> prepareMissingIngredientsForBulkAdd(
    List<String> missingIngredientNames,
  ) {
    try {
      final ingredients = <Map<String, dynamic>>[];

      for (final name in missingIngredientNames) {
        if (name.trim().isNotEmpty) {
          ingredients.add({
            'name': name.trim(), // 이름만 전달
          });
        }
      }

      return ingredients;
    } catch (e) {
      developer.log('누락된 재료 데이터 준비 실패: $e', name: 'IngredientCubit');
      return [];
    }
  }
}
