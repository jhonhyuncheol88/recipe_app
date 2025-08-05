import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'recipe_ingredient.dart';

class Recipe extends Equatable {
  final String id;
  final String name;
  final String description;
  final double outputAmount;
  final String outputUnit;
  final double totalCost;
  final String? imagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RecipeIngredient> ingredients;
  final List<String> tagIds; // 태그 ID 목록

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.outputAmount,
    required this.outputUnit,
    required this.totalCost,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
    this.ingredients = const [],
    this.tagIds = const [],
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'output_amount': outputAmount,
      'output_unit': outputUnit,
      'total_cost': totalCost,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tag_ids': jsonEncode(tagIds), // List<String>을 JSON 문자열로 변환
    };
  }

  // JSON 역직렬화
  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> tagIds = [];

    // tag_ids가 문자열인 경우 JSON으로 파싱
    if (json['tag_ids'] != null) {
      if (json['tag_ids'] is String) {
        try {
          final decoded = jsonDecode(json['tag_ids']);
          if (decoded is List) {
            tagIds = List<String>.from(decoded);
          } else {
            tagIds = [];
          }
        } catch (e) {
          // 파싱 실패 시 빈 리스트로 설정
          tagIds = [];
        }
      } else if (json['tag_ids'] is List) {
        // 기존 List 형태 지원 (하위 호환성)
        try {
          tagIds = List<String>.from(json['tag_ids']);
        } catch (e) {
          tagIds = [];
        }
      }
    }

    return Recipe(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      outputAmount: (json['output_amount'] is int)
          ? (json['output_amount'] as int).toDouble()
          : json['output_amount'].toDouble(),
      outputUnit: json['output_unit'],
      totalCost: (json['total_cost'] is int)
          ? (json['total_cost'] as int).toDouble()
          : json['total_cost'].toDouble(),
      imagePath: json['image_path'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tagIds: tagIds,
    );
  }

  // 복사본 생성
  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    double? outputAmount,
    String? outputUnit,
    double? totalCost,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<RecipeIngredient>? ingredients,
    List<String>? tagIds,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      outputAmount: outputAmount ?? this.outputAmount,
      outputUnit: outputUnit ?? this.outputUnit,
      totalCost: totalCost ?? this.totalCost,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ingredients: ingredients ?? this.ingredients,
      tagIds: tagIds ?? this.tagIds,
    );
  }

  // 태그 추가
  Recipe addTag(String tagId) {
    if (!tagIds.contains(tagId)) {
      return copyWith(tagIds: [...tagIds, tagId], updatedAt: DateTime.now());
    }
    return this;
  }

  // 태그 제거
  Recipe removeTag(String tagId) {
    return copyWith(
      tagIds: tagIds.where((id) => id != tagId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  // 태그가 있는지 확인
  bool hasTag(String tagId) {
    return tagIds.contains(tagId);
  }

  // 태그 목록 업데이트
  Recipe updateTags(List<String> newTagIds) {
    return copyWith(tagIds: newTagIds, updatedAt: DateTime.now());
  }

  // 레시피에 재료 추가
  Recipe addIngredient(RecipeIngredient ingredient) {
    final updatedIngredients = List<RecipeIngredient>.from(ingredients)
      ..add(ingredient);

    return copyWith(ingredients: updatedIngredients, updatedAt: DateTime.now());
  }

  // 레시피에서 재료 제거
  Recipe removeIngredient(String ingredientId) {
    final updatedIngredients = ingredients
        .where((ingredient) => ingredient.ingredientId != ingredientId)
        .toList();

    return copyWith(ingredients: updatedIngredients, updatedAt: DateTime.now());
  }

  // 레시피 재료 수량 업데이트
  Recipe updateIngredientAmount(String ingredientId, double newAmount) {
    final updatedIngredients = ingredients.map((ingredient) {
      if (ingredient.ingredientId == ingredientId) {
        return ingredient.copyWith(amount: newAmount);
      }
      return ingredient;
    }).toList();

    return copyWith(ingredients: updatedIngredients, updatedAt: DateTime.now());
  }

  // 총 원가 재계산
  double calculateTotalCost() {
    return ingredients.fold(0.0, (total, ingredient) {
      return total + ingredient.calculatedCost;
    });
  }

  // 1인분당 원가 계산
  double get costPerServing {
    if (outputAmount <= 0) return 0.0;
    return totalCost / outputAmount;
  }

  // 레시피 완성도 (재료 개수 기반)
  double get completionRate {
    if (ingredients.isEmpty) return 0.0;
    // 최소 3개 이상의 재료가 있어야 완성도가 높다고 간주
    return (ingredients.length / 3.0).clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, totalCost: $totalCost, ingredients: ${ingredients.length}, tags: $tagIds)';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    outputAmount,
    outputUnit,
    totalCost,
    imagePath,
    createdAt,
    updatedAt,
    ingredients,
    tagIds,
  ];
}
