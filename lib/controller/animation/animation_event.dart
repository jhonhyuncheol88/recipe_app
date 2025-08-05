import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import '../../../model/ingredient.dart';

/// 재료 애니메이션 이벤트
abstract class AnimationEvent extends Equatable {
  const AnimationEvent();

  @override
  List<Object?> get props => [];
}

/// 재료 추가 애니메이션 시작
class StartIngredientAnimation extends AnimationEvent {
  final Ingredient ingredient;
  final Offset? initialPosition;
  final double? initialVelocity;

  const StartIngredientAnimation({
    required this.ingredient,
    this.initialPosition,
    this.initialVelocity,
  });

  @override
  List<Object?> get props => [ingredient, initialPosition, initialVelocity];
}

/// 재료 제거 애니메이션 시작
class RemoveIngredientAnimation extends AnimationEvent {
  final String ingredientId;

  const RemoveIngredientAnimation({required this.ingredientId});

  @override
  List<Object?> get props => [ingredientId];
}

/// 모든 재료 애니메이션 초기화
class ResetAnimation extends AnimationEvent {
  const ResetAnimation();
}

/// 화면 흔들기 감지
class ShakeDetected extends AnimationEvent {
  final double intensity;

  const ShakeDetected({required this.intensity});

  @override
  List<Object?> get props => [intensity];
}

/// 애니메이션 일시정지
class PauseAnimation extends AnimationEvent {
  const PauseAnimation();
}

/// 애니메이션 재개
class ResumeAnimation extends AnimationEvent {
  const ResumeAnimation();
}

/// 애니메이션 속도 변경
class ChangeAnimationSpeed extends AnimationEvent {
  final double speed;

  const ChangeAnimationSpeed({required this.speed});

  @override
  List<Object?> get props => [speed];
}

/// 재료 볼 터치
class IngredientBallTapped extends AnimationEvent {
  final String ingredientId;

  const IngredientBallTapped({required this.ingredientId});

  @override
  List<Object?> get props => [ingredientId];
}

/// 재료 볼 길게 누름
class IngredientBallLongPressed extends AnimationEvent {
  final String ingredientId;

  const IngredientBallLongPressed({required this.ingredientId});

  @override
  List<Object?> get props => [ingredientId];
}

/// 물리 엔진 업데이트
class UpdatePhysics extends AnimationEvent {
  final double deltaTime;

  const UpdatePhysics({required this.deltaTime});

  @override
  List<Object?> get props => [deltaTime];
}

/// 애니메이션 설정 변경
class UpdateAnimationSettings extends AnimationEvent {
  final bool enableShakeDetection;
  final bool enablePhysics;
  final bool enableSound;

  const UpdateAnimationSettings({
    required this.enableShakeDetection,
    required this.enablePhysics,
    required this.enableSound,
  });

  @override
  List<Object?> get props => [enableShakeDetection, enablePhysics, enableSound];
}
