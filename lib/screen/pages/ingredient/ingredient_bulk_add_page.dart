import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import 'ingredient_form_card.dart';

/// 재료 일괄 추가 페이지 — 단일 등록 페이지와 동일한 카드/버튼 패턴.
///
/// 각 재료마다 [IngredientFormCard] 를 재사용해 일관된 입력 UX 를 제공한다.
class IngredientBulkAddPage extends StatefulWidget {
  const IngredientBulkAddPage({super.key});

  @override
  State<IngredientBulkAddPage> createState() => _IngredientBulkAddPageState();
}

class _IngredientBulkAddPageState extends State<IngredientBulkAddPage> {
  final _formKey = GlobalKey<FormState>();
  final List<_BulkRow> _rows = <_BulkRow>[];
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForPrefilledData();
      if (_rows.isEmpty) {
        setState(() => _rows.add(_BulkRow()));
      }
    });
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _checkForPrefilledData() {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    if (extra == null) return;
    final list = extra['prefilledIngredients'] as List<Map<String, dynamic>>?;
    if (list == null || list.isEmpty) return;

    setState(() {
      _rows.clear();
      for (final data in list) {
        final row = _BulkRow();
        row.nameController.text = (data['name'] ?? '').toString();
        final amount = data['amount'];
        double? parsedAmount;
        if (amount is num) {
          parsedAmount = amount.toDouble();
        } else if (amount is String) {
          parsedAmount = double.tryParse(amount);
        }
        if (parsedAmount != null && parsedAmount > 0) {
          row.amountController.text =
              parsedAmount % 1 == 0
                  ? parsedAmount.toStringAsFixed(0)
                  : parsedAmount.toString();
        }
        final unit = (data['unit'] ?? '').toString();
        if (_availableUnits.contains(unit)) {
          row.selectedUnitId = unit;
        }
        _rows.add(row);
      }
    });
  }

  void _addRow() {
    setState(() => _rows.add(_BulkRow()));
  }

  void _removeRow(int index) {
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
  }

  double? _parseNumber(String s) {
    if (s.isEmpty) return null;
    final clean = s.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(clean);
  }

  Future<void> _selectExpiryDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _rows[index].expiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _rows[index].expiryDate = picked);
    }
  }

  Future<void> _save() async {
    final locale = context.read<LocaleCubit>().state;
    if (!_formKey.currentState!.validate()) return;
    if (_rows.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final cubit = context.read<IngredientCubit>();
      var success = 0;
      for (final row in _rows) {
        try {
          final price = _parseNumber(row.priceController.text) ?? 0;
          final amount = _parseNumber(row.amountController.text) ?? 0;
          await cubit.addIngredient(
            name: row.nameController.text.trim(),
            purchasePrice: price,
            purchaseAmount: amount,
            purchaseUnitId: row.selectedUnitId,
            expiryDate: row.expiryDate,
            tagIds: row.selectedTagId.isEmpty ? const [] : [row.selectedTagId],
          );
          success++;
        } catch (_) {
          // 한 행 실패는 무시하고 다음 행 계속.
        }
      }
      if (!mounted) return;
      if (success > 0) {
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getBulkSaveFailed(locale)),
          ),
        );
      }
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
          AppStrings.getBulkAddIngredients(locale),
          style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _addRow,
            icon: Icon(Icons.add, color: tokens.fgStrong),
            tooltip: AppStrings.getAddIngredientToList(locale),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CountHeader(
                        count: _rows.length,
                        locale: locale,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      for (int i = 0; i < _rows.length; i++) ...[
                        _BulkItem(
                          index: i,
                          canRemove: _rows.length > 1,
                          row: _rows[i],
                          availableUnits: _availableUnits,
                          locale: locale,
                          formatStyle: formatStyle,
                          onTagChanged: (id) =>
                              setState(() => _rows[i].selectedTagId = id),
                          onUnitChanged: (id) =>
                              setState(() => _rows[i].selectedUnitId = id),
                          onPickExpiry: () => _selectExpiryDate(i),
                          onClearExpiry: () =>
                              setState(() => _rows[i].expiryDate = null),
                          onRemove: () => _removeRow(i),
                        ),
                        const SizedBox(height: AppSpacing.s12),
                      ],
                      _AddRowButton(
                        label: AppStrings.getAddIngredientToList(locale),
                        onPressed: _isSaving ? null : _addRow,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _BottomActionButton(
              label: _isSaving
                  ? AppStrings.getSaving(locale)
                  : AppStrings.getBulkSave(locale),
              isLoading: _isSaving,
              onPressed: _rows.isEmpty || _isSaving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkRow {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String selectedTagId = '';
  String selectedUnitId = 'g';
  DateTime? expiryDate;

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    amountController.dispose();
  }
}

class _CountHeader extends StatelessWidget {
  final int count;
  final AppLocale locale;

  const _CountHeader({required this.count, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Text(
      AppStrings.getIngredientCount(locale, count),
      style: AppTypography.headline2.copyWith(
        color: tokens.fgStrong,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BulkItem extends StatelessWidget {
  final int index;
  final bool canRemove;
  final _BulkRow row;
  final List<String> availableUnits;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final ValueChanged<String> onTagChanged;
  final ValueChanged<String> onUnitChanged;
  final VoidCallback onPickExpiry;
  final VoidCallback onClearExpiry;
  final VoidCallback onRemove;

  const _BulkItem({
    required this.index,
    required this.canRemove,
    required this.row,
    required this.availableUnits,
    required this.locale,
    required this.formatStyle,
    required this.onTagChanged,
    required this.onUnitChanged,
    required this.onPickExpiry,
    required this.onClearExpiry,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.s4,
            right: AppSpacing.s4,
            bottom: AppSpacing.s8,
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: tokens.primarySoft,
                  borderRadius: AppRadius.brPill,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: AppTypography.label2.copyWith(
                    color: tokens.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Text(
                  AppStrings.getIngredientName(locale),
                  style: AppTypography.label1.copyWith(
                    color: tokens.fgSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: tokens.negative,
                  ),
                  tooltip: AppStrings.getRemoveIngredient(locale),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),
        ),
        IngredientFormCard(
          nameController: row.nameController,
          priceController: row.priceController,
          amountController: row.amountController,
          selectedTagId: row.selectedTagId,
          selectedUnitId: row.selectedUnitId,
          availableUnits: availableUnits,
          expiryDate: row.expiryDate,
          locale: locale,
          formatStyle: formatStyle,
          onTagChanged: onTagChanged,
          onUnitChanged: onUnitChanged,
          onPickExpiry: onPickExpiry,
          onClearExpiry: onClearExpiry,
        ),
      ],
    );
  }
}

class _AddRowButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _AddRowButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: AppRadius.brR12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        decoration: BoxDecoration(
          color: tokens.bgBase,
          borderRadius: AppRadius.brR12,
          border: Border.all(
            color: tokens.borderSubtle,
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: tokens.primary, size: 20),
            const SizedBox(width: AppSpacing.s6),
            Text(
              label,
              style: AppTypography.label1.copyWith(
                color: tokens.primary,
                fontWeight: FontWeight.w700,
              ),
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
