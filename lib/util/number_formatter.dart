import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'app_locale.dart';

/// 천 단위 구분자 입력 포맷터
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 콤마 제거
    final text = newValue.text.replaceAll(',', '');

    // 숫자가 아닌 문자 제거
    final cleanText = text.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 숫자로 변환
    final number = int.tryParse(cleanText);
    if (number == null) {
      return oldValue;
    }

    // 천 단위 구분자 추가
    final formattedText = NumberFormat('#,###', 'ko_KR').format(number);

    return newValue.copyWith(text: formattedText);
  }
}

/// 국가별 숫자 포맷팅 유틸리티
class NumberFormatter {
  static final Map<AppLocale, NumberFormat> _currencyFormatters = {
    AppLocale.korea: NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    ),
    AppLocale.japan: NumberFormat.currency(
      locale: 'ja_JP',
      symbol: '¥',
      decimalDigits: 0,
    ),
    AppLocale.china: NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 2,
    ),
    AppLocale.usa: NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    ),
    AppLocale.euro: NumberFormat.currency(
      locale: 'de_DE',
      symbol: '€',
      decimalDigits: 2,
    ),
  };

  static final Map<AppLocale, NumberFormat> _numberFormatters = {
    AppLocale.korea: NumberFormat('#,###', 'ko_KR'),
    AppLocale.japan: NumberFormat('#,###', 'ja_JP'),
    AppLocale.china: NumberFormat('#,###', 'zh_CN'),
    AppLocale.usa: NumberFormat('#,###', 'en_US'),
    AppLocale.euro: NumberFormat('#,###', 'de_DE'),
  };

  static final Map<AppLocale, NumberFormat> _decimalFormatters = {
    AppLocale.korea: NumberFormat('#,##0.00', 'ko_KR'),
    AppLocale.japan: NumberFormat('#,##0.00', 'ja_JP'),
    AppLocale.china: NumberFormat('#,##0.00', 'zh_CN'),
    AppLocale.usa: NumberFormat('#,##0.00', 'en_US'),
    AppLocale.euro: NumberFormat('#,##0.00', 'de_DE'),
  };

  static final Map<AppLocale, NumberFormat> _percentFormatters = {
    AppLocale.korea: NumberFormat.percentPattern('ko_KR'),
    AppLocale.japan: NumberFormat.percentPattern('ja_JP'),
    AppLocale.china: NumberFormat.percentPattern('zh_CN'),
    AppLocale.usa: NumberFormat.percentPattern('en_US'),
    AppLocale.euro: NumberFormat.percentPattern('de_DE'),
  };

  /// 통화 포맷팅
  static String formatCurrency(double amount, AppLocale locale) {
    return _currencyFormatters[locale]?.format(amount) ?? amount.toString();
  }

  /// 숫자 포맷팅 (천 단위 구분자)
  static String formatNumber(int number, AppLocale locale) {
    return _numberFormatters[locale]?.format(number) ?? number.toString();
  }

  /// 소수점 숫자 포맷팅
  static String formatDecimal(double number, AppLocale locale) {
    return _decimalFormatters[locale]?.format(number) ?? number.toString();
  }

  /// 퍼센트 포맷팅
  static String formatPercent(double percent, AppLocale locale) {
    return _percentFormatters[locale]?.format(percent) ?? '${percent}%';
  }

  /// 가격 포맷팅 (원화는 정수, 달러는 소수점 2자리)
  static String formatPrice(double price, AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return NumberFormat.currency(
          locale: 'ko_KR',
          symbol: '₩',
          decimalDigits: 0,
        ).format(price);
      case AppLocale.japan:
        return NumberFormat.currency(
          locale: 'ja_JP',
          symbol: '¥',
          decimalDigits: 0,
        ).format(price);
      case AppLocale.china:
        return NumberFormat.currency(
          locale: 'zh_CN',
          symbol: '¥',
          decimalDigits: 2,
        ).format(price);
      case AppLocale.usa:
        return NumberFormat.currency(
          locale: 'en_US',
          symbol: '\$',
          decimalDigits: 2,
        ).format(price);
      case AppLocale.euro:
        return NumberFormat.currency(
          locale: 'de_DE',
          symbol: '€',
          decimalDigits: 2,
        ).format(price);
    }
  }

  /// 무게 포맷팅
  static String formatWeight(double weight, String unit, AppLocale locale) {
    final formattedNumber =
        _decimalFormatters[locale]?.format(weight) ?? weight.toString();

    switch (locale) {
      case AppLocale.korea:
        return '$formattedNumber$unit';
      case AppLocale.japan:
        return '$formattedNumber$unit';
      case AppLocale.china:
        return '$formattedNumber$unit';
      case AppLocale.usa:
        return '$formattedNumber $unit';
      case AppLocale.euro:
        return '$formattedNumber $unit';
    }
  }

  /// 수량 포맷팅
  static String formatQuantity(int quantity, AppLocale locale) {
    final formattedNumber =
        _numberFormatters[locale]?.format(quantity) ?? quantity.toString();

    switch (locale) {
      case AppLocale.korea:
        return '${formattedNumber}개';
      case AppLocale.japan:
        return '${formattedNumber}個';
      case AppLocale.china:
        return '${formattedNumber}个';
      case AppLocale.usa:
        return '$formattedNumber pcs';
      case AppLocale.euro:
        return '$formattedNumber Stk';
    }
  }

  /// 단위 변환 포맷팅
  static String formatUnit(
    double value,
    String fromUnit,
    String toUnit,
    AppLocale locale,
  ) {
    final formattedValue =
        _decimalFormatters[locale]?.format(value) ?? value.toString();

    switch (locale) {
      case AppLocale.korea:
        return '$formattedValue$fromUnit → $formattedValue$toUnit';
      case AppLocale.japan:
        return '$formattedValue$fromUnit → $formattedValue$toUnit';
      case AppLocale.china:
        return '$formattedValue$fromUnit → $formattedValue$toUnit';
      case AppLocale.usa:
        return '$formattedValue $fromUnit → $formattedValue $toUnit';
      case AppLocale.euro:
        return '$formattedValue $fromUnit → $formattedValue $toUnit';
    }
  }

  /// 통화 심볼 가져오기
  static String getCurrencySymbol(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '₩';
      case AppLocale.japan:
        return '¥';
      case AppLocale.china:
        return '¥';
      case AppLocale.usa:
        return '\$';
      case AppLocale.euro:
        return '€';
    }
  }

  /// 통화명 가져오기
  static String getCurrencyName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원';
      case AppLocale.japan:
        return '円';
      case AppLocale.china:
        return '元';
      case AppLocale.usa:
        return 'Dollar';
      case AppLocale.euro:
        return 'Euro';
    }
  }
}
