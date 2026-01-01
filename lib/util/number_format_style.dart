/// 숫자 포맷팅 스타일
enum NumberFormatStyle {
  /// 천단위 콤마식 (1,000,000)
  thousandsComma,

  /// 달러식 (1,000.00)
  dollarStyle,

  /// 유럽식 (100.000.000)
  europeanStyle;

  /// 기본 스타일
  static NumberFormatStyle get defaultStyle => NumberFormatStyle.thousandsComma;

  /// 키 값으로 스타일 찾기
  static NumberFormatStyle? fromKey(String key) {
    for (final style in NumberFormatStyle.values) {
      if (style.key == key) {
        return style;
      }
    }
    return null;
  }

  /// 스타일의 키 값
  String get key {
    switch (this) {
      case NumberFormatStyle.thousandsComma:
        return 'thousands_comma';
      case NumberFormatStyle.dollarStyle:
        return 'dollar_style';
      case NumberFormatStyle.europeanStyle:
        return 'european_style';
    }
  }
}
