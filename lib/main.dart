import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router/index.dart';
import 'theme/app_theme.dart';
import 'util/app_strings.dart';
import 'util/app_locale.dart';
import 'controller/index.dart';
import 'data/index.dart';
import 'service/sauce_cost_service.dart';
import 'service/recipe_cost_service.dart';
import 'service/sauce_expiry_service.dart';
import 'service/admob_forward.dart';
import 'service/initial_data_service.dart';
import 'service/in_app_review_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'service/notification_service.dart';
import 'controller/ocr/ocr_cubit.dart';
import 'controller/encyclopedia/encyclopedia_cubit.dart';
import 'service/encyclopedia_service.dart';
import 'package:logger/logger.dart';
import 'dart:io' show Platform;
import 'controller/setting/theme_cubit.dart';
import 'firebase_options.dart';

void main() async {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  logger.i('🚀 앱 시작 - WidgetsFlutterBinding 초기화');
  WidgetsFlutterBinding.ensureInitialized();
  logger.i('✅ WidgetsFlutterBinding 초기화 완료');

  // 전역 에러 캡처(런타임 예외로 인한 조기 종료 방지)
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e('FlutterError: \\n${details.exceptionAsString()}');
    FlutterError.presentError(details);
  };
  WidgetsBinding.instance.platformDispatcher.onError =
      (Object error, StackTrace stack) {
    logger.e('Uncaught error: $error');
    logger.e('Stack: $stack');
    return true; // 에러를 처리했다고 알림(프로세스 종료 방지)
  };

  // 필수 초기화는 실패해도 앱 실행을 계속함
  await _safePreRunInitialization(logger);

  // 타임존 초기화 (zonedSchedule 전 반드시 필요)
  try {
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    logger.i('✅ 타임존 초기화 완료: ${tzInfo.identifier}');
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('UTC'));
    logger.w('⚠️ 타임존 초기화 실패, UTC 사용: $e');
  }

  logger.i('🎨 MyApp 실행');
  runApp(const MyApp());
  logger.i('✅ 앱 실행 완료');

  // 프레임 이후(위젯 트리 준비 후) 추가 초기화 수행
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _postAppInitialization(logger);
    await _initializeInitialData(logger);
    await _checkAndRequestReview(logger);
  });
}

Future<void> _safePreRunInitialization(Logger logger) async {
  // .env 로드(없어도 앱 실행 계속)
  try {
    logger.i('🔧 환경 변수 로드 시작');
    await dotenv.load();
    logger.i('✅ 환경 변수 로드 완료');
  } catch (e) {
    logger.e('⚠️ .env 로드 실패(무시하고 계속): $e');
  }

  // Firebase 초기화(권장: 플랫폼 옵션 사용)
  try {
    logger.i('🔥 Firebase 초기화 시작');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i('✅ Firebase 초기화 완료');
  } catch (e) {
    logger.e('❌ Firebase 초기화 실패(앱은 계속 실행): $e');
  }

  // Analytics 설정(실패 무시)
  try {
    logger.i('📊 Firebase Analytics 설정 시작');
    final firebaseAnalytics = FirebaseAnalytics.instance;
    await firebaseAnalytics.setAnalyticsCollectionEnabled(true);
    await firebaseAnalytics.logAppOpen();
    logger.i('✅ Firebase Analytics 설정 완료');
  } catch (e) {
    logger.e('⚠️ Analytics 설정 실패(무시): $e');
  }
}

Future<void> _postAppInitialization(Logger logger) async {
  // Android에서만 AdMob 초기화(실패 무시)
  if (Platform.isAndroid) {
    logger.i('📱 AdMob 초기화 시도 (Android, post-frame)');
    try {
      await AdMobForwardService.instance.initialize();
      logger.i('✅ AdMob 초기화 완료 (광고 미리 로드 시작됨)');

      // 앱 실행 시 광고 표시 (10분 쿨다운)
      await _showAppOpenAdWithCooldown(logger);
    } catch (e) {
      logger.e('⚠️ AdMob 초기화 실패(무시): $e');
    }
  } else {
    logger.i('ℹ️ iOS에서는 AdMob을 초기화하지 않습니다');
  }
}

/// 앱 실행 시 광고 표시 (10분 쿨다운)
Future<void> _showAppOpenAdWithCooldown(Logger logger) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const String lastAdShownKey = 'last_ad_shown_time_millis';

    // 마지막으로 광고를 본 시간 가져오기
    final lastAdShownTimeMillis = prefs.getInt(lastAdShownKey) ?? 0;
    final currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
    const tenMinutesInMillis = 10 * 60 * 1000; // 10분

    if (currentTimeMillis - lastAdShownTimeMillis < tenMinutesInMillis) {
      final remainingMinutes =
          (tenMinutesInMillis - (currentTimeMillis - lastAdShownTimeMillis)) ~/
              (60 * 1000);
      logger.d('ℹ️ 광고 쿨다운 중. ${remainingMinutes + 1}분 후 다시 표시 가능.');
      return;
    }

    logger.i('📺 앱 오픈 광고 표시 시도');

    // 광고가 로드될 때까지 잠시 대기
    await Future.delayed(const Duration(seconds: 2));

    try {
      final shown = await AdMobForwardService.instance.showInterstitialAd();
      if (shown) {
        // 광고가 성공적으로 표시되었으면 현재 시간 기록
        await prefs.setInt(lastAdShownKey, currentTimeMillis);
        logger.i('✅ 앱 오픈 광고 표시 완료 (10분 후 다시 표시 가능)');
      } else {
        logger.w('⚠️ 앱 오픈 광고 표시 실패 (광고 로드 실패)');
      }
    } catch (e) {
      logger.w('⚠️ 앱 오픈 광고 표시 중 오류: $e');
    }
  } catch (e) {
    logger.w('⚠️ 앱 오픈 광고 표시 체크 중 오류 (무시): $e');
  }
}

Future<void> _initializeInitialData(Logger logger) async {
  try {
    logger.i('📦 초기 데이터 체크 시작');

    // 1. 언어 선택 여부 확인
    final prefs = await SharedPreferences.getInstance();
    final languageSelected = prefs.getBool('language_selected') ?? false;
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    // 언어가 선택되지 않았거나 온보딩이 완료되지 않았으면 초기 데이터 삽입하지 않음
    if (!languageSelected) {
      logger.i('⏳ 언어 선택 대기 중 - 초기 데이터 삽입 스킵');
      return;
    }

    if (!onboardingCompleted) {
      logger.i('⏳ 온보딩 대기 중 - 초기 데이터 삽입 스킵');
      return;
    }

    // Repository 생성
    final ingredientRepo = IngredientRepository();
    final recipeRepo = RecipeRepository();
    final unitRepo = UnitRepository();

    final initialDataService = InitialDataService(
      ingredientRepository: ingredientRepo,
      recipeRepository: recipeRepo,
      unitRepository: unitRepo,
    );

    // 초기 데이터가 이미 삽입되었는지 확인
    final isInserted = await initialDataService.isInitialDataInserted();

    if (!isInserted) {
      logger.i('📦 초기 데이터 없음 - 삽입 시작');
      await initialDataService.insertInitialData();
      logger.i('✅ 초기 데이터 삽입 완료');
    } else {
      logger.i('✅ 초기 데이터 이미 존재');
    }
  } catch (e) {
    logger.e('⚠️ 초기 데이터 초기화 실패(무시): $e');
    // 실패해도 앱 실행은 계속
  }
}

/// 인앱 리뷰 요청 체크 및 실행
Future<void> _checkAndRequestReview(Logger logger) async {
  try {
    logger.i('⭐ 인앱 리뷰 체크 시작');

    // 온보딩이 완료되지 않았으면 리뷰 요청하지 않음
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    
    if (!onboardingCompleted) {
      logger.i('⏳ 온보딩 완료 대기 중 - 리뷰 요청 스킵');
      return;
    }

    // 앱 실행 횟수 추적
    const String appLaunchCountKey = 'app_launch_count';
    final launchCount = prefs.getInt(appLaunchCountKey) ?? 0;
    await prefs.setInt(appLaunchCountKey, launchCount + 1);

    // 최소 3회 이상 실행된 경우에만 리뷰 요청
    if (launchCount < 2) {
      logger.i('ℹ️ 앱 실행 횟수 부족 (${launchCount + 1}회) - 리뷰 요청 스킵');
      return;
    }

    // 리뷰 서비스 인스턴스 가져오기
    final reviewService = InAppReviewService();

    // 리뷰 요청 가능 여부 확인
    final canRequest = await reviewService.canRequestReview();
    
    if (canRequest) {
      // 앱이 완전히 로드된 후 3초 대기 (사용자 경험 개선)
      await Future.delayed(const Duration(seconds: 3));
      
      logger.i('⭐ 인앱 리뷰 요청 시작');
      final requested = await reviewService.requestReview();
      
      if (requested) {
        logger.i('✅ 인앱 리뷰 요청 완료');
      } else {
        logger.d('ℹ️ 인앱 리뷰 요청 실패 또는 스킵');
      }
    } else {
      logger.d('ℹ️ 인앱 리뷰 요청 조건 미충족');
    }
  } catch (e) {
    logger.e('⚠️ 인앱 리뷰 체크 중 오류 (무시): $e');
    // 실패해도 앱 실행은 계속
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Firebase Analytics
        RepositoryProvider<FirebaseAnalytics>(
          create: (_) => FirebaseAnalytics.instance,
        ),
        // Repository들
        RepositoryProvider<IngredientRepository>(
          create: (context) => IngredientRepository(),
        ),
        RepositoryProvider<RecipeRepository>(
          create: (context) => RecipeRepository(),
        ),
        RepositoryProvider<TagRepository>(create: (context) => TagRepository()),
        RepositoryProvider<UnitRepository>(
          create: (context) => UnitRepository(),
        ),
        RepositoryProvider<SauceRepository>(
          create: (context) => SauceRepository(),
        ),

        // Services
        RepositoryProvider<NotificationService>(
          create: (context) => NotificationService(),
        ),
        RepositoryProvider<SauceCostService>(
          create: (context) => SauceCostService(
            sauceRepository: context.read<SauceRepository>(),
            ingredientRepository: context.read<IngredientRepository>(),
          ),
        ),
        RepositoryProvider<RecipeCostService>(
          create: (context) => RecipeCostService(
            recipeRepository: context.read<RecipeRepository>(),
            sauceRepository: context.read<SauceRepository>(),
            sauceCostService: context.read<SauceCostService>(),
          ),
        ),
        RepositoryProvider<SauceExpiryService>(
          create: (context) => SauceExpiryService(
            sauceRepository: context.read<SauceRepository>(),
            ingredientRepository: context.read<IngredientRepository>(),
          ),
        ),

        // 레시피 관련 BLoC
        BlocProvider<RecipeCubit>(
          create: (context) => RecipeCubit(
            recipeRepository: context.read<RecipeRepository>(),
            ingredientRepository: context.read<IngredientRepository>(),
            unitRepository: context.read<UnitRepository>(),
            tagRepository: context.read<TagRepository>(),
          ),
        ),

        // 소스 관련 BLoC
        BlocProvider<SauceCubit>(
          create: (context) => SauceCubit(
            sauceRepository: context.read<SauceRepository>(),
            ingredientRepository: context.read<IngredientRepository>(),
            sauceCostService: context.read<SauceCostService>(),
          ),
        ),

        // 태그 관련 BLoC
        BlocProvider<TagCubit>(
          create: (context) => TagCubit(
            tagRepository: context.read<TagRepository>(),
            ingredientRepository: context.read<IngredientRepository>(),
            recipeRepository: context.read<RecipeRepository>(),
          ),
        ),

        // 알림 관련 BLoC
        BlocProvider<ExpiryNotificationCubit>(
          create: (context) => ExpiryNotificationCubit(
            ingredientRepository: context.read<IngredientRepository>(),
            sauceRepository: context.read<SauceRepository>(),
            sauceExpiryService: context.read<SauceExpiryService>(),
            notificationService: context.read<NotificationService>(),
          ),
        ),
        BlocProvider<NotificationPermissionCubit>(
          create: (_) => NotificationPermissionCubit()..refresh(),
        ),

        // 재료 관련 BLoC (알림 Cubit 이후 생성하여 주입 가능)
        BlocProvider<IngredientCubit>(
          create: (context) => IngredientCubit(
            ingredientRepository: context.read<IngredientRepository>(),
            tagRepository: context.read<TagRepository>(),
            expiryNotificationCubit: context.read<ExpiryNotificationCubit>(),
          ),
        ),

        // 온보딩 관련 Cubit (라우터에서 사용되므로 먼저 초기화)
        BlocProvider<OnboardingCubit>(create: (context) => OnboardingCubit()),

        // 로케일 관련 BLoC
        BlocProvider<LocaleCubit>(create: (context) => LocaleCubit()),

        // 숫자 포맷팅 관련 Cubit
        BlocProvider<NumberFormatCubit>(
          create: (context) => NumberFormatCubit(),
        ),

        // OCR 관련 Cubit
        BlocProvider<OcrCubit>(create: (context) => OcrCubit()),

        // 테마 관련 BLoC
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),

        // 백과사전 관련 Cubit
        BlocProvider<EncyclopediaCubit>(
          create: (context) => EncyclopediaCubit(
            service: EncyclopediaService(),
          ),
        ),

        // Firebase 인증 관련 BLoC
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: AuthRepository())..add(AppStarted()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleCubit, AppLocale>(
            builder: (context, currentLocale) {
              return PermissionRequester(
                child: MaterialApp.router(
                  title: AppStrings.getAppTitle(currentLocale),
                  theme: AppTheme.getTheme(
                    themeState.themeType,
                    themeState.brightness,
                  ),
                  routerConfig: AppRouter.router,
                  debugShowCheckedModeBanner: false,
                  locale: currentLocale.locale,
                  supportedLocales: AppLocale.supportedLocales,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PermissionRequester extends StatefulWidget {
  final Widget child;
  const PermissionRequester({super.key, required this.child});

  @override
  State<PermissionRequester> createState() => _PermissionRequesterState();
}

class _PermissionRequesterState extends State<PermissionRequester> {
  @override
  void initState() {
    super.initState();
    // OnboardingCubit 초기화를 위해 더 긴 지연 시간 설정
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // OnboardingCubit 초기화 완료 대기
      await Future.delayed(const Duration(milliseconds: 500));
      _initializeNotificationService();
    });
  }

  // NotificationService.initialize()에서 Android POST_NOTIFICATIONS, iOS 알림 권한 요청
  // 초기화 완료 후 loadExpiryNotifications()로 알람 스케줄 등록

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _initializeNotificationService() async {
    try {
      if (!mounted) return;
      final service = context.read<NotificationService>();

      // iOS: 네이티브 권한 팝업, Android 13+: POST_NOTIFICATIONS 런타임 요청
      print('🔔 알림 서비스 초기화 및 권한 요청');
      await service.initialize(requestIOSPermission: true);

      if (!mounted) return;
      final notifCubit = context.read<ExpiryNotificationCubit>();
      if (notifCubit.notificationsEnabled) {
        await notifCubit.loadExpiryNotifications();
      }
    } catch (e) {
      // 초기화 실패를 조용히 무시 (디버그 모드에서만 로그)
      debugPrint('Notification service initialization failed: $e');
    }
  }
}
