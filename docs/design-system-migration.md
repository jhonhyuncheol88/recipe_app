# 디자인 시스템 마이그레이션 (Wanted DS 토큰화)

> 작업 시작: 2026-05-04
> 작업자: Jeon hyun cheol + Claude
> 참고 디자인: `레시피앱_디자인/project/` (원티드 디자인 시스템 기반 원가계산기 프로토타입)

---

## 1. 목적

기존 4개의 ThemeType (`wonkkaSignature`, `minimalistMono`, `natureGreen`, `oceanBlue`)
구조를 폐기하고, **Wanted Design System 기반 단일 토큰 시스템**으로 통합한다.

- 라이트/다크 두 모드만 지원 (사용자 토글 가능)
- 색·타이포·스페이싱·라운드·그림자 모두 토큰화
- 토큰은 `lib/theme/tokens/` 한 곳에서 관리

## 2. 결정 사항 (Decisions)

| 항목 | 결정 |
|---|---|
| 컬러 시스템 | Wanted 팔레트 (Cool Neutral + Blue primary + AI 보라 액센트) |
| 시맨틱 컬러 | `bg/fg/border/primary/positive/negative/warning/info/ai` |
| 타이포 | Pretendard 9 weight, 18 스타일 (`display1 → caption2`) |
| 스페이싱 | 4px 베이스 (`s2/4/6/8/12/16/20/24/32/40/48/64/96/128`) |
| 라운드 | `r2/4/6/8/10/12/16/20/24/32` + `pill` |
| 그림자 | `shadow1/2/3 + overlay` 4단계 |
| 다크 모드 | 시맨틱 토큰만 오버라이드 (atomic 팔레트는 공유) |
| 기존 ThemeType | **제거** — `ThemeCubit` 은 Brightness 만 관리 |
| 기존 `AppColors` / `AppTextStyles` | **그대로 둠** (위젯 다수가 참조 중, 별도 후속 작업으로 정리) |

## 3. 작업 계획

```
[1] 문서 작성 (이 파일)
[2] Pretendard 폰트 → assets/fonts/ 복사 + pubspec.yaml 등록
[3] lib/theme/tokens/ 5개 파일 생성
    - app_color_tokens.dart
    - app_typography.dart
    - app_spacing.dart
    - app_radius.dart
    - app_shadows.dart
[4] lib/theme/app_theme.dart 재작성 (light + dark)
[5] lib/controller/setting/theme_cubit.dart 단순화 (Brightness 전용)
[6] 호출부 정리
    - lib/main.dart 의 AppTheme.getTheme(themeType, brightness) → AppTheme.light()/dark()
    - lib/screen/pages/settings_page.dart 의 ThemeType 선택 UI 제거
[7] flutter analyze 통과 확인
```

## 4. 진행 로그

### 2026-05-04
- 디자인 분석 완료 (`레시피앱_디자인/project/` — 원티드 DS 기반 iOS 모바일 원가계산기 프로토타입)
- 작업 범위 합의: 토큰 시스템 도입 + 기존 4개 ThemeType 제거 + 라이트/다크 유지
- 마이그레이션 문서 작성
- **Pretendard 폰트 등록**: 9 weight (`assets/fonts/Pretendard-*.ttf`) 복사 + `pubspec.yaml` `fonts:` 섹션 등록
- **토큰 파일 5종 생성** (`lib/theme/tokens/`):
  - `app_color_tokens.dart` — `AppPalette`(atomic Wanted 팔레트) + `AppColorTokens`(시맨틱 light/dark, `ThemeExtension`)
  - `app_typography.dart` — Pretendard 18 스타일 + Material `TextTheme` 매퍼
  - `app_spacing.dart` — 4px 베이스 14단계
  - `app_radius.dart` — 10단계 + pill + `BorderRadius` 헬퍼
  - `app_shadows.dart` — 4단계 (`shadow1/2/3/overlay`)
  - `tokens.dart` — barrel export
- **`app_theme.dart` 재작성**: `AppTheme.light`/`AppTheme.dark` 정적 게터로 라이트/다크 ThemeData 빌드. AppBar/Card/Button(Elevated/Filled/Outlined/Text/Icon)/Input/Switch/Checkbox/Radio/Dialog/BottomSheet/SnackBar/BottomNav/NavigationBar/TabBar/ListTile/Divider/FAB/Chip/ProgressIndicator 모두 토큰 기반으로 일관 적용. `extensions: [tokens]` 로 `AppColorTokens.of(context)` 접근 가능.
- **`ThemeCubit` 단순화**: `ThemeType` enum 제거. `Brightness` 만 보관, `toggleBrightness` / `setBrightness` 유지.
- **`main.dart` 수정**: `MaterialApp.router` 가 `theme`/`darkTheme`/`themeMode` 3 가지를 받도록 변경. `themeState.isDark` 로 분기.
- **`settings_page.dart` 수정**: 테마 색상 선택 UI(`SettingsListTile` + `_showThemeDialog`) 제거. 다크 모드 토글만 유지. 사용 안 하게 된 `app_colors.dart` import 제거.
- **`app_colors.dart` 정리**: `getColorScheme(ThemeType, Brightness)` 등 `ThemeType` 의존 메서드 제거. 정적 상수만 유지(레거시 호환용, 점진 제거 예정).
- **검증**: `flutter pub get` 성공, `flutter analyze` 결과 **0 errors** (308 issues 는 모두 기존 코드의 info/warning, 이번 작업과 무관).

### 2026-05-04 (추가) — iOS UIScene 마이그레이션
- 런타임 경고: `UIScene lifecycle support will soon be required` (https://flutter.dev/to/uiscene-migration)
- **`ios/Runner/Info.plist` 변경**:
  - 제거: `UIMainStoryboardFile = Main`
  - 추가: `UIApplicationSceneManifest` (`UIApplicationSupportsMultipleScenes = false`, `UISceneDelegateClassName = FlutterSceneDelegate`, `UISceneStoryboardFile = Main`)
  - Flutter 3.38+ 가 빌트인 제공하는 `FlutterSceneDelegate` 를 사용하므로 `SceneDelegate.swift` 신규 작성 불필요
- **`ios/Runner/AppDelegate.swift`**: 변경 없음. 현행 `didFinishLaunchingWithOptions` 의 `GeneratedPluginRegistrant.register(with: self)` + `UNUserNotificationCenter` 델리게이트 셋업은 UIScene 라이프사이클과 호환됨.
- **검증**: `plutil -lint Info.plist` → OK. iOS 디바이스/시뮬레이터에서 `flutter run` 으로 실제 경고가 사라졌는지 확인 필요.
- **호환성**: iOS 13 미만은 UIScene 미지원이지만, 현재 프로젝트의 deployment target 으로 영향 없음 (Flutter 3.41 의 최소 iOS 12 정책상 자동 폴백).

### 2026-05-04 (추가) — CocoaPods Profile xcconfig 누락 수정
- `pod install` 경고: `CocoaPods did not set the base configuration ... please ... include Pods-Runner.profile.xcconfig`
- **원인**: `ios/Flutter/Profile.xcconfig` 파일은 디스크에 존재하지만, **Xcode 프로젝트(`Runner.xcodeproj/project.pbxproj`) 안에 `PBXFileReference` 로 등록돼 있지 않았음**. 그래서 Runner 타겟의 `Profile` 빌드 구성이 잘못된 base config(`Release.xcconfig`)를 가리키고 있었고, 결과적으로 `Pods-Runner.profile.xcconfig` 가 빌드에 포함되지 않음.
- **수정**: `ios/Runner.xcodeproj/project.pbxproj` 직접 편집
  - `Profile.xcconfig` 의 `PBXFileReference` 추가 (ID `9740EEB41CF90195004384FC`)
  - `Flutter` PBXGroup 의 children 에 새 ID 등록
  - Runner 타겟 `Profile` 빌드 구성의 `baseConfigurationReference` 를 `Release.xcconfig` 에서 `Profile.xcconfig` 로 교체
- **검증**: `plutil -lint project.pbxproj` OK, `pod install` 재실행 → 경고 사라짐.

## 5. 사용 가이드 (마이그레이션 후)

### 5.1 ThemeData 접근
```dart
// 색
Theme.of(context).colorScheme.primary       // 0066FF
Theme.of(context).colorScheme.surface       // bg-base

// 텍스트
Theme.of(context).textTheme.titleLarge      // Pretendard 700 22px
```

### 5.2 토큰 직접 사용 (시맨틱 색이 부족할 때)
```dart
import 'package:recipe_app/theme/tokens/app_color_tokens.dart';
import 'package:recipe_app/theme/tokens/app_spacing.dart';

final colors = AppColorTokens.of(context);
Container(
  padding: EdgeInsets.all(AppSpacing.s16),
  color: colors.bgElev1,
  child: Text('...', style: AppTypography.body1),
);
```

### 5.3 다크 모드 토글
```dart
context.read<ThemeCubit>().toggleBrightness();
context.read<ThemeCubit>().setBrightness(Brightness.dark);
```

## 6. 호환성 / 주의

- 기존 `AppColors.X` / `AppTextStyles.X` 정적 상수는 **그대로 동작**한다 (ThemeData 와 무관).
- 후속 작업으로 위젯들을 `Theme.of(context)` 또는 `AppColorTokens.of(context)` 기반으로 점진 이전 권장.
- `ThemeType` enum 은 제거되므로 외부에서 참조하던 `themeCubit.state.themeType` 같은 코드는 전부 컴파일 에러가 난다.
  ↳ 이 마이그레이션에서 모두 정리됨.

## 7. 핸드오프 (Handoff)

### 7.1 다음 세션이 알아야 할 것
- **이 문서가 단일 진실 소스**다. 변경/추가는 항상 여기에 기록.
- 토큰은 `lib/theme/tokens/` 안에서만 정의한다. 다른 곳에 hex 박지 않기.
- Wanted DS 원본 토큰: `레시피앱_디자인/project/ds/colors_and_type.css` (참조용, 빌드에 포함 X)

### 7.2 끝나지 않은 일 / 후속 작업 후보
1. **위젯 단위 마이그레이션**: 현재 `AppColors.expiryDanger` 등을 직접 부르는 위젯들을 `AppColorTokens.of(context).negative` 류로 점진 이전.
2. **AppTextStyles 정리**: Nunito/google_fonts 의존 제거, Pretendard 통일.
3. **다크 모드 컬러 균형**: 디자인 원본의 다크 토큰을 그대로 가져왔으므로, 실제 화면 대비 결과 보고 미세 조정 필요.
4. **공통 위젯 (`app_button.dart` 등) 토큰 이전**: 현재 `AppColors.buttonPrimary` 사용 → `colorScheme.primary` 로 교체.
5. **Wanted DS 의 컴포넌트 패턴 도입**: Badge(soft surface), Card(inset border), Sheet(iOS 곡선) 같은 룰을 공통 위젯으로 추출.

### 7.3 롤백
- 이 마이그레이션은 다음 파일만 손댄다:
  - `lib/theme/app_theme.dart` (재작성)
  - `lib/theme/tokens/*` (신규)
  - `lib/controller/setting/theme_cubit.dart` (단순화)
  - `lib/main.dart` (themeType 제거)
  - `lib/screen/pages/settings_page.dart` (ThemeType 선택 UI 제거)
  - `pubspec.yaml` (Pretendard 폰트 등록)
  - `assets/fonts/Pretendard-*.ttf` (신규)
- `git revert` 한 커밋으로 원복 가능하도록 단일 커밋으로 묶을 것.
