OCR 기반 원가 계산기 앱 설계 문서를 작성해 드릴게요.

-----

## **OCR 기반 원가 계산기 앱 설계 문서**

### **1. 개요**

영수증, 사진 속 식자재 정보를 OCR 기술로 자동 인식하여 원가 계산기에 등록하는 Flutter 앱입니다. **BLoC 패턴**과 **MVC 아키텍처**를 활용하여 유지보수성과 확장성을 높이고, **Local Cubit**을 통해 다국어(한국어, 영어, 중국어, 일본어)를 지원합니다.

### **2. 시스템 아키텍처**

**MVC (Model-View-Controller) 아키텍처**를 기반으로 각 레이어를 분리하여 개발합니다.

  * **Model**: 데이터와 비즈니스 로직을 담당합니다. (예: `Ingredient`, `Receipt` 모델)
  * **View**: 사용자 인터페이스(UI)를 담당합니다. (예: `HomePage`, `CameraPage`)
  * **Controller**: Model과 View 사이의 상호작용을 제어하고, BLoC을 통해 상태를 관리합니다.

**BLoC (Business Logic Component)** 패턴을 사용하여 상태 관리를 효율적으로 처리합니다.

  * **UI (View)**: 이벤트를 BLoC에 전달합니다.
  * **BLoC**: 이벤트를 받아 비즈니스 로직을 처리하고, 새로운 상태를 UI에 전달합니다.
  * **Data Layer (Repository)**: 데이터 소스(API, 로컬 DB 등)와 상호작용합니다.

### **3. 주요 기능 및 화면 설계**

#### **3.1. 화면 흐름**

**메인 화면** -\> **이미지 선택 (카메라/갤러리)** -\> **OCR 인식 및 편집 화면** -\> **원가 계산기 등록**

#### **3.2. 화면별 기능 명세**

  * **메인 화면 (`HomePage`)**

      * 등록된 재료 목록 표시 (재료명, 구매 단위, 구매 가격)
      * OCR 스캔 버튼 (카메라/갤러리 선택 옵션 제공)
      * 언어 변경 설정 버튼

  * **카메라/갤러리 화면 (`CameraPage`, `GalleryPage`)**

      * 카메라를 이용한 영수증 및 이미지 촬영
      * 갤러리에서 이미지 선택

  * **OCR 인식 및 편집 화면 (`OcrResultPage`)**

      * 선택된 이미지 표시
      * OCR 인식 진행 상태 표시 (로딩 인디케이터)
      * 인식된 텍스트를 "재료명", "구매 단위", "구매 가격" 필드에 자동으로 채워 넣기
      * 사용자가 인식 결과를 수정할 수 있는 입력 필드 제공
      * "원가 계산기에 추가" 버튼

### **4. 데이터 모델 (`Model`)**

**`Ingredient` 모델**

```dart
class Ingredient {
  final String name;
  final String unit;
  final double price;

  Ingredient({required this.name, required this.unit, required this.price});
}
```

### **5. 상태 관리 (BLoC)**

#### **5.1. `OcrBloc`**

  * **Events**:
      * `OcrScanStarted(File image)`: OCR 스캔 시작
      * `IngredientAdded(Ingredient ingredient)`: 재료 추가
  * **States**:
      * `OcrInitial`: 초기 상태
      * `OcrLoading`: OCR 스캔 진행 중
      * `OcrSuccess(List<Ingredient> ingredients)`: OCR 스캔 성공 및 결과 반환
      * `OcrFailure(String error)`: OCR 스캔 실패

#### **5.2. `LocaleCubit` (다국어 지원)**

  * **State**: `Locale`
  * **Methods**: `changeLocale(Locale locale)`

### **6. OCR 구현**

**`google_mlkit_text_recognition`** 패키지를 사용하여 텍스트 인식을 구현합니다.

  * `TextRecognizer`를 초기화할 때, `LocaleCubit`의 현재 언어 설정에 따라 `TextRecognitionScript`를 동적으로 변경합니다.

    ```dart
    // 예시 코드
    TextRecognizer getTextRecognizer(Locale locale) {
      switch (locale.languageCode) {
        case 'ko':
          return TextRecognizer(script: TextRecognitionScript.korean);
        case 'ja':
          return TextRecognizer(script: TextRecognitionScript.japanese);
        case 'zh':
          return TextRecognizer(script: TextRecognitionScript.chinese);
        default:
          return TextRecognizer(script: TextRecognitionScript.latin);
      }
    }
    ```

  * 인식된 텍스트(`RecognizedText`)에서 정규식 또는 문자열 분석을 통해 "재료명", "단위", "가격" 정보를 추출합니다.

### **7. 데이터 저장**

인식된 재료 데이터는 **로컬 데이터베이스**(예: `sqflite`, `Hive`)에 저장하여 영구적으로 관리합니다.

### **8. 기술 스택**

  * **언어**: Dart
  * **프레임워크**: Flutter
  * **상태 관리**: flutter\_bloc
  * **OCR**: google\_mlkit\_text\_recognition
  * **이미지 선택**: image\_picker
  * **로컬 DB**: sqflite 또는 Hive
  * **다국어 지원**: intl

이 설계 문서를 바탕으로 개발을 진행하시면 체계적이고 효율적인 앱 개발이 가능할 것입니다. 😊