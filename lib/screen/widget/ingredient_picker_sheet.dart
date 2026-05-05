import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/ingredient/ingredient_cubit.dart';
import '../../controller/ingredient/ingredient_state.dart';
import '../../controller/setting/locale_cubit.dart';
import '../../controller/setting/number_format_cubit.dart';
import '../../model/ingredient.dart';
import '../../theme/tokens/tokens.dart';
import '../../util/app_strings.dart';
import '../../util/number_formatter.dart';
import '../../util/unit_converter.dart' as uc;

/// 재료 선택 바텀 시트.
///
/// 이미 선택된 재료는 [excludeIds] 로 전달해서 목록에서 제외한다.
/// 사용자가 한 항목을 탭하면 해당 [Ingredient] 가 반환되고, X 또는
/// 바깥 영역을 탭해 닫으면 `null` 이 반환된다.
Future<Ingredient?> showIngredientPickerSheet(
  BuildContext context, {
  required List<String> excludeIds,
}) {
  final tokens = AppColorTokens.of(context);
  return showModalBottomSheet<Ingredient>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: tokens.fgStrong.withValues(alpha: 0.4),
    builder: (sheetCtx) {
      return _IngredientPickerSheet(excludeIds: excludeIds);
    },
  );
}

class _IngredientPickerSheet extends StatelessWidget {
  final List<String> excludeIds;

  const _IngredientPickerSheet({required this.excludeIds});

  List<Ingredient> _ingredientsOf(IngredientState state) {
    if (state is IngredientLoaded) return state.ingredients;
    if (state is IngredientFilteredByTag) return state.ingredients;
    if (state is IngredientFilteredByTags) return state.ingredients;
    if (state is IngredientFilteredByExpiry) return state.ingredients;
    if (state is IngredientSearchResult) return state.ingredients;
    if (state is IngredientAdded) return state.ingredients;
    if (state is IngredientUpdated) return state.ingredients;
    if (state is IngredientDeleted) return state.ingredients;
    return const [];
  }

  double _pricePerBaseUnit(Ingredient ing) {
    final unit = uc.UnitConverter.getUnit(ing.purchaseUnitId);
    final factor = unit?.conversionFactor ?? 1.0;
    final denom = ing.purchaseAmount * factor;
    if (denom == 0) return 0;
    return ing.purchasePrice / denom;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.read<LocaleCubit>().state;
    final formatStyle = context.read<NumberFormatCubit>().state;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetCtx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: tokens.bgBase,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.r20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // 드래그 핸들
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.borderDefault,
                      borderRadius: AppRadius.brPill,
                    ),
                  ),
                ),
                // 타이틀 + X 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s12,
                    AppSpacing.s8,
                    AppSpacing.s8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.getSelectIngredientSheet(locale),
                          style: AppTypography.heading2.copyWith(
                            color: tokens.fgStrong,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: tokens.fgSecondary),
                        tooltip: AppStrings.getClose(locale),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<IngredientCubit, IngredientState>(
                    builder: (ctx, state) {
                      if (state is IngredientLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final all = _ingredientsOf(state);
                      final visible = all
                          .where((i) => !excludeIds.contains(i.id))
                          .toList();

                      if (visible.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.s24),
                            child: Text(
                              '추가할 재료가 없습니다',
                              style: AppTypography.body2.copyWith(
                                color: tokens.fgTertiary,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s20,
                          AppSpacing.s4,
                          AppSpacing.s20,
                          AppSpacing.s24,
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 6),
                        itemBuilder: (_, index) {
                          final ing = visible[index];
                          final perUnit = NumberFormatter
                              .formatPerBaseUnitPrice(
                            _pricePerBaseUnit(ing),
                            ing.purchaseUnitId,
                            locale,
                            formatStyle,
                          );
                          return _IngredientRow(
                            name: ing.name,
                            subtitle: perUnit,
                            onTap: () => Navigator.of(context).pop(ing),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  const _IngredientRow({
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Material(
      color: tokens.bgMuted,
      borderRadius: AppRadius.brR12,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brR12,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTypography.headline2.copyWith(
                        color: tokens.fgStrong,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
              Icon(Icons.add, color: tokens.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
