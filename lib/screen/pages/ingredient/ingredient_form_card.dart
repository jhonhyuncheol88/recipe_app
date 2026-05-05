import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/date_formatter.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../widget/ingredient_tag_chip.dart';

/// 재료 등록/수정 페이지에서 공통으로 쓰는 단일 카드 폼 (이미지 2).
class IngredientFormCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController amountController;
  final String selectedTagId;
  final String selectedUnitId;
  final List<String> availableUnits;
  final DateTime? expiryDate;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final ValueChanged<String> onTagChanged;
  final ValueChanged<String> onUnitChanged;
  final VoidCallback onPickExpiry;
  final VoidCallback onClearExpiry;

  const IngredientFormCard({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.amountController,
    required this.selectedTagId,
    required this.selectedUnitId,
    required this.availableUnits,
    required this.expiryDate,
    required this.locale,
    required this.formatStyle,
    required this.onTagChanged,
    required this.onUnitChanged,
    required this.onPickExpiry,
    required this.onClearExpiry,
  });

  String _baseUnitSymbol() {
    final type = uc.UnitConverter.getUnitType(selectedUnitId);
    if (type == uc.UnitType.weight) return 'g';
    if (type == uc.UnitType.volume) return 'ml';
    return '개';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);

    return Container(
      decoration: BoxDecoration(
        color: tokens.bgBase,
        borderRadius: AppRadius.brR16,
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(text: AppStrings.getIngredientName(locale)),
          const SizedBox(height: AppSpacing.s8),
          _OutlinedTextField(
            controller: nameController,
            hint: AppStrings.getEnterIngredientNameHint(locale),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppStrings.getIngredientNameRequired(locale);
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.s20),
          _FieldLabel(text: AppStrings.getCategory(locale)),
          const SizedBox(height: AppSpacing.s8),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              _tagChip(
                IngredientTagPalette.fresh,
                AppStrings.getIngredientTagFresh(locale),
              ),
              _tagChip(
                IngredientTagPalette.frozen,
                AppStrings.getIngredientTagFrozen(locale),
              ),
              _tagChip(
                IngredientTagPalette.indoor,
                AppStrings.getIngredientTagIndoor(locale),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: AppStrings.getUnitPrice(locale)),
                    const SizedBox(height: AppSpacing.s8),
                    _OutlinedTextField(
                      controller: priceController,
                      hint: '0',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ],
                      suffixText:
                          '${NumberFormatter.getCurrencyName(locale)}/${_baseUnitSymbol()}',
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppStrings.getPriceRequired(locale);
                        }
                        final cleanValue = v.replaceAll(RegExp(r'[^\d.]'), '');
                        final n = double.tryParse(cleanValue);
                        if (n == null || n <= 0) {
                          return AppStrings.getValidPriceRequired(locale);
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(text: AppStrings.getUnit(locale)),
                    const SizedBox(height: AppSpacing.s8),
                    _UnitDropdown(
                      value: selectedUnitId,
                      units: availableUnits,
                      onChanged: onUnitChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          _FieldLabel(text: AppStrings.getPurchaseAmountShort(locale)),
          const SizedBox(height: AppSpacing.s8),
          _OutlinedTextField(
            controller: amountController,
            hint: '0',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
            suffixText: selectedUnitId,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppStrings.getAmountRequired(locale);
              }
              final cleanValue = v.replaceAll(RegExp(r'[^\d.]'), '');
              final n = double.tryParse(cleanValue);
              if (n == null || n <= 0) {
                return AppStrings.getValidAmountRequired(locale);
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.s20),
          _FieldLabel(text: AppStrings.getExpiryDate(locale)),
          const SizedBox(height: AppSpacing.s8),
          _ExpiryDateField(
            date: expiryDate,
            locale: locale,
            onPick: onPickExpiry,
            onClear: onClearExpiry,
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String id, String label) {
    return IngredientSelectableChip(
      label: label,
      selected: selectedTagId == id,
      onTap: () => onTagChanged(selectedTagId == id ? '' : id),
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
  final String? Function(String?)? validator;
  final String? suffixText;

  const _OutlinedTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: AppTypography.body1.copyWith(color: tokens.fgDefault),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body1.copyWith(color: tokens.fgTertiary),
        suffixText: suffixText,
        suffixStyle:
            AppTypography.label1.copyWith(color: tokens.fgTertiary),
        filled: true,
        fillColor: tokens.bgBase,
        contentPadding: const EdgeInsets.symmetric(
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
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.negative, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.negative, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.brR12,
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  final String value;
  final List<String> units;
  final ValueChanged<String> onChanged;

  const _UnitDropdown({
    required this.value,
    required this.units,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return DropdownButtonFormField<String>(
      initialValue: units.contains(value) ? value : null,
      isDense: true,
      icon: Icon(Icons.expand_more, color: tokens.fgTertiary),
      style: AppTypography.body1.copyWith(color: tokens.fgDefault),
      dropdownColor: tokens.bgBase,
      decoration: InputDecoration(
        filled: true,
        fillColor: tokens.bgBase,
        contentPadding: const EdgeInsets.symmetric(
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
      items: units
          .map(
            (u) => DropdownMenuItem<String>(
              value: u,
              child: Text(u),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _ExpiryDateField extends StatelessWidget {
  final DateTime? date;
  final AppLocale locale;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _ExpiryDateField({
    required this.date,
    required this.locale,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final hasDate = date != null;
    return InkWell(
      onTap: onPick,
      borderRadius: AppRadius.brR12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: tokens.bgBase,
          borderRadius: AppRadius.brR12,
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasDate
                    ? DateFormatter.formatDate(date!, locale)
                    : AppStrings.getSelectExpiryDate(locale),
                style: AppTypography.body1.copyWith(
                  color: hasDate ? tokens.fgDefault : tokens.fgTertiary,
                ),
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s4),
                  child: Icon(Icons.close, size: 18, color: tokens.fgTertiary),
                ),
              ),
            Icon(Icons.calendar_today_outlined,
                size: 18, color: tokens.fgTertiary),
          ],
        ),
      ),
    );
  }
}
