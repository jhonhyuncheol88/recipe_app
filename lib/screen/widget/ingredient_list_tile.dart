import 'package:flutter/material.dart';

import '../../model/ingredient.dart';
import '../../theme/tokens/tokens.dart';
import '../../util/app_locale.dart';
import '../../util/app_strings.dart';
import '../../util/number_format_style.dart';
import '../../util/number_formatter.dart';
import '../../util/unit_converter.dart' as uc;
import 'ingredient_tag_chip.dart';

/// 재료 메인 페이지의 카드 디자인.
///
/// 좌: 이름·D-day, 단가/구매량 / 우: 가격, 날짜.
class IngredientListTile extends StatelessWidget {
  final Ingredient ingredient;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final VoidCallback onTap;

  const IngredientListTile({
    super.key,
    required this.ingredient,
    required this.locale,
    required this.formatStyle,
    required this.onTap,
  });

  int? get _daysLeft {
    final exp = ingredient.expiryDate;
    if (exp == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(exp.year, exp.month, exp.day);
    return target.difference(today).inDays;
  }

  double _pricePerBaseUnit() {
    final unit = uc.UnitConverter.getUnit(ingredient.purchaseUnitId);
    final factor = unit?.conversionFactor ?? 1.0;
    final denom = ingredient.purchaseAmount * factor;
    if (denom == 0) return 0;
    return ingredient.purchasePrice / denom;
  }

  String _yyyymmdd(DateTime d) {
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yyyy.$mm.$dd';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final days = _daysLeft;
    final hasExpiry = ingredient.expiryDate != null;

    final perUnitText = NumberFormatter.formatPerBaseUnitPrice(
      _pricePerBaseUnit(),
      ingredient.purchaseUnitId,
      locale,
      formatStyle,
    );
    final stockText =
        '${AppStrings.getPurchaseAmountShort(locale)} ${NumberFormatter.formatNumber(ingredient.purchaseAmount.round(), formatStyle)}${ingredient.purchaseUnitId}';
    final priceText = NumberFormatter.formatCurrency(
      ingredient.purchasePrice,
      locale,
      formatStyle,
    );
    final dateText = hasExpiry ? _yyyymmdd(ingredient.expiryDate!) : '';

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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            ingredient.name,
                            style: AppTypography.headline2.copyWith(
                              color: tokens.fgStrong,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (days != null) ...[
                          const SizedBox(width: AppSpacing.s8),
                          IngredientDDayBadge(daysLeft: days),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$perUnitText · $stockText',
                      style: AppTypography.label2.copyWith(
                        color: tokens.fgTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    priceText,
                    style: AppTypography.headline2.copyWith(
                      color: tokens.fgStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (dateText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: AppTypography.label2.copyWith(
                        color: tokens.fgTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
