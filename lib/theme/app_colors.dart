import 'package:flutter/material.dart';

/// Legacy color constants — 위젯에서 직접 참조하는 정적 색.
///
/// 신규 작업은 `Theme.of(context).colorScheme` 또는
/// `lib/theme/tokens/app_color_tokens.dart` 의 `AppColorTokens.of(context)` 를 사용한다.
/// 이 클래스는 점진적으로 제거될 예정이다.
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
}
