import 'package:flutter/material.dart';
import '../controller/setting/theme_cubit.dart';

/// Semantic Color Palette
class AppColors {
  // --- Static Defaults (Backwards Compatibility / Default Theme) ---
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFF000051);
  static const Color secondary = Color(0xFFE65100);
  static const Color accent = Color(0xFFE65100);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF000000); // 검은색 (라이트)
  static const Color textSecondary = Color(0xFF000000); // 검은색 (라이트)
  static const Color textLight = Color(0xFF000000); // 검은색 (라이트)
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF7FB069);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF81C784);
  static const Color expiryNormal = Color(0xFF7FB069);
  static const Color expiryWarning = Color(0xFFFFB74D);
  static const Color expiryDanger = Color(0xFFFF8A65);
  static const Color expiryExpired = Color(0xFFE57373);
  static const Color buttonPrimary = Color(0xFF1A237E);
  static const Color buttonSecondary = Color(0xFFFFFFFF);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonTextDark = Color(0xFF000000);
  static const Color numberPrimary = Color(0xFF000000);
  static const Color numberAccent = Color(0xFFE65100); // 주황색 강조
  static const Color numberSecondary = Color(0xFF000000);
  static const Color costEmphasized = Color(0xFFE65100); // 주황색 강조
  static const Color shadow = Color(0x0A000000);
  static const Color shadowDark = Color(0x1A000000);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFF5F5F5);
  static const Color aiRecipeCard = Color(0xFFFFFFFF);
  static const Color aiRecipeHeader = Color(0xFFF5F5F5);

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
          primary: Color(0xFF1A237E), // Deep Navy
          onPrimary: Colors.white,
          secondary: Color(0xFFE65100), // Burnt Orange
          onSecondary: Colors.white,
          surface: Color(0xFFFFFFFF), // Pure white background
          onSurface: Color(0xFF000000), // 검은색 텍스트
          error: Color(0xFFB00020),
          onError: Colors.white,
        );
      case ThemeType.minimalistMono:
        return const ColorScheme.light(
          primary: Color(0xFF212121), // Matte Black
          onPrimary: Colors.white,
          secondary: Color(0xFF757575), // Grey
          onSecondary: Colors.white,
          surface: Color(0xFFFFFFFF), // Pure white
          onSurface: Color(0xFF000000), // 검은색 텍스트
          error: Color(0xFFB00020),
          onError: Colors.white,
        );
      case ThemeType.natureGreen:
        return const ColorScheme.light(
          primary: Color(0xFF2E7D32), // Forest Green
          onPrimary: Colors.white,
          secondary: Color(0xFFA5D6A7), // Sage
          onSecondary: Color(0xFF2E7D32),
          surface: Color(0xFFFFFFFF), // Pure white
          onSurface: Color(0xFF000000), // 검은색 텍스트
          error: Color(0xFFB00020),
          onError: Colors.white,
        );
      case ThemeType.oceanBlue:
        return const ColorScheme.light(
          primary: Color(0xFF1565C0), // Royal Blue
          onPrimary: Colors.white,
          secondary: Color(0xFF90CAF9), // Sky Blue
          onSecondary: Color(0xFF0D47A1),
          surface: Color(0xFFFFFFFF), // Pure white
          onSurface: Color(0xFF000000), // 검은색 텍스트
          error: Color(0xFFB00020),
          onError: Colors.white,
        );
    }
  }

  static ColorScheme _getDarkColorScheme(ThemeType type) {
    // Shared dark base colors to ensure readability
    const darkBackground = Color(0xFF121212);
    const darkOnSurface = Color(0xFFFFFFFF); // 흰색 텍스트

    switch (type) {
      case ThemeType.wonkkaSignature:
        return const ColorScheme.dark(
          primary: Color(0xFF534BAE), // Lighter Navy
          onPrimary: Colors.white,
          secondary: Color(0xFFFF833A), // Lighter Orange
          onSecondary: Colors.black,
          surface: darkBackground,
          onSurface: darkOnSurface,
          error: Color(0xFFCF6679),
          onError: Colors.black,
        );
      case ThemeType.minimalistMono:
        return const ColorScheme.dark(
          primary: Color(0xFFE0E0E0), // Whitish Grey
          onPrimary: Colors.black,
          secondary: Color(0xFFBDBDBD),
          onSecondary: Colors.black,
          surface: Colors.black,
          onSurface: darkOnSurface,
          error: Color(0xFFCF6679),
          onError: Colors.black,
        );
      case ThemeType.natureGreen:
        return const ColorScheme.dark(
          primary: Color(0xFF66BB6A), // Light Green
          onPrimary: Colors.black,
          secondary: Color(0xFF81C784),
          onSecondary: Colors.black,
          surface: Color(0xFF0E140F),
          onSurface: darkOnSurface,
          error: Color(0xFFCF6679),
          onError: Colors.black,
        );
      case ThemeType.oceanBlue:
        return const ColorScheme.dark(
          primary: Color(0xFF42A5F5), // Light Blue
          onPrimary: Colors.black,
          secondary: Color(0xFF64B5F6),
          onSecondary: Colors.black,
          surface: Color(0xFF080C10),
          onSurface: darkOnSurface,
          error: Color(0xFFCF6679),
          onError: Colors.black,
        );
    }
  }
}
