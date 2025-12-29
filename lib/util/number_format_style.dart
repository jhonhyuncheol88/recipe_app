/// 숫자 포맷팅 스타일
enum NumberFormatStyle {
  /// 천단위 콤마식: 1,000,000
  thousandsComma('thousands_comma', '1,000,000'),

  /// 달러식: 1,000.00 (천단위 콤마, 소수점 점)
  dollarStyle('dollar_style', '1,000.00'),

  /// 유럽식: 100.000.000 (천단위 점, 소수점 콤마)
  europeanStyle('european_style', '100.000.000');

  const NumberFormatStyle(this.key, this.example);

  final String key;
  final String example;

  /// 기본 포맷팅 스타일
  static NumberFormatStyle get defaultStyle => NumberFormatStyle.thousandsComma;

  /// 키로부터 NumberFormatStyle 찾기
  static NumberFormatStyle? fromKey(String key) {
    try {
      return values.firstWhere((style) => style.key == key);
    } catch (e) {
      return null;
    }
  }
}

