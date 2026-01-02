import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/date_formatter.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../model/tag.dart';
import '../../../model/unit.dart';
import '../../widget/index.dart';

/// 재료 일괄 추가 페이지
class IngredientBulkAddPage extends StatefulWidget {
  const IngredientBulkAddPage({super.key});

  @override
  State<IngredientBulkAddPage> createState() => _IngredientBulkAddPageState();
}

class _IngredientBulkAddPageState extends State<IngredientBulkAddPage> {
  final List<Map<String, Object?>> _ingredients = <Map<String, Object?>>[];
  final List<TextEditingController> _nameControllers =
      <TextEditingController>[];
  final List<TextEditingController> _priceControllers =
      <TextEditingController>[];
  final List<TextEditingController> _amountControllers =
      <TextEditingController>[];
  List<Tag> _availableTags = <Tag>[];
  List<Unit> _availableUnits = <Unit>[];
  bool _isLoading = false;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    // 전달받은 데이터가 있는지 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForPrefilledData();
    });

    // 전달받은 데이터가 없으면 기본 재료 하나 추가
    if (_ingredients.isEmpty) {
      _addIngredient();
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
    });
  }

  void _checkForPrefilledData() {
    // GoRouter의 extra 파라미터에서 데이터 확인
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    if (extra != null && extra['prefilledIngredients'] != null) {
      final prefilledIngredients =
          extra['prefilledIngredients'] as List<Map<String, dynamic>>;

      if (prefilledIngredients.isNotEmpty) {
        setState(() {
          // 기존 데이터 초기화
          _ingredients.clear();

          // 전달받은 데이터로 채우기
          for (final ingredientData in prefilledIngredients) {
            // amount와 unit이 있으면 사용, 없으면 기본값
            final amount = ingredientData['amount'];
            final unit = ingredientData['unit'] ?? '개';
            
            // amount를 숫자로 변환 시도
            double? parsedAmount;
            if (amount != null) {
              if (amount is num) {
                parsedAmount = amount.toDouble();
              } else if (amount is String) {
                parsedAmount = double.tryParse(amount);
              }
            }
            
            _ingredients.add({
              'name': ingredientData['name'] ?? '', // 이름
              'purchasePrice': 0.0, // 사용자가 입력할 수 있도록 0으로 설정
              'purchaseAmount': parsedAmount ?? 0.0, // 전달받은 수량 또는 0
              'purchaseUnitId': unit, // 전달받은 단위 또는 기본값
              'expiryDate': null, // 사용자가 선택할 수 있도록 null로 설정
              'tagIds': <String>[], // 사용자가 선택할 수 있도록 빈 배열로 설정
            });
          }

          // 각 재료에 대한 컨트롤러 생성
          _nameControllers.clear();
          _priceControllers.clear();
          _amountControllers.clear();

          for (int i = 0; i < _ingredients.length; i++) {
            final ingredient = _ingredients[i];
            // 이름 미리 채우기
            _nameControllers.add(
              TextEditingController(text: ingredient['name']?.toString() ?? ''),
            );
            // 가격은 빈 값으로 시작
            _priceControllers.add(TextEditingController());
            // 수량은 전달받은 값이 있으면 채우기
            final amount = ingredient['purchaseAmount'] as double?;
            _amountControllers.add(
              TextEditingController(
                text: amount != null && amount > 0 ? amount.toString() : '',
              ),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // 모든 컨트롤러 정리
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    for (final controller in _priceControllers) {
      controller.dispose();
    }
    for (final controller in _amountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredients.add({
        'name': '',
        'purchasePrice': 0.0,
        'purchaseAmount': 0.0,
        'purchaseUnitId': _availableUnits.isNotEmpty
            ? _availableUnits.first.id
            : '',
        'expiryDate': null,
        'tagIds': <String>[],
      });

      // 컨트롤러 추가
      _nameControllers.add(TextEditingController());
      _priceControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      // 컨트롤러도 제거
      _nameControllers[index].dispose();
      _priceControllers[index].dispose();
      _amountControllers[index].dispose();
      _nameControllers.removeAt(index);
      _priceControllers.removeAt(index);
      _amountControllers.removeAt(index);
    });
  }

  void _updateIngredient(int index, Object field, Object? value) {
    setState(() {
      _ingredients[index] = {..._ingredients[index], field.toString(): value};
    });
  }

  void _toggleTag(int ingredientIndex, String tagId) {
    setState(() {
      final currentTags = List<String>.from(
        (_ingredients[ingredientIndex]['tagIds'] as List<dynamic>?) ??
            <dynamic>[],
      );
      if (currentTags.contains(tagId)) {
        // 이미 선택된 태그라면 제거
        currentTags.remove(tagId);
      } else {
        // 새로운 태그를 선택하면 기존 태그를 모두 제거하고 새 태그만 추가
        currentTags.clear();
        currentTags.add(tagId);
      }
      _ingredients[ingredientIndex]['tagIds'] = currentTags;
    });
  }

  bool _validateIngredients() {
    for (int i = 0; i < _ingredients.length; i++) {
      final ingredient = _ingredients[i];
      if (ingredient['name'].toString().trim().isEmpty) {
        _showValidationError('재료명', i);
        return false;
      }
      final price = (ingredient['purchasePrice'] as num?)?.toDouble() ?? 0.0;
      if (price <= 0.0) {
        _showValidationError('구매 가격', i);
        return false;
      }
      final amount = (ingredient['purchaseAmount'] as num?)?.toDouble() ?? 0.0;
      if (amount <= 0.0) {
        _showValidationError('구매 수량', i);
        return false;
      }
      if (ingredient['purchaseUnitId'].toString().isEmpty) {
        _showValidationError('단위', i);
        return false;
      }
    }
    return true;
  }

  void _showValidationError(String fieldName, int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${index + 1}번째 재료의 $fieldName을(를) 확인해주세요'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _saveIngredients() async {
    if (!_validateIngredients()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cubit = context.read<IngredientCubit>();
      int successCount = 0;

      for (final ingredientData in _ingredients) {
        try {
          await cubit.addIngredient(
            name: ingredientData['name'].toString().trim(),
            purchasePrice: (ingredientData['purchasePrice'] as num).toDouble(),
            purchaseAmount: (ingredientData['purchaseAmount'] as num)
                .toDouble(),
            purchaseUnitId: ingredientData['purchaseUnitId'].toString(),
            expiryDate: ingredientData['expiryDate'] as DateTime?,
            tagIds: List<String>.from(
              ingredientData['tagIds'] as List<dynamic>,
            ),
          );
          successCount++;
        } catch (e) {
          print('재료 추가 실패: ${ingredientData['name']} - $e');
        }
      }

      if (mounted) {
        final currentLocale = context.read<LocaleCubit>().state;
        if (successCount > 0) {
          context.pop();
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.getBulkSaveFailed(currentLocale)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final currentLocale = context.read<LocaleCubit>().state;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getBulkSaveFailed(currentLocale)),
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

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getBulkAddIngredients(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _ingredients.isNotEmpty ? _saveIngredients : null,
              child: Text(
                AppStrings.getBulkSave(currentLocale),
                style: AppTextStyles.buttonMedium.copyWith(
                  color: _ingredients.isNotEmpty
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(currentLocale),
                Expanded(
                  child: _ingredients.isEmpty
                      ? _buildEmptyState(currentLocale)
                      : _buildIngredientList(currentLocale),
                ),
                _buildBottomActions(currentLocale),
              ],
            ),
    );
  }

  Widget _buildHeader(AppLocale currentLocale) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getBulkAddIngredientsDescription(currentLocale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.getIngredientCount(
                  currentLocale,
                  _ingredients.length,
                ),
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                    tooltip: AppStrings.getAddIngredientToList(currentLocale),
                  ),
                  if (_ingredients.isNotEmpty)
                    IconButton(
                      onPressed: () =>
                          setState(() => _showPreview = !_showPreview),
                      icon: Icon(_showPreview ? Icons.list : Icons.preview),
                      color: AppColors.primary,
                      tooltip: AppStrings.getPreview(currentLocale),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocale currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getNoIngredients(currentLocale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getNoIngredientsDescription(currentLocale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: AppStrings.getAddIngredientToList(currentLocale),
            type: AppButtonType.primary,
            onPressed: _addIngredient,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientList(AppLocale currentLocale) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = _ingredients[index];
        return _buildIngredientCard(currentLocale, ingredient, index);
      },
    );
  }

  Widget _buildIngredientCard(
    AppLocale currentLocale,
    Map<String, dynamic> ingredient,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${index + 1}번째 재료',
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeIngredient(index),
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.error,
                  tooltip: AppStrings.getRemoveIngredient(currentLocale),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildIngredientForm(currentLocale, ingredient, index),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientForm(
    AppLocale currentLocale,
    Map<String, dynamic> ingredient,
    int index,
  ) {
    return Column(
      children: [
        // 재료명
        AppInputField(
          controller: _nameControllers[index],
          label: AppStrings.getIngredientName(currentLocale),
          hint: AppStrings.getEnterIngredientNameHint(currentLocale),
          onChanged: (value) => _updateIngredient(index, 'name', value),
        ),
        const SizedBox(height: 16),

        // 가격과 수량을 한 줄에
        Row(
          children: [
            Expanded(
              child: CurrencyInputField(
                controller: _priceControllers[index],
                label: AppStrings.getPurchasePrice(currentLocale),
                hint: AppStrings.getEnterPriceHint(currentLocale),
                locale: currentLocale,
                onChanged: (value) {
                  final price = _parseFormattedPrice(value.toString());
                  if (price != null) {
                    _updateIngredient(index, 'purchasePrice', price);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: NumberInputField(
                controller: _amountControllers[index],
                label: AppStrings.getPurchaseAmount(currentLocale),
                hint: AppStrings.getEnterAmountHint(currentLocale),
                onChanged: (value) {
                  final amount = _parseFormattedAmount(value.toString());
                  if (amount != null) {
                    _updateIngredient(index, 'purchaseAmount', amount);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 단위 선택
        DropdownButtonFormField<String>(
          value: ingredient['purchaseUnitId'].isNotEmpty
              ? ingredient['purchaseUnitId']
              : null,
          decoration: InputDecoration(
            labelText: AppStrings.getUnit(currentLocale),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: _availableUnits.map((unit) {
            return DropdownMenuItem(value: unit.id, child: Text(unit.name));
          }).toList(),
          onChanged: (value) {
            _updateIngredient(index, 'purchaseUnitId', value ?? '');
          },
        ),
        const SizedBox(height: 16),

        // 유통기한
        InkWell(
          onTap: () => _selectExpiryDate(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
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
                    ingredient['expiryDate'] != null
                        ? DateFormatter.formatDate(
                            ingredient['expiryDate'],
                            currentLocale,
                          )
                        : AppStrings.getSelectExpiryDate(currentLocale),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: ingredient['expiryDate'] != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (ingredient['expiryDate'] != null)
                  IconButton(
                    onPressed: () {
                      _updateIngredient(index, 'expiryDate', null);
                    },
                    icon: const Icon(Icons.clear, size: 20),
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 태그 선택
        Text(
          '${AppStrings.getTags(currentLocale)} (하나만 선택)',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = ingredient['tagIds'].contains(tag.id);
            return FilterChip(
              label: Text(tag.name),
              selected: isSelected,
              onSelected: (selected) => _toggleTag(index, tag.id),
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

  Widget _buildBottomActions(AppLocale currentLocale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: AppStrings.getAddIngredientToList(currentLocale),
              type: AppButtonType.secondary,
              onPressed: _addIngredient,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: _isLoading
                  ? AppStrings.getSaving(currentLocale)
                  : AppStrings.getBulkSave(currentLocale),
              type: AppButtonType.primary,
              onPressed: _ingredients.isNotEmpty && !_isLoading
                  ? _saveIngredients
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _selectExpiryDate(int index) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate:
          (_ingredients[index]['expiryDate'] as DateTime?) ??
          now.add(const Duration(days: 7)),
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
      _updateIngredient(index, 'expiryDate', selectedDate);
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
}
