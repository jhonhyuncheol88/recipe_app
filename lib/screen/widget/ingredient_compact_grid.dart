import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/setting/locale_cubit.dart';
import '../../controller/setting/number_format_cubit.dart';
import '../../model/ingredient.dart';
import '../../theme/app_text_styles.dart';
import '../../util/number_formatter.dart';
import '../../util/unit_converter.dart' as uc;

/// 재료 간편 보기 — 2열 그리드, 이름 + 단위당 가격 표시
class IngredientCompactGrid extends StatelessWidget {
  final List<Ingredient> ingredients;
  final void Function(Ingredient) onTap;
  final void Function(Ingredient) onLongPress;

  const IngredientCompactGrid({
    super.key,
    required this.ingredients,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.4,
      ),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return _CompactGridItem(
          ingredient: ingredient,
          onTap: () => onTap(ingredient),
          onLongPress: () => onLongPress(ingredient),
          colorScheme: colorScheme,
        );
      },
    );
  }
}

class _CompactGridItem extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ColorScheme colorScheme;

  const _CompactGridItem({
    required this.ingredient,
    required this.onTap,
    required this.onLongPress,
    required this.colorScheme,
  });

  Color _dotColor() {
    switch (ingredient.expiryStatus) {
      case ExpiryStatus.expired:
        return const Color(0xFFE53935);
      case ExpiryStatus.danger:
        return const Color(0xFFFF7043);
      case ExpiryStatus.warning:
        return const Color(0xFFFFB300);
      case ExpiryStatus.normal:
        return const Color(0xFF43A047);
    }
  }

  /// 기본 단위(g/ml/개)당 가격 계산
  double _pricePerBaseUnit() {
    final unit = uc.UnitConverter.getUnit(ingredient.purchaseUnitId);
    final factor = unit?.conversionFactor ?? 1.0;
    return ingredient.purchasePrice / (ingredient.purchaseAmount * factor);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;
    final priceText = NumberFormatter.formatPerUnitText(
      _pricePerBaseUnit(),
      ingredient.purchaseUnitId,
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
                      color: ingredient.expiryDate != null
                          ? _dotColor()
                          : colorScheme.onSurface.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ingredient.name,
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
                  priceText,
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
