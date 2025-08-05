import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/ingredient.dart';
import 'animation_event.dart';
import 'animation_state.dart';

/// 재료 애니메이션 Cubit
class AnimationCubit extends Cubit<AnimationState> {
  Timer? _physicsTimer;
  final Map<String, AnimatedIngredient> _animatedIngredients = {};
  AnimationSettings _settings = const AnimationSettings();

  AnimationCubit() : super(const AnimationInitial());

  @override
  Future<void> close() {
    _physicsTimer?.cancel();
    return super.close();
  }

  /// 재료 애니메이션 시작
  void startIngredientAnimation(
    Ingredient ingredient, {
    double? initialVelocity,
    double? positionX,
    double? positionY,
  }) {
    final animationId =
        '${ingredient.id}_${DateTime.now().millisecondsSinceEpoch}';

    final animatedIngredient = AnimatedIngredient(
      ingredient: ingredient,
      animationId: animationId,
      isAnimating: true,
      velocity: initialVelocity ?? 100.0,
      positionX: positionX ?? Random().nextDouble() * 300,
      positionY: positionY ?? -100.0,
    );

    _animatedIngredients[animationId] = animatedIngredient;

    if (state is AnimationRunning) {
      final currentState = state as AnimationRunning;
      emit(
        currentState.copyWith(
          animatedIngredients: _animatedIngredients.values.toList(),
        ),
      );
    } else {
      emit(
        AnimationRunning(
          animatedIngredients: _animatedIngredients.values.toList(),
          enableShakeDetection: _settings.enableShakeDetection,
          enablePhysics: _settings.enablePhysics,
          enableSound: _settings.enableSound,
          animationSpeed: _settings.animationSpeed,
        ),
      );
    }

    _startPhysicsTimer();
  }

  /// 재료 제거 애니메이션
  void removeIngredientAnimation(String ingredientId) {
    _animatedIngredients.removeWhere(
      (key, value) => value.ingredient.id == ingredientId,
    );

    if (state is AnimationRunning) {
      final currentState = state as AnimationRunning;
      emit(
        currentState.copyWith(
          animatedIngredients: _animatedIngredients.values.toList(),
        ),
      );
    }
  }

  /// 애니메이션 초기화
  void resetAnimation() {
    _animatedIngredients.clear();
    _physicsTimer?.cancel();
    emit(const AnimationInitial());
  }

  /// 애니메이션 일시정지
  void pauseAnimation() {
    if (state is AnimationRunning) {
      final currentState = state as AnimationRunning;
      emit(currentState.copyWith(isPaused: true));
      _physicsTimer?.cancel();
    }
  }

  /// 애니메이션 재개
  void resumeAnimation() {
    if (state is AnimationRunning) {
      final currentState = state as AnimationRunning;
      emit(currentState.copyWith(isPaused: false));
      _startPhysicsTimer();
    }
  }

  /// 애니메이션 속도 변경
  void changeAnimationSpeed(double speed) {
    _settings = _settings.copyWith(animationSpeed: speed);

    if (state is AnimationRunning) {
      final currentState = state as AnimationRunning;
      emit(currentState.copyWith(animationSpeed: speed));
    }
  }

  /// 재료 볼 터치
  void ingredientBallTapped(String ingredientId) {
    // 터치 효과 애니메이션 로직
    final animatedIngredient = _animatedIngredients.values.firstWhere(
      (element) => element.ingredient.id == ingredientId,
    );

    // 터치 시 시각적 피드백 (예: 크기 변화, 색상 변화 등)
    // 실제 구현에서는 더 복잡한 애니메이션 효과를 추가할 수 있습니다
  }

  /// 재료 볼 길게 누름
  void ingredientBallLongPressed(String ingredientId) {
    // 길게 누름 효과 애니메이션 로직
    final animatedIngredient = _animatedIngredients.values.firstWhere(
      (element) => element.ingredient.id == ingredientId,
    );

    // 길게 누름 시 시각적 피드백 (예: 진동, 색상 변화 등)
  }

  /// 애니메이션 설정 업데이트
  void updateAnimationSettings({
    bool? enableShakeDetection,
    bool? enablePhysics,
    bool? enableSound,
    double? animationSpeed,
    double? gravity,
    double? bounceFactor,
    double? friction,
  }) {
    _settings = _settings.copyWith(
      enableShakeDetection: enableShakeDetection,
      enablePhysics: enablePhysics,
      enableSound: enableSound,
      animationSpeed: animationSpeed,
      gravity: gravity,
      bounceFactor: bounceFactor,
      friction: friction,
    );

    if (state is AnimationRunning) {
      final currentState = state as AnimationRunning;
      emit(
        currentState.copyWith(
          enableShakeDetection: _settings.enableShakeDetection,
          enablePhysics: _settings.enablePhysics,
          enableSound: _settings.enableSound,
          animationSpeed: _settings.animationSpeed,
        ),
      );
    }

    // 설정 변경에 따른 타이머 재시작
    if (enablePhysics == true) {
      _startPhysicsTimer();
    } else {
      _physicsTimer?.cancel();
    }

    // 센서 관련 코드 제거됨
  }

  /// 물리 엔진 타이머 시작
  void _startPhysicsTimer() {
    _physicsTimer?.cancel();
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (state is AnimationRunning) {
        final currentState = state as AnimationRunning;
        if (!currentState.isPaused && _settings.enablePhysics) {
          _updatePhysics(1 / 60); // 60 FPS
        }
      }
    });
  }

  /// 물리 엔진 업데이트
  void _updatePhysics(double deltaTime) {
    final updatedIngredients = <String, AnimatedIngredient>{};

    for (final entry in _animatedIngredients.entries) {
      final animatedIngredient = entry.value;

      if (animatedIngredient.isSettled) {
        updatedIngredients[entry.key] = animatedIngredient;
        continue;
      }

      // 중력 적용
      double newVelocity =
          (animatedIngredient.velocity ?? 0) + _settings.gravity * deltaTime;

      double newPositionY =
          (animatedIngredient.positionY ?? 0) + newVelocity * deltaTime;

      // 바닥 충돌 감지 (화면 높이 600으로 가정)
      const groundLevel = 600.0;
      if (newPositionY >= groundLevel) {
        newPositionY = groundLevel;
        newVelocity = -newVelocity * _settings.bounceFactor;

        // 속도가 충분히 작으면 정착
        if (newVelocity.abs() < 10) {
          updatedIngredients[entry.key] = animatedIngredient.copyWith(
            isSettled: true,
            velocity: 0,
            positionY: groundLevel,
          );
          continue;
        }
      }

      // 마찰력 적용
      newVelocity *= _settings.friction;

      updatedIngredients[entry.key] = animatedIngredient.copyWith(
        velocity: newVelocity,
        positionY: newPositionY,
      );
    }

    _animatedIngredients.clear();
    _animatedIngredients.addAll(updatedIngredients);

    if (state is AnimationRunning) {
      final currentState = state as AnimationRunning;
      emit(
        currentState.copyWith(
          animatedIngredients: _animatedIngredients.values.toList(),
        ),
      );
    }
  }

  /// 현재 애니메이션 상태 가져오기
  List<AnimatedIngredient> get currentAnimatedIngredients {
    if (state is AnimationRunning) {
      return (state as AnimationRunning).animatedIngredients;
    }
    return [];
  }

  /// 애니메이션 설정 가져오기
  AnimationSettings get settings => _settings;
}
