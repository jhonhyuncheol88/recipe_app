import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available Theme Types
enum ThemeType {
  wonkkaSignature,
  minimalistMono,
  natureGreen,
  oceanBlue,
}

/// Extension to get display names
extension ThemeTypeExtension on ThemeType {
  String get displayName {
    switch (this) {
      case ThemeType.wonkkaSignature:
        return 'Wonkka Signature';
      case ThemeType.minimalistMono:
        return 'Minimalist Mono';
      case ThemeType.natureGreen:
        return 'Nature Green';
      case ThemeType.oceanBlue:
        return 'Ocean Blue';
    }
  }
}

/// Theme State
class ThemeState extends Equatable {
  final ThemeType themeType;
  final Brightness brightness;

  const ThemeState({
    this.themeType = ThemeType.wonkkaSignature,
    this.brightness = Brightness.light,
  });

  ThemeState copyWith({
    ThemeType? themeType,
    Brightness? brightness,
  }) {
    return ThemeState(
      themeType: themeType ?? this.themeType,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  List<Object> get props => [themeType, brightness];
}

/// Theme Cubit
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_type') ?? 0;
    final isDark = prefs.getBool('is_dark_mode') ?? false;

    emit(ThemeState(
      themeType:
          ThemeType.values[themeIndex.clamp(0, ThemeType.values.length - 1)],
      brightness: isDark ? Brightness.dark : Brightness.light,
    ));
  }

  Future<void> changeTheme(ThemeType type) async {
    emit(state.copyWith(themeType: type));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_type', type.index);
  }

  Future<void> toggleBrightness() async {
    final newBrightness = state.brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    emit(state.copyWith(brightness: newBrightness));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', newBrightness == Brightness.dark);
  }

  Future<void> setBrightness(Brightness brightness) async {
    emit(state.copyWith(brightness: brightness));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', brightness == Brightness.dark);
  }
}
