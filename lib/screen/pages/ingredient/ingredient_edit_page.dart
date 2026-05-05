import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import 'ingredient_form_card.dart';

/// 재료 수정 페이지 — 등록 페이지와 동일한 폼 카드 디자인 (이미지 2).
class IngredientEditPage extends StatefulWidget {
  final Ingredient ingredient;

  const IngredientEditPage({super.key, required this.ingredient});

  @override
  State<IngredientEditPage> createState() => _IngredientEditPageState();
}

class _IngredientEditPageState extends State<IngredientEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _amountController;

  late String _selectedTagId;
  late String _selectedUnitId;
  DateTime? _expiryDate;
  bool _isSaving = false;
  bool _priceInitialized = false;

  static const _availableUnits = <String>[
    'g',
    'kg',
    'ml',
    'L',
    '개',
    '마리',
    '장',
    '인분',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.ingredient.name);
    _priceController = TextEditingController();
    _amountController = TextEditingController(
      text: widget.ingredient.purchaseAmount.toStringAsFixed(0),
    );
    _selectedUnitId = widget.ingredient.purchaseUnitId;
    _selectedTagId = widget.ingredient.tagIds.isNotEmpty
        ? widget.ingredient.tagIds.first
        : '';
    _expiryDate = widget.ingredient.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _initPriceIfNeeded(NumberFormatStyle style, AppLocale locale) {
    if (_priceInitialized) return;
    _priceController.text = NumberFormatter.formatNumber(
      widget.ingredient.purchasePrice.round(),
      style,
    );
    _priceInitialized = true;
  }

  double? _parseNumber(String s) {
    if (s.isEmpty) return null;
    final clean = s.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean);
  }

  Future<void> _save() async {
    final locale = context.read<LocaleCubit>().state;
    final tokens = AppColorTokens.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final updated = widget.ingredient.copyWith(
        name: _nameController.text.trim(),
        purchasePrice: _parseNumber(_priceController.text) ?? 0,
        purchaseAmount: _parseNumber(_amountController.text) ?? 0,
        purchaseUnitId: _selectedUnitId,
        expiryDate: _expiryDate,
        tagIds: _selectedTagId.isEmpty ? const [] : [_selectedTagId],
      );
      await context.read<IngredientCubit>().updateIngredient(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.getIngredientUpdatedSuccessfully(locale),
          ),
          backgroundColor: tokens.primary,
        ),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getIngredientUpdateFailed(locale)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectExpiry() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365));
    DateTime initial = _expiryDate ?? now.add(const Duration(days: 7));
    if (initial.isBefore(firstDate)) initial = firstDate;
    if (initial.isAfter(lastDate)) initial = lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _confirmDelete(AppLocale locale) async {
    final tokens = AppColorTokens.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.getDelete(locale)),
        content: Text(
          '${widget.ingredient.name}${AppStrings.getDeleteRecipeConfirm(locale)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: tokens.negative),
            child: Text(AppStrings.getDelete(locale)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;
    await context.read<IngredientCubit>().deleteIngredient(
          widget.ingredient.id,
        );
    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.getIngredientDeleted(locale))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;
    _initPriceIfNeeded(formatStyle, locale);

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
          AppStrings.getEditIngredient(locale),
          style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : () => _confirmDelete(locale),
            icon: Icon(Icons.delete_outline, color: tokens.fgStrong),
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s16,
                  AppSpacing.s16,
                  AppSpacing.s16,
                ),
                child: Form(
                  key: _formKey,
                  child: IngredientFormCard(
                    nameController: _nameController,
                    priceController: _priceController,
                    amountController: _amountController,
                    selectedTagId: _selectedTagId,
                    selectedUnitId: _selectedUnitId,
                    availableUnits: _availableUnits,
                    expiryDate: _expiryDate,
                    locale: locale,
                    formatStyle: formatStyle,
                    onTagChanged: (id) =>
                        setState(() => _selectedTagId = id),
                    onUnitChanged: (id) =>
                        setState(() => _selectedUnitId = id),
                    onPickExpiry: _selectExpiry,
                    onClearExpiry: () => setState(() => _expiryDate = null),
                  ),
                ),
              ),
            ),
            _BottomActionButton(
              label: AppStrings.getSaveChanges(locale),
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
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
