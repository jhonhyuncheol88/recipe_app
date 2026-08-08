import 'package:flutter/material.dart';

import '../../model/sauce.dart';
import '../../theme/tokens/tokens.dart';
import '../../util/app_locale.dart';
import '../../util/app_strings.dart';
import '../../util/number_format_style.dart';
import '../../util/number_formatter.dart';
import 'favorite_star.dart';

/// 레시피 메인 페이지의 소스 요약 카드.
///
/// 즐겨찾기 화면(Task 8)에서도 재사용된다.
class SauceSummaryCard extends StatelessWidget {
  final Sauce sauce;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  const SauceSummaryCard({
    super.key,
    required this.sauce,
    required this.locale,
    required this.formatStyle,
    required this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final costText = NumberFormatter.formatCurrency(
      sauce.totalCost,
      locale,
      formatStyle,
    );

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
                            sauce.name,
                            style: AppTypography.headline2.copyWith(
                              color: tokens.fgStrong,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onToggleFavorite != null)
                          FavoriteStar(
                            isFavorite: sauce.isFavorite,
                            onTap: onToggleFavorite!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppStrings.getTotalWeight(locale)} ${NumberFormatter.formatNumber(sauce.totalWeight.round(), formatStyle)}g',
                      style: AppTypography.label2.copyWith(
                        color: tokens.fgTertiary,
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
                children: [
                  Text(
                    costText,
                    style: AppTypography.headline2.copyWith(
                      color: tokens.fgStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.getSauceCostLabel(locale),
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
