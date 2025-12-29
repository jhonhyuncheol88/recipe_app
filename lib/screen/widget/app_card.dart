import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../util/number_formatter.dart';
import '../../util/app_locale.dart';
import '../../util/app_strings.dart';
import '../../model/recipe.dart';
import '../../controller/setting/number_format_cubit.dart';

/// 앱에서 사용하는 공통 카드 위젯
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isClickable;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardWidget = Container(
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface, // 흰색 카드 배경
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider, // 카드 테두리 추가 (배경과 구분)
          width: 1,
        ),
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: elevation!,
                  offset: const Offset(0, 1), // Flat 디자인: 최소 그림자
                ),
              ]
            : null, // Flat 디자인: elevation이 0이면 그림자 없음
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (isClickable || onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// 재료 카드 위젯
class IngredientCard extends StatelessWidget {
  final String name;
  final double price;
  final double amount;
  final String unit;
  final double? unitPrice; // 단위당 가격 추가
  final DateTime? expiryDate;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final AppLocale locale; // 로컬화 지원 추가

  const IngredientCard({
    super.key,
    required this.name,
    required this.price,
    required this.amount,
    required this.unit,
    this.unitPrice, // 단위당 가격 매개변수 추가
    this.expiryDate,
    this.onTap,
    this.onEdit,
    this.onDelete,
    required this.locale, // 로컬화 지원 필수 매개변수
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      isClickable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 20),
                  color: AppColors.textSecondary,
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppColors.error,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                NumberFormatter.formatCurrency(
                  price,
                  locale,
                  context.watch<NumberFormatCubit>().state,
                ),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '${NumberFormatter.formatNumber(amount.toInt(), context.watch<NumberFormatCubit>().state)} $unit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          if (unitPrice != null) ...[
            const SizedBox(height: 4),
            Text(
              '${NumberFormatter.formatCurrency(unitPrice!, locale, context.watch<NumberFormatCubit>().state)}/$unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
          if (expiryDate != null) ...[
            const SizedBox(height: 8),
            _buildExpiryDate(context),
          ],
        ],
      ),
    );
  }

  Widget _buildExpiryDate(BuildContext context) {
    if (expiryDate == null) {
      // 유통기한이 없는 경우
      return Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.textLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.getNoExpiryDate(locale),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      );
    }

    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;

    Color statusColor;
    String statusText;

    if (daysUntilExpiry < 0) {
      statusColor = AppColors.expiryExpired;
      statusText = AppStrings.getExpired(locale);
    } else if (daysUntilExpiry <= 3) {
      statusColor = AppColors.expiryDanger;
      statusText = AppStrings.getDanger(locale);
    } else if (daysUntilExpiry <= 7) {
      statusColor = AppColors.expiryWarning;
      statusText = AppStrings.getWarning(locale);
    } else {
      statusColor = AppColors.expiryNormal;
      statusText = AppStrings.getNormal(locale);
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '${AppStrings.getExpiryDate(locale)}: ${expiryDate!.year}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')} ($statusText)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

/// 레시피 카드 위젯
class RecipeCard extends StatelessWidget {
  final String name;
  final String description;
  final double totalCost;
  final int ingredientCount;
  final double totalWeight;
  final String weightUnit;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onLongPress;
  final VoidCallback? onAiAnalysis; // AI 분석 콜백 추가
  final VoidCallback? onViewQuick; // 레시피 바로보기 콜백 추가
  final VoidCallback? onPriceChart; // 가격 차트 콜백 추가
  final VoidCallback? onShare; // 공유 콜백 추가
  final Recipe? recipe; // 실제 Recipe 객체 추가
  final AppLocale locale; // 로컬화 지원 추가

  const RecipeCard({
    super.key,
    required this.name,
    required this.description,
    required this.totalCost,
    required this.ingredientCount,
    required this.totalWeight,
    required this.weightUnit,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onLongPress,
    this.onAiAnalysis, // AI 분석 콜백 선택적 매개변수
    this.onViewQuick, // 레시피 바로보기 콜백 선택적 매개변수
    this.onPriceChart, // 가격 차트 콜백 선택적 매개변수
    this.onShare, // 공유 콜백 선택적 매개변수
    this.recipe, // Recipe 객체 선택적 매개변수
    required this.locale, // 로컬화 지원 필수 매개변수
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      isClickable: true,
      backgroundColor: isSelected
          ? AppColors.primaryLight.withAlpha(51)
          : AppColors.surface, // 흰색 카드 배경
      elevation: 0, // Flat 디자인
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              // AI 분석 버튼 (작은 텍스트 버튼, 오렌지색)
              if (onAiAnalysis != null)
                TextButton.icon(
                  onPressed: onAiAnalysis,
                  icon: const Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: AppColors.accent,
                  ),
                  label: Text(
                    AppStrings.getAnalyzeWithAi(locale),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              if (onPriceChart != null)
                IconButton(
                  icon: const Icon(
                    Icons.show_chart,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onPriceChart,
                  tooltip: AppStrings.getPriceChart(locale),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text(AppStrings.getEdit(locale)),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 16,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 8),
                            Text(
                              AppStrings.getDelete(locale),
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.getIngredientCountSimple(locale),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormatter.formatQuantity(ingredientCount, locale, context.watch<NumberFormatCubit>().state)} ${AppStrings.getUnitPiece(locale)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.getTotalWeight(locale),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormatter.formatNumber(totalWeight.toInt(), context.watch<NumberFormatCubit>().state)} $weightUnit',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.getTotalCost(locale),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        NumberFormatter.formatCurrency(
                          totalCost,
                          locale,
                          context.watch<NumberFormatCubit>().state,
                        ),
                        style: AppTextStyles.costEmphasized, // 크고 굵은 오렌지색
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 레시피 바로보기 버튼
          if (onViewQuick != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onViewQuick,
                icon: const Icon(Icons.visibility, size: 20),
                label: Text(
                  AppStrings.getViewRecipeQuick(locale),
                  style: AppTextStyles.buttonMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
