import 'package:equatable/equatable.dart';

/// 재료당 1행의 현재 재고 잔량.
class InventoryItem extends Equatable {
  final String id;
  final String ingredientId;
  final double currentQty;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.ingredientId,
    required this.currentQty,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ingredient_id': ingredientId,
        'current_qty': currentQty,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'],
        ingredientId: json['ingredient_id'],
        currentQty: (json['current_qty'] as num).toDouble(),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  InventoryItem copyWith({double? currentQty, DateTime? updatedAt}) =>
      InventoryItem(
        id: id,
        ingredientId: ingredientId,
        currentQty: currentQty ?? this.currentQty,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, ingredientId, currentQty, updatedAt];
}
