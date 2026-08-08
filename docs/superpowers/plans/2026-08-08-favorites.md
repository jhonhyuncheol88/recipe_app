# 즐겨찾기(Favorites) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 재료·레시피·소스를 목록 항목의 별 아이콘 탭으로 즐겨찾기하고, 앱바 별 아이콘으로 진입하는 별도 즐겨찾기 화면(세그먼트 3탭)에서 모아본다.

**Architecture:** 각 테이블에 `is_favorite` 컬럼(DB v10)을 두고, 모델에 `isFavorite` 필드를 추가한다. Repository `setFavorite`(단일 컬럼 UPDATE) → Cubit `toggleFavorite`(기존 "재조회 후 Loaded emit" 패턴) → 목록 위젯의 별 아이콘. 즐겨찾기 화면은 기존 Cubit 상태를 `isFavorite`로 필터링해 기존 카드/타일을 재사용한다.

**Tech Stack:** Flutter, flutter_bloc(Cubit), sqflite, go_router, Equatable, Wanted DS 토큰.

## Global Constraints

- 새 코드는 디자인 토큰(`AppColorTokens.of(context)`, `AppTypography`, `AppSpacing`, `AppRadius`)만 사용. 레거시 `colorScheme.*`/`AppTextStyles` 금지.
- 신규 문구는 6개 로케일 전부: `AppLocale.korea/japan/china/usa/chinaTraditional/vietnam`.
- `flutter analyze` 신규 에러 0.
- DB 테스트는 `sqflite_common_ffi` 하네스 사용: `sqfliteFfiInit(); databaseFactory = databaseFactoryFfi;` + 고유 임시 경로.
- 모델 직렬화는 `toJson`/`fromJson`, DB 컬럼명은 snake_case(`is_favorite`).

---

### Task 1: DB 스키마 v10 — is_favorite 컬럼

**Files:**
- Modify: `lib/data/database_helper.dart` (`schemaVersion`, `_onCreate`, `_onUpgrade`)
- Test: `test/data/favorites_schema_test.dart`

**Interfaces:**
- Produces: `ingredients`/`recipes`/`sauces` 테이블에 `is_favorite INTEGER NOT NULL DEFAULT 0` 컬럼.

- [ ] **Step 1: Write the failing test**

```dart
// test/data/favorites_schema_test.dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/favorites_schema_test.dart`
Expected: FAIL — `ingredients.is_favorite 없음`.

- [ ] **Step 3: Bump schemaVersion**

`lib/data/database_helper.dart:13` 을 다음으로 변경:

```dart
  static const int schemaVersion = 10;
```

- [ ] **Step 4: Add column to _onCreate**

`_onCreate` 의 세 `CREATE TABLE` 문 각각에 컬럼을 추가한다. `ingredients` 테이블 정의(약 line 81~)의 마지막 컬럼 뒤에:

```dart
        is_favorite INTEGER NOT NULL DEFAULT 0,
```

`recipes`(약 line 100~), `sauces`(약 line 134~) 테이블 정의에도 동일하게 `is_favorite INTEGER NOT NULL DEFAULT 0` 컬럼을 추가한다. (각 CREATE TABLE 의 마지막 컬럼이 되도록, 직전 컬럼 끝의 콤마 처리에 주의)

- [ ] **Step 5: Add _onUpgrade block**

`_onUpgrade` 의 마지막 `if (oldVersion < 9)` 블록 뒤에 추가:

```dart
      if (oldVersion < 10) {
        await db.execute(
          'ALTER TABLE ingredients ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE recipes ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute(
          'ALTER TABLE sauces ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0',
        );
      }
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/data/favorites_schema_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/data/database_helper.dart test/data/favorites_schema_test.dart
git commit -m "feat(favorites): DB v10 — ingredients/recipes/sauces is_favorite 컬럼"
```

---

### Task 2: 모델 isFavorite 필드

**Files:**
- Modify: `lib/model/ingredient.dart`, `lib/model/recipe.dart`, `lib/model/sauce.dart`
- Test: `test/model/favorite_serialization_test.dart`

**Interfaces:**
- Produces: `Ingredient`/`Recipe`/`Sauce` 에 `final bool isFavorite` (기본 `false`), `copyWith({bool? isFavorite})`, `toJson`/`fromJson` 의 `is_favorite`(1/0) 매핑.

- [ ] **Step 1: Write the failing test**

```dart
// test/model/favorite_serialization_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/model/ingredient.dart';
import 'package:recipe_app/model/sauce.dart';

Ingredient _ing({bool fav = false}) => Ingredient(
      id: 'a', name: '양파', purchasePrice: 1000, purchaseAmount: 1,
      purchaseUnitId: 'u1', createdAt: DateTime(2026, 1, 1), isFavorite: fav,
    );

void main() {
  test('Ingredient toJson/fromJson 라운드트립에 isFavorite 유지', () {
    final json = _ing(fav: true).toJson();
    expect(json['is_favorite'], 1);
    expect(Ingredient.fromJson(json).isFavorite, isTrue);
  });

  test('Ingredient 레거시 행(is_favorite 없음) → false', () {
    final json = _ing().toJson()..remove('is_favorite');
    expect(Ingredient.fromJson(json).isFavorite, isFalse);
  });

  test('Ingredient.copyWith(isFavorite) 토글', () {
    expect(_ing().copyWith(isFavorite: true).isFavorite, isTrue);
  });

  test('Sauce toJson/fromJson 라운드트립에 isFavorite 유지', () {
    final s = Sauce(
      id: 's', name: '소스', totalWeight: 10, totalCost: 5,
      createdAt: DateTime(2026, 1, 1), isFavorite: true,
    );
    final json = s.toJson();
    expect(json['is_favorite'], 1);
    expect(Sauce.fromJson(json).isFavorite, isTrue);
    expect(Sauce.fromJson(json..remove('is_favorite')).isFavorite, isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/model/favorite_serialization_test.dart`
Expected: FAIL — `isFavorite` 명명 인자 없음 (컴파일 에러).

- [ ] **Step 3: Ingredient 모델 수정**

`lib/model/ingredient.dart`:
- 필드 추가(`storageLocation` 아래, line 21 뒤): `final bool isFavorite;`
- 생성자에 추가(`this.storageLocation,` 아래): `this.isFavorite = false,`
- `toJson()` 맵에 추가: `'is_favorite': isFavorite ? 1 : 0,`
- `fromJson()` 의 `Ingredient(...)` 생성 인자에 추가: `isFavorite: (json['is_favorite'] ?? 0) == 1,`
- `copyWith` 파라미터에 추가: `bool? isFavorite,` / 본문에 `isFavorite: isFavorite ?? this.isFavorite,`
- `props` 리스트에 `isFavorite` 추가.

- [ ] **Step 4: Recipe 모델 수정**

`lib/model/recipe.dart`:
- 필드 추가(`tagIds` 아래): `final bool isFavorite;`
- 생성자에 추가(`this.tagIds = const [],` 아래): `this.isFavorite = false,`
- `toJson()` 맵에 추가: `'is_favorite': isFavorite ? 1 : 0,`
- `fromJson()` 의 `Recipe(...)` 생성 인자에 추가: `isFavorite: (json['is_favorite'] ?? 0) == 1,`
- `copyWith` 파라미터에 `bool? isFavorite,` / 본문에 `isFavorite: isFavorite ?? this.isFavorite,`
- `props` 리스트에 `isFavorite` 추가.

- [ ] **Step 5: Sauce 모델 수정**

`lib/model/sauce.dart`:
- 필드 추가(`createdAt` 아래): `final bool isFavorite;`
- 생성자에 추가(`required this.createdAt,` 아래): `this.isFavorite = false,`
- `toJson()` 맵에 추가: `'is_favorite': isFavorite ? 1 : 0,`
- `fromJson()` 의 `Sauce(...)` 생성 인자에 추가: `isFavorite: (json['is_favorite'] ?? 0) == 1,`
- `copyWith` 파라미터에 `bool? isFavorite,` / 본문에 `isFavorite: isFavorite ?? this.isFavorite,`
- `props` 리스트에 `isFavorite` 추가.

- [ ] **Step 6: Run test + analyze**

Run: `flutter test test/model/favorite_serialization_test.dart && flutter analyze lib/model`
Expected: PASS, analyze 신규 에러 0.

- [ ] **Step 7: Commit**

```bash
git add lib/model/ingredient.dart lib/model/recipe.dart lib/model/sauce.dart test/model/favorite_serialization_test.dart
git commit -m "feat(favorites): 모델에 isFavorite 필드 + 직렬화"
```

---

### Task 3: Repository setFavorite

**Files:**
- Modify: `lib/data/ingredient_repository.dart`, `lib/data/recipe_repository.dart`, `lib/data/sauce_repository.dart`
- Test: `test/data/favorite_repository_test.dart`

**Interfaces:**
- Consumes: 모델 `isFavorite`(Task 2), DB 컬럼(Task 1).
- Produces: 세 Repository 각각 `Future<void> setFavorite(String id, bool value)`.

- [ ] **Step 1: Write the failing test**

```dart
// test/data/favorite_repository_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:recipe_app/data/database_helper.dart';
import 'package:recipe_app/data/ingredient_repository.dart';
import 'package:recipe_app/data/sauce_repository.dart';
import 'package:recipe_app/model/ingredient.dart';
import 'package:recipe_app/model/sauce.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await databaseFactory.setDatabasesPath(
      Directory.systemTemp.createTempSync('fav_repo_').path,
    );
  });

  setUp(() async {
    final db = await DatabaseHelper().database;
    await db.delete('ingredients');
    await db.delete('sauces');
  });

  test('IngredientRepository.setFavorite 가 단일 컬럼만 갱신하고 유지된다', () async {
    final repo = IngredientRepository();
    final db = await DatabaseHelper().database;
    await db.insert('ingredients', Ingredient(
      id: 'a', name: '양파', purchasePrice: 1000, purchaseAmount: 1,
      purchaseUnitId: 'u1', createdAt: DateTime(2026, 1, 1),
    ).toJson());

    await repo.setFavorite('a', true);
    expect((await repo.getIngredientById('a'))!.isFavorite, isTrue);

    await repo.setFavorite('a', false);
    expect((await repo.getIngredientById('a'))!.isFavorite, isFalse);
  });

  test('SauceRepository.setFavorite 가 값을 유지한다', () async {
    final repo = SauceRepository();
    final db = await DatabaseHelper().database;
    await db.insert('sauces', Sauce(
      id: 's', name: '소스', totalWeight: 10, totalCost: 5,
      createdAt: DateTime(2026, 1, 1),
    ).toJson());

    await repo.setFavorite('s', true);
    final sauces = await repo.getAllSauces();
    expect(sauces.firstWhere((e) => e.id == 's').isFavorite, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/data/favorite_repository_test.dart`
Expected: FAIL — `setFavorite` 메서드 없음.

- [ ] **Step 3: IngredientRepository.setFavorite 추가**

`lib/data/ingredient_repository.dart` 의 `updateIngredient` 뒤에 추가:

```dart
  Future<void> setFavorite(String id, bool value) async {
    final db = await _databaseHelper.database;
    await db.update(
      'ingredients',
      {'is_favorite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
```

- [ ] **Step 4: SauceRepository.setFavorite 추가**

`lib/data/sauce_repository.dart` 의 `updateSauce` 뒤에 추가:

```dart
  Future<void> setFavorite(String id, bool value) async {
    final db = await _databaseHelper.database;
    await db.update(
      'sauces',
      {'is_favorite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
```

- [ ] **Step 5: RecipeRepository.setFavorite 추가**

`lib/data/recipe_repository.dart` 의 `updateRecipe` 뒤에 추가:

```dart
  Future<void> setFavorite(String id, bool value) async {
    final db = await _databaseHelper.database;
    await db.update(
      'recipes',
      {'is_favorite': value ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/data/favorite_repository_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add lib/data/ingredient_repository.dart lib/data/sauce_repository.dart lib/data/recipe_repository.dart test/data/favorite_repository_test.dart
git commit -m "feat(favorites): Repository setFavorite (단일 컬럼 UPDATE)"
```

---

### Task 4: Cubit toggleFavorite

**Files:**
- Modify: `lib/controller/ingredient/ingredient_cubit.dart`, `lib/controller/recipe/recipe_cubit.dart`, `lib/controller/sauce/sauce_cubit.dart`
- Test: `test/controller/favorite_toggle_test.dart`

**Interfaces:**
- Consumes: `setFavorite`(Task 3), `getAllIngredients`/`getAllRecipes`/`getAllSauces`.
- Produces:
  - `IngredientCubit.toggleFavorite(Ingredient)` → `IngredientLoaded`
  - `RecipeCubit.toggleFavorite(Recipe)` → `RecipeLoaded(recipes, stats)`
  - `SauceCubit.toggleFavorite(Sauce)` → `SauceLoaded(sauces)`

- [ ] **Step 1: Write the failing test**

```dart
// test/controller/favorite_toggle_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/controller/sauce/sauce_cubit.dart';
import 'package:recipe_app/controller/sauce/sauce_state.dart';
import 'package:recipe_app/data/sauce_repository.dart';
import 'package:recipe_app/model/sauce.dart';

class _FakeSauceRepo extends SauceRepository {
  final Map<String, bool> favs = {};
  List<Sauce> items;
  _FakeSauceRepo(this.items);

  @override
  Future<void> setFavorite(String id, bool value) async => favs[id] = value;

  @override
  Future<List<Sauce>> getAllSauces() async => [
        for (final s in items)
          s.copyWith(isFavorite: favs[s.id] ?? s.isFavorite),
      ];
}

Sauce _sauce(String id) => Sauce(
      id: id, name: id, totalWeight: 10, totalCost: 5,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  test('SauceCubit.toggleFavorite 가 저장하고 Loaded 로 반영한다', () async {
    final repo = _FakeSauceRepo([_sauce('a')]);
    final cubit = SauceCubit(sauceRepository: repo);

    await cubit.toggleFavorite(_sauce('a'));

    expect(repo.favs['a'], isTrue);
    final state = cubit.state as SauceLoaded;
    expect(state.sauces.firstWhere((e) => e.id == 'a').isFavorite, isTrue);
    await cubit.close();
  });
}
```

(레시피/재료 Cubit 은 아래 구현이 동일 패턴을 따르므로 소스 테스트로 대표 검증한다. 세 메서드 모두 `flutter analyze` 로 컴파일 확인.)

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/controller/favorite_toggle_test.dart`
Expected: FAIL — `toggleFavorite` 없음.

- [ ] **Step 3: SauceCubit.toggleFavorite 추가**

`lib/controller/sauce/sauce_cubit.dart` 의 `updateSauce` 뒤에 추가:

```dart
  Future<void> toggleFavorite(Sauce sauce) async {
    try {
      await _sauceRepository.setFavorite(sauce.id, !sauce.isFavorite);
      final sauces = await _sauceRepository.getAllSauces();
      emit(SauceLoaded(sauces: sauces));
    } catch (e) {
      emit(SauceError('즐겨찾기 변경에 실패했습니다: $e'));
    }
  }
```

(`SauceError` 가 없으면 기존 에러 상태 클래스명에 맞춘다 — `sauce_state.dart` 확인.)

- [ ] **Step 4: IngredientCubit.toggleFavorite 추가**

`lib/controller/ingredient/ingredient_cubit.dart` 의 `updateIngredient` 뒤에 추가:

```dart
  Future<void> toggleFavorite(Ingredient ingredient) async {
    try {
      await _ingredientRepository.setFavorite(
        ingredient.id,
        !ingredient.isFavorite,
      );
      final ingredients = await _ingredientRepository.getAllIngredients();
      emit(IngredientLoaded(ingredients: ingredients));
    } catch (e) {
      emit(IngredientError('즐겨찾기 변경에 실패했습니다: $e'));
    }
  }
```

- [ ] **Step 5: RecipeCubit.toggleFavorite 추가**

`lib/controller/recipe/recipe_cubit.dart` 의 `updateRecipe` 뒤에 추가:

```dart
  Future<void> toggleFavorite(Recipe recipe) async {
    try {
      await _recipeRepository.setFavorite(recipe.id, !recipe.isFavorite);
      final recipes = await _recipeRepository.getAllRecipes();
      final stats = await _recipeRepository.getRecipeStats();
      emit(RecipeLoaded(recipes: recipes, stats: stats));
    } catch (e) {
      emit(RecipeError('즐겨찾기 변경에 실패했습니다: $e'));
    }
  }
```

(`getRecipeStats`/`RecipeLoaded` 시그니처는 `loadRecipes` 의 emit(약 line 71)과 동일하게 맞춘다.)

- [ ] **Step 6: Run test + analyze**

Run: `flutter test test/controller/favorite_toggle_test.dart && flutter analyze lib/controller`
Expected: PASS, analyze 신규 에러 0.

- [ ] **Step 7: Commit**

```bash
git add lib/controller test/controller/favorite_toggle_test.dart
git commit -m "feat(favorites): Cubit toggleFavorite (재조회 후 Loaded emit)"
```

---

### Task 5: i18n 문구

**Files:**
- Modify: `lib/util/app_strings/app_strings_common.dart`, `lib/util/app_strings.dart`

**Interfaces:**
- Produces: `AppStrings.getFavorites`, `AppStrings.getNoFavoriteIngredients`, `AppStrings.getNoFavoriteRecipes`, `AppStrings.getNoFavoriteSauces`.

- [ ] **Step 1: app_strings_common.dart 에 4개 메서드 추가**

`getSortNameAsc` 등 정렬 문구 뒤 아무 곳에 추가:

```dart
  static String getFavorites(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '즐겨찾기';
      case AppLocale.japan:
        return 'お気に入り';
      case AppLocale.china:
        return '收藏';
      case AppLocale.usa:
        return 'Favorites';
      case AppLocale.chinaTraditional:
        return 'Favorites';
      case AppLocale.vietnam:
        return 'Yêu thích';
    }
  }

  static String getNoFavoriteIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '즐겨찾기한 재료가 없어요';
      case AppLocale.japan:
        return 'お気に入りの材料がありません';
      case AppLocale.china:
        return '没有收藏的材料';
      case AppLocale.usa:
        return 'No favorite ingredients';
      case AppLocale.chinaTraditional:
        return 'No favorite ingredients';
      case AppLocale.vietnam:
        return 'Chưa có nguyên liệu yêu thích';
    }
  }

  static String getNoFavoriteRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '즐겨찾기한 레시피가 없어요';
      case AppLocale.japan:
        return 'お気に入りのレシピがありません';
      case AppLocale.china:
        return '没有收藏的食谱';
      case AppLocale.usa:
        return 'No favorite recipes';
      case AppLocale.chinaTraditional:
        return 'No favorite recipes';
      case AppLocale.vietnam:
        return 'Chưa có công thức yêu thích';
    }
  }

  static String getNoFavoriteSauces(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '즐겨찾기한 소스가 없어요';
      case AppLocale.japan:
        return 'お気に入りのソースがありません';
      case AppLocale.china:
        return '没有收藏的酱料';
      case AppLocale.usa:
        return 'No favorite sauces';
      case AppLocale.chinaTraditional:
        return 'No favorite sauces';
      case AppLocale.vietnam:
        return 'Chưa có nước sốt yêu thích';
    }
  }
```

- [ ] **Step 2: app_strings.dart facade 에 위임 추가**

정렬 facade 근처에 추가:

```dart
  static String getFavorites(AppLocale locale) =>
      AppStringsCommon.getFavorites(locale);
  static String getNoFavoriteIngredients(AppLocale locale) =>
      AppStringsCommon.getNoFavoriteIngredients(locale);
  static String getNoFavoriteRecipes(AppLocale locale) =>
      AppStringsCommon.getNoFavoriteRecipes(locale);
  static String getNoFavoriteSauces(AppLocale locale) =>
      AppStringsCommon.getNoFavoriteSauces(locale);
```

- [ ] **Step 3: analyze 로 검증**

Run: `flutter analyze lib/util/app_strings.dart lib/util/app_strings/app_strings_common.dart`
Expected: 신규 에러 0 (switch 모든 로케일 처리 → exhaustive).

- [ ] **Step 4: Commit**

```bash
git add lib/util/app_strings.dart lib/util/app_strings/app_strings_common.dart
git commit -m "feat(favorites): 즐겨찾기 i18n 문구 4종 (6 로케일)"
```

---

### Task 6: 재료 타일 별 아이콘 + 재료 페이지 토글 배선

**Files:**
- Modify: `lib/screen/widget/ingredient_list_tile.dart`
- Modify: `lib/screen/pages/ingredient/ingredient_main_page.dart`

**Interfaces:**
- Consumes: `Ingredient.isFavorite`, `IngredientCubit.toggleFavorite`.
- Produces: `IngredientListTile` 에 `VoidCallback? onToggleFavorite` 파라미터 + 별 아이콘.

- [ ] **Step 1: IngredientListTile 에 콜백 + 별 아이콘 추가**

`ingredient_list_tile.dart`:
- 필드 추가(`onTap` 아래): `final VoidCallback? onToggleFavorite;`
- 생성자에 추가: `this.onToggleFavorite,`
- `build` 의 최상위 `Row`(line 90~) 의 마지막(가격 Column 뒤)에 별 아이콘을 추가한다. 가격 `Column` 다음에:

```dart
              if (onToggleFavorite != null) ...[
                const SizedBox(width: AppSpacing.s4),
                _FavoriteStar(
                  isFavorite: ingredient.isFavorite,
                  onTap: onToggleFavorite!,
                ),
              ],
```

- 파일 하단에 공용 별 위젯 추가:

```dart
class _FavoriteStar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteStar({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? tokens.primary : tokens.fgTertiary,
          size: 22,
        ),
      ),
    );
  }
}
```

(별 영역은 자체 `InkResponse.onTap` 으로 토글만 처리 → 행의 `InkWell.onTap`(상세 진입)과 겹치지 않는다. 탭 이벤트는 가장 안쪽 제스처가 처리하므로 별 탭 시 행 탭은 발생하지 않는다.)

- [ ] **Step 2: 재료 페이지에서 콜백 전달**

`ingredient_main_page.dart` 의 `_Body` 는 `IngredientListTile` 을 생성한다(약 line 705). `onTapIngredient` 처럼 `onToggleFavorite` 콜백을 `_Body` 로 내려보내야 한다:
- `_Body` 에 `final ValueChanged<Ingredient> onToggleFavorite;` 필드 + 생성자 파라미터 추가.
- `IngredientListTile(...)` 에 추가: `onToggleFavorite: () => onToggleFavorite(ingredient),`
- `build` 의 `_Body(...)` 생성부(약 line 217)에 추가:
  `onToggleFavorite: (ing) => context.read<IngredientCubit>().toggleFavorite(ing),`

- [ ] **Step 3: analyze**

Run: `flutter analyze lib/screen/widget/ingredient_list_tile.dart lib/screen/pages/ingredient/ingredient_main_page.dart`
Expected: 신규 에러 0.

- [ ] **Step 4: 수동 스모크 확인**

`flutter run` 후 재료 탭 → 타일 별 아이콘 탭 → 즉시 채워짐/비워짐 전환, 행 탭 시엔 상세로 이동(별과 분리) 확인.

- [ ] **Step 5: Commit**

```bash
git add lib/screen/widget/ingredient_list_tile.dart lib/screen/pages/ingredient/ingredient_main_page.dart
git commit -m "feat(favorites): 재료 타일 별 아이콘 토글"
```

---

### Task 7: 레시피/소스 카드 공용화 + 별 아이콘 + 배선

**Files:**
- Create: `lib/screen/widget/recipe_summary_card.dart`
- Create: `lib/screen/widget/sauce_summary_card.dart`
- Modify: `lib/screen/pages/recipe/recipe_main_page.dart`

**Interfaces:**
- Consumes: `Recipe`/`Sauce` `isFavorite`, `RecipeCubit.toggleFavorite`, `SauceCubit.toggleFavorite`.
- Produces:
  - `RecipeSummaryCard({required Recipe recipe, required AppLocale locale, required NumberFormatStyle formatStyle, required VoidCallback onTap, VoidCallback? onToggleFavorite})`
  - `SauceSummaryCard({required Sauce sauce, required AppLocale locale, required NumberFormatStyle formatStyle, required VoidCallback onTap, VoidCallback? onToggleFavorite})`

- [ ] **Step 1: `_RecipeCard` → `RecipeSummaryCard` 로 추출**

`recipe_main_page.dart` 의 `_RecipeCard` 클래스 전체를 새 파일 `lib/screen/widget/recipe_summary_card.dart` 로 옮기고 `public` 이름 `RecipeSummaryCard` 로 바꾼다. 필요한 import(`material`, `model/recipe.dart`, `theme/tokens/tokens.dart`, `util/app_locale.dart`, `util/app_strings.dart`, `util/number_format_style.dart`, `util/number_formatter.dart`, `util/recipe_margin.dart`) 를 옮기고, `_CostSellPair` 도 같은 파일로 이동한다. 클래스에 다음을 추가:
- 필드/생성자: `final VoidCallback? onToggleFavorite;`
- 마진 `Column`(우측) 위 또는 이름 Row 우측에 별을 배치. 이름 `Text`(line ~390) 를 감싼 부분을 다음처럼 이름 + 별 Row 로 변경:

```dart
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: AppTypography.headline2.copyWith(
                              color: tokens.fgStrong,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onToggleFavorite != null)
                          FavoriteStar(
                            isFavorite: recipe.isFavorite,
                            onTap: onToggleFavorite!,
                          ),
                      ],
                    ),
```

- [ ] **Step 2: 공용 `FavoriteStar` 위젯 분리**

Task 6 에서 `ingredient_list_tile.dart` 에 넣은 `_FavoriteStar` 를 `lib/screen/widget/favorite_star.dart` 의 public `FavoriteStar` 로 옮기고, `ingredient_list_tile.dart` 는 이를 import 해 사용하도록 변경한다(중복 제거):

```dart
// lib/screen/widget/favorite_star.dart
import 'package:flutter/material.dart';
import '../../theme/tokens/tokens.dart';

class FavoriteStar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteStar({super.key, required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite ? tokens.primary : tokens.fgTertiary,
          size: 22,
        ),
      ),
    );
  }
}
```

`ingredient_list_tile.dart` 에서 `_FavoriteStar` 정의를 삭제하고 `import '../widget/favorite_star.dart';` 후 `_FavoriteStar` → `FavoriteStar` 로 교체.

- [ ] **Step 3: `_SauceCard` → `SauceSummaryCard` 로 추출**

`recipe_main_page.dart` 의 `_SauceCard` 를 `lib/screen/widget/sauce_summary_card.dart` 의 public `SauceSummaryCard` 로 옮긴다. 이름 `Text`(line ~584) 를 이름 + 별 Row 로 변경:

```dart
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sauce.name,
                            style: AppTypography.headline2.copyWith(
                              color: tokens.fgStrong,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onToggleFavorite != null)
                          FavoriteStar(
                            isFavorite: sauce.isFavorite,
                            onTap: onToggleFavorite!,
                          ),
                      ],
                    ),
```

`import '../../screen/widget/favorite_star.dart';`(상대경로에 맞게) 추가.

- [ ] **Step 4: recipe_main_page.dart 에서 새 카드 사용 + 토글 배선**

`recipe_main_page.dart`:
- `_RecipeCard`/`_SauceCard`/`_CostSellPair` 정의 삭제(추출됨), `import '../../widget/recipe_summary_card.dart';` `import '../../widget/sauce_summary_card.dart';` 추가.
- `_RecipeList` 의 `itemBuilder` 에서 `_RecipeCard(...)` → `RecipeSummaryCard(...)` 로 교체하고 `onToggleFavorite: () => context.read<RecipeCubit>().toggleFavorite(r),` 추가. (`_RecipeList` 는 `StatelessWidget` 이므로 `itemBuilder` 의 `context` 로 `read` 가능.)
- `_SauceList` 의 `itemBuilder` 에서 `_SauceCard(...)` → `SauceSummaryCard(...)` 로 교체하고 `onToggleFavorite: () => context.read<SauceCubit>().toggleFavorite(s),` 추가.

- [ ] **Step 5: analyze**

Run: `flutter analyze lib/screen/widget/recipe_summary_card.dart lib/screen/widget/sauce_summary_card.dart lib/screen/widget/favorite_star.dart lib/screen/widget/ingredient_list_tile.dart lib/screen/pages/recipe/recipe_main_page.dart`
Expected: 신규 에러 0.

- [ ] **Step 6: 수동 스모크 확인**

레시피/소스 탭에서 카드 별 탭 → 토글, 카드 본문 탭 → 상세/편집 이동 확인.

- [ ] **Step 7: Commit**

```bash
git add lib/screen/widget/recipe_summary_card.dart lib/screen/widget/sauce_summary_card.dart lib/screen/widget/favorite_star.dart lib/screen/widget/ingredient_list_tile.dart lib/screen/pages/recipe/recipe_main_page.dart
git commit -m "feat(favorites): 레시피/소스 카드 공용화 + 별 아이콘 토글"
```

---

### Task 8: 즐겨찾기 화면 + 라우트 + 앱바 진입

**Files:**
- Create: `lib/screen/pages/favorites/favorites_page.dart`
- Modify: `lib/router/app_router.dart`
- Modify: `lib/screen/pages/ingredient/ingredient_main_page.dart` (앱바 진입 아이콘)
- Modify: `lib/screen/pages/recipe/recipe_main_page.dart` (앱바 진입 아이콘)

**Interfaces:**
- Consumes: `IngredientCubit`/`RecipeCubit`/`SauceCubit` 전역 인스턴스, `IngredientListTile`, `RecipeSummaryCard`, `SauceSummaryCard`, `SegmentControl`, `AppStrings.getFavorites`/`getNoFavorite*`.
- Produces: `AppRouter.favorites = '/favorites'`, `FavoritesPage`.

- [ ] **Step 1: 라우트 상수 + GoRoute 등록**

`lib/router/app_router.dart`:
- 상수 추가(`premium` 근처): `static const String favorites = '/favorites';`
- `import '../screen/pages/favorites/favorites_page.dart';` 추가.
- 라우트 등록(다른 단순 `GoRoute` 옆): `GoRoute(path: favorites, builder: (context, state) => const FavoritesPage()),`

- [ ] **Step 2: FavoritesPage 작성**

```dart
// lib/screen/pages/favorites/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/recipe/recipe_state.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../model/recipe.dart';
import '../../../model/sauce.dart';
import '../../../router/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../widget/ingredient_list_tile.dart';
import '../../widget/recipe_summary_card.dart';
import '../../widget/sauce_summary_card.dart';
import '../../widget/segment_control.dart';

enum _FavTab { ingredient, recipe, sauce }

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  _FavTab _tab = _FavTab.ingredient;

  @override
  void initState() {
    super.initState();
    context.read<IngredientCubit>().loadIngredients();
    context.read<RecipeCubit>().loadRecipes();
    context.read<SauceCubit>().loadSauces();
  }

  List<Ingredient> _ingredientsOf(IngredientState s) =>
      s is IngredientLoaded ? s.ingredients : const [];
  List<Recipe> _recipesOf(RecipeState s) =>
      s is RecipeLoaded ? s.recipes : const [];
  List<Sauce> _saucesOf(SauceState s) =>
      s is SauceLoaded ? s.sauces : const [];

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;

    return Scaffold(
      backgroundColor: tokens.bgElev2,
      appBar: AppBar(
        backgroundColor: tokens.bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.getFavorites(locale),
          style: AppTypography.heading1.copyWith(color: tokens.fgStrong),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: tokens.bgBase,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s12),
            child: SegmentControl<_FavTab>(
              items: [
                SegmentItem(
                  value: _FavTab.ingredient,
                  label: AppStrings.getIngredients(locale),
                ),
                SegmentItem(
                  value: _FavTab.recipe,
                  label: AppStrings.getRecipes(locale),
                ),
                SegmentItem(
                  value: _FavTab.sauce,
                  label: AppStrings.getSauces(locale),
                ),
              ],
              selected: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              _FavTab.ingredient => BlocBuilder<IngredientCubit, IngredientState>(
                  builder: (context, state) {
                    final favs = _ingredientsOf(state)
                        .where((e) => e.isFavorite)
                        .toList();
                    if (favs.isEmpty) {
                      return _Empty(
                        message: AppStrings.getNoFavoriteIngredients(locale));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s32),
                      itemCount: favs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.s8),
                      itemBuilder: (context, i) => IngredientListTile(
                        ingredient: favs[i],
                        locale: locale,
                        formatStyle: formatStyle,
                        onTap: () => context.push(
                          AppRouter.ingredientDetail, extra: favs[i]),
                        onToggleFavorite: () =>
                            context.read<IngredientCubit>().toggleFavorite(favs[i]),
                      ),
                    );
                  },
                ),
              _FavTab.recipe => BlocBuilder<RecipeCubit, RecipeState>(
                  builder: (context, state) {
                    final favs =
                        _recipesOf(state).where((e) => e.isFavorite).toList();
                    if (favs.isEmpty) {
                      return _Empty(
                        message: AppStrings.getNoFavoriteRecipes(locale));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s32),
                      itemCount: favs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.s8),
                      itemBuilder: (context, i) => RecipeSummaryCard(
                        recipe: favs[i],
                        locale: locale,
                        formatStyle: formatStyle,
                        onTap: () => context.push(
                          AppRouter.recipeDetail, extra: favs[i]),
                        onToggleFavorite: () =>
                            context.read<RecipeCubit>().toggleFavorite(favs[i]),
                      ),
                    );
                  },
                ),
              _FavTab.sauce => BlocBuilder<SauceCubit, SauceState>(
                  builder: (context, state) {
                    final favs =
                        _saucesOf(state).where((e) => e.isFavorite).toList();
                    if (favs.isEmpty) {
                      return _Empty(
                        message: AppStrings.getNoFavoriteSauces(locale));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s16, AppSpacing.s16, AppSpacing.s16, AppSpacing.s32),
                      itemCount: favs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.s8),
                      itemBuilder: (context, i) => SauceSummaryCard(
                        sauce: favs[i],
                        locale: locale,
                        formatStyle: formatStyle,
                        onTap: () => context.push(
                          AppRouter.sauceEdit, extra: favs[i]),
                        onToggleFavorite: () =>
                            context.read<SauceCubit>().toggleFavorite(favs[i]),
                      ),
                    );
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 56, color: tokens.fgDisabled),
            const SizedBox(height: AppSpacing.s12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
            ),
          ],
        ),
      ),
    );
  }
}
```

(`router/index.dart`, `RecipeLoaded.recipes`, `SauceLoaded.sauces`, `IngredientLoaded.ingredients`, `SegmentControl`/`SegmentItem` 시그니처는 기존 코드 기준. `switch` 표현식은 프로젝트 Dart 3 환경에서 동작.)

- [ ] **Step 3: 재료 메인 페이지 앱바에 진입 아이콘 추가**

`ingredient_main_page.dart` 의 `AppBar.actions` 리스트 맨 앞(OCR 아이콘 앞)에 추가:

```dart
          IconButton(
            onPressed: () => context.push(AppRouter.favorites),
            icon: Icon(Icons.star_border, color: tokens.fgStrong),
            tooltip: AppStrings.getFavorites(locale),
          ),
```

- [ ] **Step 4: 레시피 메인 페이지 앱바(스티키 헤더)에 진입 아이콘 추가**

`recipe_main_page.dart` 의 `_StickyHeader` 는 제목 Row 우측에 `_AddPillButton` 을 둔다. 제목 `Expanded` 와 `_AddPillButton` 사이에 별 아이콘 버튼을 추가하려면, `_StickyHeader` 에 `final VoidCallback onOpenFavorites;` 를 추가하고 제목 Row 의 `_AddPillButton` 앞에 삽입:

```dart
              IconButton(
                onPressed: onOpenFavorites,
                icon: Icon(Icons.star_border, color: tokens.fgStrong),
                tooltip: AppStrings.getFavorites(locale),
              ),
```

`build` 의 `_StickyHeader(...)` 생성부에 `onOpenFavorites: () => context.push(AppRouter.favorites),` 를 전달한다. (`RecipeMainPage.build` 에는 이미 go_router `context` 가 있으므로 `context.push` 사용 가능.)

- [ ] **Step 5: analyze**

Run: `flutter analyze lib/screen/pages/favorites/favorites_page.dart lib/router/app_router.dart lib/screen/pages/ingredient/ingredient_main_page.dart lib/screen/pages/recipe/recipe_main_page.dart`
Expected: 신규 에러 0.

- [ ] **Step 6: 수동 스모크 확인**

재료/레시피 페이지 앱바 별 아이콘 → 즐겨찾기 화면 진입 → 3탭 각각 즐겨찾기 항목만 노출 → 즐겨찾기 화면에서 별 해제 시 목록에서 사라짐 확인.

- [ ] **Step 7: 전체 테스트 + Commit**

```bash
flutter test
git add lib/screen/pages/favorites/favorites_page.dart lib/router/app_router.dart lib/screen/pages/ingredient/ingredient_main_page.dart lib/screen/pages/recipe/recipe_main_page.dart
git commit -m "feat(favorites): 즐겨찾기 화면 + 라우트 + 앱바 진입"
```

---

## 완료 기준

- 재료·레시피·소스 목록에서 별 아이콘 탭으로 즐겨찾기 토글(입력 0, 탭 1회).
- 앱바 별 아이콘 → 즐겨찾기 화면(세그먼트 3탭)에서 타입별 즐겨찾기만 표시.
- 앱 재시작 후에도 유지(DB 영속). 6개 로케일 문구. `flutter analyze` 신규 에러 0, `flutter test` 전체 통과.

## 리스크 / 메모

- **Recipe/Sauce `updateRecipe`/`updateSauce` 는 이미 `toJson` 으로 전체 저장** → 모델에 `is_favorite` 추가 후 이 경로로도 값이 보존된다(별도 회귀 없음).
- 세그먼트 탭 카드 재사용을 위해 Task 7 에서 `_RecipeCard`/`_SauceCard` 를 public 위젯으로 추출한다(단순 이동 + 별 추가). 추출 시 `recipe_main_page.dart` 의 기존 import/사용부만 갱신.
- `switch` 표현식(Task 8)이 프로젝트 Dart 버전에서 미지원이면 `if/else` 분기로 대체.
```
