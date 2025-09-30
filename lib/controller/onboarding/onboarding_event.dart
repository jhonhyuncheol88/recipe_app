part of 'onboarding_cubit.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// 온보딩 완료 이벤트
class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

/// 온보딩 재설정 이벤트
class ResetOnboarding extends OnboardingEvent {
  const ResetOnboarding();
}

/// 온보딩 상태 새로고침 이벤트
class RefreshOnboardingStatus extends OnboardingEvent {
  const RefreshOnboardingStatus();
}
