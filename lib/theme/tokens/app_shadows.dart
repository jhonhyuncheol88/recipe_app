import 'package:flutter/material.dart';

/// Wanted DS elevation tokens.
///
/// 라이트 톤 기준의 그림자 정의. 다크 모드는 보더 / 배경 톤 차이로
/// 입체감을 표현하므로 그림자를 거의 사용하지 않음.
class AppShadows {
  AppShadows._();

  /// `0 1px 2px rgba(23,23,23,0.05), 0 1px 1px rgba(23,23,23,0.06)`
  static const List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Color(0x0D171717), // 5%
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F171717), // 6%
      blurRadius: 1,
      offset: Offset(0, 1),
    ),
  ];

  /// `0 2px 6px rgba(23,23,23,0.07), 0 1px 2px rgba(23,23,23,0.06)`
  static const List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Color(0x12171717), // 7%
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0F171717),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// `0 6px 16px rgba(23,23,23,0.10), 0 2px 4px rgba(23,23,23,0.06)`
  static const List<BoxShadow> shadow3 = [
    BoxShadow(
      color: Color(0x1A171717), // 10%
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x0F171717),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// `0 16px 48px rgba(0,0,0,0.12), 0 2px 8px rgba(0,0,0,0.08)`
  static const List<BoxShadow> overlay = [
    BoxShadow(
      color: Color(0x1F000000), // 12%
      blurRadius: 48,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x14000000), // 8%
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
