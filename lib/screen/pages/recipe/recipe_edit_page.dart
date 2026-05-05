import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../model/recipe.dart';
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

/// 레시피 수정 페이지 — screens.jsx 1361~ (RecipeNew) 디자인 1:1 이식.
class RecipeEditPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeEditPage({super.key, required this.recipe});

  @override
  State<RecipeEditPage> createState() => _RecipeEditPageState();
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

  /// [initialQty] 는 g 단위 사용량.
  _SauceLine({required this.sauce, required double initialQty})
      : qtyController = TextEditingController(text: _formatQty(initialQty));

  /// 사용량(g).
  double get qty {
    final raw = qtyController.text.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(raw) ?? 0;
  }

  /// 라인 원가 = (g당 단가) × (입력 g).
  double get lineCost => sauce.unitCost * qty;

  void dispose() => qtyController.dispose();

  static String _formatQty(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _sellPriceController;

  final List<_IngredientLine> _ingredients = [];
  final List<_SauceLine> _sauces = [];

  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.recipe.name);
    _sellPriceController = TextEditingController(
      text: widget.recipe.sellPrice > 0
          ? _formatNumber(widget.recipe.sellPrice)
          : '',
    );
    _sellPriceController.addListener(_onChanged);
    _hydrateLines();
  }

  static String _formatNumber(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  void _hydrateLines() {
    final ingState = context.read<IngredientCubit>().state;
    final sauceState = context.read<SauceCubit>().state;
    final allIngredients = _ingredientsOf(ingState);
    final allSauces = _saucesOf(sauceState);

    for (final ri in widget.recipe.ingredients) {
      Ingredient? ing;
      for (final i in allIngredients) {
        if (i.id == ri.ingredientId) {
          ing = i;
          break;
        }
      }
      if (ing == null) continue;
      final line = _IngredientLine(ingredient: ing, initialQty: ri.amount);
      line.qtyController.addListener(_onChanged);
      _ingredients.add(line);
    }

    for (final rs in widget.recipe.sauces) {
      Sauce? sauce;
      for (final s in allSauces) {
        if (s.id == rs.sauceId) {
          sauce = s;
          break;
        }
      }
      if (sauce == null) continue;
      final line = _SauceLine(sauce: sauce, initialQty: rs.amount);
      line.qtyController.addListener(_onChanged);
      _sauces.add(line);
    }
    if (mounted) setState(() {});
  }

  List<Ingredient> _ingredientsOf(IngredientState state) {
    if (state is IngredientLoaded) return state.ingredients;
    if (state is IngredientFilteredByTag) return state.ingredients;
    if (state is IngredientFilteredByTags) return state.ingredients;
    if (state is IngredientFilteredByExpiry) return state.ingredients;
    if (state is IngredientSearchResult) return state.ingredients;
    if (state is IngredientAdded) return state.ingredients;
    if (state is IngredientUpdated) return state.ingredients;
    if (state is IngredientDeleted) return state.ingredients;
    return const [];
  }

  List<Sauce> _saucesOf(SauceState state) {
    if (state is SauceLoaded) return state.sauces;
    if (state is SauceAdded) return state.sauces;
    if (state is SauceUpdatedState) return state.sauces;
    if (state is SauceDeleted) return state.sauces;
    return const [];
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

  void _onChanged() {
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
    line.qtyController.addListener(_onChanged);
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
      initialQty: picked.totalWeight > 0
          ? picked.totalWeight.roundToDouble()
          : 0,
    );
    line.qtyController.addListener(_onChanged);
    setState(() => _sauces.add(line));
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

  Future<void> _save() async {
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

      final newIngredients = _ingredients
          .map(
            (l) => RecipeIngredient(
              id: '',
              recipeId: widget.recipe.id,
              ingredientId: l.ingredient.id,
              amount: l.qty,
              unitId: l.ingredient.purchaseUnitId,
              calculatedCost: 0,
            ),
          )
          .toList();
      final newSauces = _sauces
          .map(
            (l) => RecipeSauce(
              id: '',
              recipeId: widget.recipe.id,
              sauceId: l.sauce.id,
              amount: l.qty,
              // 소스 단위는 항상 g 기준으로 저장 (UnitConverter 가 인식 가능한
              // 실제 unitId 여야 함).
              unitId: 'g',
            ),
          )
          .toList();

      final updated = widget.recipe.copyWith(
        name: name,
        sellPrice: sellPrice,
        ingredients: newIngredients,
        sauces: newSauces,
        updatedAt: DateTime.now(),
      );

      await context.read<RecipeCubit>().updateRecipe(updated);
      if (!mounted) return;
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: tokens.negative,
          content: Text(AppStrings.getRecipeUpdateError(locale)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final locale = context.read<LocaleCubit>().state;
    final tokens = AppColorTokens.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: tokens.bgBase,
          title: Text(
            AppStrings.getDeleteRecipe(locale),
            style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
          ),
          content: Text(
            AppStrings.getDeleteRecipeConfirm(locale),
            style: AppTypography.body1.copyWith(color: tokens.fgDefault),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text(
                AppStrings.getCancel(locale),
                style: AppTypography.label1.copyWith(
                  color: tokens.fgSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: tokens.negative,
                foregroundColor: tokens.fgOnPrimary,
              ),
              child: Text(
                AppStrings.getDelete(locale),
                style: AppTypography.label1.copyWith(
                  color: tokens.fgOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isDeleting = true);
    try {
      await context.read<RecipeCubit>().deleteRecipe(widget.recipe.id);
      if (!mounted) return;
      context.pop(true);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;
    final busy = _isSaving || _isDeleting;

    return Scaffold(
      backgroundColor: tokens.bgElev2,
      appBar: AppBar(
        backgroundColor: tokens.bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: busy ? null : () => context.pop(),
          icon: Icon(Icons.arrow_back, color: tokens.fgStrong),
        ),
        title: Text(
          AppStrings.getEditRecipe(locale),
          style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: busy ? null : _confirmDelete,
            icon: Icon(Icons.delete_outline, color: tokens.negative),
            tooltip: AppStrings.getDelete(locale),
          ),
          const SizedBox(width: AppSpacing.s4),
        ],
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
              label: AppStrings.getSaveChanges(locale),
              isLoading: _isSaving,
              onPressed: busy ? null : _save,
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
