import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// 앱 오픈(App Open) 광고 전용 서비스.
///
/// 정책:
/// - 앱 cold start 직후 1회 노출. 다른 앱에서 복귀(resume)할 때는 호출하지 않는다.
/// - 전면(interstitial) 광고와 ID·수명·flag 가 모두 다르므로 [AdMobForwardService] 와는
///   별도의 싱글톤으로 분리.
/// - Premium 사용자는 광고를 스킵 (gate callback 으로 매번 조회).
class AppOpenAdService {
  static AppOpenAdService? _instance;
  static AppOpenAdService get instance =>
      _instance ??= AppOpenAdService._internal();

  late final Logger _logger;

  AppOpenAd? _preloadedAd;
  /// 진행 중인 로드. preload 와 showIfAvailable 이 동시에 호출돼도 같은 future 를
  /// 공유해 race / 중복 로드 / "이미 로드 중" 으로 인한 광고 누락을 막는다.
  Completer<AppOpenAd?>? _loadCompleter;
  bool _isShowing = false;
  bool Function()? _premiumGate;

  AppOpenAdService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    );
  }

  /// PremiumCubit.state.isPremium 게이트. main.dart 의 PremiumCubit 생성 시 등록.
  void setPremiumGate(bool Function() gate) {
    _premiumGate = gate;
    _logger.i('[AppOpenAd] Premium gate 등록 완료');
  }

  // ---------------------------------------------------------------------------
  // 광고 단위 ID 결정
  // ---------------------------------------------------------------------------

  /// 디버그 빌드에서는 무조건 *_TEST 키만 사용. prod ID 호출 가능성을 차단해
  /// 실수로 테스트 트래픽이 운영 광고에 집계되는 것을 방지.
  /// *_TEST 키가 .env 에 없으면 Google 공식 sample test ID 로 fallback.
  /// 릴리즈 빌드에서는 prod 키 사용. 없으면 throw.
  String getAppOpenAdUnitId() {
    if (kDebugMode) {
      final testKey = Platform.isAndroid
          ? 'ADMOB_ANDROID_APP_OPEN_ID_TEST'
          : 'ADMOB_IOS_APP_OPEN_ID_TEST';
      final testFromEnv = dotenv.env[testKey];
      if (testFromEnv != null && testFromEnv.isNotEmpty) {
        _logger.d('[AppOpenAd] 디버그 — env 테스트 ID 사용: $testFromEnv');
        return testFromEnv;
      }
      _logger.w('[AppOpenAd] 디버그 — $testKey 미설정, Google sample test ID 사용');
      return _googleSampleTestId();
    }

    final prodKey = Platform.isAndroid
        ? 'ADMOB_ANDROID_APP_OPEN_ID'
        : 'ADMOB_IOS_APP_OPEN_ID';
    final prodId = dotenv.env[prodKey];
    if (prodId != null && prodId.isNotEmpty) {
      _logger.i('[AppOpenAd] 프로덕션 ID 사용: $prodId');
      return prodId;
    }

    throw Exception('$prodKey 가 설정되지 않았습니다. .env 파일을 확인해주세요.');
  }

  String _googleSampleTestId() {
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/9257395921'
        : 'ca-app-pub-3940256099942544/5575463023';
  }

  // ---------------------------------------------------------------------------
  // 로드
  // ---------------------------------------------------------------------------

  /// 광고 로드. 이미 진행 중인 로드가 있으면 같은 future 를 공유한다.
  /// 동시 호출자가 모두 같은 광고 객체(또는 null)를 받게 해 race 를 제거.
  Future<AppOpenAd?> loadAppOpenAd() {
    if (_premiumGate?.call() == true) {
      _logger.d('[AppOpenAd] Premium — 로드 스킵');
      return Future<AppOpenAd?>.value(null);
    }

    final inflight = _loadCompleter;
    if (inflight != null) {
      _logger.d('[AppOpenAd] 진행 중인 로드에 합류');
      return inflight.future;
    }
    final completer = Completer<AppOpenAd?>();
    _loadCompleter = completer;

    try {
      final adUnitId = getAppOpenAdUnitId();
      _logger.i('[AppOpenAd] 로드 시작 ($adUnitId)');

      AppOpenAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _logger.i('[AppOpenAd] 로드 성공');
            if (!completer.isCompleted) completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            _logger.e('[AppOpenAd] 로드 실패: ${error.message} '
                '(code=${error.code}, domain=${error.domain})');
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );
    } catch (e) {
      _logger.e('[AppOpenAd] 로드 중 오류: $e');
      if (!completer.isCompleted) completer.complete(null);
    }

    return completer.future
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _logger.w('[AppOpenAd] 로드 타임아웃');
        if (!completer.isCompleted) completer.complete(null);
        return null;
      },
    )
        .whenComplete(() {
      // completer 가 동일하면 _loadCompleter 정리 (이미 다른 로드가 시작됐다면 보존)
      if (identical(_loadCompleter, completer)) {
        _loadCompleter = null;
      }
    });
  }

  /// 다음 노출에 대비해 광고를 미리 로드.
  /// 이미 캐시에 있거나 다른 호출자가 광고를 가져갔으면 no-op.
  Future<void> preload() async {
    if (_premiumGate?.call() == true) {
      _logger.d('[AppOpenAd] Premium — preload 스킵');
      return;
    }

    if (_preloadedAd != null) {
      _logger.d('[AppOpenAd] preload skip — 이미 캐시 있음');
      return;
    }
    final ad = await loadAppOpenAd();
    if (ad == null) return;
    // 동시에 호출된 showIfAvailable() 가 같은 ad 를 사용 중일 수 있으므로
    // 표시 중이거나 이미 다른 캐시가 채워져 있으면 캐시하지 않는다.
    if (_isShowing || _preloadedAd != null) {
      _logger.d('[AppOpenAd] preload — 이미 사용 중인 ad, 캐시하지 않음');
      return;
    }
    _preloadedAd = ad;
    _logger.i('[AppOpenAd] preload 완료');
  }

  // ---------------------------------------------------------------------------
  // 표시
  // ---------------------------------------------------------------------------

  /// 앱 오픈 광고 표시.
  /// 반환: 광고가 표시(또는 skip) 되었으면 true, 표시 실패 시 false.
  /// - Premium 사용자 → 즉시 true (스킵)
  /// - 이미 표시 중 → false
  /// - 캐시 광고 없으면 즉시 1회 로드 시도
  Future<bool> showIfAvailable() async {
    if (_premiumGate?.call() == true) {
      _logger.i('[AppOpenAd] 🎟️ Premium — 광고 스킵');
      return true;
    }
    if (_isShowing) {
      _logger.d('[AppOpenAd] 이미 표시 중 — skip');
      return false;
    }

    AppOpenAd? ad = _preloadedAd;
    _preloadedAd = null;

    ad ??= await loadAppOpenAd();

    if (ad == null) {
      _logger.w('[AppOpenAd] 표시 가능한 광고 없음');
      return false;
    }

    final completer = Completer<bool>();
    _isShowing = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _logger.d('[AppOpenAd] 표시 시작');
      },
      onAdDismissedFullScreenContent: (ad) {
        _logger.d('[AppOpenAd] 닫힘');
        _isShowing = false;
        ad.dispose();
        // 다음 cold start 대비 미리 로드
        unawaited(preload());
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logger.e('[AppOpenAd] 표시 실패: ${error.message}');
        _isShowing = false;
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdImpression: (ad) {
        _logger.d('[AppOpenAd] 노출됨');
      },
      onAdClicked: (ad) {
        _logger.d('[AppOpenAd] 클릭됨');
      },
    );

    try {
      await ad.show();
    } catch (e) {
      _logger.e('[AppOpenAd] show() 오류: $e');
      _isShowing = false;
      ad.dispose();
      return false;
    }

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _logger.w('[AppOpenAd] 표시 타임아웃');
        _isShowing = false;
        return false;
      },
    );
  }
}
