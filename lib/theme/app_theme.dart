import 'package:flutter/material.dart';
import '../controller/setting/theme_cubit.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// 앱 테마 설정
class AppTheme {
  /// Compatibility getter for transition
  static ThemeData get lightTheme =>
      getTheme(ThemeType.wonkkaSignature, Brightness.light);

  /// Compatibility getter for transition
  static ThemeData get darkTheme =>
      getTheme(ThemeType.wonkkaSignature, Brightness.dark);

  static ThemeData getTheme(ThemeType type, Brightness brightness) {
    final colorScheme = AppColors.getColorScheme(type, brightness);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // 스캐폴드 배경색
      scaffoldBackgroundColor: colorScheme.surface,

      // 앱바 테마
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headline4.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
      ),

      // 카드 테마
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0, // Flat design
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? Colors.white10 : Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // 버튼 테마 (Flat 디자인)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // 텍스트 버튼 테마
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary, // Accent color usually
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // 아이콘 버튼 테마
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
          backgroundColor: Colors.transparent,
        ),
      ),

      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? Colors.white.withValues(alpha: 0.05) : Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: isDark ? Colors.white24 : Color(0xFFEEEEEE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: isDark ? Colors.white24 : Color(0xFFEEEEEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        labelStyle:
            TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
      ),

      // 스위치 테마
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary;
          }
          return isDark ? Colors.grey[400] : Colors.grey[600];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.5);
          }
          return isDark ? Colors.grey[800] : Colors.grey[300];
        }),
      ),

      // 다이얼로그 테마
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? Colors.white10 : Colors.transparent),
        ),
        titleTextStyle: AppTextStyles.headline4.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
      ),

      // 스낵바 테마
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? Colors.white : const Color(0xFF323232),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: isDark ? Colors.black : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        actionTextColor: colorScheme.primary,
      ),

      // 바텀 네비게이션 바 테마
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 0, // Flat
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // 리스트 타일 테마
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurface.withValues(alpha: 0.7),
      ),

      // 구분선 테마
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white24 : Color(0xFFEEEEEE),
        thickness: 1,
        space: 1,
      ),

      // 플로팅 액션 버튼 테마
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),

      // 텍스트 테마
      textTheme: TextTheme(
        displayLarge:
            AppTextStyles.headline1.copyWith(color: colorScheme.onSurface),
        displayMedium:
            AppTextStyles.headline2.copyWith(color: colorScheme.onSurface),
        displaySmall:
            AppTextStyles.headline3.copyWith(color: colorScheme.onSurface),
        headlineLarge:
            AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        headlineMedium:
            AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        headlineSmall:
            AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        titleLarge:
            AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        titleMedium:
            AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
        titleSmall:
            AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
        bodySmall: AppTextStyles.bodySmall
            .copyWith(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        labelLarge:
            AppTextStyles.buttonLarge.copyWith(color: colorScheme.onSurface),
        labelMedium:
            AppTextStyles.buttonMedium.copyWith(color: colorScheme.onSurface),
        labelSmall:
            AppTextStyles.buttonSmall.copyWith(color: colorScheme.onSurface),
      ),

      // 아이콘 테마
      iconTheme: IconThemeData(
          color: colorScheme.onSurface.withValues(alpha: 0.7), size: 24),
      primaryIconTheme: IconThemeData(color: colorScheme.primary, size: 24),
    );
  }
}
