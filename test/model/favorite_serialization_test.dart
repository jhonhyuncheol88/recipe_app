import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/model/ingredient.dart';
import 'package:recipe_app/model/sauce.dart';

Ingredient _ing({bool fav = false}) => Ingredient(
      id: 'a', name: '양파', purchasePrice: 1000, purchaseAmount: 1,
      purchaseUnitId: 'u1', createdAt: DateTime(2026, 1, 1), isFavorite: fav,
    );

void main() {
  test('Ingredient toJson/fromJson 라운드트립에 isFavorite 유지', () {
    final json = _ing(fav: true).toJson();
    expect(json['is_favorite'], 1);
    expect(Ingredient.fromJson(json).isFavorite, isTrue);
  });

  test('Ingredient 레거시 행(is_favorite 없음) → false', () {
    final json = _ing().toJson()..remove('is_favorite');
    expect(Ingredient.fromJson(json).isFavorite, isFalse);
  });

  test('Ingredient.copyWith(isFavorite) 토글', () {
    expect(_ing().copyWith(isFavorite: true).isFavorite, isTrue);
  });

  test('Sauce toJson/fromJson 라운드트립에 isFavorite 유지', () {
    final s = Sauce(
      id: 's', name: '소스', totalWeight: 10, totalCost: 5,
      createdAt: DateTime(2026, 1, 1), isFavorite: true,
    );
    final json = s.toJson();
    expect(json['is_favorite'], 1);
    expect(Sauce.fromJson(json).isFavorite, isTrue);
    expect(Sauce.fromJson(json..remove('is_favorite')).isFavorite, isFalse);
  });
}
