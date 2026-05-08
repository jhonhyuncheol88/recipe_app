import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

/// 배너 광고 ID 해석 + Premium 게이팅 진입점.
///
/// `AdMobForwardService`(전면) / `AppOpenAdService`(앱 열기) 와 동일한 패턴:
///   - 디버그 모드는 기본적으로 테스트 ID. `ADMOB_FORCE_PRODUCTION=true`
///     일 때만 prod ID 사용.
///   - 릴리즈 모드는 prod ID. 미설정 시 fallback 으로 테스트 ID(릴리즈에서
///     테스트 ID 노출은 정책 위반 위험이 있어 경고 로그만 남기고 호출자가
///     로드 실패를 받도록 빈 문자열 반환).
///   - Premium 게이트: AdMobForwardService 와 같은 callback 패턴.
///     `main.dart` 에서 PremiumCubit 생성 시점에 등록.
class BannerAdService {
  static BannerAdService? _instance;
  static BannerAdService get instance =>
      _instance ??= BannerAdService._internal();

  BannerAdService._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, lineLength: 120, printEmojis: true),
  );

  bool Function()? _premiumGate;

  /// `MobileAds.instance.initialize()` 호출을 1회로 캐시하기 위한 future.
  /// AppOpenAd / Interstitial 흐름은 부팅 시퀀스에서 별도 호출하지만, 메인
  /// 탭이 화면에 마운트되는 시점이 그 호출보다 빠를 수 있어 배너 로드가
  /// 무음 실패한다. 따라서 배너는 로드 직전 자체적으로 초기화를 보장한다.
  Future<void>? _initFuture;

  /// `main.dart` 의 PremiumCubit 생성 직후 호출.
  void setPremiumGate(bool Function() gate) {
    _premiumGate = gate;
    _logger.i('Banner premium gate 등록 완료');
  }

  /// Premium 사용자면 true — 호출처에서 배너를 노출하지 않는다.
  bool get isPremium => _premiumGate?.call() == true;

  /// `BannerAd.load()` 전 호출. `MobileAds.instance.initialize()` 가 끝났음을
  /// 보장한다. 여러 번 호출해도 SDK 가 알아서 캐시하므로 안전하지만, 여기서도
  /// future 를 캐시해 동시 다발 await 가 한 번의 초기화로 모이게 한다.
  Future<void> ensureInitialized() {
    return _initFuture ??= MobileAds.instance.initialize().then((status) {
      _logger.i('✅ MobileAds 초기화 완료(BannerAdService): '
          '${status.adapterStatuses.length} adapters');
    }).catchError((Object e, StackTrace st) {
      _logger.e('❌ MobileAds 초기화 실패: $e');
      // 실패한 future 를 캐시에 두면 영구히 막히므로 다음 시도 가능하도록 비움.
      _initFuture = null;
    });
  }

  /// 현재 환경에 맞는 배너 광고 단위 ID. 반환 값이 빈 문자열이면 광고를
  /// 로드하지 않는다 (.env 키가 비어있을 때).
  String resolveBannerAdUnitId() {
    final forceProduction = dotenv.env['ADMOB_FORCE_PRODUCTION'] == 'true';

    final prodKey =
        Platform.isAndroid ? 'ADMOB_ANDROID_BANNER_ID' : 'ADMOB_IOS_BANNER_ID';
    final testKey = Platform.isAndroid
        ? 'ADMOB_ANDROID_BANNER_ID_TEST'
        : 'ADMOB_IOS_BANNER_ID_TEST';

    final prodId = dotenv.env[prodKey] ?? '';
    final testId = dotenv.env[testKey] ?? '';

    // 디버그 빌드: 정책 안전을 위해 기본은 테스트 ID.
    if (kDebugMode && !forceProduction) {
      if (testId.isEmpty) {
        _logger.e('❌ $testKey 가 비어있습니다. .env 를 확인하세요. 배너 비노출.');
        return '';
      }
      return testId;
    }

    // 릴리즈 빌드 또는 forceProduction.
    if (prodId.isNotEmpty) return prodId;

    _logger.e('❌ $prodKey 가 비어있습니다. .env 를 확인하세요. 배너 비노출.');
    return '';
  }

  /// 적응형 배너 사이즈 계산. 화면 너비를 기반으로 가장 적절한 배너 높이를
  /// 반환. null 이면 사이즈 산출 실패(아주 좁은 화면 등).
  Future<AdSize?> resolveAdaptiveSize(int widthPx) {
    return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(widthPx);
  }
}
