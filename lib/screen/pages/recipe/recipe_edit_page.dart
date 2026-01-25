import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_app/router/router_helper.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_formatter.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/recipe/recipe_cubit.dart' as rc;

import '../../../model/index.dart';

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
    final locale = context.read<LocaleCubit>().state;
    setState(() {
      _availableTags = DefaultTags.recipeTagsFor(locale);
    });
  }

  void _loadUnits() {
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
    }
  }

  double _calculateUnitPrice(Ingredient ingredient) {
    return ingredient.purchasePrice / ingredient.purchaseAmount;
  }

  void _calculateIngredientCost(String ingredientId, double amount) {
    final ingredient = _selectedIngredients.firstWhere(
      (i) => i.id == ingredientId,
    );
    final purchaseBase = uc.UnitConverter.toBaseUnit(
      ingredient.purchaseAmount,
      ingredient.purchaseUnitId,
    );
    final baseUnitPrice =
        purchaseBase > 0 ? ingredient.purchasePrice / purchaseBase : 0.0;
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

  void _calculateTotalCost() {
    _totalCost = _ingredientCosts.values.fold(0.0, (sum, cost) => sum + cost);
  }

  int _extractNumberFromText(String text) {
    final cleanText = text.replaceAll(',', '');
    return int.tryParse(cleanText) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppStrings.getEditRecipe(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    _saveRecipe();
                  },
            child: Text(
              AppStrings.getSave(currentLocale),
              style: AppTextStyles.buttonMedium.copyWith(
                color: _isLoading
                    ? colorScheme.onSurface.withValues(alpha: 0.3)
                    : colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getBasicInfo(currentLocale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.getRecipeIngredients(currentLocale),
                style: AppTextStyles.headline4.copyWith(
                  color: colorScheme.onSurface,
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
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getNoIngredientsSelected(currentLocale),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
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

                return Card(
                  color: colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  colorScheme.primary.withValues(alpha: 0.1),
                              child: Text(
                                ingredient.name.isNotEmpty
                                    ? ingredient.name[0]
                                    : 'I',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: colorScheme.primary,
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
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '1${_getUnitName(ingredient.purchaseUnitId)}당 ${NumberFormatter.formatCurrency(unitPrice, currentLocale, context.watch<NumberFormatCubit>().state)}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _editIngredient(ingredient),
                              icon: Icon(
                                Icons.edit,
                                color: colorScheme.primary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeIngredient(ingredient),
                              icon: Icon(
                                Icons.delete,
                                color: colorScheme.error,
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
                              dropdownColor: colorScheme.surface,
                              style: TextStyle(color: colorScheme.onSurface),
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
                                    uc.UnitConverter.fromBaseUnit(baseUsage, v);
                                setState(() {
                                  _ingredientUnitIds[ingredient.id] = v;
                                  _ingredientAmounts[ingredient.id] = converted;
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
                                      context.watch<NumberFormatCubit>().state,
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
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: colorScheme.outlineVariant),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.getCost(currentLocale),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.5),
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
                                      style: AppTextStyles.headline4.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
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

  Widget _buildSaucesSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.getSauces(currentLocale),
                style: AppTextStyles.headline4.copyWith(
                  color: colorScheme.onSurface,
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
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                    color: colorScheme.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
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
                                        color: colorScheme.onSurface,
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
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _removeSauceEntry(entry.sauceId),
                                icon: Icon(
                                  Icons.delete,
                                  color: colorScheme.error,
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
                                      '${AppStrings.getInputAmount(currentLocale)} (${entry.unitId})',
                                  hint: '0',
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    ThousandsSeparatorInputFormatter(),
                                  ],
                                  onChanged: (val) async {
                                    final amt =
                                        _extractNumberFromText(val).toDouble();
                                    await context
                                        .read<rc.RecipeCubit>()
                                        .updateRecipeSauceAmount(
                                          recipeId: widget.recipe.id,
                                          sauceId: entry.sauceId,
                                          newAmount: amt,
                                        );
                                    setState(() {});
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: colorScheme.outlineVariant),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.getCost(currentLocale),
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          NumberFormatter.formatCurrency(
                                            display.cost,
                                            currentLocale,
                                            context
                                                .watch<NumberFormatCubit>()
                                                .state,
                                          ),
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getRecipeTags(context.watch<LocaleCubit>().state),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
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
                  selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                  checkmarkColor: colorScheme.primary,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
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
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getCostInfo(currentLocale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<double>(
            future: _computeTotalSauceCost(),
            builder: (context, snapshot) {
              final sauceSum = snapshot.data ?? 0.0;
              final ingredientSum = _totalCost;
              final total = ingredientSum + sauceSum;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            AppStrings.getIngredientCostLabel(currentLocale),
                            style: TextStyle(color: colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            NumberFormatter.formatCurrency(
                              ingredientSum,
                              currentLocale,
                              context.watch<NumberFormatCubit>().state,
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            AppStrings.getSauceCostLabel(currentLocale),
                            style: TextStyle(color: colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            NumberFormatter.formatCurrency(
                              sauceSum,
                              currentLocale,
                              context.watch<NumberFormatCubit>().state,
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 20, color: colorScheme.outlineVariant),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            AppStrings.getTotalCost(currentLocale),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            NumberFormatter.formatCurrency(total, currentLocale,
                                context.watch<NumberFormatCubit>().state),
                            style: AppTextStyles.headline4.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
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

  void _addIngredient() async {
    final result = await RouterHelper.goToRecipeIngredientSelect(
      context,
      currentSelectedIngredients: _selectedIngredients,
      currentIngredientAmounts: _ingredientAmounts,
      currentIngredientUnitIds: _ingredientUnitIds,
    );

    if (result != null && mounted) {
      final selectedIngredients = result['ingredients'] as List<Ingredient>?;
      final amounts = result['amounts'] as Map<String, double>?;
      final unitIds = result['unitIds'] as Map<String, String>?;

      if (selectedIngredients != null) {
        setState(() {
          _selectedIngredients = selectedIngredients;
          if (amounts != null) {
            for (var key in amounts.keys) {
              _ingredientAmounts[key] = amounts[key]!;
            }
          }
          if (unitIds != null) {
            for (var key in unitIds.keys) {
              _ingredientUnitIds[key] = unitIds[key]!;
            }
          }

          for (final ing in _selectedIngredients) {
            final amount = _ingredientAmounts[ing.id] ?? 0.0;
            if (amount > 0) {
              final selectedUnitId =
                  _ingredientUnitIds[ing.id] ?? ing.purchaseUnitId;
              final basePurchase = uc.UnitConverter.toBaseUnit(
                ing.purchaseAmount,
                ing.purchaseUnitId,
              );
              final unitPrice = ing.purchasePrice / basePurchase;
              final baseUsage = uc.UnitConverter.toBaseUnit(
                amount,
                selectedUnitId,
              );
              _ingredientCosts[ing.id] = unitPrice * baseUsage;
            }
          }
          _calculateTotalCost();
        });
      }
    }
  }

  void _editIngredient(Ingredient ingredient) {
    // 인라인 편집 기능을 제공하므로 별도 다이얼로그는 불필요할 수 있음
  }

  void _removeIngredient(Ingredient ingredient) {
    setState(() {
      _selectedIngredients.removeWhere((i) => i.id == ingredient.id);
      _ingredientAmounts.remove(ingredient.id);
      _ingredientUnitIds.remove(ingredient.id);
      _ingredientCosts.remove(ingredient.id);
      _calculateTotalCost();
    });
  }

  void _addSauce() async {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    final sauceRepo = context.read<SauceRepository>();
    final sauces = await sauceRepo.getAllSauces();
    Sauce? selected;
    String unitId = 'g';
    final amountController = TextEditingController(text: '0');
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(AppStrings.getSelectSauce(currentLocale)),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: sauces.length,
              itemBuilder: (context, index) {
                final s = sauces[index];
                final isSelected = selected?.id == s.id;
                return ListTile(
                  selected: isSelected,
                  title: Text(s.name,
                      style: TextStyle(color: colorScheme.onSurface)),
                  onTap: () => setDialogState(() => selected = s),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getCancel(currentLocale)),
            ),
            TextButton(
              onPressed: () async {
                if (selected != null) {
                  await context.read<rc.RecipeCubit>().addSauceToRecipe(
                        recipeId: widget.recipe.id,
                        sauceId: selected!.id,
                        amount: 0,
                        unitId: 'g',
                      );
                  if (mounted) Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text(AppStrings.getAdd(currentLocale)),
            ),
          ],
        ),
      ),
    );
  }

  void _removeSauceEntry(String sauceId) async {
    await context.read<rc.RecipeCubit>().removeSauceFromRecipe(
          recipeId: widget.recipe.id,
          sauceId: sauceId,
        );
    setState(() {});
  }

  Future<double> _computeTotalSauceCost() async {
    final displays = await _fetchRecipeSauceDisplays();
    double sum = 0;
    for (final d in displays) sum += d.cost;
    return sum;
  }

  Future<List<_RecipeSauceDisplay>> _fetchRecipeSauceDisplays() async {
    final sauceRepo = context.read<SauceRepository>();
    final sauceCostService = context.read<SauceCostService>();
    final currentRecipe = await context
        .read<rc.RecipeCubit>()
        .recipeRepo
        .getRecipeById(widget.recipe.id);
    if (currentRecipe == null) return [];
    final list = <_RecipeSauceDisplay>[];
    for (final rs in currentRecipe.sauces) {
      final s = await sauceRepo.getSauceById(rs.sauceId);
      final unitCost = await sauceCostService.getSauceUnitCost(rs.sauceId);
      final baseUsage = uc.UnitConverter.toBaseUnit(rs.amount, rs.unitId);
      list.add(
        _RecipeSauceDisplay(
          entry: rs,
          sauceName: s?.name ?? '소스(${rs.sauceId})',
          cost: unitCost * baseUsage,
        ),
      );
    }
    return list;
  }

  void _saveRecipe() async {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final currentRecipe = await context
          .read<rc.RecipeCubit>()
          .recipeRepo
          .getRecipeById(widget.recipe.id);
      if (currentRecipe == null) return;

      final updatedIngredients = <RecipeIngredient>[];
      for (final ing in _selectedIngredients) {
        final amount = _ingredientAmounts[ing.id] ?? 0.0;
        final unitId = _ingredientUnitIds[ing.id] ?? ing.purchaseUnitId;
        updatedIngredients.add(RecipeIngredient(
          id: const Uuid().v4(),
          recipeId: widget.recipe.id,
          ingredientId: ing.id,
          amount: amount,
          unitId: unitId,
          calculatedCost: _ingredientCosts[ing.id] ?? 0.0,
        ));
      }

      final updatedRecipe = currentRecipe.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        tagIds: _selectedTagId.isNotEmpty ? [_selectedTagId] : [],
        ingredients: updatedIngredients,
      );

      await context.read<rc.RecipeCubit>().updateRecipe(updatedRecipe);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppStrings.getRecipeUpdateError(currentLocale, e.toString())),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
