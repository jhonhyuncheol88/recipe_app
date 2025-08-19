import 'dart:io';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';
import '../controller/ad/ad_cubit.dart';

class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._internal();

  late final Logger _logger;
  AdCubit? _adCubit;

  AdMobService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }

  /// AdCubit 설정
  void setAdCubit(AdCubit adCubit) {
    _adCubit = adCubit;
    _logger.i('AdCubit 설정 완료');
  }

  /// AdMob 초기화
  Future<void> initialize() async {
    _logger.i('AdMob 초기화 시작');

    try {
      await MobileAds.instance.initialize();
      _logger.i('AdMob 초기화 완료');

      // 테스트 모드 설정 (개발 중일 때)
      if (dotenv.env['APP_ENV'] == 'development') {
        _logger.d('개발 모드: 테스트 디바이스 설정 적용');
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: ['EMULATOR', 'TEST_DEVICE_ID']),
        );
        _logger.d('테스트 디바이스 설정 완료');
      } else {
        _logger.i('프로덕션 모드로 실행 중');
      }
    } catch (e) {
      _logger.e('AdMob 초기화 실패: $e');
      rethrow;
    }
  }

  /// 배너 광고 ID 가져오기
  String getBannerAdUnitId() {
    final currentMode = dotenv.env['APP_ENV'] ?? 'unknown';
    _logger.d('광고 ID 요청 - 현재 모드: $currentMode');

    // 개발 모드에서는 테스트 광고 ID를 우선적으로 사용
    if (currentMode == 'development') {
      _logger.d('개발 모드: 테스트 광고 ID 사용');
      if (Platform.isAndroid) {
        final testId =
            dotenv.env['ADMOB_TEST_BANNER_ID'] ??
            'ca-app-pub-3940256099942544/6300978111';
        _logger.d('Android 테스트 배너 ID: $testId');
        return testId;
      } else if (Platform.isIOS) {
        final testId =
            dotenv.env['ADMOB_TEST_BANNER_ID'] ??
            'ca-app-pub-3940256099942544/2934735716';
        _logger.d('iOS 테스트 배너 ID: $testId');
        return testId;
      }
    } else {
      _logger.d('프로덕션 모드: 실제 광고 ID 사용');
    }

    // 프로덕션 모드에서는 실제 광고 ID 사용
    if (Platform.isAndroid) {
      final prodId =
          dotenv.env['ADMOB_ANDROID_BANNER_ID'] ??
          'ca-app-pub-3940256099942544/6300978111';
      _logger.d('Android 프로덕션 배너 ID: $prodId');
      return prodId;
    } else if (Platform.isIOS) {
      final prodId =
          dotenv.env['ADMOB_IOS_BANNER_ID'] ??
          'ca-app-pub-3940256099942544/2934735716';
      _logger.d('iOS 프로덕션 배너 ID: $prodId');
      return prodId;
    }

    final defaultId = 'ca-app-pub-3940256099942544/6300978111';
    _logger.w('기본 광고 ID 사용: $defaultId');
    return defaultId;
  }

  /// 배너 광고 생성
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _logger.i('배너 광고가 로드되었습니다. ID: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (ad, error) {
          _logger.e('배너 광고 로드 실패: ${error.message}');
          ad.dispose();
        },
        onAdOpened: (ad) {
          _logger.d('배너 광고가 열렸습니다.');
        },
        onAdClosed: (ad) {
          _logger.d('배너 광고가 닫혔습니다.');
        },
      ),
    );
  }

  /// 배너 광고 로드
  Future<BannerAd?> loadBannerAd() async {
    _logger.d('배너 광고 로드 시작');
    try {
      final bannerAd = createBannerAd();
      _logger.d('배너 광고 생성 완료, 로드 중...');
      await bannerAd.load();
      _logger.i('배너 광고 로드 성공');
      return bannerAd;
    } catch (e) {
      _logger.e('배너 광고 로드 중 오류 발생: $e');
      return null;
    }
  }

  /// 앱 ID 가져오기
  String getAppId() {
    _logger.d('앱 ID 요청');
    if (Platform.isAndroid) {
      final appId =
          dotenv.env['ADMOB_ANDROID_APP_ID'] ??
          dotenv.env['ADMOB_TEST_APP_ID'] ??
          'ca-app-pub-3940256099942544~3347511713';
      _logger.d('Android 앱 ID: $appId');
      return appId;
    } else if (Platform.isIOS) {
      final appId =
          dotenv.env['ADMOB_IOS_APP_ID'] ??
          dotenv.env['ADMOB_TEST_APP_ID'] ??
          'ca-app-pub-3940256099942544~1458002511';
      _logger.d('iOS 앱 ID: $appId');
      return appId;
    }
    final defaultAppId = 'ca-app-pub-3940256099942544~3347511713';
    _logger.w('기본 앱 ID 사용: $defaultAppId');
    return defaultAppId;
  }

  /// 전면 광고 ID 가져오기
  String getInterstitialAdUnitId() {
    final currentMode = dotenv.env['APP_ENV'] ?? 'unknown';
    _logger.d('전면 광고 ID 요청 - 현재 모드: $currentMode');

    // 개발 모드에서는 테스트 광고 ID를 우선적으로 사용
    if (currentMode == 'development') {
      _logger.d('개발 모드: 테스트 전면 광고 ID 사용');
      if (Platform.isAndroid) {
        final testId =
            dotenv.env['ADMOB_TEST_INTERSTITIAL_ID'] ??
            'ca-app-pub-3940256099942544/1033173712';
        _logger.d('Android 테스트 전면 광고 ID: $testId');
        return testId;
      } else if (Platform.isIOS) {
        final testId =
            dotenv.env['ADMOB_TEST_INTERSTITIAL_ID'] ??
            'ca-app-pub-3940256099942544/1033173712';
        _logger.d('iOS 테스트 전면 광고 ID: $testId');
        return testId;
      }
    } else {
      _logger.d('프로덕션 모드: 실제 전면 광고 ID 사용');
    }

    // 프로덕션 모드에서는 실제 광고 ID 사용
    if (Platform.isAndroid) {
      final prodId =
          dotenv.env['ADMOB_ANDROID_INTERSTITIAL_ID'] ??
          'ca-app-pub-3940256099942544/1033173712';
      _logger.d('Android 프로덕션 전면 광고 ID: $prodId');
      return prodId;
    } else if (Platform.isIOS) {
      final prodId =
          dotenv.env['ADMOB_IOS_INTERSTITIAL_ID'] ??
          'ca-app-pub-3940256099942544/1033173712';
      _logger.d('iOS 프로덕션 전면 광고 ID: $prodId');
      return prodId;
    }

    final defaultId = 'ca-app-pub-3940256099942544/1033173712';
    _logger.w('기본 전면 광고 ID 사용: $defaultId');
    return defaultId;
  }

  /// 전면 광고 로드
  Future<InterstitialAd?> loadInterstitialAd() async {
    _logger.d('전면 광고 로드 시작');
    try {
      final completer = Completer<InterstitialAd?>();

      InterstitialAd.load(
        adUnitId: getInterstitialAdUnitId(),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _logger.i('전면 광고가 로드되었습니다. ID: ${ad.adUnitId}');
            completer.complete(ad);
          },
          onAdFailedToLoad: (error) {
            _logger.e('전면 광고 로드 실패: ${error.message}');
            completer.complete(null);
          },
        ),
      );

      final interstitialAd = await completer.future;
      if (interstitialAd != null) {
        _logger.i('전면 광고 로드 성공');
      }
      return interstitialAd;
    } catch (e) {
      _logger.e('전면 광고 로드 중 오류 발생: $e');
      return null;
    }
  }

  /// 전면 광고 표시
  Future<bool> showInterstitialAd() async {
    _logger.d('전면 광고 표시 요청');
    _adCubit?.startAdLoading();

    try {
      final interstitialAd = await loadInterstitialAd();
      if (interstitialAd != null) {
        _adCubit?.adLoaded();
        _adCubit?.startAdShowing();

        final completer = Completer<bool>();

        // 광고가 닫힐 때까지 기다리기 위한 콜백 설정
        interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {
            _logger.d('전면 광고가 열렸습니다.');
            print('전면 광고가 열렸습니다.');
          },
          onAdDismissedFullScreenContent: (ad) {
            _logger.d('전면 광고가 닫혔습니다.');
            print('전면 광고가 닫혔습니다.');
            ad.dispose();

            // AdCubit 상태 업데이트
            _adCubit?.adWatched();

            // 광고가 닫힌 후에 true 반환
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onAdImpression: (ad) {
            _logger.d('전면 광고가 노출되었습니다.');
          },
          onAdClicked: (ad) {
            _logger.d('전면 광고가 클릭되었습니다.');
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            _logger.e('전면 광고 표시 실패: ${error.message}');
            print('전면 광고 표시 실패: ${error.message}');
            ad.dispose();

            // AdCubit 상태 업데이트
            _adCubit?.adFailed(error.message);

            if (!completer.isCompleted) {
              completer.complete(false);
            }
          },
        );

        await interstitialAd.show();
        _logger.i('전면 광고 표시 시작');
        print('전면 광고 표시 시작');

        // 광고가 닫힐 때까지 기다림
        final result = await completer.future;
        _logger.i('전면 광고 시청 완료: $result');
        print('전면 광고 시청 완료: $result');
        return result;
      } else {
        _logger.w('전면 광고 로드 실패로 표시할 수 없음');
        _adCubit?.adFailed('광고 로드 실패');
        return false;
      }
    } catch (e) {
      _logger.e('전면 광고 표시 중 오류 발생: $e');
      _adCubit?.adFailed(e.toString());
      return false;
    }
  }

  /// 전면 광고 미리 로드 (성능 향상)
  InterstitialAd? _preloadedInterstitialAd;

  Future<void> preloadInterstitialAd() async {
    _logger.d('전면 광고 사전 로드 시작');
    try {
      final interstitialAd = await loadInterstitialAd();
      if (interstitialAd != null) {
        _preloadedInterstitialAd = interstitialAd;
        _logger.i('전면 광고 사전 로드 완료');
      }
    } catch (e) {
      _logger.e('전면 광고 사전 로드 실패: $e');
    }
  }

  /// 사전 로드된 전면 광고 표시
  Future<bool> showPreloadedInterstitialAd() async {
    if (_preloadedInterstitialAd != null) {
      _logger.d('사전 로드된 전면 광고 표시');
      try {
        await _preloadedInterstitialAd!.show();
        _preloadedInterstitialAd = null; // 사용 후 제거
        _logger.i('사전 로드된 전면 광고 표시 성공');
        return true;
      } catch (e) {
        _logger.e('사전 로드된 전면 광고 표시 실패: $e');
        _preloadedInterstitialAd = null;
        return false;
      }
    } else {
      _logger.w('사전 로드된 전면 광고가 없음');
      return false;
    }
  }
}
