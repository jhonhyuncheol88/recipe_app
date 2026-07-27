import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recipe_app/data/database_helper.dart';
import 'package:recipe_app/data/inventory_repository.dart';
import 'package:recipe_app/model/index.dart';
import 'package:recipe_app/data/ingredient_repository.dart';
import 'package:recipe_app/data/repositories/ingredient_repository_impl.dart';

void main() {
  late InventoryRepository repo;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // 병렬 isolate 간 DB 파일 충돌(flake) 방지: 파일별 고유 임시 경로
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('inv_test_repo_').path,
    );
  });

  setUp(() async {
    repo = InventoryRepository();
    final db = await DatabaseHelper().database;
    await db.delete('inventory_transactions');
    await db.delete('inventory_items');
  });

  test('setQuantity: 행이 없으면 lazy 생성 후 잔량 설정 + adjust 트랜잭션', () async {
    final item = await repo.setQuantity(
      ingredientId: 'ing1',
      newQty: 3.0,
      type: InventoryTxType.adjust,
    );
    expect(item.currentQty, 3.0);

    final items = await repo.getAllItems();
    expect(items['ing1']!.currentQty, 3.0);
  });

  test('changeQuantity: 음수 clamp — 잔량 1에서 -5 하면 0', () async {
    await repo.setQuantity(
        ingredientId: 'ing1', newQty: 1.0, type: InventoryTxType.adjust);
    final item = await repo.changeQuantity(
      ingredientId: 'ing1',
      delta: -5.0,
      type: InventoryTxType.consume,
    );
    expect(item.currentQty, 0.0);
  });

  test('changeQuantity: 동시 호출 시 lost update 없음 (트랜잭션 내 read-modify-write)',
      () async {
    await Future.wait([
      for (var i = 0; i < 10; i++)
        repo.changeQuantity(
          ingredientId: 'ing-race',
          delta: 1.0,
          type: InventoryTxType.purchase,
        ),
    ]);
    final items = await repo.getAllItems();
    expect(items['ing-race']!.currentQty, 10.0);
  });

  test('recordPurchase: 잔량 증가 + 오늘 구매 합산', () async {
    await repo.recordPurchase(ingredientId: 'ing1', qty: 2.0, price: 5000);
    await repo.recordPurchase(ingredientId: 'ing2', qty: 1.0, price: 3000);

    final items = await repo.getAllItems();
    expect(items['ing1']!.currentQty, 2.0);

    final summary = await repo.getTodaySummary();
    expect(summary.totalPurchase, 8000);
    expect(summary.txCount, 2);
  });

  test('재료 삭제 시 재고·이력 명시 정리 (CASCADE 대체)', () async {
    final db = await DatabaseHelper().database;
    final ingredientRepo = IngredientRepository();
    await ingredientRepo.insertIngredient(Ingredient(
      id: 'ing-del',
      name: '삭제재료',
      purchasePrice: 0,
      purchaseAmount: 1,
      purchaseUnitId: 'u1',
      createdAt: DateTime.now(),
      tagIds: const [],
    ));
    await repo.recordPurchase(ingredientId: 'ing-del', qty: 1, price: 100);
    await ingredientRepo.deleteIngredient('ing-del');

    final items = await repo.getAllItems();
    expect(items['ing-del'], isNull);
    final txs = await db.query('inventory_transactions',
        where: "ingredient_id = 'ing-del'");
    expect(txs, isEmpty);
  });

  test(
      'IngredientRepositoryImpl.updateIngredientsBatch: idsToDelete 삭제 경로도 재고·이력 정리',
      () async {
    final db = await DatabaseHelper().database;
    final ingredientRepo = IngredientRepository();
    await ingredientRepo.insertIngredient(Ingredient(
      id: 'ing-batch-del',
      name: '배치삭제재료',
      purchasePrice: 0,
      purchaseAmount: 1,
      purchaseUnitId: 'u1',
      createdAt: DateTime.now(),
      tagIds: const [],
    ));
    await repo.recordPurchase(ingredientId: 'ing-batch-del', qty: 1, price: 100);

    final impl = IngredientRepositoryImpl(DatabaseHelper());
    await impl.updateIngredientsBatch(const [], ['ing-batch-del']);

    final items = await repo.getAllItems();
    expect(items['ing-batch-del'], isNull);
    final txs = await db.query('inventory_transactions',
        where: "ingredient_id = 'ing-batch-del'");
    expect(txs, isEmpty);
    final ingredientRows = await db.query('ingredients',
        where: "id = 'ing-batch-del'");
    expect(ingredientRows, isEmpty);
  });

  test('getTodayPurchases: 오늘 purchase 만 시간순으로 반환', () async {
    final db = await DatabaseHelper().database;
    await repo.recordPurchase(ingredientId: 'ing1', qty: 2, price: 5000);
    await repo.recordPurchase(ingredientId: 'ing2', qty: 1, price: 3000);
    // 오늘이지만 구매가 아닌 조정 — 제외되어야 함
    await repo.setQuantity(
        ingredientId: 'ing1', newQty: 5, type: InventoryTxType.adjust);
    // 어제 구매 — 제외되어야 함
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await db.insert('inventory_transactions', {
      'id': 'tx-yesterday',
      'ingredient_id': 'ing3',
      'type': 'purchase',
      'qty_delta': 1.0,
      'resulting_qty': 1.0,
      'price': 9999.0,
      'created_at': yesterday.toIso8601String(),
    });

    final purchases = await repo.getTodayPurchases();
    expect(purchases.length, 2);
    expect(purchases[0].ingredientId, 'ing1');
    expect(purchases[1].ingredientId, 'ing2');
    expect(purchases.every((t) => t.type == InventoryTxType.purchase), true);
  });

  test('updatePurchase: 수량 차이만큼 잔량 보정 + tx 갱신', () async {
    await repo.recordPurchase(ingredientId: 'ing1', qty: 2.0, price: 5000);
    final purchases = await repo.getTodayPurchases();
    final txId = purchases.single.id;

    // 2 → 5 로 수정: 잔량 +3, 금액 7000 으로
    await repo.updatePurchase(txId: txId, qty: 5.0, price: 7000);

    final items = await repo.getAllItems();
    expect(items['ing1']!.currentQty, 5.0);

    final updated = (await repo.getTodayPurchases()).single;
    expect(updated.qtyDelta, 5.0);
    expect(updated.price, 7000);
    expect(updated.resultingQty, 5.0);

    // 5 → 1 로 수정: 잔량 -4
    await repo.updatePurchase(txId: txId, qty: 1.0, price: 7000);
    expect((await repo.getAllItems())['ing1']!.currentQty, 1.0);
  });

  test('deletePurchase: 잔량 롤백(clamp) + tx 삭제', () async {
    await repo.recordPurchase(ingredientId: 'ing1', qty: 3.0, price: 5000);
    // 소비로 잔량 1 로 줄인 뒤 구매 삭제 → 1-3 = -2 → clamp 0
    await repo.changeQuantity(
        ingredientId: 'ing1', delta: -2.0, type: InventoryTxType.consume);

    final purchase = (await repo.getTodayPurchases()).single;
    await repo.deletePurchase(purchase.id);

    expect((await repo.getAllItems())['ing1']!.currentQty, 0.0);
    expect(await repo.getTodayPurchases(), isEmpty);
  });

  test('getAllPurchases: purchase 만 최신순', () async {
    final db = await DatabaseHelper().database;
    await repo.recordPurchase(ingredientId: 'ing1', qty: 1, price: 100);
    await db.insert('inventory_transactions', {
      'id': 'tx-old',
      'ingredient_id': 'ing2',
      'type': 'purchase',
      'qty_delta': 1.0,
      'resulting_qty': 1.0,
      'price': 200.0,
      'created_at': DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String(),
    });
    await repo.setQuantity(
        ingredientId: 'ing1', newQty: 9, type: InventoryTxType.adjust);

    final all = await repo.getAllPurchases();
    expect(all.length, 2);
    expect(all.first.ingredientId, 'ing1'); // 최신순
    expect(all.last.id, 'tx-old');
  });

  test('getPurchaseTotals: 일/월/연 그룹 합산', () async {
    final db = await DatabaseHelper().database;
    Future<void> insertPurchase(String id, DateTime at, double price) =>
        db.insert('inventory_transactions', {
          'id': id,
          'ingredient_id': 'ing1',
          'type': 'purchase',
          'qty_delta': 1.0,
          'resulting_qty': 1.0,
          'price': price,
          'created_at': at.toIso8601String(),
        });

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    await insertPurchase('t1', today, 1000);
    await insertPurchase('t2', today, 2000); // 같은 날 합산 → 3000
    await insertPurchase(
        't3', today.subtract(const Duration(days: 1)), 500); // 어제
    await insertPurchase(
        't4', today.subtract(const Duration(days: 40)), 700); // 30일 밖

    final daily = await repo.getPurchaseTotals(PurchasePeriod.daily);
    // 30일 밖(t4)은 제외, 어제+오늘 2개 그룹
    expect(daily.length, 2);
    expect(daily.last.total, 3000); // 오늘 (label ASC → 마지막)
    expect(daily.first.total, 500);
    expect(daily.last.label.length, 10); // yyyy-MM-dd

    final yearly = await repo.getPurchaseTotals(PurchasePeriod.yearly);
    // 연 단위는 전체 포함 (t1+t2+t3+t4 가 같은 해라면 4200 하나,
    // t4 가 해를 넘으면 2개 그룹) — 합계로 검증
    final yearSum = yearly.fold<double>(0, (s, r) => s + r.total);
    expect(yearSum, 4200);
    expect(yearly.first.label.length, 4); // yyyy
  });
}
