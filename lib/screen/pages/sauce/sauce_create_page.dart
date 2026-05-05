import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../router/app_router.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../widget/ingredient_picker_sheet.dart';

/// 소스 만들기 페이지 — 디자인 핸드오프(SauceNew, screens.jsx 1247~) 1:1 이식.
class SauceCreatePage extends StatefulWidget {
  const SauceCreatePage({super.key});

  @override
  State<SauceCreatePage> createState() => _SauceCreatePageState();
}

class _SauceCreatePageState extends State<SauceCreatePage> {
  final _nameController = TextEditingController();
  final List<_IngredientLine> _items = [];
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    for (final l in _items) {
      l.qtyController.dispose();
    }
    super.dispose();
  }

  // ---------- cost calc ----------

  /// 1g(또는 1ml/1개) 당 단가.
  double _pricePerBaseUnit(Ingredient ing) {
    final base = uc.UnitConverter.toBaseUnit(
      ing.purchaseAmount,
      ing.purchaseUnitId,
    );
    if (base <= 0) return 0;
    return ing.purchasePrice / base;
  }

  /// 한 줄의 원가 = (구매가/구매기준량) × 사용량(기본단위 환산).
  double _lineCost(_IngredientLine line) {
    final perBase = _pricePerBaseUnit(line.ingredient);
    final baseUsage = uc.UnitConverter.toBaseUnit(
      line.qty,
      line.ingredient.purchaseUnitId,
    );
    return perBase * baseUsage;
  }

  double get _totalCost {
    var sum = 0.0;
    for (final l in _items) {
      sum += _lineCost(l);
    }
    return sum;
  }

  // ---------- handlers ----------

  Future<void> _pickIngredient() async {
    final picked = await showIngredientPickerSheet(
      context,
      excludeIds: _items.map((l) => l.ingredient.id).toList(),
    );
    if (picked == null) return;
    setState(() {
      _items.add(
        _IngredientLine(
          ingredient: picked,
          qty: 10,
          qtyController: TextEditingController(text: '10'),
        ),
      );
    });
  }

  void _removeLine(int index) {
    setState(() {
      _items[index].qtyController.dispose();
      _items.removeAt(index);
    });
  }

  void _onQtyChanged(int index, String value) {
    final clean = value.replaceAll(RegExp(r'[^\d.]'), '');
    final n = double.tryParse(clean) ?? 0;
    setState(() {
      _items[index] = _items[index].copyWith(qty: n);
    });
  }

  Future<void> _submit() async {
    final locale = context.read<LocaleCubit>().state;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getSauceNameRequired(locale))),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getAtLeastOneIngredient(locale))),
      );
      return;
    }

    setState(() => _submitting = true);
    final cubit = context.read<SauceCubit>();
    try {
      await cubit.addSauce(name: name);

      // SauceAdded state 에서 새로 생성된 sauce.id 추출.
      final st = cubit.state;
      String? newSauceId;
      if (st is SauceAdded) {
        newSauceId = st.sauce.id;
      }

      if (newSauceId != null) {
        for (final line in _items) {
          await cubit.addIngredientToSauce(
            sauceId: newSauceId,
            ingredientId: line.ingredient.id,
            amount: line.qty,
            unitId: line.ingredient.purchaseUnitId,
          );
        }
      }

      if (!mounted) return;
      context.go(AppRouter.recipes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getDeleteError(locale, ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ---------- build ----------

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
          AppStrings.getMakeSauceTitle(locale),
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
                    _NameCard(
                      controller: _nameController,
                      locale: locale,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _CompositionCard(
                      items: _items,
                      totalCost: _totalCost,
                      locale: locale,
                      formatStyle: formatStyle,
                      onAdd: _submitting ? null : _pickIngredient,
                      onRemove: _submitting ? null : _removeLine,
                      onQtyChanged: _onQtyChanged,
                    ),
                    if (_items.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s12),
                      _TotalCostPreview(
                        cost: _totalCost,
                        locale: locale,
                        formatStyle: formatStyle,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _BottomActionButton(
              label: AppStrings.getDoRegister(locale),
              isLoading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// 폼 상태가 보유하는 한 줄 — picked Ingredient + qty TextEditingController + qty value.
class _IngredientLine {
  final Ingredient ingredient;
  final double qty;
  final TextEditingController qtyController;

  const _IngredientLine({
    required this.ingredient,
    required this.qty,
    required this.qtyController,
  });

  _IngredientLine copyWith({double? qty}) => _IngredientLine(
        ingredient: ingredient,
        qty: qty ?? this.qty,
        qtyController: qtyController,
      );
}

// ============================================================================
// Card 1 — Name
// ============================================================================
class _NameCard extends StatelessWidget {
  final TextEditingController controller;
  final AppLocale locale;

  const _NameCard({required this.controller, required this.locale});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getSauceName(locale),
            style: AppTypography.label1.copyWith(
              color: tokens.fgDefault,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          _OutlinedTextField(
            controller: controller,
            hint: AppStrings.getSauceNamePlaceholder(locale),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Card 2 — 구성 재료
// ============================================================================
class _CompositionCard extends StatelessWidget {
  final List<_IngredientLine> items;
  final double totalCost;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final VoidCallback? onAdd;
  final void Function(int index)? onRemove;
  final void Function(int index, String value) onQtyChanged;

  const _CompositionCard({
    required this.items,
    required this.totalCost,
    required this.locale,
    required this.formatStyle,
    required this.onAdd,
    required this.onRemove,
    required this.onQtyChanged,
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
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              14,
              AppSpacing.s12,
              14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.getCompositionIngredients(locale),
                        style: AppTypography.headline2.copyWith(
                          color: tokens.fgStrong,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppStrings.getIngredientCount(locale, items.length)} · ${AppStrings.getCost(locale)} ${NumberFormatter.formatCurrency(totalCost, locale, formatStyle)}',
                        style: AppTypography.label2.copyWith(
                          color: tokens.fgTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(AppStrings.getAddIngredientSection(locale)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.fgStrong,
                    side: BorderSide(color: tokens.borderDefault, width: 1),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.brR8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: AppSpacing.s8,
                    ),
                    textStyle: AppTypography.label1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    visualDensity: VisualDensity.compact,
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(
                AppStrings.getAtLeastOneIngredient(locale),
                style: AppTypography.body2.copyWith(
                  color: tokens.fgTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            for (var i = 0; i < items.length; i++)
              _CompositionRow(
                line: items[i],
                locale: locale,
                formatStyle: formatStyle,
                onQtyChanged: (v) => onQtyChanged(i, v),
                onRemove: onRemove == null ? null : () => onRemove!(i),
              ),
        ],
      ),
    );
  }
}

class _CompositionRow extends StatelessWidget {
  final _IngredientLine line;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final ValueChanged<String> onQtyChanged;
  final VoidCallback? onRemove;

  const _CompositionRow({
    required this.line,
    required this.locale,
    required this.formatStyle,
    required this.onQtyChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final ing = line.ingredient;
    final base = uc.UnitConverter.toBaseUnit(
      ing.purchaseAmount,
      ing.purchaseUnitId,
    );
    final perBase = base > 0 ? ing.purchasePrice / base : 0.0;
    final perBaseText = NumberFormatter.formatPerBaseUnitPrice(
      perBase.toDouble(),
      ing.purchaseUnitId,
      locale,
      formatStyle,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s12,
        AppSpacing.s8,
        AppSpacing.s12,
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
                  ing.name,
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
                  perBaseText,
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
            width: 100,
            child: _OutlinedTextField(
              controller: line.qtyController,
              hint: '0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              suffixText: ing.purchaseUnitId,
              onChanged: onQtyChanged,
              compact: true,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.close, size: 18, color: tokens.fgTertiary),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(AppSpacing.s6),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Card 3 — 총 원가 preview
// ============================================================================
class _TotalCostPreview extends StatelessWidget {
  final double cost;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;

  const _TotalCostPreview({
    required this.cost,
    required this.locale,
    required this.formatStyle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.primarySoft,
        borderRadius: AppRadius.brR16,
      ),
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.getTotalCostLabel(locale),
            style: AppTypography.label1.copyWith(
              color: tokens.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          Text(
            NumberFormatter.formatCurrency(cost, locale, formatStyle),
            style: AppTypography.title2.copyWith(
              color: tokens.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.36,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Bottom button (mirrors ingredient_add_page._BottomActionButton).
// ============================================================================
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

// ============================================================================
// Local outlined TextField (no Form / validator). Mirrors style of
// ingredient_form_card._OutlinedTextField.
// ============================================================================
class _OutlinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final ValueChanged<String>? onChanged;
  final bool compact;

  const _OutlinedTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.suffixText,
    this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: AppTypography.body1.copyWith(color: tokens.fgDefault),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body1.copyWith(color: tokens.fgTertiary),
        suffixText: suffixText,
        suffixStyle:
            AppTypography.label1.copyWith(color: tokens.fgTertiary),
        filled: true,
        fillColor: tokens.bgBase,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.s12 : AppSpacing.s16,
          vertical: compact ? AppSpacing.s8 : AppSpacing.s12,
        ),
        isDense: compact,
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
