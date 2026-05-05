import 'package:equatable/equatable.dart';

class RecipePriceHistory extends Equatable {
  final String id;
  final String recipeId;
  final double price; // 원가 (totalCost) 스냅샷
  final double sellPrice; // 판매가 스냅샷 (DB v8 컬럼)
  final DateTime recordedAt;

  const RecipePriceHistory({
    required this.id,
    required this.recipeId,
    required this.price,
    this.sellPrice = 0,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'price': price,
      'sell_price': sellPrice,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  factory RecipePriceHistory.fromJson(Map<String, dynamic> json) {
    final rawSell = json['sell_price'];
    final double sellPrice = rawSell == null ? 0 : (rawSell as num).toDouble();
    return RecipePriceHistory(
      id: json['id'] as String,
      recipeId: json['recipe_id'] as String,
      price: (json['price'] as num).toDouble(),
      sellPrice: sellPrice,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  RecipePriceHistory copyWith({
    String? id,
    String? recipeId,
    double? price,
    double? sellPrice,
    DateTime? recordedAt,
  }) {
    return RecipePriceHistory(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      price: price ?? this.price,
      sellPrice: sellPrice ?? this.sellPrice,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  List<Object?> get props => [id, recipeId, price, sellPrice, recordedAt];
}
