import 'package:flutter/material.dart';

/// 깨끗한 주방 느낌의 베이지색을 메인으로 한 색상 팔레트
class AppColors {
  // 메인 색상 - 깨끗한 주방 베이지
  static const Color primary = Color(0xFFF5F1E8); // 메인 베이지
  static const Color primaryLight = Color(0xFFFDFCF8); // 밝은 베이지
  static const Color primaryDark = Color(0xFFE8E0D0); // 어두운 베이지

  // 보조 색상
  static const Color secondary = Color(0xFFD4C4A8); // 따뜻한 베이지
  static const Color accent = Color(0xFFB8A898); // 포인트 베이지

  // 배경 색상
  static const Color background = Color(0xFFFFFEFC); // 거의 흰색
  static const Color surface = Color(0xFFFDFCF8); // 카드 배경

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF2C2C2C); // 메인 텍스트
  static const Color textSecondary = Color(0xFF6B6B6B); // 보조 텍스트
  static const Color textLight = Color(0xFF9E9E9E); // 연한 텍스트

  // 상태 색상
  static const Color success = Color(0xFF7FB069); // 성공 (초록)
  static const Color warning = Color(0xFFFFB74D); // 경고 (주황)
  static const Color error = Color(0xFFE57373); // 오류 (빨강)
  static const Color info = Color(0xFF81C784); // 정보 (연한 초록)

  // 유통기한 상태 색상
  static const Color expiryNormal = Color(0xFF7FB069); // 정상 (초록)
  static const Color expiryWarning = Color(0xFFFFB74D); // 경고 (주황)
  static const Color expiryDanger = Color(0xFFFF8A65); // 위험 (빨강)
  static const Color expiryExpired = Color(0xFFE57373); // 만료 (진한 빨강)

  // 버튼 색상
  static const Color buttonPrimary = Color(0xFFB8A898); // 메인 버튼
  static const Color buttonSecondary = Color(0xFFD4C4A8); // 보조 버튼
  static const Color buttonText = Color(0xFF2C2C2C); // 버튼 텍스트

  // 그림자 색상
  static const Color shadow = Color(0x1A000000); // 연한 그림자
  static const Color shadowDark = Color(0x33000000); // 진한 그림자

  // 구분선 색상
  static const Color divider = Color(0xFFE0E0E0); // 연한 회색
  static const Color dividerLight = Color(0xFFF0F0E0); // 매우 연한 회색

  // AI 레시피 관련 색상
  static const Color aiRecipeCard = Color(0xFFF8F6F0); // AI 레시피 카드 배경
  static const Color aiRecipeHeader = Color(0xFFE8E0D0); // AI 레시피 헤더 배경
}
