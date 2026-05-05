import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controller/report/report_cubit.dart';
import '../../../controller/report/report_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/report_data.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_strings/app_strings_report.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import '../../../util/recipe_margin.dart';
import '../../widget/segment_control.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, locale) {
        return BlocBuilder<NumberFormatCubit, NumberFormatStyle>(
          builder: (context, formatStyle) {
            return BlocBuilder<ReportCubit, ReportState>(
              builder: (context, state) {
                return _ReportScaffold(
                  state: state,
                  locale: locale,
                  formatStyle: formatStyle,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ReportScaffold extends StatelessWidget {
  final ReportState state;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;

  const _ReportScaffold({
    required this.state,
    required this.locale,
    required this.formatStyle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.bgBase,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, tokens)),
            SliverToBoxAdapter(child: _buildPeriodSegment(context)),
            SliverToBoxAdapter(child: _buildMonthPicker(context, tokens)),
            if (state is ReportLoading)
              SliverToBoxAdapter(child: _buildLoadingBody(tokens))
            else if (state is ReportLoaded)
              SliverToBoxAdapter(
                child: _buildLoadedBody(
                  context,
                  (state as ReportLoaded).data,
                  (state as ReportLoaded).period,
                  tokens,
                ),
              )
            else if (state is ReportError)
              SliverToBoxAdapter(
                child: _buildError(
                  context,
                  (state as ReportError).message,
                  tokens,
                ),
              )
            else
              SliverToBoxAdapter(child: _buildEmptyInitial(tokens)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppColorTokens tokens) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s24,
        AppSpacing.s20,
        AppSpacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getReport(locale),
            style: AppTypography.title2.copyWith(color: tokens.fgStrong),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            AppStrings.getReportSubtitle(locale),
            style: AppTypography.body2.copyWith(color: tokens.fgTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSegment(BuildContext context) {
    final currentPeriod =
        state is ReportLoaded
            ? (state as ReportLoaded).period
            : ReportPeriod.monthly;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s8,
      ),
      child: SegmentControl<ReportPeriod>(
        items: [
          SegmentItem(
            value: ReportPeriod.weekly,
            label: AppStrings.getPeriodWeekly(locale),
          ),
          SegmentItem(
            value: ReportPeriod.monthly,
            label: AppStrings.getPeriodMonthly(locale),
          ),
          SegmentItem(
            value: ReportPeriod.quarterly,
            label: AppStrings.getPeriodQuarterly(locale),
          ),
        ],
        selected: currentPeriod,
        onChanged: (p) => context.read<ReportCubit>().changePeriod(p),
      ),
    );
  }

  /// monthly 모드일 때만 노출되는 월 선택 버튼.
  /// 탭하면 최근 12개월 리스트가 bottom sheet 로 뜬다.
  Widget _buildMonthPicker(BuildContext context, AppColorTokens tokens) {
    if (state is! ReportLoaded) return const SizedBox.shrink();
    final loaded = state as ReportLoaded;
    if (loaded.period != ReportPeriod.monthly) {
      return const SizedBox.shrink();
    }

    final anchor = loaded.anchorMonth ??
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    final label = _formatMonthLabel(anchor, locale);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s4,
        AppSpacing.s20,
        AppSpacing.s8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: () => _openMonthPicker(context, anchor),
          borderRadius: AppRadius.brR8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: tokens.bgMuted,
              borderRadius: AppRadius.brR8,
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: tokens.fgSecondary,
                ),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  label,
                  style: AppTypography.label2.copyWith(color: tokens.fgStrong),
                ),
                const SizedBox(width: AppSpacing.s4),
                Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: tokens.fgTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMonthPicker(BuildContext context, DateTime current) {
    final tokens = AppColorTokens.of(context);
    final cubit = context.read<ReportCubit>();
    final now = DateTime.now();
    final months = List<DateTime>.generate(
      12,
      (i) => DateTime(now.year, now.month - i, 1),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.bgBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.s12),
                decoration: BoxDecoration(
                  color: tokens.borderSubtle,
                  borderRadius: AppRadius.brPill,
                ),
              ),
              ...months.map((m) {
                final isSelected =
                    m.year == current.year && m.month == current.month;
                return ListTile(
                  title: Text(
                    _formatMonthLabel(m, locale),
                    style: AppTypography.body2.copyWith(
                      color: isSelected ? tokens.primary : tokens.fgDefault,
                      fontWeight: isSelected ? FontWeight.w700 : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: tokens.primary)
                      : null,
                  onTap: () {
                    final isCurrentMonth =
                        m.year == now.year && m.month == now.month;
                    cubit.changeAnchorMonth(isCurrentMonth ? null : m);
                    Navigator.of(sheetCtx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMonthLabel(DateTime m, AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '${m.year}년 ${m.month}월';
      case AppLocale.japan:
        return '${m.year}年${m.month}月';
      case AppLocale.china:
      case AppLocale.chinaTraditional:
        return '${m.year}年${m.month}月';
      case AppLocale.vietnam:
        return 'Tháng ${m.month}/${m.year}';
      case AppLocale.usa:
        const monthsEn = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ];
        return '${monthsEn[m.month - 1]} ${m.year}';
    }
  }

  Widget _buildLoadingBody(AppColorTokens tokens) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        children: [
          _shimmerCard(tokens),
          const SizedBox(height: AppSpacing.s16),
          _shimmerCard(tokens),
          const SizedBox(height: AppSpacing.s16),
          _shimmerCard(tokens),
        ],
      ),
    );
  }

  Widget _shimmerCard(AppColorTokens tokens) {
    return _ReportCard(
      child: SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: tokens.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedBody(
    BuildContext context,
    ReportData data,
    ReportPeriod period,
    AppColorTokens tokens,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s8,
      ),
      child: Column(
        children: [
          _CostRatioCard(
            data: data,
            period: period,
            locale: locale,
            formatStyle: formatStyle,
            tokens: tokens,
          ),
          const SizedBox(height: AppSpacing.s16),
          _MarginRankCard(
            data: data,
            locale: locale,
            formatStyle: formatStyle,
            tokens: tokens,
          ),
          const SizedBox(height: AppSpacing.s16),
          _ExpensiveIngrCard(
            data: data,
            locale: locale,
            formatStyle: formatStyle,
            tokens: tokens,
          ),
          const SizedBox(height: AppSpacing.s32),
        ],
      ),
    );
  }

  Widget _buildEmptyInitial(AppColorTokens tokens) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s40),
        child: Text(
          AppStrings.getEmptyReportPrompt(locale),
          style: AppTypography.body2.copyWith(color: tokens.fgTertiary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    String message,
    AppColorTokens tokens,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s40),
        child: Column(
          children: [
            Text(
              message.isNotEmpty
                  ? message
                  : AppStrings.getEmptyReportPrompt(locale),
              style: AppTypography.body2.copyWith(color: tokens.fgTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),
            TextButton(
              onPressed: () => context.read<ReportCubit>().refresh(),
              child: Text(
                AppStrings.getRetry(locale),
                style: TextStyle(color: tokens.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card Shell
// ---------------------------------------------------------------------------

class _ReportCard extends StatelessWidget {
  final Widget child;

  const _ReportCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.bgBase,
        borderRadius: AppRadius.brR16,
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// 원가율 시계열 카드
// ---------------------------------------------------------------------------

class _CostRatioCard extends StatelessWidget {
  final ReportData data;
  final ReportPeriod period;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final AppColorTokens tokens;

  const _CostRatioCard({
    required this.data,
    required this.period,
    required this.locale,
    required this.formatStyle,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = data.costRatioSeries.any((p) => p.avgCostRatio != null);

    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(title: AppStrings.getAvgCostRatio(locale), tokens: tokens),
          const SizedBox(height: AppSpacing.s12),
          if (!hasData)
            _EmptyState(
              message:
                  data.hasHistory
                      ? AppStrings.getEmptyReportPrompt(locale)
                      : AppStrings.getEmptyHistoryPrompt(locale),
              tokens: tokens,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${data.avgCostRatio.toStringAsFixed(1)}%',
                      style: AppTypography.display3.copyWith(
                        color: tokens.fgStrong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    if (data.avgCostRatio <= 40)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: AppSpacing.s2,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.positiveSoft,
                          borderRadius: AppRadius.brR8,
                        ),
                        child: Text(
                          AppStrings.getGoalAchieved(locale, 40),
                          style: AppTypography.caption1.copyWith(
                            color: tokens.positive,
                          ),
                        ),
                      ),
                  ],
                ),
                if (data.deltaVsPrevPct != null) ...[
                  const SizedBox(height: AppSpacing.s4),
                  _DeltaBadge(
                    delta: data.deltaVsPrevPct!,
                    periodLabel: _periodLabel(),
                    tokens: tokens,
                    locale: locale,
                  ),
                ],
                const SizedBox(height: AppSpacing.s16),
                SizedBox(
                  height: 120,
                  child: _CostRatioLineChart(
                    series: data.costRatioSeries,
                    tokens: tokens,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  ReportPeriodLabel _periodLabel() {
    switch (period) {
      case ReportPeriod.weekly:
        return ReportPeriodLabel.weekly;
      case ReportPeriod.monthly:
        return ReportPeriodLabel.monthly;
      case ReportPeriod.quarterly:
        return ReportPeriodLabel.quarterly;
    }
  }
}

class _DeltaBadge extends StatelessWidget {
  final double delta;
  final ReportPeriodLabel periodLabel;
  final AppColorTokens tokens;
  final AppLocale locale;

  const _DeltaBadge({
    required this.delta,
    required this.periodLabel,
    required this.tokens,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    // 원가율: 낮을수록 좋음. delta 감소 = green
    final isGood = delta <= 0;
    final color = isGood ? tokens.positive : tokens.negative;
    final arrow = isGood ? '▼' : '▲';
    final absStr = delta.abs().toStringAsFixed(1);

    return Row(
      children: [
        Text(
          '$arrow ${absStr}pp',
          style: AppTypography.label2.copyWith(color: color),
        ),
        const SizedBox(width: AppSpacing.s4),
        Text(
          AppStrings.getDeltaVsPrevPeriod(locale, periodLabel),
          style: AppTypography.caption2.copyWith(color: tokens.fgTertiary),
        ),
      ],
    );
  }
}

class _CostRatioLineChart extends StatelessWidget {
  final List<CostRatioPoint> series;
  final AppColorTokens tokens;

  const _CostRatioLineChart({required this.series, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (int i = 0; i < series.length; i++) {
      final val = series[i].avgCostRatio;
      if (val != null) {
        spots.add(FlSpot(i.toDouble(), val));
      }
    }

    if (spots.isEmpty) {
      return const SizedBox.shrink();
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.1;

    final lineColors = [
      ReportCubit.palette[0],
      ReportCubit.palette[4],
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        minY: minY < 0 ? 0 : minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: lineColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: lineColors[0],
                strokeWidth: 2,
                strokeColor: tokens.bgBase,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColors[0].withValues(alpha: 0.25),
                  lineColors[0].withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 마진율 순위 카드
// ---------------------------------------------------------------------------

class _MarginRankCard extends StatelessWidget {
  final ReportData data;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final AppColorTokens tokens;

  const _MarginRankCard({
    required this.data,
    required this.locale,
    required this.formatStyle,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final top5 = data.marginRanking.take(5).toList();

    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CardTitle(
                title: AppStrings.getMarginRanking(locale),
                tokens: tokens,
              ),
              if (data.marginRanking.length > 5)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _showFullSheet(context),
                  child: Text(
                    AppStrings.getViewAll(locale),
                    style: AppTypography.label2.copyWith(color: tokens.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          if (top5.isEmpty)
            _EmptyState(
              message: AppStrings.getEmptyReportPrompt(locale),
              tokens: tokens,
            )
          else
            Column(
              children:
                  top5
                      .asMap()
                      .entries
                      .map(
                        (e) => _MarginRankRow(
                          rank: e.key + 1,
                          item: e.value,
                          locale: locale,
                          formatStyle: formatStyle,
                          tokens: tokens,
                        ),
                      )
                      .toList(),
            ),
        ],
      ),
    );
  }

  void _showFullSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: tokens.bgBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r16),
        ),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            expand: false,
            builder:
                (_, controller) => ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: tokens.borderSubtle,
                          borderRadius: AppRadius.brPill,
                        ),
                      ),
                    ),
                    Text(
                      AppStrings.getMarginRanking(locale),
                      style: AppTypography.heading1.copyWith(
                        color: tokens.fgStrong,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    ...data.marginRanking.asMap().entries.map(
                      (e) => _MarginRankRow(
                        rank: e.key + 1,
                        item: e.value,
                        locale: locale,
                        formatStyle: formatStyle,
                        tokens: tokens,
                      ),
                    ),
                  ],
                ),
          ),
    );
  }
}

class _MarginRankRow extends StatelessWidget {
  final int rank;
  final MarginRankItem item;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final AppColorTokens tokens;

  const _MarginRankRow({
    required this.rank,
    required this.item,
    required this.locale,
    required this.formatStyle,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final marginColor = RecipeMargin.color(item.marginPct, tokens);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: AppTypography.caption1.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.recipe.name,
                  style: AppTypography.label1.copyWith(color: tokens.fgStrong),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${NumberFormatter.formatCurrency(item.cost, locale, formatStyle)} → ${NumberFormatter.formatCurrency(item.sellPrice, locale, formatStyle)}',
                  style: AppTypography.caption1.copyWith(
                    color: tokens.fgTertiary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.marginPct.toStringAsFixed(1)}%',
            style: AppTypography.label1.copyWith(
              color: marginColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 비싼 재료 TOP 5 카드
// ---------------------------------------------------------------------------

class _ExpensiveIngrCard extends StatelessWidget {
  final ReportData data;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final AppColorTokens tokens;

  const _ExpensiveIngrCard({
    required this.data,
    required this.locale,
    required this.formatStyle,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return _ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            title: AppStrings.getExpensiveIngredientsTop5(locale),
            subtitle: AppStrings.getUnitPriceBasis(locale),
            tokens: tokens,
          ),
          const SizedBox(height: AppSpacing.s12),
          if (data.expensiveIngredients.isEmpty)
            _EmptyState(
              message: AppStrings.getEmptyReportPrompt(locale),
              tokens: tokens,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final maxPrice = data.expensiveIngredients
                    .map((e) => e.unitPrice)
                    .reduce((a, b) => a > b ? a : b);
                return Column(
                  children: [
                    for (var i = 0;
                        i < data.expensiveIngredients.length;
                        i++)
                      _ExpensiveIngrRow(
                        item: data.expensiveIngredients[i],
                        maxPrice: maxPrice,
                        fullWidth: constraints.maxWidth,
                        barColor:
                            ReportCubit.palette[i % ReportCubit.palette.length],
                        locale: locale,
                        formatStyle: formatStyle,
                        tokens: tokens,
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ExpensiveIngrRow extends StatelessWidget {
  final ExpensiveIngredientItem item;
  final double maxPrice;
  final double fullWidth;
  final Color barColor;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final AppColorTokens tokens;

  const _ExpensiveIngrRow({
    required this.item,
    required this.maxPrice,
    required this.fullWidth,
    required this.barColor,
    required this.locale,
    required this.formatStyle,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final ratio =
        maxPrice > 0 ? (item.unitPrice / maxPrice).clamp(0.0, 1.0) : 0.0;
    final priceText = NumberFormatter.formatCurrency(
      item.unitPrice,
      locale,
      formatStyle,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.ingredient.name,
                  style: AppTypography.label2.copyWith(color: tokens.fgDefault),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$priceText / ${item.unitDisplay}',
                style: AppTypography.label2.copyWith(color: tokens.fgStrong),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          ClipRRect(
            borderRadius: AppRadius.brPill,
            child: Container(
              height: 6,
              width: fullWidth * ratio,
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _CardTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final AppColorTokens tokens;

  const _CardTitle({required this.title, this.subtitle, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.s2),
          Text(
            subtitle!,
            style: AppTypography.caption1.copyWith(color: tokens.fgTertiary),
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final AppColorTokens tokens;

  const _EmptyState({required this.message, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s24),
      child: Center(
        child: Text(
          message,
          style: AppTypography.body2.copyWith(color: tokens.fgTertiary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
