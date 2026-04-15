import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recipe_app/util/app_strings.dart';
import '../controller/setting/locale_cubit.dart';
import '../controller/recipe/recipe_cubit.dart';
import '../controller/ingredient/ingredient_cubit.dart';
import '../screen/pages/ingredient/ingredient_main_page.dart';
import '../screen/pages/ingredient/ingredient_add_page.dart';
import '../screen/pages/ingredient/ingredient_bulk_add_page.dart';
import '../screen/pages/ingredient/ingredient_edit_page.dart';
import '../screen/pages/recipe/recipe_main_page.dart';
import '../screen/pages/recipe/recipe_add_page.dart';
import '../screen/pages/recipe/recipe_edit_page.dart';
import '../screen/pages/recipe/recipe_ingredient_select_page.dart';
import '../screen/pages/sauce/sauce_main_page.dart';
import '../screen/pages/sauce/sauce_edit_page.dart';
import '../screen/pages/sauce/sauce_ingredient_select_page.dart';
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
import '../screen/pages/language_selection_page.dart';
import '../screen/pages/encyclopedia/encyclopedia_main_page.dart';
import '../screen/pages/encyclopedia/encyclopedia_recipe_detail_page.dart';
import '../presentation/pages/batch_edit/batch_edit_page.dart';
import '../screen/pages/settings/recipe_tag_management_page.dart';

import '../util/app_locale.dart';

import '../model/encyclopedia_recipe.dart';

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
  static const String recipeIngredientSelect = '/recipe/ingredient-select';
  static const String ingredientAdd = '/ingredient/add';
  static const String ingredientBulkAdd = '/ingredient/bulk-add';
  static const String ingredientEdit = '/ingredient/edit';
  static const String ingredientBatchEdit = '/ingredient/batch-edit';
  static const String recipeEdit = '/recipe/edit';
  static const String ingredientDetail = '/ingredient/detail';
  static const String recipeDetail = '/recipe/detail';
  static const String scanReceipt = '/scan-receipt';
  static const String ocr = '/ocr';
  static const String ocrResult = '/ocr/result';
  static const String sauces = '/sauces';
  static const String sauceEdit = '/sauce/edit';
  static const String sauceIngredientSelect = '/sauce/ingredient-select';
  static const String login = '/login';
  static const String accountInfo = '/account-info';
  static const String languageSelection = '/language-selection';
  static const String onboarding = '/onboarding';
  static const String recipeTagManagement = '/settings/recipe-tags';
  static const String encyclopedia = '/encyclopedia';
  static const String encyclopediaRecipeDetail = '/encyclopedia/recipe/:number';

  /// GoRouter 인스턴스 생성
  static GoRouter get router => GoRouter(
        initialLocation: home,
        redirect: (context, state) async {
          try {
            // 언어 선택 상태 확인 (SharedPreferences)
            final prefs = await SharedPreferences.getInstance();
            final languageSelected =
                prefs.getBool('language_selected') ?? false;
            final onboardingCompleted =
                prefs.getBool('onboarding_completed') ?? false;
            final forceOnboarding = state.extra is Map<String, dynamic> &&
                (state.extra as Map<String, dynamic>)['forceOnboarding'] ==
                    true;

            // 언어가 선택되지 않은 경우 언어 선택 페이지로
            if (!languageSelected &&
                state.matchedLocation != languageSelection) {
              return languageSelection;
            }

            // 언어가 선택되었고 온보딩이 완료되지 않은 경우 온보딩으로
            if (languageSelected &&
                !onboardingCompleted &&
                state.matchedLocation != onboarding &&
                state.matchedLocation != languageSelection &&
                state.matchedLocation != home) {
              return onboarding;
            }

            // 온보딩 완료 후 홈으로
            if (onboardingCompleted &&
                state.matchedLocation == onboarding &&
                !forceOnboarding) {
              return home;
            }

            return null;
          } catch (e) {
            // 에러 발생 시 기본적으로 홈으로 이동
            return null;
          }
        },
        routes: [
          // 언어 선택 페이지
          GoRoute(
            path: languageSelection,
            builder: (context, state) => const LanguageSelectionPage(),
          ),

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
              final preFilledAmount = args?['preFilledAmount'] as String?;
              final preFilledUnit = args?['preFilledUnit'] as String?;
              return IngredientAddPage(
                preFilledIngredientName: preFilledIngredientName,
                preFilledAmount: preFilledAmount,
                preFilledUnit: preFilledUnit,
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
          GoRoute(
            path: ingredientBatchEdit,
            builder: (context, state) => const BatchEditPage(),
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
            path: sauceIngredientSelect,
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              return SauceIngredientSelectPage(
                sauceId: args?['sauceId'] as String? ?? '',
              );
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
            path: recipeIngredientSelect,
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>?;
              return RecipeIngredientSelectPage(
                currentSelectedIngredients:
                    args?['currentSelectedIngredients'] as List<Ingredient>?,
                currentIngredientAmounts:
                    args?['currentIngredientAmounts'] as Map<String, double>?,
                currentIngredientUnitIds:
                    args?['currentIngredientUnitIds'] as Map<String, String>?,
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

          // 백과사전 관련 라우트
          GoRoute(
            path: encyclopedia,
            builder: (context, state) => const EncyclopediaMainPage(),
          ),
          GoRoute(
            path: encyclopediaRecipeDetail,
            builder: (context, state) {
              // extra가 Map인 경우 (번역 정보 포함)
              if (state.extra is Map<String, dynamic>) {
                final extra = state.extra as Map<String, dynamic>;
                final recipe = extra['recipe'] as EncyclopediaRecipe?;
                if (recipe != null) {
                  return EncyclopediaRecipeDetailPage(
                    recipe: recipe,
                    translationData:
                        extra['translationData'] as Map<String, dynamic>?,
                  );
                }
              }

              // extra가 EncyclopediaRecipe인 경우 (기존 호환성)
              final recipe = state.extra as EncyclopediaRecipe?;
              if (recipe != null) {
                return EncyclopediaRecipeDetailPage(recipe: recipe);
              }

              // extra가 없으면 번호로 찾기
              final numberStr = state.pathParameters['number'] ?? '';
              final number = int.tryParse(numberStr);
              if (number == null) {
                return const EncyclopediaMainPage();
              }
              // 번호로 레시피를 찾아야 하는데, 여기서는 간단하게 메인으로 리다이렉트
              return const EncyclopediaMainPage();
            },
          ),

          // 설정 페이지
          GoRoute(
            path: settings,
            builder: (context, state) => const SettingsPage(),
          ),

          // 레시피 메뉴 태그 관리 페이지
          GoRoute(
            path: recipeTagManagement,
            builder: (context, state) => const RecipeTagManagementPage(),
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
        errorBuilder: (context, state) => BlocBuilder<LocaleCubit, AppLocale>(
          builder: (context, currentLocale) {
            final colorScheme = Theme.of(context).colorScheme;
            return Scaffold(
              backgroundColor: colorScheme.surface,
              appBar: AppBar(
                title: Text(AppStrings.getPageNotFoundTitle(currentLocale)),
                backgroundColor: colorScheme.surface,
                elevation: 0,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.getPageNotFoundTitle(currentLocale),
                      style: Theme.of(
                        context,
                      )
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.getPageNotFoundSubtitle(currentLocale),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go(home),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppStrings.getBackToHome(currentLocale)),
                    ),
                  ],
                ),
              ),
            );
          },
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
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        final colorScheme = Theme.of(context).colorScheme;
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

                  // 탭 변경 시 해당 페이지 데이터 새로고침
                  if (index == 1) {
                    // 레시피 탭
                    context.read<RecipeCubit>().loadRecipes();
                  } else if (index == 0) {
                    // 재료 탭
                    context.read<IngredientCubit>().loadIngredients();
                  }
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: colorScheme.surface,
                selectedItemColor: colorScheme.primary,
                unselectedItemColor:
                    colorScheme.onSurface.withValues(alpha: 0.6),
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

/// 영수증 스캔 페이지 (임시)
class ScanReceiptPage extends StatelessWidget {
  const ScanReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        final colorScheme = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(AppStrings.getScanReceipt(currentLocale)),
            backgroundColor: colorScheme.surface,
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
