# 재고조사(Inventory) 기능 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 보관 위치별 재고 잔량을 최소 입력으로 기록·조정하고, 구매·차감 이력과 일별 구매 총액을 관리하며, 기존 OCR 파이프라인으로 사진 속 텍스트를 분석해 재고를 일괄 갱신하는 재고 탭을 추가한다.

**Architecture:** 하이브리드 데이터 모델 — `inventory_items`(재료당 현재 잔량 1행) + `inventory_transactions`(변동 이력). Cubit + Repository + Service 기존 패턴 준수. AI 분석은 기존 `OcrService`(ML Kit 텍스트 추출) → 신규 `InventoryGeminiService`(텍스트 분석) 재사용.

**Tech Stack:** Flutter, flutter_bloc(Cubit), sqflite(DB v9), google_generative_ai(`gemini-3-flash-preview`), image_picker, uuid. 테스트: flutter_test + sqflite_common_ffi.

**Spec:** `docs/superpowers/specs/2026-07-27-inventory-design.md`

## Global Constraints

- 신규/수정 화면은 디자인 토큰만 사용: `AppColorTokens.of(context)`, `AppTypography`, `AppSpacing`, `AppRadius` (`lib/theme/tokens/`). 레거시 `colorScheme.primary`, `AppTextStyles` 금지.
- 모든 사용자 노출 문자열은 6로케일 (korea, japan, china, chinaTraditional, usa, vietnam) `AppStrings` 경유.
- `flutter analyze` 신규 에러 0. (기존 `withOpacity` deprecation info 는 무시)
- DB 마이그레이션은 v8 → v9. 기존 사용자 데이터 보존.
- 재고 단위 = 재료 마스터 구매 단위(`purchaseUnitId`) 그대로. 단위 변환 없음.
- `inventory_items` 행은 미리 만들지 않고 최초 조정/분류/구매 시 lazy 생성 (초기 잔량 0).
- 잔량은 음수 불가 (0 미만으로 내려가는 조정은 0 으로 clamp).
- 로그는 `dart:developer` 의 `developer.log` (repository) / `Logger` (service) — 기존 파일 패턴 따름.
- 커밋 메시지 끝에 다음 트레일러 필수:
  ```
  Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
  Claude-Session: https://claude.ai/code/session_015xmar9douQnnT3h9SL7MvB
  ```

---

### Task 1: DB v9 마이그레이션 + 테스트 인프라

**Files:**
- Modify: `lib/data/database_helper.dart` (version 8→9, `_onCreate` 에 신규 테이블/컬럼, `_onUpgrade` 에 v9 블록)
- Modify: `pubspec.yaml` (dev_dependencies 에 `sqflite_common_ffi: ^2.3.0`)
- Test: `test/data/inventory_schema_test.dart`

**Interfaces:**
- Produces: DB 테이블 `inventory_items`(id, ingredient_id UNIQUE, current_qty, updated_at), `inventory_transactions`(id, ingredient_id, type, qty_delta, resulting_qty, price, created_at), `ingredients.storage_location TEXT` 컬럼. 이후 모든 Task 가 이 스키마에 의존.

- [ ] **Step 1: dev dependency 추가**

`pubspec.yaml` 의 `dev_dependencies:` 블록에 추가:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^5.0.0
  sqflite_common_ffi: ^2.3.0
```

Run: `flutter pub get` — 성공 확인.

- [ ] **Step 2: 실패하는 스키마 테스트 작성**

`test/data/inventory_schema_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recipe_app/data/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
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
    expect(
      () => db.insert('inventory_items', {
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
```

- [ ] **Step 3: 테스트 실패 확인**

Run: `flutter test test/data/inventory_schema_test.dart`
Expected: FAIL (`no such table` 또는 `expect(tables.length, 2)` 불일치)

- [ ] **Step 4: database_helper.dart 수정**

(a) 버전 변경 — `_initDatabase` 내:

```dart
        version: 9, // 버전 업데이트 (재고조사: inventory 테이블 + storage_location)
```

(b) `_onCreate` 의 ingredients CREATE TABLE 문에 컬럼 추가. 기존 문 끝의 컬럼 나열에 `storage_location TEXT` 를 추가 (기존 컬럼·제약은 그대로 유지):

```sql
        CREATE TABLE ingredients (
          ... 기존 컬럼 전부 유지 ...,
          storage_location TEXT
        )
```

(c) `_onCreate` 마지막(다른 CREATE TABLE 들 뒤)에 신규 테이블 2개 생성:

```dart
      // 재고 잔량 (재료당 1행)
      developer.log('Inventory 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
        CREATE TABLE inventory_items (
          id TEXT PRIMARY KEY,
          ingredient_id TEXT NOT NULL UNIQUE,
          current_qty REAL NOT NULL DEFAULT 0,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
        )
      ''');

      // 재고 변동 이력
      await db.execute('''
        CREATE TABLE inventory_transactions (
          id TEXT PRIMARY KEY,
          ingredient_id TEXT NOT NULL,
          type TEXT NOT NULL,
          qty_delta REAL NOT NULL,
          resulting_qty REAL NOT NULL,
          price REAL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_inventory_tx_ingredient_id ON inventory_transactions(ingredient_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_inventory_tx_created_at ON inventory_transactions(created_at)',
      );
```

(d) `_onUpgrade` 의 기존 `if (oldVersion < 8)` 블록 **뒤**에 추가:

```dart
      if (oldVersion < 9) {
        // 버전 9: 재고조사 — storage_location 컬럼 + inventory 테이블
        developer.log('재고조사 테이블 추가 시작', name: 'DatabaseHelper');

        await db.execute(
          'ALTER TABLE ingredients ADD COLUMN storage_location TEXT',
        );

        await db.execute('''
          CREATE TABLE IF NOT EXISTS inventory_items (
            id TEXT PRIMARY KEY,
            ingredient_id TEXT NOT NULL UNIQUE,
            current_qty REAL NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS inventory_transactions (
            id TEXT PRIMARY KEY,
            ingredient_id TEXT NOT NULL,
            type TEXT NOT NULL,
            qty_delta REAL NOT NULL,
            resulting_qty REAL NOT NULL,
            price REAL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
          )
        ''');
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_inventory_tx_ingredient_id ON inventory_transactions(ingredient_id)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_inventory_tx_created_at ON inventory_transactions(created_at)',
        );

        developer.log('재고조사 테이블 추가 완료', name: 'DatabaseHelper');
      }
```

- [ ] **Step 5: 테스트 통과 확인**

Run: `flutter test test/data/inventory_schema_test.dart`
Expected: PASS

Run: `flutter analyze lib/data/database_helper.dart`
Expected: No issues (신규 에러 0)

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/data/database_helper.dart test/data/inventory_schema_test.dart
git commit -m "feat: DB v9 — 재고조사 테이블(inventory_items/transactions) + storage_location 컬럼"
```

---

### Task 2: 모델 — StorageLocation, InventoryItem, InventoryTransaction + Ingredient 확장

**Files:**
- Create: `lib/model/storage_location.dart`
- Create: `lib/model/inventory_item.dart`
- Create: `lib/model/inventory_transaction.dart`
- Modify: `lib/model/ingredient.dart` (필드·toJson·fromJson·copyWith·props)
- Modify: `lib/model/index.dart` (export 추가)
- Test: `test/model/inventory_models_test.dart`

**Interfaces:**
- Produces:
  - `enum StorageLocation { shelf, fridge, freezer }` + `String dbValue` + `static StorageLocation? fromDb(String?)`
  - `class InventoryItem { String id; String ingredientId; double currentQty; DateTime updatedAt; }` + `toJson/fromJson/copyWith`
  - `enum InventoryTxType { purchase, consume, adjust, aiAdjust }` + `String dbValue` + `static InventoryTxType fromDb(String)`
  - `class InventoryTransaction { String id; String ingredientId; InventoryTxType type; double qtyDelta; double resultingQty; double? price; DateTime createdAt; }` + `toJson/fromJson`
  - `Ingredient.storageLocation` (`StorageLocation?`), copyWith 에 `storageLocation` 파라미터

- [ ] **Step 1: 실패하는 테스트 작성**

`test/model/inventory_models_test.dart`:

```dart
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
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/model/inventory_models_test.dart`
Expected: FAIL (컴파일 에러 — 클래스 미존재)

- [ ] **Step 3: 모델 구현**

`lib/model/storage_location.dart`:

```dart
/// 재료 보관 위치. DB 에는 dbValue 문자열로 저장.
enum StorageLocation {
  shelf('shelf'),
  fridge('fridge'),
  freezer('freezer');

  const StorageLocation(this.dbValue);
  final String dbValue;

  static StorageLocation? fromDb(String? value) {
    if (value == null) return null;
    for (final location in StorageLocation.values) {
      if (location.dbValue == value) return location;
    }
    return null;
  }
}
```

`lib/model/inventory_item.dart`:

```dart
import 'package:equatable/equatable.dart';

/// 재료당 1행의 현재 재고 잔량.
class InventoryItem extends Equatable {
  final String id;
  final String ingredientId;
  final double currentQty;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.ingredientId,
    required this.currentQty,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ingredient_id': ingredientId,
        'current_qty': currentQty,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'],
        ingredientId: json['ingredient_id'],
        currentQty: (json['current_qty'] as num).toDouble(),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  InventoryItem copyWith({double? currentQty, DateTime? updatedAt}) =>
      InventoryItem(
        id: id,
        ingredientId: ingredientId,
        currentQty: currentQty ?? this.currentQty,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [id, ingredientId, currentQty, updatedAt];
}
```

`lib/model/inventory_transaction.dart`:

```dart
import 'package:equatable/equatable.dart';

/// 재고 변동 유형. DB 에는 dbValue 문자열로 저장.
enum InventoryTxType {
  purchase('purchase'),
  consume('consume'),
  adjust('adjust'),
  aiAdjust('ai_adjust');

  const InventoryTxType(this.dbValue);
  final String dbValue;

  static InventoryTxType fromDb(String value) {
    for (final type in InventoryTxType.values) {
      if (type.dbValue == value) return type;
    }
    return InventoryTxType.adjust;
  }
}

/// 재고 변동 이력 1건.
class InventoryTransaction extends Equatable {
  final String id;
  final String ingredientId;
  final InventoryTxType type;
  final double qtyDelta;
  final double resultingQty;
  final double? price; // purchase 일 때 구매 금액
  final DateTime createdAt;

  const InventoryTransaction({
    required this.id,
    required this.ingredientId,
    required this.type,
    required this.qtyDelta,
    required this.resultingQty,
    this.price,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ingredient_id': ingredientId,
        'type': type.dbValue,
        'qty_delta': qtyDelta,
        'resulting_qty': resultingQty,
        'price': price,
        'created_at': createdAt.toIso8601String(),
      };

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) =>
      InventoryTransaction(
        id: json['id'],
        ingredientId: json['ingredient_id'],
        type: InventoryTxType.fromDb(json['type']),
        qtyDelta: (json['qty_delta'] as num).toDouble(),
        resultingQty: (json['resulting_qty'] as num).toDouble(),
        price: (json['price'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['created_at']),
      );

  @override
  List<Object?> get props =>
      [id, ingredientId, type, qtyDelta, resultingQty, price, createdAt];
}
```

`lib/model/ingredient.dart` 수정 4곳:

```dart
// (1) import 추가
import 'storage_location.dart';

// (2) 필드 추가 (isAnimationSettled 아래)
  final StorageLocation? storageLocation; // 보관 위치 (null = 미분류)
// 생성자 파라미터에도 추가:
    this.storageLocation,

// (3) toJson 맵에 추가
        'storage_location': storageLocation?.dbValue,

// (4) fromJson 에 추가
        storageLocation: StorageLocation.fromDb(json['storage_location']),

// (5) copyWith 파라미터·본문에 추가
    StorageLocation? storageLocation,
    ...
      storageLocation: storageLocation ?? this.storageLocation,

// (6) props 리스트에 storageLocation 추가
```

`lib/model/index.dart` 에 export 3줄 추가:

```dart
export 'storage_location.dart';
export 'inventory_item.dart';
export 'inventory_transaction.dart';
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/model/inventory_models_test.dart`
Expected: PASS

Run: `flutter analyze lib/model/`
Expected: 신규 에러 0

- [ ] **Step 5: Commit**

```bash
git add lib/model/ test/model/inventory_models_test.dart
git commit -m "feat: 재고 모델 — StorageLocation/InventoryItem/InventoryTransaction, Ingredient.storageLocation"
```

---

### Task 3: InventoryRepository

**Files:**
- Create: `lib/data/inventory_repository.dart`
- Modify: `lib/data/index.dart` (export 추가)
- Test: `test/data/inventory_repository_test.dart`

**Interfaces:**
- Consumes: Task 1 스키마, Task 2 모델
- Produces (이후 Cubit 이 사용):
  - `Future<Map<String, InventoryItem>> getAllItems()` — ingredientId → item
  - `Future<InventoryItem> setQuantity({required String ingredientId, required double newQty, required InventoryTxType type, double? price})` — lazy 생성, 잔량을 newQty 로 설정하고 delta 트랜잭션 기록. newQty < 0 은 0 으로 clamp.
  - `Future<InventoryItem> changeQuantity({required String ingredientId, required double delta, required InventoryTxType type, double? price})` — 현재 잔량 + delta (0 미만 clamp)
  - `Future<InventoryItem> recordPurchase({required String ingredientId, required double qty, required double price})` — changeQuantity(type: purchase, price 포함) 위임
  - `Future<({double totalPurchase, int txCount})> getTodaySummary()` — 오늘(로컬 자정 기준) purchase 금액 합 + 전체 트랜잭션 수

- [ ] **Step 1: 실패하는 테스트 작성**

`test/data/inventory_repository_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recipe_app/data/database_helper.dart';
import 'package:recipe_app/data/inventory_repository.dart';
import 'package:recipe_app/model/index.dart';

void main() {
  late InventoryRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
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

  test('recordPurchase: 잔량 증가 + 오늘 구매 합산', () async {
    await repo.recordPurchase(ingredientId: 'ing1', qty: 2.0, price: 5000);
    await repo.recordPurchase(ingredientId: 'ing2', qty: 1.0, price: 3000);

    final items = await repo.getAllItems();
    expect(items['ing1']!.currentQty, 2.0);

    final summary = await repo.getTodaySummary();
    expect(summary.totalPurchase, 8000);
    expect(summary.txCount, 2);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

Run: `flutter test test/data/inventory_repository_test.dart`
Expected: FAIL (InventoryRepository 미존재)

- [ ] **Step 3: 구현**

`lib/data/inventory_repository.dart`:

```dart
import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
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
```

`lib/data/index.dart` 에 `export 'inventory_repository.dart';` 추가.

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/data/`
Expected: PASS (schema + repository 테스트 모두)

Run: `flutter analyze lib/data/inventory_repository.dart`
Expected: 신규 에러 0

- [ ] **Step 5: Commit**

```bash
git add lib/data/ test/data/inventory_repository_test.dart
git commit -m "feat: InventoryRepository — 잔량 조정/구매 기록/오늘 요약"
```

---

### Task 4: 단위 스텝 유틸 + InventoryCubit

**Files:**
- Create: `lib/util/inventory_step.dart`
- Create: `lib/controller/inventory/inventory_cubit.dart`
- Modify: `lib/controller/index.dart` (export 추가)
- Test: `test/util/inventory_step_test.dart`, `test/controller/inventory_cubit_test.dart`

**Interfaces:**
- Consumes: `InventoryRepository`(Task 3), `IngredientRepository.getAllIngredients()/updateIngredient(Ingredient)`, `UnitRepository.getAllUnits()` (기존, `Unit` 모델은 `id`/`name` 필드 보유)
- Produces:
  - `double inventoryStepForUnit(String unitName)` — 개/팩/봉 등 1, kg/L 0.5, g/ml 100
  - `class InventoryState { bool isLoading; StorageLocation? selectedLocation; List<Ingredient> ingredients; Map<String, InventoryItem> items; Map<String, Unit> unitsById; double todayPurchaseTotal; int todayTxCount; String? error; }` + `filteredIngredients` getter (selectedLocation 기준, null 이면 미분류)
  - `class InventoryCubit extends Cubit<InventoryState>` 메서드: `load()`, `selectLocation(StorageLocation?)`, `increment(String ingredientId)`, `decrement(String ingredientId)`, `setQuantity(String ingredientId, double qty)`, `recordPurchase({required String ingredientId, required double qty, required double price})`, `classifyIngredient(String ingredientId, StorageLocation location)`

- [ ] **Step 1: 실패하는 스텝 유틸 테스트 작성**

`test/util/inventory_step_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/util/inventory_step.dart';

void main() {
  test('단위별 스테퍼 스텝', () {
    expect(inventoryStepForUnit('kg'), 0.5);
    expect(inventoryStepForUnit('L'), 0.5);
    expect(inventoryStepForUnit('l'), 0.5);
    expect(inventoryStepForUnit('g'), 100);
    expect(inventoryStepForUnit('ml'), 100);
    expect(inventoryStepForUnit('개'), 1);
    expect(inventoryStepForUnit('팩'), 1);
    expect(inventoryStepForUnit('봉'), 1);
    expect(inventoryStepForUnit('unknown'), 1);
  });
}
```

- [ ] **Step 2: 실패 확인 후 유틸 구현**

Run: `flutter test test/util/inventory_step_test.dart` → FAIL 확인.

`lib/util/inventory_step.dart`:

```dart
/// 재고 스테퍼의 단위 인식 스텝.
/// kg/L = 0.5, g/ml = 100, 그 외(개/팩/봉 등 개수 단위) = 1.
double inventoryStepForUnit(String unitName) {
  switch (unitName.trim().toLowerCase()) {
    case 'kg':
    case 'l':
      return 0.5;
    case 'g':
    case 'ml':
      return 100;
    default:
      return 1;
  }
}
```

Run: `flutter test test/util/inventory_step_test.dart` → PASS 확인.

- [ ] **Step 3: 실패하는 Cubit 테스트 작성**

`test/controller/inventory_cubit_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recipe_app/controller/inventory/inventory_cubit.dart';
import 'package:recipe_app/data/database_helper.dart';
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

    await cubit.decrement('ing1'); // 양파 단위 조회 실패 시 기본 스텝 1
    expect(cubit.state.items['ing1']!.currentQty, 2.0);
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
```

- [ ] **Step 4: 실패 확인**

Run: `flutter test test/controller/inventory_cubit_test.dart`
Expected: FAIL (InventoryCubit 미존재)

- [ ] **Step 5: Cubit 구현**

`lib/controller/inventory/inventory_cubit.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/index.dart';
import '../../model/index.dart';
import '../../util/inventory_step.dart';

class InventoryState extends Equatable {
  final bool isLoading;

  /// 선택된 세그먼트. null = 미분류 세그먼트.
  final StorageLocation? selectedLocation;
  final List<Ingredient> ingredients;
  final Map<String, InventoryItem> items; // ingredientId → 잔량
  final Map<String, Unit> unitsById;
  final double todayPurchaseTotal;
  final int todayTxCount;
  final String? error;

  const InventoryState({
    this.isLoading = false,
    this.selectedLocation = StorageLocation.shelf,
    this.ingredients = const [],
    this.items = const {},
    this.unitsById = const {},
    this.todayPurchaseTotal = 0,
    this.todayTxCount = 0,
    this.error,
  });

  /// 현재 세그먼트에 속한 재료 (이름순)
  List<Ingredient> get filteredIngredients {
    final list = ingredients
        .where((i) => i.storageLocation == selectedLocation)
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// 미분류 재료 수 (세그먼트 배지용)
  int get unsortedCount =>
      ingredients.where((i) => i.storageLocation == null).length;

  InventoryState copyWith({
    bool? isLoading,
    StorageLocation? Function()? selectedLocation,
    List<Ingredient>? ingredients,
    Map<String, InventoryItem>? items,
    Map<String, Unit>? unitsById,
    double? todayPurchaseTotal,
    int? todayTxCount,
    String? Function()? error,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      selectedLocation: selectedLocation != null
          ? selectedLocation()
          : this.selectedLocation,
      ingredients: ingredients ?? this.ingredients,
      items: items ?? this.items,
      unitsById: unitsById ?? this.unitsById,
      todayPurchaseTotal: todayPurchaseTotal ?? this.todayPurchaseTotal,
      todayTxCount: todayTxCount ?? this.todayTxCount,
      error: error != null ? error() : null,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        selectedLocation,
        ingredients,
        items,
        unitsById,
        todayPurchaseTotal,
        todayTxCount,
        error,
      ];
}

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _inventoryRepository;
  final IngredientRepository _ingredientRepository;
  final UnitRepository _unitRepository;

  InventoryCubit({
    required InventoryRepository inventoryRepository,
    required IngredientRepository ingredientRepository,
    required UnitRepository unitRepository,
  })  : _inventoryRepository = inventoryRepository,
        _ingredientRepository = ingredientRepository,
        _unitRepository = unitRepository,
        super(const InventoryState());

  /// 전체 로드: 재료 + 잔량 + 단위 + 오늘 요약
  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: () => null));
    try {
      final ingredients = await _ingredientRepository.getAllIngredients();
      final items = await _inventoryRepository.getAllItems();
      final units = await _unitRepository.getAllUnits();
      final summary = await _inventoryRepository.getTodaySummary();

      emit(state.copyWith(
        isLoading: false,
        ingredients: ingredients,
        items: items,
        unitsById: {for (final u in units) u.id: u},
        todayPurchaseTotal: summary.totalPurchase,
        todayTxCount: summary.txCount,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: () => e.toString()));
    }
  }

  void selectLocation(StorageLocation? location) {
    emit(state.copyWith(selectedLocation: () => location));
  }

  /// 재료의 구매 단위 기준 스텝 (단위 미조회 시 1)
  double stepFor(String ingredientId) {
    final ingredient =
        state.ingredients.where((i) => i.id == ingredientId).firstOrNull;
    if (ingredient == null) return 1;
    final unit = state.unitsById[ingredient.purchaseUnitId];
    if (unit == null) return 1;
    return inventoryStepForUnit(unit.name);
  }

  Future<void> increment(String ingredientId) => _change(
      ingredientId, stepFor(ingredientId), InventoryTxType.adjust);

  Future<void> decrement(String ingredientId) => _change(
      ingredientId, -stepFor(ingredientId), InventoryTxType.consume);

  Future<void> _change(
      String ingredientId, double delta, InventoryTxType type) async {
    try {
      final item = await _inventoryRepository.changeQuantity(
        ingredientId: ingredientId,
        delta: delta,
        type: type,
      );
      await _refreshAfterChange(ingredientId, item);
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  /// 직접 입력으로 잔량 설정 (adjust)
  Future<void> setQuantity(String ingredientId, double qty) async {
    try {
      final item = await _inventoryRepository.setQuantity(
        ingredientId: ingredientId,
        newQty: qty,
        type: InventoryTxType.adjust,
      );
      await _refreshAfterChange(ingredientId, item);
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  /// 구매 기록: 잔량 증가 + 금액 기록
  Future<void> recordPurchase({
    required String ingredientId,
    required double qty,
    required double price,
  }) async {
    try {
      final item = await _inventoryRepository.recordPurchase(
        ingredientId: ingredientId,
        qty: qty,
        price: price,
      );
      await _refreshAfterChange(ingredientId, item);
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  /// 미분류 재료의 보관 위치 지정 + 재고 행 lazy 생성 (잔량 0 유지)
  Future<void> classifyIngredient(
      String ingredientId, StorageLocation location) async {
    try {
      final ingredient =
          state.ingredients.where((i) => i.id == ingredientId).firstOrNull;
      if (ingredient == null) return;

      final updated = ingredient.copyWith(storageLocation: location);
      await _ingredientRepository.updateIngredient(updated);

      // 재고 행 없으면 잔량 0 으로 생성 (트랜잭션 delta 0)
      if (!state.items.containsKey(ingredientId)) {
        await _inventoryRepository.setQuantity(
          ingredientId: ingredientId,
          newQty: 0,
          type: InventoryTxType.adjust,
        );
      }
      await load();
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  Future<void> _refreshAfterChange(
      String ingredientId, InventoryItem item) async {
    final summary = await _inventoryRepository.getTodaySummary();
    emit(state.copyWith(
      items: {...state.items, ingredientId: item},
      todayPurchaseTotal: summary.totalPurchase,
      todayTxCount: summary.txCount,
    ));
  }
}
```

`lib/controller/index.dart` 에 `export 'inventory/inventory_cubit.dart';` 추가.

참고: `firstOrNull` 은 Dart 3 `package:collection` 없이 내장 (`Iterable.firstOrNull`, `import` 불필요 — sdk ^3.7.0).

- [ ] **Step 6: 테스트 통과 확인**

Run: `flutter test test/util/ test/controller/`
Expected: PASS

Run: `flutter analyze lib/controller/inventory/ lib/util/inventory_step.dart`
Expected: 신규 에러 0

- [ ] **Step 7: Commit**

```bash
git add lib/util/inventory_step.dart lib/controller/ test/util/ test/controller/
git commit -m "feat: InventoryCubit — 위치 필터/스테퍼 조정/구매 기록/분류"
```

---

### Task 5: i18n 문자열 (6로케일)

**Files:**
- Create: `lib/util/app_strings/app_strings_inventory.dart`
- Modify: `lib/util/app_strings.dart` (위임 getter 추가)

**Interfaces:**
- Produces: `AppStrings.getInventory(locale)` 등 아래 표의 모든 getter. 이후 UI Task 들이 사용.

- [ ] **Step 1: 문자열 mixin 작성**

`lib/util/app_strings/app_strings_inventory.dart` — 기존 `app_strings_ocr.dart` 와 동일한 switch 패턴으로, 아래 표의 **모든 행**을 각각 `static String getXxx(AppLocale locale)` 로 구현한다. 표의 번역을 그대로 사용:

| getter | korea | japan | china | chinaTraditional | usa | vietnam |
|---|---|---|---|---|---|---|
| getInventory | 재고 | 在庫 | 库存 | 庫存 | Inventory | Tồn kho |
| getInventoryShelf | 선반장 | 棚 | 货架 | 貨架 | Shelf | Kệ |
| getInventoryFridge | 냉장고 | 冷蔵庫 | 冷藏 | 冷藏 | Fridge | Tủ lạnh |
| getInventoryFreezer | 냉동고 | 冷凍庫 | 冷冻 | 冷凍 | Freezer | Tủ đông |
| getInventoryUnsorted | 미분류 | 未分類 | 未分类 | 未分類 | Unsorted | Chưa phân loại |
| getInventoryTodayPurchase | 오늘 구매 | 本日購入 | 今日采购 | 今日採購 | Today's purchases | Mua hôm nay |
| getInventoryAiScan | AI 재고 스캔 | AI在庫スキャン | AI库存扫描 | AI庫存掃描 | AI Stock Scan | Quét kho AI |
| getInventoryRecordPurchase | 구매 기록 | 購入記録 | 采购记录 | 採購記錄 | Record Purchase | Ghi mua hàng |
| getInventoryQtyUpdated | 재고가 변경되었습니다 | 在庫を更新しました | 库存已更新 | 庫存已更新 | Stock updated | Đã cập nhật kho |
| getUndo | 실행취소 | 元に戻す | 撤销 | 復原 | Undo | Hoàn tác |
| getInventoryEnterQty | 수량 입력 | 数量入力 | 输入数量 | 輸入數量 | Enter quantity | Nhập số lượng |
| getInventoryEmpty | 이 위치에 재료가 없습니다 | この場所に材料がありません | 此位置没有食材 | 此位置沒有食材 | No ingredients here | Không có nguyên liệu ở đây |
| getInventorySelectIngredient | 재료 선택 | 材料選択 | 选择食材 | 選擇食材 | Select ingredient | Chọn nguyên liệu |
| getInventoryPurchaseSaved | 구매가 기록되었습니다 | 購入を記録しました | 已记录采购 | 已記錄採購 | Purchase recorded | Đã ghi mua hàng |
| getInventoryAiPreviewTitle | AI 재고 미리보기 | AI在庫プレビュー | AI库存预览 | AI庫存預覽 | AI Stock Preview | Xem trước kho AI |
| getInventoryNewIngredient | 새 재료 | 新しい材料 | 新食材 | 新食材 | New | Mới |
| getInventoryApply | 반영 | 反映 | 应用 | 套用 | Apply | Áp dụng |
| getInventoryCurrent | 현재 | 現在 | 当前 | 目前 | Now | Hiện tại |
| getInventoryAiGuess | 추측 | 推測 | 推测 | 推測 | Est. | Ước tính |
| getInventoryAnalyzing | 재고 분석 중... | 在庫分析中... | 库存分析中... | 庫存分析中... | Analyzing stock... | Đang phân tích kho... |
| getInventoryNoAiResults | 인식된 재료가 없습니다 | 認識された材料がありません | 未识别到食材 | 未識別到食材 | No items recognized | Không nhận diện được nguyên liệu |
| getInventoryStorageLocation | 보관 위치 | 保管場所 | 存放位置 | 存放位置 | Storage location | Vị trí bảo quản |
| getInventoryPickImage | 사진 선택 | 写真選択 | 选择照片 | 選擇照片 | Choose photo | Chọn ảnh |
| getInventoryTakePhoto | 사진 촬영 | 写真撮影 | 拍照 | 拍照 | Take photo | Chụp ảnh |
| getInventoryError | 재고 처리 중 오류가 발생했습니다 | 在庫処理中にエラーが発生しました | 库存处理时发生错误 | 庫存處理時發生錯誤 | Inventory error occurred | Lỗi xử lý kho |

파일 골격과 첫 getter 의 정확한 형태 (나머지 getter 도 이 형태를 반복):

```dart
import '../app_locale.dart';

/// 재고조사 관련 문자열
mixin AppStringsInventory {
  static String getInventory(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재고';
      case AppLocale.japan:
        return '在庫';
      case AppLocale.china:
        return '库存';
      case AppLocale.chinaTraditional:
        return '庫存';
      case AppLocale.usa:
        return 'Inventory';
      case AppLocale.vietnam:
        return 'Tồn kho';
    }
  }

  // ... 표의 나머지 getter 전부 동일 패턴 ...

  /// 변동 건수 (파라미터 포함)
  static String getInventoryTodayChanges(AppLocale locale, int count) {
    switch (locale) {
      case AppLocale.korea:
        return '변동 $count건';
      case AppLocale.japan:
        return '変動 $count件';
      case AppLocale.china:
        return '变动 $count条';
      case AppLocale.chinaTraditional:
        return '變動 $count筆';
      case AppLocale.usa:
        return '$count changes';
      case AppLocale.vietnam:
        return '$count thay đổi';
    }
  }
}
```

- [ ] **Step 2: AppStrings 위임 추가**

`lib/util/app_strings.dart` 에 import 와 위임 getter 를 알파벳 순서 위치에 추가 (기존 `AppStringsSauce.getAdd` 위임과 동일 패턴):

```dart
import 'app_strings/app_strings_inventory.dart';
// ...
  static String getInventory(AppLocale locale) =>
      AppStringsInventory.getInventory(locale);
  static String getInventoryShelf(AppLocale locale) =>
      AppStringsInventory.getInventoryShelf(locale);
  // ... 표의 모든 getter + getInventoryTodayChanges(locale, count), getUndo ...
```

주의: `getUndo` 가 `app_strings.dart` 에 이미 존재하면 새로 추가하지 말고 기존 것을 사용.

- [ ] **Step 3: 검증**

Run: `flutter analyze lib/util/`
Expected: 신규 에러 0 (switch 누락 시 non-exhaustive 에러로 잡힘)

- [ ] **Step 4: Commit**

```bash
git add lib/util/app_strings/ lib/util/app_strings.dart
git commit -m "feat: 재고조사 i18n 문자열 (6로케일)"
```

---

### Task 6: 재고 탭 등록 + InventoryPage 메인 UI

**Files:**
- Create: `lib/screen/pages/inventory/inventory_page.dart`
- Modify: `lib/router/app_router.dart` (`_pages` 2번째 삽입, 탭 아이템/새로고침 인덱스 갱신)
- Modify: `lib/main.dart` (`InventoryCubit` BlocProvider 등록)

**Interfaces:**
- Consumes: `InventoryCubit`(Task 4), `AppStrings.getInventory*`(Task 5), 디자인 토큰
- Produces: `class InventoryMainPage extends StatelessWidget` (`inventory_page.dart`). 하단 탭 순서: 재료(0) · **재고(1)** · 레시피(2) · 리포트(3) · 설정(4). Task 7/9 가 이 페이지의 하단 액션에서 진입.

- [ ] **Step 1: main.dart 에 Cubit 등록**

`lib/main.dart` 의 MultiBlocProvider providers 에서 `IngredientCubit` 등록 블록 **뒤**에 추가:

```dart
        // 재고조사 Cubit
        BlocProvider<InventoryCubit>(
          create: (context) => InventoryCubit(
            inventoryRepository: InventoryRepository(),
            ingredientRepository: context.read<IngredientRepository>(),
            unitRepository: context.read<UnitRepository>(),
          ),
        ),
```

(`controller/index.dart`, `data/index.dart` 는 이미 import 되어 있음 — export 추가로 자동 인식)

- [ ] **Step 2: InventoryPage 구현**

`lib/screen/pages/inventory/inventory_page.dart` — 전체 구현:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/index.dart';
import '../../../model/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_formatter.dart';

/// 재고 탭 메인. 위치 세그먼트 + 인라인 스테퍼 목록 + 하단 액션.
class InventoryMainPage extends StatelessWidget {
  const InventoryMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, locale) {
        return Scaffold(
          backgroundColor: tokens.bgBase,
          appBar: AppBar(
            title: Text(AppStrings.getInventory(locale),
                style: AppTypography.title2.copyWith(color: tokens.fgStrong)),
            backgroundColor: tokens.bgBase,
            elevation: 0,
          ),
          body: BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
              if (state.isLoading && state.ingredients.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  _SummaryCard(state: state, locale: locale),
                  _LocationSegments(state: state, locale: locale),
                  Expanded(
                    child: state.filteredIngredients.isEmpty
                        ? _EmptyView(locale: locale)
                        : _IngredientList(state: state, locale: locale),
                  ),
                  _BottomActions(locale: locale),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// 상단 요약: 오늘 구매 총액 · 변동 건수
class _SummaryCard extends StatelessWidget {
  final InventoryState state;
  final AppLocale locale;
  const _SummaryCard({required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s8),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR12,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 20, color: tokens.primary),
          const SizedBox(width: AppSpacing.s8),
          Text(
            '${AppStrings.getInventoryTodayPurchase(locale)} '
            '${NumberFormatter.formatCurrency(state.todayPurchaseTotal, locale)}',
            style: AppTypography.label1.copyWith(color: tokens.fgStrong),
          ),
          const Spacer(),
          Text(
            AppStrings.getInventoryTodayChanges(locale, state.todayTxCount),
            style: AppTypography.caption1.copyWith(color: tokens.fgTertiary),
          ),
        ],
      ),
    );
  }
}

/// 위치 세그먼트: 선반장 | 냉장고 | 냉동고 | 미분류(n)
class _LocationSegments extends StatelessWidget {
  final InventoryState state;
  final AppLocale locale;
  const _LocationSegments({required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final cubit = context.read<InventoryCubit>();

    Widget chip(String label, StorageLocation? value, {int? badge}) {
      final selected = state.selectedLocation == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => cubit.selectLocation(value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
            decoration: BoxDecoration(
              color: selected ? tokens.primary : tokens.bgMuted,
              borderRadius: AppRadius.brR8,
            ),
            alignment: Alignment.center,
            child: Text(
              badge != null && badge > 0 ? '$label($badge)' : label,
              style: AppTypography.label2.copyWith(
                color: selected ? Colors.white : tokens.fgSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16, vertical: AppSpacing.s4),
      child: Row(
        children: [
          chip(AppStrings.getInventoryShelf(locale), StorageLocation.shelf),
          const SizedBox(width: AppSpacing.s6),
          chip(AppStrings.getInventoryFridge(locale), StorageLocation.fridge),
          const SizedBox(width: AppSpacing.s6),
          chip(AppStrings.getInventoryFreezer(locale), StorageLocation.freezer),
          const SizedBox(width: AppSpacing.s6),
          chip(AppStrings.getInventoryUnsorted(locale), null,
              badge: state.unsortedCount),
        ],
      ),
    );
  }
}

/// 재료 목록. 분류된 세그먼트 = 스테퍼 행, 미분류 = 위치 지정 칩 행.
class _IngredientList extends StatelessWidget {
  final InventoryState state;
  final AppLocale locale;
  const _IngredientList({required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isUnsorted = state.selectedLocation == null;
    final items = state.filteredIngredients;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
      itemBuilder: (context, index) {
        final ingredient = items[index];
        return isUnsorted
            ? _UnsortedRow(ingredient: ingredient, locale: locale)
            : _StepperRow(
                ingredient: ingredient, state: state, locale: locale);
      },
    );
  }
}

/// 분류된 재료 행: 이름 + [-] 잔량 단위 [+]
class _StepperRow extends StatelessWidget {
  final Ingredient ingredient;
  final InventoryState state;
  final AppLocale locale;
  const _StepperRow(
      {required this.ingredient, required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final cubit = context.read<InventoryCubit>();
    final qty = state.items[ingredient.id]?.currentQty ?? 0.0;
    final unitName = state.unitsById[ingredient.purchaseUnitId]?.name ?? '';
    // 소수점 불필요 시 정수 표기
    final qtyText = qty == qty.roundToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR12,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(ingredient.name,
                style: AppTypography.body1.copyWith(color: tokens.fgStrong),
                overflow: TextOverflow.ellipsis),
          ),
          _RoundIconButton(
            icon: Icons.remove,
            onTap: () => _changeWithUndo(context, () =>
                cubit.decrement(ingredient.id)),
          ),
          GestureDetector(
            onTap: () => _showQtyInputDialog(context, cubit),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              child: Text('$qtyText $unitName',
                  style:
                      AppTypography.label1.copyWith(color: tokens.fgStrong)),
            ),
          ),
          _RoundIconButton(
            icon: Icons.add,
            onTap: () => _changeWithUndo(context, () =>
                cubit.increment(ingredient.id)),
          ),
        ],
      ),
    );
  }

  /// 변경 실행 + 실행취소 스낵바 (이전 잔량으로 setQuantity 복원)
  void _changeWithUndo(
      BuildContext context, Future<void> Function() action) async {
    final cubit = context.read<InventoryCubit>();
    final previousQty =
        cubit.state.items[ingredient.id]?.currentQty ?? 0.0;
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(AppStrings.getInventoryQtyUpdated(locale)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: AppStrings.getUndo(locale),
          onPressed: () => cubit.setQuantity(ingredient.id, previousQty),
        ),
      ));
  }

  /// 숫자패드 직접 입력
  void _showQtyInputDialog(BuildContext context, InventoryCubit cubit) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.getInventoryEnterQty(locale)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText:
                cubit.state.unitsById[ingredient.purchaseUnitId]?.name ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () {
              final qty = double.tryParse(controller.text);
              if (qty != null) {
                cubit.setQuantity(ingredient.id, qty);
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text(AppStrings.getConfirm(locale)),
          ),
        ],
      ),
    );
  }
}

/// 미분류 재료 행: 이름 + 위치 지정 칩 3개
class _UnsortedRow extends StatelessWidget {
  final Ingredient ingredient;
  final AppLocale locale;
  const _UnsortedRow({required this.ingredient, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final cubit = context.read<InventoryCubit>();

    Widget chip(String label, StorageLocation location) {
      return GestureDetector(
        onTap: () => cubit.classifyIngredient(ingredient.id, location),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
          decoration: BoxDecoration(
            color: tokens.primarySoft,
            borderRadius: AppRadius.brPill,
          ),
          child: Text(label,
              style: AppTypography.caption1.copyWith(color: tokens.primary)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR12,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(ingredient.name,
                style: AppTypography.body1.copyWith(color: tokens.fgStrong),
                overflow: TextOverflow.ellipsis),
          ),
          chip(AppStrings.getInventoryShelf(locale), StorageLocation.shelf),
          const SizedBox(width: AppSpacing.s4),
          chip(AppStrings.getInventoryFridge(locale), StorageLocation.fridge),
          const SizedBox(width: AppSpacing.s4),
          chip(AppStrings.getInventoryFreezer(locale), StorageLocation.freezer),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brPill,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: tokens.bgMuted,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: tokens.fgSecondary),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final AppLocale locale;
  const _EmptyView({required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Center(
      child: Text(AppStrings.getInventoryEmpty(locale),
          style: AppTypography.body2.copyWith(color: tokens.fgTertiary)),
    );
  }
}

/// 하단 액션: AI 재고 스캔 · 구매 기록 (Task 7/9 에서 onPressed 연결)
class _BottomActions extends StatelessWidget {
  final AppLocale locale;
  const _BottomActions({required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.accentAi,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                ),
                onPressed: () => onAiScanPressed(context, locale),
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: Text(AppStrings.getInventoryAiScan(locale),
                    style: AppTypography.label1),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                ),
                onPressed: () => onPurchasePressed(context, locale),
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                label: Text(AppStrings.getInventoryRecordPurchase(locale),
                    style: AppTypography.label1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Task 9 에서 실제 흐름으로 교체. 이 Task 에서는 no-op.
  void onAiScanPressed(BuildContext context, AppLocale locale) {}

  /// Task 7 에서 실제 흐름으로 교체. 이 Task 에서는 no-op.
  void onPurchasePressed(BuildContext context, AppLocale locale) {}
}
```

주의: `AppStrings.getCancel` / `getConfirm` / `NumberFormatter.formatCurrency` 는 기존 코드에 존재 — 시그니처가 다르면 기존 것에 맞춘다 (예: `formatCurrency(double, AppLocale)` 가 아니라 `format(...)` 이면 그걸 사용).

- [ ] **Step 3: 라우터에 탭 추가**

`lib/router/app_router.dart`:

(a) import 추가: `import '../screen/pages/inventory/inventory_page.dart';`

(b) `_pages` 를 다음으로 교체 (재고를 2번째로):

```dart
  final List<Widget> _pages = [
    const IngredientMainPage(),
    const InventoryMainPage(),
    const RecipeMainPage(),
    const ReportPage(),
    const SettingsPage(),
  ];
```

(c) `onTap` 의 새로고침 분기를 새 인덱스로 교체:

```dart
                  if (index == 0) {
                    context.read<IngredientCubit>().loadIngredients();
                  } else if (index == 1) {
                    // 재고 탭
                    context.read<InventoryCubit>().load();
                  } else if (index == 2) {
                    context.read<RecipeCubit>().loadRecipes();
                  } else if (index == 3) {
                    context.read<ReportCubit>().refresh();
                  }
```

(d) `items` 에 재고 탭 아이템을 2번째로 삽입:

```dart
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.warehouse_outlined),
                    label: AppStrings.getInventory(currentLocale),
                  ),
```

(`controller/index.dart` import 는 기존 파일에 이미 있음 — InventoryCubit 자동 인식)

- [ ] **Step 4: 검증**

Run: `flutter analyze lib/screen/pages/inventory/ lib/router/app_router.dart lib/main.dart`
Expected: 신규 에러 0

Run: `flutter test`
Expected: 기존 테스트 전부 PASS

수동 확인 (시뮬레이터/기기): 앱 실행 → 하단 탭 5개 · 순서(재료/재고/레시피/리포트/설정) 확인 → 재고 탭에서 세그먼트 전환, 미분류에서 위치 칩으로 분류, 스테퍼 +/− 동작, 직접 입력, 실행취소 스낵바 확인.

- [ ] **Step 5: Commit**

```bash
git add lib/screen/pages/inventory/ lib/router/app_router.dart lib/main.dart
git commit -m "feat: 재고 탭 — 위치 세그먼트/인라인 스테퍼/미분류 분류 UI"
```

---

### Task 7: 구매 기록 바텀시트

**Files:**
- Create: `lib/screen/pages/inventory/purchase_record_sheet.dart`
- Modify: `lib/screen/pages/inventory/inventory_page.dart` (`onPurchasePressed` 연결)

**Interfaces:**
- Consumes: `InventoryCubit.recordPurchase`, `InventoryState.ingredients/unitsById`
- Produces: `void showPurchaseRecordSheet(BuildContext context, AppLocale locale)` — 바텀시트 열기

- [ ] **Step 1: 바텀시트 구현**

`lib/screen/pages/inventory/purchase_record_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/index.dart';
import '../../../model/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';

/// 구매 기록 바텀시트.
/// 재료 검색 선택 → 수량/금액이 구매단위량·구매가로 프리필 → 저장 (2탭 목표).
void showPurchaseRecordSheet(BuildContext context, AppLocale locale) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<InventoryCubit>(),
      child: _PurchaseSheetBody(locale: locale),
    ),
  );
}

class _PurchaseSheetBody extends StatefulWidget {
  final AppLocale locale;
  const _PurchaseSheetBody({required this.locale});

  @override
  State<_PurchaseSheetBody> createState() => _PurchaseSheetBodyState();
}

class _PurchaseSheetBodyState extends State<_PurchaseSheetBody> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  Ingredient? _selected;

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _select(Ingredient ingredient) {
    setState(() {
      _selected = ingredient;
      // 프리필: 구매단위량 / 구매가 — 반복 구매는 그대로 저장만 누르면 됨
      _qtyController.text = ingredient.purchaseAmount == 
              ingredient.purchaseAmount.roundToDouble()
          ? ingredient.purchaseAmount.toInt().toString()
          : ingredient.purchaseAmount.toString();
      _priceController.text = ingredient.purchasePrice == 
              ingredient.purchasePrice.roundToDouble()
          ? ingredient.purchasePrice.toInt().toString()
          : ingredient.purchasePrice.toString();
    });
  }

  Future<void> _save() async {
    final ingredient = _selected;
    if (ingredient == null) return;
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    if (qty <= 0) return;

    final cubit = context.read<InventoryCubit>();
    await cubit.recordPurchase(
        ingredientId: ingredient.id, qty: qty, price: price);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppStrings.getInventoryPurchaseSaved(widget.locale)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final state = context.watch<InventoryCubit>().state;
    final query = _searchController.text.trim();
    final candidates = query.isEmpty
        ? state.ingredients
        : state.ingredients
            .where((i) => i.name.contains(query))
            .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: tokens.bgElev1,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.r16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.getInventoryRecordPurchase(widget.locale),
                style:
                    AppTypography.title3.copyWith(color: tokens.fgStrong)),
            const SizedBox(height: AppSpacing.s12),
            if (_selected == null) ...[
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText:
                      AppStrings.getInventorySelectIngredient(widget.locale),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final ingredient = candidates[index];
                    final unitName =
                        state.unitsById[ingredient.purchaseUnitId]?.name ??
                            '';
                    return ListTile(
                      dense: true,
                      title: Text(ingredient.name,
                          style: AppTypography.body1
                              .copyWith(color: tokens.fgStrong)),
                      subtitle: Text(
                          '${ingredient.purchaseAmount} $unitName · '
                          '${ingredient.purchasePrice}',
                          style: AppTypography.caption1
                              .copyWith(color: tokens.fgTertiary)),
                      onTap: () => _select(ingredient),
                    );
                  },
                ),
              ),
            ] else ...[
              // 선택된 재료 + 프리필된 수량/금액
              Row(
                children: [
                  Expanded(
                    child: Text(_selected!.name,
                        style: AppTypography.heading1
                            .copyWith(color: tokens.fgStrong)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selected = null),
                    child: Text(AppStrings.getCancel(widget.locale)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText:
                            AppStrings.getInventoryEnterQty(widget.locale),
                        suffixText: state
                                .unitsById[_selected!.purchaseUnitId]?.name ??
                            '',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            AppStrings.getInventoryTodayPurchase(widget.locale),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                ),
                onPressed: _save,
                child: Text(AppStrings.getSave(widget.locale),
                    style: AppTypography.label1),
              ),
            ],
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}
```

주의: `AppStrings.getSave` / `getCancel` 이 기존에 존재하는지 확인하고 없으면 Task 5 mixin 에 같은 패턴으로 추가.

- [ ] **Step 2: InventoryPage 연결**

`inventory_page.dart` 의 `_BottomActions.onPurchasePressed` 를 교체:

```dart
import 'purchase_record_sheet.dart';
// ...
  void onPurchasePressed(BuildContext context, AppLocale locale) {
    showPurchaseRecordSheet(context, locale);
  }
```

- [ ] **Step 3: 검증**

Run: `flutter analyze lib/screen/pages/inventory/`
Expected: 신규 에러 0

수동 확인: 구매 기록 버튼 → 재료 검색·선택 → 프리필 값 그대로 저장 → 잔량 증가·오늘 구매 총액 갱신·스낵바 확인.

- [ ] **Step 4: Commit**

```bash
git add lib/screen/pages/inventory/
git commit -m "feat: 구매 기록 바텀시트 — 프리필로 2탭 저장"
```

---

### Task 8: InventoryGeminiService (AI 텍스트 분석)

**Files:**
- Create: `lib/service/inventory_gemini_service.dart`
- Test: `test/service/inventory_gemini_parse_test.dart`

**Interfaces:**
- Consumes: `dotenv.env['GEMINI_API_KEY']`, `google_generative_ai`
- Produces:
  - `class InventoryAiRow { String name; double qty; String unit; String note; }`
  - `class InventoryGeminiService { Future<List<InventoryAiRow>> analyzeInventoryText(String ocrText); static List<InventoryAiRow> parseResponse(String text); }`
  - 파싱은 `재료명 | 수량 | 단위 | 비고` 파이프 형식 (OcrGeminiService 와 동일 컨벤션)

- [ ] **Step 1: 실패하는 파싱 테스트 작성**

`test/service/inventory_gemini_parse_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/service/inventory_gemini_service.dart';

void main() {
  test('파이프 응답 파싱: 정상 행', () {
    const response = '''
양파 | 4 | kg | 박스 라벨 기준
소시지 | 2 | 팩 |
''';
    final rows = InventoryGeminiService.parseResponse(response);
    expect(rows.length, 2);
    expect(rows[0].name, '양파');
    expect(rows[0].qty, 4);
    expect(rows[0].unit, 'kg');
    expect(rows[1].name, '소시지');
    expect(rows[1].unit, '팩');
  });

  test('잘못된 행 무시: 헤더/빈 줄/수량 파싱 불가', () {
    const response = '''
# 분석 결과
양파 | abc | kg |

감자 | 3 | kg |
''';
    final rows = InventoryGeminiService.parseResponse(response);
    expect(rows.length, 1);
    expect(rows[0].name, '감자');
  });
}
```

- [ ] **Step 2: 실패 확인**

Run: `flutter test test/service/inventory_gemini_parse_test.dart`
Expected: FAIL (클래스 미존재)

- [ ] **Step 3: 서비스 구현**

`lib/service/inventory_gemini_service.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// AI 재고 스캔 결과 1행.
class InventoryAiRow {
  final String name;
  final double qty;
  final String unit;
  final String note;

  const InventoryAiRow({
    required this.name,
    required this.qty,
    required this.unit,
    this.note = '',
  });
}

/// 사진 속 텍스트(OCR 결과)를 분석해 재고 수량을 추측하는 서비스.
/// [OcrGeminiService] 와 같은 패턴 — 별도 프롬프트/파서를 가진 독립 클래스.
class InventoryGeminiService {
  static const String _modelName = 'gemini-3-flash-preview';
  late final GenerativeModel _model;

  InventoryGeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY가 설정되지 않았습니다.');
    }
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        topK: 20,
        topP: 0.8,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// OCR 텍스트에서 재고 추측 목록 추출
  Future<List<InventoryAiRow>> analyzeInventoryText(String ocrText) async {
    final prompt = _buildPrompt(ocrText);
    final response = await _model.generateContent([Content.text(prompt)]);
    return parseResponse(response.text ?? '');
  }

  /// `재료명 | 수량 | 단위 | 비고` 형식 응답 파싱. 수량 파싱 불가 행은 무시.
  static List<InventoryAiRow> parseResponse(String text) {
    final rows = <InventoryAiRow>[];
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || !trimmed.contains('|')) continue;
      if (trimmed.startsWith('#') || trimmed.startsWith('-')) continue;

      final parts = trimmed.split('|').map((p) => p.trim()).toList();
      if (parts.length < 2 || parts[0].isEmpty) continue;

      final qty = double.tryParse(parts[1].replaceAll(',', ''));
      if (qty == null || qty < 0) continue;

      rows.add(InventoryAiRow(
        name: parts[0],
        qty: qty,
        unit: parts.length > 2 ? parts[2] : '',
        note: parts.length > 3 ? parts[3] : '',
      ));
    }
    return rows;
  }

  String _buildPrompt(String ocrText) {
    return '''
당신은 매장 재고 사진에서 추출된 텍스트를 분석하여 재료별 현재 재고 수량을 추측하는 전문가입니다.

## 분석 대상 텍스트 (사진 OCR 결과):
```
$ocrText
```

## 목표:
- 텍스트에 보이는 식재료의 이름과 수량을 추측합니다.
- 박스/포장 라벨의 용량 표기 (예: 300g*2, 2kg) 와 개수를 활용합니다.
- 식재료가 아닌 것 (날짜, 가격표, 바코드, 매장 정보) 은 제외합니다.

## 출력 형식 (한 줄에 하나, 파이프 구분):
재료명 | 수량 | 단위 | 비고

규칙:
- 수량은 숫자만 (예: 4, 2.5). 추측 불가 시 그 행은 출력하지 않습니다.
- 단위는 kg, g, L, ml, 개, 팩, 봉 중 텍스트에서 확인되는 것. 불명확하면 개.
- 설명 문장, 헤더, 마크다운 없이 데이터 행만 출력합니다.

예시:
양파 | 4 | kg | 박스 라벨
소시지 | 2 | 팩 |
''';
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

Run: `flutter test test/service/inventory_gemini_parse_test.dart`
Expected: PASS

Run: `flutter analyze lib/service/inventory_gemini_service.dart`
Expected: 신규 에러 0

- [ ] **Step 5: Commit**

```bash
git add lib/service/inventory_gemini_service.dart test/service/
git commit -m "feat: InventoryGeminiService — OCR 텍스트 기반 재고 추측"
```

---

### Task 9: AI 스캔 흐름 + 미리보기 페이지

**Files:**
- Create: `lib/screen/pages/inventory/inventory_ai_preview_page.dart`
- Modify: `lib/screen/pages/inventory/inventory_page.dart` (`onAiScanPressed` 연결)
- Modify: `lib/controller/inventory/inventory_cubit.dart` (`applyAiAdjustments` 메서드 추가)

**Interfaces:**
- Consumes: `image_picker`(기존), `OcrService.recognizeTextAuto(File)`(기존), `InventoryGeminiService`(Task 8), `IngredientRepository.insertIngredient`, `UnitRepository.getAllUnits`
- Produces:
  - `InventoryCubit.applyAiAdjustments(List<InventoryAiApplyItem> items)` — 체크된 항목 일괄 반영
  - `class InventoryAiApplyItem { String? ingredientId; String name; double qty; String unitName; }` — ingredientId null 이면 새 재료 생성
  - `class InventoryAiPreviewPage extends StatefulWidget` — Navigator.push 로 진입

- [ ] **Step 1: Cubit 에 applyAiAdjustments 추가**

`lib/controller/inventory/inventory_cubit.dart` 에 클래스와 메서드 추가:

```dart
// 파일 상단 (InventoryState 위)
/// AI 미리보기에서 반영할 1건. ingredientId null = 새 재료 생성.
class InventoryAiApplyItem {
  final String? ingredientId;
  final String name;
  final double qty;
  final String unitName;

  const InventoryAiApplyItem({
    this.ingredientId,
    required this.name,
    required this.qty,
    required this.unitName,
  });
}
```

InventoryCubit 클래스에 필드·메서드 추가 (uuid import 필요: `package:uuid/uuid.dart`):

```dart
  final Uuid _uuid = const Uuid();

  /// AI 미리보기에서 체크된 항목 일괄 반영.
  /// - 기존 재료: 잔량을 추측값으로 설정 (ai_adjust)
  /// - 새 재료: 재료 마스터 생성 (구매가 0, 위치 shelf) 후 잔량 설정
  Future<void> applyAiAdjustments(List<InventoryAiApplyItem> items) async {
    try {
      for (final item in items) {
        String ingredientId;
        if (item.ingredientId != null) {
          ingredientId = item.ingredientId!;
        } else {
          // 단위 이름 매칭 (대소문자 무시), 실패 시 첫 단위
          final units = await _unitRepository.getAllUnits();
          final matched = units
              .where((u) =>
                  u.name.toLowerCase() == item.unitName.toLowerCase())
              .firstOrNull;
          final unitId =
              matched?.id ?? (units.isNotEmpty ? units.first.id : '');

          final newIngredient = Ingredient(
            id: _uuid.v4(),
            name: item.name,
            purchasePrice: 0,
            purchaseAmount: item.qty > 0 ? item.qty : 1,
            purchaseUnitId: unitId,
            createdAt: DateTime.now(),
            tagIds: const [],
            storageLocation: StorageLocation.shelf,
          );
          await _ingredientRepository.insertIngredient(newIngredient);
          ingredientId = newIngredient.id;
        }

        await _inventoryRepository.setQuantity(
          ingredientId: ingredientId,
          newQty: item.qty,
          type: InventoryTxType.aiAdjust,
        );
      }
      await load();
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }
```

- [ ] **Step 2: Cubit 테스트 추가 후 통과 확인**

`test/controller/inventory_cubit_test.dart` 에 테스트 추가:

```dart
  test('applyAiAdjustments: 기존 재료 조정 + 새 재료 생성', () async {
    await cubit.load();
    await cubit.applyAiAdjustments([
      const InventoryAiApplyItem(
          ingredientId: 'ing1', name: '양파', qty: 4, unitName: 'kg'),
      const InventoryAiApplyItem(
          ingredientId: null, name: '감자', qty: 3, unitName: 'kg'),
    ]);

    expect(cubit.state.items['ing1']!.currentQty, 4.0);
    final potato =
        cubit.state.ingredients.where((i) => i.name == '감자').firstOrNull;
    expect(potato, isNotNull);
    expect(potato!.storageLocation, StorageLocation.shelf);
    expect(cubit.state.items[potato.id]!.currentQty, 3.0);
  });
```

Run: `flutter test test/controller/inventory_cubit_test.dart` → PASS 확인.

- [ ] **Step 3: 미리보기 페이지 구현**

`lib/screen/pages/inventory/inventory_ai_preview_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/index.dart';
import '../../../model/index.dart';
import '../../../service/inventory_gemini_service.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';

/// AI 재고 스캔 미리보기. 행별 체크 → 확인 시 일괄 반영.
class InventoryAiPreviewPage extends StatefulWidget {
  final List<InventoryAiRow> rows;
  final AppLocale locale;

  const InventoryAiPreviewPage({
    super.key,
    required this.rows,
    required this.locale,
  });

  @override
  State<InventoryAiPreviewPage> createState() =>
      _InventoryAiPreviewPageState();
}

class _InventoryAiPreviewPageState extends State<InventoryAiPreviewPage> {
  late final List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(widget.rows.length, true);
  }

  /// 이름으로 기존 재료 매칭 (정확 일치 우선, 없으면 contains)
  Ingredient? _match(InventoryState state, String name) {
    final exact =
        state.ingredients.where((i) => i.name == name).firstOrNull;
    if (exact != null) return exact;
    return state.ingredients
        .where((i) => i.name.contains(name) || name.contains(i.name))
        .firstOrNull;
  }

  Future<void> _apply() async {
    final cubit = context.read<InventoryCubit>();
    final state = cubit.state;
    final items = <InventoryAiApplyItem>[];
    for (var i = 0; i < widget.rows.length; i++) {
      if (!_checked[i]) continue;
      final row = widget.rows[i];
      final matched = _match(state, row.name);
      items.add(InventoryAiApplyItem(
        ingredientId: matched?.id,
        name: row.name,
        qty: row.qty,
        unitName: row.unit,
      ));
    }
    await cubit.applyAiAdjustments(items);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final state = context.watch<InventoryCubit>().state;
    final locale = widget.locale;

    return Scaffold(
      backgroundColor: tokens.bgBase,
      appBar: AppBar(
        title: Text(AppStrings.getInventoryAiPreviewTitle(locale),
            style: AppTypography.title2.copyWith(color: tokens.fgStrong)),
        backgroundColor: tokens.bgBase,
        elevation: 0,
      ),
      body: widget.rows.isEmpty
          ? Center(
              child: Text(AppStrings.getInventoryNoAiResults(locale),
                  style:
                      AppTypography.body2.copyWith(color: tokens.fgTertiary)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: widget.rows.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.s8),
              itemBuilder: (context, index) {
                final row = widget.rows[index];
                final matched = _match(state, row.name);
                final currentQty = matched == null
                    ? null
                    : (state.items[matched.id]?.currentQty ?? 0.0);

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                  decoration: BoxDecoration(
                    color: tokens.bgElev1,
                    borderRadius: AppRadius.brR12,
                    border: Border.all(color: tokens.borderSubtle),
                  ),
                  child: CheckboxListTile(
                    value: _checked[index],
                    onChanged: (v) =>
                        setState(() => _checked[index] = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(row.name,
                              style: AppTypography.body1
                                  .copyWith(color: tokens.fgStrong),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (matched == null) ...[
                          const SizedBox(width: AppSpacing.s6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s6,
                                vertical: AppSpacing.s2),
                            decoration: BoxDecoration(
                              color: tokens.accentAiSoft,
                              borderRadius: AppRadius.brPill,
                            ),
                            child: Text(
                                AppStrings.getInventoryNewIngredient(locale),
                                style: AppTypography.caption2
                                    .copyWith(color: tokens.accentAi)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      matched == null
                          ? '${AppStrings.getInventoryAiGuess(locale)} '
                              '${row.qty} ${row.unit}'
                          : '${AppStrings.getInventoryCurrent(locale)} '
                              '$currentQty → '
                              '${AppStrings.getInventoryAiGuess(locale)} '
                              '${row.qty}',
                      style: AppTypography.caption1
                          .copyWith(color: tokens.fgTertiary),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: tokens.primary,
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.s12),
            ),
            onPressed: widget.rows.isEmpty ? null : _apply,
            child: Text(AppStrings.getInventoryApply(locale),
                style: AppTypography.label1),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 스캔 진입 흐름 연결**

`inventory_page.dart` 의 `_BottomActions.onAiScanPressed` 를 교체. import 추가:

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../service/ocr_service.dart';
import '../../../service/inventory_gemini_service.dart';
import 'inventory_ai_preview_page.dart';
```

구현:

```dart
  Future<void> onAiScanPressed(BuildContext context, AppLocale locale) async {
    final cubit = context.read<InventoryCubit>();
    final tokens = AppColorTokens.of(context);

    // 1) 카메라/갤러리 선택
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(AppStrings.getInventoryTakePhoto(locale)),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(AppStrings.getInventoryPickImage(locale)),
              onTap: () =>
                  Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    // 2) 이미지 선택
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null || !context.mounted) return;

    // 3) 분석 진행 다이얼로그
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            color: tokens.bgElev1,
            borderRadius: AppRadius.brR16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.s12),
              Text(AppStrings.getInventoryAnalyzing(locale),
                  style: AppTypography.body2
                      .copyWith(color: tokens.fgSecondary)),
            ],
          ),
        ),
      ),
    );

    try {
      // 4) 기존 OCR (ML Kit) → 텍스트 → Gemini 재고 추측
      final ocrText =
          await OcrService().recognizeTextAuto(File(picked.path));
      final rows =
          await InventoryGeminiService().analyzeInventoryText(ocrText);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // 진행 다이얼로그 닫기

      // 5) 미리보기 페이지
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: InventoryAiPreviewPage(rows: rows, locale: locale),
        ),
      ));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // 진행 다이얼로그 닫기
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppStrings.getInventoryError(locale)),
        duration: const Duration(seconds: 3),
      ));
    }
  }
```

주의: `_BottomActions` 는 StatelessWidget 이므로 `onAiScanPressed` 가 async 여도 무방. `OcrService.recognizeTextAuto` 시그니처가 다르면 (locale 파라미터 필요 등) 기존 `ocr_main_page.dart` 의 호출 방식을 따른다.

- [ ] **Step 5: 검증**

Run: `flutter analyze lib/screen/pages/inventory/ lib/controller/inventory/`
Expected: 신규 에러 0

Run: `flutter test`
Expected: 전부 PASS

수동 확인 (실기기 권장 — 카메라/ML Kit): AI 재고 스캔 → 사진 촬영 → 분석 다이얼로그 → 미리보기 (기존 재료 매칭 행 + 새 재료 배지 행) → 체크 해제 1건 → 반영 → 재고 탭 잔량 갱신 확인. 같은 사진 반복 반영 시 잔량이 덮어써지는지(누적 아님) 확인.

- [ ] **Step 6: Commit**

```bash
git add lib/screen/pages/inventory/ lib/controller/inventory/ test/controller/
git commit -m "feat: AI 재고 스캔 — OCR→Gemini 추측→미리보기→일괄 반영"
```

---

### Task 10: 재료 폼 보관위치 필드 + 최종 검증 + 문서

**Files:**
- Modify: `lib/screen/pages/ingredient/ingredient_add_page.dart` (보관 위치 선택 칩 — 실제 파일명은 `ls lib/screen/pages/ingredient/` 로 확인 후 add/edit 페이지에 적용)
- Modify: `CLAUDE.md` (Active Workstreams 표에 재고조사 행 추가)

**Interfaces:**
- Consumes: `Ingredient.storageLocation`, `Ingredient.copyWith(storageLocation:)`, Task 5 문자열

- [ ] **Step 1: 재료 추가/수정 페이지에 보관 위치 필드**

재료 add/edit 페이지의 폼 (유통기한 필드 근처) 에 선택형 칩 3개를 추가한다. 페이지의 기존 상태 관리 방식(StatefulWidget state 변수)에 맞춰:

```dart
// state 변수
StorageLocation? _storageLocation;

// (edit 페이지) initState 에서 기존 값 로드
_storageLocation = widget.ingredient.storageLocation;

// 폼 위젯 (기존 필드들과 같은 섹션 스타일로)
Widget _buildStorageLocationField(AppLocale locale) {
  final tokens = AppColorTokens.of(context);
  Widget chip(String label, StorageLocation value) {
    final selected = _storageLocation == value;
    return GestureDetector(
      onTap: () => setState(
          () => _storageLocation = selected ? null : value),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12, vertical: AppSpacing.s6),
        decoration: BoxDecoration(
          color: selected ? tokens.primary : tokens.bgMuted,
          borderRadius: AppRadius.brPill,
        ),
        child: Text(label,
            style: AppTypography.label2.copyWith(
                color: selected ? Colors.white : tokens.fgSecondary)),
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(AppStrings.getInventoryStorageLocation(locale),
          style: AppTypography.label1.copyWith(color: tokens.fgSecondary)),
      const SizedBox(height: AppSpacing.s6),
      Row(children: [
        chip(AppStrings.getInventoryShelf(locale), StorageLocation.shelf),
        const SizedBox(width: AppSpacing.s6),
        chip(AppStrings.getInventoryFridge(locale), StorageLocation.fridge),
        const SizedBox(width: AppSpacing.s6),
        chip(AppStrings.getInventoryFreezer(locale), StorageLocation.freezer),
      ]),
    ],
  );
}
```

저장 시 `Ingredient(...)` 생성 / `copyWith(...)` 호출에 `storageLocation: _storageLocation` 를 전달한다. add 페이지가 `IngredientCubit.addIngredient` 를 쓰면 해당 메서드 시그니처에도 optional 파라미터를 추가한다 (기본 null — 기존 호출부 영향 없음).

- [ ] **Step 2: 전체 검증**

```bash
flutter analyze          # 신규 에러 0 (기존 withOpacity info 제외)
flutter test             # 전체 PASS
```

수동 검증 체크리스트 (시뮬레이터 + 가능하면 실기기):
1. **v8→v9 업그레이드**: 이전 버전 설치본 위에 새 빌드 설치 → 기존 재료/레시피 데이터 보존 + 재고 탭 정상 동작
2. 미분류 → 위치 칩 분류 → 해당 세그먼트에 표시
3. 스테퍼: kg 단위 재료 ±0.5, 개 단위 ±1, g 단위 ±100 스텝 확인
4. 직접 입력, 0 미만 clamp, 실행취소
5. 구매 기록 2탭 흐름 → 잔량 증가 + 오늘 구매 총액
6. AI 스캔 전체 흐름 (Task 9 수동 확인 재실행)
7. 재료 추가 시 보관 위치 지정 → 재고 탭 바로 표시
8. 로케일 변경 (설정) → 재고 탭 문자열 6로케일 표시 확인 (최소 en/ko)

- [ ] **Step 3: CLAUDE.md 갱신**

Active Workstreams 표에 행 추가:

```markdown
| 재고조사 탭 (위치별 재고/구매 기록/AI 스캔) | **구현 완료 — 검증 중** | `docs/superpowers/specs/2026-07-27-inventory-design.md` |
```

- [ ] **Step 4: Commit**

```bash
git add lib/screen/pages/ingredient/ lib/controller/ CLAUDE.md
git commit -m "feat: 재료 폼 보관위치 필드 + 재고조사 워크스트림 문서"
```

---

## Self-Review 결과

- **Spec coverage**: 탭 순서(Task 6) ✓ / 하이브리드 모델(Task 1·3) ✓ / 단위 스텝(Task 4) ✓ / 미분류 연동(Task 6) ✓ / 구매 프리필(Task 7) ✓ / OCR 재사용 AI 스캔·새 재료 배지(Task 8·9) ✓ / 재료 폼 위치 필드(Task 10) ✓ / lazy 생성·clamp(Task 3) ✓ / i18n·토큰(Task 5·전역) ✓
- **주의 필요 지점** (구현자가 확인할 기존 코드 시그니처): `NumberFormatter.formatCurrency`, `AppStrings.getSave/getCancel/getConfirm/getUndo` 존재 여부, `OcrService.recognizeTextAuto` 시그니처, `Unit` 모델 필드명(`name`), 재료 add/edit 페이지 파일명. 각 Task 본문에 대응 지침 명시됨.
- **Type consistency**: `InventoryAiApplyItem`(Task 9 Cubit ↔ Preview) / `InventoryAiRow`(Task 8 ↔ 9) / repository 시그니처(Task 3 ↔ 4) 일치 확인.
