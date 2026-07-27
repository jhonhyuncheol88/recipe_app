import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recipe_app/controller/inventory/inventory_cubit.dart';
import 'package:recipe_app/data/index.dart';
import 'package:recipe_app/model/index.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late InventoryCubit cubit;
  late IngredientRepository ingredientRepo;

  setUp(() async {
    final db = await DatabaseHelper().database;
    await db.delete('inventory_transactions');
    await db.delete('inventory_items');
    await db.delete('ingredients');

    ingredientRepo = IngredientRepository();
    await ingredientRepo.insertIngredient(Ingredient(
      id: 'ing1',
      name: '양파',
      purchasePrice: 5000,
      purchaseAmount: 2,
      purchaseUnitId: 'u1',
      createdAt: DateTime.now(),
      tagIds: const [],
      storageLocation: StorageLocation.fridge,
    ));

    cubit = InventoryCubit(
      inventoryRepository: InventoryRepository(),
      ingredientRepository: ingredientRepo,
      unitRepository: UnitRepository(),
    );
  });

  tearDown(() => cubit.close());

  test('load: 재료·잔량·요약을 채운다', () async {
    await cubit.load();
    expect(cubit.state.isLoading, false);
    expect(cubit.state.ingredients.length, 1);
    expect(cubit.state.items['ing1'], isNull); // lazy — 아직 행 없음
  });

  test('increment/decrement: 잔량 변경 + 상태 갱신', () async {
    await cubit.load();
    await cubit.setQuantity('ing1', 3.0);
    expect(cubit.state.items['ing1']!.currentQty, 3.0);
    expect(cubit.state.error, isNull); // 변경 성공 시 에러 없음(클리어 규약)

    await cubit.decrement('ing1'); // 양파 단위 조회 실패 시 기본 스텝 1
    expect(cubit.state.items['ing1']!.currentQty, 2.0);
  });

  test('error 라이프사이클: copyWith 보존/클리어 규약', () async {
    await cubit.load();
    final errored = cubit.state.copyWith(error: () => 'boom');
    expect(errored.error, 'boom');
    // 미지정 시 보존
    expect(errored.copyWith(isLoading: true).error, 'boom');
    // 명시적 클리어
    expect(errored.copyWith(error: () => null).error, isNull);
  });

  test('recordPurchase: 잔량 증가 + 오늘 구매 총액 갱신', () async {
    await cubit.load();
    await cubit.recordPurchase(ingredientId: 'ing1', qty: 2, price: 5000);
    expect(cubit.state.items['ing1']!.currentQty, 2.0);
    expect(cubit.state.todayPurchaseTotal, 5000);
  });

  test('classifyIngredient: 위치 변경 + 재고 행 생성', () async {
    await cubit.load();
    await cubit.classifyIngredient('ing1', StorageLocation.freezer);
    final updated =
        cubit.state.ingredients.firstWhere((i) => i.id == 'ing1');
    expect(updated.storageLocation, StorageLocation.freezer);
    expect(cubit.state.items['ing1'], isNotNull); // lazy 생성됨
  });

  test('filteredIngredients: 위치 필터', () async {
    await cubit.load();
    cubit.selectLocation(StorageLocation.fridge);
    expect(cubit.state.filteredIngredients.length, 1);
    cubit.selectLocation(StorageLocation.shelf);
    expect(cubit.state.filteredIngredients, isEmpty);
    cubit.selectLocation(null); // 미분류
    expect(cubit.state.filteredIngredients, isEmpty);
  });
}
