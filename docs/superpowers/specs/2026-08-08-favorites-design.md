# 즐겨찾기(Favorites) 기능 설계

- 작성일: 2026-08-08
- 대상: 재료(Ingredient) · 레시피(Recipe) · 소스(Sauce)
- 핵심 원칙: **입력 최소화**(텍스트 입력 0, 모든 조작 탭 1회) · **버튼 최소화**(항목당 별 아이콘 1개 + 앱바 진입 아이콘 1개)

## 1. 개요

재료·레시피·소스를 즐겨찾기로 표시하고, 별도 화면에서 모아본다.
- 토글: 목록 항목(재료 타일 / 레시피·소스 카드)의 **별 아이콘 탭**.
- 모아보기: **별도 즐겨찾기 화면** (`/favorites`), **세그먼트 탭 3개**(재료 · 레시피 · 소스).
- 진입점: 재료·레시피 **메인 페이지 앱바의 별 아이콘**.

하단 탭은 이미 5개(재료·재고·레시피·리포트·설정)로 포화 → 즐겨찾기는 탭이 아닌 앱바 진입으로 처리한다.

## 2. 데이터 & 영속화

### 2.1 DB 마이그레이션 (v9 → v10)
`database_helper.dart`의 `schemaVersion`을 `9` → `10`으로 올리고, `_onUpgrade`에 기존 `if (oldVersion < N)` 패턴으로 블록 추가:

```dart
if (oldVersion < 10) {
  await db.execute('ALTER TABLE ingredients ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0');
  await db.execute('ALTER TABLE recipes ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0');
  await db.execute('ALTER TABLE sauces ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0');
}
```

`_onCreate`의 `ingredients`/`recipes`/`sauces` `CREATE TABLE`에도 동일 컬럼 추가(신규 설치 대응).

별도 즐겨찾기 테이블이 아닌 **컬럼 방식**을 채택 — 마이그레이션·조회가 단순하고 기존 스키마 패턴(`sell_price`, `storage_location` 등)과 일치한다.

### 2.2 모델
`Ingredient`/`Recipe`/`Sauce` 각각에 `final bool isFavorite` 추가 (기본값 `false`).
- 생성자: `this.isFavorite = false`.
- `toJson()`: `'is_favorite': isFavorite ? 1 : 0`.
- `fromJson()`: `isFavorite: (json['is_favorite'] ?? 0) == 1` — 레거시 행(컬럼 미존재 또는 0)은 `false`로 매핑.
- `copyWith({bool? isFavorite})`: `isFavorite: isFavorite ?? this.isFavorite`.
- `props`(Equatable)에 `isFavorite` 포함.

### 2.3 Repository
`IngredientRepository`/`RecipeRepository`/`SauceRepository`에 단일 컬럼만 갱신하는 메서드 추가:

```dart
Future<void> setFavorite(String id, bool value) async {
  final db = await _db;
  await db.update(
    '<table>',
    {'is_favorite': value ? 1 : 0},
    where: 'id = ?',
    whereArgs: [id],
  );
}
```

전체 레코드 저장이 아닌 **부분 UPDATE**로 최소 쓰기. 조회는 기존 `getAll*`가 `is_favorite`를 함께 읽어오므로 별도 즐겨찾기 전용 쿼리는 두지 않는다.

## 3. 토글 동작 & Cubit

각 Cubit에 `toggleFavorite` 추가:
- `IngredientCubit.toggleFavorite(Ingredient)`
- `RecipeCubit.toggleFavorite(Recipe)`
- `SauceCubit.toggleFavorite(Sauce)`

동작:
1. `repository.setFavorite(item.id, !item.isFavorite)` 저장.
2. **메모리 상 로드된 리스트에서 해당 항목만** `copyWith(isFavorite: !item.isFavorite)`로 교체.
3. 갱신된 리스트로 `Loaded` 상태 emit → 전체 재조회 없이 즉시 반영(스크롤·정렬·검색 상태 유지).

별 아이콘 위젯:
- 목록 항목 내부에 배치하되 **행 탭(상세 진입)과 분리**. 별 영역은 자체 `GestureDetector`/`InkWell` `onTap`으로 토글만 처리하고 이벤트 전파를 막는다.
- 상태 표시: 채워진 별 `Icons.star` (`tokens.primary`) / 빈 별 `Icons.star_border` (`tokens.fgTertiary`).
- 대상 위젯: `IngredientListTile`, 레시피 `_RecipeCard`, 소스 `_SauceCard` — 각각 `isFavorite`(또는 item에서 파생) + `onToggleFavorite` 콜백 파라미터 추가.

## 4. 즐겨찾기 화면

- 신규 `FavoritesPage`, 라우트 `/favorites` (`AppRouter.favorites`).
- 상단 `SegmentControl<_FavTab>` 재사용 — 재료 · 레시피 · 소스 3탭.
- 각 탭은 **기존 카드/타일을 그대로 재사용**한다. `IngredientCubit`/`RecipeCubit`/`SauceCubit`의 로드된 상태를 `BlocBuilder`로 읽어 `where((e) => e.isFavorite)` 필터링.
- **데이터 로드 보장**: `FavoritesPage`의 `initState`에서 세 Cubit의 `loadIngredients`/`loadRecipes`/`loadSauces`를 호출한다(앱 시작 직후 해당 목록 페이지를 아직 방문하지 않아 상태가 비어 있는 경우 대비). 각 Cubit은 로드 완료 시 `is_favorite`를 포함한 리스트를 보유하므로 추가 즐겨찾기 전용 조회는 불필요.
- 즐겨찾기 화면에서도 별 탭으로 해제 가능 → 해제 시 필터 결과에서 즉시 사라진다.
- 탭별 빈 상태: 아이콘 + "아직 즐겨찾기한 재료가 없어요" 등 안내 문구.

## 5. 진입점 & i18n

- `IngredientMainPage` / `RecipeMainPage` 앱바 `actions`에 별 아이콘 `IconButton` 1개 추가 → `context.push(AppRouter.favorites)`.
- 신규 i18n(6개 로케일: 한/일/중간/중번/영/베):
  - 화면 제목 "즐겨찾기" (`getFavorites`)
  - 탭별 빈 상태 문구 3종 (`getNoFavoriteIngredients` / `getNoFavoriteRecipes` / `getNoFavoriteSauces`)
- 세그먼트 라벨은 기존 `getIngredients` / `getRecipes` / `getSauces` 재사용.

## 6. 테스트

- **스키마**: v10 마이그레이션 후 세 테이블에 `is_favorite` 컬럼 존재 및 default 0 (기존 `inventory_schema_test.dart` 패턴).
- **Repository**: `setFavorite`가 단일 컬럼만 갱신하고 재조회 시 값이 유지되는지.
- **모델**: `toJson`/`fromJson` 라운드트립에 `isFavorite` 포함, 레거시 행(`is_favorite` 없음/0) → `false` 매핑.
- **Cubit**: `toggleFavorite`가 저장 호출 + 메모리 리스트의 해당 항목만 갱신하는지 (fake repository 패턴 활용).

## 7. 범위 밖 (YAGNI)

- 즐겨찾기 기준 정렬 옵션 추가
- 홈/대시보드 위젯에 즐겨찾기 노출
- 즐겨찾기 개수 뱃지
- 즐겨찾기 동기화(클라우드)

필요 시 후속 작업으로 분리한다.

## 8. 영향 파일 (예상)

- `lib/data/database_helper.dart` — 스키마 v10, `_onCreate`/`_onUpgrade`
- `lib/model/ingredient.dart` · `recipe.dart` · `sauce.dart` — `isFavorite` 필드
- `lib/data/ingredient_repository.dart` · `recipe_repository.dart` · `sauce_repository.dart` — `setFavorite`
- `lib/controller/ingredient/ingredient_cubit.dart` · `controller/recipe/recipe_cubit.dart` · `controller/sauce/sauce_cubit.dart` — `toggleFavorite`
- `lib/screen/widget/ingredient_list_tile.dart` · `lib/screen/pages/recipe/recipe_main_page.dart`(`_RecipeCard`/`_SauceCard`) — 별 아이콘
- `lib/screen/pages/ingredient/ingredient_main_page.dart` · `recipe/recipe_main_page.dart` — 앱바 진입 아이콘
- `lib/screen/pages/favorites/favorites_page.dart` — 신규
- `lib/router/app_router.dart` — `/favorites` 라우트
- `lib/util/app_strings*.dart` — 신규 문구
