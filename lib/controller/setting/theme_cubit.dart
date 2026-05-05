import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme State — light/dark 만 보관.
class ThemeState extends Equatable {
  final Brightness brightness;

  const ThemeState({this.brightness = Brightness.light});

  ThemeState copyWith({Brightness? brightness}) {
    return ThemeState(brightness: brightness ?? this.brightness);
  }

  bool get isDark => brightness == Brightness.dark;

  @override
  List<Object> get props => [brightness];
}

/// Theme Cubit.
///
/// 라이트/다크 모드 전환만 관리한다. 색·타이포·여백 등의 디자인 토큰은
/// `lib/theme/tokens/` 에서 관리되며, `AppTheme.light` / `AppTheme.dark` 가
/// 양쪽 ThemeData 를 빌드한다.
class ThemeCubit extends Cubit<ThemeState> {
  static const String _kIsDarkMode = 'is_dark_mode';

  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_kIsDarkMode) ?? false;
    emit(ThemeState(
      brightness: isDark ? Brightness.dark : Brightness.light,
    ));
  }

  Future<void> toggleBrightness() async {
    final next = state.isDark ? Brightness.light : Brightness.dark;
    await setBrightness(next);
  }

  Future<void> setBrightness(Brightness brightness) async {
    emit(state.copyWith(brightness: brightness));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsDarkMode, brightness == Brightness.dark);
  }
}
