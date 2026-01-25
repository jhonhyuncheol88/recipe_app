import 'package:equatable/equatable.dart';
import '../../../domain/entities/ingredient.dart';

enum BatchEditStatus { initial, loading, loaded, saving, success, failure }

class BatchEditState extends Equatable {
  final BatchEditStatus status;
  final List<Ingredient> ingredients;
  final Map<String, Ingredient> editedIngredients;
  final Set<String> idsToDelete;
  final String? errorMessage;

  const BatchEditState({
    this.status = BatchEditStatus.initial,
    this.ingredients = const [],
    this.editedIngredients = const {},
    this.idsToDelete = const {},
    this.errorMessage,
  });

  bool get hasChanges => editedIngredients.isNotEmpty || idsToDelete.isNotEmpty;

  BatchEditState copyWith({
    BatchEditStatus? status,
    List<Ingredient>? ingredients,
    Map<String, Ingredient>? editedIngredients,
    Set<String>? idsToDelete,
    String? errorMessage,
  }) {
    return BatchEditState(
      status: status ?? this.status,
      ingredients: ingredients ?? this.ingredients,
      editedIngredients: editedIngredients ?? this.editedIngredients,
      idsToDelete: idsToDelete ?? this.idsToDelete,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, ingredients, editedIngredients, idsToDelete, errorMessage];
}
