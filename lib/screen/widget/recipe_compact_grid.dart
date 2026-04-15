import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/setting/locale_cubit.dart';
import '../../controller/setting/number_format_cubit.dart';
import '../../model/recipe.dart';
import '../../theme/app_text_styles.dart';
import '../../util/number_formatter.dart';

/// 레시피 간편 보기 — 2열 그리드, 이름 + 총 원가 표시
class RecipeCompactGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final void Function(Recipe) onTap;
  final void Function(Recipe) onLongPress;

  const RecipeCompactGrid({
    super.key,
    required this.recipes,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.4,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _RecipeCompactItem(
          recipe: recipe,
          onTap: () => onTap(recipe),
          onLongPress: () => onLongPress(recipe),
          colorScheme: colorScheme,
        );
      },
    );
  }
}

class _RecipeCompactItem extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ColorScheme colorScheme;

  const _RecipeCompactItem({
    required this.recipe,
    required this.onTap,
    required this.onLongPress,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;
    final costText = NumberFormatter.formatCurrency(
      recipe.totalCost,
      locale,
      formatStyle,
    );

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      recipe.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 13),
                child: Text(
                  costText,
                  style: AppTextStyles.caption.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
