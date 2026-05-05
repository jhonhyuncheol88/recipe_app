# Handoff — 광고 제거 일회성 결제 (RevenueCat)

광고 제거 단일 entitlement 의 일회성(non-consumable) 결제. 9 Phase plan 중 **Phase 1~8 완료**, **Phase 9 (외부 등록 + sandbox QA) 만 남음**.

## 전체 Phase 상태

| Phase | 내용 | 상태 |
|---|---|---|
| 0 | 외부 인프라 (RevenueCat / 스토어 콘솔 / Firebase Auth provider / Apple Capability) | 사용자 책임 — 일부 진행됨 |
| 1 | Auth 보강 (Google + Apple Sign-In) | ✅ 완료 |
| 2 | RevenueCat SDK 통합 (configure / logIn / customerInfoStream wrap) | ✅ 완료 |
| 3 | `PremiumCubit` + entitlement 흐름 | ✅ 완료 |
| 4 | 결제 페이지 UI (PremiumPage + 라우트 + 설정 메뉴 진입점) | ✅ 완료 |
| 5 | 광고 게이팅 (`AdMobForwardService` premium gate 주입) | ✅ 완료 |
| 6 | Firestore 통합 + 보안 규칙 (이력 적재 + isPremium 캐시) | ✅ 완료 (rules 배포 완료) |
| 7 | Cloud Functions Webhook (RevenueCat → 환불/차지백 자동 반영) | ✅ 완료 (배포 + secret 등록 완료) |
| 8 | i18n 마무리 (premium 라벨 6 로케일) | ✅ Phase 4 와 함께 완료 |
| 9 | QA (sandbox 결제 / 복원 / 환불 / 오프라인) | ⏳ 외부 등록 + 실기기 sandbox 테스트 |

---

## 사용자 책임 외부 작업 (선결 조건)

코드는 모두 ready. **다음 작업 없이는 sandbox 결제가 동작하지 않음.**

### 인증 (Phase 1 관련)
- [ ] **Firebase Console → Authentication → Sign-in method**: Google + Apple provider 활성화
- [x] Apple Developer → App ID Capability "Sign in with Apple" 추가
- [x] iOS Xcode `CODE_SIGN_ENTITLEMENTS` 3 config 모두 적용 (코드로 처리)
- [x] iOS `Info.plist` 의 `CFBundleURLSchemes` 에 Google `REVERSED_CLIENT_ID` 등록 (코드로 처리)
- [ ] **Android**: Firebase Console 에 SHA-1 + SHA-256 fingerprint 등록 (debug + release). `cd android && ./gradlew signingReport`

### 결제 (Phase 2~9 관련)
- [ ] **RevenueCat 계정**: 프로젝트 생성 + iOS / Android App 등록
- [ ] **App Store Connect**: in-app product `com.recipeapp.adfree.lifetime` (Non-Consumable) + Banking/Tax + Sandbox 테스터
- [ ] **Google Play Console**: in-app product `adfree_lifetime` (Managed product) + Internal testing track 빌드 + License testers
- [ ] **RevenueCat 대시보드**: Entitlement `premium` + Offering `default` + Package `lifetime` 생성, 두 스토어 product 연결
- [ ] **`.env` 채우기**: `REVENUECAT_IOS_KEY` / `REVENUECAT_ANDROID_KEY` 에 RevenueCat → Project Settings → API Keys 의 **Public SDK Keys** (Secret Key 아님)
- [ ] **RevenueCat 대시보드 → Project Settings → Integrations → Webhooks → Add new** (Phase 7 배포 결과 등록):
  - **URL**: `https://revenuecatwebhook-l2v44foqua-du.a.run.app`
  - **Authorization header**: `Bearer 07b99eb4ca857881be0c21e873747f6e2df9d41a1af48e9cb3ff292e805c32a0`
  - 위 secret 은 Firebase Secret Manager 에 같은 값으로 등록되어 있음. 변경 시 양쪽 동시 갱신 필요

### Cloud Functions / Firestore (이미 완료)
- [x] GCP Blaze 결제 활성화
- [x] Firestore rules 배포 (`firebase deploy --only firestore:rules`)
- [x] Cloud Functions IAM 권한 부여 (`584875089226-compute@developer.gserviceaccount.com` → cloudbuild.builds.builder + artifactregistry.writer + logging.logWriter)
- [x] `REVENUECAT_WEBHOOK_SECRET` Secret Manager 등록
- [x] `revenueCatWebhook` 배포 (asia-northeast3)

---

## ✅ Phase 1 — Auth 보강 (Google + Apple Sign-In)

목적: 결제가 가능하려면 사용자가 식별돼야 함. AuthBloc 인프라는 살아 있었으나 signIn 메서드가 비어 있어 `Authenticated(user)` 도달 경로가 없었음.

### 신규 / 수정 파일
- **MODIFY** `pubspec.yaml` — `google_sign_in ^6.3.0`, `sign_in_with_apple ^6.1.4`, `crypto ^3.0.6` 추가
- **MODIFY** `lib/util/app_strings/app_strings_auth.dart` — Apple 로그인 / 진행중 / 기능 로그인 안내 / 계정 탈퇴(타이틀·메시지·reauth·완료) 9개 라벨 6 로케일
- **MODIFY** `lib/util/app_strings.dart` — 위 9개 facade 매핑 (이름 충돌 회피: `getCancel` 은 기존 Common 사용, 신규는 `getSignInRequiredForFeature` 명명)
- **MODIFY** `lib/controller/auth/auth_event.dart` — `SignInWithGoogleRequested`, `SignInWithAppleRequested`, `DeleteAccountRequested`
- **REWRITE** `lib/data/auth_repository.dart` — `signInWithGoogle`, `signInWithApple` (랜덤 nonce + SHA256), `deleteAccount`, `_createOrUpdateUserDocument` (`merge:true`, isFirstSignIn 일 때만 createdAt, 매번 lastSignInAt, **isPremium 미포함** — Phase 6 rules 가 클라 write 차단). 사용자 취소는 `AuthCancelledException` sentinel
- **REWRITE** `lib/controller/auth/auth_bloc.dart` — 핸들러 3개 추가. 취소는 silent (`Unauthenticated` 복귀), 실패는 `AuthFailure(message)`. `requires-recent-login` 은 `authReauthRequiredSentinel` 상수로 전달. listener 안 emit 의 lint 는 ignore 주석 (구조 변경 risk 회피)
- **REWRITE** `lib/screen/pages/auth/login_screen.dart` — 디자인 토큰. `BlocConsumer` 로 Authenticated 시 `returnTo ?? '/'`, AuthFailure 시 SnackBar. iOS 에서만 Apple 버튼 (`!kIsWeb && Platform.isIOS`)
- **MODIFY** `lib/router/app_router.dart` — `/login` 라우트가 `extra` (String 또는 `Map['returnTo']`) 받음

### iOS Native 보강
- **MODIFY** `ios/Runner.xcodeproj/project.pbxproj` — `CODE_SIGN_ENTITLEMENTS = Runner/RunnerProfile.entitlements` 가 Profile only 였던 것을 Debug (line 705) / Release (line 737) 두 곳에도 추가. 3 config 모두 적용
- **MODIFY** `ios/Runner/Info.plist` — `CFBundleURLTypes` 신규. `GoogleService-Info.plist` 의 `REVERSED_CLIENT_ID` 를 `CFBundleURLSchemes` 등록. `PlistBuddy` 검증

### 검증
- 변경 파일 `flutter analyze` → No issues. 전체 276 issues 는 사전 경고

---

## ✅ Phase 2 — RevenueCat SDK 통합

### 신규 / 수정 파일
- **MODIFY** `pubspec.yaml` — `purchases_flutter ^10.0.1` 추가, `in_app_purchase ^3.1.13` 제거 (lib import 0건이라 안전. RC 와 영수증 검증 경로 분리 방지)
- **MODIFY** `.env` — `REVENUECAT_IOS_KEY=""`, `REVENUECAT_ANDROID_KEY=""` placeholder
- **NEW** `lib/service/revenue_cat_service.dart` — 싱글톤. configure / identify / logout / fetchDefaultOffering / getCustomerInfo / purchasePackage / restorePurchases / isEntitlementActive + `customerInfoStream` (SDK `addCustomerInfoUpdateListener` wrap). 상수 `premiumEntitlementId='premium'`, `defaultOfferingId='default'`. API key 미설정 시 silent skip → `isReady=false`. `initialize(initialAppUserId:)` 가 Firebase Auth cached uid 받아 race 방지
- **MODIFY** `lib/main.dart` — 1) `_safePreRunInitialization` 끝에 `RevenueCatService.instance.initialize(initialAppUserId: FirebaseAuth.currentUser?.uid)` 2) `MyApp` widget tree 에 `BlocListener<AuthBloc>` wrap → Authenticated 시 `Purchases.logIn(uid)`, Unauthenticated 시 `Purchases.logOut()`

### 핵심 결정
- **purchases_flutter 10.x 의 새 API**: `Purchases.purchasePackage(p)` deprecated → `Purchases.purchase(PurchaseParams.package(p))` 사용. service wrapper 는 호출자에 여전히 `CustomerInfo` 만 노출 (`PurchaseResult.customerInfo` 추출)
- **API key 미설정 graceful**: `.env` 비워도 부팅 가능. `isReady=false` 면 PremiumCubit 가 결제 메뉴 비활성

### 검증
- `flutter analyze lib/main.dart lib/service/revenue_cat_service.dart` → 신규 에러 0건

---

## ✅ Phase 3 — `PremiumCubit` + entitlement 흐름

### 신규 / 수정 파일
- **NEW** `lib/controller/premium/premium_state.dart`
  - `enum PremiumErrorKind { userCancelled, paymentPending, network, store, alreadyPurchased, notReady, unknown }`
  - `abstract class PremiumState extends Equatable` + 7개 구체: `PremiumUnknown / Checking / Free / Active(productId, originalPurchaseDate) / Purchasing / Restoring / Error(kind, message)`
  - `bool get isPremium => this is PremiumActive`
- **NEW** `lib/controller/premium/premium_cubit.dart` — `RevenueCatService` 만 의존. `bootstrap` / `refreshFromStore` / `purchase(Package)` / `restore`. 결제·복원 중 중복 호출 무시. 에러 후 `_settleAfterError()` 가 `getCustomerInfo()` 재조회로 자동 settle. `_classifyError` 가 `PurchasesErrorHelper.getErrorCode` → enum 매핑
- **MODIFY** `lib/controller/index.dart` — premium cubit/state export
- **MODIFY** `lib/main.dart` — `BlocProvider<PremiumCubit>(... ..bootstrap())` 등록 (AuthBloc provider 다음)

### 핵심 결정
- **AuthBloc 의존성 제거**: Plan 은 PremiumCubit ↔ AuthBloc 의존을 명시했으나 main 의 `BlocListener<AuthBloc>` 가 이미 RC.identify/logout 호출 → customerInfoStream 자동 emit → cubit 자동 갱신. 단방향 (AuthBloc → main listener → RC SDK → PremiumCubit) 으로 단순화
- **에러 후 자동 복귀**: `PremiumError` emit 직후 `_settleAfterError()` 가 마지막 entitlement 으로 settle. 사용자 취소도 sticky 하지 않음
- **진행 중 stream emit 무시**: 결제/복원 중 background customerInfoStream emit 무시 — 진행 메서드가 await 결과 직접 emit. race 방지

### 검증
- `flutter analyze lib/controller/premium/ lib/controller/index.dart lib/main.dart` → 신규 에러 0건

---

## 데이터 흐름 (Phase 1~3 종합)

```
앱 부팅
  └─ Firebase init → currentUser?.uid 로 RC.configure (race 방지)
  └─ AuthBloc 생성 + AppStarted → authStateChanges → Authenticated/Unauthenticated emit
       └─ main BlocListener<AuthBloc> → RC.identify(uid) | logout()
            └─ RC.customerInfoStream → PremiumCubit._onCustomerInfoUpdated
                 └─ PremiumActive(productId, originalPurchaseDate) | PremiumFree

사용자가 결제 버튼 탭 (Phase 4 에서 노출 예정)
  └─ PremiumCubit.purchase(package)
       └─ emit Purchasing → RC.purchasePackage → 성공 시 emit Active
       └─ 실패 시 emit Error(kind) → _settleAfterError → emit 마지막 entitlement
```

---

## ✅ Phase 4 — 결제 페이지 UI

### 신규/수정 파일
- **NEW** `lib/util/app_strings/app_strings_premium.dart` + facade — 24개 라벨 6 로케일 (Phase 8 합쳐서 처리)
- **NEW** `lib/screen/pages/premium/premium_page.dart` — Stateful + initState 가드 (비로그인 → `/login?extra=/premium` redirect) + `RevenueCatService.fetchDefaultOffering()` 별도 fetch + `BlocConsumer<PremiumCubit>` 분기. `_AlreadyOwnedView` (Active) / `_PurchaseView` (Free) / `_BusyOverlay` (Purchasing·Restoring) 컴포넌트 분리. listener 가 PremiumError SnackBar (userCancelled silent) + 복원 결과 안내 (`prev is PremiumRestoring` + `curr is Active/Free` → 별도 메시지)
- **MODIFY** `lib/router/app_router.dart` — `static const String premium = '/premium';` + GoRoute
- **MODIFY** `lib/router/router_helper.dart` — `goToPremium(context)` 헬퍼
- **MODIFY** `lib/screen/pages/settings_page.dart` — `_buildAppSettings` 에 `SettingsListTile(getPremiumMenuTitle, Icons.workspace_premium_outlined)` 진입점
- **MODIFY** `lib/screen/pages/auth/account_info_page.dart` (이후 D 작업에서 전면 재작성) — placeholder SnackBar → `RouterHelper.goToPremium`

### state 분기
| state | UI |
|---|---|
| Unknown / Checking | 중앙 CircularProgressIndicator |
| Free | 혜택 리스트 + `package.storeProduct.priceString` + 구매 + 복원 + 약관 |
| Purchasing / Restoring | 모든 버튼 비활성 + `_BusyOverlay` (전체 화면 dim + 스피너) |
| Active | `_AlreadyOwnedView` (구매일 + 복원만) |
| Error(userCancelled) | SnackBar 미노출, cubit 가 자동 settle |
| Error(paymentPending/network/store/alreadyPurchased/notReady/unknown) | listener 가 분류된 메시지 SnackBar |

### 핵심 결정
- **Offering fetch 는 page state 로 분리** (cubit 의 7 state 에 Offering 끼워넣지 않음). `_offering / _offeringLoading / _offeringFailed` page 자체 관리. RC `isReady=false` 면 `_offeringFailed=true` fallback
- **Package 선택**: `_offering.lifetime ?? _offering.availablePackages.firstOrNull` — RC Package 가 `lifetime` 명명일 때 우선
- **listener 가 복원 결과 안내**: `prev is PremiumRestoring` + `curr` 분기로 success / noPurchase 별도 SnackBar

---

## ✅ Phase 5 — 광고 게이팅

### 신규/수정 파일
- **MODIFY** `lib/service/admob_forward.dart` — `bool Function()? _premiumGate` 필드 + `setPremiumGate(bool Function() gate)` + `showInterstitialAd()` 첫 줄 가드
  ```dart
  if (_premiumGate?.call() == true) {
    _logger.i('🎟️ Premium 사용자 — 광고 스킵');
    _adCubit?.adWatched();
    return true;
  }
  ```
- **MODIFY** `lib/main.dart` — `BlocProvider<PremiumCubit>` 를 `lazy: false` 로 즉시 생성 + create 안에서 `AdMobForwardService.instance.setPremiumGate(() => cubit.state.isPremium)` 호출

호출처 4곳 (`main.dart` 앱 오픈 광고 / `ai_analysis_ad_dialog` / `encyclopedia_main` / `ai_sales_analysis`) 코드 변경 **0건**.

### 핵심 결정
- **`lazy: false` 가 필수** — 부팅 직후의 앱 오픈 광고가 호출될 때 PremiumCubit 가 아직 생성 안 됐으면 `_premiumGate=null` → 광고 노출. lazy:false 로 callback 등록이 광고 호출보다 먼저 보장됨
- **`_adCubit?.adWatched()` 호출** — 호출처(`ai_analysis_ad_dialog` 등)가 `if (adWatched) onAdWatched()` 패턴이라 Pro 사용자가 광고 없이 즉시 후속 액션 진행하도록

---

## ✅ Phase 6 — Firestore 통합 + 보안 규칙

### 신규/수정 파일
- **NEW** `lib/model/purchase_event.dart` — `PurchaseEvent` (id/timestamp/productId/status/errorCode/platform) + `PurchaseEventStatus` enum (success/restored/cancelled/pending/failed) + `wireValue`/`fromWire` 직렬화
- **NEW** `lib/service/purchase_history_service.dart` — `recordEvent({productId, status, errorCode})`. 내부에서 uid 조회 + eventId 자동 생성(`cli_<ts>_<product>_<rand>`) + platform 판단. 비로그인 silent skip. Firestore 쓰기 실패 swallow. `watch()` Stream 도 제공
- **MODIFY** `lib/data/auth_repository.dart` — `_createOrUpdateUserDocument` 가 isFirstSignIn 일 때만 `isPremium: false` 함께 set. update 분기에서 절대 포함 안 함 (rules 가 차단)
- **MODIFY** `lib/controller/premium/premium_cubit.dart` — `PurchaseHistoryService? _history` 옵션 의존. purchase 성공→success / 실패→`_statusForErrorKind` (cancelled/pending/failed) + errorCode. restore 성공 + Active 면 restored, Free 면 무기록
- **MODIFY** `lib/main.dart` — `RepositoryProvider<PurchaseHistoryService>` + `PremiumCubit` 에 history 주입
- **NEW** `firestore.rules` — users/{uid} (read 본인, create 시 isPremium=false 또는 미포함, update 시 isPremium 변경 차단, delete deny) + purchases/{uid}/events/{eventId} (append-only, 본인 read, update/delete deny)
- **NEW** `.firebaserc` — default project = `recipeapp-eec6c`
- **MODIFY** `firebase.json` — `firestore: { rules: "firestore.rules" }` 섹션 추가

### 배포 결과
```
=== Deploying to 'recipeapp-eec6c'...
✔  cloud.firestore: rules file firestore.rules compiled successfully
✔  firestore: released rules firestore.rules to cloud.firestore
✔  Deploy complete!
```

### 보안 계층
1. RevenueCat 서버 (영수증 검증) ← 진실원천
2. Cloud Functions Webhook (Phase 7) ← isPremium 토글 권한
3. Firestore `users/{uid}.isPremium` ← 캐시 (클라이언트 read only)
4. PremiumCubit state ← UI 게이팅 in-memory

---

## ✅ Phase 7 — Cloud Functions Webhook

### 신규/수정 파일
- **NEW** `functions/package.json` — firebase-admin ^12.7.0, firebase-functions ^6.0.1, typescript ^5.6.2. Node 20
- **NEW** `functions/tsconfig.json` — strict, es2020, commonjs, outDir lib
- **NEW** `functions/.gitignore` — node_modules, lib
- **NEW** `functions/src/index.ts` — v2 onRequest + `defineSecret('REVENUECAT_WEBHOOK_SECRET')`. POST 만 허용, Authorization Bearer 검증, anonymous user 스킵, 멱등성 (events/{eventId} exists 체크), event 적재 (`raw` 보존), isPremium 토글 (grant/revoke 타입 분류)
- **MODIFY** `firebase.json` — functions 섹션 (source/codebase/predeploy 빌드 hook)

### 이벤트 타입 분류
| 타입 | 동작 |
|---|---|
| `INITIAL_PURCHASE` / `NON_RENEWING_PURCHASE` / `RENEWAL` / `PRODUCT_CHANGE` / `UNCANCELLATION` | `users/{uid}.isPremium = true` + premiumProductId 기록 |
| `CANCELLATION` / `EXPIRATION` / `BILLING_ISSUE` / `SUBSCRIPTION_PAUSED` / `REFUND` | `users/{uid}.isPremium = false` |
| 그 외 | 이벤트만 적재, isPremium 변경 X |

### 인프라 셋업 (배포 과정에서 처리됨)
- IAM 권한 부여: `584875089226-compute@developer.gserviceaccount.com` 에 3개 role
  - `roles/cloudbuild.builds.builder`
  - `roles/artifactregistry.writer`
  - `roles/logging.logWriter`
- Webhook secret 생성 (`openssl rand -hex 32`) → Firebase Secret Manager `REVENUECAT_WEBHOOK_SECRET` (version 1)
- Cloud Functions v2 자동 부여: `secretAccessor` on REVENUECAT_WEBHOOK_SECRET

### 배포 결과
```
✔  functions[revenueCatWebhook(asia-northeast3)] Successful update operation.
Function URL: https://revenuecatwebhook-l2v44foqua-du.a.run.app
✔  Deploy complete!
```

### Webhook secret (RC 대시보드 등록용)
```
Bearer 07b99eb4ca857881be0c21e873747f6e2df9d41a1af48e9cb3ff292e805c32a0
```

---

## ✅ Phase 8 — i18n 마무리 (Phase 4 와 합쳐서 진행)

`app_strings_premium.dart` + facade 24개 라벨 6 로케일.

라벨 키:
`premiumMenuTitle / MenuSubtitle / PageTitle / BenefitNoAds / BenefitForever / BenefitFamilyShare / LoadingPrice / PriceUnavailable / PurchaseButton / RestoreButton / Purchasing / Restoring / AlreadyOwnedTitle / AlreadyOwnedSubtitle / PurchasedAt / LoginRequired / ErrorPending / ErrorNetwork / ErrorStore / ErrorAlready / ErrorNotReady / ErrorUnknown / RestoreSuccess / RestoreNoPurchase / TermsNotice`

---

## ⏳ Phase 9 — QA

시나리오 체크리스트:
- [ ] happy path (비로그인 → 설정 → 광고 제거 → 로그인 → 결제 → 광고 사라짐)
- [ ] 이탈/재진입 (요구 17): 결제 진행 중 background → foreground → entitlement 정상 반영
- [ ] 취소: 조용히 이전 state 복귀, SnackBar 미노출
- [ ] 이중 탭 방지: 5회 연타 → IAP 다이얼로그 1번
- [ ] 복원: 앱 삭제 → 재설치 → 같은 계정 → 복원
- [ ] 다른 기기 동기화: 기기 A 결제 → 기기 B 같은 Firebase 계정 → 자동
- [ ] 환불 (Phase 7 후): App Store Connect sandbox 환불 → 다음 부팅 시 광고 재노출
- [ ] 오프라인: 비행기 모드 → 결제 시 네트워크 에러. Pro 면 SDK 캐시로 광고 미노출 유지

---

## 결정 보류 / 사용자에게 물어볼 항목

1. 가격대 (₩4,900 / ₩6,900 / ₩9,900 — App Store Tier 매핑)
2. 출시 지역 (6 로케일 전부 vs 한국+미국 우선)
3. 가족 공유 (Family Sharing) — 활성화 권장
4. 프로모 코드 (App Store Connect 월 100개 무료 발급 가능)
5. 환불 정책 — 일회성 결제 24h 내 환불 자유, 환불 후 재구매 허용 (기본)
6. 추가 혜택 — 광고 제거 외 (AI 무제한 / 리포트 고급) 1.0 부터 vs 후속
7. Phase 7 (Cloud Functions) 출시 전/후 — 권장: 출시 전 (환불 자동 대응)

---

## 알려진 한계 / TODO

- **AuthBloc listener 안 emit lint 회피**: Phase 1 에서 `// ignore: invalid_use_of_visible_for_testing_member` 2줄. 깔끔한 처리는 stream → 이벤트 변환 → add 패턴이지만 보류
- **`account_info_page.dart` 레거시**: 디자인 토큰 미사용 (`AppTextStyles` / `colorScheme` 직접), `AppLocale.korea` 하드코딩 line 17. Phase 4 에서 `goToPremium` 진입점 교체 시 같이 정리
- **익명 → 로그인 마이그레이션**: 비로그인 사용자가 로그인할 때 로컬 sqflite 데이터를 어떻게 다룰지 결정 안 됨 (현재 그대로 유지). 클라우드 동기화는 별개
- **Apple deleteAccount reauth**: `requires-recent-login` 시 `authReauthRequiredSentinel` emit. UI 가 sentinel 받아 reauthenticate 다이얼로그 띄우는 로직 미구현 (Phase 4 또는 별도)
- **`account_info_page.dart`** 비로그인 redirect 가 `WidgetsBinding.addPostFrameCallback` 안에서 `context.go('/login')` — returnTo 미전달. Phase 4 에서 `state.extra: '/account-info'` 로 교체
