import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/date_formatter.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';

import '../../../model/ingredient.dart';
import '../../../model/tag.dart';
import '../../../model/unit.dart';
import '../../widget/index.dart';
import '../../../controller/setting/locale_cubit.dart';

/// 재료 추가 페이지
class IngredientAddPage extends StatefulWidget {
  const IngredientAddPage({super.key});

  @override
  State<IngredientAddPage> createState() => _IngredientAddPageState();
}

class _IngredientAddPageState extends State<IngredientAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();

  // 포맷팅된 값 저장용 (미사용 필드 정리)

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
  }

  void _loadInitialData() {
    // TODO: 태그와 단위 목록 로드
    _loadTags();
    _loadUnits();
  }

  void _loadTags() {
    // TODO: TagCubit에서 태그 목록 가져오기
    final locale = context.read<LocaleCubit>().state;
    setState(() {
      _availableTags = DefaultTags.ingredientTagsFor(locale);
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
      if (_availableUnits.isNotEmpty) {
        _selectedUnitId = _availableUnits.first.id;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getAddIngredient(currentLocale),
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
            onPressed: _isLoading ? null : _saveIngredient,
            child: Text(
              AppStrings.getSave(currentLocale),
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
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getBasicInformation(currentLocale),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
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
          onChanged: (price) {
            // 가격이 변경될 때 처리
          },
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
              onChanged: (amount) {
                // 수량이 변경될 때 처리
              },
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
              decoration: InputDecoration(
                labelText: AppStrings.getUnit(currentLocale),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getTags(currentLocale),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getSelectTagsDescription(currentLocale),
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
    final currentLocale = context.watch<LocaleCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getExpiryDate(currentLocale),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getExpiryDateDescription(currentLocale),
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
                        ? DateFormatter.formatDate(_expiryDate!, currentLocale)
                        : AppStrings.getSelectExpiryDate(currentLocale),
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
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
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

  void _saveIngredient() async {
    final currentLocale = context.read<LocaleCubit>().state;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUnitId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getUnitRequired(currentLocale)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final ingredient = Ingredient(
        id: '', // Cubit에서 생성
        name: _nameController.text.trim(),
        purchasePrice: _parseFormattedPrice(_priceController.text) ?? 0.0,
        purchaseAmount: _parseFormattedAmount(_amountController.text) ?? 0.0,
        purchaseUnitId: _selectedUnitId,
        expiryDate: _expiryDate,
        createdAt: DateTime.now(),
        tagIds: _selectedTagId.isNotEmpty ? [_selectedTagId] : [],
      );

      context.read<IngredientCubit>().addIngredient(
        name: ingredient.name,
        purchasePrice: ingredient.purchasePrice,
        purchaseAmount: ingredient.purchaseAmount,
        purchaseUnitId: ingredient.purchaseUnitId,
        expiryDate: ingredient.expiryDate,
        tagIds: _selectedTagId.isNotEmpty ? [_selectedTagId] : [],
      );

      if (mounted) {
        context.pop();

        // 성공 메시지와 함께 레시피 생성 옵션 제공
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.getIngredientAddedSuccessfully(currentLocale),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 레시피 생성 페이지로 이동
                    context.push('/recipe/create');
                  },
                  child: Text(
                    AppStrings.getCreateRecipeFromIngredients(currentLocale),
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getIngredientAddFailed(currentLocale)),
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
