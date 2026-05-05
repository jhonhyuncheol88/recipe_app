import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../model/sauce.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../widget/ingredient_picker_sheet.dart';

/// 소스 수정 페이지 — 디자인 핸드오프(SauceNew, screens.jsx 1247~) 동일 레이아웃.
class SauceEditPage extends StatefulWidget {
  final Sauce sauce;
  const SauceEditPage({super.key, required this.sauce});

  @override
  State<SauceEditPage> createState() => _SauceEditPageState();
}

class _SauceEditPageState extends State<SauceEditPage> {
  final _nameController = TextEditingController();
  final List<_IngredientLine> _items = [];

  /// 페이지 진입 당시 존재했던 sauce_ingredient.id 들. 저장 시 이 목록과
  /// 현재 _items 의 sauceIngredientId 를 비교해 빠진 줄은 삭제한다.
  final Set<String> _initialSauceIngredientIds = {};

  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.sauce.name;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final l in _items) {
      l.qtyController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final cubit = context.read<SauceCubit>();
    final ingredients = _availableIngredients();
    try {
      final list = await cubit.getIngredientsForSauce(widget.sauce.id);
      final lines = <_IngredientLine>[];
      for (final si in list) {
        final ing = ingredients.firstWhere(
          (i) => i.id == si.ingredientId,
          orElse: () => Ingredient(
            id: si.ingredientId,
            name: '재료(${si.ingredientId})',
            purchasePrice: 0,
            purchaseAmount: 1,
            purchaseUnitId: si.unitId,
            createdAt: DateTime.now(),
          ),
        );
        lines.add(
          _IngredientLine(
            sauceIngredientId: si.id,
            ingredient: ing,
            qty: si.amount,
            unitId: si.unitId,
            qtyController: TextEditingController(
              text: _formatInitialQty(si.amount),
            ),
          ),
        );
        _initialSauceIngredientIds.add(si.id);
      }
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(lines);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<Ingredient> _availableIngredients() {
    final st = context.read<IngredientCubit>().state;
    if (st is IngredientLoaded) return st.ingredients;
    if (st is IngredientAdded) return st.ingredients;
    if (st is IngredientUpdated) return st.ingredients;
    if (st is IngredientDeleted) return st.ingredients;
    return const [];
  }

  String _formatInitialQty(double qty) {
    if (qty <= 0) return '';
    if (qty == qty.truncateToDouble()) {
      return qty.toInt().toString();
    }
    return qty.toString();
  }

  // ---------- cost ----------

  double _pricePerBaseUnit(Ingredient ing) {
    final base = uc.UnitConverter.toBaseUnit(
      ing.purchaseAmount,
      ing.purchaseUnitId,
    );
    if (base <= 0) return 0;
    return ing.purchasePrice / base;
  }

  double _lineCost(_IngredientLine line) {
    final perBase = _pricePerBaseUnit(line.ingredient);
    final baseUsage = uc.UnitConverter.toBaseUnit(line.qty, line.unitId);
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
          sauceIngredientId: null, // new
          ingredient: picked,
          qty: 10,
          unitId: picked.purchaseUnitId,
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
      // 1) 이름 변경 — Sauce 객체 전체로 업데이트.
      if (name != widget.sauce.name) {
        await cubit.updateSauce(widget.sauce.copyWith(name: name));
      }

      // 2) 현재 _items 에 남아있는 sauceIngredientId set.
      final keptIds = _items
          .map((l) => l.sauceIngredientId)
          .whereType<String>()
          .toSet();

      // 3) 초기 목록과 비교해 사라진 항목 삭제.
      for (final initId in _initialSauceIngredientIds) {
        if (!keptIds.contains(initId)) {
          await cubit.removeSauceIngredientById(
            sauceId: widget.sauce.id,
            sauceIngredientId: initId,
          );
        }
      }

      // 4) 각 줄 처리: 기존(sauceIngredientId != null) → 수정, 신규 → 추가.
      for (final line in _items) {
        if (line.sauceIngredientId != null) {
          await cubit.updateSauceIngredient(
            sauceId: widget.sauce.id,
            ingredientId: line.ingredient.id,
            amount: line.qty,
            unitId: line.unitId,
          );
        } else {
          await cubit.addIngredientToSauce(
            sauceId: widget.sauce.id,
            ingredientId: line.ingredient.id,
            amount: line.qty,
            unitId: line.unitId,
          );
        }
      }

      if (!mounted) return;
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getDeleteError(locale, ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
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
            AppStrings.getDeleteSauce(locale),
            style: AppTypography.headline2.copyWith(color: tokens.fgStrong),
          ),
          content: Text(
            AppStrings.getDeleteSauceConfirm(locale, widget.sauce.name),
            style: AppTypography.body1.copyWith(color: tokens.fgDefault),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text(
                AppStrings.getCancel(locale),
                style: TextStyle(color: tokens.fgSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: Text(
                AppStrings.getDelete(locale),
                style: TextStyle(color: tokens.negative),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final cubit = context.read<SauceCubit>();
    await cubit.deleteSauce(widget.sauce.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.getSauceDeleted(locale))),
    );
    context.pop(true);
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
          AppStrings.getEditSauceTitle(locale),
          style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _submitting ? null : _confirmDelete,
            icon: Icon(Icons.delete_outline, color: tokens.negative),
            tooltip: AppStrings.getDelete(locale),
          ),
          const SizedBox(width: AppSpacing.s4),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                    label: AppStrings.getSaveChanges(locale),
                    isLoading: _submitting,
                    onPressed: _submit,
                  ),
                ],
              ),
      ),
    );
  }
}

/// 한 줄 — 기존 항목인 경우 [sauceIngredientId] 가 채워진다. 신규는 null.
class _IngredientLine {
  final String? sauceIngredientId;
  final Ingredient ingredient;
  final double qty;
  final String unitId;
  final TextEditingController qtyController;

  const _IngredientLine({
    required this.sauceIngredientId,
    required this.ingredient,
    required this.qty,
    required this.unitId,
    required this.qtyController,
  });

  _IngredientLine copyWith({double? qty, String? unitId}) => _IngredientLine(
        sauceIngredientId: sauceIngredientId,
        ingredient: ingredient,
        qty: qty ?? this.qty,
        unitId: unitId ?? this.unitId,
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
              suffixText: line.unitId,
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
// Bottom button
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
// Local outlined TextField.
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
