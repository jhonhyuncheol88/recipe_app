# Handoff — Auth Stabilization (2026-05-08 진행 중)

iOS 시뮬레이터에서 Google 로그인이 동작하지 않는 사용자 보고를 시작점으로
시작된 라운드. Google 측은 패키지 업그레이드까지 진행, Apple 측은 새로
드러난 Firebase 자격증명 거절 이슈가 미해결 상태.

직전 라운드: `history-2026-05-07.md` (iOS Google 로그인 picker 강제 — 그
구현이 시뮬레이터에서 백지 페이지 문제를 일으킨 것이 이번 라운드의
시작점이다).

---

## 1. iOS Google 로그인 — `signInWithProvider` 분기 제거

### 동기
- 직전 커밋 `8e3be76` 가 iOS picker 강제를 위해 `_firebaseAuth.signInWithProvider(GoogleAuthProvider)` + `prompt=select_account` 를 사용.
- 이 흐름은 in-app 웹뷰에서 `https://{project}.firebaseapp.com/__/auth/handler` 로 redirect 하는데, **iOS 시뮬레이터에서 그 페이지가 백지로 뜨는 이슈** 발생.
- picker 강제 효과는 있지만 시뮬레이터 호환성이 무너졌다.

### 변경
- **MODIFY** `lib/data/auth_repository.dart`
  - iOS 분기 (`if (!kIsWeb && Platform.isIOS) { signInWithProvider(...) }`) 전체 제거.
  - Android/iOS 공통으로 네이티브 `_googleSignIn.signOut()` → `_googleSignIn.signIn()` 흐름으로 통합.
  - picker 강제 효과는 사전 `signOut()` 으로 GIDSignIn 캐시를 비워서 유지. iOS GIDSignIn 네이티브 SDK 는 자체 토큰을 관리하므로 Safari 쿠키 공유 이슈에 영향을 받지 않음.
  - `dart:io Platform`, `package:flutter/foundation.dart kIsWeb` import 제거.

### 결과
- `flutter analyze` 신규 에러 0.
- 그러나 후속 검증에서 시뮬레이터에 띄운 결과는 **여전히 백지** 였다 (URL 바엔 `accounts.google.com` 이 정상 표시되지만 페이지 본문이 비어있음). 이 시점에서 v6.2.2 + iOS 17/18 시뮬레이터 + ASWebAuthenticationSession 조합 자체 의심으로 전환.

---

## 2. `google_sign_in` v6 → v7 업그레이드

### 동기
- 시뮬레이터 Safari 에서 `accounts.google.com` 직접 접속은 정상 동작 → 시뮬레이터 자체 네트워크/렌더링 문제는 아님.
- Bundle ID, URL scheme, AppDelegate URL callback handler 모두 정상.
- 즉 `google_sign_in 6.x` 의 iOS 구현 (ASWebAuthenticationSession 사용) 측 호환성 이슈가 가장 유력.
- 사용자가 다른 프로젝트에서 v7 (`GoogleSignIn.instance` / `initialize()` / `authenticate()`) 사용 중인 코드를 공유했고, 그 프로젝트는 정상 동작.

### 변경
- **MODIFY** `pubspec.yaml`
  - `google_sign_in: ^6.2.2` → `^7.2.0`
  - 코멘트 갱신: 과거의 "7.x → 6.x 다운그레이드" 코멘트는 시뮬레이터 백지 회피 사유로 다시 v7 채택을 명시.
- **MODIFY** `lib/data/auth_repository.dart` — v7 API 마이그레이션
  - `GoogleSignIn(...)` constructor 제거 → `GoogleSignIn.instance` 싱글톤
  - 첫 호출 시 `initialize(serverClientId: _googleWebClientId)` 한 번만 실행 (`_ensureGoogleSignInInitialized()` 가드, `_googleSignInInitialized` flag).
  - `signIn()` (nullable) → `authenticate(scopeHint: _googleScopes)` (interactive, throws on cancel).
  - 취소 처리: `on GoogleSignInException catch (e) { if (e.code == GoogleSignInExceptionCode.canceled) throw const AuthCancelledException(); rethrow; }`
  - `accessToken` 은 v7 에서 `account.authentication` 에 더 이상 포함되지 않음 → `account.authorizationClient.authorizationForScopes(_googleScopes)` 로 별도 획득.
  - Firestore users 문서 생성, Apple 로그인, `signOut`, `deleteAccount` 의 외부 API (publically called by `AuthBloc`) 는 그대로 유지.
- **POD UPDATE** `ios/`
  - `cd ios && rm -rf Pods Podfile.lock && pod install`
  - `GoogleSignIn` iOS SDK: 9.1.0 으로 갱신됨.
- AuthBloc / 호출부 변경 없음 — `AuthRepository.signInWithGoogle()` 의 public signature 동일.

### 검증
- `flutter analyze` 신규 에러 0.
- 시뮬레이터 풀 빌드 (`flutter clean && flutter run`) 시 동작은 **사용자 직접 검증 필요** 상태로 핸드오프됨 (이번 세션 시점에는 빌드 후 결과를 받지 못함).
- 만약 v7 에서도 백지가 재현되면 시뮬레이터 한정 SDK/OS 버그로 분류, 실기기 검증으로 우회 권장.

### 롤백 가이드
- 메모리 `project_google_signin_version_history.md` 참조.
- v7 에서 추가 문제가 생기면 `^7.2.0` → `^6.2.2` 다운그레이드 후 `signIn()` 패턴으로 다시 작성. 단 그 경우 시뮬레이터 백지는 다시 재현될 수 있으므로 검증은 실기기로.

---

## 3. Apple 로그인 — Firebase `signInWithCredential` 거절 (미해결)

### 증상
- `[signInWithApple]` 호출 시 Apple 자체는 통과하나 `_firebaseAuth.signInWithCredential(oauthCredential)` 단계에서 실패.
- 사용자 스크린샷의 스택트레이스:
  ```
  AuthRepository.signInWithApple
    → FirebaseAuth.signInWithCredential
      → MethodChannelFirebaseAuth.signInWithCredential
        → ges.pigeon.dart:1103
  ```
- 정확한 `FirebaseAuthException` 코드는 스크린샷에서 잘려 있어 확인 못 함.

### 점검 완료한 항목
- `ios/Runner/RunnerProfile.entitlements` 에 `com.apple.developer.applesignin = Default` 등록되어 있음 → Sign in with Apple capability 활성.
- `Runner.xcodeproj/project.pbxproj` 의 Debug/Release/Profile 모두 같은 entitlements 파일 가리킴 → 시뮬레이터 빌드도 capability 적용.
- `auth_repository.dart` 의 Apple 흐름 자체 (`SignInWithApple.getAppleIDCredential` + nonce sha256 + `OAuthProvider('apple.com').credential(idToken, rawNonce)`) 는 표준 패턴, 코드 측 결함은 발견 못 함.

### 다음 단계 (다음 세션이 받아야 할 것)
1. **사용자에게 정확한 `FirebaseAuthException` 코드 받기.** 가장 흔한 케이스:

   | 코드 | 원인 | 조치 |
   |---|---|---|
   | `invalid-credential` | 시뮬레이터에 iCloud 미로그인 / nonce mismatch / 토큰 만료 | 시뮬레이터 Settings → Sign in to your iPhone 으로 Apple ID 로그인 |
   | `operation-not-allowed` | Firebase Console 에서 Apple provider 비활성 | Firebase Console → Authentication → Sign-in method → Apple 활성화 + Service ID 등록 |
   | `account-exists-with-different-credential` | 같은 이메일이 다른 provider 로 이미 가입됨 | UX 처리 필요 |
   | `network-request-failed` | 네트워크 | 시뮬레이터 네트워크 점검 |

2. **시뮬레이터의 iCloud 로그인 상태 확인** (사용자 작업) — 이번 세션의 1순위 가설.
3. **Firebase Console 의 Apple provider 활성/Service ID 등록 상태 확인** (사용자 작업) — Firebase Console 접근 권한이 필요해 코드만으로 확인 불가.

---

## 4. 설정 페이지의 로그인/프리미엄 위젯 일시 주석 처리

### 동기
- Auth 흐름 안정화될 때까지 사용자 노출을 막아두기 위함. 사용자 명시적 요청.

### 변경
- **MODIFY** `lib/screen/pages/settings_page.dart`
  - `body` 의 `_PremiumHeroBanner`, `_UserProfileCard`, 사이의 `SizedBox(height: AppSpacing.s24)` 3줄 주석 처리. TODO 코멘트로 사유 표기.
  - 두 위젯 클래스 정의 위에 `// 현재 settings_page 본문에서 일시 주석 처리됨 — 추후 재활성화 예정.` + `// ignore: unused_element` 추가. 어노테이션만 지우고 본문 주석을 풀면 즉시 복원 가능.

### 결과
- `flutter analyze` 신규 warning/error 0. 설정 페이지에는 알림 / 표시 / 데이터 / 기타 섹션만 노출.

---

## 핸드오프 요약

| 항목 | 상태 | 다음 작업 |
|---|---|---|
| iOS Google 로그인 v7 마이그레이션 | 코드/Pods 적용 완료 | 시뮬레이터 풀 빌드 후 결과 확인 — 정상이면 종료, 백지 재현되면 실기기 검증으로 분기 |
| Apple 로그인 `signInWithCredential` 거절 | 원인 미확정 | 정확한 `FirebaseAuthException` 코드 수집 → iCloud 로그인 / Firebase Console Apple provider 점검 |
| 설정 페이지 로그인/프리미엄 위젯 노출 차단 | 일시 주석 처리 완료 | 위 두 항목 안정화 후 주석 풀고 재활성화 |
| 외부 작업 (사용자 책임) | — | 시뮬레이터 iCloud 로그인, Firebase Console Apple provider 활성/Service ID 등록 |

이 라운드 완전 종료 후엔 `history-2026-05-08.md` 로 이관, CLAUDE.md 워크스트림 표 갱신.
