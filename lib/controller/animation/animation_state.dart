import 'package:equatable/equatable.dart';
import '../../../model/ingredient.dart';

/// 재료 애니메이션 상태
abstract class AnimationState extends Equatable {
  const AnimationState();

  @override
  List<Object?> get props => [];
}

/// 초기 상태
class AnimationInitial extends AnimationState {
  const AnimationInitial();
}

/// 로딩 상태
class AnimationLoading extends AnimationState {
  const AnimationLoading();
}

/// 애니메이션 실행 중
class AnimationRunning extends AnimationState {
  final List<AnimatedIngredient> animatedIngredients;
  final bool isPaused;
  final double animationSpeed;
  final bool enableShakeDetection;
  final bool enablePhysics;
  final bool enableSound;

  const AnimationRunning({
    required this.animatedIngredients,
    this.isPaused = false,
    this.animationSpeed = 1.0,
    this.enableShakeDetection = true,
    this.enablePhysics = true,
    this.enableSound = false,
  });

  @override
  List<Object?> get props => [
    animatedIngredients,
    isPaused,
    animationSpeed,
    enableShakeDetection,
    enablePhysics,
    enableSound,
  ];

  AnimationRunning copyWith({
    List<AnimatedIngredient>? animatedIngredients,
    bool? isPaused,
    double? animationSpeed,
    bool? enableShakeDetection,
    bool? enablePhysics,
    bool? enableSound,
  }) {
    return AnimationRunning(
      animatedIngredients: animatedIngredients ?? this.animatedIngredients,
      isPaused: isPaused ?? this.isPaused,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      enableShakeDetection: enableShakeDetection ?? this.enableShakeDetection,
      enablePhysics: enablePhysics ?? this.enablePhysics,
      enableSound: enableSound ?? this.enableSound,
    );
  }
}

/// 애니메이션 완료
class AnimationCompleted extends AnimationState {
  final List<AnimatedIngredient> finalIngredients;

  const AnimationCompleted({required this.finalIngredients});

  @override
  List<Object?> get props => [finalIngredients];
}

/// 애니메이션 오류
class AnimationError extends AnimationState {
  final String message;

  const AnimationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// 애니메이션된 재료 정보
class AnimatedIngredient extends Equatable {
  final Ingredient ingredient;
  final String animationId;
  final bool isAnimating;
  final bool isSettled;
  final double? velocity;
  final double? positionX;
  final double? positionY;

  const AnimatedIngredient({
    required this.ingredient,
    required this.animationId,
    this.isAnimating = false,
    this.isSettled = false,
    this.velocity,
    this.positionX,
    this.positionY,
  });

  @override
  List<Object?> get props => [
    ingredient,
    animationId,
    isAnimating,
    isSettled,
    velocity,
    positionX,
    positionY,
  ];

  AnimatedIngredient copyWith({
    Ingredient? ingredient,
    String? animationId,
    bool? isAnimating,
    bool? isSettled,
    double? velocity,
    double? positionX,
    double? positionY,
  }) {
    return AnimatedIngredient(
      ingredient: ingredient ?? this.ingredient,
      animationId: animationId ?? this.animationId,
      isAnimating: isAnimating ?? this.isAnimating,
      isSettled: isSettled ?? this.isSettled,
      velocity: velocity ?? this.velocity,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
    );
  }
}

/// 애니메이션 설정
class AnimationSettings extends Equatable {
  final bool enableShakeDetection;
  final bool enablePhysics;
  final bool enableSound;
  final double animationSpeed;
  final double gravity;
  final double bounceFactor;
  final double friction;

  const AnimationSettings({
    this.enableShakeDetection = true,
    this.enablePhysics = true,
    this.enableSound = false,
    this.animationSpeed = 1.0,
    this.gravity = 500.0,
    this.bounceFactor = 0.7,
    this.friction = 0.98,
  });

  @override
  List<Object?> get props => [
    enableShakeDetection,
    enablePhysics,
    enableSound,
    animationSpeed,
    gravity,
    bounceFactor,
    friction,
  ];

  AnimationSettings copyWith({
    bool? enableShakeDetection,
    bool? enablePhysics,
    bool? enableSound,
    double? animationSpeed,
    double? gravity,
    double? bounceFactor,
    double? friction,
  }) {
    return AnimationSettings(
      enableShakeDetection: enableShakeDetection ?? this.enableShakeDetection,
      enablePhysics: enablePhysics ?? this.enablePhysics,
      enableSound: enableSound ?? this.enableSound,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      gravity: gravity ?? this.gravity,
      bounceFactor: bounceFactor ?? this.bounceFactor,
      friction: friction ?? this.friction,
    );
  }
} 