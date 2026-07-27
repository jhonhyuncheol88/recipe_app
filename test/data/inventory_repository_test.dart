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
}
