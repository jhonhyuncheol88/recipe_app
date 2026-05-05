---
name: wonkka_expert
description: Expert assistant for developing 'Wonkka' (원까), an AI-based restaurant cost calculator Flutter app. Covers architecture, BLoC patterns, multilingual support, theme system, SQLite, Firebase, and AI integration.
---

# Wonkka (원까) Project Skill

AI 기반 레스토랑 원가 계산 앱 '원까' 개발을 위한 종합 어시스턴트입니다.

---

## 앱 개요

- **앱 이름**: 원까 (Wonkka)
- **대상**: 식당 경영자 (레시피 원가, 재료 관리, 유통기한, OCR 영수증 스캔)
- **버전**: 1.0.16+38 / Dart SDK ^3.7.0
- **플랫폼**: Flutter (iOS, Android)
- **지원 언어**: 한국어, 일본어, 중국어, 영어, 독일어, 베트남어 (6개)

---

## 아키텍처: Clean Architecture + BLoC

### 3계층 구조

```
Presentation (UI + BLoC/Cubit)
    ↓ only
Domain (Entities, Repository 인터페이스, UseCases) — 외부 의존성 없음
    ↓ only
Data (Repository 구현, SQLite, Firebase, AI API)
```

### 디렉터리 구조
```
lib/
├── controller/        # 기능별 Cubit/Bloc
├── data/              # Repository 구현, 모델, DB
├── domain/            # 엔티티, 추상 인터페이스
├── model/             # 데이터 모델
├── screen/            # UI (pages/, widget/)
├── service/           # 도메인 서비스
├── router/            # GoRouter 네비게이션
├── theme/             # 테마 시스템
└── util/              # AppStrings, 포매터 등
```

---

## BLoC/Cubit 패턴

### Cubit 구조 템플릿
```dart
class FeatureCubit extends Cubit<FeatureState> {
  final FeatureRepository _repository;
  FeatureCubit(this._repository) : super(FeatureInitial());

  Future<void> load() async {
    emit(FeatureLoading());
    try {
      final data = await _repository.getAll();
      emit(data.isEmpty ? FeatureEmpty() : FeatureLoaded(data));
    } catch (e) {
      emit(FeatureError(e.toString()));
    }
  }
}
```

### State 구조 (Equatable 필수)
```dart
abstract class FeatureState extends Equatable {
  @override List<Object?> get props => [];
}
class FeatureInitial extends FeatureState {}
class FeatureLoading extends FeatureState {}
class FeatureLoaded extends FeatureState {
  final List<Item> items;
  const FeatureLoaded(this.items);
  @override List<Object?> get props => [items];
}
class FeatureEmpty extends FeatureState {}
class FeatureError extends FeatureState {
  final String message;
  const FeatureError(this.message);
  @override List<Object?> get props => [message];
}
```

### UI 패턴
```dart
// 상태 렌더링
BlocBuilder<FeatureCubit, FeatureState>(builder: (context, state) {
  return switch (state) {
    FeatureLoading() => const CircularProgressIndicator(),
    FeatureLoaded(:final items) => ListView(...),
    FeatureEmpty() => const EmptyState(),
    FeatureError(:final message) => ErrorWidget(message),
    _ => const SizedBox.shrink(),
  };
})

// 부수 효과 (네비게이션, 스낵바)
BlocListener<FeatureCubit, FeatureState>(listener: (context, state) {
  if (state is FeatureSaved) context.pop();
  if (state is FeatureError) ScaffoldMessenger.of(context).showSnackBar(...);
})
```

### 등록된 Cubit/Bloc 목록
| Cubit/Bloc | 역할 |
|---|---|
| `IngredientCubit` | 식재료 CRUD |
| `RecipeCubit` | 레시피 + 원가 계산 |
| `SauceCubit` | 소스 관리 |
| `TagCubit` | 태그 관리 |
| `AuthBloc` | Firebase 인증 |
| `LocaleCubit` | 언어 전환 |
| `ThemeCubit` | 테마 전환 |
| `NumberFormatCubit` | 숫자 형식 |
| `OcrCubit` | 영수증 OCR |
| `ExpiryNotificationCubit` | 유통기한 알림 |
| `OnboardingCubit` | 온보딩 흐름 |
| `EncyclopediaCubit` | 식재료 백과사전 |
| `AdCubit` | AdMob 광고 |

---

## 코딩 규칙

### 필수 규칙
1. **파일 길이**: 단일 .dart 파일 최대 **1,500줄**
2. **색상 투명도**: `withOpacity()` 금지 → `withAlpha()` 사용
   ```dart
   // WRONG: color.withOpacity(0.1)
   // RIGHT: color.withAlpha(25) // 0.1 * 255
   ```
3. **ID 생성**: `const Uuid().v4()` (정수 autoincrement 아님)
4. **로깅**: `developer.log()` (print 금지)
5. **문자열**: `AppStrings.xxx(locale)` 사용 (하드코딩 금지)
6. **SQL**: `whereArgs` 파라미터 사용 (SQL 인젝션 방지)
7. **색상**: `Theme.of(context).colorScheme` 또는 `AppColors` 사용

---

## 다국어 지원

```dart
enum AppLocale { ko, ja, zhCN, en, de, vi }

// 문자열 접근 패턴
final locale = context.read<LocaleCubit>().state.locale;
Text(AppStrings.getTitle(locale))

// 새 도메인 문자열 추가 위치
// lib/util/app_strings/app_strings_<domain>.dart
```

---

## 테마 시스템

```dart
enum AppThemeType {
  wonkkaSignature, // 기본 — soft purple-blue
  minimalistMono,  // 블랙/그레이
  natureGreen,     // 포레스트 그린
  oceanBlue,       // 스카이 블루
}

// 테마 색상 접근
Theme.of(context).colorScheme.primary
// 하드코딩 금지: Color(0xFF1A237E) ← NEVER (AppColors 정의 파일 제외)
```

---

## 데이터베이스: SQLite (sqflite)

### 핵심 테이블
```
Ingredients  → id(UUID), name, purchase_price, purchase_amount, purchase_unit_id, expiry_date
Units        → id, name, type(weight/volume/count), base_unit_id, conversion_factor
Recipes      → id, name, total_cost, output_amount, output_unit
RecipeIngredients → recipe_id, ingredient_id, amount, unit_id
Sauces       → id, name, total_weight, total_cost
SauceIngredients  → sauce_id, ingredient_id, amount, unit_id
RecipeSauces → recipe_id, sauce_id, amount, unit_id
```

### 원가 계산 공식
```
g당 가격 = purchase_price / (purchase_amount × conversion_factor)
재료 원가 = g당 가격 × (사용량 × 변환계수)
소스 원가 = 소스 g당 가격 × (사용량 × 변환계수)
레시피 총원가 = Σ재료 원가 + Σ소스 원가
추천 판매가 = 총원가 / (목표원가율 / 100)  // 기본 35%
```

---

## 기능별 핵심 서비스

| 서비스 | 역할 |
|---|---|
| `RecipeCostService` | 레시피 총원가 계산 |
| `SauceCostService` | 소스 원가 계산 |
| `SauceExpiryService` | 소스 유통기한 추적 |
| `NotificationService` | 로컬 알림 (3일 전, 1일 전, 당일) |
| `EncyclopediaService` | 식재료 백과사전 데이터 |
| `AiSalesAnalysisService` | Gemini AI 판매가 분석 |
| `InAppReviewService` | 앱 리뷰 요청 (3회 실행 후) |

---

## AI 기능

### Gemini API (레시피 생성)
```dart
// flutter_gemini 패키지
// JSON 구조화 응답 강제 프롬프트 사용
// API 키: .env → flutter_dotenv
```

### OCR (영수증 스캔)
```dart
// google_mlkit_text_recognition
// Human-in-the-loop: 결과는 반드시 사용자 확인 단계 거침
// OcrCubit 통해 상태 관리
```

---

## 유통기한 관리

```dart
// 4단계 상태 (색상 규칙 준수)
정상: 7일+  → 녹색
경고: 3-7일 → 노란색
위험: 1-3일 → 주황색
만료: 0일-  → 빨간색
```

---

## 네비게이션

```dart
// GoRouter 전용 (lib/router/app_router.dart)
context.go('/ingredient');
context.push('/recipe/$recipeId');
context.pop();
```

---

## 광고 (AdMob)

- **Android 전용**: `Platform.isAndroid` 확인 필수
- `AdCubit`으로 상태 관리
- 광고 실패 시 앱 기능 유지 (graceful degradation)

---

## 금지 패턴

```dart
// UI에서 직접 DB 접근 금지
await DatabaseHelper.instance.database; // UI ← NEVER

// Cubit에서 BuildContext 사용 금지
void action(BuildContext ctx) {} // NEVER

// print 금지
print('debug'); // → developer.log 사용

// withOpacity 금지
color.withOpacity(0.5); // → withAlpha(128)

// 문자열 하드코딩 금지
Text('재료 추가'); // → AppStrings 사용

// 색상 하드코딩 금지 (AppColors 파일 제외)
Color(0xFF1A237E); // → Theme.of(context).colorScheme.primary
```

---

## 일일 작업 리뷰

중요한 구현 완료 후, `reviews/YYYY-MM-DD_review.md`에 기록:
- 완료된 작업 요약
- 코드 변경 개요
- 핵심 설계 결정
- 챌린지 및 후속 TODO

---

## 설계 문서 참조

| 문서 | 내용 |
|---|---|
| `required/new_required.md` | 핵심 아키텍처 및 구현 가이드 |
| `required/recipe.md` | 레시피 도메인 + 소스 모듈 설계 |
| `required/auth.md` | Firebase 인증 시스템 |
| `required/onboarding.md` | 온보딩 플로우 (4화면) |
| `required/ocr.md` | OCR 영수증 스캔 스펙 |
| `required/todo.md` | 기능 로드맵 (디자인, 색상 시스템) |
| `UPDATE_NEWS.md` | 버전별 변경 이력 (6개 언어) |
