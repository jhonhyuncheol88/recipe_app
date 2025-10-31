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
        
        // 실제 기기 ID를 환경 변수에서 가져오거나 기본값 사용
        final testDeviceIdFromEnv = dotenv.env['ADMOB_TEST_DEVICE_ID'];
        final testDeviceIds = <String>['EMULATOR'];
        
        if (testDeviceIdFromEnv != null && testDeviceIdFromEnv.isNotEmpty) {
          testDeviceIds.add(testDeviceIdFromEnv);
          _logger.d('환경 변수에서 테스트 디바이스 ID 로드: $testDeviceIdFromEnv');
        } else {
          // 환경 변수에 없으면 로그에 안내 메시지 출력
          _logger.w('⚠️ ADMOB_TEST_DEVICE_ID가 설정되지 않았습니다.');
          _logger.w('⚠️ 실제 기기에서 테스트 광고를 보려면:');
          _logger.w('⚠️ 1. 앱을 실행하고 로그캣에서 "To get test ads on this device" 메시지를 찾으세요');
          _logger.w('⚠️ 2. .env 파일에 ADMOB_TEST_DEVICE_ID="실제기기ID" 추가하세요');
        }
        
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: testDeviceIds),
        );
        _logger.d('테스트 디바이스 설정 완료: $testDeviceIds');
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

    // 환경 변수로 실제 광고 ID 강제 사용 여부 확인
    final forceProduction = dotenv.env['ADMOB_FORCE_PRODUCTION'] == 'true';
    
    // 실제 광고 ID 확인
    final envKey = Platform.isAndroid
        ? 'ADMOB_ANDROID_FORWARD_ID'
        : 'ADMOB_IOS_FORWARD_ID';
    final prodId = dotenv.env[envKey];
    
    // 디버그 모드에서는 테스트 광고 ID 사용 (강제 프로덕션 모드가 아닐 때만)
    // HTTP 403 에러 방지를 위해 디버그 모드에서는 기본적으로 테스트 ID 사용
    if (kDebugMode && !forceProduction) {
      _logger.w('⚠️ 디버그 모드: 테스트 광고 ID 사용');
      _logger.w('⚠️ 실제 광고 ID를 사용하려면 릴리즈 빌드로 실행하거나');
      _logger.w('⚠️ .env 파일에 ADMOB_FORCE_PRODUCTION=true 추가하세요');
      
      final testId = Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android 테스트 전면
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS 테스트 전면
      _logger.d('${Platform.operatingSystem} 테스트 전면 광고 ID: $testId');
      print('AdMobService: 테스트 광고 ID 사용 - $testId');
      return testId;
    }
    
    // 릴리즈 모드이거나 강제 프로덕션 모드에서는 실제 광고 ID 사용
    if (prodId != null && prodId.isNotEmpty) {
      _logger.i('✅ 실제 전면 광고 ID 사용: $prodId');
      _logger.i('   - kDebugMode: $kDebugMode');
      _logger.i('   - forceProduction: $forceProduction');
      print('AdMobService: 실제 광고 ID 사용 - $prodId');
      return prodId;
    }
    
    // 실제 광고 ID가 없으면 디버그 모드에서만 테스트 ID 사용
    if (kDebugMode) {
      _logger.w('⚠️ 실제 광고 ID가 설정되지 않음 ($envKey)');
      _logger.w('⚠️ 디버그 모드이므로 테스트 광고 ID를 사용합니다');
      
      final testId = Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712' // Android 테스트 전면
          : 'ca-app-pub-3940256099942544/4411468910'; // iOS 테스트 전면
      _logger.d('${Platform.operatingSystem} 테스트 전면 광고 ID: $testId');
      print('AdMobService: 테스트 광고 ID 사용 - $testId');
      return testId;
    }

    // 릴리즈 모드에서 실제 광고 ID가 없으면 에러
    _logger.e('프로덕션 전면 광고 ID가 설정되지 않음 ($envKey)');
    throw Exception('프로덕션 전면 광고 ID가 설정되지 않았습니다. .env 파일에서 $envKey를 확인해주세요.');
  }

  /// 전면 광고 로드
  Future<InterstitialAd?> loadInterstitialAd() async {
    _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.i('📺 전면 광고 로드 시작');
    _logger.i('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    try {
      final completer = Completer<InterstitialAd?>();
      final adUnitId = getInterstitialAdUnitId();

      _logger.i('🔍 광고 단위 ID: $adUnitId');
      _logger.i('🔍 kDebugMode: $kDebugMode');
      _logger.i('🔍 Platform: ${Platform.operatingSystem}');
      _logger.i('🔍 AdMob 초기화 상태 확인 중...');
      
      // AdMob 초기화 상태 확인
      try {
        final initializationStatus = await MobileAds.instance.initialize();
        _logger.i('🔍 AdMob 초기화 상태: ${initializationStatus.adapterStatuses}');
        print('AdMob 초기화 상태: ${initializationStatus.adapterStatuses}');
      } catch (e) {
        _logger.w('AdMob 초기화 상태 확인 실패: $e');
      }
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('AdMobService: 광고 로드 시도 시작');
      print('광고 단위 ID: $adUnitId');
      print('kDebugMode: $kDebugMode');
      print('Platform: ${Platform.operatingSystem}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _logger.i('✅✅✅ 전면 광고 로드 성공 ✅✅✅');
            _logger.i('광고 단위 ID: ${ad.adUnitId}');
            _logger.i('응답 정보: ${ad.responseInfo}');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('✅✅✅ AdMobService: 전면 광고 로드 성공 ✅✅✅');
            print('광고 단위 ID: ${ad.adUnitId}');
            print('응답 정보: ${ad.responseInfo}');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            if (!completer.isCompleted) {
              completer.complete(ad);
            }
          },
          onAdFailedToLoad: (error) {
            _logger.e('❌❌❌ 전면 광고 로드 실패 ❌❌❌');
            _logger.e('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            _logger.e('에러 메시지: ${error.message}');
            _logger.e('에러 코드: ${error.code}');
            _logger.e('에러 도메인: ${error.domain}');
            _logger.e('에러 응답 정보: ${error.responseInfo}');
            _logger.e('에러 응답 정보 toString: ${error.responseInfo?.toString()}');
            
            // 에러 코드별 상세 설명
            switch (error.code) {
              case 0:
                _logger.e('에러 유형: ERROR_CODE_INTERNAL_ERROR - 내부 오류');
                break;
              case 1:
                _logger.e('에러 유형: ERROR_CODE_INVALID_REQUEST - 잘못된 요청');
                break;
              case 2:
                _logger.e('에러 유형: ERROR_CODE_NETWORK_ERROR - 네트워크 오류');
                break;
              case 3:
                _logger.e('에러 유형: ERROR_CODE_NO_FILL - 광고 없음 (가장 흔한 경우)');
                _logger.e('⚠️ 이 에러는 광고 단위에 광고가 없을 때 발생합니다.');
                _logger.e('⚠️ 광고 단위가 방금 생성되었거나 승인 대기 중일 수 있습니다.');
                break;
              case 8:
                _logger.e('에러 유형: ERROR_CODE_INVALID_AD_SIZE - 잘못된 광고 크기');
                break;
              default:
                _logger.e('에러 유형: 알 수 없는 에러 코드');
            }
            
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('❌❌❌ AdMobService: 전면 광고 로드 실패 ❌❌❌');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('에러 메시지: ${error.message}');
            print('에러 코드: ${error.code}');
            print('에러 도메인: ${error.domain}');
            print('에러 응답 정보: ${error.responseInfo}');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            
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
        _logger.i('✅ 전면 광고 로드 완료 - 광고 객체 반환');
        print('AdMobService: 전면 광고 로드 완료 - 광고 객체 반환');
      } else {
        _logger.w('⚠️ 전면 광고 로드 실패 - null 반환');
        _logger.w('⚠️ 광고 요청이 AdMob 서버에 전달되지 않았을 수 있습니다');
        _logger.w('⚠️ 확인사항:');
        _logger.w('   1. .env 파일에 ADMOB_ANDROID_FORWARD_ID가 설정되어 있는지');
        _logger.w('   2. 실제 광고 단위 ID가 올바른지');
        _logger.w('   3. AdMob 콘솔에서 광고 단위가 활성화되어 있는지');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('⚠️ AdMobService: 전면 광고 로드 실패 - null 반환');
        print('⚠️ 광고 요청이 AdMob 서버에 전달되지 않았을 수 있습니다');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
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
