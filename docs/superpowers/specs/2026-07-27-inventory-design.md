# 재고조사(Inventory) 기능 설계

날짜: 2026-07-27
상태: 사용자 승인됨 (구현 전)

## 목적

매장 재료의 현재 재고를 최소 입력으로 기록·관리한다. 보관 위치(선반장/냉장고/냉동고)별로
재료를 나눠 보여주고, 구매·차감·실사 조정을 이력으로 남기며, 사진 속 텍스트를 기존 OCR
파이프라인으로 분석해 재고 추측→일괄 반영을 돕는다.

**최우선 원칙: 입력 횟수 최소화.** 모든 흐름은 탭 1~2번으로 끝나는 것을 목표로 한다.

## 사용자 결정 사항

| 항목 | 결정 |
|---|---|
| 보관 위치 | 재료당 1개 (선반장 `shelf` / 냉장고 `fridge` / 냉동고 `freezer`) |
| 구매 기록 | 재료별 구매 기록 + 일별 총액 자동 합산 |
| AI 새 재료 | 미리보기에 `[새 재료]` 배지로 제안, 체크 시 마스터 생성 + 재고 등록 동시 처리 |
| AI 분석 방식 | **사진 속 텍스트 기반** — 기존 OCR(ML Kit 텍스트 인식) → Gemini 텍스트 분석 재사용. 비전(이미지 직접 인식) 아님 |
| 탭 위치/순서 | 하단 5탭: 재료 · **재고** · 레시피 · 리포트 · 설정 |
| 데이터 모델 | 하이브리드(C안): 잔량 테이블 + 변동 이력 테이블 |

## 데이터 모델 (DB v8 → v9)

```sql
-- 기존 테이블 컬럼 추가
ALTER TABLE ingredients ADD COLUMN storage_location TEXT;  -- 'shelf'|'fridge'|'freezer'|NULL(미분류)

-- 재료당 현재 잔량 1행
CREATE TABLE inventory_items (
  id TEXT PRIMARY KEY,
  ingredient_id TEXT NOT NULL UNIQUE REFERENCES ingredients(id) ON DELETE CASCADE,
  current_qty REAL NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL
);

-- 변동 이력 (구매/차감/실사조정/AI조정)
CREATE TABLE inventory_transactions (
  id TEXT PRIMARY KEY,
  ingredient_id TEXT NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
  type TEXT NOT NULL,          -- 'purchase' | 'consume' | 'adjust' | 'ai_adjust'
  qty_delta REAL NOT NULL,     -- 변동량 (+/-)
  resulting_qty REAL NOT NULL, -- 변동 후 잔량 (감사/디버그용)
  price REAL,                  -- purchase 일 때 구매 금액
  created_at TEXT NOT NULL
);
```

- 잔량 표시는 `inventory_items` 즉시 조회 (합산 계산 없음).
- `inventory_items` 행은 미리 만들지 않고 **최초 조정/분류/구매 시점에 lazy 생성** (초기 잔량 0).
- 일별 구매 총액은 `inventory_transactions` 에서 `type='purchase'` 를 날짜로 그룹 합산.
- **재고 단위 = 재료 마스터의 구매 단위(`purchaseUnitId`) 그대로. 단위 변환 없음.**
- 재료 삭제 시 재고·이력도 CASCADE 삭제.

## 아키텍처

기존 패턴(Cubit + Repository + Service) 준수:

| 컴포넌트 | 역할 |
|---|---|
| `InventoryRepository` (`lib/data/`) | inventory_items / inventory_transactions CRUD, 일별 구매 합산 쿼리 |
| `InventoryCubit` (`lib/controller/inventory/`) | 위치별 목록 로드, 잔량 조정, 구매 기록, AI 결과 일괄 반영, 오늘 요약 |
| `InventoryGeminiService` (`lib/service/`) | OCR 텍스트 → 재고 추측 프롬프트 분석. `OcrGeminiService` 와 **별도 클래스**, 같은 패턴 (동일 모델 `gemini-3-flash-preview`) |
| `InventoryPage` (`lib/screen/pages/inventory/`) | 재고 탭 메인 |
| `InventoryAiPreviewPage` | AI 스캔 미리보기/반영 |
| `PurchaseRecordSheet` | 구매 기록 바텀시트 |

라우팅: `AppRouter` 에 `/inventory` 및 하위 경로 추가, 하단 탭 IndexedStack 에 2번째로 삽입.
탭 전환 시 `InventoryCubit.load()` 새로고침 (기존 탭들과 동일 패턴).

## UI

### 재고 탭 메인 (`InventoryPage`)

```
[오늘 구매 45,000원 · 변동 7건]        ← 상단 요약 카드 (탭하면 오늘 이력 목록)
[선반장 | 냉장고 | 냉동고 | 미분류]      ← 위치 세그먼트
─────────────────────────────
양파          [-]  2.5 kg  [+]        ← 행마다 인라인 스테퍼
돼지고기      [-]  4 kg    [+]
─────────────────────────────
[📷 AI 재고 스캔]   [🛒 구매 기록]      ← 하단 고정 액션
```

- **단위 인식 스테퍼 스텝**: 개/팩/봉 = ±1, kg/L = ±0.5, g/ml = ±100.
- 수량 영역 탭 → 숫자패드 직접 입력 다이얼로그.
- `[-]` = `consume` 트랜잭션, `[+]`/직접 입력 = `adjust` 트랜잭션. 별도 "재고조사 모드" 없음.
- 변경 즉시 저장 + 실행취소(undo) 스낵바.
- **미분류 세그먼트**: `storage_location IS NULL` 인 기존 재료 나열. 행에서 위치 칩
  (선반장/냉장고/냉동고) 탭 한 번으로 분류 → 재고 연동 완료.
- 재료 추가/수정 페이지에 보관 위치 선택 필드 추가 (선택 사항, 기본 미분류).

### 구매 기록 (`PurchaseRecordSheet`)

재료 검색 선택 → **수량·금액을 재료 마스터의 구매단위량·구매가로 프리필** → 저장.
반복 구매는 "재료 선택 → 저장" 2탭으로 종료. 저장 시:
1. `inventory_items.current_qty += 수량`
2. `purchase` 트랜잭션 기록 (금액 포함)
3. 상단 "오늘 구매 총액" 자동 갱신

### AI 재고 스캔 (`InventoryAiPreviewPage`)

1. 사진 촬영/갤러리 선택 (기존 `image_picker` + 권한 흐름 재사용)
2. 기존 `OcrService`(ML Kit) 로 텍스트 추출
3. `InventoryGeminiService` 가 재고 추측 분석 — 응답 형식은 OCR 서비스와 같은
   파이프(`|`) 구분 텍스트: `재료명 | 추측수량 | 단위 | 비고`
4. 미리보기 체크리스트:
   - 기존 재료 매칭(이름 기반): "양파 — 현재 2.5kg → 추측 4kg"
   - 미등록 재료: `[새 재료]` 배지. 체크 시 재료 마스터 생성 + 재고 등록 동시 수행
5. 확인 → 체크 항목만 일괄 `ai_adjust` 반영
6. 매일 반복 촬영 시 같은 흐름으로 잔량 갱신 (덮어쓰기 조정)

## 에러 처리

- DB 실패: 스낵바 + Cubit 상태 롤백 (기존 IngredientCubit 패턴).
- Gemini 실패/타임아웃: 기존 OCR 에러 상태 패턴 재사용 (`OcrError` 상응).
- AI 매칭 모호(동명 재료 등): 미리보기에서 사용자가 체크 해제로 제외 — 자동 반영 없음.
- 미리보기의 모든 반영은 명시적 확인 후에만 수행 (AI 단독으로 재고를 바꾸지 않음).

## 스코프 제외 (YAGNI)

- 재료당 다중 보관 위치 분리 추적
- 단위 환산 (구매 단위 그대로 사용)
- 재고 부족 알림/발주점 — 추후 별도 라운드
- 보상형 광고의 재고 스캔 흐름 적용 — 추후 결정
- 폐기/사용 사유 구분 — `consume` 단일 유형으로 시작

## 검증 기준

- `flutter analyze` 신규 에러 0
- 6로케일 i18n (`AppStrings`) + 디자인 토큰 (`AppColorTokens`/`AppTypography`/`AppSpacing`/`AppRadius`)
- DB v9 마이그레이션: 기존 사용자 데이터 보존 확인 (v8 → v9 업그레이드 경로)
- 핵심 흐름 수동 검증: 위치 분류 → 스테퍼 조정 → 구매 기록 → 일별 합산 → AI 스캔 반영
