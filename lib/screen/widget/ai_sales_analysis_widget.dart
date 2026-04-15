import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';

/// AI 판매 분석 결과를 섹션 카드별로 보여주는 위젯
class AiSalesAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> analysisResult;
  final VoidCallback? onClose;
  final AppLocale locale;

  const AiSalesAnalysisWidget({
    super.key,
    required this.analysisResult,
    required this.locale,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOptimalPriceCard(context),
        const SizedBox(height: 12),
        _buildMarketingPointsCard(context),
        const SizedBox(height: 12),
        _buildServingGuidanceCard(context),
        const SizedBox(height: 12),
        _buildBusinessInsightsCard(context),
        if (onClose != null) ...[
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(AppStrings.getClose(currentLocale)),
            ),
          ),
        ],
      ],
    );
  }

  // ───────────────────────── 최적 가격 분석 ─────────────────────────

  Widget _buildOptimalPriceCard(BuildContext context) {
    final optimalPrice = analysisResult['optimal_price'] as Map<String, dynamic>?;
    if (optimalPrice == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      icon: Icons.attach_money,
      accentColor: colorScheme.primary,
      title: AppStrings.getOptimalPriceAnalysis(locale),
      children: [
        // 핵심 수치 3개를 가로 카드로
        Row(
          children: [
            _metricTile(
              context,
              label: AppStrings.getRecommendedPrice(locale),
              value: _formatPrice(optimalPrice['recommended_price'], context),
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            _metricTile(
              context,
              label: AppStrings.getTargetMarginRate(locale),
              value: '${optimalPrice['cost_ratio'] ?? '-'}%',
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            _metricTile(
              context,
              label: AppStrings.getProfitPerServing(locale),
              value: _formatPrice(optimalPrice['profit_per_serving'], context),
              color: colorScheme.secondary,
            ),
          ],
        ),
        if (optimalPrice['price_analysis'] != null) ...[
          const SizedBox(height: 12),
          _analysisTextBox(
            context,
            _formatAnalysisText(optimalPrice['price_analysis'], context),
          ),
        ],
      ],
    );
  }

  // ───────────────────────── 마케팅 포인트 ─────────────────────────

  Widget _buildMarketingPointsCard(BuildContext context) {
    final mp = analysisResult['marketing_points'] as Map<String, dynamic>?;
    if (mp == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      icon: Icons.campaign,
      accentColor: Colors.orange,
      title: AppStrings.getMarketingPoints(locale),
      children: [
        _infoItem(context,
            label: AppStrings.getTargetCustomers(locale),
            value: mp['target_customers'] ?? '-'),
        _infoItem(context,
            label: AppStrings.getOptimalSellingSeason(locale),
            value: mp['seasonal_timing'] ?? '-'),
        if (mp['unique_selling_points'] != null) ...[
          const SizedBox(height: 8),
          _bulletList(
            context,
            title: AppStrings.getUniqueSellingPoints(locale),
            icon: Icons.check_circle,
            color: colorScheme.secondary,
            items: List<String>.from(mp['unique_selling_points'] as List),
          ),
        ],
        if (mp['competitive_advantages'] != null) ...[
          const SizedBox(height: 8),
          _bulletList(
            context,
            title: AppStrings.getCompetitiveAdvantages(locale),
            icon: Icons.star,
            color: Colors.amber.shade600,
            items: List<String>.from(mp['competitive_advantages'] as List),
          ),
        ],
      ],
    );
  }

  // ───────────────────────── 서빙 가이드 ─────────────────────────

  Widget _buildServingGuidanceCard(BuildContext context) {
    final sg = analysisResult['serving_guidance'] as Map<String, dynamic>?;
    if (sg == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return _SectionCard(
      icon: Icons.restaurant,
      accentColor: colorScheme.tertiary,
      title: AppStrings.getServingGuidance(locale),
      children: [
        _infoItem(context,
            label: AppStrings.getOpeningScript(locale),
            value: sg['opening_script'] ?? '-'),
        _infoItem(context,
            label: AppStrings.getRecipeDescriptionScript(locale),
            value: sg['description_script'] ?? '-'),
        _infoItem(context,
            label: AppStrings.getPriceJustification(locale),
            value: sg['price_justification'] ?? '-'),
        if (sg['upselling_tips'] != null) ...[
          const SizedBox(height: 8),
          _bulletList(
            context,
            title: AppStrings.getUpsellingTips(locale),
            icon: Icons.lightbulb,
            color: Colors.amber.shade600,
            items: List<String>.from(sg['upselling_tips'] as List),
          ),
        ],
      ],
    );
  }

  // ───────────────────────── 비즈니스 인사이트 ─────────────────────────

  Widget _buildBusinessInsightsCard(BuildContext context) {
    final bi = analysisResult['business_insights'] as Map<String, dynamic>?;
    if (bi == null) return const SizedBox.shrink();

    return _SectionCard(
      icon: Icons.business,
      accentColor: Colors.indigo,
      title: AppStrings.getBusinessInsights(locale),
      children: [
        _infoItem(context,
            label: AppStrings.getCostEfficiency(locale),
            value: bi['cost_efficiency'] ?? '-'),
        _infoItem(context,
            label: AppStrings.getProfitabilityTips(locale),
            value: bi['profitability_tips'] ?? '-'),
        _infoItem(context,
            label: AppStrings.getRiskFactors(locale),
            value: bi['risk_factors'] ?? '-'),
      ],
    );
  }

  // ───────────────────────── 공통 헬퍼 위젯 ─────────────────────────

  /// 수치 하이라이트 타일 (3개 나란히)
  Widget _metricTile(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// 라벨 + 값 세로 배치 항목
  Widget _infoItem(
    BuildContext context, {
    required String label,
    required dynamic value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueStr = value?.toString() ?? '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valueStr.isEmpty ? '-' : valueStr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// 불릿 리스트 (제목 + 아이콘 항목들)
  Widget _bulletList(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 분석 텍스트 박스
  Widget _analysisTextBox(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: colorScheme.onSurface),
      ),
    );
  }

  String _formatPrice(dynamic value, BuildContext context) {
    return NumberFormatter.formatAiPrice(
        value, locale, context.watch<NumberFormatCubit>().state);
  }

  String _formatAnalysisText(dynamic text, BuildContext context) {
    if (text == null) return '';
    final textStr = text.toString();
    if (textStr.isEmpty) return textStr;
    return textStr.replaceAllMapped(RegExp(r'\b(\d{1,3}(,\d{3})*|\d+)\b'),
        (match) {
      final numberStr = match.group(0)?.replaceAll(',', '') ?? '';
      final number = int.tryParse(numberStr);
      if (number != null) {
        return NumberFormatter.formatNumber(
            number, context.watch<NumberFormatCubit>().state);
      }
      return match.group(0) ?? '';
    });
  }
}

// ───────────────────────── 섹션 카드 ─────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.07),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // 콘텐츠
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
