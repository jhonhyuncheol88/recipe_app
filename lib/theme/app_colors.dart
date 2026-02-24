import 'package:flutter/material.dart';
import '../controller/setting/theme_cubit.dart';

/// Semantic Color Palette
class AppColors {
  // --- Static Defaults (파스텔 톤) ---
  static const Color primary = Color(0xFF9CA8E0);
  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF7A88C4);
  static const Color secondary = Color(0xFFE8B4B8);
  static const Color accent = Color(0xFFE8B4B8);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFF9F5);
  static const Color textPrimary = Color(0xFF4A4541);
  static const Color textSecondary = Color(0xFF4A4541);
  static const Color textLight = Color(0xFF4A4541);
  static const Color error = Color(0xFFE8A5A5);
  static const Color success = Color(0xFFA8D5BA);
  static const Color warning = Color(0xFFF5D6A8);
  static const Color info = Color(0xFFA8D5BA);
  static const Color expiryNormal = Color(0xFFA8D5BA);
  static const Color expiryWarning = Color(0xFFF5D6A8);
  static const Color expiryDanger = Color(0xFFE8A598);
  static const Color expiryExpired = Color(0xFFE8A5A5);
  static const Color buttonPrimary = Color(0xFF9CA8E0);
  static const Color buttonSecondary = Color(0xFFFFFFFF);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonTextDark = Color(0xFF1A1A1A);
  static const Color numberPrimary = Color(0xFF4A4541);
  static const Color numberAccent = Color(0xFFD4A5A5);
  static const Color numberSecondary = Color(0xFF4A4541);
  static const Color costEmphasized = Color(0xFFD4A5A5);
  static const Color shadow = Color(0x0A000000);
  static const Color shadowDark = Color(0x1A000000);
  static const Color divider = Color(0xFFEDE8E4);
  static const Color dividerLight = Color(0xFFF8F5F2);
  static const Color aiRecipeCard = Color(0xFFFFFFFF);
  static const Color aiRecipeHeader = Color(0xFFF8F5F2);

  // --- Dynamic Theme Logic ---

  static ColorScheme getColorScheme(ThemeType type, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return _getDarkColorScheme(type);
    }
    return _getLightColorScheme(type);
  }

  static ColorScheme _getLightColorScheme(ThemeType type) {
    switch (type) {
      case ThemeType.wonkkaSignature:
        return const ColorScheme.light(
          primary: Color(0xFF9CA8E0), // 소프트 퍼플블루
          onPrimary: Color(0xFF1A1A1A),
          secondary: Color(0xFFE8B4B8), // 듀스티 로즈
          onSecondary: Color(0xFF4A4541),
          surface: Color(0xFFFFF9F5), // 크림 화이트
          onSurface: Color(0xFF4A4541), // 웜 그레이
          error: Color(0xFFE8A5A5),
          onError: Color(0xFF1A1A1A),
        );
      case ThemeType.minimalistMono:
        return const ColorScheme.light(
          primary: Color(0xFF7D7D7D),
          onPrimary: Colors.white,
          secondary: Color(0xFFB8B8B8),
          onSecondary: Color(0xFF3D3D3D),
          surface: Color(0xFFFAFAF8),
          onSurface: Color(0xFF3D3D3D),
          error: Color(0xFFE8A5A5),
          onError: Color(0xFF1A1A1A),
        );
      case ThemeType.natureGreen:
        return const ColorScheme.light(
          primary: Color(0xFF8FBC8F), // 다크 시에라
          onPrimary: Color(0xFF1A1A1A),
          secondary: Color(0xFFC5E1C5), // 라이트 세이지
          onSecondary: Color(0xFF3D4A3D),
          surface: Color(0xFFF5FAF5),
          onSurface: Color(0xFF3D4A3D),
          error: Color(0xFFE8A5A5),
          onError: Color(0xFF1A1A1A),
        );
      case ThemeType.oceanBlue:
        return const ColorScheme.light(
          primary: Color(0xFF87CEEB), // 스카이 블루
          onPrimary: Color(0xFF1A1A1A),
          secondary: Color(0xFFB5D8EB), // 파우더 블루
          onSecondary: Color(0xFF3D4A52),
          surface: Color(0xFFF5FAFC),
          onSurface: Color(0xFF3D4A52),
          error: Color(0xFFE8A5A5),
          onError: Color(0xFF1A1A1A),
        );
    }
  }

  static ColorScheme _getDarkColorScheme(ThemeType type) {
    const darkOnSurface = Color(0xFFF5F5F0);

    switch (type) {
      case ThemeType.wonkkaSignature:
        return const ColorScheme.dark(
          primary: Color(0xFFB5C4F0),
          onPrimary: Color(0xFF1A1A1A),
          secondary: Color(0xFFE8B4B8),
          onSecondary: Color(0xFF1A1A1A),
          surface: Color(0xFF1E1C24),
          onSurface: darkOnSurface,
          error: Color(0xFFE8A5A5),
          onError: Color(0xFF1A1A1A),
        );
      case ThemeType.minimalistMono:
        return const ColorScheme.dark(
          primary: Color(0xFFE0E0E0),
          onPrimary: Color(0xFF1A1A1A),
          secondary: Color(0xFFBDBDBD),
          onSecondary: Color(0xFF1A1A1A),
          surface: Color(0xFF1A1A1A),
          onSurface: darkOnSurface,
          error: Color(0xFFE8A5A5),
          onError: Color(0xFF1A1A1A),
        );
      case ThemeType.natureGreen:
        return const ColorScheme.dark(
          primary: Color(0xFFA8D5BA),
          onPrimary: Color(0xFF1A1A1A),
          secondary: Color(0xFFB5D8C5),
          onSecondary: Color(0xFF1A1A1A),
          surface: Color(0xFF1A221C),
          onSurface: darkOnSurface,
          error: Color(0xFFE8A5A5),
          onError: Color(0xFF1A1A1A),
        );
      case ThemeType.oceanBlue:
        return const ColorScheme.dark(
          primary: Color(0xFFA5C9EB),
          onPrimary: Color(0xFF1A1A1A),
          secondary: Color(0xFFB5D8EB),
          onSecondary: Color(0xFF1A1A1A),
          surface: Color(0xFF1A1E24),
          onSurface: darkOnSurface,
          error: Color(0xFFE8A5A5),
          onError: Color(0xFF1A1A1A),
        );
    }
  }
}
