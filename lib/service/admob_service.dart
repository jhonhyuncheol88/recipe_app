import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
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

      // kDebugMode를 사용해서 테스트 모드 설정 (디버그 빌드일 때만)
      if (kDebugMode) {
        _logger.d('디버그 모드: 테스트 디바이스 설정 적용');
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: ['EMULATOR', 'TEST_DEVICE_ID']),
        );
        _logger.d('테스트 디바이스 설정 완료');
      } else {
        _logger.i('릴리즈 모드로 실행 중');
      }
    } catch (e) {
      _logger.e('AdMob 초기화 실패: $e');
      rethrow;
    }
  }

  /// 앱 ID 가져오기 (Android/iOS)
  String getAppId() {
    _logger.d('${Platform.operatingSystem} 앱 ID 요청');
    final envKey =
        Platform.isAndroid ? 'ADMOB_ANDROID_APP_ID' : 'ADMOB_IOS_APP_ID';
    final appId = dotenv.env[envKey];
    if (appId == null || appId.isEmpty) {
      _logger.e('$envKey가 설정되지 않음');
      throw Exception('$envKey가 설정되지 않았습니다. .env 파일을 확인해주세요.');
    }
    _logger.d('${Platform.operatingSystem} 앱 ID: $appId');
    return appId;
  }

  /// 전면 광고 ID 가져오기 (Android/iOS)
  String getInterstitialAdUnitId() {
    _logger.d(
        '전면 광고 ID 요청 - kDebugMode: $kDebugMode, Platform: ${Platform.operatingSystem}');

    // 디버그 모드에서는 테스트 광고 ID 사용
    if (kDebugMode) {
      _logger.d('디버그 모드: 테스트 전면 광고 ID 사용');
      // Android와 iOS 테스트 ID
      final testId = Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android 테스트 전면
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS 테스트 전면
      _logger.d('${Platform.operatingSystem} 테스트 전면 광고 ID: $testId');
      return testId;
    }

    // 릴리즈 모드에서는 실제 광고 ID 사용
    _logger.d('릴리즈 모드: 실제 전면 광고 ID 사용');
    final envKey = Platform.isAndroid
        ? 'ADMOB_ANDROID_FORWARD_ID'
        : 'ADMOB_IOS_FORWARD_ID';
    final prodId = dotenv.env[envKey];
    if (prodId == null || prodId.isEmpty) {
      _logger.e('프로덕션 전면 광고 ID가 설정되지 않음 ($envKey)');
      throw Exception('프로덕션 전면 광고 ID가 설정되지 않았습니다. .env 파일에서 $envKey를 확인해주세요.');
    }
    _logger.d('${Platform.operatingSystem} 프로덕션 전면 광고 ID: $prodId');
    return prodId;
  }

  /// 전면 광고 로드
  Future<InterstitialAd?> loadInterstitialAd() async {
    _logger.d('전면 광고 로드 시작');
    try {
      final completer = Completer<InterstitialAd?>();
      final adUnitId = getInterstitialAdUnitId();

      _logger.d('광고 로드 시도 - ID: $adUnitId');
      print('AdMobService: 광고 로드 시도 - ID: $adUnitId');

      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _logger.i('전면 광고가 로드되었습니다. ID: ${ad.adUnitId}');
            print('AdMobService: 전면 광고 로드 성공 - ID: ${ad.adUnitId}');
            if (!completer.isCompleted) {
              completer.complete(ad);
            }
          },
          onAdFailedToLoad: (error) {
            _logger.e('전면 광고 로드 실패: ${error.message}');
            _logger.e('전면 광고 로드 실패 코드: ${error.code}');
            _logger.e('전면 광고 로드 실패 도메인: ${error.domain}');
            print('AdMobService: 전면 광고 로드 실패 - ${error.message}');
            print('AdMobService: 전면 광고 로드 실패 코드 - ${error.code}');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
        ),
      );

      // 타임아웃 설정 (10초)
      final interstitialAd = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.e('전면 광고 로드 타임아웃');
          print('AdMobService: 전면 광고 로드 타임아웃');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
          return null;
        },
      );

      if (interstitialAd != null) {
        _logger.i('전면 광고 로드 성공');
        print('AdMobService: 전면 광고 로드 완료');
      } else {
        _logger.w('전면 광고 로드 실패 - null 반환');
        print('AdMobService: 전면 광고 로드 실패 - null 반환');
      }
      return interstitialAd;
    } catch (e) {
      _logger.e('전면 광고 로드 중 오류 발생: $e');
      print('AdMobService: 전면 광고 로드 중 오류 발생: $e');
      return null;
    }
  }

  /// 전면 광고 표시
  Future<bool> showInterstitialAd() async {
    _logger.d('전면 광고 표시 요청');
    print('AdMobService: 전면 광고 표시 요청');
    _adCubit?.startAdLoading();

    try {
      final interstitialAd = await loadInterstitialAd();
      if (interstitialAd != null) {
        _logger.i('전면 광고 로드 성공, 표시 시도 중...');
        print('AdMobService: 전면 광고 로드 성공, 표시 시도 중...');

        _adCubit?.adLoaded();
        _adCubit?.startAdShowing();

        final completer = Completer<bool>();

        // 광고가 닫힐 때까지 기다리기 위한 콜백 설정
        interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {
            _logger.d('전면 광고가 열렸습니다.');
            print('AdMobService: 전면 광고가 열렸습니다.');
          },
          onAdDismissedFullScreenContent: (ad) {
            _logger.d('전면 광고가 닫혔습니다.');
            print('AdMobService: 전면 광고가 닫혔습니다.');
            ad.dispose();

            // AdCubit 상태 업데이트 (mounted 체크)
            try {
              _adCubit?.adWatched();
            } catch (e) {
              _logger.w('AdCubit 상태 업데이트 실패 (이미 close됨): $e');
            }

            // 광고가 닫힌 후에 true 반환
            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onAdImpression: (ad) {
            _logger.d('전면 광고가 노출되었습니다.');
            print('AdMobService: 전면 광고가 노출되었습니다.');
          },
          onAdClicked: (ad) {
            _logger.d('전면 광고가 클릭되었습니다.');
            print('AdMobService: 전면 광고가 클릭되었습니다.');
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            _logger.e('전면 광고 표시 실패: ${error.message}');
            print('AdMobService: 전면 광고 표시 실패 - ${error.message}');
            ad.dispose();

            // AdCubit 상태 업데이트 (mounted 체크)
            try {
              _adCubit?.adFailed(error.message);
            } catch (e) {
              _logger.w('AdCubit 상태 업데이트 실패 (이미 close됨): $e');
            }

            if (!completer.isCompleted) {
              completer.complete(false);
            }
          },
        );

        await interstitialAd.show();
        _logger.i('전면 광고 표시 시작');
        print('AdMobService: 전면 광고 표시 시작');

        // 광고가 닫힐 때까지 기다림 (타임아웃 30초)
        final result = await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            _logger.e('전면 광고 표시 타임아웃');
            print('AdMobService: 전면 광고 표시 타임아웃');
            if (!completer.isCompleted) {
              completer.complete(false);
            }
            return false;
          },
        );

        _logger.i('전면 광고 시청 완료: $result');
        print('AdMobService: 전면 광고 시청 완료: $result');
        return result;
      } else {
        _logger.w('전면 광고 로드 실패로 표시할 수 없음');
        print('AdMobService: 전면 광고 로드 실패로 표시할 수 없음');
        _adCubit?.adFailed('광고 로드 실패');
        // 광고 로드 실패 시에도 다음 함수 실행을 위해 true 반환
        return true;
      }
    } catch (e) {
      _logger.e('전면 광고 표시 중 오류 발생: $e');
      print('AdMobService: 전면 광고 표시 중 오류 발생: $e');
      _adCubit?.adFailed(e.toString());
      // 에러 발생 시에도 다음 함수 실행을 위해 true 반환
      return true;
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
      } else {
        _logger.w('전면 광고 사전 로드 실패: 광고를 로드할 수 없음');
      }
    } catch (e) {
      _logger.e('전면 광고 사전 로드 실패: $e');
      // 에러 발생 시에도 앱 실행에 영향을 주지 않음
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
        // 에러 발생 시에도 다음 함수 실행을 위해 true 반환
        return true;
      }
    } else {
      _logger.w('사전 로드된 전면 광고가 없음');
      // 사전 로드된 광고가 없어도 다음 함수 실행을 위해 true 반환
      return true;
    }
  }
}
