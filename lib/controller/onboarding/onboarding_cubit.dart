import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/ingredient_repository.dart';
import '../../data/recipe_repository.dart';
import '../../data/unit_repository.dart';
import '../../service/initial_data_service.dart';
import 'package:logger/logger.dart';

part 'onboarding_state.dart';
part 'onboarding_event.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  static const String _prefsKey = 'onboarding_completed';
  late final Logger _logger;

  OnboardingCubit() : super(OnboardingLoading()) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    );
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

      // prefs 는 초기 데이터 삽입 후에만 true — 부팅 시퀀스·앱 오픈 광고와 경합 방지
      await _insertInitialDataIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);

      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError('온보딩 완료 처리 중 오류가 발생했습니다: $e'));
    }
  }

  /// 초기 데이터 삽입 (필요한 경우)
  Future<void> _insertInitialDataIfNeeded() async {
    try {
      _logger.i('📦 온보딩 완료 후 초기 데이터 체크 시작');

      // Repository 생성
      final ingredientRepo = IngredientRepository();
      final recipeRepo = RecipeRepository();
      final unitRepo = UnitRepository();

      final initialDataService = InitialDataService(
        ingredientRepository: ingredientRepo,
        recipeRepository: recipeRepo,
        unitRepository: unitRepo,
      );

      // 초기 데이터가 이미 삽입되었는지 확인
      final isInserted = await initialDataService.isInitialDataInserted();

      if (!isInserted) {
        _logger.i('📦 초기 데이터 없음 - 삽입 시작 (언어: ${await _getSelectedLanguage()})');
        await initialDataService.insertInitialData();
        _logger.i('✅ 초기 데이터 삽입 완료');
      } else {
        _logger.i('✅ 초기 데이터 이미 존재');
      }
    } catch (e) {
      _logger.e('⚠️ 초기 데이터 삽입 실패: $e');
      // 실패해도 온보딩 완료는 계속 진행
    }
  }

  /// 선택된 언어 가져오기
  Future<String> _getSelectedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString('app_locale_code') ?? 'ko_KR';
      return localeCode;
    } catch (e) {
      return 'ko_KR';
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
