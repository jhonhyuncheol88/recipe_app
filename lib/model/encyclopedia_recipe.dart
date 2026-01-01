import 'package:equatable/equatable.dart';

/// 백과사전 레시피 모델 (JSON 파싱용)
class EncyclopediaRecipe extends Equatable {
  final int number;
  final String menuName;
  final String page;
  final List<EncyclopediaIngredient> ingredients;
  final List<EncyclopediaIngredient> sauces;
  final String cookingMethod;

  const EncyclopediaRecipe({
    required this.number,
    required this.menuName,
    required this.page,
    required this.ingredients,
    required this.sauces,
    required this.cookingMethod,
  });

  /// JSON에서 EncyclopediaRecipe 생성
  factory EncyclopediaRecipe.fromJson(Map<String, dynamic> json) {
    // 메뉴명에서 "업소용 레시피"를 "쉐프 레시피"로 변경
    final rawMenuName = (json['메뉴명'] as String?) ?? '';
    final menuName = rawMenuName.replaceAll('업소용 레시피', '쉐프 레시피');

    return EncyclopediaRecipe(
      number: (json['번호'] as num?)?.toInt() ?? 0,
      menuName: menuName,
      page: (json['페이지'] as String?) ?? '',
      ingredients: (json['재료'] as List<dynamic>?)
              ?.map((item) {
                if (item is Map<String, dynamic>) {
                  return EncyclopediaIngredient.fromJson(item);
                }
                return null;
              })
              .whereType<EncyclopediaIngredient>()
              .toList() ??
          [],
      sauces: (json['양념'] as List<dynamic>?)
              ?.map((item) {
                if (item is Map<String, dynamic>) {
                  return EncyclopediaIngredient.fromJson(item);
                }
                return null;
              })
              .whereType<EncyclopediaIngredient>()
              .toList() ??
          [],
      cookingMethod: (json['조리방법'] as String?) ?? '',
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      '번호': number,
      '메뉴명': menuName,
      '페이지': page,
      '재료': ingredients.map((item) => item.toJson()).toList(),
      '양념': sauces.map((item) => item.toJson()).toList(),
      '조리방법': cookingMethod,
    };
  }

  @override
  List<Object?> get props =>
      [number, menuName, page, ingredients, sauces, cookingMethod];
}

/// 백과사전 재료/양념 모델
class EncyclopediaIngredient extends Equatable {
  final String name;
  final String amount;
  final String unit;

  const EncyclopediaIngredient({
    required this.name,
    required this.amount,
    required this.unit,
  });

  /// JSON에서 EncyclopediaIngredient 생성
  factory EncyclopediaIngredient.fromJson(Map<String, dynamic> json) {
    return EncyclopediaIngredient(
      name: (json['재료명'] as String?) ?? '',
      amount: (json['수량'] as String?) ?? '',
      unit: (json['단위'] as String?) ?? '',
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      '재료명': name,
      '수량': amount,
      '단위': unit,
    };
  }

  /// 단위 정규화 (예: "마리(다지기)" → "마리")
  String get normalizedUnit {
    if (unit.contains('(')) {
      return unit.substring(0, unit.indexOf('(')).trim();
    }
    return unit.trim();
  }

  /// ingredient_bulk_add_page로 전달할 형태로 변환
  Map<String, dynamic> toBulkAddFormat() {
    return {
      'name': name.trim(),
    };
  }

  @override
  List<Object?> get props => [name, amount, unit];
}
