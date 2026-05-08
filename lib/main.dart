import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
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
import 'service/app_open_ad_service.dart';
import 'service/banner_ad_service.dart';
import 'service/startup_app_open_ad.dart';
import 'service/initial_data_service.dart';
import 'service/purchase_history_service.dart';
import 'service/revenue_cat_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'service/notification_service.dart';
import 'controller/ocr/ocr_cubit.dart';
import 'controller/encyclopedia/encyclopedia_cubit.dart';
import 'service/encyclopedia_service.dart';
import 'package:logger/logger.dart';
import 'controller/setting/theme_cubit.dart';
import 'controller/report/report_cubit.dart';
import 'firebase_options.dart';

/// 알림 권한 단계가 끝났음을 부팅 시퀀서에 알리기 위한 게이트.
/// [PermissionRequester._initializeNotificationService] 가 종료될 때 complete.
final Completer<void> _notificationReadyCompleter = Completer<void>();

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

  // 부팅 시 prefs 동기 로드 → 초기 라우트 결정.
  // go_router 의 async redirect 가 풀리기 전 HomePage 가 잠깐 그려지는
  // 깜빡임을 방지하기 위해, 첫 프레임부터 올바른 경로로 시작하게 한다.
  await _bootstrapInitialRoute(logger);

  // 타임존 초기화 (zonedSchedule 전 반드시 필요)
  try {
    tz.initializeTimeZones();
    final tzName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzName));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('UTC'));
    logger.w('⚠️ 타임존 초기화 실패, UTC 사용: $e');
  }

  logger.i('🎨 MyApp 실행');
  runApp(const MyApp());
  logger.i('✅ 앱 실행 완료');

  // 프레임 이후(위젯 트리 준비 후) 부팅 시퀀스를 단일 흐름으로 실행
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_runStartupSequence(logger));
  });
}

/// 부팅 후 사용자에게 노출되는 단계들을 직렬화한다.
/// 1) 알림 권한 → 2) 온보딩 완료 → 3) 초기 데이터 → 4) 앱 열기 광고
/// 인앱 리뷰는 부팅 흐름에서 제거 — 재료/레시피가 실제로 추가된 시점에
/// 각 cubit 에서 [InAppReviewService.requestReview] 를 호출한다.
Future<void> _runStartupSequence(Logger logger) async {
  try {
    logger.i('🚦 [Startup] 1) 알림 권한 단계 대기');
    await _notificationReadyCompleter.future;

    logger.i('🚦 [Startup] 2) 온보딩 완료 대기');
    await _waitUntilOnboardingCompleted();

    logger.i('🚦 [Startup] 3) 초기 데이터');
    await _initializeInitialData(logger);

    logger.i('🚦 [Startup] 4) 앱 열기 광고');
    await StartupAppOpenAd.runAppOpenFlow(
      logger,
      loadGrace: const Duration(seconds: 2),
    );

    logger.i('🚦 [Startup] 완료');
  } catch (e, st) {
    logger.e('⚠️ [Startup] 시퀀스 오류 (무시): $e\n$st');
  }
}

/// `onboarding_completed` prefs 가 true 가 될 때까지 polling.
/// 이미 완료된 사용자는 즉시 통과.
Future<void> _waitUntilOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  while (true) {
    if (prefs.getBool('onboarding_completed') ?? false) return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
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

  // RevenueCat 초기화. Firebase Auth cached uid 로 race 없이 시작.
  try {
    logger.i('💳 RevenueCat 초기화 시작');
    final cachedUid = FirebaseAuth.instance.currentUser?.uid;
    await RevenueCatService.instance.initialize(initialAppUserId: cachedUid);
  } catch (e) {
    logger.e('⚠️ RevenueCat 초기화 실패(무시): $e');
  }
}

/// prefs 의 `language_selected` / `onboarding_completed` 를 동기 로드해
/// [AppRouter.bootstrapInitialLocation] 에 첫 경로를 주입한다.
/// 실패해도 앱은 계속 실행 — 그 경우 home(/) 으로 시작.
Future<void> _bootstrapInitialRoute(Logger logger) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final languageSelected = prefs.getBool('language_selected') ?? false;
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!languageSelected) {
      AppRouter.bootstrapInitialLocation(AppRouter.languageSelection);
    } else if (!onboardingCompleted) {
      AppRouter.bootstrapInitialLocation(AppRouter.onboarding);
    }
    logger.i('🧭 초기 라우트: lang=$languageSelected, onboarding=$onboardingCompleted');
  } catch (e) {
    logger.w('⚠️ 초기 라우트 결정 실패(home 으로 진행): $e');
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
        RepositoryProvider<RecipePriceHistoryRepository>(
          create: (context) => RecipePriceHistoryRepository(),
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

        // 재료 관련 BLoC (알림/레시피/소스 Cubit 이후 생성하여 주입 가능)
        BlocProvider<IngredientCubit>(
          create: (context) => IngredientCubit(
            ingredientRepository: context.read<IngredientRepository>(),
            tagRepository: context.read<TagRepository>(),
            expiryNotificationCubit: context.read<ExpiryNotificationCubit>(),
            recipeCubit: context.read<RecipeCubit>(),
            sauceCubit: context.read<SauceCubit>(),
          ),
        ),

        // 온보딩 관련 Cubit (라우터에서 사용되므로 먼저 초기화)
        BlocProvider<OnboardingCubit>(create: (context) => OnboardingCubit()),

        // 로케일 관련 BLoC (ReportCubit 이 의존하므로 먼저 생성)
        BlocProvider<LocaleCubit>(create: (context) => LocaleCubit()),

        // 리포트 관련 Cubit (IngredientCubit + RecipeCubit + LocaleCubit 이후 생성)
        BlocProvider<ReportCubit>(
          create: (context) => ReportCubit(
            recipeRepository: context.read<RecipeRepository>(),
            ingredientRepository: context.read<IngredientRepository>(),
            historyRepository: context.read<RecipePriceHistoryRepository>(),
            unitRepository: context.read<UnitRepository>(),
            recipeCubit: context.read<RecipeCubit>(),
            ingredientCubit: context.read<IngredientCubit>(),
            localeCubit: context.read<LocaleCubit>(),
          )..refresh(),
        ),

        // 숫자 포맷팅 관련 Cubit
        BlocProvider<NumberFormatCubit>(
          create: (context) => NumberFormatCubit(),
        ),

        // OCR 관련 Cubit
        BlocProvider<OcrCubit>(create: (context) => OcrCubit()),

        // 테마 관련 BLoC
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),

        // 보기 모드 관련 Cubit
        BlocProvider<ViewModeCubit>(create: (context) => ViewModeCubit()),
        BlocProvider<RecipeViewModeCubit>(
          create: (context) => RecipeViewModeCubit(),
        ),

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

        // 결제 이력 적재용 Firestore service.
        RepositoryProvider<PurchaseHistoryService>(
          create: (_) => PurchaseHistoryService(),
        ),

        // 광고 제거(RevenueCat) entitlement 상태.
        // lazy:false 로 즉시 생성 — admob_forward 의 premium gate 가 광고 호출
        // 전에 등록되어야 한다. 부팅 직후의 앱 오픈 광고도 게이팅 적용 받음.
        BlocProvider<PremiumCubit>(
          lazy: false,
          create: (ctx) {
            final cubit = PremiumCubit(
              rc: RevenueCatService.instance,
              history: ctx.read<PurchaseHistoryService>(),
            )..bootstrap();
            AdMobForwardService.instance
                .setPremiumGate(() => cubit.state.isPremium);
            AppOpenAdService.instance
                .setPremiumGate(() => cubit.state.isPremium);
            BannerAdService.instance
                .setPremiumGate(() => cubit.state.isPremium);
            return cubit;
          },
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            curr is Authenticated || curr is Unauthenticated,
        listener: _onAuthStateChanged,
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LocaleCubit, AppLocale>(
              builder: (context, currentLocale) {
                return PermissionRequester(
                  child: MaterialApp.router(
                    title: AppStrings.getAppTitle(currentLocale),
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode:
                        themeState.isDark ? ThemeMode.dark : ThemeMode.light,
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
      ),
    );
  }

  /// 로그인/로그아웃 변화에 맞춰 RevenueCat App User ID 를 동기화.
  /// SDK 가 ready 상태일 때만 호출 — initialize 가 실패했으면 silent skip.
  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      _syncRevenueCatLogin(context, state.user.uid);
    } else if (state is Unauthenticated) {
      _syncRevenueCatLogout(context);
    }
  }

  Future<void> _syncRevenueCatLogin(BuildContext context, String uid) async {
    final rc = RevenueCatService.instance;
    if (!rc.isReady) return;
    try {
      await rc.identify(uid);
      if (!context.mounted) return;
      await context.read<PremiumCubit>().refreshFromStore();
    } catch (e) {
      debugPrint('[RevenueCat] identify failed: $e');
    }
  }

  Future<void> _syncRevenueCatLogout(BuildContext context) async {
    final rc = RevenueCatService.instance;
    if (!rc.isReady) return;
    try {
      await rc.logout();
      if (!context.mounted) return;
      await context.read<PremiumCubit>().refreshFromStore();
    } catch (e) {
      debugPrint('[RevenueCat] logout failed: $e');
    }
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
    } finally {
      // 부팅 시퀀서가 다음 단계(온보딩/광고/리뷰)로 진행하도록 게이트 해제.
      // 실패 경로에서도 반드시 풀어주어야 영원히 대기하지 않는다.
      if (!_notificationReadyCompleter.isCompleted) {
        _notificationReadyCompleter.complete();
      }
    }
  }
}
