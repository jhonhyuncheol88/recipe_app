import 'package:flutter/material.dart';

/// 앱에서 지원하는 국가별 로케일 정보
enum AppLocale {
  korea('ko', 'KR', '한국어', '🇰🇷'),
  japan('ja', 'JP', '日本語', '🇯🇵'),
  china('zh', 'CN', '中文', '🇨🇳'),
  usa('en', 'US', 'English', '🇺🇸'),
  euro('de', 'DE', 'Deutsch', '🇪🇺'),
  vietnam('vi', 'VN', 'Tiếng Việt', '🇻🇳');

  const AppLocale(
    this.languageCode,
    this.countryCode,
    this.displayName,
    this.flag,
  );

  final String languageCode;
  final String countryCode;
  final String displayName;
  final String flag;

  /// 네이티브 언어 이름 (민족어로 표기)
  String get nativeName {
    switch (this) {
      case AppLocale.korea:
        return '한국어';
      case AppLocale.japan:
        return '日本語';
      case AppLocale.china:
        return '中文';
      case AppLocale.usa:
        return 'English';
      case AppLocale.euro:
        return 'Deutsch';
      case AppLocale.vietnam:
        return 'Tiếng Việt';
    }
  }

  /// Locale 객체 생성
  Locale get locale => Locale(languageCode, countryCode);

  /// 언어 코드와 국가 코드 조합
  String get localeString => '${languageCode}_$countryCode';

  /// 지원하는 모든 로케일 목록
  static List<Locale> get supportedLocales =>
      values.map((e) => e.locale).toList();

  /// 기본 로케일 (한국)
  static AppLocale get defaultLocale => AppLocale.korea;

  /// 로케일 코드로 AppLocale 찾기
  static AppLocale? fromLocaleCode(String localeCode) {
    try {
      return values.firstWhere((locale) => locale.localeString == localeCode);
    } catch (e) {
      return null;
    }
  }

  /// 언어 코드로 AppLocale 찾기
  static AppLocale? fromLanguageCode(String languageCode) {
    try {
      return values.firstWhere((locale) => locale.languageCode == languageCode);
    } catch (e) {
      return null;
    }
  }
}
