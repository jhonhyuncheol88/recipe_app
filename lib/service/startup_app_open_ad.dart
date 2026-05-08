import 'dart:async';
import 'dart:io' show Platform;

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admob_forward.dart';
import 'app_open_ad_service.dart';

/// cold start 부팅 시퀀스·온보딩 완료 직후 공통 앱 오픈 광고 흐름.
class StartupAppOpenAd {
  StartupAppOpenAd._();

  static const String _lastAdShownKey = 'last_ad_shown_time_millis';
  static const int _tenMinutesInMillis = 10 * 60 * 1000;

  /// AdMob 초기화 후 앱 오픈 광고 1회 시도 (10분 쿨다운).
  ///
  /// [loadGrace] — cold start 는 네트워크 여유를 위해 2초 권장,
  /// 온보딩 직후는 [Duration.zero] 로 바로 시도.
  static Future<void> runAppOpenFlow(
    Logger logger, {
    Duration loadGrace = const Duration(seconds: 2),
  }) async {
    logger.i('📱 AdMob 초기화 시도 (${Platform.operatingSystem})');
    try {
      await AdMobForwardService.instance.initialize();
      logger.i('✅ AdMob 초기화 완료');
      unawaited(AppOpenAdService.instance.preload());
      await _showWithCooldown(logger, loadGrace: loadGrace);
    } catch (e, st) {
      logger.e('⚠️ AdMob / 앱 오픈 광고 흐름 실패(무시): $e', stackTrace: st);
    }
  }

  static Future<void> _showWithCooldown(
    Logger logger, {
    required Duration loadGrace,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAdShownTimeMillis = prefs.getInt(_lastAdShownKey) ?? 0;
      final currentTimeMillis = DateTime.now().millisecondsSinceEpoch;

      if (currentTimeMillis - lastAdShownTimeMillis < _tenMinutesInMillis) {
        final remainingMinutes =
            (_tenMinutesInMillis - (currentTimeMillis - lastAdShownTimeMillis)) ~/
                (60 * 1000);
        logger.d('ℹ️ App Open 광고 쿨다운 중. ${remainingMinutes + 1}분 후 다시 표시 가능.');
        return;
      }

      logger.i('📺 앱 오픈 광고 표시 시도');
      if (loadGrace > Duration.zero) {
        await Future<void>.delayed(loadGrace);
      }

      final shown = await AppOpenAdService.instance.showIfAvailable();
      if (shown) {
        await prefs.setInt(_lastAdShownKey, currentTimeMillis);
        logger.i('✅ 앱 오픈 광고 표시 완료 (10분 후 다시 표시 가능)');
      } else {
        logger.w('⚠️ 앱 오픈 광고 표시 실패 (광고 미준비)');
      }
    } catch (e, st) {
      logger.w('⚠️ 앱 오픈 광고 표시 체크 중 오류 (무시): $e\n$st');
    }
  }
}
