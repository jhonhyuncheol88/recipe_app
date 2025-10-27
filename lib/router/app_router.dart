import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_app/util/app_strings.dart';
import '../controller/setting/locale_cubit.dart';
import '../controller/onboarding/onboarding_cubit.dart';
import '../screen/pages/ingredient/ingredient_main_page.dart';
import '../screen/pages/ingredient/ingredient_add_page.dart';
import '../screen/pages/ingredient/ingredient_bulk_add_page.dart';
import '../screen/pages/ingredient/ingredient_edit_page.dart';
import '../screen/pages/recipe/recipe_main_page.dart';
import '../screen/pages/recipe/recipe_add_page.dart';
import '../screen/pages/recipe/recipe_edit_page.dart';
import '../screen/pages/sauce/sauce_main_page.dart';
import '../screen/pages/sauce/sauce_edit_page.dart';
import '../model/index.dart';
import '../screen/pages/settings_page.dart';
import '../screen/pages/ai/ai_tabbar_page.dart';
import '../screen/pages/ai/ai_recipe_detail_page.dart';
import '../screen/pages/recipe/ai_sales_analysis_page.dart';
import '../screen/pages/auth/login_screen.dart';
import '../screen/pages/auth/account_info_page.dart';
import '../screen/pages/ocr/ocr_main_page.dart';
import '../screen/pages/ocr/ocr_result_page.dart';
import '../screen/pages/onboarding/onboarding_page.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../util/app_locale.dart';

import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../model/ocr_result.dart';

/// 앱 라우터 설정
class AppRouter {
  static const String home = '/';
  static const String ingredients = '/ingredients';
  static const String recipes = '/recipes';
  static const String ai = '/ai';
  static const String aiRecipeManagement = '/ai/recipes';
  static const String aiRecipeDetail = '/ai/recipe/detail';
  static const String aiSalesAnalysis = '/ai/sales-analysis';
  static const String settings = '/settings';
  static const String widgetExamples = '/widget-examples';
  static const String recipeCreate = '/recipe/create';
  static const String ingredientAdd = '/ingredient/add';
  static const String ingredientBulkAdd = '/ingredient/bulk-add';
  static const String ingredientEdit = '/ingredient/edit';
  static const String recipeEdit = '/recipe/edit';
  static const String ingredientDetail = '/ingredient/detail';
  static const String recipeDetail = '/recipe/detail';
  static const String scanReceipt = '/scan-receipt';
  static const String ocr = '/ocr';
  static const String ocrResult = '/ocr/result';
  static const String sauces = '/sauces';
  static const String sauceEdit = '/sauce/edit';
  static const String login = '/login';
  static const String accountInfo = '/account-info';
  static const String onboarding = '/onboarding';

  /// GoRouter 인스턴스 생성
  static GoRouter get router => GoRouter(
        initialLocation: home,
        redirect: (context, state) async {
          try {
            // 온보딩 상태 확인
            final onboardingCubit = context.read<OnboardingCubit>();
            final onboardingState = onboardingCubit.state;

            // 로딩 중인 경우 리다이렉트하지 않음 (상태 확인 대기)
            if (onboardingState is OnboardingLoading) {
              return null;
            }

            // 온보딩이 완료되지 않았고, 온보딩 페이지가 아닌 경우 온보딩으로 리다이렉트
            if (onboardingState is OnboardingNotCompleted &&
                state.matchedLocation != onboarding) {
              return onboarding;
            }

            // 온보딩이 완료되면 바로 메인 페이지로 이동
            if (onboardingState is OnboardingCompleted) {
              if (state.matchedLocation == onboarding) {
                return home;
              }
            }

            return null;
          } catch (e) {
            // 에러 발생 시 기본적으로 홈으로 이동
            return null;
          }
        },
        routes: [
          // 온보딩 페이지
          GoRoute(
            path: onboarding,
            builder: (context, state) => const OnboardingPage(),
          ),

          // 홈 페이지 (탭 네비게이션)
          GoRoute(path: home, builder: (context, state) => const HomePage()),

          // 재료 관련 라우트
          GoRoute(
            path: ingredients,
            builder: (context, state) => const IngredientMainPage(),
          ),
          GoRoute(
            path: ingredientAdd,
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              final preFilledIngredientName =
                  args?['preFilledIngredientName'] as String?;
              return IngredientAddPage(
                preFilledIngredientName: preFilledIngredientName,
              );
            },
          ),
          GoRoute(
            path: ingredientBulkAdd,
            builder: (context, state) => const IngredientBulkAddPage(),
          ),
          GoRoute(
            path: ingredientEdit,
            builder: (context, state) {
              final ingredient = state.extra as Ingredient?;
              return IngredientEditPage(ingredient: ingredient!);
            },
          ),

          // 레시피 관련 라우트
          GoRoute(
            path: recipes,
            builder: (context, state) => const RecipeMainPage(),
          ),
          // 소스 관련 라우트
          GoRoute(
              path: sauces, builder: (context, state) => const SauceMainPage()),
          GoRoute(
            path: sauceEdit,
            builder: (context, state) {
              final sauce = state.extra as Sauce?;
              return SauceEditPage(sauce: sauce!);
            },
          ),
          GoRoute(
            path: recipeCreate,
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              return RecipeAddPage(
                selectedIngredients:
                    args?['selectedIngredients'] as List<Ingredient>?,
                selectedSauces: args?['selectedSauces'] as List<Sauce>?,
              );
            },
          ),
          GoRoute(
            path: recipeEdit,
            builder: (context, state) {
              final recipe = state.extra as Recipe?;
              return RecipeEditPage(recipe: recipe!);
            },
          ),

          // 설정 페이지
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsPage(),
          ),

          // 로그인 페이지
          GoRoute(path: login, builder: (context, state) => LoginScreen()),

          // 계정 정보 페이지
          GoRoute(
            path: accountInfo,
            builder: (context, state) => const AccountInfoPage(),
          ),

          // AI 페이지 (탭바 페이지)
          GoRoute(path: ai, builder: (context, state) => const AiTabbarPage()),

          // AI 레시피 상세 페이지
          GoRoute(
            path: aiRecipeDetail,
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              final aiRecipeId = args?['aiRecipeId'] as String? ?? '';
              return AiRecipeDetailPage(aiRecipeId: aiRecipeId);
            },
          ),

          // AI 판매 분석 페이지
          GoRoute(
            path: aiSalesAnalysis,
            builder: (context, state) {
              final recipe = state.extra as Recipe?;
              if (recipe == null) {
                return const Scaffold(
                    body: Center(child: Text('레시피 정보가 없습니다.')));
              }

              return AiSalesAnalysisPage(recipe: recipe);
            },
          ),

          // 영수증 스캔 페이지
          GoRoute(
            path: scanReceipt,
            builder: (context, state) => const ScanReceiptPage(),
          ),

          // OCR 메인 페이지
          GoRoute(path: ocr, builder: (context, state) => const OcrMainPage()),

          // OCR 결과 페이지
          GoRoute(
            path: ocrResult,
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              final ingredients =
                  args?['ingredients'] as List<Ingredient>? ?? [];
              final imagePath = args?['imagePath'] as String?;
              final ocrResult = args?['ocrResult'] as OcrResult?;

              if (imagePath == null) {
                return const Scaffold(
                    body: Center(child: Text('이미지 정보가 없습니다.')));
              }

              return OcrResultPage(
                ingredients: ingredients,
                imageFile: File(imagePath),
                ocrResult: ocrResult,
              );
            },
          ),
        ],

        // 에러 페이지
        errorBuilder: (context, state) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppStrings.getPageNotFoundTitle(AppLocale.korea)),
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  AppStrings.getPageNotFoundTitle(AppLocale.korea),
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.getPageNotFoundSubtitle(AppLocale.korea),
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppStrings.getBackToHome(AppLocale.korea)),
                ),
              ],
            ),
          ),
        ),
      );
}

/// 홈 페이지 (탭 네비게이션)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const IngredientMainPage(),
    const RecipeMainPage(),
    const AiTabbarPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 하단 네비게이션 바
              BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.surface,
                selectedItemColor: AppColors.accent,
                unselectedItemColor: AppColors.textSecondary,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.inventory_2),
                    label: AppStrings.getIngredients(currentLocale),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.restaurant_menu),
                    label: AppStrings.getRecipes(currentLocale),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.auto_awesome),
                    label: AppStrings.getAi(currentLocale),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: AppStrings.getSettings(currentLocale),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );
}

/// 영수증 스캔 페이지 (임시)
class ScanReceiptPage extends StatelessWidget {
  const ScanReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AppStrings.getScanReceipt(currentLocale)),
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          body: Center(
            child: Text(
              AppStrings.getFeatureComingSoon(currentLocale, '영수증 스캔'),
            ),
          ),
        );
      },
    );
  }
}
