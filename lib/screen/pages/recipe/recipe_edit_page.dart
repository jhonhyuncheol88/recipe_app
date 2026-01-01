import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_formatter.dart';

import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/recipe/recipe_cubit.dart' as rc;

import '../../../model/recipe.dart';
import '../../../model/ingredient.dart';
import '../../../model/index.dart';
import '../../../model/tag.dart';
import '../../../model/unit.dart';
import 'package:uuid/uuid.dart';
import '../../widget/index.dart';
import '../../../data/index.dart';
import '../../../service/sauce_cost_service.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';

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
  Map<String, String> _ingredientUnitIds = {}; // 재료별 선택 단위
  double _totalCost = 0.0; // 총 원가
  bool _isLoading = false;
  final Map<String, TextEditingController> _sauceAmountControllers = {};

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
    _selectedTagId =
        widget.recipe.tagIds.isNotEmpty ? widget.recipe.tagIds.first : '';

    // 레시피 재료들을 초기화
    _selectedIngredients = [];
    _ingredientAmounts = {};
    _ingredientUnitIds = {};
    _ingredientCosts = {};

    // 기존 재료 정보 복원
    for (final ri in widget.recipe.ingredients) {
      _ingredientAmounts[ri.ingredientId] = ri.amount;
      _ingredientUnitIds[ri.ingredientId] = ri.unitId;
      _ingredientCosts[ri.ingredientId] = ri.calculatedCost;
    }
  }

  void _loadInitialData() {
    _loadTags();
    _loadUnits();
    _loadIngredients();
  }

  void _loadTags() {
    // TODO: TagCubit에서 태그 목록 가져오기
    final locale = context.read<LocaleCubit>().state;
    setState(() {
      _availableTags = DefaultTags.recipeTagsFor(locale);
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

  void _loadIngredients() async {
    // IngredientCubit에서 실제 재료 목록 가져오기
    final currentState = context.read<IngredientCubit>().state;
    if (currentState is IngredientLoaded) {
      final available = currentState.ingredients;
      List<Ingredient> selected = _selectedIngredients;
      final Map<String, double> amounts = {..._ingredientAmounts};
      final Map<String, String> unitIds = {..._ingredientUnitIds};
      final Map<String, double> costs = {..._ingredientCosts};

      if (selected.isEmpty && widget.recipe.ingredients.isNotEmpty) {
        selected = [];
        for (final ri in widget.recipe.ingredients) {
          Ingredient ing;
          try {
            ing = available.firstWhere((i) => i.id == ri.ingredientId);
          } catch (_) {
            // 폴백: 저장소에서 직접 조회하여 실제 이름을 사용
            final repo = context.read<IngredientRepository>();
            final fetched = await repo.getIngredientById(ri.ingredientId);
            ing = fetched ??
                Ingredient(
                  id: ri.ingredientId,
                  name: '재료',
                  purchasePrice: 0,
                  purchaseAmount: 1,
                  purchaseUnitId: ri.unitId,
                  createdAt: DateTime.now(),
                );
          }
          selected.add(ing);
          amounts[ri.ingredientId] = ri.amount;
          unitIds[ri.ingredientId] = ri.unitId;
          costs[ri.ingredientId] = ri.calculatedCost;
        }
      }

      setState(() {
        _availableIngredients = available;
        _selectedIngredients = selected;
        _ingredientAmounts = amounts;
        _ingredientUnitIds = unitIds;
        _ingredientCosts = costs;
        _calculateTotalCost();
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
      // 임시 데이터에서도 레시피 재료 복원 시도
      if (_selectedIngredients.isEmpty &&
          widget.recipe.ingredients.isNotEmpty) {
        final List<Ingredient> selected = [];
        for (final ri in widget.recipe.ingredients) {
          Ingredient ing;
          try {
            ing = _availableIngredients.firstWhere(
              (i) => i.id == ri.ingredientId,
            );
          } catch (_) {
            ing = Ingredient(
              id: ri.ingredientId,
              name: '재료(${ri.ingredientId})',
              purchasePrice: 0,
              purchaseAmount: 1,
              purchaseUnitId: ri.unitId,
              createdAt: DateTime.now(),
            );
          }
          selected.add(ing);
          _ingredientAmounts[ri.ingredientId] = ri.amount;
          _ingredientUnitIds[ri.ingredientId] = ri.unitId;
          _ingredientCosts[ri.ingredientId] = ri.calculatedCost;
        }
        _selectedIngredients = selected;
        _calculateTotalCost();
      }
    }
  }

  // 1g당(또는 개당) 재료 가격 계산
  double _calculateUnitPrice(Ingredient ingredient) {
    return ingredient.purchasePrice / ingredient.purchaseAmount;
  }

  // 재료별 원가 계산 (기본 단위로 환산하여 계산)
  void _calculateIngredientCost(String ingredientId, double amount) {
    final ingredient = _selectedIngredients.firstWhere(
      (i) => i.id == ingredientId,
    );
    // 구매 기준 → 기본단위(g/ml/개) 단가
    final purchaseBase = uc.UnitConverter.toBaseUnit(
      ingredient.purchaseAmount,
      ingredient.purchaseUnitId,
    );
    final baseUnitPrice =
        purchaseBase > 0 ? ingredient.purchasePrice / purchaseBase : 0.0;
    // 입력 단위 사용량을 기본단위로 환산
    final selectedUnitId =
        _ingredientUnitIds[ingredientId] ?? ingredient.purchaseUnitId;
    final baseUsage = uc.UnitConverter.toBaseUnit(amount, selectedUnitId);
    final cost = baseUnitPrice * baseUsage;

    setState(() {
      _ingredientAmounts[ingredientId] = amount;
      _ingredientCosts[ingredientId] = cost;
      _ingredientUnitIds[ingredientId] = selectedUnitId;
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
    final currentLocale = context.watch<LocaleCubit>().state;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getEditRecipe(currentLocale),
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
            onPressed: _isLoading
                ? null
                : () {
                    _saveRecipe();
                    // _saveRecipe 내부에서 성공 시 뒤로가기 처리됨
                  },
            child: Text(
              AppStrings.getSave(currentLocale),
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
                    _buildSaucesSection(),
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
    final currentLocale = context.watch<LocaleCubit>().state;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getBasicInfo(currentLocale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AppInputField(
            label: AppStrings.getRecipeName(currentLocale),
            hint: AppStrings.getRecipeNameHint(currentLocale),
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.getRecipeNameRequired(currentLocale);
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppInputField(
            label: AppStrings.getRecipeDescription(currentLocale),
            hint: AppStrings.getRecipeDescriptionHint(currentLocale),
            controller: _descriptionController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.getRecipeIngredients(currentLocale),
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addIngredient,
                icon: const Icon(Icons.add, size: 16),
                label: Text(AppStrings.getAddIngredient(currentLocale)),
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
                    AppStrings.getNoIngredientsSelected(currentLocale),
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
                // 저장된 레시피의 단위를 우선 사용하고, 없으면 구매단위 사용
                final recipeEntry = widget.recipe.ingredients.firstWhere(
                  (ri) => ri.ingredientId == ingredient.id,
                  orElse: () => RecipeIngredient(
                    id: '',
                    recipeId: widget.recipe.id,
                    ingredientId: ingredient.id,
                    amount: 0,
                    unitId: ingredient.purchaseUnitId,
                    calculatedCost: 0,
                  ),
                );
                final unitId =
                    _ingredientUnitIds[ingredient.id] ?? recipeEntry.unitId;
                if (!_ingredientUnitIds.containsKey(ingredient.id)) {
                  _ingredientUnitIds[ingredient.id] = unitId;
                }
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
                                      '1${_getUnitName(ingredient.purchaseUnitId)}당 ${NumberFormatter.formatCurrency(unitPrice, currentLocale, context.watch<NumberFormatCubit>().state)}',
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButton<String>(
                                value: unitId,
                                items: [
                                  if (uc.UnitConverter.getUnitType(
                                        ingredient.purchaseUnitId,
                                      ) ==
                                      uc.UnitType.weight)
                                    const DropdownMenuItem(
                                      value: 'g',
                                      child: Text('g'),
                                    ),
                                  if (uc.UnitConverter.getUnitType(
                                        ingredient.purchaseUnitId,
                                      ) ==
                                      uc.UnitType.weight)
                                    const DropdownMenuItem(
                                      value: 'kg',
                                      child: Text('kg'),
                                    ),
                                  if (uc.UnitConverter.getUnitType(
                                        ingredient.purchaseUnitId,
                                      ) ==
                                      uc.UnitType.volume)
                                    const DropdownMenuItem(
                                      value: 'ml',
                                      child: Text('ml'),
                                    ),
                                  if (uc.UnitConverter.getUnitType(
                                        ingredient.purchaseUnitId,
                                      ) ==
                                      uc.UnitType.volume)
                                    const DropdownMenuItem(
                                      value: 'L',
                                      child: Text('L'),
                                    ),
                                  if (uc.UnitConverter.getUnitType(
                                        ingredient.purchaseUnitId,
                                      ) ==
                                      uc.UnitType.count)
                                    const DropdownMenuItem(
                                      value: '개',
                                      child: Text('개'),
                                    ),
                                ],
                                onChanged: (v) async {
                                  if (v == null) return;
                                  final prevUnitId =
                                      _ingredientUnitIds[ingredient.id] ??
                                          ingredient.purchaseUnitId;
                                  final currentAmount =
                                      _ingredientAmounts[ingredient.id] ?? 0.0;
                                  final baseUsage = uc.UnitConverter.toBaseUnit(
                                    currentAmount,
                                    prevUnitId,
                                  );
                                  final converted =
                                      uc.UnitConverter.fromBaseUnit(
                                          baseUsage, v);
                                  setState(() {
                                    _ingredientUnitIds[ingredient.id] = v;
                                    _ingredientAmounts[ingredient.id] =
                                        converted;
                                  });
                                  _calculateIngredientCost(
                                    ingredient.id,
                                    converted,
                                  );
                                  await context
                                      .read<rc.RecipeCubit>()
                                      .updateRecipeIngredientUnitAndAmount(
                                        recipeId: widget.recipe.id,
                                        ingredientId: ingredient.id,
                                        newUnitId: v,
                                        newAmount: converted,
                                      );
                                },
                              ),
                              const SizedBox(height: 8),
                              AppInputField(
                                label: AppStrings.getInputAmount(currentLocale),
                                hint: '0',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  ThousandsSeparatorInputFormatter(),
                                ],
                                initialValue: amount > 0
                                    ? NumberFormatter.formatNumber(
                                        amount.toInt(),
                                        context
                                            .watch<NumberFormatCubit>()
                                            .state,
                                      )
                                    : null,
                                onChanged: (value) async {
                                  final newAmount = _extractNumberFromText(
                                    value,
                                  ).toDouble();
                                  _calculateIngredientCost(
                                    ingredient.id,
                                    newAmount,
                                  );
                                  final unitForIngredient =
                                      _ingredientUnitIds[ingredient.id] ??
                                          ingredient.purchaseUnitId;
                                  await context
                                      .read<rc.RecipeCubit>()
                                      .updateRecipeIngredientUnitAndAmount(
                                        recipeId: widget.recipe.id,
                                        ingredientId: ingredient.id,
                                        newUnitId: unitForIngredient,
                                        newAmount: newAmount,
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
                                      AppStrings.getCost(currentLocale),
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        NumberFormatter.formatCurrency(
                                          cost,
                                          currentLocale,
                                          context
                                              .watch<NumberFormatCubit>()
                                              .state,
                                        ),
                                        style: AppTextStyles
                                            .costEmphasized, // 크고 굵은 오렌지색
                                        textAlign: TextAlign.left,
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
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSaucesSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.getSauces(currentLocale),
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addSauce,
                icon: const Icon(Icons.add, size: 16),
                label: Text(AppStrings.getAddSauce(currentLocale)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<_RecipeSauceDisplay>>(
            future: _fetchRecipeSauceDisplays(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <_RecipeSauceDisplay>[];
              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppStrings.getNoRecipeSauces(currentLocale),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final display = items[index];
                  final entry = display.entry;
                  final controller = _sauceAmountControllers.putIfAbsent(
                    entry.sauceId,
                    () => TextEditingController(
                      text: entry.amount > 0
                          ? NumberFormatter.formatNumber(
                              entry.amount.toInt(),
                              context.watch<NumberFormatCubit>().state,
                            )
                          : '',
                    ),
                  );
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
                                      display.sauceName,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    FutureBuilder<SauceAggregation>(
                                      future: context
                                          .read<SauceCostService>()
                                          .aggregateSauce(entry.sauceId),
                                      builder: (context, snapAgg) {
                                        final agg = snapAgg.data;
                                        if (agg == null ||
                                            agg.totalBaseAmount <= 0) {
                                          return const SizedBox.shrink();
                                        }
                                        final unitCost =
                                            agg.totalCost / agg.totalBaseAmount;
                                        final unitId = agg.unitType ==
                                                uc.UnitType.weight
                                            ? 'g'
                                            : agg.unitType == uc.UnitType.volume
                                                ? 'ml'
                                                : '개';
                                        return Text(
                                          '1$unitId당 ${NumberFormatter.formatCurrency(unitCost, currentLocale, context.watch<NumberFormatCubit>().state)}',
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                ),
                                onPressed: () => _removeSauce(entry),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // 단위 선택 + 수량 입력
                              DropdownButton<String>(
                                value: entry.unitId,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'g',
                                    child: Text('g'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ml',
                                    child: Text('ml'),
                                  ),
                                  DropdownMenuItem(
                                    value: '개',
                                    child: Text('개'),
                                  ),
                                ],
                                onChanged: (v) async {
                                  if (v == null) return;
                                  // 현 입력값을 기존 단위에서 기본단위로 환산 후 새 단위로 변환
                                  final typed = controller.text;
                                  final clean = typed.replaceAll(
                                    RegExp(r'[^\\d]'),
                                    '',
                                  );
                                  final currentAmount =
                                      (double.tryParse(clean) ?? entry.amount)
                                          .toDouble();
                                  final baseUsage = uc.UnitConverter.toBaseUnit(
                                    currentAmount,
                                    entry.unitId,
                                  );
                                  final converted =
                                      uc.UnitConverter.fromBaseUnit(
                                          baseUsage, v);
                                  controller.text =
                                      NumberFormatter.formatNumber(
                                    converted.toInt(),
                                    context.watch<NumberFormatCubit>().state,
                                  );
                                  await context
                                      .read<rc.RecipeCubit>()
                                      .updateRecipeSauceUnit(
                                        recipeId: widget.recipe.id,
                                        sauceId: entry.sauceId,
                                        newUnitId: v,
                                      );
                                  await context
                                      .read<rc.RecipeCubit>()
                                      .updateRecipeSauceAmount(
                                        recipeId: widget.recipe.id,
                                        sauceId: entry.sauceId,
                                        newAmount: converted,
                                      );
                                  if (mounted) setState(() {});
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppInputField(
                                  label: AppStrings.getInputAmount(
                                    currentLocale,
                                  ),
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    ThousandsSeparatorInputFormatter(),
                                  ],
                                  controller: controller,
                                  onChanged: (value) async {
                                    final clean = value.replaceAll(
                                      RegExp(r'[^\d]'),
                                      '',
                                    );
                                    final newAmount =
                                        double.tryParse(clean) ?? 0;
                                    await context
                                        .read<rc.RecipeCubit>()
                                        .updateRecipeSauceAmount(
                                          recipeId: widget.recipe.id,
                                          sauceId: entry.sauceId,
                                          newAmount: newAmount,
                                        );
                                    if (mounted) setState(() {});
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
                                  child: FutureBuilder<double>(
                                    future: context
                                        .read<SauceCostService>()
                                        .getSauceUnitCost(entry.sauceId),
                                    builder: (context, snapUnit) {
                                      final unitCost = snapUnit.data ?? 0.0;
                                      final typed = controller.text;
                                      final clean = typed.replaceAll(
                                        RegExp(r'[^\d]'),
                                        '',
                                      );
                                      final amount = (double.tryParse(clean) ??
                                              entry.amount)
                                          .toDouble();
                                      final baseUsage =
                                          uc.UnitConverter.toBaseUnit(
                                        amount,
                                        entry.unitId,
                                      );
                                      final cost = unitCost * baseUsage;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.getCost(currentLocale),
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              NumberFormatter.formatCurrency(
                                                cost,
                                                currentLocale,
                                                context
                                                    .watch<NumberFormatCubit>()
                                                    .state,
                                              ),
                                              style: AppTextStyles
                                                  .costEmphasized, // 크고 굵은 오렌지색
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getRecipeTags(currentLocale),
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
                  color:
                      isSelected ? AppColors.accent : AppColors.textSecondary,
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
    final currentLocale = context
        .watch<LocaleCubit>()
        .state; // ignore: use_build_context_synchronously
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getCostInfo(currentLocale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<_RecipeSauceDisplay>>(
            future: _fetchRecipeSauceDisplays(),
            builder: (context, snapshot) {
              final sauceItems = snapshot.data ?? const <_RecipeSauceDisplay>[];
              final sauceSum = sauceItems.fold(0.0, (s, e) => s + e.cost);
              final ingredientSum = _totalCost;
              final total = ingredientSum + sauceSum;
              return Container(
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
                        Text(AppStrings.getIngredientCostLabel(currentLocale)),
                        Text(
                          NumberFormatter.formatCurrency(
                            ingredientSum,
                            currentLocale,
                            context.watch<NumberFormatCubit>().state,
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppStrings.getSauceCostLabel(currentLocale)),
                        Text(
                          NumberFormatter.formatCurrency(
                            sauceSum,
                            currentLocale,
                            context.watch<NumberFormatCubit>().state,
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.getTotalCost(currentLocale),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          NumberFormatter.formatCurrency(total, currentLocale,
                              context.watch<NumberFormatCubit>().state),
                          style: AppTextStyles.headline4.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final currentLocale = context.watch<LocaleCubit>().state;
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        text: AppStrings.getSaveRecipe(currentLocale),
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
    final currentLocale = context.read<LocaleCubit>().state;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getSelectIngredient(currentLocale)),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
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
                                '${NumberFormatter.formatCurrency(ingredient.purchasePrice, currentLocale, context.watch<NumberFormatCubit>().state)} / ${_formatNumber(ingredient.purchaseAmount)} ${_getUnitName(ingredient.purchaseUnitId)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '1${_getUnitName(ingredient.purchaseUnitId)}당 ${NumberFormatter.formatCurrency(unitPrice, currentLocale, context.watch<NumberFormatCubit>().state)}',
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(currentLocale)),
          ),
        ],
      ),
    );
  }

  Future<List<_RecipeSauceDisplay>> _fetchRecipeSauceDisplays() async {
    final recipeRepo = context.read<RecipeRepository>();
    final sauceRepo = context.read<SauceRepository>();
    final sauceCostService = context.read<SauceCostService>();
    final entries = await recipeRepo.getRecipeSauces(widget.recipe.id);
    final sauces = await sauceRepo.getAllSauces();
    final map = {for (final s in sauces) s.id: s};
    final List<_RecipeSauceDisplay> results = [];
    for (final e in entries) {
      final unitCost = await sauceCostService.getSauceUnitCost(e.sauceId);
      final baseUsage = uc.UnitConverter.toBaseUnit(e.amount, e.unitId);
      final cost = unitCost * baseUsage;
      results.add(
        _RecipeSauceDisplay(
          entry: e,
          sauceName: map[e.sauceId]?.name ?? '소스(${e.sauceId})',
          cost: cost,
        ),
      );
    }
    return results;
  }

  void _addSauce() async {
    final currentLocale = context.read<LocaleCubit>().state;
    final sauceRepo = context.read<SauceRepository>();
    final sauces = await sauceRepo.getAllSauces();
    Sauce? selected;
    final amountController = TextEditingController(text: '0');
    String unitId = 'g';

    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(AppStrings.getSelectSauce(currentLocale)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<Sauce>(
                value: selected,
                hint: Text(AppStrings.getSelectSauce(currentLocale)),
                items: sauces
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (v) => setStateDialog(() => selected = v),
              ),
              const SizedBox(height: 8),
              AppInputField(
                label: AppStrings.getQuantity(currentLocale),
                hint: '0',
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: unitId,
                items: const [
                  DropdownMenuItem(value: 'g', child: Text('g')),
                  DropdownMenuItem(value: 'ml', child: Text('ml')),
                  DropdownMenuItem(value: '개', child: Text('개')),
                ],
                onChanged: (v) => setStateDialog(() => unitId = v ?? 'g'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getCancel(currentLocale)),
            ),
            TextButton(
              onPressed: () async {
                final s = selected;
                final clean = amountController.text.replaceAll(
                  RegExp(r'[^\d]'),
                  '',
                );
                final amount = double.tryParse(clean) ?? 0;
                if (s != null && amount > 0) {
                  await context.read<rc.RecipeCubit>().addSauceToRecipe(
                        recipeId: widget.recipe.id,
                        sauceId: s.id,
                        amount: amount,
                        unitId: unitId,
                      );
                  if (mounted) setState(() {});
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(AppStrings.getAdd(currentLocale)),
            ),
          ],
        ),
      ),
    );
  }

  // 인라인 입력으로 대체됨

  void _removeSauce(RecipeSauce entry) async {
    await context.read<rc.RecipeCubit>().removeSauceFromRecipe(
          recipeId: widget.recipe.id,
          sauceId: entry.sauceId,
        );
    if (mounted) setState(() {});
  }

  void _editIngredient(Ingredient ingredient) {
    final currentLocale = context.read<LocaleCubit>().state;
    final currentAmount = _ingredientAmounts[ingredient.id] ?? 0.0;
    final unitPrice = _calculateUnitPrice(ingredient);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getEditIngredientAmount(currentLocale)),
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
                            '1${_getUnitName(ingredient.purchaseUnitId)}당 ${NumberFormatter.formatCurrency(unitPrice, currentLocale, context.watch<NumberFormatCubit>().state)}',
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
              label:
                  '${AppStrings.getInputAmount(currentLocale)} (${_getUnitName(ingredient.purchaseUnitId)})',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              initialValue: currentAmount > 0
                  ? NumberFormatter.formatNumber(
                      currentAmount.toInt(),
                      context.watch<NumberFormatCubit>().state,
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
                    AppStrings.getCalculatedCost(currentLocale),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    NumberFormatter.formatCurrency(
                      _ingredientCosts[ingredient.id] ?? 0.0,
                      currentLocale,
                      context.watch<NumberFormatCubit>().state,
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
            child: Text(AppStrings.getCancel(currentLocale)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppStrings.getSave(currentLocale)),
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

    final currentLocale = context.read<LocaleCubit>().state;
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getRecipeIngredientsRequired(currentLocale)),
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
              recipeId: widget.recipe.id,
              ingredientId: ingredient.id,
              amount: amount,
              unitId: _ingredientUnitIds[ingredient.id] ??
                  ingredient.purchaseUnitId,
              calculatedCost: _ingredientCosts[ingredient.id] ?? 0.0,
            ),
          );
        }
      }

      final updatedRecipe = widget.recipe.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        outputAmount: widget.recipe.outputAmount, // 기존 값 유지
        outputUnit: widget.recipe.outputUnit, // 기존 값 유지
        ingredients: recipeIngredients, // 재료 정보 포함
        tagIds: _selectedTagId.isNotEmpty ? [_selectedTagId] : [],
        updatedAt: DateTime.now(),
      );

      await context.read<RecipeCubit>().updateRecipe(updatedRecipe);

      // 레시피 수정 성공 시 뒤로가기
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getRecipeUpdateError(currentLocale)),
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

class _RecipeSauceDisplay {
  final RecipeSauce entry;
  final String sauceName;
  final double cost;
  _RecipeSauceDisplay({
    required this.entry,
    required this.sauceName,
    required this.cost,
  });
}
