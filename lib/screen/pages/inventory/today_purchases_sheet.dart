import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/index.dart';
import '../../../data/index.dart';
import '../../../model/index.dart';
import '../../../router/app_router.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_formatter.dart';

/// 오늘 구매 내역 바텀시트.
/// 재고 탭 상단 "오늘 구매" 카드 탭 → 품목/수량/금액 목록 + 합계.
/// 하단 [기간별 리포트 보기] 로 리포트 탭 전환 (유도).
void showTodayPurchasesSheet(BuildContext context, AppLocale locale) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<InventoryCubit>(),
      child: _TodayPurchasesBody(locale: locale),
    ),
  );
}

class _TodayPurchasesBody extends StatelessWidget {
  final AppLocale locale;
  const _TodayPurchasesBody({required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final state = context.watch<InventoryCubit>().state;
    final numberStyle = context.watch<NumberFormatCubit>().state;
    final ingredientsById = {
      for (final ingredient in state.ingredients) ingredient.id: ingredient,
    };

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: tokens.bgElev1,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.r16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.getTodayPurchasesTitle(locale),
                style: AppTypography.title3.copyWith(color: tokens.fgStrong)),
            const SizedBox(height: AppSpacing.s12),
            FutureBuilder<List<InventoryTransaction>>(
              future: InventoryRepository().getTodayPurchases(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.s24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final purchases = snapshot.data!;
                if (purchases.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    child: Center(
                      child: Text(AppStrings.getNoTodayPurchases(locale),
                          style: AppTypography.body2
                              .copyWith(color: tokens.fgTertiary)),
                    ),
                  );
                }

                final total = purchases.fold<double>(
                    0, (sum, t) => sum + (t.price ?? 0));

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: purchases.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: tokens.borderSubtle),
                        itemBuilder: (context, index) {
                          final tx = purchases[index];
                          final ingredient = ingredientsById[tx.ingredientId];
                          final unitName = ingredient == null
                              ? ''
                              : state.unitsById[ingredient.purchaseUnitId]
                                      ?.name ??
                                  '';
                          final qty = tx.qtyDelta == tx.qtyDelta.roundToDouble()
                              ? tx.qtyDelta.toInt().toString()
                              : tx.qtyDelta.toStringAsFixed(1);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.s8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ingredient?.name ?? '—',
                                    style: AppTypography.body2
                                        .copyWith(color: tokens.fgStrong),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text('$qty $unitName',
                                    style: AppTypography.caption1
                                        .copyWith(color: tokens.fgTertiary)),
                                const SizedBox(width: AppSpacing.s12),
                                Text(
                                  NumberFormatter.formatCurrency(
                                      tx.price ?? 0, locale, numberStyle),
                                  style: AppTypography.label1
                                      .copyWith(color: tokens.fgStrong),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Divider(height: 1, color: tokens.borderDefault),
                    const SizedBox(height: AppSpacing.s8),
                    Row(
                      children: [
                        Text(AppStrings.getTotal(locale),
                            style: AppTypography.label1
                                .copyWith(color: tokens.fgSecondary)),
                        const Spacer(),
                        Text(
                          NumberFormatter.formatCurrency(
                              total, locale, numberStyle),
                          style: AppTypography.heading2
                              .copyWith(color: tokens.primary),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.s16),
            // 리포트 탭 유도
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: tokens.primary,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                HomePage.tabRequest.value = 3; // 리포트 탭
              },
              icon: const Icon(Icons.bar_chart, size: 20),
              label: Text(AppStrings.getViewPurchaseReport(locale),
                  style: AppTypography.label1),
            ),
          ],
        ),
      ),
    );
  }
}
