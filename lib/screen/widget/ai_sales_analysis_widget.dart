import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';

/// AI 판매 분석 결과를 보여주는 위젯
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          _buildHeader(context),
          const SizedBox(height: 20),

          // 최적 가격 분석
          _buildOptimalPriceSection(context),
          const SizedBox(height: 20),

          // 마케팅 포인트
          _buildMarketingPointsSection(context),
          const SizedBox(height: 20),

          // 서빙 가이드
          _buildServingGuidanceSection(context),
          const SizedBox(height: 20),

          // 비즈니스 인사이트
          _buildBusinessInsightsSection(context),

          const SizedBox(height: 20),

          // 닫기 버튼
          if (onClose != null)
            Center(
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(AppStrings.getClose(currentLocale)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.analytics, color: colorScheme.secondary, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppStrings.getAiSalesAnalysisTitle(locale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (onClose != null)
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
      ],
    );
  }

  Widget _buildOptimalPriceSection(BuildContext context) {
    final optimalPrice =
        analysisResult['optimal_price'] as Map<String, dynamic>?;
    if (optimalPrice == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return _buildSection(
      context,
      title: AppStrings.getOptimalPriceAnalysis(locale),
      icon: Icons.attach_money,
      children: [
        _buildInfoRow(
          context,
          AppStrings.getRecommendedPrice(locale),
          _formatPrice(optimalPrice['recommended_price'], context),
        ),
        _buildInfoRow(
          context,
          AppStrings.getTargetMarginRate(locale),
          '${optimalPrice['cost_ratio']}%',
        ),
        _buildInfoRow(
          context,
          AppStrings.getProfitPerServing(locale),
          _formatPrice(optimalPrice['profit_per_serving'], context),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _formatAnalysisText(optimalPrice['price_analysis'] ?? '-', context),
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketingPointsSection(BuildContext context) {
    final marketingPoints =
        analysisResult['marketing_points'] as Map<String, dynamic>?;
    if (marketingPoints == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return _buildSection(
      context,
      title: AppStrings.getMarketingPoints(locale),
      icon: Icons.campaign,
      children: [
        _buildInfoRow(
          context,
          AppStrings.getTargetCustomers(locale),
          marketingPoints['target_customers'] ?? '',
        ),
        _buildInfoRow(
          context,
          AppStrings.getOptimalSellingSeason(locale),
          marketingPoints['seasonal_timing'] ?? '',
        ),
        const SizedBox(height: 8),

        // 고유한 판매 포인트
        if (marketingPoints['unique_selling_points'] != null) ...[
          Text(
            AppStrings.getUniqueSellingPoints(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          ...(marketingPoints['unique_selling_points'] as List<dynamic>).map(
            (point) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: colorScheme.secondary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 8),

        // 경쟁 우위
        if (marketingPoints['competitive_advantages'] != null) ...[
          Text(
            AppStrings.getCompetitiveAdvantages(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          ...(marketingPoints['competitive_advantages'] as List<dynamic>).map(
            (advantage) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.star, color: colorScheme.secondary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advantage.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServingGuidanceSection(BuildContext context) {
    final servingGuidance =
        analysisResult['serving_guidance'] as Map<String, dynamic>?;
    if (servingGuidance == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return _buildSection(
      context,
      title: AppStrings.getServingGuidance(locale),
      icon: Icons.restaurant,
      children: [
        _buildInfoRow(
          context,
          AppStrings.getOpeningScript(locale),
          servingGuidance['opening_script'] ?? '',
        ),
        _buildInfoRow(
          context,
          AppStrings.getRecipeDescriptionScript(locale),
          servingGuidance['description_script'] ?? '',
        ),
        _buildInfoRow(
          context,
          AppStrings.getPriceJustification(locale),
          servingGuidance['price_justification'] ?? '',
        ),

        const SizedBox(height: 8),

        // 추가 판매 팁
        if (servingGuidance['upselling_tips'] != null) ...[
          Text(
            AppStrings.getUpsellingTips(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          ...(servingGuidance['upselling_tips'] as List<dynamic>).map(
            (tip) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: colorScheme.secondary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBusinessInsightsSection(BuildContext context) {
    final businessInsights =
        analysisResult['business_insights'] as Map<String, dynamic>?;
    if (businessInsights == null) return const SizedBox.shrink();

    return _buildSection(
      context,
      title: AppStrings.getBusinessInsights(locale),
      icon: Icons.business,
      children: [
        _buildInfoRow(
          context,
          AppStrings.getCostEfficiency(locale),
          businessInsights['cost_efficiency'] ?? '',
        ),
        _buildInfoRow(
          context,
          AppStrings.getProfitabilityTips(locale),
          businessInsights['profitability_tips'] ?? '',
        ),
        _buildInfoRow(
          context,
          AppStrings.getRiskFactors(locale),
          businessInsights['risk_factors'] ?? '',
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.secondary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, dynamic value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildValueWidget(context, value)),
        ],
      ),
    );
  }

  /// 값의 타입에 따라 적절한 위젯을 반환하는 헬퍼 메서드
  Widget _buildValueWidget(BuildContext context, dynamic value) {
    final colorScheme = Theme.of(context).colorScheme;
    if (value == null) {
      return Text(
        '-',
        style: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (value is String) {
      if (value.isEmpty) {
        return Text(
          '-',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontStyle: FontStyle.italic,
          ),
        );
      }
      return Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
      );
    }

    if (value is List) {
      if (value.isEmpty) {
        return Text(
          '-',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontStyle: FontStyle.italic,
          ),
        );
      }
      // 리스트의 첫 번째 항목만 표시하고 "외 N개" 형태로 표시
      try {
        final firstItem = value.first?.toString() ?? '';
        final remainingCount = value.length - 1;
        if (remainingCount > 0) {
          return Text(
            '$firstItem 외 $remainingCount개',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          );
        }
        return Text(
          firstItem,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        );
      } catch (e) {
        // 리스트 처리 중 오류 발생 시 안전하게 처리
        return Text(
          '${value.length}개 항목',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        );
      }
    }

    // 기타 타입은 문자열로 변환
    return Text(
      value.toString(),
      style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
    );
  }

  /// 가격 포맷팅 (AI 전용 포맷터 사용)
  String _formatPrice(dynamic value, BuildContext context) {
    return NumberFormatter.formatAiPrice(
        value, locale, context.watch<NumberFormatCubit>().state);
  }

  /// AI 분석 결과 텍스트에서 숫자 포맷팅 개선
  String _formatAnalysisText(dynamic text, BuildContext context) {
    if (text == null) return '';

    final textStr = text.toString();
    if (textStr.isEmpty) return textStr;

    // 텍스트에서 숫자 패턴을 찾아서 천 단위 구분자 추가
    return textStr.replaceAllMapped(RegExp(r'\b(\d{1,3}(,\d{3})*|\d+)\b'), (
      match,
    ) {
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
