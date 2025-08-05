import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';

import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';

import '../../../model/recipe.dart';
import '../../../model/ingredient.dart';
import '../../../model/tag.dart';
import '../../../model/unit.dart';
import '../../widget/index.dart';

/// 레시피 수정 페이지
class RecipeEditPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeEditPage({super.key, required this.recipe});

  @override
  State<RecipeEditPage> createState() => _RecipeEditPageState();
}

class _RecipeEditPageState extends State<RecipeEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  String _selectedTagId = '';
  List<Tag> _availableTags = [];
  List<Unit> _availableUnits = [];
  List<Ingredient> _selectedIngredients = [];
  List<Ingredient> _availableIngredients = [];
  Map<String, double> _ingredientAmounts = {}; // 재료별 투입량
  Map<String, double> _ingredientCosts = {}; // 재료별 원가
  double _totalCost = 0.0; // 총 원가
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.recipe.name);
    _descriptionController = TextEditingController(
      text: widget.recipe.description,
    );
    _selectedTagId = widget.recipe.tagIds.isNotEmpty
        ? widget.recipe.tagIds.first
        : '';

    // TODO: 레시피 재료들을 Ingredient 객체로 변환
    _selectedIngredients = [];
  }

  void _loadInitialData() {
    _loadTags();
    _loadUnits();
    _loadIngredients();
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

  // 텍스트에서 숫자 추출 (천 단위 구분자 제거)
  int _extractNumberFromText(String text) {
    final cleanText = text.replaceAll(',', '');
    return int.tryParse(cleanText) ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getEditRecipe(AppLocale.korea),
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

                return Hero(
                  tag: 'ingredient_${ingredient.id}',
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.accent.withOpacity(
                                  0.1,
                                ),
                                child: Text(
                                  ingredient.name[0],
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                onPressed: () => _editIngredient(ingredient),
                                icon: const Icon(
                                  Icons.edit,
                                  color: AppColors.accent,
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
                          Row(
                            children: [
                              Expanded(
                                child: AppInputField(
                                  label:
                                      '투입량 (${_getUnitName(ingredient.purchaseUnitId)})',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    ThousandsSeparatorInputFormatter(),
                                  ],
                                  initialValue: amount > 0
                                      ? NumberFormatter.formatNumber(
                                          amount.toInt(),
                                          AppLocale.korea,
                                        )
                                      : null,
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
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.divider,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.accent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  void _editIngredient(Ingredient ingredient) {
    final currentAmount = _ingredientAmounts[ingredient.id] ?? 0.0;
    final unitPrice = _calculateUnitPrice(ingredient);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getEditIngredientAmount(AppLocale.korea)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'ingredient_${ingredient.id}',
              child: Material(
                color: Colors.transparent,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.accent.withOpacity(0.1),
                      child: Text(
                        ingredient.name[0],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppInputField(
              label: '투입량 (${_getUnitName(ingredient.purchaseUnitId)})',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              initialValue: currentAmount > 0
                  ? NumberFormatter.formatNumber(
                      currentAmount.toInt(),
                      AppLocale.korea,
                    )
                  : null,
              onChanged: (value) {
                final newAmount = _extractNumberFromText(value).toDouble();
                _calculateIngredientCost(ingredient.id, newAmount);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '계산된 원가',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    NumberFormatter.formatCurrency(
                      _ingredientCosts[ingredient.id] ?? 0.0,
                      AppLocale.korea,
                    ),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(AppLocale.korea)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppStrings.getSave(AppLocale.korea)),
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
      final updatedRecipe = widget.recipe.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        outputAmount: widget.recipe.outputAmount, // 기존 값 유지
        outputUnit: widget.recipe.outputUnit, // 기존 값 유지
        tagIds: _selectedTagId.isNotEmpty ? [_selectedTagId] : [],
        updatedAt: DateTime.now(),
      );

      await context.read<RecipeCubit>().updateRecipe(updatedRecipe);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getRecipeUpdated(AppLocale.korea)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getRecipeUpdateError(AppLocale.korea)),
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
