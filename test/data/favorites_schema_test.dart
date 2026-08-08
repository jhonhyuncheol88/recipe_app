import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recipe_app/data/database_helper.dart';

Future<bool> _hasColumn(db, String table, String column) async {
  final rows = await db.rawQuery('PRAGMA table_info($table)');
  return rows.any((r) => r['name'] == column);
}

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('fav_schema_').path,
    );
  });

  test('v10 스키마: ingredients/recipes/sauces 에 is_favorite 컬럼(default 0)', () async {
    final db = await DatabaseHelper().database;
    for (final table in ['ingredients', 'recipes', 'sauces']) {
      expect(await _hasColumn(db, table, 'is_favorite'), isTrue,
          reason: '$table.is_favorite 없음');
    }
    // default 0 확인: 최소 컬럼만 넣어 insert 후 조회
    await db.insert('sauces', {
      'id': 's1', 'name': '테스트', 'description': '',
      'total_weight': 0.0, 'total_cost': 0.0,
      'created_at': DateTime(2026, 1, 1).toIso8601String(),
    });
    final row = (await db.query('sauces', where: 'id = ?', whereArgs: ['s1'])).first;
    expect(row['is_favorite'], 0);
  });
}
