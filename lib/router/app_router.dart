import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screen/pages/ingredient/ingredient_main_page.dart';
import '../screen/pages/ingredient/ingredient_add_page.dart';
import '../screen/pages/ingredient/ingredient_edit_page.dart';
import '../screen/pages/recipe/recipe_main_page.dart';
import '../screen/pages/recipe/recipe_add_page.dart';
import '../screen/pages/recipe/recipe_edit_page.dart';
import '../screen/pages/settings_page.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../util/app_locale.dart';
import '../util/number_formatter.dart';
import '../util/date_formatter.dart';
import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../screen/widget/index.dart';

/// 앱 라우터 설정
class AppRouter {
  static const String home = '/';
  static const String ingredients = '/ingredients';
  static const String recipes = '/recipes';
  static const String settings = '/settings';
  static const String widgetExamples = '/widget-examples';
  static const String recipeCreate = '/recipe/create';
  static const String ingredientAdd = '/ingredient/add';
  static const String ingredientEdit = '/ingredient/edit';
  static const String recipeEdit = '/recipe/edit';
  static const String ingredientDetail = '/ingredient/detail';
  static const String recipeDetail = '/recipe/detail';
  static const String scanReceipt = '/scan-receipt';

  /// GoRouter 인스턴스 생성
  static GoRouter get router => GoRouter(
    initialLocation: home,
    routes: [
      // 홈 페이지 (탭 네비게이션)
      GoRoute(path: home, builder: (context, state) => const HomePage()),

      // 재료 관련 라우트
      GoRoute(
        path: ingredients,
        builder: (context, state) => const IngredientMainPage(),
      ),
      GoRoute(
        path: ingredientAdd,
        builder: (context, state) => const IngredientAddPage(),
      ),
      GoRoute(
        path: ingredientEdit,
        builder: (context, state) {
          final ingredient = state.extra as Ingredient?;
          return IngredientEditPage(ingredient: ingredient!);
        },
      ),
      GoRoute(
        path: ingredientDetail,
        builder: (context, state) {
          final ingredient = state.extra as Ingredient?;
          return IngredientDetailPage(ingredient: ingredient!);
        },
      ),

      // 레시피 관련 라우트
      GoRoute(
        path: recipes,
        builder: (context, state) => const RecipeMainPage(),
      ),
      GoRoute(
        path: recipeCreate,
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return RecipeAddPage(
            selectedIngredients:
                args?['selectedIngredients'] as List<Ingredient>?,
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
      GoRoute(
        path: recipeDetail,
        builder: (context, state) {
          final recipe = state.extra as Recipe?;
          return RecipeDetailPage(recipe: recipe!);
        },
      ),

      // 설정 페이지
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // 영수증 스캔 페이지
      GoRoute(
        path: scanReceipt,
        builder: (context, state) => const ScanReceiptPage(),
      ),
    ],

    // 에러 페이지
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('페이지를 찾을 수 없습니다'),
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
              '페이지를 찾을 수 없습니다',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '요청하신 페이지가 존재하지 않거나 이동되었습니다.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
              child: const Text('홈으로 돌아가기'),
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
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: '재료'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: '레시피',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}

/// 재료 상세 페이지 (임시)
class IngredientDetailPage extends StatelessWidget {
  final Ingredient ingredient;

  const IngredientDetailPage({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(ingredient.name),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '재료 정보',
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('이름', ingredient.name),
                  _buildInfoRow(
                    '구매 가격',
                    NumberFormatter.formatCurrency(
                      ingredient.purchasePrice,
                      AppLocale.korea,
                    ),
                  ),
                  _buildInfoRow(
                    '구매 수량',
                    '${ingredient.purchaseAmount} ${ingredient.purchaseUnitId}',
                  ),
                  if (ingredient.expiryDate != null)
                    _buildInfoRow(
                      '유통기한',
                      DateFormatter.formatDate(
                        ingredient.expiryDate!,
                        AppLocale.korea,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}

/// 레시피 상세 페이지 (임시)
class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRouter.recipeEdit, extra: recipe),
            icon: const Icon(Icons.edit, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '레시피 정보',
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('이름', recipe.name),
                  _buildInfoRow('설명', recipe.description),
                  _buildInfoRow(
                    '생산량',
                    '${recipe.outputAmount} ${recipe.outputUnit}',
                  ),
                  _buildInfoRow(
                    '총 원가',
                    NumberFormatter.formatCurrency(
                      recipe.totalCost,
                      AppLocale.korea,
                    ),
                  ),
                  _buildInfoRow(
                    '1인분당 원가',
                    NumberFormatter.formatCurrency(
                      recipe.costPerServing,
                      AppLocale.korea,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '재료 목록',
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (recipe.ingredients.isEmpty)
                    Text(
                      '등록된 재료가 없습니다.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipe.ingredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = recipe.ingredients[index];
                        return ListTile(
                          title: Text('재료 ID: ${ingredient.ingredientId}'),
                          subtitle: Text(
                            '${ingredient.amount} ${ingredient.unitId}',
                          ),
                          trailing: Text(
                            NumberFormatter.formatCurrency(
                              ingredient.calculatedCost,
                              AppLocale.korea,
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
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
}

/// 영수증 스캔 페이지 (임시)
class ScanReceiptPage extends StatelessWidget {
  const ScanReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('영수증 스캔'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const Center(child: Text('영수증 스캔 기능은 추후 구현 예정입니다.')),
    );
  }
}
