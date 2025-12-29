import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'app_locale.dart';
import 'number_format_style.dart';
import 'unit_converter.dart' as uc;

// ThousandsSeparatorInputFormatter를 export
export 'package:flutter/services.dart' show TextInputFormatter;

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
  /// NumberFormatStyle에 따른 NumberFormat 생성
  static NumberFormat _getNumberFormatter(
    NumberFormatStyle style, {
    bool includeDecimals = false,
  }) {
    switch (style) {
      case NumberFormatStyle.thousandsComma:
        return NumberFormat(
          includeDecimals ? '#,##0.00' : '#,###',
          'en_US',
        );
      case NumberFormatStyle.dollarStyle:
        return NumberFormat(
          includeDecimals ? '#,##0.00' : '#,###',
          'en_US',
        );
      case NumberFormatStyle.europeanStyle:
        // 유럽식: 천단위 점, 소수점 콤마
        // NumberFormat 패턴은 항상 .을 소수점으로 사용하고, locale이 자동 변환
        return NumberFormat(
          includeDecimals ? '#,##0.00' : '#,###',
          'de_DE',
        );
    }
  }

  /// 통화 심볼 가져오기 (AppLocale 기반)
  static String _getCurrencySymbol(AppLocale locale) {
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
      case AppLocale.vietnam:
        return '₫';
    }
  }

  /// 통화 소수점 자릿수 가져오기 (AppLocale 기반)
  static int _getCurrencyDecimalDigits(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 0;
      case AppLocale.japan:
        return 0;
      case AppLocale.china:
        return 2;
      case AppLocale.usa:
        return 2;
      case AppLocale.euro:
        return 2;
      case AppLocale.vietnam:
        return 0;
    }
  }

  /// 통화 포맷팅
  /// 소수점 2자리까지 표시하되, .00인 경우는 생략
  static String formatCurrency(
    double amount,
    AppLocale locale,
    NumberFormatStyle formatStyle,
  ) {
    final symbol = _getCurrencySymbol(locale);

    // 항상 소수점 2자리까지 포맷팅
    final formatter = _getNumberFormatter(
      formatStyle,
      includeDecimals: true,
    );

    // 통화 심볼을 수동으로 추가
    String formatted = formatter.format(amount);

    // .00 또는 ,00으로 끝나면 제거 (유럽식은 ,00)
    if (formatted.endsWith('.00')) {
      formatted = formatted.substring(0, formatted.length - 3);
    } else if (formatted.endsWith(',00')) {
      // 유럽식 포맷 (천단위 점, 소수점 콤마)
      formatted = formatted.substring(0, formatted.length - 3);
    }

    return '$symbol$formatted';
  }

  /// 숫자 포맷팅 (천 단위 구분자)
  static String formatNumber(int number, NumberFormatStyle formatStyle) {
    final formatter = _getNumberFormatter(formatStyle);
    return formatter.format(number);
  }

  /// 소수점 숫자 포맷팅
  static String formatDecimal(double number, NumberFormatStyle formatStyle) {
    final formatter = _getNumberFormatter(formatStyle, includeDecimals: true);
    return formatter.format(number);
  }

  /// 퍼센트 포맷팅
  static String formatPercent(double percent, NumberFormatStyle formatStyle) {
    // 퍼센트는 기본적으로 소수점 포함
    final formatter = _getNumberFormatter(formatStyle, includeDecimals: true);
    return '${formatter.format(percent / 100)}%';
  }

  /// 가격 포맷팅 (원화는 정수, 달러는 소수점 2자리, 위안은 소수점 2자리, 엔은 정수)
  static String formatPrice(
    double price,
    AppLocale locale,
    NumberFormatStyle formatStyle,
  ) {
    return formatCurrency(price, locale, formatStyle);
  }

  /// 무게 포맷팅
  static String formatWeight(
    double weight,
    String unit,
    AppLocale locale,
    NumberFormatStyle formatStyle,
  ) {
    final formattedNumber = formatDecimal(weight, formatStyle);

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
      case AppLocale.vietnam:
        return '$formattedNumber$unit';
    }
  }

  /// 수량 포맷팅
  static String formatQuantity(
    int quantity,
    AppLocale locale,
    NumberFormatStyle formatStyle,
  ) {
    final formattedNumber = formatNumber(quantity, formatStyle);

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
      case AppLocale.vietnam:
        return '$formattedNumber cái';
    }
  }

  /// 단위 변환 포맷팅
  static String formatUnit(
    double value,
    String fromUnit,
    String toUnit,
    AppLocale locale,
    NumberFormatStyle formatStyle,
  ) {
    final formattedValue = formatDecimal(value, formatStyle);

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
      case AppLocale.vietnam:
        return '$formattedValue$fromUnit → $formattedValue$toUnit';
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
      case AppLocale.vietnam:
        return '₫';
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
      case AppLocale.vietnam:
        return 'Đồng';
    }
  }

  /// g/ml/개 당 가격 텍스트 (예: g당 ₩120)
  static String formatPerUnitText(
    double unitPrice,
    String unitId,
    AppLocale locale,
    NumberFormatStyle formatStyle,
  ) {
    final unitType = uc.UnitConverter.getUnitType(unitId);
    final label = unitType == uc.UnitType.count
        ? '개당'
        : unitType == uc.UnitType.weight
            ? 'g당'
            : 'ml당';
    return '$label ${formatCurrency(unitPrice, locale, formatStyle)}';
  }

  /// 기본 단위 기준 단가 (예: ₩120 / g)
  static String formatPerBaseUnitPrice(
    double unitPrice,
    String unitId,
    AppLocale locale,
    NumberFormatStyle formatStyle,
  ) {
    final unitType = uc.UnitConverter.getUnitType(unitId);
    final baseSymbol = unitType == uc.UnitType.count
        ? '개'
        : unitType == uc.UnitType.weight
            ? 'g'
            : 'ml';
    return '${formatCurrency(unitPrice, locale, formatStyle)} / $baseSymbol';
  }

  /// AI 분석 결과용 가격 포맷팅 (천 단위 구분자 포함)
  static String formatAiPrice(
    dynamic value,
    AppLocale locale,
    NumberFormatStyle formatStyle,
  ) {
    if (value == null) return formatCurrency(0, locale, formatStyle);

    final strValue = value.toString().trim();
    if (strValue.isEmpty) return formatCurrency(0, locale, formatStyle);

    // 이미 통화 기호가 포함되어 있으면 그대로 반환
    if (strValue.contains('₩') ||
        strValue.contains('¥') ||
        strValue.contains('\$') ||
        strValue.contains('€') ||
        strValue.contains('₫') ||
        strValue.contains('원')) {
      return strValue;
    }

    // 숫자만 있으면 천 단위 구분자와 함께 포맷팅
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(strValue)) {
      final number = double.tryParse(strValue);
      if (number != null) {
        return formatCurrency(number, locale, formatStyle);
      }
    }

    return strValue;
  }

  /// AI 분석 결과용 퍼센트 포맷팅
  static String formatAiPercentage(
    dynamic value,
    NumberFormatStyle formatStyle,
  ) {
    if (value == null) return formatPercent(0, formatStyle);

    final strValue = value.toString().trim();
    if (strValue.isEmpty) return formatPercent(0, formatStyle);

    // 이미 "%"가 포함되어 있으면 그대로 반환
    if (strValue.contains('%')) return strValue;

    // 숫자만 있으면 퍼센트 포맷팅
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(strValue)) {
      final number = double.tryParse(strValue);
      if (number != null) {
        return formatPercent(number, formatStyle);
      }
    }

    return strValue;
  }

  /// AI 분석 결과용 숫자 포맷팅 (천 단위 구분자만)
  static String formatAiNumber(
    dynamic value,
    NumberFormatStyle formatStyle,
  ) {
    if (value == null) return formatNumber(0, formatStyle);

    final strValue = value.toString().trim();
    if (strValue.isEmpty) return formatNumber(0, formatStyle);

    // 숫자만 있으면 천 단위 구분자만 적용
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(strValue)) {
      final number = double.tryParse(strValue);
      if (number != null) {
        return formatNumber(number.round(), formatStyle);
      }
    }

    return strValue;
  }

  /// 가격 문자열을 double로 파싱 (천 단위 구분자, 통화 기호 제거)
  static double? parsePrice(String priceText, NumberFormatStyle formatStyle) {
    if (priceText.isEmpty) return null;

    // 통화 기호와 천 단위 구분자 제거
    String cleanText = priceText.replaceAll(RegExp(r'[₩¥\$€₫원]'), '').trim();

    // 포맷팅 스타일에 따라 구분자 제거
    switch (formatStyle) {
      case NumberFormatStyle.thousandsComma:
      case NumberFormatStyle.dollarStyle:
        // 콤마 제거
        cleanText = cleanText.replaceAll(',', '');
        break;
      case NumberFormatStyle.europeanStyle:
        // 유럽식: 점을 제거하고 콤마를 점으로 변환
        cleanText = cleanText.replaceAll('.', '');
        cleanText = cleanText.replaceAll(',', '.');
        break;
    }

    return double.tryParse(cleanText);
  }

  /// 수량 문자열을 double로 파싱
  static double? parseAmount(String amountText) {
    if (amountText.isEmpty) return null;

    // 공백과 특수문자 제거
    final cleanText = amountText.trim();

    return double.tryParse(cleanText);
  }
}
