/// 빌드 시점에 주입되는 환경 변수.
///
/// .env 는 앱 에셋에 넣지 않는다(APK/IPA 압축만 풀면 평문으로 노출되기 때문).
/// 대신 빌드·실행 때 `--dart-define-from-file=.env` 로 값을 컴파일 상수로 넣는다.
///
///   flutter run --dart-define-from-file=.env
///   flutter build appbundle --release --dart-define-from-file=.env
///   flutter build ipa --release --dart-define-from-file=.env
///
/// `String.fromEnvironment` 는 키가 리터럴이어야 하므로 쓰는 키를 모두 여기에 나열한다.
/// 새 키를 .env 에 추가하면 아래 [_values] 에도 추가해야 한다.
class Env {
  Env._();

  static const Map<String, String> _values = {
    'GEMINI_API_KEY': String.fromEnvironment('GEMINI_API_KEY'),
    'APP_ENV': String.fromEnvironment('APP_ENV'),
    'REVENUECAT_IOS_KEY': String.fromEnvironment('REVENUECAT_IOS_KEY'),
    'REVENUECAT_ANDROID_KEY': String.fromEnvironment('REVENUECAT_ANDROID_KEY'),
    'ADMOB_FORCE_PRODUCTION': String.fromEnvironment('ADMOB_FORCE_PRODUCTION'),
    'ADMOB_TEST_DEVICE_ID': String.fromEnvironment('ADMOB_TEST_DEVICE_ID'),
    'ADMOB_ANDROID_APP_ID': String.fromEnvironment('ADMOB_ANDROID_APP_ID'),
    'ADMOB_ANDROID_FORWARD_ID': String.fromEnvironment('ADMOB_ANDROID_FORWARD_ID'),
    'ADMOB_ANDROID_INTERSTITIAL_ID':
        String.fromEnvironment('ADMOB_ANDROID_INTERSTITIAL_ID'),
    'ADMOB_ANDROID_NATIVE_ID': String.fromEnvironment('ADMOB_ANDROID_NATIVE_ID'),
    'ADMOB_ANDROID_APP_OPEN_ID':
        String.fromEnvironment('ADMOB_ANDROID_APP_OPEN_ID'),
    'ADMOB_ANDROID_APP_OPEN_ID_TEST':
        String.fromEnvironment('ADMOB_ANDROID_APP_OPEN_ID_TEST'),
    'ADMOB_ANDROID_BANNER_ID': String.fromEnvironment('ADMOB_ANDROID_BANNER_ID'),
    'ADMOB_ANDROID_BANNER_ID_TEST':
        String.fromEnvironment('ADMOB_ANDROID_BANNER_ID_TEST'),
    'ADMOB_ANDROID_REWARDED_ID':
        String.fromEnvironment('ADMOB_ANDROID_REWARDED_ID'),
    'ADMOB_ANDROID_REWARDED_ID_TEST':
        String.fromEnvironment('ADMOB_ANDROID_REWARDED_ID_TEST'),
    'ADMOB_IOS_APP_ID': String.fromEnvironment('ADMOB_IOS_APP_ID'),
    'ADMOB_IOS_FORWARD_ID': String.fromEnvironment('ADMOB_IOS_FORWARD_ID'),
    'ADMOB_IOS_NATVIE_ID': String.fromEnvironment('ADMOB_IOS_NATVIE_ID'),
    'ADMOB_IOS_APP_OPEN_ID': String.fromEnvironment('ADMOB_IOS_APP_OPEN_ID'),
    'ADMOB_IOS_APP_OPEN_ID_TEST':
        String.fromEnvironment('ADMOB_IOS_APP_OPEN_ID_TEST'),
    'ADMOB_IOS_BANNER_ID': String.fromEnvironment('ADMOB_IOS_BANNER_ID'),
    'ADMOB_IOS_BANNER_ID_TEST': String.fromEnvironment('ADMOB_IOS_BANNER_ID_TEST'),
    'ADMOB_IOS_REWARDED_ID': String.fromEnvironment('ADMOB_IOS_REWARDED_ID'),
    'ADMOB_IOS_REWARDED_ID_TEST':
        String.fromEnvironment('ADMOB_IOS_REWARDED_ID_TEST'),
  };

  /// 값이 없거나 빈 문자열이면 null (기존 `dotenv.env[key]` 와 같은 사용감).
  static String? get(String key) {
    final value = _values[key];
    return (value == null || value.isEmpty) ? null : value;
  }

  /// 빌드에 .env 가 주입됐는지 (대표 키 하나로 판단).
  static bool get isLoaded => _values.values.any((v) => v.isNotEmpty);
}
