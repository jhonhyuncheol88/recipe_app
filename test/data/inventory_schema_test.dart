import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recipe_app/data/database_helper.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // 병렬 isolate 간 DB 파일 충돌(flake) 방지: 파일별 고유 임시 경로
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('inv_test_schema_').path,
    );
  });

  test('v9 스키마: inventory 테이블과 storage_location 컬럼이 존재한다', () async {
    final db = await DatabaseHelper().database;

    // inventory_items / inventory_transactions 테이블 존재
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' "
      "AND name IN ('inventory_items','inventory_transactions')",
    );
    expect(tables.length, 2);

    // ingredients.storage_location 컬럼 존재
    final columns = await db.rawQuery('PRAGMA table_info(ingredients)');
    final columnNames = columns.map((c) => c['name']).toList();
    expect(columnNames, contains('storage_location'));

    // inventory_items.ingredient_id UNIQUE 제약 (중복 insert 시 실패)
    await db.insert('inventory_items', {
      'id': 't1',
      'ingredient_id': 'ing-dup',
      'current_qty': 1.0,
      'updated_at': DateTime.now().toIso8601String(),
    });
    await expectLater(
      db.insert('inventory_items', {
        'id': 't2',
        'ingredient_id': 'ing-dup',
        'current_qty': 2.0,
        'updated_at': DateTime.now().toIso8601String(),
      }),
      throwsA(anything),
    );
    await db.delete('inventory_items', where: "ingredient_id = 'ing-dup'");
  });
}
