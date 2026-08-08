import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recipe_app/data/database_helper.dart';
import 'package:recipe_app/data/ingredient_repository.dart';
import 'package:recipe_app/data/sauce_repository.dart';
import 'package:recipe_app/model/ingredient.dart';
import 'package:recipe_app/model/sauce.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('fav_repo_').path,
    );
  });

  setUp(() async {
    final db = await DatabaseHelper().database;
    await db.delete('ingredients');
    await db.delete('sauces');
  });

  test('IngredientRepository.setFavorite 가 단일 컬럼만 갱신하고 유지된다', () async {
    final repo = IngredientRepository();
    final db = await DatabaseHelper().database;
    await db.insert('ingredients', Ingredient(
      id: 'a', name: '양파', purchasePrice: 1000, purchaseAmount: 1,
      purchaseUnitId: 'u1', createdAt: DateTime(2026, 1, 1),
    ).toJson());

    await repo.setFavorite('a', true);
    expect((await repo.getIngredientById('a'))!.isFavorite, isTrue);

    await repo.setFavorite('a', false);
    expect((await repo.getIngredientById('a'))!.isFavorite, isFalse);
  });

  test('SauceRepository.setFavorite 가 값을 유지한다', () async {
    final repo = SauceRepository();
    final db = await DatabaseHelper().database;
    await db.insert('sauces', Sauce(
      id: 's', name: '소스', totalWeight: 10, totalCost: 5,
      createdAt: DateTime(2026, 1, 1),
    ).toJson());

    await repo.setFavorite('s', true);
    final sauces = await repo.getAllSauces();
    expect(sauces.firstWhere((e) => e.id == 's').isFavorite, isTrue);
  });
}
