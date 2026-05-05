import 'package:flutter/material.dart';

/// Wanted DS typography scale — Pretendard, 18 styles.
///
/// CSS letter-spacing(em) → Flutter letterSpacing(px) 환산:
///   px = em * fontSize
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Pretendard';

  static const TextStyle display1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 1.286,
    letterSpacing: -1.7864, // -0.0319em * 56
  );

  static const TextStyle display2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.300,
    letterSpacing: -1.128, // -0.0282em * 40
  );

  static const TextStyle display3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.334,
    letterSpacing: -0.972, // -0.027em * 36
  );

  static const TextStyle title1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.375,
    letterSpacing: -0.8096, // -0.0253em * 32
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.358,
    letterSpacing: -0.6608, // -0.0236em * 28
  );

  static const TextStyle title3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.334,
    letterSpacing: -0.552, // -0.023em * 24
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.364,
    letterSpacing: -0.4268, // -0.0194em * 22
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: -0.24, // -0.012em * 20
  );

  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.445,
    letterSpacing: -0.036, // -0.002em * 18
  );

  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.412,
    letterSpacing: 0,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.0912, // 0.0057em * 16
  );

  static const TextStyle body1Reading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.625,
    letterSpacing: 0.0912,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.467,
    letterSpacing: 0.144, // 0.0096em * 15
  );

  static const TextStyle body2Reading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 0.144,
  );

  static const TextStyle label1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.429,
    letterSpacing: 0.203, // 0.0145em * 14
  );

  static const TextStyle label1Reading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.571,
    letterSpacing: 0.203,
  );

  static const TextStyle label2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.385,
    letterSpacing: 0.2522, // 0.0194em * 13
  );

  static const TextStyle caption1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.334,
    letterSpacing: 0.3024, // 0.0252em * 12
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.273,
    letterSpacing: 0.3421, // 0.0311em * 11
  );

  /// Material `TextTheme` 매핑.
  ///
  /// Display → Title → Heading → Headline → Body → Label → Caption
  /// 의 7-tier 를 Material 의 13개 슬롯에 합리적으로 분배.
  static TextTheme buildTextTheme(Color onSurface, Color onSurfaceMuted) {
    TextStyle s(TextStyle base, Color color) => base.copyWith(color: color);
    return TextTheme(
      displayLarge: s(display1, onSurface),
      displayMedium: s(display2, onSurface),
      displaySmall: s(display3, onSurface),
      headlineLarge: s(title1, onSurface),
      headlineMedium: s(title2, onSurface),
      headlineSmall: s(title3, onSurface),
      titleLarge: s(heading1, onSurface),
      titleMedium: s(heading2, onSurface),
      titleSmall: s(headline1, onSurface),
      bodyLarge: s(body1, onSurface),
      bodyMedium: s(body2, onSurface),
      bodySmall: s(caption1, onSurfaceMuted),
      labelLarge: s(label1, onSurface),
      labelMedium: s(label2, onSurface),
      labelSmall: s(caption2, onSurfaceMuted),
    );
  }
}
