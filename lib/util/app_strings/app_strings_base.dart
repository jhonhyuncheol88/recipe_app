import '../app_locale.dart';

/// 기본 앱 정보 관련 문자열
mixin AppStringsBase {
  /// 앱 제목
  static String getAppTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원까';
      case AppLocale.japan:
        return '原価カ';
      case AppLocale.china:
        return '原价卡';
      case AppLocale.usa:
        return 'Wonka';
      case AppLocale.euro:
        return 'Wonka';
      case AppLocale.vietnam:
        return 'Wonka';
    }
  }
}
