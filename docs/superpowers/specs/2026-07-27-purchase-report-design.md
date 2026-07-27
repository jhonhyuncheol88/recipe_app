# 구매 리포트 설계

날짜: 2026-07-27
상태: 사용자 승인됨
선행: 재고조사 기능 (2026-07-27-inventory-design.md) — `inventory_transactions` 테이블 재사용, 스키마 변경 없음

## 목적

구매 기록을 일/월/연 단위로 리포트 탭에서 집계해 보여주고, 재고 탭의 "오늘 구매" 카드에서
오늘 내역을 간단히 확인한 뒤 리포트로 자연스럽게 유도한다.

## 사용자 결정

| 항목 | 결정 |
|---|---|
| 리포트 형태 | 리포트 페이지에 **독립 "구매 지출" 카드** + 카드 내 [일\|월\|연] 자체 토글 (기존 기간 세그먼트와 무관) |
| 유도 흐름 | 재고 탭 "오늘 구매" 카드 탭 → 오늘 구매 내역 바텀시트(품목/수량/금액/합계) → 시트 하단 [기간별 리포트 보기] → 리포트 탭 전환 |
| 변동 건수 표시 | 요약 카드에서 제거 (완료: ee65d2c) |
| 스낵바 | 추가하지 않음 (전역 정책: 실패 알림만) |

## 구성

### 1. InventoryRepository 확장
```dart
enum PurchasePeriod { daily, monthly, yearly } // lib/model/purchase_period.dart

Future<List<InventoryTransaction>> getTodayPurchases(); // 오늘 type='purchase', 시간순
Future<List<({String label, double total})>> getPurchaseTotals(PurchasePeriod period);
// daily: 최근 30일, substr(created_at,1,10) 그룹 / monthly: 최근 12개월, substr 1,7 / yearly: 전체, substr 1,4
// label 오름차순 정렬, 구매 없던 구간은 행 없음 (차트에서 0 처리 안 함 — 있는 데이터만 막대)
```
ffi 단위 테스트: 오늘 내역 조회, 일/월 그룹 합산 정확성.

### 2. 오늘 구매 내역 시트 (`lib/screen/pages/inventory/today_purchases_sheet.dart`)
- `_SummaryCard` 를 탭 가능하게 (InkWell) → `showTodayPurchasesSheet(context, locale)`
- 목록: 재료명(ingredients 맵 조인, 삭제된 재료는 이름 미상 처리) / 수량+단위 / 금액, 하단 합계
- 빈 상태: "오늘 구매 내역이 없습니다"
- 하단 버튼 [기간별 리포트 보기] → `HomePage.tabRequest.value = 3` + 시트 닫기

### 3. 탭 전환 장치 (`app_router.dart` HomePage)
```dart
static final ValueNotifier<int?> tabRequest = ValueNotifier<int?>(null);
// _HomePageState: initState 에서 listen → 값 있으면 setState(_currentIndex = v) + null 복원, dispose 에서 제거
```

### 4. 리포트 "구매 지출" 카드 (`lib/screen/pages/report/purchase_report_card.dart`)
- `PurchaseReportCubit` (카드 전용, ReportPage 로컬 BlocProvider): `load(PurchasePeriod)` → totals + 기간 합계
- 카드 UI: 헤더(제목 + 기간 합계) / [일|월|연] 토글 칩 / fl_chart BarChart
  - 일: 최근 30일 (라벨 일부만 표시), 월: 12개월, 연: 연도별
- 빈 상태: "재고 탭에서 구매를 기록해보세요" (역방향 유도)
- ReportPage `_buildLoadedBody` 마지막에 카드 삽입 — 기존 리포트 상태와 무관하게 항상 표시

### 5. i18n (6로케일, app_strings_inventory.dart 에 추가)
getPurchaseReportTitle(구매 지출), getPurchaseDaily(일)/Monthly(월)/Yearly(연),
getTodayPurchasesTitle(오늘 구매 내역), getViewPurchaseReport(기간별 리포트 보기),
getTotalAmount(합계), getNoTodayPurchases(오늘 구매 내역이 없습니다),
getNoPurchaseData(재고 탭에서 구매를 기록해보세요)

## 검증 기준
- `flutter analyze` 신규 에러 0, 기존+신규 테스트 전체 PASS
- 수동: 구매 기록 → 요약 카드 탭 → 시트 확인 → 리포트 이동 → 카드 일/월/연 전환
