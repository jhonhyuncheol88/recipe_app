import 'package:sqflite/sqflite.dart';
import '../model/recipe_price_history.dart';
import 'database_helper.dart';

class RecipePriceHistoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 가격 히스토리 추가
  Future<void> insertPriceHistory(RecipePriceHistory history) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'recipe_price_history',
      history.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 레시피의 모든 가격 히스토리 조회
  Future<List<RecipePriceHistory>> getPriceHistoryByRecipeId(
    String recipeId,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipe_price_history',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'recorded_at ASC',
    );

    return maps.map((map) => RecipePriceHistory.fromJson(map)).toList();
  }

  // 특정 기간의 가격 히스토리 조회
  Future<List<RecipePriceHistory>> getPriceHistoryByDateRange(
    String recipeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipe_price_history',
      where: 'recipe_id = ? AND recorded_at >= ? AND recorded_at <= ?',
      whereArgs: [
        recipeId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'recorded_at ASC',
    );

    return maps.map((map) => RecipePriceHistory.fromJson(map)).toList();
  }

  // 레시피의 최신 가격 조회
  Future<RecipePriceHistory?> getLatestPrice(String recipeId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipe_price_history',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'recorded_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return RecipePriceHistory.fromJson(maps.first);
  }

  // 레시피의 가격 히스토리 삭제 (레시피 삭제 시)
  Future<void> deletePriceHistoryByRecipeId(String recipeId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'recipe_price_history',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
  }
}




