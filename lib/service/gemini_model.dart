import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

/// 앱 전체 Gemini 모델 (Firebase AI Logic — Gemini Developer API).
const String kGeminiModel = 'gemini-3.1-flash-lite';

/// Firebase AI Logic 모델 생성. API 키 없이 Firebase 프로젝트로 호출하고,
/// 요청마다 App Check 토큰을 붙인다.
///
/// Firebase.initializeApp 이후에 호출해야 하므로 서비스에서는 `late final` 로 지연 생성한다.
GenerativeModel createGeminiModel({GenerationConfig? generationConfig}) {
  return FirebaseAI.googleAI(
    appCheck: FirebaseAppCheck.instance,
  ).generativeModel(model: kGeminiModel, generationConfig: generationConfig);
}
