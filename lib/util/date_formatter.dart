import 'package:intl/intl.dart';
import 'app_locale.dart';

/// 국가별 날짜 포맷팅 유틸리티
class DateFormatter {
  static final Map<AppLocale, DateFormat> _dateFormatters = {
    AppLocale.korea: DateFormat('yyyy년 MM월 dd일', 'ko_KR'),
    AppLocale.japan: DateFormat('yyyy年MM月dd日', 'ja_JP'),
    AppLocale.china: DateFormat('yyyy年MM月dd日', 'zh_CN'),
    AppLocale.usa: DateFormat('MMM dd, yyyy', 'en_US'),
    AppLocale.euro: DateFormat('dd.MM.yyyy', 'de_DE'),
  };

  static final Map<AppLocale, DateFormat> _timeFormatters = {
    AppLocale.korea: DateFormat('HH:mm', 'ko_KR'),
    AppLocale.japan: DateFormat('HH:mm', 'ja_JP'),
    AppLocale.china: DateFormat('HH:mm', 'zh_CN'),
    AppLocale.usa: DateFormat('h:mm a', 'en_US'),
    AppLocale.euro: DateFormat('HH:mm', 'de_DE'),
  };

  static final Map<AppLocale, DateFormat> _dateTimeFormatters = {
    AppLocale.korea: DateFormat('yyyy년 MM월 dd일 HH:mm', 'ko_KR'),
    AppLocale.japan: DateFormat('yyyy年MM月dd日 HH:mm', 'ja_JP'),
    AppLocale.china: DateFormat('yyyy年MM月dd日 HH:mm', 'zh_CN'),
    AppLocale.usa: DateFormat('MMM dd, yyyy h:mm a', 'en_US'),
    AppLocale.euro: DateFormat('dd.MM.yyyy HH:mm', 'de_DE'),
  };

  static final Map<AppLocale, DateFormat> _shortDateFormatters = {
    AppLocale.korea: DateFormat('MM/dd', 'ko_KR'),
    AppLocale.japan: DateFormat('MM/dd', 'ja_JP'),
    AppLocale.china: DateFormat('MM/dd', 'zh_CN'),
    AppLocale.usa: DateFormat('MM/dd', 'en_US'),
    AppLocale.euro: DateFormat('dd.MM', 'de_DE'),
  };

  /// 날짜 포맷팅
  static String formatDate(DateTime date, AppLocale locale) {
    return _dateFormatters[locale]?.format(date) ?? date.toString();
  }

  /// 시간 포맷팅
  static String formatTime(DateTime time, AppLocale locale) {
    return _timeFormatters[locale]?.format(time) ?? time.toString();
  }

  /// 날짜와 시간 포맷팅
  static String formatDateTime(DateTime dateTime, AppLocale locale) {
    return _dateTimeFormatters[locale]?.format(dateTime) ?? dateTime.toString();
  }

  /// 짧은 날짜 포맷팅
  static String formatShortDate(DateTime date, AppLocale locale) {
    return _shortDateFormatters[locale]?.format(date) ?? date.toString();
  }

  /// 상대적 시간 포맷팅 (예: 3일 전, 1시간 전)
  static String formatRelativeTime(DateTime date, AppLocale locale) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      switch (locale) {
        case AppLocale.korea:
          return '${difference.inDays}일 전';
        case AppLocale.japan:
          return '${difference.inDays}日前';
        case AppLocale.china:
          return '${difference.inDays}天前';
        case AppLocale.usa:
          return '${difference.inDays} days ago';
        case AppLocale.euro:
          return 'vor ${difference.inDays} Tagen';
      }
    } else if (difference.inHours > 0) {
      switch (locale) {
        case AppLocale.korea:
          return '${difference.inHours}시간 전';
        case AppLocale.japan:
          return '${difference.inHours}時間前';
        case AppLocale.china:
          return '${difference.inHours}小时前';
        case AppLocale.usa:
          return '${difference.inHours} hours ago';
        case AppLocale.euro:
          return 'vor ${difference.inHours} Stunden';
      }
    } else if (difference.inMinutes > 0) {
      switch (locale) {
        case AppLocale.korea:
          return '${difference.inMinutes}분 전';
        case AppLocale.japan:
          return '${difference.inMinutes}分前';
        case AppLocale.china:
          return '${difference.inMinutes}分钟前';
        case AppLocale.usa:
          return '${difference.inMinutes} minutes ago';
        case AppLocale.euro:
          return 'vor ${difference.inMinutes} Minuten';
      }
    } else {
      switch (locale) {
        case AppLocale.korea:
          return '방금 전';
        case AppLocale.japan:
          return '今';
        case AppLocale.china:
          return '刚刚';
        case AppLocale.usa:
          return 'Just now';
        case AppLocale.euro:
          return 'Gerade eben';
      }
    }
  }

  /// 유통기한 상태 텍스트
  static String getExpiryStatusText(DateTime expiryDate, AppLocale locale) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);

    if (difference.isNegative) {
      // 만료됨
      switch (locale) {
        case AppLocale.korea:
          return '만료됨';
        case AppLocale.japan:
          return '期限切れ';
        case AppLocale.china:
          return '已过期';
        case AppLocale.usa:
          return 'Expired';
        case AppLocale.euro:
          return 'Abgelaufen';
      }
    } else if (difference.inDays <= 1) {
      // 위험
      switch (locale) {
        case AppLocale.korea:
          return '위험';
        case AppLocale.japan:
          return '危険';
        case AppLocale.china:
          return '危险';
        case AppLocale.usa:
          return 'Danger';
        case AppLocale.euro:
          return 'Gefahr';
      }
    } else if (difference.inDays <= 3) {
      // 경고
      switch (locale) {
        case AppLocale.korea:
          return '경고';
        case AppLocale.japan:
          return '警告';
        case AppLocale.china:
          return '警告';
        case AppLocale.usa:
          return 'Warning';
        case AppLocale.euro:
          return 'Warnung';
      }
    } else {
      // 정상
      switch (locale) {
        case AppLocale.korea:
          return '정상';
        case AppLocale.japan:
          return '正常';
        case AppLocale.china:
          return '正常';
        case AppLocale.usa:
          return 'Normal';
        case AppLocale.euro:
          return 'Normal';
      }
    }
  }
}
