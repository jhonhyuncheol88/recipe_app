import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../util/app_strings.dart';
import '../../util/app_locale.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/setting/locale_cubit.dart';

/// 앱에서 사용하는 빈 상태 위젯
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final Color? iconColor;

  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onActionPressed,
    this.actionText,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 60,
                  color: iconColor ?? AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onActionPressed != null && actionText != null) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: onActionPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: AppColors.buttonText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(actionText!, style: AppTextStyles.buttonMedium),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 재료 빈 상태 위젯
class IngredientEmptyState extends StatelessWidget {
  final VoidCallback? onAddPressed;
  final VoidCallback? onScanPressed;

  const IngredientEmptyState({
    super.key,
    this.onAddPressed,
    this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    return AppEmptyState(
      title: AppStrings.getNoIngredients(currentLocale),
      subtitle: AppStrings.getNoIngredientsDescription(currentLocale),
      icon: Icons.inventory_2,
      iconColor: AppColors.accent,
      onActionPressed: onScanPressed ?? onAddPressed,
      actionText: onScanPressed != null
          ? AppStrings.getScanReceiptButton(currentLocale)
          : AppStrings.getAddIngredientButton(currentLocale),
    );
  }
}

/// 레시피 빈 상태 위젯
class RecipeEmptyState extends StatelessWidget {
  final VoidCallback? onAddPressed;
  final VoidCallback? onScanPressed;

  const RecipeEmptyState({super.key, this.onAddPressed, this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    return AppEmptyState(
      title: AppStrings.getNoRecipes(currentLocale),
      subtitle: AppStrings.getNoRecipesDescription(currentLocale),
      icon: Icons.restaurant_menu,
      iconColor: AppColors.accent,
    );
  }
}

/// 검색 결과 빈 상태 위젯
class SearchEmptyState extends StatelessWidget {
  final String searchTerm;

  const SearchEmptyState({super.key, required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: '검색 결과가 없습니다',
      subtitle: '"$searchTerm"에 대한 결과를 찾을 수 없습니다.\n다른 검색어를 시도해보세요.',
      icon: Icons.search_off,
      iconColor: AppColors.textLight,
    );
  }
}

/// 로딩 상태 위젯
class AppLoadingState extends StatelessWidget {
  final String message;

  const AppLoadingState({super.key, this.message = '로딩 중...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 오류 상태 위젯
class AppErrorState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.title = '오류가 발생했습니다',
    this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: title,
      subtitle: subtitle ?? '잠시 후 다시 시도해주세요.',
      icon: Icons.error_outline,
      iconColor: AppColors.error,
      onActionPressed: onRetry,
      actionText: '다시 시도',
    );
  }
}
