import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'router/index.dart';
import 'theme/app_theme.dart';
import 'util/app_strings.dart';
import 'util/app_locale.dart';
import 'controller/index.dart';
import 'data/index.dart';
import 'service/sauce_cost_service.dart';
import 'service/recipe_cost_service.dart';
import 'service/sauce_expiry_service.dart';
import 'service/admob_service.dart';
import 'service/initial_data_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'service/notification_service.dart';
import 'controller/ocr/ocr_cubit.dart';
import 'package:logger/logger.dart';
import 'dart:io' show Platform;
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

  logger.i('🎨 MyApp 실행');
  runApp(const MyApp());
  logger.i('✅ 앱 실행 완료');

  // 프레임 이후(위젯 트리 준비 후) 추가 초기화 수행
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await _postAppInitialization(logger);
    await _initializeInitialData(logger);
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
      await AdMobService.instance.initialize();
      logger.i('✅ AdMob 초기화 완료');
    } catch (e) {
      logger.e('⚠️ AdMob 초기화 실패(무시): $e');
    }
  } else {
    logger.i('ℹ️ iOS에서는 AdMob을 초기화하지 않습니다');
  }
}

Future<void> _initializeInitialData(Logger logger) async {
  try {
    logger.i('📦 초기 데이터 체크 시작');

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

        // OCR 관련 Cubit
        BlocProvider<OcrCubit>(create: (context) => OcrCubit()),

        // Firebase 인증 관련 BLoC
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: AuthRepository())..add(AppStarted()),
        ),
      ],
      child: BlocBuilder<LocaleCubit, AppLocale>(
        builder: (context, currentLocale) {
          return PermissionRequester(
            child: MaterialApp.router(
              title: AppStrings.getAppTitle(currentLocale),
              theme: AppTheme.lightTheme,
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

  // NotificationService는 권한 요청 없이 초기화만 수행합니다
  // 실제 권한 요청은 PermissionRequestPage에서 PermissionService를 통해 이루어집니다

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _initializeNotificationService() async {
    try {
      if (!mounted) return;
      final service = context.read<NotificationService>();

      // iOS에서는 네이티브 권한 팝업 표시
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
