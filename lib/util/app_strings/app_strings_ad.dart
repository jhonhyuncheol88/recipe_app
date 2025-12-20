import '../app_locale.dart';

/// Ad 관련 문자열
mixin AppStringsAd {
  /// 광고 다이얼로그 관련 텍스트
  static String getWatchAd(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고 시청하기';
      case AppLocale.japan:
        return '広告を視聴';
      case AppLocale.china:
        return '观看广告';
      case AppLocale.usa:
        return 'Watch Ad';
      case AppLocale.euro:
        return 'Watch Ad';
      case AppLocale.vietnam:
        return 'Xem quảng cáo';
    }
  }

  static String getAdLoadFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고 로드에 실패했습니다. 잠시 후 다시 시도해주세요.';
      case AppLocale.japan:
        return '広告の読み込みに失敗しました。しばらくしてからもう一度お試しください。';
      case AppLocale.china:
        return '广告加载失败。请稍后再试。';
      case AppLocale.usa:
        return 'Failed to load ad. Please try again later.';
      case AppLocale.euro:
        return 'Failed to load ad. Please try again later.';
      case AppLocale.vietnam:
        return 'Không thể tải quảng cáo. Vui lòng thử lại sau.';
    }
  }
}
