import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:recipe_app/config/env.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// 보상형(Rewarded) 광고 전용 서비스.
///
/// 정책:
/// - OCR(영수증 AI 분석)이 완료된 직후 자연스러운 흐름으로 1회 노출한다.
///   호출처는 [OcrResultPage] 의 `OcrGeminiCompleted` 리스너.
/// - 전면([AdMobForwardService]) / 앱 열기([AppOpenAdService]) / 배너
///   ([BannerAdService]) 와 ID·수명·flag 가 모두 다르므로 별도 싱글톤으로 분리.
/// - Premium 사용자는 광고를 스킵 (gate callback 으로 매번 조회).
/// - 디버그 빌드에서는 *_TEST 키만 사용해 운영 광고에 테스트 트래픽이 섞이지 않게 한다.
class RewardedAdService {
  static RewardedAdService? _instance;
  static RewardedAdService get instance =>
      _instance ??= RewardedAdService._internal();

  late final Logger _logger;

  RewardedAd? _preloadedAd;

  /// 진행 중인 로드. preload 와 show 가 동시에 호출돼도 같은 future 를 공유해
  /// race / 중복 로드 / "이미 로드 중" 으로 인한 광고 누락을 막는다.
  Completer<RewardedAd?>? _loadCompleter;
  bool _isShowing = false;
  bool Function()? _premiumGate;

  RewardedAdService._internal() {
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
    _logger.i('[Rewarded] Premium gate 등록 완료');
  }

  // ---------------------------------------------------------------------------
  // 광고 단위 ID 결정
  // ---------------------------------------------------------------------------

  /// 디버그 빌드에서는 무조건 *_TEST 키만 사용. prod ID 호출 가능성을 차단해
  /// 실수로 테스트 트래픽이 운영 광고에 집계되는 것을 방지.
  /// *_TEST 키가 .env 에 없으면 Google 공식 sample test ID 로 fallback.
  /// 릴리즈 빌드에서는 prod 키 사용. 없으면 throw.
  String getRewardedAdUnitId() {
    if (kDebugMode) {
      final testKey = Platform.isAndroid
          ? 'ADMOB_ANDROID_REWARDED_ID_TEST'
          : 'ADMOB_IOS_REWARDED_ID_TEST';
      final testFromEnv = Env.get(testKey);
      if (testFromEnv != null && testFromEnv.isNotEmpty) {
        _logger.d('[Rewarded] 디버그 — env 테스트 ID 사용: $testFromEnv');
        return testFromEnv;
      }
      _logger.w('[Rewarded] 디버그 — $testKey 미설정, Google sample test ID 사용');
      return _googleSampleTestId();
    }

    final prodKey = Platform.isAndroid
        ? 'ADMOB_ANDROID_REWARDED_ID'
        : 'ADMOB_IOS_REWARDED_ID';
    final prodId = Env.get(prodKey);
    if (prodId != null && prodId.isNotEmpty) {
      _logger.i('[Rewarded] 프로덕션 ID 사용: $prodId');
      return prodId;
    }

    throw Exception('$prodKey 가 설정되지 않았습니다. .env 파일을 확인해주세요.');
  }

  String _googleSampleTestId() {
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';
  }

  // ---------------------------------------------------------------------------
  // 로드
  // ---------------------------------------------------------------------------

  /// 광고 로드. 이미 진행 중인 로드가 있으면 같은 future 를 공유한다.
  Future<RewardedAd?> loadRewardedAd() {
    if (_premiumGate?.call() == true) {
      _logger.d('[Rewarded] Premium — 로드 스킵');
      return Future<RewardedAd?>.value(null);
    }

    final inflight = _loadCompleter;
    if (inflight != null) {
      _logger.d('[Rewarded] 진행 중인 로드에 합류');
      return inflight.future;
    }
    final completer = Completer<RewardedAd?>();
    _loadCompleter = completer;

    try {
      final adUnitId = getRewardedAdUnitId();
      _logger.i('[Rewarded] 로드 시작 ($adUnitId)');

      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _logger.i('[Rewarded] 로드 성공');
            if (!completer.isCompleted) completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            _logger.e('[Rewarded] 로드 실패: ${error.message} '
                '(code=${error.code}, domain=${error.domain})');
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );
    } catch (e) {
      _logger.e('[Rewarded] 로드 중 오류: $e');
      if (!completer.isCompleted) completer.complete(null);
    }

    return completer.future
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _logger.w('[Rewarded] 로드 타임아웃');
        if (!completer.isCompleted) completer.complete(null);
        return null;
      },
    )
        .whenComplete(() {
      if (identical(_loadCompleter, completer)) {
        _loadCompleter = null;
      }
    });
  }

  /// 다음 노출에 대비해 광고를 미리 로드.
  /// OCR 분석 시작(OcrGeminiAnalyzing) 시점에 호출하면 완료 시 대기 없이 노출된다.
  Future<void> preload() async {
    if (_premiumGate?.call() == true) {
      _logger.d('[Rewarded] Premium — preload 스킵');
      return;
    }
    if (_preloadedAd != null) {
      _logger.d('[Rewarded] preload skip — 이미 캐시 있음');
      return;
    }
    final ad = await loadRewardedAd();
    if (ad == null) return;
    // 동시에 호출된 show 가 같은 ad 를 사용 중일 수 있으므로 캐시 중복을 방지.
    if (_isShowing || _preloadedAd != null) {
      _logger.d('[Rewarded] preload — 이미 사용 중인 ad, 캐시하지 않음');
      await ad.dispose();
      return;
    }
    _preloadedAd = ad;
    _logger.i('[Rewarded] preload 완료');
  }

  // ---------------------------------------------------------------------------
  // 표시
  // ---------------------------------------------------------------------------

  /// 보상형 광고 표시.
  /// 반환: 광고가 표시(또는 premium skip)되었으면 true, 표시할 광고가 없거나
  /// 표시 실패 시 false.
  /// - Premium 사용자 → 즉시 true (스킵)
  /// - 이미 표시 중 → false
  /// - 캐시 광고 없으면 즉시 1회 로드 시도
  /// [onUserEarnedReward] 는 사용자가 보상 조건(끝까지 시청)을 충족했을 때 호출된다.
  Future<bool> showIfAvailable({
    void Function(RewardItem reward)? onUserEarnedReward,
  }) async {
    if (_premiumGate?.call() == true) {
      _logger.i('[Rewarded] 🎟️ Premium — 광고 스킵');
      return true;
    }
    if (_isShowing) {
      _logger.d('[Rewarded] 이미 표시 중 — skip');
      return false;
    }

    RewardedAd? ad = _preloadedAd;
    _preloadedAd = null;

    ad ??= await loadRewardedAd();

    if (ad == null) {
      _logger.w('[Rewarded] 표시 가능한 광고 없음');
      return false;
    }

    final completer = Completer<bool>();
    _isShowing = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _logger.d('[Rewarded] 표시 시작');
      },
      onAdDismissedFullScreenContent: (ad) {
        _logger.d('[Rewarded] 닫힘');
        _isShowing = false;
        ad.dispose();
        // 다음 노출 대비 미리 로드
        unawaited(preload());
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logger.e('[Rewarded] 표시 실패: ${error.message}');
        _isShowing = false;
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdImpression: (ad) {
        _logger.d('[Rewarded] 노출됨');
      },
      onAdClicked: (ad) {
        _logger.d('[Rewarded] 클릭됨');
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          _logger.i('[Rewarded] 보상 획득: ${reward.amount} ${reward.type}');
          onUserEarnedReward?.call(reward);
        },
      );
    } catch (e) {
      _logger.e('[Rewarded] show() 오류: $e');
      _isShowing = false;
      ad.dispose();
      return false;
    }

    return completer.future.timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        _logger.w('[Rewarded] 표시 타임아웃');
        _isShowing = false;
        return false;
      },
    );
  }
}
