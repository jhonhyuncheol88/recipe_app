import 'package:flutter/material.dart';

import 'tokens/tokens.dart';

/// 앱 전역 ThemeData 빌더 — Wanted DS 토큰 기반.
///
/// 라이트/다크 두 모드만 제공한다.
/// 색은 `AppColorTokens` (시맨틱) + `ColorScheme` (Material) 양쪽에서
/// 동일한 값으로 노출되므로 위젯에서 어느 쪽으로 접근해도 일관성 유지.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        tokens: AppColorTokens.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        tokens: AppColorTokens.dark,
      );

  /// 호환용 — 기존 호출처가 정리되기 전까지 유지.
  static ThemeData get lightTheme => light;
  static ThemeData get darkTheme => dark;

  static ThemeData of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static ThemeData _build({
    required Brightness brightness,
    required AppColorTokens tokens,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: tokens.fgOnPrimary,
      primaryContainer: tokens.primarySoft,
      onPrimaryContainer: tokens.primary,
      secondary: tokens.accentAi,
      onSecondary: tokens.fgOnPrimary,
      secondaryContainer: tokens.accentAiSoft,
      onSecondaryContainer: tokens.accentAi,
      tertiary: tokens.info,
      onTertiary: tokens.fgOnPrimary,
      tertiaryContainer: tokens.infoSoft,
      onTertiaryContainer: tokens.info,
      error: tokens.negative,
      onError: tokens.fgOnPrimary,
      errorContainer: tokens.negativeSoft,
      onErrorContainer: tokens.negative,
      surface: tokens.bgBase,
      onSurface: tokens.fgDefault,
      surfaceContainerLowest: tokens.bgBase,
      surfaceContainerLow: tokens.bgElev1,
      surfaceContainer: tokens.bgElev2,
      surfaceContainerHigh: tokens.bgMuted,
      surfaceContainerHighest: tokens.bgMuted,
      onSurfaceVariant: tokens.fgSecondary,
      outline: tokens.borderDefault,
      outlineVariant: tokens.borderSubtle,
      inverseSurface: tokens.bgInverse,
      onInverseSurface: isDark ? tokens.fgStrong : tokens.fgOnPrimary,
      inversePrimary: tokens.primaryHover,
      shadow: const Color(0xFF000000),
      scrim: const Color(0x73000000),
    );

    final textTheme = AppTypography.buildTextTheme(
      tokens.fgDefault,
      tokens.fgTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: tokens.bgElev2,
      canvasColor: tokens.bgBase,
      dividerColor: tokens.borderSubtle,
      splashFactory: InkRipple.splashFactory,
      extensions: <ThemeExtension<dynamic>>[
        tokens,
      ],

      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bgBase,
        foregroundColor: tokens.fgStrong,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.headline2.copyWith(color: tokens.fgStrong),
        iconTheme: IconThemeData(color: tokens.fgStrong, size: 24),
      ),

      cardTheme: CardThemeData(
        color: tokens.bgBase,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brR16,
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.fgOnPrimary,
          disabledBackgroundColor: tokens.borderSubtle,
          disabledForegroundColor: tokens.fgDisabled,
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: AppTypography.label1.copyWith(fontWeight: FontWeight.w700),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brR10),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s12,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.fgOnPrimary,
          textStyle: AppTypography.label1.copyWith(fontWeight: FontWeight.w700),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brR10),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s12,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.fgStrong,
          side: BorderSide(color: tokens.borderSubtle, width: 1),
          textStyle: AppTypography.label1.copyWith(fontWeight: FontWeight.w700),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brR10),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s12,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.primary,
          textStyle: AppTypography.label1.copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brR8),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: tokens.fgSecondary,
          backgroundColor: Colors.transparent,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.bgBase,
        border: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.negative, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.negative, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        hintStyle: AppTypography.body2.copyWith(color: tokens.fgTertiary),
        labelStyle: AppTypography.label1.copyWith(color: tokens.fgSecondary),
        helperStyle: AppTypography.caption1.copyWith(color: tokens.fgTertiary),
        errorStyle: AppTypography.caption1.copyWith(color: tokens.negative),
        prefixIconColor: tokens.fgTertiary,
        suffixIconColor: tokens.fgTertiary,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return tokens.fgOnPrimary;
          // OFF 상태 썸은 트랙 위에서 충분히 도드라지도록.
          return isDark ? tokens.fgTertiary : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return tokens.primary;
          // OFF 상태 트랙 — 다크에선 bgMuted (배경보다 밝은 컨테이너 톤),
          // 라이트에선 borderDefault 보다 진한 채움색.
          return isDark ? tokens.bgMuted : tokens.borderDefault;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          // 다크에서 트랙 외곽선으로 한 번 더 윤곽을 잡아 배경과 분리.
          return isDark ? tokens.borderDefault : Colors.transparent;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return tokens.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(tokens.fgOnPrimary),
        side: BorderSide(color: tokens.borderDefault, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.r6)),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return tokens.primary;
          return tokens.borderDefault;
        }),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: tokens.bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.brR20,
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        titleTextStyle: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        contentTextStyle:
            AppTypography.body2.copyWith(color: tokens.fgSecondary),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.r20),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: tokens.borderDefault,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.bgInverse,
        contentTextStyle: AppTypography.label1.copyWith(
          color: isDark ? tokens.fgStrong : Colors.white,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brPill),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        actionTextColor: tokens.primary,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.bgBase,
        selectedItemColor: tokens.primary,
        unselectedItemColor: tokens.fgTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTypography.caption2.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.caption2,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.bgBase,
        elevation: 0,
        height: 64,
        indicatorColor: tokens.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.caption2.copyWith(
            color: selected ? tokens.primary : tokens.fgTertiary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? tokens.primary : tokens.fgTertiary,
            size: 24,
          );
        }),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: tokens.fgStrong,
        unselectedLabelColor: tokens.fgTertiary,
        labelStyle: AppTypography.label1.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTypography.label1,
        indicatorColor: tokens.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: tokens.borderSubtle,
      ),

      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: tokens.primarySoft,
        selectedColor: tokens.primary,
        textColor: tokens.fgDefault,
        iconColor: tokens.fgSecondary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brR12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: tokens.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.primary,
        foregroundColor: tokens.fgOnPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brR16),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: tokens.bgMuted,
        selectedColor: tokens.fgStrong,
        secondarySelectedColor: tokens.fgStrong,
        disabledColor: tokens.borderSubtle,
        labelStyle: AppTypography.label1.copyWith(color: tokens.fgSecondary),
        secondaryLabelStyle:
            AppTypography.label1.copyWith(color: tokens.fgOnPrimary),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s6,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.primary,
        linearTrackColor: tokens.bgMuted,
        circularTrackColor: tokens.bgMuted,
      ),

      iconTheme: IconThemeData(color: tokens.fgSecondary, size: 24),
      primaryIconTheme: IconThemeData(color: tokens.primary, size: 24),
    );
  }
}
