import 'package:equatable/equatable.dart';

class SauceIngredient extends Equatable {
  final String id;
  final String sauceId;
  final String ingredientId;
  final double amount; // 사용량
  final String unitId; // 단위 ID

  const SauceIngredient({
    required this.id,
    required this.sauceId,
    required this.ingredientId,
    required this.amount,
    required this.unitId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sauce_id': sauceId,
      'ingredient_id': ingredientId,
      'amount': amount,
      'unit_id': unitId,
    };
  }

  factory SauceIngredient.fromJson(Map<String, dynamic> json) {
    return SauceIngredient(
      id: json['id'],
      sauceId: json['sauce_id'],
      ingredientId: json['ingredient_id'],
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'].toDouble(),
      unitId: json['unit_id'],
    );
  }

  SauceIngredient copyWith({
    String? id,
    String? sauceId,
    String? ingredientId,
    double? amount,
    String? unitId,
  }) {
    return SauceIngredient(
      id: id ?? this.id,
      sauceId: sauceId ?? this.sauceId,
      ingredientId: ingredientId ?? this.ingredientId,
      amount: amount ?? this.amount,
      unitId: unitId ?? this.unitId,
    );
  }

  @override
  List<Object?> get props => [id, sauceId, ingredientId, amount, unitId];
}
