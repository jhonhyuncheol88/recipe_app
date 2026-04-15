import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                Icon(Icons.restaurant,
                    color: Theme.of(context).colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.recipe.name,
                    style: AppTextStyles.headline4.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 가격 표시
            _buildPriceSection(),
            const SizedBox(height: 24),

            // 원가 비중 파이 차트
            _buildCostPieChart(),

            // 레시피 메모
            _buildMemoSection(),
            const SizedBox(height: 24),

            // 배수 조정
            _buildMultiplierSection(),
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
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: content,
      );
    }

    return content;
  }

  /// 배수 조정 섹션
  Widget _buildMultiplierSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getMultiplier(widget.locale),
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getMultiplierDescription(widget.locale),
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getMultiplierRange(widget.locale),
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                activeColor: colorScheme.primary,
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
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.5)),
              ),
              child: Text(
                '${_multiplier.toStringAsFixed(0)}${_getMultiplierUnit()}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
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

  /// 재료 수에 따라 파스텔 톤 색상 생성
  List<Color> _generatePastelColors(int count) {
    if (count == 0) return [];
    // 재료 수 * 37도 오프셋으로 재료 수마다 다른 색상 팔레트
    final hueOffset = (count * 37) % 360;
    return List.generate(count, (i) {
      final hue = (hueOffset + (360.0 / count) * i) % 360;
      return HSLColor.fromAHSL(1.0, hue, 0.52, 0.78).toColor();
    });
  }

  String _getCostChartTitle() {
    switch (widget.locale.languageCode) {
      case 'ko':
        return '원가 비중';
      case 'ja':
        return '原価比率';
      case 'zh':
        return '成本比例';
      default:
        return 'Cost Breakdown';
    }
  }

  /// 원가 비중 파이 차트 섹션
  Widget _buildCostPieChart() {
    final validIngredients = widget.recipe.ingredients
        .where((ing) => ing.calculatedCost > 0)
        .toList();

    if (validIngredients.isEmpty) return const SizedBox.shrink();

    final totalCost =
        validIngredients.fold(0.0, (sum, ing) => sum + ing.calculatedCost);
    if (totalCost <= 0) return const SizedBox.shrink();

    final colors = _generatePastelColors(validIngredients.length);
    final colorScheme = Theme.of(context).colorScheme;

    final sections = validIngredients.asMap().entries.map((entry) {
      final idx = entry.key;
      final ingredient = entry.value;
      final percentage = ingredient.calculatedCost / totalCost * 100;
      final name = _ingredientNames[ingredient.ingredientId] ??
          ingredient.ingredientId;
      // 섹션 안에 표시할 재료명 (5자 초과 시 줄임)
      final shortName = name.length > 5 ? '${name.substring(0, 4)}…' : name;

      return PieChartSectionData(
        color: colors[idx],
        value: ingredient.calculatedCost * _multiplier,
        // 섹션 내부: 재료명
        title: shortName,
        titleStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 3)],
        ),
        titlePositionPercentageOffset: 0.6,
        radius: 70,
        // 섹션 외곽: 퍼센테이지 뱃지
        badgeWidget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: colors[idx],
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        badgePositionPercentageOffset: 1.45,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getCostChartTitle(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        // 차트: 전체 너비 사용, 높이 확대 (퍼센테이지 뱃지 공간 확보)
        SizedBox(
          height: 260,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 32,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 가격 표시 섹션
  Widget _buildPriceSection() {
    final totalPrice = widget.recipe.totalCost * _multiplier;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getTotalCost(widget.locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                    color: colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_multiplier.toStringAsFixed(_multiplier % 1 == 0 ? 0 : 1)}${_getMultiplierUnit()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.secondary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getRecipeMemo(widget.locale),
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
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
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            widget.recipe.description.isNotEmpty
                ? widget.recipe.description
                : AppStrings.getNoMemo(widget.locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.recipe.description.isNotEmpty
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.6),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getIngredientsAndAmounts(widget.locale),
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
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
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              AppStrings.getNoRecipeIngredients(widget.locale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...widget.recipe.ingredients.map((ingredient) {
            final adjustedAmount = ingredient.amount * _multiplier;
            final formattedAmount = adjustedAmount % 1 == 0
                ? adjustedAmount.toStringAsFixed(0)
                : adjustedAmount.toStringAsFixed(1);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _ingredientNames.containsKey(ingredient.ingredientId)
                        ? Text(
                            _ingredientNames[ingredient.ingredientId]!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface,
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
                                    colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ingredient.ingredientId,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5),
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
                      '$formattedAmount ${ingredient.unitId}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
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

    final colorScheme = Theme.of(context).colorScheme;

    // 바텀시트 내부에서는 부모 Scaffold의 context를 사용
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.getRecipeShareCopied(widget.locale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primaryContainer,
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
