import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';
import '../model/index.dart';
import 'database_helper.dart';

class InventoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  /// ingredientId → InventoryItem 맵 조회
  Future<Map<String, InventoryItem>> getAllItems() async {
    try {
      final db = await _databaseHelper.database;
      final rows = await db.query('inventory_items');
      return {
        for (final row in rows)
          row['ingredient_id'] as String: InventoryItem.fromJson(row),
      };
    } catch (e) {
      developer.log('재고 목록 조회 실패: $e', name: 'InventoryRepository');
      rethrow;
    }
  }

  /// 트랜잭션 안에서 읽기-계산-쓰기: 현재 잔량을 읽어 compute 로 새 잔량을
  /// 계산하고 (0 미만 clamp), 행이 없으면 lazy 생성 후 변동량을 트랜잭션으로 기록.
  Future<InventoryItem> _writeQuantity({
    required String ingredientId,
    required double Function(double current) compute,
    required InventoryTxType type,
    double? price,
  }) async {
    final db = await _databaseHelper.database;
    return db.transaction((txn) async {
      final existing = await txn.query(
        'inventory_items',
        where: 'ingredient_id = ?',
        whereArgs: [ingredientId],
      );

      final now = DateTime.now();
      final double previousQty = existing.isEmpty
          ? 0.0
          : (existing.first['current_qty'] as num).toDouble();

      final newQty = compute(previousQty);
      final clamped = newQty < 0 ? 0.0 : newQty;

      final InventoryItem item;
      if (existing.isEmpty) {
        item = InventoryItem(
          id: _uuid.v4(),
          ingredientId: ingredientId,
          currentQty: clamped,
          updatedAt: now,
        );
        await txn.insert('inventory_items', item.toJson());
      } else {
        item = InventoryItem.fromJson(existing.first)
            .copyWith(currentQty: clamped, updatedAt: now);
        await txn.update(
          'inventory_items',
          item.toJson(),
          where: 'ingredient_id = ?',
          whereArgs: [ingredientId],
        );
      }

      final tx = InventoryTransaction(
        id: _uuid.v4(),
        ingredientId: ingredientId,
        type: type,
        qtyDelta: clamped - previousQty,
        resultingQty: clamped,
        price: price,
        createdAt: now,
      );
      await txn.insert('inventory_transactions', tx.toJson());
      return item;
    });
  }

  /// 잔량을 newQty 로 설정 (행 없으면 lazy 생성). 변동량을 트랜잭션으로 기록.
  Future<InventoryItem> setQuantity({
    required String ingredientId,
    required double newQty,
    required InventoryTxType type,
    double? price,
  }) async {
    try {
      return await _writeQuantity(
        ingredientId: ingredientId,
        compute: (_) => newQty,
        type: type,
        price: price,
      );
    } catch (e) {
      developer.log('재고 설정 실패: $e', name: 'InventoryRepository');
      rethrow;
    }
  }

  /// 현재 잔량에 delta 를 더함 (0 미만 clamp). 읽기-계산-쓰기가 한 트랜잭션.
  Future<InventoryItem> changeQuantity({
    required String ingredientId,
    required double delta,
    required InventoryTxType type,
    double? price,
  }) async {
    try {
      return await _writeQuantity(
        ingredientId: ingredientId,
        compute: (current) => current + delta,
        type: type,
        price: price,
      );
    } catch (e) {
      developer.log('재고 변경 실패: $e', name: 'InventoryRepository');
      rethrow;
    }
  }

  /// 구매 기록: 잔량 증가 + purchase 트랜잭션(금액 포함)
  Future<InventoryItem> recordPurchase({
    required String ingredientId,
    required double qty,
    required double price,
  }) {
    return changeQuantity(
      ingredientId: ingredientId,
      delta: qty,
      type: InventoryTxType.purchase,
      price: price,
    );
  }

  /// 오늘(로컬 자정 기준) 요약: 구매 총액 + 변동 건수
  Future<({double totalPurchase, int txCount})> getTodaySummary() async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now();
      final startOfDay =
          DateTime(now.year, now.month, now.day).toIso8601String();

      final rows = await db.query(
        'inventory_transactions',
        where: 'created_at >= ?',
        whereArgs: [startOfDay],
      );

      double total = 0;
      for (final row in rows) {
        if (row['type'] == InventoryTxType.purchase.dbValue) {
          total += (row['price'] as num?)?.toDouble() ?? 0;
        }
      }
      return (totalPurchase: total, txCount: rows.length);
    } catch (e) {
      developer.log('오늘 요약 조회 실패: $e', name: 'InventoryRepository');
      rethrow;
    }
  }

  /// 오늘(로컬 자정 기준)의 구매 트랜잭션 목록 (시간순)
  Future<List<InventoryTransaction>> getTodayPurchases() async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now();
      final startOfDay =
          DateTime(now.year, now.month, now.day).toIso8601String();

      final rows = await db.query(
        'inventory_transactions',
        where: 'created_at >= ? AND type = ?',
        whereArgs: [startOfDay, InventoryTxType.purchase.dbValue],
        orderBy: 'created_at ASC',
      );
      return rows.map(InventoryTransaction.fromJson).toList();
    } catch (e) {
      developer.log('오늘 구매 내역 조회 실패: $e', name: 'InventoryRepository');
      rethrow;
    }
  }

  /// 구매 금액을 기간 단위로 집계 (label 오름차순).
  /// daily: 최근 30일(yyyy-MM-dd) / monthly: 최근 12개월(yyyy-MM) / yearly: 전체(yyyy)
  /// created_at 은 로컬 기준 ISO8601 로 저장되므로 substr prefix 그룹이 로컬 날짜와 일치.
  Future<List<({String label, double total})>> getPurchaseTotals(
      PurchasePeriod period) async {
    try {
      final db = await _databaseHelper.database;
      final now = DateTime.now();

      final int prefixLength;
      final String since;
      switch (period) {
        case PurchasePeriod.daily:
          prefixLength = 10;
          since =
              DateTime(now.year, now.month, now.day - 29).toIso8601String();
        case PurchasePeriod.monthly:
          prefixLength = 7;
          since = DateTime(now.year, now.month - 11, 1).toIso8601String();
        case PurchasePeriod.yearly:
          prefixLength = 4;
          since = '';
      }

      final rows = await db.rawQuery(
        '''
        SELECT substr(created_at, 1, $prefixLength) AS label,
               SUM(COALESCE(price, 0)) AS total
        FROM inventory_transactions
        WHERE type = ? ${since.isEmpty ? '' : 'AND created_at >= ?'}
        GROUP BY label
        ORDER BY label ASC
        ''',
        [
          InventoryTxType.purchase.dbValue,
          if (since.isNotEmpty) since,
        ],
      );

      return rows
          .map((row) => (
                label: row['label'] as String,
                total: (row['total'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList();
    } catch (e) {
      developer.log('구매 집계 조회 실패: $e', name: 'InventoryRepository');
      rethrow;
    }
  }
}
