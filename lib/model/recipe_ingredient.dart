import 'package:equatable/equatable.dart';

class RecipeIngredient extends Equatable {
  final String id;
  final String recipeId;
  final String ingredientId;
  final double amount;
  final String unitId;
  final double calculatedCost;

  RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.amount,
    required this.unitId,
    required this.calculatedCost,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'ingredient_id': ingredientId,
      'amount': amount,
      'unit_id': unitId,
      'calculated_cost': calculatedCost,
    };
  }

  // JSON 역직렬화
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'],
      recipeId: json['recipe_id'],
      ingredientId: json['ingredient_id'],
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'].toDouble(),
      unitId: json['unit_id'],
      calculatedCost: (json['calculated_cost'] is int)
          ? (json['calculated_cost'] as int).toDouble()
          : json['calculated_cost'].toDouble(),
    );
  }

  // 복사본 생성
  RecipeIngredient copyWith({
    String? id,
    String? recipeId,
    String? ingredientId,
    double? amount,
    String? unitId,
    double? calculatedCost,
  }) {
    return RecipeIngredient(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      ingredientId: ingredientId ?? this.ingredientId,
      amount: amount ?? this.amount,
      unitId: unitId ?? this.unitId,
      calculatedCost: calculatedCost ?? this.calculatedCost,
    );
  }

  // 원가 재계산
  RecipeIngredient recalculateCost(double newCalculatedCost) {
    return copyWith(calculatedCost: newCalculatedCost);
  }

  @override
  String toString() {
    return 'RecipeIngredient(id: $id, ingredientId: $ingredientId, amount: $amount, cost: $calculatedCost)';
  }

  @override
  List<Object?> get props => [
    id,
    recipeId,
    ingredientId,
    amount,
    unitId,
    calculatedCost,
  ];
}
