import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../model/recipe_ingredient.dart';
import '../../../model/recipe_sauce.dart';
import '../../../model/sauce.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import '../../../util/recipe_margin.dart';
import '../../widget/ingredient_picker_sheet.dart';
import '../../widget/sauce_picker_sheet.dart';

/// 레시피 등록 페이지 — screens.jsx 1361~ (RecipeNew) 디자인 1:1 이식.
class RecipeAddPage extends StatefulWidget {
  /// (옵션) 외부에서 미리 선택돼 들어온 재료 — 라우터 호환성 유지.
  final List<Ingredient>? selectedIngredients;

  /// (옵션) 외부에서 미리 선택돼 들어온 소스 — 라우터 호환성 유지.
  final List<Sauce>? selectedSauces;

  const RecipeAddPage({
    super.key,
    this.selectedIngredients,
    this.selectedSauces,
  });

  @override
  State<RecipeAddPage> createState() => _RecipeAddPageState();
}

class _IngredientLine {
  final Ingredient ingredient;
  final TextEditingController qtyController;

  _IngredientLine({required this.ingredient, required double initialQty})
      : qtyController = TextEditingController(text: _formatQty(initialQty));

  double get qty {
    final raw = qtyController.text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(raw) ?? 0;
  }

  /// 1g 당 가격 = 구매가 / 구매양 (디자인 단순 모델, 단위 변환 없음).
  double get pricePerInputUnit {
    if (ingredient.purchaseAmount <= 0) return 0;
    return ingredient.purchasePrice / ingredient.purchaseAmount;
  }

  double get lineCost => pricePerInputUnit * qty;

  void dispose() => qtyController.dispose();

  static String _formatQty(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }
}

class _SauceLine {
  final Sauce sauce;
  final TextEditingController qtyController;

  /// [initialQty] 는 g 단위 사용량. 기본값은 소스 전체 분량(=sauce.totalWeight).
  _SauceLine({required this.sauce, required double initialQty})
      : qtyController = TextEditingController(text: _formatQty(initialQty));

  /// 사용량(g).
  double get qty {
    final raw = qtyController.text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(raw) ?? 0;
  }

  /// 라인 원가 = (g당 단가) × (입력 g). sauce.unitCost == totalCost/totalWeight.
  double get lineCost => sauce.unitCost * qty;

  void dispose() => qtyController.dispose();

  static String _formatQty(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }
}

class _RecipeAddPageState extends State<RecipeAddPage> {
  final _nameController = TextEditingController();
  final _sellPriceController = TextEditingController();

  final List<_IngredientLine> _ingredients = [];
  final List<_SauceLine> _sauces = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 외부에서 들어온 초기 선택 재료/소스 반영 (라우터 호환).
    if (widget.selectedIngredients != null) {
      for (final ing in widget.selectedIngredients!) {
        _ingredients.add(_IngredientLine(ingredient: ing, initialQty: 100));
      }
    }
    if (widget.selectedSauces != null) {
      for (final s in widget.selectedSauces!) {
        _sauces.add(_SauceLine(
          sauce: s,
          initialQty: _defaultSauceQty(s),
        ));
      }
    }
    // qty 변경 시 원가 미리보기 갱신.
    for (final l in _ingredients) {
      l.qtyController.addListener(_onAnyQtyChanged);
    }
    for (final l in _sauces) {
      l.qtyController.addListener(_onAnyQtyChanged);
    }
    _sellPriceController.addListener(_onAnyQtyChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sellPriceController.dispose();
    for (final l in _ingredients) {
      l.dispose();
    }
    for (final l in _sauces) {
      l.dispose();
    }
    super.dispose();
  }

  void _onAnyQtyChanged() {
    if (mounted) setState(() {});
  }

  double get _totalCost {
    final ic =
        _ingredients.fold<double>(0, (sum, l) => sum + l.lineCost);
    final sc = _sauces.fold<double>(0, (sum, l) => sum + l.lineCost);
    return ic + sc;
  }

  double _parseSellPrice() {
    final raw =
        _sellPriceController.text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(raw) ?? 0;
  }

  Future<void> _pickIngredient() async {
    final picked = await showIngredientPickerSheet(
      context,
      excludeIds: _ingredients.map((l) => l.ingredient.id).toList(),
    );
    if (picked == null) return;
    final line = _IngredientLine(ingredient: picked, initialQty: 100);
    line.qtyController.addListener(_onAnyQtyChanged);
    setState(() => _ingredients.add(line));
  }

  Future<void> _pickSauce() async {
    final picked = await showSaucePickerSheet(
      context,
      excludeIds: _sauces.map((l) => l.sauce.id).toList(),
    );
    if (picked == null) return;
    final line = _SauceLine(
      sauce: picked,
      initialQty: _defaultSauceQty(picked),
    );
    line.qtyController.addListener(_onAnyQtyChanged);
    setState(() => _sauces.add(line));
  }

  /// 신규 소스 행의 기본 사용량(g). 소스 전체 분량(=totalWeight) 을 기본값으로
  /// 채워서 "소스 한 통을 그대로 쓴다" 가 자연스럽게 표현되게 한다. 0 이면 0.
  double _defaultSauceQty(Sauce s) {
    final w = s.totalWeight;
    if (w <= 0) return 0;
    return w.roundToDouble();
  }

  void _removeIngredient(int index) {
    setState(() {
      final line = _ingredients.removeAt(index);
      line.dispose();
    });
  }

  void _removeSauce(int index) {
    setState(() {
      final line = _sauces.removeAt(index);
      line.dispose();
    });
  }

  Future<void> _submit() async {
    final locale = context.read<LocaleCubit>().state;
    final tokens = AppColorTokens.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: tokens.negative,
          content: Text(AppStrings.getRecipeNameRequired(locale)),
        ),
      );
      return;
    }
    if (_ingredients.isEmpty && _sauces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: tokens.negative,
          content: Text(AppStrings.getAddIngredientOrSauce(locale)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final sellPrice = _parseSellPrice();
      final ingredients = _ingredients
          .map(
            (l) => RecipeIngredient(
              id: '',
              recipeId: '',
              ingredientId: l.ingredient.id,
              amount: l.qty,
              unitId: l.ingredient.purchaseUnitId,
              calculatedCost: 0,
            ),
          )
          .toList();
      final sauces = _sauces
          .map(
            (l) => RecipeSauce(
              id: '',
              recipeId: '',
              sauceId: l.sauce.id,
              amount: l.qty,
              // 소스 단위는 항상 g 기준으로 저장. 비용 계산은
              // sauce.totalCost / sauce.totalWeight(g) × amount(g) 으로 이루어짐.
              unitId: 'g',
            ),
          )
          .toList();

      await context.read<RecipeCubit>().addRecipe(
            name: name,
            description: '',
            outputAmount: 1,
            outputUnit: '인분',
            sellPrice: sellPrice,
            ingredients: ingredients,
            sauces: sauces,
          );

      if (!mounted) return;
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: tokens.negative,
          content: Text(AppStrings.getRecipeAddError(
              context.read<LocaleCubit>().state)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;

    return Scaffold(
      backgroundColor: tokens.bgElev2,
      appBar: AppBar(
        backgroundColor: tokens.bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: tokens.fgStrong),
        ),
        title: Text(
          AppStrings.getAddRecipe(locale),
          style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BasicInfoCard(
                      nameController: _nameController,
                      sellPriceController: _sellPriceController,
                      locale: locale,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _IngredientsCard(
                      lines: _ingredients,
                      locale: locale,
                      formatStyle: formatStyle,
                      onAdd: _pickIngredient,
                      onRemove: _removeIngredient,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _SaucesCard(
                      lines: _sauces,
                      locale: locale,
                      formatStyle: formatStyle,
                      onAdd: _pickSauce,
                      onRemove: _removeSauce,
                    ),
                    if (_ingredients.isNotEmpty || _sauces.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s12),
                      _CostPreviewCard(
                        cost: _totalCost,
                        sellPrice: _parseSellPrice(),
                        locale: locale,
                        formatStyle: formatStyle,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s24),
                  ],
                ),
              ),
            ),
            _BottomActionButton(
              label: AppStrings.getDoRegister(locale),
              isLoading: _isSaving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ Basic info card

class _BasicInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController sellPriceController;
  final AppLocale locale;

  const _BasicInfoCard({
    required this.nameController,
    required this.sellPriceController,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(text: AppStrings.getRecipeName(locale)),
          const SizedBox(height: AppSpacing.s8),
          _OutlinedTextField(
            controller: nameController,
            hint: AppStrings.getRecipeNameHint(locale),
          ),
          const SizedBox(height: AppSpacing.s16),
          _FieldLabel(text: AppStrings.getSellPrice(locale)),
          const SizedBox(height: AppSpacing.s8),
          _OutlinedTextField(
            controller: sellPriceController,
            hint: '0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            suffixText: NumberFormatter.getCurrencyName(locale),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ Section cards

class _IngredientsCard extends StatelessWidget {
  final List<_IngredientLine> lines;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final Future<void> Function() onAdd;
  final void Function(int index) onRemove;

  const _IngredientsCard({
    required this.lines,
    required this.locale,
    required this.formatStyle,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.bgBase,
        borderRadius: AppRadius.brR16,
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SectionHeader(
            label: AppStrings.getIngredients(locale),
            count: lines.length,
            onAdd: onAdd,
            locale: locale,
          ),
          for (int i = 0; i < lines.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i < lines.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: tokens.borderSubtle,
                          width: 1,
                        ),
                      )
                    : null,
              ),
              child: _IngredientRow(
                line: lines[i],
                locale: locale,
                formatStyle: formatStyle,
                onRemove: () => onRemove(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _SaucesCard extends StatelessWidget {
  final List<_SauceLine> lines;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final Future<void> Function() onAdd;
  final void Function(int index) onRemove;

  const _SaucesCard({
    required this.lines,
    required this.locale,
    required this.formatStyle,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.bgBase,
        borderRadius: AppRadius.brR16,
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _SectionHeader(
            label: AppStrings.getSauces(locale),
            count: lines.length,
            onAdd: onAdd,
            locale: locale,
          ),
          for (int i = 0; i < lines.length; i++)
            Container(
              decoration: BoxDecoration(
                border: i < lines.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: tokens.borderSubtle,
                          width: 1,
                        ),
                      )
                    : null,
              ),
              child: _SauceRow(
                line: lines[i],
                locale: locale,
                formatStyle: formatStyle,
                onRemove: () => onRemove(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Future<void> Function() onAdd;
  final AppLocale locale;

  const _SectionHeader({
    required this.label,
    required this.count,
    required this.onAdd,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s8,
        AppSpacing.s12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.heading2.copyWith(
                      color: tokens.fgStrong,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: AppSpacing.s6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '$count',
                      style: AppTypography.label2.copyWith(
                        color: tokens.fgTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: Text(AppStrings.getAddShort(locale)),
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.fgDefault,
              side: BorderSide(color: tokens.borderDefault, width: 1),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s12,
                vertical: AppSpacing.s6,
              ),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: AppTypography.label1.copyWith(
                fontWeight: FontWeight.w600,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.brR8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final _IngredientLine line;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final VoidCallback onRemove;

  const _IngredientRow({
    required this.line,
    required this.locale,
    required this.formatStyle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line.ingredient.name,
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
                  NumberFormatter.formatCurrency(
                    line.lineCost,
                    locale,
                    formatStyle,
                  ),
                  style: AppTypography.label2.copyWith(
                    color: tokens.fgTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          SizedBox(
            width: 90,
            child: _OutlinedTextField(
              controller: line.qtyController,
              hint: '0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              suffixText: line.ingredient.purchaseUnitId,
              dense: true,
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 18, color: tokens.fgTertiary),
            visualDensity: VisualDensity.compact,
            tooltip: AppStrings.getDelete(locale),
            padding: const EdgeInsets.all(AppSpacing.s6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _SauceRow extends StatelessWidget {
  final _SauceLine line;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final VoidCallback onRemove;

  const _SauceRow({
    required this.line,
    required this.locale,
    required this.formatStyle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.blender_outlined, size: 18, color: tokens.positive),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line.sauce.name,
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
                  '${NumberFormatter.formatCurrency(line.sauce.unitCost, locale, formatStyle)}/g · '
                  '${NumberFormatter.formatCurrency(line.lineCost, locale, formatStyle)}',
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
          SizedBox(
            width: 80,
            child: _OutlinedTextField(
              controller: line.qtyController,
              hint: '0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              suffixText: 'g',
              dense: true,
            ),
          ),
          const SizedBox(width: AppSpacing.s4),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 18, color: tokens.fgTertiary),
            visualDensity: VisualDensity.compact,
            tooltip: AppStrings.getDelete(locale),
            padding: const EdgeInsets.all(AppSpacing.s6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ Cost preview

class _CostPreviewCard extends StatelessWidget {
  final double cost;
  final double sellPrice;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;

  const _CostPreviewCard({
    required this.cost,
    required this.sellPrice,
    required this.locale,
    required this.formatStyle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final showMargin = sellPrice > 0;
    final marginPct = RecipeMargin.percent(sellPrice, cost);
    final marginColor = RecipeMargin.color(marginPct, tokens);

    return Container(
      decoration: BoxDecoration(
        color: tokens.primarySoft,
        borderRadius: AppRadius.brR16,
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.getTotalCostLabel(locale),
                style: AppTypography.label1.copyWith(
                  color: tokens.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                NumberFormatter.formatCurrency(cost, locale, formatStyle),
                style: AppTypography.heading2.copyWith(
                  color: tokens.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (showMargin) ...[
            const SizedBox(height: AppSpacing.s8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.getExpectedMargin(locale),
                  style: AppTypography.label1.copyWith(
                    color: tokens.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${marginPct.toStringAsFixed(1)}%',
                  style: AppTypography.heading2.copyWith(
                    color: marginColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ Shared atoms

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Text(
      text,
      style: AppTypography.label1.copyWith(
        color: tokens.fgDefault,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _OutlinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final bool dense;

  const _OutlinedTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.suffixText,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: AppTypography.body1.copyWith(color: tokens.fgDefault),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body1.copyWith(color: tokens.fgTertiary),
        suffixText: suffixText,
        suffixStyle: AppTypography.label2.copyWith(color: tokens.fgTertiary),
        isDense: dense,
        filled: true,
        fillColor: tokens.bgBase,
        contentPadding: dense
            ? const EdgeInsets.symmetric(
                horizontal: AppSpacing.s8,
                vertical: AppSpacing.s8,
              )
            : const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _BottomActionButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
      width: double.infinity,
      color: tokens.bgElev2,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      child: SizedBox(
        height: 56,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: tokens.primary,
            foregroundColor: tokens.fgOnPrimary,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.brR12,
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tokens.fgOnPrimary,
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.headline2.copyWith(
                    color: tokens.fgOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
