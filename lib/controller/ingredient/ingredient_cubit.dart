import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/index.dart';
import '../../model/index.dart';
import '../../model/ocr_result.dart';

import 'ingredient_state.dart';

class IngredientCubit extends Cubit<IngredientState> {
  final IngredientRepository _ingredientRepository;
  final TagRepository _tagRepository;
  final Uuid _uuid = const Uuid();

  IngredientCubit({
    required IngredientRepository ingredientRepository,
    required TagRepository tagRepository,
  }) : _ingredientRepository = ingredientRepository,
       _tagRepository = tagRepository,
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

      developer.log('재료 목록 다시 로드 시작', name: 'IngredientCubit');
      final ingredients = await _ingredientRepository.getAllIngredients();
      developer.log(
        '재료 목록 로드 완료: ${ingredients.length}개',
        name: 'IngredientCubit',
      );

      emit(IngredientLoaded(ingredients: ingredients));
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
      final ingredients = await _ingredientRepository.getAllIngredients();

      emit(IngredientLoaded(ingredients: ingredients));
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
      final ingredients = await _ingredientRepository.getAllIngredients();

      emit(IngredientLoaded(ingredients: ingredients));
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
        if (item.isValid && item.name.isNotEmpty && item.price > 0) {
          try {
            final ingredient = Ingredient(
              id: _uuid.v4(),
              name: item.name,
              purchasePrice: item.price,
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
}
