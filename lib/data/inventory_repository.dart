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

  /// 잔량을 newQty 로 설정 (행 없으면 lazy 생성). 변동량을 트랜잭션으로 기록.
  Future<InventoryItem> setQuantity({
    required String ingredientId,
    required double newQty,
    required InventoryTxType type,
    double? price,
  }) async {
    final clamped = newQty < 0 ? 0.0 : newQty;
    try {
      final db = await _databaseHelper.database;
      return await db.transaction((txn) async {
        final existing = await txn.query(
          'inventory_items',
          where: 'ingredient_id = ?',
          whereArgs: [ingredientId],
        );

        final now = DateTime.now();
        final double previousQty = existing.isEmpty
            ? 0.0
            : (existing.first['current_qty'] as num).toDouble();

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
    } catch (e) {
      developer.log('재고 설정 실패: $e', name: 'InventoryRepository');
      rethrow;
    }
  }

  /// 현재 잔량에 delta 를 더함 (0 미만 clamp).
  Future<InventoryItem> changeQuantity({
    required String ingredientId,
    required double delta,
    required InventoryTxType type,
    double? price,
  }) async {
    final items = await getAllItems();
    final current = items[ingredientId]?.currentQty ?? 0.0;
    return setQuantity(
      ingredientId: ingredientId,
      newQty: current + delta,
      type: type,
      price: price,
    );
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
}
