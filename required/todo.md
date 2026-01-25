1. 재료 일괄 등록 기능 
2. 2. 만들어진 레시피는 공유기능 
3. 3. 광고 입력 배너 , 전면 광고, 

# 디자인 개편 및 테마 시스템 기획 (Design Revamp Plan)

## 1. 디자인 철학: "Clean & Professional"
- **Minimalism**: 불필요한 장식 요소 제거, 컨텐츠(텍스트, 음식 사진) 중심.
- **Consistency**: 통일된 코너 라운딩(Radius), 그림자(Shadow), 여백(Spacing).
- **Functionality**: 요리 중에도 쉽게 볼 수 있는 높은 가독성 (High Contrast).

## 2. 색상 시스템 (Color System)
사용자가 기분이나 취향에 따라 선택할 수 있는 4가지 테마를 제공합니다.

### A. Wonkka Signature (기존 계승 & 보정)
- **Concept**: 신뢰감 있는 전문성
- **Primary**: Deep Navy (#1A237E)
- **Accent**: Burnt Orange (#E65100)
- **Background**: Pure White / Dark Grey

### B. Minimalist Mono (심플/모던)
- **Concept**: 가장 깔끔하고 질리지 않는 스타일
- **Primary**: Matte Black (#212121)
- **Accent**: Dark Grey (#757575)
- **Background**: Soft White (#FAFAFA) / True Black

### C. Nature Green (편안함/건강)
- **Concept**: 신선한 식재료와 건강함
- **Primary**: Forest Green (#2E7D32)
- **Accent**: Sage (#A5D6A7)
- **Background**: Beige White (#FFFBFA) / Deep Moss

### D. Ocean Blue (청량함)
- **Concept**: 시원하고 깨끗한 주방
- **Primary**: Royal Blue (#1565C0)
- **Accent**: Sky Blue (#90CAF9)
- **Background**: Cool White (#F0F4F8) / Deep Sea

## 3. 다크 모드 전략 (Dark Mode Strategy)
- 모든 테마는 라이트/다크 모드를 완벽 지원합니다.
- 배경색은 단순히 검정(#000000)이 아닌, 눈이 편안한 **Dark Grey (#121212)** 계열 사용.
- 텍스트는 **Off-White (#EEEEEE)**를 사용하여 눈부심 방지.
- 카드는 배경보다 한 톤 밝은 색상(#1E1E1E)으로 구분감(Elevation) 표현.

## 4. UI 컴포넌트 개선안 (Component Cleanup)
- **Card**: 그림자(Shadow)를 최소화하고, 얇은 테두리(Border)나 배경색 차이로 구분하는 Flat 디자인 지향.
- **Button**: 꽉 찬 버튼(Filled)과 선 버튼(Outlined)의 위계를 명확히 하여 화면 복잡도 감소.
- **Typography**: 헤드라인과 본문의 크기 대비를 키워 정보의 구조를 한눈에 파악하도록 개선.