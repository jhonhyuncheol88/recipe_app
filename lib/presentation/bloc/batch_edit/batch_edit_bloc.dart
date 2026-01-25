import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/ingredient.dart';
import '../../../domain/repositories/ingredient_repository.dart';
import '../../../domain/usecases/batch_update_ingredients_usecase.dart';
import 'batch_edit_event.dart';
import 'batch_edit_state.dart';

class BatchEditBloc extends Bloc<BatchEditEvent, BatchEditState> {
  final IngredientRepository repository;
  final BatchUpdateIngredientsUseCase batchUpdateUseCase;

  BatchEditBloc({
    required this.repository,
    required this.batchUpdateUseCase,
  }) : super(const BatchEditState()) {
    on<LoadIngredientsEvent>(_onLoadIngredients);
    on<UpdateIngredientFieldEvent>(_onUpdateField);
    on<ToggleDeleteIngredientEvent>(_onToggleDelete);
    on<SaveBatchChangesEvent>(_onSaveBatch);
  }

  Future<void> _onLoadIngredients(
    LoadIngredientsEvent event,
    Emitter<BatchEditState> emit,
  ) async {
    emit(state.copyWith(status: BatchEditStatus.loading));
    try {
      final ingredients = await repository.getIngredients();
      emit(state.copyWith(
        status: BatchEditStatus.loaded,
        ingredients: ingredients,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BatchEditStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onUpdateField(
    UpdateIngredientFieldEvent event,
    Emitter<BatchEditState> emit,
  ) {
    final originalIngredient =
        state.ingredients.firstWhere((e) => e.id == event.ingredientId);
    final currentEdited =
        state.editedIngredients[event.ingredientId] ?? originalIngredient;

    // copyWith는 null을 기존 값으로 유지하므로, 명시적으로 null을 설정하려면
    // Ingredient 생성자를 직접 사용해야 합니다.
    Ingredient updated;
    
    // expiryDate를 명시적으로 null로 설정해야 하는 경우 처리
    // (이벤트의 모든 필드가 null이고 expiryDate만 명시적으로 null로 설정하려는 경우)
    if (event.expiryDate == null && 
        currentEdited.expiryDate != null &&
        event.name == null &&
        event.purchasePrice == null &&
        event.purchaseAmount == null &&
        event.purchaseUnitId == null &&
        event.tagIds == null) {
      // 유통기한만 클리어하는 경우
      updated = Ingredient(
        id: currentEdited.id,
        name: currentEdited.name,
        purchasePrice: currentEdited.purchasePrice,
        purchaseAmount: currentEdited.purchaseAmount,
        purchaseUnitId: currentEdited.purchaseUnitId,
        expiryDate: null, // 명시적으로 null 설정
        createdAt: currentEdited.createdAt,
        tagIds: currentEdited.tagIds,
        animationX: currentEdited.animationX,
        animationY: currentEdited.animationY,
        isAnimationSettled: currentEdited.isAnimationSettled,
      );
    } else {
      // 일반적인 업데이트
      updated = currentEdited.copyWith(
        name: event.name,
        purchasePrice: event.purchasePrice,
        purchaseAmount: event.purchaseAmount,
        purchaseUnitId: event.purchaseUnitId,
        expiryDate: event.expiryDate,
        tagIds: event.tagIds,
      );
    }

    final newEditedMap = Map<String, Ingredient>.from(state.editedIngredients);

    // If the updated version is same as original, remove from edited map
    if (updated == originalIngredient) {
      newEditedMap.remove(event.ingredientId);
    } else {
      newEditedMap[event.ingredientId] = updated;
    }

    emit(state.copyWith(editedIngredients: newEditedMap));
  }

  void _onToggleDelete(
    ToggleDeleteIngredientEvent event,
    Emitter<BatchEditState> emit,
  ) {
    final newIdsToDelete = Set<String>.from(state.idsToDelete);
    if (newIdsToDelete.contains(event.id)) {
      newIdsToDelete.remove(event.id);
    } else {
      newIdsToDelete.add(event.id);
    }
    emit(state.copyWith(idsToDelete: newIdsToDelete));
  }

  Future<void> _onSaveBatch(
    SaveBatchChangesEvent event,
    Emitter<BatchEditState> emit,
  ) async {
    if (!state.hasChanges) return;

    emit(state.copyWith(status: BatchEditStatus.saving));
    try {
      await batchUpdateUseCase(
        ingredientsToUpdate: state.editedIngredients.values.toList(),
        idsToDelete: state.idsToDelete.toList(),
      );
      emit(state.copyWith(status: BatchEditStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: BatchEditStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
