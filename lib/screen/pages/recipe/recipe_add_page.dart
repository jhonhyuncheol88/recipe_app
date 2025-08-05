import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';
import '../../../util/date_formatter.dart';

import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';

import '../../../model/recipe.dart';
import '../../../model/ingredient.dart';
import '../../../model/tag.dart';
import '../../../model/unit.dart';
import '../../../model/recipe_ingredient.dart';
import 'package:uuid/uuid.dart';
import '../../widget/index.dart';

/// 레시피 추가 페이지
class RecipeAddPage extends StatefulWidget {
  final List<Ingredient>? selectedIngredients;

  const RecipeAddPage({super.key, this.selectedIngredients});

  @override
  State<RecipeAddPage> createState() => _RecipeAddPageState();
}

class _RecipeAddPageState extends State<RecipeAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedTagId = '';
  List<Tag> _availableTags = [];
  List<Unit> _availableUnits = [];
  List<Ingredient> _selectedIngredients = [];
  List<Ingredient> _availableIngredients = [];
  Map<String, double> _ingredientAmounts = {}; // 재료별 투입량
  Map<String, double> _ingredientCosts = {}; // 재료별 원가
  Map<String, TextEditingController> _amountControllers = {}; // 투입량 컨트롤러
  double _totalCost = 0.0; // 총 원가
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _loadTags();
    _loadUnits();
    _loadIngredients();

    // 선택된 재료가 있다면 추가
    if (widget.selectedIngredients != null) {
      _selectedIngredients = List.from(widget.selectedIngredients!);
    }
  }

  void _loadTags() {
    // TODO: TagCubit에서 태그 목록 가져오기
    setState(() {
      _availableTags = DefaultTags.recipeTags;
    });
  }

  void _loadUnits() {
    // TODO: UnitRepository에서 단위 목록 가져오기
    setState(() {
      _availableUnits = [
        Unit(id: '개', name: '개', type: 'count', conversionFactor: 1.0),
        Unit(id: '인분', name: '인분', type: 'count', conversionFactor: 1.0),
        Unit(id: '조각', name: '조각', type: 'count', conversionFactor: 1.0),
        Unit(id: 'g', name: 'g', type: 'weight', conversionFactor: 1.0),
        Unit(id: 'kg', name: 'kg', type: 'weight', conversionFactor: 1000.0),
        Unit(id: 'ml', name: 'ml', type: 'volume', conversionFactor: 1.0),
        Unit(id: 'L', name: 'L', type: 'volume', conversionFactor: 1000.0),
      ];
    });
  }

  void _loadIngredients() {
    // IngredientCubit에서 실제 재료 목록 가져오기
    final currentState = context.read<IngredientCubit>().state;
    if (currentState is IngredientLoaded) {
      setState(() {
        _availableIngredients = currentState.ingredients;
      });
    } else {
      // 임시 데이터 (Cubit이 로드되지 않은 경우)
      setState(() {
        _availableIngredients = [
          Ingredient(
            id: '1',
            name: '밀가루',
            purchasePrice: 5000.0,
            purchaseAmount: 1000.0,
            purchaseUnitId: 'g',
            expiryDate: DateTime.now().add(const Duration(days: 30)),
            createdAt: DateTime.now(),
            tagIds: ['baking'],
          ),
          Ingredient(
            id: '2',
            name: '버터',
            purchasePrice: 8000.0,
            purchaseAmount: 500.0,
            purchaseUnitId: 'g',
            expiryDate: DateTime.now().add(const Duration(days: 14)),
            createdAt: DateTime.now(),
            tagIds: ['dairy'],
          ),
          Ingredient(
            id: '3',
            name: '계란',
            purchasePrice: 3000.0,
            purchaseAmount: 30.0,
            purchaseUnitId: '개',
            expiryDate: DateTime.now().add(const Duration(days: 7)),
            createdAt: DateTime.now(),
            tagIds: ['dairy'],
          ),
          Ingredient(
            id: '4',
            name: '우유',
            purchasePrice: 2500.0,
            purchaseAmount: 1000.0,
            purchaseUnitId: 'ml',
            expiryDate: DateTime.now().add(const Duration(days: 5)),
            createdAt: DateTime.now(),
            tagIds: ['dairy'],
          ),
          Ingredient(
            id: '5',
            name: '설탕',
            purchasePrice: 2000.0,
            purchaseAmount: 1000.0,
            purchaseUnitId: 'g',
            expiryDate: DateTime.now().add(const Duration(days: 365)),
            createdAt: DateTime.now(),
            tagIds: ['baking'],
          ),
        ];
      });
    }
  }

  // 1g당(또는 개당) 재료 가격 계산
  double _calculateUnitPrice(Ingredient ingredient) {
    return ingredient.purchasePrice / ingredient.purchaseAmount;
  }

  // 재료별 원가 계산
  void _calculateIngredientCost(String ingredientId, double amount) {
    final ingredient = _selectedIngredients.firstWhere(
      (i) => i.id == ingredientId,
    );
    final unitPrice = _calculateUnitPrice(ingredient);
    final cost = unitPrice * amount;

    setState(() {
      _ingredientAmounts[ingredientId] = amount;
      _ingredientCosts[ingredientId] = cost;
      _calculateTotalCost();
    });
  }

  // 총 원가 계산
  void _calculateTotalCost() {
    _totalCost = _ingredientCosts.values.fold(0.0, (sum, cost) => sum + cost);
  }

  // 숫자 포맷팅 (천 단위 콤마)
  String _formatNumber(double number) {
    return number.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]},',
    );
  }

  // 텍스트 필드에서 숫자 추출
  int _extractNumberFromText(String text) {
    final cleanText = text.replaceAll(',', '');
    return int.tryParse(cleanText) ?? 0;
  }

  // 투입량 컨트롤러 가져오기 또는 생성
  TextEditingController _getAmountController(String ingredientId) {
    if (!_amountControllers.containsKey(ingredientId)) {
      final amount = _ingredientAmounts[ingredientId] ?? 0.0;
      _amountControllers[ingredientId] = TextEditingController(
        text: amount > 0
            ? NumberFormatter.formatNumber(amount.toInt(), AppLocale.korea)
            : '',
      );
    }
    return _amountControllers[ingredientId]!;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    // 모든 투입량 컨트롤러 해제
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getAddRecipe(AppLocale.korea),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveRecipe,
            child: Text(
              AppStrings.getSave(AppLocale.korea),
              style: AppTextStyles.buttonMedium.copyWith(
                color: _isLoading ? AppColors.textLight : AppColors.accent,
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
                    _buildIngredientsSection(),
                    const SizedBox(height: 24),
                    _buildTagsSection(),
                    const SizedBox(height: 24),
                    _buildCostSection(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getBasicInfo(AppLocale.korea),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AppInputField(
            label: AppStrings.getRecipeName(AppLocale.korea),
            hint: AppStrings.getRecipeNameHint(AppLocale.korea),
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.getRecipeNameRequired(AppLocale.korea);
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppInputField(
            label: AppStrings.getRecipeDescription(AppLocale.korea),
            hint: AppStrings.getRecipeDescriptionHint(AppLocale.korea),
            controller: _descriptionController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.getRecipeIngredients(AppLocale.korea),
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add, size: 16),
                label: Text(AppStrings.getAddIngredient(AppLocale.korea)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedIngredients.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getNoIngredientsSelected(AppLocale.korea),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = _selectedIngredients[index];
                final unitPrice = _calculateUnitPrice(ingredient);
                final amount = _ingredientAmounts[ingredient.id] ?? 0.0;
                final cost = _ingredientCosts[ingredient.id] ?? 0.0;
                final amountController = _getAmountController(ingredient.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ingredient.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '1${_getUnitName(ingredient.purchaseUnitId)}당 ${NumberFormatter.formatCurrency(unitPrice, AppLocale.korea)}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeIngredient(ingredient),
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            AppInputField(
                              label:
                                  '투입량 (${_getUnitName(ingredient.purchaseUnitId)})',
                              hint: '0',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                ThousandsSeparatorInputFormatter(),
                              ],
                              controller: amountController,
                              onChanged: (value) {
                                final newAmount = _extractNumberFromText(
                                  value,
                                ).toDouble();
                                _calculateIngredientCost(
                                  ingredient.id,
                                  newAmount,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '원가',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    NumberFormatter.formatCurrency(
                                      cost,
                                      AppLocale.korea,
                                    ),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getRecipeTags(AppLocale.korea),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTagId == tag.id;
                return FilterChip(
                  label: Text(tag.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTagId = selected ? tag.id : '';
                    });
                  },
                  selectedColor: AppColors.accent.withOpacity(0.2),
                  checkmarkColor: AppColors.accent,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getCostInfo(AppLocale.korea),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 원가',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      NumberFormatter.formatCurrency(
                        _totalCost,
                        AppLocale.korea,
                      ),
                      style: AppTextStyles.headline4.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: AppStrings.getSaveRecipe(AppLocale.korea),
        type: AppButtonType.primary,
        size: AppButtonSize.large,
        isFullWidth: true,
        onPressed: _saveRecipe,
        isLoading: _isLoading,
      ),
    );
  }

  String _getUnitName(String unitId) {
    final unit = _availableUnits.firstWhere(
      (unit) => unit.id == unitId,
      orElse: () =>
          Unit(id: unitId, name: unitId, type: 'count', conversionFactor: 1.0),
    );
    return unit.name;
  }

  void _addIngredient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getSelectIngredient(AppLocale.korea)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _availableIngredients.length,
            itemBuilder: (context, index) {
              final ingredient = _availableIngredients[index];
              final isSelected = _selectedIngredients.any(
                (i) => i.id == ingredient.id,
              );
              final unitPrice = _calculateUnitPrice(ingredient);

              return Hero(
                tag: 'ingredient_${ingredient.id}',
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withOpacity(0.1),
                      child: Text(
                        ingredient.name[0],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(
                      ingredient.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${NumberFormatter.formatCurrency(ingredient.purchasePrice, AppLocale.korea)} / ${_formatNumber(ingredient.purchaseAmount)} ${_getUnitName(ingredient.purchaseUnitId)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '1${_getUnitName(ingredient.purchaseUnitId)}당 ${NumberFormatter.formatCurrency(unitPrice, AppLocale.korea)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          )
                        : const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.textSecondary,
                          ),
                    onTap: () {
                      if (isSelected) {
                        setState(() {
                          _selectedIngredients.removeWhere(
                            (i) => i.id == ingredient.id,
                          );
                          _ingredientAmounts.remove(ingredient.id);
                          _ingredientCosts.remove(ingredient.id);
                          _calculateTotalCost();
                        });
                      } else {
                        setState(() {
                          _selectedIngredients.add(ingredient);
                        });
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(AppLocale.korea)),
          ),
        ],
      ),
    );
  }

  void _removeIngredient(Ingredient ingredient) {
    setState(() {
      _selectedIngredients.removeWhere((i) => i.id == ingredient.id);
      _ingredientAmounts.remove(ingredient.id);
      _ingredientCosts.remove(ingredient.id);
      _calculateTotalCost();

      // 컨트롤러도 제거
      if (_amountControllers.containsKey(ingredient.id)) {
        _amountControllers[ingredient.id]!.dispose();
        _amountControllers.remove(ingredient.id);
      }
    });
  }

  void _saveRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.getRecipeIngredientsRequired(AppLocale.korea),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 선택된 재료들을 RecipeIngredient로 변환
      final recipeIngredients = <RecipeIngredient>[];
      for (final ingredient in _selectedIngredients) {
        final amount = _ingredientAmounts[ingredient.id] ?? 0.0;
        if (amount > 0) {
          recipeIngredients.add(
            RecipeIngredient(
              id: const Uuid().v4(),
              recipeId: '', // 레시피 생성 후 설정됨
              ingredientId: ingredient.id,
              amount: amount,
              unitId: ingredient.purchaseUnitId,
              calculatedCost: _ingredientCosts[ingredient.id] ?? 0.0,
            ),
          );
        }
      }

      await context.read<RecipeCubit>().addRecipe(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        outputAmount: 1.0, // 기본값으로 1 설정
        outputUnit: '인분', // 기본값으로 인분 설정
        tagIds: _selectedTagId.isNotEmpty ? [_selectedTagId] : [],
        ingredients: recipeIngredients,
      );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getRecipeAdded(AppLocale.korea)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getRecipeAddError(AppLocale.korea)),
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
