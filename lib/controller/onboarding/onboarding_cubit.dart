import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_state.dart';
part 'onboarding_event.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  static const String _prefsKey = 'onboarding_completed';

  OnboardingCubit() : super(OnboardingLoading()) {
    _checkOnboardingStatus();
  }

  /// 온보딩 상태 확인
  Future<void> _checkOnboardingStatus() async {
    try {
      // SharedPreferences가 완전히 초기화될 때까지 잠시 대기
      await Future.delayed(const Duration(milliseconds: 100));

      final prefs = await SharedPreferences.getInstance();
      final isCompleted = prefs.getBool(_prefsKey) ?? false;

      if (isCompleted) {
        emit(OnboardingCompleted());
      } else {
        emit(OnboardingNotCompleted());
      }
    } catch (e) {
      emit(OnboardingError('온보딩 상태 확인 중 오류가 발생했습니다: $e'));
    }
  }

  /// 온보딩 완료 처리
  Future<void> completeOnboarding() async {
    try {
      emit(OnboardingLoading());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);

      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError('온보딩 완료 처리 중 오류가 발생했습니다: $e'));
    }
  }

  /// 온보딩 재설정 (테스트용)
  Future<void> resetOnboarding() async {
    try {
      emit(OnboardingLoading());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, false);

      emit(OnboardingNotCompleted());
    } catch (e) {
      emit(OnboardingError('온보딩 재설정 중 오류가 발생했습니다: $e'));
    }
  }

  /// 온보딩 상태 새로고침
  Future<void> refreshOnboardingStatus() async {
    await _checkOnboardingStatus();
  }
}
