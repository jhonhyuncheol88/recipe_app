import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/model/index.dart';

void main() {
  test('StorageLocation dbValue 왕복', () {
    expect(StorageLocation.fromDb('shelf'), StorageLocation.shelf);
    expect(StorageLocation.fromDb('fridge'), StorageLocation.fridge);
    expect(StorageLocation.fromDb('freezer'), StorageLocation.freezer);
    expect(StorageLocation.fromDb(null), isNull);
    expect(StorageLocation.shelf.dbValue, 'shelf');
  });

  test('InventoryItem toJson/fromJson 왕복', () {
    final item = InventoryItem(
      id: 'i1',
      ingredientId: 'ing1',
      currentQty: 2.5,
      updatedAt: DateTime.parse('2026-07-27T10:00:00.000'),
    );
    final restored = InventoryItem.fromJson(item.toJson());
    expect(restored, item);
    expect(item.toJson()['ingredient_id'], 'ing1');
    expect(item.toJson()['current_qty'], 2.5);
  });

  test('InventoryTransaction toJson/fromJson 왕복 (price null 포함)', () {
    final tx = InventoryTransaction(
      id: 't1',
      ingredientId: 'ing1',
      type: InventoryTxType.aiAdjust,
      qtyDelta: -1.5,
      resultingQty: 1.0,
      price: null,
      createdAt: DateTime.parse('2026-07-27T10:00:00.000'),
    );
    final restored = InventoryTransaction.fromJson(tx.toJson());
    expect(restored, tx);
    expect(tx.toJson()['type'], 'ai_adjust');
  });

  test('Ingredient storageLocation 직렬화', () {
    final ing = Ingredient(
      id: 'ing1',
      name: '양파',
      purchasePrice: 3000,
      purchaseAmount: 1,
      purchaseUnitId: 'u-kg',
      createdAt: DateTime.parse('2026-07-27T10:00:00.000'),
      tagIds: const [],
      storageLocation: StorageLocation.fridge,
    );
    expect(ing.toJson()['storage_location'], 'fridge');
    final restored = Ingredient.fromJson(ing.toJson());
    expect(restored.storageLocation, StorageLocation.fridge);

    final moved = ing.copyWith(storageLocation: StorageLocation.freezer);
    expect(moved.storageLocation, StorageLocation.freezer);
  });
}
