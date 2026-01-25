import 'package:equatable/equatable.dart';

abstract class BatchEditEvent extends Equatable {
  const BatchEditEvent();

  @override
  List<Object?> get props => [];
}

class LoadIngredientsEvent extends BatchEditEvent {}

class UpdateIngredientFieldEvent extends BatchEditEvent {
  final String ingredientId;
  final String? name;
  final double? purchasePrice;
  final double? purchaseAmount;
  final String? purchaseUnitId;
  final DateTime? expiryDate;
  final List<String>? tagIds;

  const UpdateIngredientFieldEvent({
    required this.ingredientId,
    this.name,
    this.purchasePrice,
    this.purchaseAmount,
    this.purchaseUnitId,
    this.expiryDate,
    this.tagIds,
  });

  @override
  List<Object?> get props => [
        ingredientId,
        name,
        purchasePrice,
        purchaseAmount,
        purchaseUnitId,
        expiryDate,
        tagIds,
      ];
}

class ToggleDeleteIngredientEvent extends BatchEditEvent {
  final String id;

  const ToggleDeleteIngredientEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SaveBatchChangesEvent extends BatchEditEvent {}
