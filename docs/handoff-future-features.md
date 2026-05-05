# Handoff — 미진행 기능 plan

이미 진행된 워크스트림은 다음 문서 참조:
- 광고 제거 결제 (RevenueCat) — `docs/handoff-revenuecat.md` (Phase 1~8 완료, Phase 9 외부 등록·QA 만 남음)
- 레시피·소스 / 리포트 페이지 — `docs/history-2026-05.md` (종료)

## 의존 그래프

```
A 배너 광고 (미진행)  ──┐
                      ├─ 독립
B 리포트 ✅ (2026-05-04)─┘

C 로그인 ✅ Phase 1 ──→ D 유저 페이지 ✅ ──→ E 광고 제거 결제 ✅ Phase 1~8
                                                     │
                                                     └─ A 광고 게이팅 ✅ (RC Phase 5 에서 흡수)
```

남은 작업:
1. **A 배너 광고 (선택)** — 현재 전면 광고만 있음. 배너는 미진행
2. **RevenueCat Phase 9** — 외부 등록 (RC 대시보드 webhook / 스토어 콘솔 product / .env API key) + 실기기 sandbox QA. 자세히는 `docs/handoff-revenuecat.md`

---

## A. 배너 광고

> **현재 상태**: 전면 광고 (`InterstitialAd`) 4곳이 동작 중 (앱 오픈 / AI 분석 / 백과사전 / AI 판매 분석). RC Phase 5 에서 Pro 사용자는 자동 스킵 동작 함. **배너 광고 자체가 없는 상태**.

목적: 무료 사용자에게 하단 배너 노출, Pro 자동 숨김.

### 설계 포인트
- 패키지: 이미 `google_mobile_ads ^6.0.0` 도입됨
- AdUnit ID: `lib/util/ads_config.dart` 패턴 참고 (디버그 빌드는 Google 테스트 ID, 프로덕션은 .env 의 ADMOB_*_BANNER_ID 같은 키)
- 위젯: `lib/screen/widget/app_banner_ad.dart` 신규 — `AdWidget(BannerAd)`, 로딩 실패 시 0높이 collapse
- 노출 위치 후보: 메인 탭 페이지(재료/레시피/리포트/설정) 하단 SafeArea 위. `BottomNavigationBar` 위에 stack
- **숨김 조건**: `BlocBuilder<PremiumCubit>` 로 `state.isPremium == true` 면 `SizedBox.shrink()`. 또는 더 단순하게 RC Phase 5 의 `AdMobForwardService.setPremiumGate` 패턴 같이 callback 등록
- AdMob 정책: 인터랙티브 요소와 시각적 분리, "광고" 라벨 권장
- 이벤트 트래킹: `FirebaseAnalytics` `ad_impression`/`ad_click` 자동 기록 확인

### 검증
- [ ] 디버그에서 Google 테스트 배너 노출
- [ ] Pro mock state 시 배너 사라짐
- [ ] 광고 로딩 실패 시 빈 공간 없이 collapse

---

## C. 로그인 — ✅ Phase 1 완료

자세한 내용: `docs/handoff-revenuecat.md` 의 Phase 1 섹션.

요약: Firebase Auth 기반 Google + Apple Sign-In 동작. `AuthBloc` 의 `Authenticated(user)` / `Unauthenticated` state, returnTo 흐름, 디자인 토큰 준수 LoginScreen, iOS 네이티브 capability/URL Schemes 적용 완료.

남은 외부 작업: Firebase Console Auth provider 활성화 + Android SHA-1/256 등록 (자세히는 RevenueCat 문서의 외부 작업 체크리스트).

---

## D. 유저 페이지 — ✅ 완료 (2026-05-04)

### 신규/수정 파일
- **REWRITE** `lib/screen/pages/auth/account_info_page.dart` — 322L → ~380L. 디자인 토큰 전면 (AppColorTokens / AppTypography / AppRadius / AppSpacing). `BlocBuilder<LocaleCubit>` i18n 동적. `BlocConsumer<AuthBloc>` listener 가 `AuthFailure` 처리: `authReauthRequiredSentinel` 면 reauth 다이얼로그, 그 외 SnackBar
- **MODIFY** `lib/screen/pages/settings_page.dart` — `_buildAppSettings` 의 광고 제거 메뉴 위에 `SettingsListTile(title: getAccountInfo, icon: person_outline)` 추가 (`RouterHelper.goToAccountInfo` 활용)

### 페이지 구성
- **ProfileHeader** (로그인) / **SignedOutHeader** (비로그인 — 로그인 CTA)
- **PremiumCard** — `BlocBuilder<PremiumCubit>` 분기. Active: positive 카드 + 구매일. Free/그 외: 광고 제거 CTA → `/premium`
- **AccountActions** (로그인 시만): 로그아웃 + 계정 탈퇴 (negative)

### 핵심 결정
- **비로그인 시 redirect 안 함** — 기존엔 `/login` 강제 redirect 였으나 새 코드는 `_SignedOutHeader` 카드 + "로그인" CTA 만 표시. 비로그인 사용자도 광고 제거 메뉴 볼 수 있음
- **로그인 CTA returnTo** — `context.go(login, extra: accountInfo)` 로 로그인 후 자동 복귀
- **deleteAccount reauth UX** — listener 가 `AuthFailure(authReauthRequiredSentinel)` 받으면 다이얼로그 → "다시 로그인" 시 자동 logout + `/login?extra=/account-info` redirect → 로그인 후 사용자가 다시 탈퇴 시도 → fresh 토큰으로 성공
- **확인 다이얼로그** — 로그아웃·탈퇴 모두 한 단계 confirm. 탈퇴 다이얼로그는 데이터 삭제 안내 메시지 포함

### 검증
- `flutter analyze lib/screen/pages/auth/account_info_page.dart` → No issues found
- 전체 lib 의 issue 수 1개 감소 (기존 `super.key` lint 자동 해소)

---

## E. 유료 구독 → ✅ "광고 제거 일회성 결제" 로 확정

원래 plan 의 월간/연간 구독 + 7일 trial 안은 폐기. **광고 제거 단일 entitlement 의 일회성(non-consumable) 결제** 로 진행. Phase 1~8 완료.

자세한 plan + 진행 상황: `docs/handoff-revenuecat.md`
