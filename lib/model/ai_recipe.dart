import 'package:equatable/equatable.dart';
import 'dart:convert';
import 'ingredient.dart';

/// AI가 생성한 레시피 모델
class AiRecipe extends Equatable {
  final String id;
  final String recipeName;
  final String description;
  final String? cuisineType;
  final int servings;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int totalTimeMinutes;
  final String difficulty;
  final List<Map<String, dynamic>> ingredients;
  final List<String> instructions;
  final List<String>? tips;
  final Map<String, dynamic>? nutritionalInfo;
  final double estimatedCost;
  final List<String> tags;
  final String? creativityScore;
  final DateTime generatedAt;
  final List<String> sourceIngredients;
  final String? aiModel;
  final String? promptVersion;
  final bool isConvertedToRecipe;
  final String? convertedRecipeId;

  AiRecipe({
    required this.id,
    required this.recipeName,
    required this.description,
    this.cuisineType,
    required this.servings,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.totalTimeMinutes,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    this.tips,
    this.nutritionalInfo,
    required this.estimatedCost,
    required this.tags,
    this.creativityScore,
    required this.generatedAt,
    required this.sourceIngredients,
    this.aiModel,
    this.promptVersion,
    this.isConvertedToRecipe = false,
    this.convertedRecipeId,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipe_name': recipeName,
      'description': description,
      'cuisine_type': cuisineType,
      'servings': servings,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'total_time_minutes': totalTimeMinutes,
      'difficulty': difficulty,
      'ingredients': jsonEncode(ingredients),
      'instructions': jsonEncode(instructions),
      'tips': tips != null ? jsonEncode(tips) : null,
      'nutritional_info': nutritionalInfo != null
          ? jsonEncode(nutritionalInfo)
          : null,
      'estimated_cost': estimatedCost,
      'tags': jsonEncode(tags),
      'creativity_score': creativityScore,
      'generated_at': generatedAt.toIso8601String(),
      'source_ingredients': jsonEncode(sourceIngredients),
      'ai_model': aiModel,
      'prompt_version': promptVersion,
      'is_converted_to_recipe': isConvertedToRecipe ? 1 : 0,
      'converted_recipe_id': convertedRecipeId,
    };
  }

  // JSON 역직렬화
  factory AiRecipe.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> ingredients = [];
    List<String> instructions = [];
    List<String>? tips;
    Map<String, dynamic>? nutritionalInfo;
    List<String> tags = [];

    // ingredients 파싱
    if (json['ingredients'] != null) {
      try {
        if (json['ingredients'] is String) {
          final decoded = jsonDecode(json['ingredients']);
          if (decoded is List) {
            ingredients = List<Map<String, dynamic>>.from(decoded);
          }
        } else if (json['ingredients'] is List) {
          ingredients = List<Map<String, dynamic>>.from(json['ingredients']);
        }
      } catch (e) {
        ingredients = [];
      }
    }

    // instructions 파싱
    if (json['instructions'] != null) {
      try {
        if (json['instructions'] is String) {
          final decoded = jsonDecode(json['instructions']);
          if (decoded is List) {
            instructions = List<String>.from(decoded);
          }
        } else if (json['instructions'] is List) {
          instructions = List<String>.from(json['instructions']);
        }
      } catch (e) {
        instructions = [];
      }
    }

    // tips 파싱
    if (json['tips'] != null) {
      try {
        if (json['tips'] is String) {
          final decoded = jsonDecode(json['tips']);
          if (decoded is List) {
            tips = List<String>.from(decoded);
          }
        } else if (json['tips'] is List) {
          tips = List<String>.from(json['tips']);
        }
      } catch (e) {
        tips = null;
      }
    }

    // nutritional_info 파싱
    if (json['nutritional_info'] != null) {
      try {
        if (json['nutritional_info'] is String) {
          final decoded = jsonDecode(json['nutritional_info']);
          if (decoded is Map) {
            nutritionalInfo = Map<String, dynamic>.from(decoded);
          }
        } else if (json['nutritional_info'] is Map) {
          nutritionalInfo = Map<String, dynamic>.from(json['nutritional_info']);
        }
      } catch (e) {
        nutritionalInfo = null;
      }
    }

    // tags 파싱
    if (json['tags'] != null) {
      try {
        if (json['tags'] is String) {
          final decoded = jsonDecode(json['tags']);
          if (decoded is List) {
            tags = List<String>.from(decoded);
          }
        } else if (json['tags'] is List) {
          tags = List<String>.from(json['tags']);
        }
      } catch (e) {
        tags = [];
      }
    }

    // source_ingredients 파싱
    List<String> sourceIngredients = [];
    if (json['source_ingredients'] != null) {
      try {
        if (json['source_ingredients'] is String) {
          final decoded = jsonDecode(json['source_ingredients']);
          if (decoded is List) {
            sourceIngredients = List<String>.from(decoded);
          }
        } else if (json['source_ingredients'] is List) {
          sourceIngredients = List<String>.from(json['source_ingredients']);
        }
      } catch (e) {
        sourceIngredients = [];
      }
    }

    return AiRecipe(
      id: json['id'],
      recipeName: json['recipe_name'],
      description: json['description'] ?? '',
      cuisineType: json['cuisine_type'],
      servings: json['servings'] ?? 0,
      prepTimeMinutes: json['prep_time_minutes'] ?? 0,
      cookTimeMinutes: json['cook_time_minutes'] ?? 0,
      totalTimeMinutes: json['total_time_minutes'] ?? 0,
      difficulty: json['difficulty'] ?? 'Beginner',
      ingredients: ingredients,
      instructions: instructions,
      tips: tips,
      nutritionalInfo: nutritionalInfo,
      estimatedCost: (json['estimated_cost'] is int)
          ? (json['estimated_cost'] as int).toDouble()
          : (json['estimated_cost'] ?? 0.0).toDouble(),
      tags: tags,
      creativityScore: json['creativity_score'],
      generatedAt: DateTime.parse(json['generated_at']),
      sourceIngredients: sourceIngredients,
      aiModel: json['ai_model'],
      promptVersion: json['prompt_version'],
      isConvertedToRecipe: json['is_converted_to_recipe'] == 1,
      convertedRecipeId: json['converted_recipe_id'],
    );
  }

  // 복사본 생성
  AiRecipe copyWith({
    String? id,
    String? recipeName,
    String? description,
    String? cuisineType,
    int? servings,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? totalTimeMinutes,
    String? difficulty,
    List<Map<String, dynamic>>? ingredients,
    List<String>? instructions,
    List<String>? tips,
    Map<String, dynamic>? nutritionalInfo,
    double? estimatedCost,
    List<String>? tags,
    String? creativityScore,
    DateTime? generatedAt,
    List<String>? sourceIngredients,
    String? aiModel,
    String? promptVersion,
    bool? isConvertedToRecipe,
    String? convertedRecipeId,
  }) {
    return AiRecipe(
      id: id ?? this.id,
      recipeName: recipeName ?? this.recipeName,
      description: description ?? this.description,
      cuisineType: cuisineType ?? this.cuisineType,
      servings: servings ?? this.servings,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      totalTimeMinutes: totalTimeMinutes ?? this.totalTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      nutritionalInfo: nutritionalInfo ?? this.nutritionalInfo,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      tags: tags ?? this.tags,
      creativityScore: creativityScore ?? this.creativityScore,
      generatedAt: generatedAt ?? this.generatedAt,
      sourceIngredients: sourceIngredients ?? this.sourceIngredients,
      aiModel: aiModel ?? this.aiModel,
      promptVersion: promptVersion ?? this.promptVersion,
      isConvertedToRecipe: isConvertedToRecipe ?? this.isConvertedToRecipe,
      convertedRecipeId: convertedRecipeId ?? this.convertedRecipeId,
    );
  }

  // 일반 Recipe로 변환
  Map<String, dynamic> toRecipeData() {
    return {
      'name': recipeName,
      'description': description,
      'outputAmount': servings.toDouble(),
      'outputUnit': '인분',
      'totalCost': estimatedCost,
      'tagIds': tags,
      'ingredients': ingredients.map((ingredient) {
        return {
          'name': ingredient['name'] ?? '',
          'amount': ingredient['quantity'] ?? 0.0,
          'unit': ingredient['unit'] ?? 'g',
        };
      }).toList(),
    };
  }

  // 변환 상태 업데이트
  AiRecipe markAsConverted(String recipeId) {
    return copyWith(isConvertedToRecipe: true, convertedRecipeId: recipeId);
  }

  // AI 레시피에서 재료 정보 추출
  List<AiRecipeIngredient> extractIngredients() {
    final List<AiRecipeIngredient> extractedIngredients = [];

    for (final ingredient in ingredients) {
      try {
        final name = ingredient['name']?.toString() ?? '';
        final quantity = _parseQuantity(ingredient['quantity']);
        final unit = ingredient['unit']?.toString() ?? 'g';

        if (name.isNotEmpty && quantity > 0) {
          extractedIngredients.add(
            AiRecipeIngredient(name: name, quantity: quantity, unit: unit),
          );
        }
      } catch (e) {
        // 개별 재료 파싱 실패 시 로그만 남기고 계속 진행
        print('재료 파싱 실패: $ingredient, 오류: $e');
      }
    }

    return extractedIngredients;
  }

  // 수량 파싱 (문자열, 숫자, null 모두 처리)
  double _parseQuantity(dynamic quantity) {
    if (quantity == null) return 0.0;
    if (quantity is num) return quantity.toDouble();
    if (quantity is String) {
      // 숫자만 추출 (예: "2개", "100g" → 2.0, 100.0)
      final clean = quantity.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }

  // 재료명 정규화 (공백, 특수문자 처리)
  String _normalizeIngredientName(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s가-힣]'), '') // 특수문자 제거
        .replaceAll(RegExp(r'\s+'), ' '); // 연속 공백을 하나로
  }

  @override
  String toString() {
    return 'AiRecipe(id: $id, name: $recipeName, cuisine: $cuisineType, servings: $servings, difficulty: $difficulty)';
  }

  @override
  List<Object?> get props => [
    id,
    recipeName,
    description,
    cuisineType,
    servings,
    prepTimeMinutes,
    cookTimeMinutes,
    totalTimeMinutes,
    difficulty,
    ingredients,
    instructions,
    tips,
    nutritionalInfo,
    estimatedCost,
    tags,
    creativityScore,
    generatedAt,
    sourceIngredients,
    aiModel,
    promptVersion,
    isConvertedToRecipe,
    convertedRecipeId,
  ];
}

/// AI 레시피의 재료 정보를 담는 클래스
class AiRecipeIngredient {
  final String name;
  final double quantity;
  final String unit;

  AiRecipeIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  // 재료명 정규화
  String get normalizedName {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s가-힣]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  String toString() {
    return 'AiRecipeIngredient(name: $name, quantity: $quantity, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiRecipeIngredient &&
        other.normalizedName == normalizedName;
  }

  @override
  int get hashCode => normalizedName.hashCode;
}

/// AI 레시피 재료와 보유 재료 비교 결과
class IngredientComparisonResult {
  final AiRecipeIngredient aiIngredient;
  final Ingredient? matchedIngredient;
  final bool isAvailable;
  final double? unitCost;
  final double? calculatedCost;

  IngredientComparisonResult({
    required this.aiIngredient,
    this.matchedIngredient,
    required this.isAvailable,
    this.unitCost,
    this.calculatedCost,
  });

  // 보유 재료가 있는 경우 투입량을 보유 재료 단위로 변환
  double? get convertedAmount {
    if (matchedIngredient == null || !isAvailable) return null;

    try {
      // AI 레시피 단위를 기본 단위로 변환
      final baseAmount = _convertToBaseUnit(
        aiIngredient.quantity,
        aiIngredient.unit,
      );
      // 기본 단위를 보유 재료 단위로 변환
      return _convertFromBaseUnit(
        baseAmount,
        matchedIngredient!.purchaseUnitId,
      );
    } catch (e) {
      print('단위 변환 실패: $e');
      return null;
    }
  }

  // 단위를 기본 단위로 변환
  double _convertToBaseUnit(double amount, String unit) {
    switch (unit.toLowerCase()) {
      case 'kg':
        return amount * 1000; // kg → g
      case 'l':
      case 'liter':
        return amount * 1000; // L → ml
      case 'ml':
      case 'g':
      case '개':
      case '조각':
      case '인분':
        return amount;
      default:
        return amount;
    }
  }

  // 기본 단위에서 단위로 변환
  double _convertFromBaseUnit(double baseAmount, String targetUnit) {
    switch (targetUnit.toLowerCase()) {
      case 'kg':
        return baseAmount / 1000; // g → kg
      case 'l':
      case 'liter':
        return baseAmount / 1000; // ml → L
      case 'ml':
      case 'g':
      case '개':
      case '조각':
      case '인분':
        return baseAmount;
      default:
        return baseAmount;
    }
  }

  @override
  String toString() {
    return 'IngredientComparisonResult(aiIngredient: $aiIngredient, isAvailable: $isAvailable, unitCost: $unitCost, calculatedCost: $calculatedCost)';
  }
}
