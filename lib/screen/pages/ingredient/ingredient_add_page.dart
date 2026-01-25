import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_app/router/router_helper.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/date_formatter.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';

import '../../../model/tag.dart';
import '../../../model/unit.dart';
import '../../widget/index.dart';
import '../../../controller/setting/locale_cubit.dart';

/// 재료 추가 페이지
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

  String _selectedUnitId = '';
  DateTime? _expiryDate;
  String _selectedTagId = '';
  List<Tag> _availableTags = [];
  List<Unit> _availableUnits = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    if (widget.preFilledIngredientName != null) {
      _nameController.text = widget.preFilledIngredientName!;
    }
  }

  void _loadInitialData() {
    _loadTags();
    _loadUnits();
  }

  void _loadTags() {
    final locale = context.read<LocaleCubit>().state;
    setState(() {
      _availableTags = DefaultTags.ingredientTagsFor(locale);
    });
  }

  void _loadUnits() {
    setState(() {
      _availableUnits = [
        Unit(id: 'g', name: 'g', type: 'weight', conversionFactor: 1.0),
        Unit(id: 'kg', name: 'kg', type: 'weight', conversionFactor: 1000.0),
        Unit(id: 'ml', name: 'ml', type: 'volume', conversionFactor: 1.0),
        Unit(id: 'L', name: 'L', type: 'volume', conversionFactor: 1000.0),
        Unit(id: '개', name: '개', type: 'count', conversionFactor: 1.0),
        Unit(id: '마리', name: '마리', type: 'count', conversionFactor: 1.0),
        Unit(id: '장', name: '장', type: 'count', conversionFactor: 1.0),
        Unit(id: '인분', name: '인분', type: 'count', conversionFactor: 1.0),
      ];

      if (widget.preFilledUnit != null) {
        final matchedUnit = _availableUnits.firstWhere(
          (unit) =>
              unit.id == widget.preFilledUnit ||
              unit.name == widget.preFilledUnit,
          orElse: () => _availableUnits.first,
        );
        _selectedUnitId = matchedUnit.id;
      } else if (_availableUnits.isNotEmpty) {
        _selectedUnitId = _availableUnits.first.id;
      }

      if (widget.preFilledAmount != null &&
          widget.preFilledAmount!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _amountController.text = widget.preFilledAmount!;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppStrings.getAddIngredient(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        ),
        actions: [
          Tooltip(
            message: AppStrings.getBulkAddTooltip(currentLocale),
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () => RouterHelper.goToIngredientBulkAdd(context),
              child: Text(
                AppStrings.getBulkAdd(currentLocale),
                style: AppTextStyles.buttonMedium.copyWith(
                  color: _isLoading
                      ? colorScheme.onSurface.withValues(alpha: 0.3)
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _isLoading ? null : _saveIngredient,
            child: Text(
              AppStrings.getSave(currentLocale),
              style: AppTextStyles.buttonMedium.copyWith(
                color: _isLoading
                    ? colorScheme.onSurface.withValues(alpha: 0.3)
                    : colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildTagSelectionSection(),
                    const SizedBox(height: 24),
                    _buildExpiryDateSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getBasicInformation(currentLocale),
          style: AppTextStyles.headline4.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        AppInputField(
          controller: _nameController,
          label: AppStrings.getIngredientName(currentLocale),
          hint: AppStrings.getEnterIngredientName(currentLocale),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.getIngredientNameRequired(currentLocale);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CurrencyInputField(
          label: AppStrings.getPurchasePrice(currentLocale),
          hint: AppStrings.getEnterPrice(currentLocale),
          controller: _priceController,
          locale: currentLocale,
          onChanged: (price) {},
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.getPriceRequired(currentLocale);
            }
            final price = _parseFormattedPrice(value);
            if (price == null || price <= 0) {
              return AppStrings.getValidPriceRequired(currentLocale);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumberInputField(
              label: AppStrings.getPurchaseAmount(currentLocale),
              hint: AppStrings.getEnterAmount(currentLocale),
              controller: _amountController,
              onChanged: (amount) {},
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.getAmountRequired(currentLocale);
                }
                final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
                final amount = double.tryParse(cleanValue);
                if (amount == null || amount <= 0) {
                  return AppStrings.getValidAmountRequired(currentLocale);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUnitId.isNotEmpty ? _selectedUnitId : null,
              dropdownColor: colorScheme.surface,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: AppStrings.getUnit(currentLocale),
                labelStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _availableUnits.map((unit) {
                return DropdownMenuItem(value: unit.id, child: Text(unit.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnitId = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.getUnitRequired(currentLocale);
                }
                return null;
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagSelectionSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getTags(currentLocale),
          style: AppTextStyles.headline4.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getSelectTagsDescription(currentLocale),
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTagId == tag.id;
            return FilterChip(
              label: Text(tag.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTagId = tag.id;
                  } else {
                    _selectedTagId = '';
                  }
                });
              },
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: colorScheme.primary,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpiryDateSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getExpiryDate(currentLocale),
          style: AppTextStyles.headline4.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getExpiryDateDescription(currentLocale),
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectExpiryDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _expiryDate != null
                        ? DateFormatter.formatDate(_expiryDate!, currentLocale)
                        : AppStrings.getSelectExpiryDate(currentLocale),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _expiryDate != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                if (_expiryDate != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _expiryDate = null;
                      });
                    },
                    icon: Icon(Icons.clear,
                        size: 20,
                        color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final currentLocale = context.watch<LocaleCubit>().state;
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: AppStrings.getSave(currentLocale),
        type: AppButtonType.primary,
        size: AppButtonSize.large,
        onPressed: _saveIngredient,
      ),
    );
  }

  void _selectExpiryDate() async {
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  double? _parseFormattedPrice(String value) {
    if (value.isEmpty) return null;
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanValue);
  }

  double? _parseFormattedAmount(String value) {
    if (value.isEmpty) return null;
    final numbers = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numbers);
  }

  void _saveIngredient() async {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUnitId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getUnitRequired(currentLocale)),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final parsedPrice = _parseFormattedPrice(_priceController.text) ?? 0.0;
      final parsedAmount = _parseFormattedAmount(_amountController.text) ?? 0.0;

      context.read<IngredientCubit>().addIngredient(
            name: _nameController.text.trim(),
            purchasePrice: parsedPrice,
            purchaseAmount: parsedAmount,
            purchaseUnitId: _selectedUnitId,
            expiryDate: _expiryDate,
            tagIds: _selectedTagId.isNotEmpty ? [_selectedTagId] : [],
          );

      if (mounted) {
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getIngredientAddFailed(currentLocale)),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
