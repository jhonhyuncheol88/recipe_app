import 'package:equatable/equatable.dart';

class RecipePriceHistory extends Equatable {
  final String id;
  final String recipeId;
  final double price;
  final DateTime recordedAt;

  const RecipePriceHistory({
    required this.id,
    required this.recipeId,
    required this.price,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'price': price,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory RecipePriceHistory.fromJson(Map<String, dynamic> json) {
    return RecipePriceHistory(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      price: (json['price'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  RecipePriceHistory copyWith({
    String? id,
    String? recipeId,
    double? price,
    DateTime? recordedAt,
  }) {
    return RecipePriceHistory(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      price: price ?? this.price,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  List<Object?> get props => [id, recipeId, price, recordedAt];
}


