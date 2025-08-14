import 'package:sqflite/sqflite.dart';
import '../model/index.dart';
import 'database_helper.dart';

class SauceRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 소스 추가
  Future<void> insertSauce(Sauce sauce) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'sauces',
      sauce.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 소스 업데이트
  Future<void> updateSauce(Sauce sauce) async {
    final db = await _databaseHelper.database;
    await db.update(
      'sauces',
      sauce.toJson(),
      where: 'id = ?',
      whereArgs: [sauce.id],
    );
  }

  // 소스 삭제 (구성 재료도 함께 삭제)
  Future<void> deleteSauce(String sauceId) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      await txn.delete(
        'sauce_ingredients',
        where: 'sauce_id = ?',
        whereArgs: [sauceId],
      );
      await txn.delete('sauces', where: 'id = ?', whereArgs: [sauceId]);
    });
  }

  // 모든 소스 조회
  Future<List<Sauce>> getAllSauces() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sauces',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Sauce.fromJson(maps[i]));
  }

  // 단일 소스 조회
  Future<Sauce?> getSauceById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sauces',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Sauce.fromJson(maps.first);
  }

  // 소스 구성 재료 추가
  Future<void> addIngredientToSauce(SauceIngredient item) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'sauce_ingredients',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 소스 구성 재료 제거
  Future<void> removeIngredientFromSauce(
    String sauceId,
    String ingredientId,
  ) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'sauce_ingredients',
      where: 'sauce_id = ? AND ingredient_id = ?',
      whereArgs: [sauceId, ingredientId],
    );
  }

  // 소스 구성 재료 단일 항목 제거 (중복 보호: 행 id 기준)
  Future<void> removeSauceIngredientById(String sauceIngredientId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'sauce_ingredients',
      where: 'id = ?',
      whereArgs: [sauceIngredientId],
    );
  }

  // 소스 구성 재료 수량/단위 업데이트
  Future<void> updateSauceIngredient(
    String sauceId,
    String ingredientId, {
    double? amount,
    String? unitId,
  }) async {
    final db = await _databaseHelper.database;
    final updates = <String, Object?>{};
    if (amount != null) updates['amount'] = amount;
    if (unitId != null) updates['unit_id'] = unitId;
    if (updates.isEmpty) return;

    await db.update(
      'sauce_ingredients',
      updates,
      where: 'sauce_id = ? AND ingredient_id = ?',
      whereArgs: [sauceId, ingredientId],
    );
  }

  // 특정 소스의 구성 재료 조회
  Future<List<SauceIngredient>> getIngredientsForSauce(String sauceId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sauce_ingredients',
      where: 'sauce_id = ?',
      whereArgs: [sauceId],
    );
    return List.generate(maps.length, (i) => SauceIngredient.fromJson(maps[i]));
  }

  // 간단 통계 (소스 개수)
  Future<int> getSauceCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM sauces');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
