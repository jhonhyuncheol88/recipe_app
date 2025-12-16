import 'package:flutter/material.dart';

/// 모던 셰프 컨셉 - 깔끔하고 전문적인 주방 느낌의 색상 팔레트
class AppColors {
  // 메인 색상 - 딥 네이비 / 차콜 그레이
  static const Color primary = Color(0xFF1A237E); // 딥 네이비
  static const Color primaryLight = Color(0xFF424242); // 차콜 그레이 (밝은 버전)
  static const Color primaryDark = Color(0xFF000051); // 진한 네이비

  // 보조 색상
  static const Color secondary = Color(0xFF424242); // 차콜 그레이
  static const Color accent = Color(0xFFE65100); // 번트 오렌지 (강조색)

  // 배경 색상
  static const Color background = Color(0xFFFFFFFF); // 깨끗한 화이트
  static const Color surface = Color(0xFFFFFFFF); // 흰색 카드 배경

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF000000); // 완전한 검정 (가독성 향상)
  static const Color textSecondary = Color(0xFF424242); // 차콜 그레이 (더 진하게)
  static const Color textLight = Color(0xFF666666); // 중간 회색

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
  static const Color buttonPrimary = Color(0xFF1A237E); // 딥 네이비 (메인 버튼)
  static const Color buttonSecondary = Color(0xFF424242); // 차콜 그레이 (보조 버튼)
  static const Color buttonText = Color(0xFFFFFFFF); // 버튼 텍스트 (흰색)
  static const Color buttonTextDark = Color(0xFF000000); // 어두운 배경용 버튼 텍스트

  // 숫자 텍스트 색상 (짙은 검은색 - 중요)
  static const Color numberPrimary = Color(0xFF000000); // 짙은 검은색 (숫자용)
  static const Color numberAccent = Color(0xFF000000); // 짙은 검은색 (강조 숫자용)
  static const Color numberSecondary = Color(0xFF000000); // 짙은 검은색 (보조 숫자용)

  // Cost 강조 색상 (번트 오렌지)
  static const Color costEmphasized = Color(0xFFE65100); // 번트 오렌지

  // 그림자 색상
  static const Color shadow = Color(0x0A000000); // 아주 연한 그림자 (Flat 디자인)
  static const Color shadowDark = Color(0x1A000000); // 연한 그림자

  // 구분선 색상
  static const Color divider = Color(0xFFE0E0E0); // 연한 회색
  static const Color dividerLight = Color(0xFFF5F5F5); // 매우 연한 쿨 그레이

  // AI 레시피 관련 색상
  static const Color aiRecipeCard = Color(0xFFFFFFFF); // AI 레시피 카드 배경 (흰색)
  static const Color aiRecipeHeader = Color(0xFFF5F5F5); // AI 레시피 헤더 배경 (밝은 회색)
}
