import 'dart:convert';
import '../../domain/entities/ingredient.dart';

class IngredientModel extends Ingredient {
  const IngredientModel({
    required super.id,
    required super.name,
    required super.purchasePrice,
    required super.purchaseAmount,
    required super.purchaseUnitId,
    super.expiryDate,
    required super.createdAt,
    super.tagIds,
    super.animationX,
    super.animationY,
    super.isAnimationSettled,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    List<String> tagIds = [];
    if (json['tag_ids'] != null) {
      if (json['tag_ids'] is String) {
        try {
          tagIds = List<String>.from(jsonDecode(json['tag_ids']));
        } catch (e) {
          if (json['tag_ids'].toString().isNotEmpty) {
            tagIds = json['tag_ids'].toString().split(',');
          }
        }
      } else if (json['tag_ids'] is List) {
        tagIds = List<String>.from(json['tag_ids']);
      }
    }

    return IngredientModel(
      id: json['id'],
      name: json['name'],
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      purchaseAmount: (json['purchase_amount'] as num).toDouble(),
      purchaseUnitId: json['purchase_unit_id'],
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      tagIds: tagIds,
      animationX: (json['animation_x'] as num?)?.toDouble(),
      animationY: (json['animation_y'] as num?)?.toDouble(),
      isAnimationSettled: json['is_animation_settled'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'purchase_price': purchasePrice,
      'purchase_amount': purchaseAmount,
      'purchase_unit_id': purchaseUnitId,
      'expiry_date': expiryDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'tag_ids': jsonEncode(tagIds),
      'animation_x': animationX,
      'animation_y': animationY,
      'is_animation_settled': isAnimationSettled ? 1 : 0,
    };
  }

  factory IngredientModel.fromEntity(Ingredient ingredient) {
    return IngredientModel(
      id: ingredient.id,
      name: ingredient.name,
      purchasePrice: ingredient.purchasePrice,
      purchaseAmount: ingredient.purchaseAmount,
      purchaseUnitId: ingredient.purchaseUnitId,
      expiryDate: ingredient.expiryDate,
      createdAt: ingredient.createdAt,
      tagIds: ingredient.tagIds,
      animationX: ingredient.animationX,
      animationY: ingredient.animationY,
      isAnimationSettled: ingredient.isAnimationSettled,
    );
  }
}
