# 재료 애니메이션 구현을 위한 패키지 분석

## 1. 개요
재료 애니메이션 설계 문서의 기능을 구현하기 위해 필요한 Flutter/Dart 패키지들을 분석하고, 각 패키지의 역할과 대안을 제시합니다.

## 2. 핵심 패키지 분석

### 2.1 애니메이션 및 물리 엔진

#### **flutter_animate** (추천)
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

#### **rflutter_alert** (대안)
```yaml
dependencies:
  rflutter_alert: ^2.0.8
```
- **역할**: 커스텀 애니메이션 알림
- **장점**: 미리 정의된 애니메이션 효과

### 2.2 물리 엔진 및 충돌 감지

#### **flame** (추천)
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

#### **box2d_flame** (Flame 확장)
```yaml
dependencies:
  box2d_flame: ^0.4.0
```
- **역할**: Box2D 물리 엔진 통합
- **장점**: 더 정교한 물리 시뮬레이션

### 2.3 센서 및 기기 인터랙션

#### **sensors_plus** (추천)
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

#### **shake** (대안)
```yaml
dependencies:
  shake: ^2.2.0
```
- **역할**: 전용 흔들기 감지 라이브러리
- **장점**: 간단한 API, 흔들기 감지에 특화

### 2.4 애니메이션 상태 관리

#### **flutter_bloc** (이미 사용 중)
```yaml
dependencies:
  flutter_bloc: ^8.1.4
```
- **역할**: 애니메이션 상태 관리
- **사용 예시**:
```dart
enum BallAnimationState { falling, bouncing, settled, shaking }

class BallAnimationCubit extends Cubit<BallAnimationState> {
  BallAnimationCubit() : super(BallAnimationState.falling);
  
  void startFalling() => emit(BallAnimationState.falling);
  void startBouncing() => emit(BallAnimationState.bouncing);
  void settle() => emit(BallAnimationState.settled);
  void shake() => emit(BallAnimationState.shaking);
}
```

### 2.5 성능 최적화

#### **flutter_staggered_animations** (추천)
```yaml
dependencies:
  flutter_staggered_animations: ^1.1.1
```
- **역할**: 성능 최적화된 애니메이션
- **장점**: 
  - RepaintBoundary 자동 적용
  - 메모리 효율적인 애니메이션

#### **flutter_sequence_animation** (대안)
```yaml
dependencies:
  flutter_sequence_animation: ^3.0.0
```
- **역할**: 복잡한 애니메이션 시퀀스 관리

### 2.6 색상 및 그라데이션

#### **flutter_color** (추천)
```yaml
dependencies:
  flutter_color: ^1.0.0
```
- **역할**: 색상 조작 및 그라데이션
- **장점**: 동적 색상 생성, 색상 변환

### 2.7 터치 인터랙션

#### **flutter_gesture_plugin** (내장)
- **역할**: 드래그, 터치, 제스처 감지
- **사용 예시**:
```dart
GestureDetector(
  onTap: () => showIngredientDetails(),
  onLongPress: () => deleteIngredient(),
  onPanUpdate: (details) => updateBallPosition(details),
  child: IngredientBall(),
)
```

## 3. 패키지 조합 시나리오

### 3.1 기본 구현 (Phase 1)
```yaml
dependencies:
  flutter_animate: ^4.5.0
  sensors_plus: ^4.0.2
  flutter_staggered_animations: ^1.1.1
```

### 3.2 고급 물리 엔진 (Phase 2)
```yaml
dependencies:
  flame: ^1.16.0
  box2d_flame: ^0.4.0
  sensors_plus: ^4.0.2
```

### 3.3 완전한 구현 (Phase 3-4)
```yaml
dependencies:
  flame: ^1.16.0
  sensors_plus: ^4.0.2
  flutter_staggered_animations: ^1.1.1
  flutter_color: ^1.0.0
  shake: ^2.2.0  # 백업 흔들기 감지
```

## 4. 성능 고려사항

### 4.1 메모리 사용량
- **flame**: 게임 엔진으로 메모리 사용량 높음
- **flutter_animate**: 경량화된 애니메이션
- **sensors_plus**: 실시간 센서 데이터로 배터리 소모

### 4.2 배터리 최적화
- 센서 리스너 적절한 해제
- 애니메이션 완료 시 리소스 정리
- 백그라운드에서 센서 비활성화

### 4.3 호환성
- **Android**: 모든 패키지 지원
- **iOS**: sensors_plus 권한 설정 필요
- **Web**: 일부 센서 기능 제한

## 5. 권장 구현 순서

### Phase 1: 기본 애니메이션
1. **flutter_animate** 설치
2. 원형 컨테이너 생성
3. 하늘에서 떨어지는 애니메이션
4. 바운스 효과

### Phase 2: 물리 엔진
1. **flame** 설치
2. 중력 및 마찰력 구현
3. 충돌 감지 시스템

### Phase 3: 인터랙션
1. **sensors_plus** 설치
2. 화면 흔들기 감지
3. 터치 인터랙션

### Phase 4: 최적화
1. **flutter_staggered_animations** 적용
2. 성능 모니터링
3. 메모리 최적화

## 6. 대안 패키지

### 6.1 경량화 옵션
```yaml
dependencies:
  flutter_animate: ^4.5.0  # 기본 애니메이션
  shake: ^2.2.0            # 간단한 흔들기 감지
```

### 6.2 고성능 옵션
```yaml
dependencies:
  flame: ^1.16.0           # 완전한 물리 엔진
  sensors_plus: ^4.0.2     # 정확한 센서 데이터
```

## 7. 결론

재료 애니메이션 구현을 위해서는 **flame**과 **sensors_plus**가 핵심 패키지이며, 성능 최적화를 위해 **flutter_staggered_animations**를 추가로 사용하는 것을 권장합니다. 단계적 구현을 통해 복잡도를 관리하고 사용자 경험을 점진적으로 향상시킬 수 있습니다. 