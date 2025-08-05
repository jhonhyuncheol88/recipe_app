import 'package:sqflite/sqflite.dart';
import '../model/index.dart';
import 'database_helper.dart';

class UnitRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 단위 추가
  Future<void> insertUnit(Unit unit) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'units',
      unit.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 모든 단위 조회
  Future<List<Unit>> getAllUnits() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('units');

    return List.generate(maps.length, (i) {
      return Unit.fromJson(maps[i]);
    });
  }

  // 단위 ID로 조회
  Future<Unit?> getUnitById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'units',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Unit.fromJson(maps.first);
    }
    return null;
  }

  // 타입별 단위 조회
  Future<List<Unit>> getUnitsByType(String type) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'units',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Unit.fromJson(maps[i]);
    });
  }

  // 무게 단위 조회
  Future<List<Unit>> getWeightUnits() async {
    return getUnitsByType('weight');
  }

  // 부피 단위 조회
  Future<List<Unit>> getVolumeUnits() async {
    return getUnitsByType('volume');
  }

  // 개수 단위 조회
  Future<List<Unit>> getCountUnits() async {
    return getUnitsByType('count');
  }

  // 기본 단위 조회 (conversion_factor가 1.0인 단위들)
  Future<List<Unit>> getBaseUnits() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'units',
      where: 'conversion_factor = 1.0',
    );

    return List.generate(maps.length, (i) {
      return Unit.fromJson(maps[i]);
    });
  }

  // 단위 업데이트
  Future<void> updateUnit(Unit unit) async {
    final db = await _databaseHelper.database;
    await db.update(
      'units',
      unit.toJson(),
      where: 'id = ?',
      whereArgs: [unit.id],
    );
  }

  // 단위 삭제
  Future<void> deleteUnit(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('units', where: 'id = ?', whereArgs: [id]);
  }

  // 단위 변환
  Future<double> convertUnit(
    double value,
    String fromUnitId,
    String toUnitId,
  ) async {
    final fromUnit = await getUnitById(fromUnitId);
    final toUnit = await getUnitById(toUnitId);

    if (fromUnit == null || toUnit == null) {
      throw Exception('단위를 찾을 수 없습니다.');
    }

    if (fromUnit.type != toUnit.type) {
      throw Exception('서로 다른 타입의 단위는 변환할 수 없습니다.');
    }

    return fromUnit.convert(value, toUnit);
  }

  // 기본 단위로 변환
  Future<double> convertToBaseUnit(double value, String unitId) async {
    final unit = await getUnitById(unitId);
    if (unit == null) {
      throw Exception('단위를 찾을 수 없습니다.');
    }

    return value * unit.conversionFactor;
  }

  // 기본 단위에서 변환
  Future<double> convertFromBaseUnit(double value, String unitId) async {
    final unit = await getUnitById(unitId);
    if (unit == null) {
      throw Exception('단위를 찾을 수 없습니다.');
    }

    return value / unit.conversionFactor;
  }

  // 호환 가능한 단위들 조회
  Future<List<Unit>> getCompatibleUnits(String unitId) async {
    final unit = await getUnitById(unitId);
    if (unit == null) return [];

    return getUnitsByType(unit.type);
  }

  // 단위 검색
  Future<List<Unit>> searchUnits(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'units',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Unit.fromJson(maps[i]);
    });
  }

  // 단위 통계 정보
  Future<Map<String, dynamic>> getUnitStats() async {
    final allUnits = await getAllUnits();

    return {
      'total': allUnits.length,
      'weight': allUnits.where((u) => u.type == 'weight').length,
      'volume': allUnits.where((u) => u.type == 'volume').length,
      'count': allUnits.where((u) => u.type == 'count').length,
    };
  }
}
