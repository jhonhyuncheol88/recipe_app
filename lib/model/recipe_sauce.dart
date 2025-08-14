import 'package:equatable/equatable.dart';

class RecipeSauce extends Equatable {
  final String id;
  final String recipeId;
  final String sauceId;
  final double amount;
  final String unitId;

  const RecipeSauce({
    required this.id,
    required this.recipeId,
    required this.sauceId,
    required this.amount,
    required this.unitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'sauce_id': sauceId,
      'amount': amount,
      'unit_id': unitId,
    };
  }

  factory RecipeSauce.fromJson(Map<String, dynamic> json) {
    return RecipeSauce(
      id: json['id'],
      recipeId: json['recipe_id'],
      sauceId: json['sauce_id'],
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'].toDouble(),
      unitId: json['unit_id'],
    );
  }

  RecipeSauce copyWith({
    String? id,
    String? recipeId,
    String? sauceId,
    double? amount,
    String? unitId,
  }) {
    return RecipeSauce(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      sauceId: sauceId ?? this.sauceId,
      amount: amount ?? this.amount,
      unitId: unitId ?? this.unitId,
    );
  }

  @override
  List<Object?> get props => [id, recipeId, sauceId, amount, unitId];
}
