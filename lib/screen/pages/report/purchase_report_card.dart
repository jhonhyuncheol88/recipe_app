import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controller/report/purchase_report_cubit.dart';
import '../../../model/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';

/// 리포트 탭 "구매 지출" 카드.
/// 자체 [일|월|연] 토글 + 막대 차트 + 기간 합계. 리포트 기간 세그먼트와 무관.
class PurchaseReportCard extends StatelessWidget {
  final AppLocale locale;
  final NumberFormatStyle formatStyle;

  const PurchaseReportCard({
    super.key,
    required this.locale,
    required this.formatStyle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PurchaseReportCubit>(
      create: (_) => PurchaseReportCubit()..load(),
      child: BlocBuilder<PurchaseReportCubit, PurchaseReportState>(
        builder: (context, state) {
          final tokens = AppColorTokens.of(context);
          return Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: tokens.bgElev1,
              borderRadius: AppRadius.brR16,
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 20, color: tokens.primary),
                    const SizedBox(width: AppSpacing.s8),
                    Text(AppStrings.getPurchaseReportTitle(locale),
                        style: AppTypography.heading1
                            .copyWith(color: tokens.fgStrong)),
                    const Spacer(),
                    Text(
                      NumberFormatter.formatCurrency(
                          state.periodTotal, locale, formatStyle),
                      style: AppTypography.heading2
                          .copyWith(color: tokens.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                _PeriodToggle(state: state, locale: locale),
                const SizedBox(height: AppSpacing.s16),
                if (state.isLoading)
                  const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.totals.isEmpty)
                  SizedBox(
                    height: 120,
                    child: Center(
                      child: Text(AppStrings.getNoPurchaseData(locale),
                          style: AppTypography.body2
                              .copyWith(color: tokens.fgTertiary)),
                    ),
                  )
                else
                  SizedBox(
                    height: 160,
                    child: _PurchaseBarChart(
                      state: state,
                      tokens: tokens,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final PurchaseReportState state;
  final AppLocale locale;
  const _PeriodToggle({required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final cubit = context.read<PurchaseReportCubit>();

    Widget chip(String label, PurchasePeriod value) {
      final selected = state.period == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => cubit.load(value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
            decoration: BoxDecoration(
              color: selected ? tokens.primary : tokens.bgMuted,
              borderRadius: AppRadius.brR8,
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTypography.label2.copyWith(
                color: selected ? tokens.fgOnPrimary : tokens.fgSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(AppStrings.getPurchaseDaily(locale), PurchasePeriod.daily),
        const SizedBox(width: AppSpacing.s6),
        chip(AppStrings.getPurchaseMonthly(locale), PurchasePeriod.monthly),
        const SizedBox(width: AppSpacing.s6),
        chip(AppStrings.getPurchaseYearly(locale), PurchasePeriod.yearly),
      ],
    );
  }
}

class _PurchaseBarChart extends StatelessWidget {
  final PurchaseReportState state;
  final AppColorTokens tokens;
  const _PurchaseBarChart({required this.state, required this.tokens});

  /// 라벨 축약: 일 'MM-dd'→'dd', 월 'yyyy-MM'→'MM', 연 'yyyy' 그대로
  String _shortLabel(String label) {
    switch (state.period) {
      case PurchasePeriod.daily:
        return label.substring(8); // yyyy-MM-dd → dd
      case PurchasePeriod.monthly:
        return label.substring(5); // yyyy-MM → MM
      case PurchasePeriod.yearly:
        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = state.totals;
    final maxTotal =
        totals.fold<double>(0, (max, r) => r.total > max ? r.total : max);
    // 라벨이 많으면(일 단위 30개) 겹치지 않게 간격을 두고 표시
    final labelStep = (totals.length / 6).ceil().clamp(1, 10);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxTotal * 1.2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              '${totals[group.x].label}\n${rod.toY.toInt()}',
              AppTypography.caption1.copyWith(color: tokens.fgOnPrimary),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 ||
                    index >= totals.length ||
                    index % labelStep != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s4),
                  child: Text(
                    _shortLabel(totals[index].label),
                    style: AppTypography.caption2
                        .copyWith(color: tokens.fgTertiary),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < totals.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: totals[i].total,
                  color: tokens.primary,
                  width: totals.length > 15 ? 6 : 14,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(AppRadius.r4)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
