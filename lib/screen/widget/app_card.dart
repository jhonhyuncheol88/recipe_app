import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../util/number_formatter.dart';
import '../../util/app_locale.dart';
import '../../util/app_strings.dart';
import '../../../router/router_helper.dart';
import '../../model/recipe.dart';

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
        color: backgroundColor ?? AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: elevation ?? 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                NumberFormatter.formatCurrency(price, AppLocale.korea),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${NumberFormatter.formatNumber(amount.toInt(), AppLocale.korea)} $unit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (unitPrice != null) ...[
            const SizedBox(height: 4),
            Text(
              '${NumberFormatter.formatCurrency(unitPrice!, AppLocale.korea)}/$unit',
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
            '유통기한 없음',
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
      statusText = '만료됨';
    } else if (daysUntilExpiry <= 3) {
      statusColor = AppColors.expiryDanger;
      statusText = '위험';
    } else if (daysUntilExpiry <= 7) {
      statusColor = AppColors.expiryWarning;
      statusText = '경고';
    } else {
      statusColor = AppColors.expiryNormal;
      statusText = '정상';
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
          '유통기한: ${expiryDate!.year}-${expiryDate!.month.toString().padLeft(2, '0')}-${expiryDate!.day.toString().padLeft(2, '0')} ($statusText)',
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
    this.recipe, // Recipe 객체 선택적 매개변수
    required this.locale, // 로컬화 지원 필수 매개변수
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      isClickable: true,
      backgroundColor: isSelected ? AppColors.primaryLight : null,
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

          // AI 분석 버튼
          if (onAiAnalysis != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAiAnalysis,
                icon: const Icon(Icons.analytics, size: 20),
                label: Text(
                  AppStrings.getAnalyzeWithAi(locale),
                  style: AppTextStyles.buttonMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
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
                      '$ingredientCount개',
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
                      '${NumberFormatter.formatNumber(totalWeight.toInt(), AppLocale.korea)} $weightUnit',
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
                    Text(
                      NumberFormatter.formatCurrency(
                        totalCost,
                        AppLocale.korea,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
