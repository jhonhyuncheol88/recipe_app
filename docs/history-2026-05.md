# History — 2026-05 라운드 (종료된 작업)

레시피/소스 디자인 핸드오프 적용 + 후속 안정화 + 리포트 페이지 — 모두 완료된 워크스트림. 새 작업 참고용 컨텍스트로만 사용.

핵심 컨벤션(디자인 토큰 / 모델 / 마진율 등)은 `CLAUDE.md` 참조.

---

## 1. 레시피/소스 디자인 핸드오프 — ✅ 적용 (2026-05-04)

목표: `레시피앱_디자인/` 의 레시피+소스 영역을 Flutter 로 1:1 이식. 마진율, 판매가, 재료/소스 선택 시트, 레시피 상세(도넛/슬라이더/배수/공유/원가 구성).

### 신규 / 수정 파일
- **NEW** `lib/util/recipe_margin.dart` — 마진율 계산 + 색상 단계 헬퍼
- **NEW** `lib/screen/widget/ingredient_picker_sheet.dart` — `showIngredientPickerSheet(context, {excludeIds})`
- **NEW** `lib/screen/widget/sauce_picker_sheet.dart` — `showSaucePickerSheet(context, {excludeIds})`
- **REWRITE** `lib/screen/pages/recipe/recipe_add_page.dart` — 새 디자인 (이름/판매가/재료/소스/원가 미리보기/등록하기)
- **REWRITE** `lib/screen/pages/recipe/recipe_edit_page.dart` — 같은 폼 + 삭제
- **NEW** `lib/screen/pages/recipe/recipe_detail_page.dart` — 도넛 + 시뮬레이션 슬라이더 + 배수 + 공유 + 원가 구성
- **NEW** `lib/screen/pages/sauce/sauce_create_page.dart` — 이름/구성재료/총 원가/등록하기
- **REWRITE** `lib/screen/pages/sauce/sauce_edit_page.dart` — 같은 폼 + 삭제
- **MODIFY** `lib/screen/pages/recipe/recipe_main_page.dart` — `_RecipeCard` 마진율 우측 표시, + 소스 버튼 → `sauce_create_page`
- **MODIFY** `lib/data/database_helper.dart` — DB v7, `recipes.sell_price` 컬럼
- **MODIFY** `lib/model/recipe.dart` — `sellPrice` 필드 추가
- **MODIFY** `lib/controller/recipe/recipe_cubit.dart` — `addRecipe(sellPrice)` 시그니처
- **MODIFY** `lib/router/app_router.dart` — `sauceCreate` 라우트 신규, `recipeDetail` 빌더 추가
- **MODIFY** `lib/util/app_strings/app_strings_common.dart` + `app_strings.dart` — 신규 i18n 30+ 문자열 (6개 로케일)

### 라우팅 매핑
| 경로 | 페이지 |
|---|---|
| `/recipe/create` | `RecipeAddPage` |
| `/recipe/edit` | `RecipeEditPage` |
| `/recipe/detail` | `RecipeDetailPage` |
| `/sauce/create` | `SauceCreatePage` |
| `/sauce/edit` | `SauceEditPage` |
| `/recipes` | `RecipeMainPage` (마진율 표시 + 소스 흐름) |

### DB 스키마 v8 (히스토리 자동 적재)
- `recipe_price_history.sell_price REAL NOT NULL DEFAULT 0` 컬럼 추가
- `RecipeRepository.insertRecipe` / `updateRecipe` 가 원가 또는 판매가 중 하나라도 변경되면 스냅샷 1행 기록 (둘 다 한 행에 같이 저장)
- detail 페이지의 "적용" → `RecipeCubit.updateRecipe(copyWith(sellPrice:))` → 자동 히스토리 동기

### 알려진 한계 (이 라운드 이후 정리됨)
- 레시피 상세의 판매가 슬라이더는 "적용" 명시 저장 (자동 저장 X)
- 배수(multiplier) 는 detail 페이지 한정, 페이지 닫으면 1.0 리셋
- 잔존 미진입 코드: `sauce_main_page.dart`, `sauce_ingredient_select_page.dart`, `recipe_ingredient_select_page.dart`, `recipe_quick_view_dialog.dart` — 다음 정리 단계 후보

---

## 2. 후속 안정화·정리 라운드 (2026-05-04 이후)

### 2-1. 데이터 일관성 — Cascade & Cache

**재료 마스터 가격 변동 cascade**: `IngredientCubit.updateIngredient` → `_sauceCubit?.refreshAffectedByIngredient(id)` → `_recipeCubit?.refreshAffectedByIngredient(id)` → 영향받은 행만 재계산 후 `RecipeLoaded`/`SauceLoaded` 한 번에 emit. **순서 중요: 소스 먼저 → 레시피.**

**`recipe_ingredients.calculated_cost` 캐시 자동 갱신**: `RecipeCubit._recalculateRecipeCost` 진입 첫 줄에 `_refreshRecipeIngredientCosts(recipeId)` 호출. 모든 호출자가 fresh 캐시 위에서 계산.

**마진율 유지 sellPrice 자동 조정**: `_recalculateRecipeCost(recipeId, {bool autoAdjustSellPrice = false})`.
- cascade 흐름은 **true** → `newSellPrice = oldSellPrice × (newCost / oldCost)` 비례 조정
- 폼이 명시 입력한 sellPrice 보존을 위해 `addRecipe`/`updateRecipe` 는 **false**(기본)
- 결과: 재료값 바뀌면 → 원가·판매가 동시 갱신 → repo 가 변경 감지 → `recipe_price_history` 자동 적재

### 2-2. 레시피 상세 — Listener / Multiplier 정리

**delete back-nav 버그 수정**: 이전엔 list 가 비면 pop 안됨. 현재 `listenWhen: curr is RecipeDeleted` + `state.deletedId == widget.recipe.id` → `addPostFrameCallback` 즉시 pop.

**배수와 원가 구성 분리**: `_HeroCard`/`_CompositionCard` 에서 multiplier 파라미터 제거 → 도넛/시뮬/구성은 항상 1배. `_MultiplierShareCard` → **`_ProductionGuideCard`** 로 교체. 슬라이더 + 재료/소스 양 리스트(스케일된 g + `1× 원본` 라벨) + 산출량 스케일. **원가 표시 없음** — 순수 제작 가이드.

### 2-3. 사진 기능 제거

`Recipe.imagePath` 필드/생성자/`toJson`/`fromJson`/`copyWith`/`props` 모두 제거. `RecipeCubit.addRecipe(imagePath:)` 파라미터도 제거. DB `recipes.image_path` 컬럼은 nullable 이라 그대로 둠 (마이그레이션 불필요).

UI placeholder 컨테이너 제거: `_RecipeCard` 56×56 박스, `_SauceCard` 44×44 박스, `_HeroCard` 64×64, `IngredientCategoryLabel` 64×64/52×52 등. 텍스트가 좌측부터 시작.

### 2-4. "배치" 단어 일괄 제거 + 소스 단위 정책 변경

**정책: 소스 단위는 항상 g.** 이전엔 `RecipeSauce.unitId = AppStrings.getPerBatch(locale)` ("1배치"/"1 batch") → `UnitConverter.toBaseUnit` ArgumentError. 현재:
- `RecipeSauce.unitId = 'g'` 고정. UI suffix 도 `'g'`
- `_SauceLine.lineCost = sauce.unitCost × qty(g)` (`unitCost = totalCost / totalWeight`)
- 신규 sauce 행 기본 qty = `sauce.totalWeight.round()` (소스 한 통)
- 행/picker 표시: `₩X/g · ₩Y`

**방어 로직**: `RecipeCostService._safeToBaseUnit` wrapper. 알 수 없는 unitId 는 amount 그대로(=g) 사용 → 과거 잘못 저장된 행도 크래시 안 함.

**i18n 정리**: `getOneBatch` / `getPerBatch` / `getOneBatchCost` 6 로케일 라벨 삭제. `_BatchCostPreview` → `_TotalCostPreview` (`getTotalCostLabel`).

### 2-5. 데이터 백업 — `BackupService`

`lib/service/backup_service.dart` 싱글톤이 export/import/reset 일괄 처리. `schemaVersion = 8` 상수 (database_helper 동기).
- **export**: 파일명에 schema version (`recipe_app_export_v8_<ts>.db`), 0바이트 가드. `exportTo(targetDir)` / `exportToTemp()` 두 메서드
- **import**: 파일 존재·크기 → SQLite 매직 헤더 검증 → read-only 임시 open → `PRAGMA user_version` 확인 (downgrade reject) → 기존 DB `*.import_backup` 백업 → import 파일 복사 → 재오픈. **실패 시 자동 롤백**
- **reset**: close → `deleteDatabase` → 재오픈 (`_onCreate` 가 기본 단위/태그 자동 재삽입)
- settings_page 는 import/reset 후 `_reloadAllState()` 헬퍼로 4 cubit + `ExpiryNotificationCubit.loadExpiryNotifications()` 동시 갱신

### 2-6. 일괄 등록 페이지 리팩토링

`ingredient_bulk_add_page.dart` 를 `ingredient_add_page.dart` 와 동일한 위젯·디자인 토큰 패턴으로 재작성. `IngredientFormCard` 재사용, `_BulkRow` 클래스 캡슐화, 단일 `Form` key 일괄 validate, 레거시 (`AppTextStyles` / `Card` / `print` / 한국어 하드코딩) 제거. prefilled OCR 데이터 기능 유지.

### 2-7. 인앱 리뷰 — 자체 게이트 제거

`_app_launch_count` 3회, `_reviewCooldown 3d`, 7일 거부 게이트, 10회 상한 모두 제거. 유지: 온보딩 완료 후 3초 지연, `userReviewed`/`userDeclined` 플래그. **노출 빈도는 OS rate limit 에 위임** (iOS 365일 내 3회 등).

### 2-8. 앱 아이콘

`flutter_launcher_icons` 가 `assets/images/appIcon.png` 사용. `adaptive_icon_background`, web `background_color`, `theme_color` 모두 primary `#0066FF` 통일. `dart run flutter_launcher_icons` 로 Android adaptive + iOS 전 사이즈 + Web/macOS/Windows 일괄 생성.

### 2-9. Logger 진단 로그 (grep 가능 태그)

- `[addRecipe]`, `[updateRecipe]`, `[deleteRecipe]`, `[refreshAffectedByIngredient]`, `[_recalculateRecipeCost]` — `RecipeCubit`
- `[insertRecipe]`, `[updateRecipe]` (repo), `[deleteRecipe]` — `RecipeRepository` (cost·sellPrice diff + history 적재)
- `[detail._applySimSellPrice]`, `[detail._confirmDelete]`, `[detail.listener]` — `recipe_detail_page`

### 2-10. 설정 메뉴 — 태그 관리 임시 비활성화

`settings_page.dart` 의 "레시피 태그 관리" `SettingsListTile` 주석 처리. 라우트 `/settings/recipe-tags` 와 페이지 자체는 유지 (주석만 풀면 즉시 복구).

---

## 3. 리포트 페이지 — ✅ 적용 (2026-05-04)

목적: 레시피·재료의 비용/마진 추이를 한눈에. BottomNav 3번째 탭 진입.

### 신규 파일
- **NEW** `lib/model/report_data.dart` — `ReportPeriod` enum (weekly 7d / monthly 30d / quarterly 90d, 후자 7일 버킷팅), `CostRatioPoint`, `CategoryShare`, `MarginRankItem`, `ExpensiveIngredientItem`, `ReportData(empty)`
- **NEW** `lib/service/report_service.dart` — 모든 메서드 static 순수 함수
  - `computeAvgCostRatioSeries` — LOCF 버킷팅. `sellPrice <= 0` 행 제외, 모든 레시피 빠진 버킷은 차트 갭(null)
  - `computeAvgAndDelta` — 시계열 절반 분할 → 현재/이전 평균 + delta(pp)
  - `computeInventoryComposition` — 재료별 `purchasePrice` 합산 → 태그별 버킷 → top 5 + "기타"
  - `computeMarginRanking` — `sellPrice > 0` 마진율 내림차순
  - `computeTopExpensiveIngredients` — 기본단위 당 단가. `UnitConverter.toBaseUnit` ArgumentError 는 try/catch skip
- **NEW** `lib/controller/report/report_state.dart` — Initial / Loading / Loaded(data, period) / Error(message)
- **NEW** `lib/controller/report/report_cubit.dart` — Recipe/Ingredient/**Locale** 3개 stream 구독 + 150ms 디바운스. 5개 repo 병렬 로드(`Future.wait`). `changePeriod()` 즉시 refresh, locale 변경 시 자동 refresh
- **NEW** `lib/screen/pages/report/report_page.dart` (~994L) — 4개 카드:
  - `_CostRatioCard` — 평균 원가율 + 목표 달성 배지(≤40%) + delta 화살표 + `fl_chart` LineChart(120h)
  - `_InventoryCard` — 재고 가치 도넛(centerSpaceRadius 34, sectionRadius 26) + 우측 범례
  - `_MarginRankCard` — TOP 5 + 5개 초과 시 "전체보기" → `DraggableScrollableSheet`(0.7~0.95)
  - `_ExpensiveIngrCard` — 단가 내림차순 가로 막대(maxPrice 비례 ratio)
- **NEW** `lib/util/app_strings/app_strings_report.dart` — 6 로케일 30+ 라벨
- **MODIFY** `lib/util/app_strings.dart` — facade 매핑

### 통합
- **MODIFY** `lib/router/app_router.dart` — `/report` + `HomePage._pages[2] = ReportPage()` (BottomNav 4탭). 탭 전환 시 `ReportCubit.refresh()`
- **MODIFY** `lib/main.dart` — `BlocProvider<ReportCubit>(...)..refresh()` 등록. `LocaleCubit` 를 `ReportCubit` provider 위로 이동(의존성 순서)
- **MODIFY** `lib/controller/index.dart` — `report/report_cubit.dart` export
- 의존성: `fl_chart ^0.69.0` (이미 pubspec 존재)

### 데이터 흐름
재료 가격 변경 → `IngredientCubit` → cascade → `RecipeCubit emit RecipeLoaded/Updated` → `ReportCubit._onRecipeState` → 150ms 디바운스 → 5개 repo 병렬 로드 → 4개 service 함수 → emit `ReportLoaded`. UI 는 `BlocBuilder<ReportCubit>` + `BlocBuilder<LocaleCubit>` + `BlocBuilder<NumberFormatCubit>` 3중 wrap 자동 리빌드.

### 마무리 수정
- `ReportCubit` 가 `LocaleCubit` 의존성 받음 → 도넛 라벨을 `AppStrings.getUncategorized/getOtherCategories(locale)` 로 i18n 화. 언어 전환 시 자동 refresh
- `_buildError` 의 재시도 버튼: `getSave` → `getRetry`. 실제 `message` 도 노출

### 알려진 한계 / TODO
- 재료 가격 history 미보유 → 비싼 재료 카드는 현재 시점 단가만 (시계열 X). 필요 시 v9 schema `ingredient_price_history`
- 사용 빈도 top-N 미구현 (사용 카운터 컬럼 없음)
- 실기기 검증 미수행 — 라이트/다크, 6 로케일, 시계열 정확성

---

## 검증 체크리스트 (2 라운드 종합)

- [x] `flutter analyze lib/` 신규 에러 0건 (276 사전 경고는 다른 파일 기존 issue)
- [x] 재료 가격 변경 → 모든 레시피·소스 카드 즉시 갱신 + `recipe_price_history` 스냅샷
- [x] 레시피 상세 → 판매가 슬라이더 "적용" → 도넛/판매가 갱신 + 히스토리 기록
- [x] 레시피 상세 → 삭제 → 메인으로 자동 pop (마지막 1개여도 동작)
- [x] 배수 슬라이더 → 도넛/구성 변동 없음, 제작 가이드 카드만 비례
- [x] 소스 g 단위 입력 → 에러 없이 저장 + 비용 합산 (₩/g × g)
- [x] 데이터 내보내기/가져오기/초기화 → 정상 + 잘못된 파일 reject + 실패 시 롤백
