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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'service/notification_service.dart';
import 'controller/auth/auth_bloc.dart';
import 'controller/auth/auth_event.dart';
import 'data/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드 - assets에서 로드
  await dotenv.load();

  await Firebase.initializeApp();
  final firebaseAnalytics = FirebaseAnalytics.instance;
  await firebaseAnalytics.setAnalyticsCollectionEnabled(true);
  await firebaseAnalytics.logAppOpen();

  // AdMob 초기화
  await AdMobService.instance.initialize();

  runApp(const MyApp());
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

        // 로케일 관련 BLoC
        BlocProvider<LocaleCubit>(create: (context) => LocaleCubit()),

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
  bool _askedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermissionIfNeeded();
      _initializeNotificationService();
    });
  }

  Future<void> _requestNotificationPermissionIfNeeded() async {
    if (_askedOnce) return;
    _askedOnce = true;
    try {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    } catch (_) {
      // ignore errors
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _initializeNotificationService() async {
    try {
      final service = context.read<NotificationService>();
      await service.initialize();
      if (!mounted) return;
      final notifCubit = context.read<ExpiryNotificationCubit>();
      if (notifCubit.notificationsEnabled) {
        await notifCubit.loadExpiryNotifications();
      }
    } catch (_) {}
  }
}
