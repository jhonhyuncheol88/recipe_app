# 재료 애니메이션 설계 문서

## 1. 개요
재료 추가 시 사용자에게 시각적 피드백을 제공하기 위한 인터랙티브 애니메이션 시스템을 설계합니다. 재료가 추가되면 하늘에서 떨어지는 로또 볼 형태의 컨테이너로 표현하여 사용자 경험을 향상시킵니다.

## 2. 핵심 개념

### 2.1 재료 볼 (Ingredient Ball)
- **형태**: 완전한 원형 Container
- **크기**: 고정 크기 (예: 80x80dp)
- **색상**: 좌우 반반 다른 색상
  - 왼쪽: 재료 타입별 메인 컬러
  - 오른쪽: 보조 컬러 (그라데이션 효과)
- **정보 표시**: 볼 표면에 재료명과 가격 정보 오버레이

### 2.2 애니메이션 시퀀스
1. **생성**: 재료 추가 버튼 클릭 시
2. **떨어짐**: 화면 상단에서 시작하여 중력 효과로 자연스럽게 하강
3. **바운스**: 바닥에 닿으면 물리적 바운스 효과
4. **정착**: 최종 위치에서 안정화

## 3. 기술적 구현

### 3.1 물리 엔진 (Physics Engine)
```dart
class IngredientBallPhysics {
  double velocity = 0.0;
  double gravity = 9.8;
  double bounceFactor = 0.7;
  double friction = 0.98;
  
  void updatePosition(double deltaTime) {
    // 중력 적용
    velocity += gravity * deltaTime;
    position.y += velocity * deltaTime;
    
    // 바닥 충돌 감지
    if (position.y >= groundLevel) {
      position.y = groundLevel;
      velocity = -velocity * bounceFactor;
    }
    
    // 마찰력 적용
    velocity *= friction;
  }
}
```

### 3.2 재료 볼 위젯
```dart
class IngredientBall extends StatefulWidget {
  final Ingredient ingredient;
  final AnimationController controller;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                ingredient.primaryColor,
                ingredient.secondaryColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ingredient.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₩${ingredient.price}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### 3.3 화면 흔들기 감지 (Shake Detection)
```dart
class ShakeDetector {
  static const double SHAKE_THRESHOLD = 12.0;
  List<double> _accelerometerValues = [];
  
  void onAccelerometerUpdate(AccelerometerEvent event) {
    _accelerometerValues.add(event.x + event.y + event.z);
    
    if (_accelerometerValues.length > 10) {
      _accelerometerValues.removeAt(0);
    }
    
    // 흔들기 감지
    if (_detectShake()) {
      _onShakeDetected();
    }
  }
  
  bool _detectShake() {
    if (_accelerometerValues.length < 10) return false;
    
    double variance = _calculateVariance(_accelerometerValues);
    return variance > SHAKE_THRESHOLD;
  }
  
  void _onShakeDetected() {
    // 모든 재료 볼에 흔들기 효과 적용
    _applyShakeEffectToAllBalls();
  }
}
```

## 4. 애니메이션 상태 관리

### 4.1 애니메이션 상태
```dart
enum BallAnimationState {
  falling,    // 떨어지는 중
  bouncing,   // 바운스 중
  settled,    // 정착됨
  shaking,    // 흔들기 효과 중
}
```

### 4.2 상태별 애니메이션
- **falling**: 중력 기반 자연스러운 하강
- **bouncing**: 탄성 있는 바운스 효과
- **settled**: 미세한 떨림으로 생동감 표현
- **shaking**: 사용자 흔들기에 반응하는 움직임

## 5. 재료별 색상 시스템

### 5.1 색상 매핑
```dart
class IngredientColorScheme {
  static Map<String, List<Color>> colorMap = {
    '채소': [Colors.green, Colors.lightGreen],
    '육류': [Colors.red, Colors.pink],
    '해산물': [Colors.blue, Colors.lightBlue],
    '곡물': [Colors.orange, Colors.amber],
    '유제품': [Colors.white, Colors.grey],
    '조미료': [Colors.purple, Colors.deepPurple],
  };
}
```

## 6. 성능 최적화

### 6.1 메모리 관리
- 최대 볼 개수 제한 (예: 50개)
- 화면 밖으로 나간 볼 자동 제거
- 애니메이션 완료된 볼의 메모리 해제

### 6.2 렌더링 최적화
- RepaintBoundary 사용으로 불필요한 리페인트 방지
- 애니메이션 프레임 레이트 최적화
- GPU 가속 활용

## 7. 사용자 인터랙션

### 7.1 터치 인터랙션
- 볼 터치 시 상세 정보 표시
- 길게 누르기로 재료 삭제
- 드래그로 볼 위치 조정

### 7.2 흔들기 인터랙션
- 화면 흔들기 시 모든 볼이 함께 움직임
- 흔들기 강도에 따른 움직임 크기 조절
- 흔들기 후 자연스러운 복원 애니메이션

## 8. 구현 우선순위

### Phase 1: 기본 애니메이션
1. 원형 컨테이너 생성
2. 하늘에서 떨어지는 애니메이션
3. 바운스 효과

### Phase 2: 물리 엔진
1. 중력 및 마찰력 구현
2. 충돌 감지 시스템
3. 자연스러운 움직임

### Phase 3: 인터랙션
1. 화면 흔들기 감지
2. 터치 인터랙션
3. 볼 간 상호작용

### Phase 4: 최적화
1. 성능 최적화
2. 메모리 관리
3. 사용자 경험 개선

## 9. 테스트 시나리오

### 9.1 기능 테스트
- 재료 추가 시 애니메이션 정상 작동
- 여러 재료 동시 추가 시 성능
- 화면 흔들기 감지 정확도

### 9.2 사용성 테스트
- 애니메이션 속도 적절성
- 시각적 피드백 만족도
- 인터랙션 직관성

## 10. 결론

이 설계는 재료 추가를 단순한 데이터 입력이 아닌 즐거운 시각적 경험으로 만들어 사용자 참여도를 높이는 것을 목표로 합니다. 물리 기반 애니메이션과 인터랙티브 요소를 통해 앱의 재미와 사용성을 동시에 향상시킬 수 있습니다.

## 11. 필요한 패키지 분석

### 11.1 핵심 패키지

#### **flame** (물리 엔진)
```yaml
dependencies:
  flame: ^1.16.0
```
- **역할**: 2D 게임 엔진, 물리 엔진 포함
- **장점**:
  - 중력, 바운스, 마찰력 등 물리 효과
  - 충돌 감지 시스템
  - 성능 최적화된 렌더링
- **사용 예시**:
```dart
class IngredientBall extends SpriteComponent with HasGameRef {
  Vector2 velocity = Vector2.zero();
  double gravity = 500.0;
  
  @override
  void update(double dt) {
    velocity.y += gravity * dt;
    position += velocity * dt;
    
    // 바닥 충돌 감지
    if (position.y > gameRef.size.y - height) {
      position.y = gameRef.size.y - height;
      velocity.y = -velocity.y * 0.7; // 바운스
    }
  }
}
```

#### **sensors_plus** (화면 흔들기)
```yaml
dependencies:
  sensors_plus: ^4.0.2
```
- **역할**: 가속도계, 자이로스코프 등 센서 데이터
- **장점**:
  - 화면 흔들기 감지
  - 실시간 센서 데이터
- **사용 예시**:
```dart
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  void startListening() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double acceleration = (event.x * event.x + event.y * event.y + event.z * event.z).sqrt();
      if (acceleration > SHAKE_THRESHOLD) {
        onShakeDetected();
      }
    });
  }
}
```

#### **flutter_animate** (고급 애니메이션)
```yaml
dependencies:
  flutter_animate: ^4.5.0
```
- **역할**: 고급 애니메이션 라이브러리
- **장점**: 
  - 복잡한 애니메이션 체이닝 지원
  - 물리 기반 애니메이션 내장
  - 성능 최적화
- **사용 예시**:
```dart
Container().animate()
  .fadeIn(duration: 600.ms)
  .slideY(begin: -1.0, end: 0.0)
  .then()
  .bounce()
```

### 11.2 보조 패키지

#### **flutter_staggered_animations** (성능 최적화)
```yaml
dependencies:
  flutter_staggered_animations: ^1.1.1
```
- **역할**: 성능 최적화된 애니메이션
- **장점**: 
  - RepaintBoundary 자동 적용
  - 메모리 효율적인 애니메이션

#### **shake** (대안 흔들기 감지)
```yaml
dependencies:
  shake: ^2.2.0
```
- **역할**: 전용 흔들기 감지 라이브러리
- **장점**: 간단한 API, 흔들기 감지에 특화

### 11.3 패키지 조합 시나리오

#### **Phase 1: 기본 구현**
```yaml
dependencies:
  flutter_animate: ^4.5.0
  sensors_plus: ^4.0.2
  flutter_staggered_animations: ^1.1.1
```

#### **Phase 2: 고급 물리 엔진**
```yaml
dependencies:
  flame: ^1.16.0
  box2d_flame: ^0.4.0
  sensors_plus: ^4.0.2
```

#### **Phase 3: 완전한 구현**
```yaml
dependencies:
  flame: ^1.16.0
  sensors_plus: ^4.0.2
  flutter_staggered_animations: ^1.1.1
  flutter_color: ^1.0.0
  shake: ^2.2.0  # 백업 흔들기 감지
```

### 11.4 성능 고려사항

#### **메모리 사용량**
- **flame**: 게임 엔진으로 메모리 사용량 높음
- **flutter_animate**: 경량화된 애니메이션
- **sensors_plus**: 실시간 센서 데이터로 배터리 소모

#### **배터리 최적화**
- 센서 리스너 적절한 해제
- 애니메이션 완료 시 리소스 정리
- 백그라운드에서 센서 비활성화

#### **플랫폼 호환성**
- **Android**: 모든 패키지 지원 ✅
- **iOS**: sensors_plus 권한 설정 필요
- **Web**: 일부 센서 기능 제한

### 11.5 권장 구현 순서

#### **Phase 1: 기본 애니메이션**
1. **flutter_animate** 설치
2. 원형 컨테이너 생성
3. 하늘에서 떨어지는 애니메이션
4. 바운스 효과

#### **Phase 2: 물리 엔진**
1. **flame** 설치
2. 중력 및 마찰력 구현
3. 충돌 감지 시스템

#### **Phase 3: 인터랙션**
1. **sensors_plus** 설치
2. 화면 흔들기 감지
3. 터치 인터랙션

#### **Phase 4: 최적화**
1. **flutter_staggered_animations** 적용
2. 성능 모니터링
3. 메모리 최적화

## 12. 최종 결론

재료 애니메이션 구현을 위해서는 **flame**과 **sensors_plus**가 핵심 패키지이며, 성능 최적화를 위해 **flutter_staggered_animations**를 추가로 사용하는 것을 권장합니다. 단계적 구현을 통해 복잡도를 관리하고 사용자 경험을 점진적으로 향상시킬 수 있습니다. 