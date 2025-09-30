part of 'onboarding_cubit.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// 온보딩 초기 상태
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// 온보딩 로딩 상태
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// 온보딩 완료 상태
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// 온보딩 미완료 상태
class OnboardingNotCompleted extends OnboardingState {
  const OnboardingNotCompleted();
}

/// 온보딩 오류 상태
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
