import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import '../model/index.dart';
import 'database_helper.dart';

class IngredientRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 재료 추가
  Future<void> insertIngredient(Ingredient ingredient) async {
    try {
      developer.log('재료 저장 시작', name: 'IngredientRepository');
      developer.log(
        '저장할 데이터: ${ingredient.toJson()}',
        name: 'IngredientRepository',
      );

      final db = await _databaseHelper.database;
      developer.log('데이터베이스 연결 완료', name: 'IngredientRepository');

      final result = await db.insert(
        'ingredients',
        ingredient.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      developer.log('재료 저장 완료, ID: $result', name: 'IngredientRepository');
    } catch (e) {
      developer.log('재료 저장 실패: $e', name: 'IngredientRepository');
      rethrow;
    }
  }

  // 재료 목록 조회
  Future<List<Ingredient>> getAllIngredients() async {
    try {
      developer.log('재료 목록 조회 시작', name: 'IngredientRepository');

      final db = await _databaseHelper.database;
      developer.log('데이터베이스 연결 완료', name: 'IngredientRepository');

      final List<Map<String, dynamic>> maps = await db.query('ingredients');
      developer.log('쿼리 결과: ${maps.length}개', name: 'IngredientRepository');

      if (maps.isNotEmpty) {}

      final ingredients = List.generate(maps.length, (i) {
        return Ingredient.fromJson(maps[i]);
      });

      developer.log(
        '재료 목록 조회 완료: ${ingredients.length}개',
        name: 'IngredientRepository',
      );
      return ingredients;
    } catch (e) {
      developer.log('재료 목록 조회 실패: $e', name: 'IngredientRepository');
      rethrow;
    }
  }

  // 재료 ID로 조회
  Future<Ingredient?> getIngredientById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Ingredient.fromJson(maps.first);
    }
    return null;
  }

  // 재료 이름으로 검색
  Future<List<Ingredient>> searchIngredientsByName(String name) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    return List.generate(maps.length, (i) {
      return Ingredient.fromJson(maps[i]);
    });
  }

  // 재료 업데이트
  Future<void> updateIngredient(Ingredient ingredient) async {
    final db = await _databaseHelper.database;
    await db.update(
      'ingredients',
      ingredient.toJson(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  // 재료 삭제
  Future<void> deleteIngredient(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('ingredients', where: 'id = ?', whereArgs: [id]);
  }

  // 유통기한이 임박한 재료 조회
  Future<List<Ingredient>> getExpiringIngredients({int days = 7}) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final expiryDate = now.add(Duration(days: days));

    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'expiry_date IS NOT NULL AND expiry_date <= ?',
      whereArgs: [expiryDate.toIso8601String()],
      orderBy: 'expiry_date ASC',
    );

    return List.generate(maps.length, (i) {
      return Ingredient.fromJson(maps[i]);
    });
  }

  // 만료된 재료 조회
  Future<List<Ingredient>> getExpiredIngredients() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();

    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'expiry_date IS NOT NULL AND expiry_date < ?',
      whereArgs: [now.toIso8601String()],
      orderBy: 'expiry_date ASC',
    );

    return List.generate(maps.length, (i) {
      return Ingredient.fromJson(maps[i]);
    });
  }

  // 재료 개수 조회
  Future<int> getIngredientCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ingredients',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 총 재료 가치 계산
  Future<double> getTotalIngredientValue() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(purchase_price) as total FROM ingredients',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // 재료 통계 정보
  Future<Map<String, dynamic>> getIngredientStats() async {
    final allIngredients = await getAllIngredients();
    final expiringIngredients = await getExpiringIngredients();
    final expiredIngredients = await getExpiredIngredients();

    return {
      'total': allIngredients.length,
      'expiring': expiringIngredients.length,
      'expired': expiredIngredients.length,
      'normal': allIngredients
          .where((i) => i.expiryStatus == ExpiryStatus.normal)
          .length,
      'warning': allIngredients
          .where((i) => i.expiryStatus == ExpiryStatus.warning)
          .length,
      'danger': allIngredients
          .where((i) => i.expiryStatus == ExpiryStatus.danger)
          .length,
    };
  }

  // 유통기한 상태별 재료 조회
  Future<List<Ingredient>> getIngredientsByExpiryStatus(
    ExpiryStatus status,
  ) async {
    final allIngredients = await getAllIngredients();
    return allIngredients
        .where((ingredient) => ingredient.expiryStatus == status)
        .toList();
  }
}
