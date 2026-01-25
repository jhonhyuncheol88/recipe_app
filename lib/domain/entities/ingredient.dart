import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String id;
  final String name;
  final double purchasePrice;
  final double purchaseAmount;
  final String purchaseUnitId;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final List<String> tagIds;
  final double? animationX;
  final double? animationY;
  final bool isAnimationSettled;

  const Ingredient({
    required this.id,
    required this.name,
    required this.purchasePrice,
    required this.purchaseAmount,
    required this.purchaseUnitId,
    this.expiryDate,
    required this.createdAt,
    this.tagIds = const [],
    this.animationX,
    this.animationY,
    this.isAnimationSettled = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        purchasePrice,
        purchaseAmount,
        purchaseUnitId,
        expiryDate,
        createdAt,
        tagIds,
        animationX,
        animationY,
        isAnimationSettled,
      ];

  Ingredient copyWith({
    String? id,
    String? name,
    double? purchasePrice,
    double? purchaseAmount,
    String? purchaseUnitId,
    DateTime? expiryDate,
    DateTime? createdAt,
    List<String>? tagIds,
    double? animationX,
    double? animationY,
    bool? isAnimationSettled,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseAmount: purchaseAmount ?? this.purchaseAmount,
      purchaseUnitId: purchaseUnitId ?? this.purchaseUnitId,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      tagIds: tagIds ?? this.tagIds,
      animationX: animationX ?? this.animationX,
      animationY: animationY ?? this.animationY,
      isAnimationSettled: isAnimationSettled ?? this.isAnimationSettled,
    );
  }
}
