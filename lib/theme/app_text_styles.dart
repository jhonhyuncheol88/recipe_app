import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 동글동글한 느낌의 텍스트 스타일 정의
class AppTextStyles {
  // 기본 폰트 설정
  static const String _fontFamily = 'Nunito'; // 동글동글한 폰트

  // 제목 스타일
  static TextStyle get headline1 => GoogleFonts.nunito(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get headline2 => GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headline3 => GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get headline4 => GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // 본문 텍스트 스타일
  static TextStyle get bodyLarge => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // 버튼 텍스트 스타일
  static TextStyle get buttonLarge => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
    height: 1.2,
  );

  static TextStyle get buttonMedium => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
    height: 1.2,
  );

  static TextStyle get buttonSmall => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
    height: 1.2,
  );

  // 캡션 스타일
  static TextStyle get caption => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.4,
  );

  // 오버라인 스타일
  static TextStyle get overline => GoogleFonts.nunito(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    height: 1.2,
    letterSpacing: 1.5,
  );

  // 특별한 스타일
  static TextStyle get appTitle => GoogleFonts.nunito(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get cardTitle => GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get priceText => GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
    height: 1.2,
  );

  static TextStyle get expiryText => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // 상태별 텍스트 색상
  static TextStyle expiryNormal() =>
      expiryText.copyWith(color: AppColors.expiryNormal);

  static TextStyle expiryWarning() =>
      expiryText.copyWith(color: AppColors.expiryWarning);

  static TextStyle expiryDanger() =>
      expiryText.copyWith(color: AppColors.expiryDanger);

  static TextStyle expiryExpired() =>
      expiryText.copyWith(color: AppColors.expiryExpired);

  // AI 레시피 관련 스타일
  static TextStyle get aiRecipeTitle => GoogleFonts.nunito(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get aiRecipeDescription => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get aiRecipeTag => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.accent,
    height: 1.2,
  );
}
