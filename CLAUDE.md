# Recipe App — Coding Agent Guide

## Project at a glance
Flutter 앱 for ingredient/sauce/recipe 원가 관리. State = Cubit (flutter_bloc), DB = sqflite, 라우팅 = go_router, 디자인 = Wanted DS 토큰 (`lib/theme/tokens/`).

## Design tokens (필수 사용)
모든 신규/수정 화면은 다음 토큰으로 작성:
- 색상: `AppColorTokens.of(context)` — `bgBase`, `bgElev1/2`, `bgMuted`, `fgStrong/Default/Secondary/Tertiary`, `primary`, `primarySoft`, `positive/positiveSoft`, `warning/warningSoft`, `negative/negativeSoft`, `accentAi/accentAiSoft`, `borderSubtle/Default`.
- 타이포: `AppTypography` — `display1~3`, `title1~3`, `heading1/2`, `headline1/2`, `body1/1Reading/2/2Reading`, `label1/1Reading/2`, `caption1/2`.
- 간격: `AppSpacing` — s2/4/6/8/12/16/20/24/32/40/48/64/96/128.
- 라운드: `AppRadius` — r2/4/6/8/10/12/16/20/24/32, `pill`, `brR8/10/12/16/20/Pill`.

레거시 `colorScheme.primary`, `AppTextStyles` 는 새 코드에 사용하지 말 것.

## 핵심 모델
- `Recipe` — `totalCost`, **`sellPrice`** (DB v7 컬럼, default 0), `outputAmount`/`outputUnit`, `ingredients: List<RecipeIngredient>`, `sauces: List<RecipeSauce>`.
- `Sauce` — `totalWeight`, `totalCost`. **재료에서 소스로 변환 시 단위는 항상 g.**
- `Ingredient` — `purchasePrice`, `purchaseAmount`, `purchaseUnitId`, `tagIds`, `expiryDate`.

## 핵심 쿠빗 메서드
- `RecipeCubit.addRecipe({...required sellPrice})`
- `RecipeCubit.updateRecipe(Recipe)` — `Recipe.copyWith(sellPrice: ...)` 거쳐 갱신
- `SauceCubit.addSauce({name})` → `SauceAdded` emit, `addIngredientToSauce(...)` 로 재료 추가

재료 마스터 가격 변경 → 옵션 의존성으로 주입된 `_sauceCubit?.refreshAffectedByIngredient` → `_recipeCubit?.refreshAffectedByIngredient` cascade. 순서 중요(소스 먼저). cascade 흐름은 `autoAdjustSellPrice = true` 로 마진율 비례 보존.

## 마진율 규약
```dart
double margin(double sellPrice, double cost) {
  if (sellPrice <= 0) return 0;
  return ((sellPrice - cost) / sellPrice) * 100;
}
```
색상 단계:
- `m >= 60` → `tokens.positive` (green)
- `40 <= m < 60` → `tokens.warning` (orange)
- `m < 40` → `tokens.negative` (red)

## 디자인 핸드오프 위치
`레시피앱_디자인/project/screens.jsx` 단일 파일에 모든 화면 함수 정의:
- `RecipesScreen` — line 870~952 (메인, 레시피/소스 탭)
- `RecipeDetail` — line 954~1082 (도넛 + 슬라이더 + 원가 구성)
- `SauceNew` — line 1247~1359
- `RecipeNew` — line 1361~1537

CSS 변수 매핑(필요 시): `--primary` ↔ `tokens.primary`, `--bg-elev-2` ↔ `tokens.bgElev2`, `--fg-tertiary` ↔ `tokens.fgTertiary`, `--positive/warning/negative` ↔ 동명 토큰, `--bg-muted` ↔ `tokens.bgMuted`, `--border-subtle` ↔ `tokens.borderSubtle`.

---

## Active Workstreams

| 워크스트림 | 상태 | 문서 |
|---|---|---|
| 광고 제거 일회성 결제 (RevenueCat) | **Phase 1~8 완료**. Phase 9 (외부 등록 + sandbox QA) 만 남음 | [`docs/handoff-revenuecat.md`](docs/handoff-revenuecat.md) |
| 미진행 기능 (A 배너 광고만 남음) | C/D/E 완료. A 는 plan only | [`docs/handoff-future-features.md`](docs/handoff-future-features.md) |
| 종료된 라운드 (레시피·소스 / 후속 안정화 / 리포트) | 종료 — 컨텍스트 참고용 | [`docs/history-2026-05.md`](docs/history-2026-05.md) |
| 종료된 라운드 (리포트 후속 / App Open 광고 / 부팅 시퀀스 / 리뷰 정책) — 2026-05-05 | 종료 — 컨텍스트 참고용 | [`docs/history-2026-05-05.md`](docs/history-2026-05-05.md) |
| 디자인 시스템 마이그레이션 | (별도 문서) | [`docs/design-system-migration.md`](docs/design-system-migration.md) |

## 의존 그래프

```
A 배너 광고 (미진행)  ──┐
                      ├─ 독립
B 리포트 ✅ (2026-05-04)─┘

C 로그인 ✅ Phase 1 ──→ D 유저 페이지 ✅ ──→ E 광고 제거 결제 ✅ Phase 1~8
                                                     │
                                                     └─ 전면 광고 게이팅 ✅ (RC Phase 5 에서 흡수)
```

남은 작업:
1. **RevenueCat Phase 9** — RC 대시보드 webhook 등록 + 스토어 콘솔 product 등록 + `.env` API key 채우기 + 실기기 sandbox QA (자세히는 handoff-revenuecat.md 의 외부 작업 체크리스트)
2. **A 배너 광고 (선택)** — 현재 전면 광고만 게이팅됨. 배너 추가 시 `BlocBuilder<PremiumCubit>` 로 isPremium 분기

각 워크스트림 완료 시:
- 진행 중 워크스트림 → 해당 `docs/handoff-*.md` 에 결과·검증 결과 추가
- 종료된 워크스트림 → `docs/history-*.md` 로 이전, 인덱스 업데이트

## 작업할 때

새 코드는 디자인 토큰 + 6 로케일 i18n + `flutter analyze` 신규 에러 0 을 기본으로. 큰 기능은 Phase 단위로 끊어서 PR. 외부 인프라 (Firebase Console / 스토어 콘솔) 가 막히는 작업은 코드만 미리 작성하고 사용자 책임 작업을 명시 보고.
