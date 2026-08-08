import 'package:flutter/material.dart';

import '../../model/recipe.dart';
import '../../theme/tokens/tokens.dart';
import '../../util/app_locale.dart';
import '../../util/app_strings.dart';
import '../../util/number_format_style.dart';
import '../../util/number_formatter.dart';
import '../../util/recipe_margin.dart';
import 'favorite_star.dart';

/// 레시피 메인 페이지의 레시피 요약 카드.
///
/// 즐겨찾기 화면(Task 8)에서도 재사용된다.
class RecipeSummaryCard extends StatelessWidget {
  final Recipe recipe;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  const RecipeSummaryCard({
    super.key,
    required this.recipe,
    required this.locale,
    required this.formatStyle,
    required this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final ingredientCount = recipe.ingredients.length;
    final sauceCount = recipe.sauces.length;
    final servings =
        '${NumberFormatter.formatNumber(recipe.outputAmount.round(), formatStyle)}${recipe.outputUnit}';
    final costText = NumberFormatter.formatCurrency(
      recipe.totalCost,
      locale,
      formatStyle,
    );
    final sellText = NumberFormatter.formatCurrency(
      recipe.sellPrice,
      locale,
      formatStyle,
    );
    final marginPct = RecipeMargin.percent(recipe.sellPrice, recipe.totalCost);
    final marginColor = recipe.sellPrice <= 0
        ? tokens.fgTertiary
        : RecipeMargin.color(marginPct, tokens);
    final marginText = recipe.sellPrice <= 0
        ? '-'
        : '${marginPct.toStringAsFixed(0)}%';

    return Material(
      color: tokens.bgBase,
      borderRadius: AppRadius.brR16,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brR16,
        child: Container(
          decoration: BoxDecoration(
            color: tokens.bgBase,
            borderRadius: AppRadius.brR16,
            border: Border.all(color: tokens.borderSubtle, width: 1),
          ),
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            style: AppTypography.headline2.copyWith(
                              color: tokens.fgStrong,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onToggleFavorite != null)
                          FavoriteStar(
                            isFavorite: recipe.isFavorite,
                            onTap: onToggleFavorite!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppStrings.getIngredients(locale)} $ingredientCount · ${AppStrings.getSauces(locale)} $sauceCount · $servings',
                      style: AppTypography.label2.copyWith(
                        color: tokens.fgTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Row(
                      children: [
                        Flexible(
                          child: _CostSellPair(
                            label: AppStrings.getCost(locale),
                            value: costText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: _CostSellPair(
                            label: AppStrings.getSell(locale),
                            value: sellText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    marginText,
                    style: AppTypography.title3.copyWith(
                      color: marginColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.getMarginRate(locale),
                    style: AppTypography.label2.copyWith(
                      color: tokens.fgTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostSellPair extends StatelessWidget {
  final String label;
  final String value;

  const _CostSellPair({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTypography.label2.copyWith(color: tokens.fgTertiary),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: AppTypography.label2.copyWith(
              color: tokens.fgStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
