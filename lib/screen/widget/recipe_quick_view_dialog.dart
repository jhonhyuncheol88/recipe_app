import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../util/app_strings.dart';
import '../../util/app_locale.dart';
import '../../util/number_formatter.dart';
import '../../controller/setting/number_format_cubit.dart';

import '../../model/recipe.dart';

import '../../data/ingredient_repository.dart';

/// 레시피 바로보기 다이얼로그
class RecipeQuickViewDialog extends StatelessWidget {
  final Recipe recipe;
  final AppLocale locale;

  const RecipeQuickViewDialog({
    super.key,
    required this.recipe,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: RecipeQuickViewContent(
          recipe: recipe,
          locale: locale,
          onClose: () => Navigator.of(context).pop(),
          isBottomSheet: false,
        ),
      ),
    );
  }
}

/// 다이얼로그/바텀시트 공용 콘텐츠
class RecipeQuickViewContent extends StatefulWidget {
  final Recipe recipe;
  final AppLocale locale;
  final VoidCallback onClose;
  final bool isBottomSheet;

  const RecipeQuickViewContent({
    super.key,
    required this.recipe,
    required this.locale,
    required this.onClose,
    this.isBottomSheet = false,
  });

  @override
  State<RecipeQuickViewContent> createState() => _RecipeQuickViewContentState();
}

class _RecipeQuickViewContentState extends State<RecipeQuickViewContent> {
  double _multiplier = 1.0;
  final IngredientRepository _ingredientRepository = IngredientRepository();
  final Map<String, String> _ingredientNames = {};

  @override
  void initState() {
    super.initState();
    _loadIngredientNames();
  }

  /// 재료 이름 로드
  Future<void> _loadIngredientNames() async {
    try {
      for (final recipeIngredient in widget.recipe.ingredients) {
        final ingredient = await _ingredientRepository.getIngredientById(
          recipeIngredient.ingredientId,
        );
        if (ingredient != null) {
          setState(() {
            _ingredientNames[recipeIngredient.ingredientId] = ingredient.name;
          });
        }
      }
    } catch (e) {
      print('재료 이름 로드 실패: $e');
    }
  }

  /// 배수 단위 반환
  String _getMultiplierUnit() {
    switch (widget.locale.languageCode) {
      case 'ko':
        return '배';
      case 'ja':
        return '倍';
      case 'zh':
        return '倍';
      default:
        return 'x';
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                Icon(Icons.restaurant, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.recipe.name,
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 배수 조정
            _buildMultiplierSection(),
            const SizedBox(height: 24),

            // 가격 표시
            _buildPriceSection(),
            const SizedBox(height: 24),

            // 레시피 메모
            _buildMemoSection(),
            const SizedBox(height: 24),

            // 재료 및 투입량
            _buildIngredientsSection(),
            const SizedBox(height: 24),

            // 공유 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _copyRecipeText,
                icon: const Icon(Icons.copy, size: 20),
                label: Text(
                  AppStrings.getShare(widget.locale),
                  style: AppTextStyles.buttonMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.getClose(widget.locale),
                  style: AppTextStyles.buttonMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.isBottomSheet) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: content,
      );
    }

    return content;
  }

  /// 배수 조정 섹션
  Widget _buildMultiplierSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getMultiplier(widget.locale),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getMultiplierDescription(widget.locale),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getMultiplierRange(widget.locale),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _multiplier,
                min: 1.0,
                max: 50.0,
                divisions: 49, // 1부터 50까지 정수 단위 (49개 구간 = 50개 값)
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _multiplier = value.roundToDouble(); // 정수로 반올림
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary),
              ),
              child: Text(
                '${_multiplier.toStringAsFixed(0)}${_getMultiplierUnit()}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w900, // w800 -> w900
                  fontSize: 18, // 16 -> 18
                  letterSpacing: 0.8, // 0.5 -> 0.8
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 가격 표시 섹션
  Widget _buildPriceSection() {
    final totalPrice = widget.recipe.totalCost * _multiplier;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(26), // withAlpha 사용 (약 10% 투명도)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.accent.withAlpha(77)), // withAlpha 사용 (약 30% 투명도)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getTotalCost(widget.locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    NumberFormatter.formatCurrency(totalPrice, widget.locale,
                        context.watch<NumberFormatCubit>().state),
                    style: AppTextStyles.costEmphasized, // 크고 굵은 오렌지색
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              if (_multiplier != 1.0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent
                        .withAlpha(51), // withAlpha 사용 (약 20% 투명도)
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_multiplier.toStringAsFixed(_multiplier % 1 == 0 ? 0 : 1)}${_getMultiplierUnit()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 메모 섹션
  Widget _buildMemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getRecipeMemo(widget.locale),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            widget.recipe.description.isNotEmpty
                ? widget.recipe.description
                : AppStrings.getNoMemo(widget.locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.recipe.description.isNotEmpty
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  /// 재료 및 투입량 섹션
  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getIngredientsAndAmounts(widget.locale),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        if (widget.recipe.ingredients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              AppStrings.getNoRecipeIngredients(widget.locale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...widget.recipe.ingredients.map((ingredient) {
            final adjustedAmount = ingredient.amount * _multiplier;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _ingredientNames.containsKey(ingredient.ingredientId)
                        ? Text(
                            _ingredientNames[ingredient.ingredientId]!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          )
                        : Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ingredient.ingredientId,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${adjustedAmount.toStringAsFixed(1)} ${ingredient.unitId}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w900, // w700 -> w900
                        fontSize: 16, // 14 -> 16
                        letterSpacing: 0.5, // 0.2 -> 0.5
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  /// 레시피 텍스트 복사
  Future<void> _copyRecipeText() async {
    final text = _buildRecipeShareText();
    await Clipboard.setData(ClipboardData(text: text));

    if (!mounted) return;

    // 바텀시트 내부에서는 부모 Scaffold의 context를 사용
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.getRecipeShareCopied(widget.locale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _buildRecipeShareText() {
    final buffer = StringBuffer();
    final multiplierUnit = _getMultiplierUnit();
    buffer.writeln(widget.recipe.name);
    buffer.writeln(
        '${_multiplier.toStringAsFixed(_multiplier % 1 == 0 ? 0 : 1)}$multiplierUnit');

    if (widget.recipe.description.isNotEmpty) {
      buffer.writeln(widget.recipe.description);
    }

    buffer.writeln('--- ${AppStrings.getIngredients(widget.locale)} ---');
    for (final ingredient in widget.recipe.ingredients) {
      final name = _ingredientNames[ingredient.ingredientId] ??
          '${AppStrings.getIngredients(widget.locale)} (${ingredient.ingredientId})';
      final amount = ingredient.amount * _multiplier;
      final amountText = amount % 1 == 0
          ? amount.toStringAsFixed(0)
          : amount.toStringAsFixed(2);
      buffer.writeln('- $name: $amountText ${ingredient.unitId}');
    }

    return buffer.toString().trim();
  }
}
