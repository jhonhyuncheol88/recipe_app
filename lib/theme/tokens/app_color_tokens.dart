import 'package:flutter/material.dart';

/// Wanted Design System — atomic palette.
///
/// Source: 레시피앱_디자인/project/ds/colors_and_type.css
class AppPalette {
  AppPalette._();

  // Neutral (true grey)
  static const neutral50 = Color(0xFFF7F7F7);
  static const neutral100 = Color(0xFFDCDCDC);
  static const neutral200 = Color(0xFFC4C4C4);
  static const neutral300 = Color(0xFFB0B0Be0);
  static const neutral400 = Color(0xFF9B9B9B);
  static const neutral500 = Color(0xFF8A8A8A);
  static const neutral600 = Color(0xFF737373);
  static const neutral700 = Color(0xFF5C5C5C);
  static const neutral800 = Color(0xFF474747);
  static const neutral900 = Color(0xFF303030);
  static const neutral950 = Color(0xFF171717);

  // Cool Neutral (signature Wanted grey)
  static const cool50 = Color(0xFFF7F7F8);
  static const cool100 = Color(0xFFF4F4F5);
  static const cool200 = Color(0xFFEAEBEC);
  static const cool300 = Color(0xFFDBDCDF);
  static const cool400 = Color(0xFFC2C4C8);
  static const cool500 = Color(0xFFAEB0B6);
  static const cool600 = Color(0xFF989BA2);
  static const cool700 = Color(0xFF878A93);
  static const cool800 = Color(0xFF70737C);
  static const cool900 = Color(0xFF46474C);
  static const cool950 = Color(0xFF171719);

  // Blue (primary brand)
  static const blue50 = Color(0xFFF7FBFF);
  static const blue100 = Color(0xFFEAF2FE);
  static const blue200 = Color(0xFFC9DEFE);
  static const blue300 = Color(0xFF9EC5FF);
  static const blue400 = Color(0xFF69A5FF);
  static const blue500 = Color(0xFF3385FF);
  static const blue600 = Color(0xFF0066FF);
  static const blue700 = Color(0xFF005EEB);
  static const blue800 = Color(0xFF0054D1);
  static const blue900 = Color(0xFF003E9C);

  // Red
  static const red50 = Color(0xFFFFFAFA);
  static const red100 = Color(0xFFFEECEC);
  static const red300 = Color(0xFFFED5D5);
  static const red500 = Color(0xFFFF8C8C);
  static const red600 = Color(0xFFFF4242);
  static const red700 = Color(0xFFE52222);
  static const red800 = Color(0xFFB20C0C);

  // Green
  static const green50 = Color(0xFFF2FFF6);
  static const green100 = Color(0xFFD9FFE6);
  static const green500 = Color(0xFF49E57D);
  static const green600 = Color(0xFF00BF40);
  static const green700 = Color(0xFF009632);
  static const green800 = Color(0xFF006E25);

  // Orange / RedOrange
  static const orange500 = Color(0xFFFFA938);
  static const orange600 = Color(0xFFFF9200);
  static const orange700 = Color(0xFFD47800);
  static const redorange500 = Color(0xFFFF7B2E);
  static const redorange600 = Color(0xFFFF5E00);

  // Cyan / LightBlue
  static const cyan500 = Color(0xFF28D0ED);
  static const cyan600 = Color(0xFF00BDDE);
  static const cyan700 = Color(0xFF0098B2);
  static const lightblue500 = Color(0xFF3DC2FF);
  static const lightblue600 = Color(0xFF00AEFF);

  // Violet (AI / featured accent)
  static const violet500 = Color(0xFF7D5EF7);
  static const violet600 = Color(0xFF6541F2);
  static const violet700 = Color(0xFF5B37ED);

  // Purple / Pink
  static const purple500 = Color(0xFFD478FF);
  static const purple600 = Color(0xFFCB59FF);
  static const pink500 = Color(0xFFFA73E3);
  static const pink600 = Color(0xFFF553DA);

  // Lime
  static const lime500 = Color(0xFF6BE016);
  static const lime600 = Color(0xFF58CF04);
}

/// Semantic color tokens — light & dark.
///
/// `ThemeExtension` 으로 등록되므로
/// `AppColorTokens.of(context)` 로 접근 가능.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  // Background
  final Color bgBase;
  final Color bgElev1;
  final Color bgElev2;
  final Color bgMuted;
  final Color bgInverse;

  // Foreground
  final Color fgStrong;
  final Color fgDefault;
  final Color fgSecondary;
  final Color fgTertiary;
  final Color fgDisabled;
  final Color fgOnPrimary;
  final Color fgLink;

  // Borders
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;

  // Brand / status
  final Color primary;
  final Color primaryHover;
  final Color primaryPress;
  final Color primarySoft;
  final Color positive;
  final Color positiveSoft;
  final Color negative;
  final Color negativeSoft;
  final Color warning;
  final Color warningSoft;
  final Color info;
  final Color infoSoft;
  final Color accentAi;
  final Color accentAiSoft;

  const AppColorTokens({
    required this.bgBase,
    required this.bgElev1,
    required this.bgElev2,
    required this.bgMuted,
    required this.bgInverse,
    required this.fgStrong,
    required this.fgDefault,
    required this.fgSecondary,
    required this.fgTertiary,
    required this.fgDisabled,
    required this.fgOnPrimary,
    required this.fgLink,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.primary,
    required this.primaryHover,
    required this.primaryPress,
    required this.primarySoft,
    required this.positive,
    required this.positiveSoft,
    required this.negative,
    required this.negativeSoft,
    required this.warning,
    required this.warningSoft,
    required this.info,
    required this.infoSoft,
    required this.accentAi,
    required this.accentAiSoft,
  });

  static const AppColorTokens light = AppColorTokens(
    bgBase: Color(0xFFFFFFFF),
    bgElev1: Color(0xFFFAFAFA),
    bgElev2: Color(0xFFF7F7F8),
    bgMuted: Color(0xFFF4F4F5),
    bgInverse: Color(0xFF171719),
    fgStrong: Color(0xFF14191E),
    fgDefault: Color(0xFF171719),
    fgSecondary: Color(0xE12E2F33), // rgba(46,47,51,0.88)
    fgTertiary: Color(0x9C37383C), // rgba(55,56,60,0.61)
    fgDisabled: Color(0x4770737C), // rgba(112,115,124,0.28)
    fgOnPrimary: Color(0xFFFFFFFF),
    fgLink: Color(0xFF0066FF),
    borderSubtle: Color(0x3870737C), // rgba(112,115,124,0.22)
    borderDefault: Color(0x4770737C), // rgba(112,115,124,0.28)
    borderStrong: Color(0xFF14191E),
    primary: Color(0xFF0066FF),
    primaryHover: Color(0xFF005EEB),
    primaryPress: Color(0xFF0054D1),
    primarySoft: Color(0xFFEAF2FE),
    positive: Color(0xFF00BF40),
    positiveSoft: Color(0xFFD9FFE6),
    negative: Color(0xFFFF4242),
    negativeSoft: Color(0xFFFEECEC),
    warning: Color(0xFFFF9200),
    warningSoft: Color(0xFFFEF4E6),
    info: Color(0xFF00AEFF),
    infoSoft: Color(0xFFE5F6FE),
    accentAi: Color(0xFF6541F2),
    accentAiSoft: Color(0xFFF0ECFE),
  );

  static const AppColorTokens dark = AppColorTokens(
    bgBase: Color(0xFF14191E),
    bgElev1: Color(0xFF1B1C1E),
    bgElev2: Color(0xFF212225),
    bgMuted: Color(0xFF2E2F33),
    bgInverse: Color(0xFFFFFFFF),
    fgStrong: Color(0xFFFFFFFF),
    fgDefault: Color(0xFFF7F7F8),
    fgSecondary: Color(0xE1F7F7F8), // rgba(247,247,248,0.88)
    fgTertiary: Color(0x9CF7F7F8), // rgba(247,247,248,0.61)
    fgDisabled: Color(0x47F7F7F8), // rgba(247,247,248,0.28)
    fgOnPrimary: Color(0xFFFFFFFF),
    fgLink: Color(0xFF3385FF),
    borderSubtle: Color(0x1FF7F7F8), // rgba(247,247,248,0.12)
    borderDefault: Color(0x38F7F7F8), // rgba(247,247,248,0.22)
    borderStrong: Color(0xFFFFFFFF),
    primary: Color(0xFF3385FF),
    primaryHover: Color(0xFF69A5FF),
    primaryPress: Color(0xFF9EC5FF),
    primarySoft: Color(0x2E0066FF), // rgba(0,102,255,0.18)
    positive: Color(0xFF1ED45A),
    positiveSoft: Color(0x2E00BF40),
    negative: Color(0xFFFF6363),
    negativeSoft: Color(0x2EFF4242),
    warning: Color(0xFFFFA938),
    warningSoft: Color(0x2EFF9200),
    info: Color(0xFF3DC2FF),
    infoSoft: Color(0x2E00AEFF),
    accentAi: Color(0xFF7D5EF7),
    accentAiSoft: Color(0x2E6541F2),
  );

  /// Convenience accessor.
  static AppColorTokens of(BuildContext context) {
    return Theme.of(context).extension<AppColorTokens>() ?? light;
  }

  @override
  AppColorTokens copyWith({
    Color? bgBase,
    Color? bgElev1,
    Color? bgElev2,
    Color? bgMuted,
    Color? bgInverse,
    Color? fgStrong,
    Color? fgDefault,
    Color? fgSecondary,
    Color? fgTertiary,
    Color? fgDisabled,
    Color? fgOnPrimary,
    Color? fgLink,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? primary,
    Color? primaryHover,
    Color? primaryPress,
    Color? primarySoft,
    Color? positive,
    Color? positiveSoft,
    Color? negative,
    Color? negativeSoft,
    Color? warning,
    Color? warningSoft,
    Color? info,
    Color? infoSoft,
    Color? accentAi,
    Color? accentAiSoft,
  }) {
    return AppColorTokens(
      bgBase: bgBase ?? this.bgBase,
      bgElev1: bgElev1 ?? this.bgElev1,
      bgElev2: bgElev2 ?? this.bgElev2,
      bgMuted: bgMuted ?? this.bgMuted,
      bgInverse: bgInverse ?? this.bgInverse,
      fgStrong: fgStrong ?? this.fgStrong,
      fgDefault: fgDefault ?? this.fgDefault,
      fgSecondary: fgSecondary ?? this.fgSecondary,
      fgTertiary: fgTertiary ?? this.fgTertiary,
      fgDisabled: fgDisabled ?? this.fgDisabled,
      fgOnPrimary: fgOnPrimary ?? this.fgOnPrimary,
      fgLink: fgLink ?? this.fgLink,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryPress: primaryPress ?? this.primaryPress,
      primarySoft: primarySoft ?? this.primarySoft,
      positive: positive ?? this.positive,
      positiveSoft: positiveSoft ?? this.positiveSoft,
      negative: negative ?? this.negative,
      negativeSoft: negativeSoft ?? this.negativeSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      accentAi: accentAi ?? this.accentAi,
      accentAiSoft: accentAiSoft ?? this.accentAiSoft,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgElev1: Color.lerp(bgElev1, other.bgElev1, t)!,
      bgElev2: Color.lerp(bgElev2, other.bgElev2, t)!,
      bgMuted: Color.lerp(bgMuted, other.bgMuted, t)!,
      bgInverse: Color.lerp(bgInverse, other.bgInverse, t)!,
      fgStrong: Color.lerp(fgStrong, other.fgStrong, t)!,
      fgDefault: Color.lerp(fgDefault, other.fgDefault, t)!,
      fgSecondary: Color.lerp(fgSecondary, other.fgSecondary, t)!,
      fgTertiary: Color.lerp(fgTertiary, other.fgTertiary, t)!,
      fgDisabled: Color.lerp(fgDisabled, other.fgDisabled, t)!,
      fgOnPrimary: Color.lerp(fgOnPrimary, other.fgOnPrimary, t)!,
      fgLink: Color.lerp(fgLink, other.fgLink, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryPress: Color.lerp(primaryPress, other.primaryPress, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      positiveSoft: Color.lerp(positiveSoft, other.positiveSoft, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      negativeSoft: Color.lerp(negativeSoft, other.negativeSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      accentAi: Color.lerp(accentAi, other.accentAi, t)!,
      accentAiSoft: Color.lerp(accentAiSoft, other.accentAiSoft, t)!,
    );
  }
}
