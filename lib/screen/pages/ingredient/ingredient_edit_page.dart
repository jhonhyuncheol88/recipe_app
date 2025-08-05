import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';
import 'package:intl/intl.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';

import '../../../model/ingredient.dart';
import '../../../model/tag.dart';
import '../../../model/unit.dart';
import '../../widget/index.dart';

/// 재료 수정 페이지
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

  // 포맷팅된 값 저장용
  String _formattedPrice = '';
  String _formattedAmount = '';

  late String _selectedUnitId;
  DateTime? _expiryDate;
  String _selectedTagId = '';
  List<Tag> _availableTags = [];
  List<Unit> _availableUnits = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.ingredient.name);
    _priceController = TextEditingController(
      text: NumberFormatter.formatCurrency(
        widget.ingredient.purchasePrice,
        AppLocale.korea,
      ),
    );
    _amountController = TextEditingController(
      text: NumberFormat(
        '#,##0',
        'en_US',
      ).format(widget.ingredient.purchaseAmount),
    );
    _selectedUnitId = widget.ingredient.purchaseUnitId;
    _expiryDate = widget.ingredient.expiryDate;
    _selectedTagId = widget.ingredient.tagIds.isNotEmpty
        ? widget.ingredient.tagIds.first
        : '';
  }

  void _loadInitialData() {
    _loadTags();
    _loadUnits();
  }

  void _loadTags() {
    // TODO: TagCubit에서 태그 목록 가져오기
    setState(() {
      _availableTags = DefaultTags.ingredientTags;
    });
  }

  void _loadUnits() {
    // TODO: UnitRepository에서 단위 목록 가져오기
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getEditIngredient(AppLocale.korea),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateIngredient,
            child: Text(
              AppStrings.getSave(AppLocale.korea),
              style: AppTextStyles.buttonMedium.copyWith(
                color: _isLoading ? AppColors.textSecondary : AppColors.primary,
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
                    _buildUpdateButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getBasicInformation(AppLocale.korea),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        AppInputField(
          controller: _nameController,
          label: AppStrings.getIngredientName(AppLocale.korea),
          hint: AppStrings.getEnterIngredientName(AppLocale.korea),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.getIngredientNameRequired(AppLocale.korea);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CurrencyInputField(
          label: AppStrings.getPurchasePrice(AppLocale.korea),
          hint: AppStrings.getEnterPrice(AppLocale.korea),
          controller: _priceController,
          locale: AppLocale.korea,
          onChanged: (price) {
            // 가격이 변경될 때 처리
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.getPriceRequired(AppLocale.korea);
            }
            final price = _parseFormattedPrice(value);
            if (price == null || price <= 0) {
              return AppStrings.getValidPriceRequired(AppLocale.korea);
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NumberInputField(
              label: AppStrings.getPurchaseAmount(AppLocale.korea),
              hint: AppStrings.getEnterAmount(AppLocale.korea),
              controller: _amountController,
              onChanged: (amount) {
                // 수량이 변경될 때 처리
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.getAmountRequired(AppLocale.korea);
                }
                final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
                final amount = double.tryParse(cleanValue);
                if (amount == null || amount <= 0) {
                  return AppStrings.getValidAmountRequired(AppLocale.korea);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value:
                  _selectedUnitId.isNotEmpty &&
                      _availableUnits.any((unit) => unit.id == _selectedUnitId)
                  ? _selectedUnitId
                  : null,
              decoration: InputDecoration(
                labelText: AppStrings.getUnit(AppLocale.korea),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
                  return AppStrings.getUnitRequired(AppLocale.korea);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getTags(AppLocale.korea),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getSelectTagsDescription(AppLocale.korea),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
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
              backgroundColor: AppColors.surface,
              selectedColor: Color(
                int.parse(tag.color.replaceAll('#', '0xFF')),
              ),
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpiryDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getExpiryDate(AppLocale.korea),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getExpiryDateDescription(AppLocale.korea),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectExpiryDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _expiryDate != null
                        ? AppStrings.formatDate(_expiryDate!, AppLocale.korea)
                        : AppStrings.getSelectExpiryDate(AppLocale.korea),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _expiryDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
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
                    icon: const Icon(Icons.clear, size: 20),
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: AppStrings.getUpdateIngredient(AppLocale.korea),
        type: AppButtonType.primary,
        size: AppButtonSize.large,
        onPressed: _updateIngredient,
      ),
    );
  }

  void _selectExpiryDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.buttonText,
              surface: AppColors.surface,
            ),
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

  // 포맷팅된 가격 파싱
  double? _parseFormattedPrice(String value) {
    final numbers = value.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(numbers);
  }

  // 포맷팅된 수량 파싱
  double? _parseFormattedAmount(String value) {
    final numbers = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(numbers);
  }

  void _updateIngredient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUnitId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getUnitRequired(AppLocale.korea)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedIngredient = widget.ingredient.copyWith(
        name: _nameController.text.trim(),
        purchasePrice: _parseFormattedPrice(_priceController.text) ?? 0.0,
        purchaseAmount: _parseFormattedAmount(_amountController.text) ?? 0.0,
        purchaseUnitId: _selectedUnitId,
        expiryDate: _expiryDate,
        tagIds: _selectedTagId.isNotEmpty ? [_selectedTagId] : [],
      );

      context.read<IngredientCubit>().updateIngredient(updatedIngredient);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.getIngredientUpdatedSuccessfully(AppLocale.korea),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppStrings.getIngredientUpdateFailed(AppLocale.korea),
            ),
            backgroundColor: AppColors.error,
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
