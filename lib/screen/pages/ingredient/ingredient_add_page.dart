import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../router/router_helper.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import 'ingredient_form_card.dart';

/// 재료 등록 페이지 — 이미지 2.
class IngredientAddPage extends StatefulWidget {
  final String? preFilledIngredientName;
  final String? preFilledAmount;
  final String? preFilledUnit;

  const IngredientAddPage({
    super.key,
    this.preFilledIngredientName,
    this.preFilledAmount,
    this.preFilledUnit,
  });

  @override
  State<IngredientAddPage> createState() => _IngredientAddPageState();
}

class _IngredientAddPageState extends State<IngredientAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();

  String _selectedTagId = '';
  String _selectedUnitId = 'g';
  DateTime? _expiryDate;
  bool _isSaving = false;

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
    if (widget.preFilledIngredientName != null) {
      _nameController.text = widget.preFilledIngredientName!;
    }
    if (widget.preFilledUnit != null) {
      final match = _availableUnits.firstWhere(
        (u) => u == widget.preFilledUnit,
        orElse: () => _availableUnits.first,
      );
      _selectedUnitId = match;
    }
    if (widget.preFilledAmount != null && widget.preFilledAmount!.isNotEmpty) {
      _amountController.text = widget.preFilledAmount!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double? _parseNumber(String s) {
    if (s.isEmpty) return null;
    final clean = s.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean);
  }

  Future<void> _save() async {
    final locale = context.read<LocaleCubit>().state;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final price = _parseNumber(_priceController.text) ?? 0;
      final amount = _parseNumber(_amountController.text) ?? 0;
      await context.read<IngredientCubit>().addIngredient(
            name: _nameController.text.trim(),
            purchasePrice: price,
            purchaseAmount: amount,
            purchaseUnitId: _selectedUnitId,
            expiryDate: _expiryDate,
            tagIds: _selectedTagId.isEmpty ? const [] : [_selectedTagId],
          );
      if (!mounted) return;
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getIngredientAddFailed(locale)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectExpiryDate(AppLocale locale) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
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
          AppStrings.getAddIngredient(locale),
          style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving
                ? null
                : () => RouterHelper.goToIngredientBulkAdd(context),
            child: Text(
              AppStrings.getBulkAdd(locale),
              style: AppTypography.label1.copyWith(
                color: tokens.fgSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                    onPickExpiry: () => _selectExpiryDate(locale),
                    onClearExpiry: () => setState(() => _expiryDate = null),
                  ),
                ),
              ),
            ),
            _BottomActionButton(
              label: AppStrings.getDoRegister(locale),
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
