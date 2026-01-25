import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';

import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';

import '../../../model/ingredient.dart';
import '../../../model/tag.dart';
import '../../../model/unit.dart';
import '../../../model/recipe_ingredient.dart';
import '../../../model/recipe_sauce.dart';
import '../../../model/sauce.dart';
import 'package:uuid/uuid.dart';
import '../../widget/index.dart';
import '../../../data/index.dart';
import '../../../service/sauce_cost_service.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../router/router_helper.dart';

/// 레시피 추가 페이지
class RecipeAddPage extends StatefulWidget {
  final List<Ingredient>? selectedIngredients;
  final List<Sauce>? selectedSauces;

  const RecipeAddPage({
    super.key,
    this.selectedIngredients,
    this.selectedSauces,
  });

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
  final Map<String, double> _ingredientAmounts = {}; // 재료별 투입량
  final Map<String, double> _ingredientCosts = {}; // 재료별 원가
  final Map<String, String> _ingredientUnitIds = {}; // 재료별 선택 단위
  final Map<String, TextEditingController> _amountControllers = {}; // 투입량 컨트롤러
  final Map<String, TextEditingController> _sauceAmountControllers =
      {}; // 소스 투입량 컨트롤러
  final List<_PendingSauce> _selectedSauces = [];
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
    // 선택된 소스가 있다면 추가 (기본 수량 0, 단위 g)
    if (widget.selectedSauces != null) {
      for (final s in widget.selectedSauces!) {
        _selectedSauces.add(
          _PendingSauce(sauceId: s.id, amount: 0, unitId: 'g'),
        );
      }
    }
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

  void _loadIngredients() {
    final currentState = context.read<IngredientCubit>().state;
    if (currentState is IngredientLoaded) {
      setState(() {
        _availableIngredients = currentState.ingredients;
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
    final selectedUnitId =
        _ingredientUnitIds[ingredientId] ?? ingredient.purchaseUnitId;
    final purchaseBase = uc.UnitConverter.toBaseUnit(
      ingredient.purchaseAmount,
      ingredient.purchaseUnitId,
    );
    final baseUnitPrice = ingredient.purchasePrice / purchaseBase;
    final baseUsage = uc.UnitConverter.toBaseUnit(amount, selectedUnitId);
    final cost = baseUnitPrice * baseUsage;

    setState(() {
      _ingredientAmounts[ingredientId] = amount;
      _ingredientCosts[ingredientId] = cost;
      _ingredientUnitIds[ingredientId] = selectedUnitId;
      _calculateTotalCost();
    });
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
              Flexible(
                child: Text(
                  AppStrings.getSauces(currentLocale),
                  style: AppTextStyles.headline4.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton.icon(
                  onPressed: _addSauce,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(AppStrings.getAddSauce(currentLocale)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedSauces.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppStrings.getNoRecipeSauces(currentLocale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _selectedSauces.length,
              itemBuilder: (context, index) {
                final ps = _selectedSauces[index];
                final amountController = _getSauceAmountController(ps.sauceId);
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
                              child: FutureBuilder<List<_PendingSauceDisplay>>(
                                future: _fetchPendingSauceDisplays(),
                                builder: (context, snapshot) {
                                  final items = snapshot.data ??
                                      const <_PendingSauceDisplay>[];
                                  final display = items.firstWhere(
                                    (e) => e.sauceId == ps.sauceId,
                                    orElse: () => _PendingSauceDisplay(
                                      sauceId: ps.sauceId,
                                      sauceName: '소스(${ps.sauceId})',
                                      amount: ps.amount,
                                      unitId: ps.unitId,
                                      cost: 0,
                                    ),
                                  );
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          display.sauceName,
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      FutureBuilder<double>(
                                        future: context
                                            .read<SauceCostService>()
                                            .getSauceUnitCost(ps.sauceId),
                                        builder: (context, snap) {
                                          final unitCost = snap.data ?? 0.0;
                                          return FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              '1${ps.unitId}당 ${NumberFormatter.formatCurrency(unitCost, currentLocale, context.watch<NumberFormatCubit>().state)}',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: colorScheme.onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removePendingSauce(ps.sauceId),
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
                                    '${AppStrings.getInputAmount(currentLocale)} (${ps.unitId})',
                                hint: '0',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  ThousandsSeparatorInputFormatter(),
                                ],
                                controller: amountController,
                                onChanged: (value) {
                                  final clean = value.replaceAll(
                                    RegExp(r'[^\\d]'),
                                    '',
                                  );
                                  final newAmount = double.tryParse(clean) ?? 0;
                                  _updateSauceAmount(ps.sauceId, newAmount);
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
                                child: FutureBuilder<double>(
                                  future: context
                                      .read<SauceCostService>()
                                      .getSauceUnitCost(ps.sauceId),
                                  builder: (context, snap) {
                                    final unitCost = snap.data ?? 0.0;
                                    final baseUsage =
                                        uc.UnitConverter.toBaseUnit(
                                      ps.amount,
                                      ps.unitId,
                                    );
                                    final cost = unitCost * baseUsage;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.getCost(currentLocale),
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
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
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
            ),
        ],
      ),
    );
  }

  void _calculateTotalCost() {
    _totalCost = _ingredientCosts.values.fold(0.0, (sum, cost) => sum + cost);
  }

  int _extractNumberFromText(String text) {
    final cleanText = text.replaceAll(',', '');
    return int.tryParse(cleanText) ?? 0;
  }

  Future<double> _computeSelectedSaucesCost() async {
    final displays = await _fetchPendingSauceDisplays();
    double total = 0.0;
    for (final d in displays) {
      total += d.cost;
    }
    return total;
  }

  Future<List<_PendingSauceDisplay>> _fetchPendingSauceDisplays() async {
    final sauceRepo = context.read<SauceRepository>();
    final sauceCostService = context.read<SauceCostService>();
    final sauces = await sauceRepo.getAllSauces();
    final byId = {for (final s in sauces) s.id: s};
    final List<_PendingSauceDisplay> results = [];
    for (final ps in _selectedSauces) {
      final unitCost = await sauceCostService.getSauceUnitCost(ps.sauceId);
      final baseUsage = uc.UnitConverter.toBaseUnit(ps.amount, ps.unitId);
      results.add(
        _PendingSauceDisplay(
          sauceId: ps.sauceId,
          sauceName: byId[ps.sauceId]?.name ?? '소스(${ps.sauceId})',
          amount: ps.amount,
          unitId: ps.unitId,
          cost: unitCost * baseUsage,
        ),
      );
    }
    return results;
  }

  TextEditingController _getAmountController(String ingredientId) {
    if (!_amountControllers.containsKey(ingredientId)) {
      final amount = _ingredientAmounts[ingredientId] ?? 0.0;
      _amountControllers[ingredientId] = TextEditingController(
        text: amount > 0
            ? NumberFormatter.formatNumber(
                amount.toInt(),
                context.watch<NumberFormatCubit>().state,
              )
            : '',
      );
    }
    return _amountControllers[ingredientId]!;
  }

  TextEditingController _getSauceAmountController(String sauceId) {
    if (!_sauceAmountControllers.containsKey(sauceId)) {
      final current = _selectedSauces.firstWhere(
        (e) => e.sauceId == sauceId,
        orElse: () => _PendingSauce(sauceId: sauceId, amount: 0, unitId: 'g'),
      );
      _sauceAmountControllers[sauceId] = TextEditingController(
        text: current.amount > 0
            ? NumberFormatter.formatNumber(
                current.amount.toInt(),
                context.watch<NumberFormatCubit>().state,
              )
            : '',
      );
    }
    return _sauceAmountControllers[sauceId]!;
  }

  void _updateSauceAmount(String sauceId, double newAmount) {
    final idx = _selectedSauces.indexWhere((e) => e.sauceId == sauceId);
    if (idx >= 0) {
      setState(() {
        _selectedSauces[idx] = _selectedSauces[idx].copyWith(amount: newAmount);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    for (final controller in _sauceAmountControllers.values) {
      controller.dispose();
    }
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
          AppStrings.getAddRecipe(currentLocale),
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
              Flexible(
                child: Text(
                  AppStrings.getRecipeIngredients(currentLocale),
                  style: AppTextStyles.headline4.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextButton.icon(
                  onPressed: () async {
                    final result =
                        await RouterHelper.goToRecipeIngredientSelect(
                      context,
                      currentSelectedIngredients: _selectedIngredients,
                      currentIngredientAmounts: _ingredientAmounts,
                      currentIngredientUnitIds: _ingredientUnitIds,
                    );
                    if (result != null && mounted) {
                      final selectedIngredients =
                          result['ingredients'] as List<Ingredient>?;
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
                                  _ingredientUnitIds[ing.id] ??
                                      ing.purchaseUnitId;
                              final basePurchase = uc.UnitConverter.toBaseUnit(
                                ing.purchaseAmount,
                                ing.purchaseUnitId,
                              );
                              final unitPrice =
                                  ing.purchasePrice / basePurchase;
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
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(AppStrings.getAddIngredient(currentLocale)),
                ),
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
                final cost = _ingredientCosts[ingredient.id] ?? 0.0;
                final amountController = _getAmountController(ingredient.id);

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
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      ingredient.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '1${_getUnitName(ingredient.purchaseUnitId)}당 ${NumberFormatter.formatCurrency(unitPrice, currentLocale, context.watch<NumberFormatCubit>().state)}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
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
                              value: _ingredientUnitIds[ingredient.id] ??
                                  ingredient.purchaseUnitId,
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
                              onChanged: (v) {
                                if (v == null) return;
                                final prevUnitId =
                                    _ingredientUnitIds[ingredient.id] ??
                                        ingredient.purchaseUnitId;
                                final currentAmount = _extractNumberFromText(
                                  amountController.text,
                                ).toDouble();
                                final baseUsage = uc.UnitConverter.toBaseUnit(
                                  currentAmount,
                                  prevUnitId,
                                );
                                final converted = uc.UnitConverter.fromBaseUnit(
                                  baseUsage,
                                  v,
                                );
                                final formattedText =
                                    NumberFormatter.formatNumber(
                                  converted.toInt(),
                                  context.read<NumberFormatCubit>().state,
                                );
                                amountController.value = TextEditingValue(
                                  text: formattedText,
                                  selection: TextSelection.collapsed(
                                    offset: formattedText.length,
                                  ),
                                );
                                setState(() {
                                  _ingredientUnitIds[ingredient.id] = v;
                                  _ingredientAmounts[ingredient.id] = converted;
                                  _calculateIngredientCost(
                                    ingredient.id,
                                    converted,
                                  );
                                });
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
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
          content: SizedBox(
            width: 500,
            height: 360,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: sauces.length,
                    itemBuilder: (context, index) {
                      final sauce = sauces[index];
                      final isSel = selected?.id == sauce.id;
                      return ListTile(
                        selected: isSel,
                        leading: CircleAvatar(
                          backgroundColor:
                              colorScheme.primary.withValues(alpha: 0.1),
                          child: Text(
                            sauce.name.isNotEmpty ? sauce.name[0] : 'S',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            sauce.name,
                            style: TextStyle(color: colorScheme.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: FutureBuilder<SauceAggregation>(
                          future: context
                              .read<SauceCostService>()
                              .aggregateSauce(sauce.id),
                          builder: (context, snapshot) {
                            final agg = snapshot.data;
                            if (agg == null || agg.totalBaseAmount <= 0) {
                              return const SizedBox.shrink();
                            }
                            final uCost = agg.totalCost / agg.totalBaseAmount;
                            final baseU = agg.unitType == uc.UnitType.weight
                                ? 'g'
                                : agg.unitType == uc.UnitType.volume
                                    ? 'ml'
                                    : '개';
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '1$baseU당 ${NumberFormatter.formatCurrency(uCost, currentLocale, context.watch<NumberFormatCubit>().state)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                        onTap: () => setDialogState(() {
                          selected = sauce;
                          unitId = 'g';
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (selected != null)
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: unitId,
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(color: colorScheme.onSurface),
                        items: const [
                          DropdownMenuItem(value: 'g', child: Text('g')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(value: '개', child: Text('개')),
                        ],
                        onChanged: (v) => setDialogState(() {
                          unitId = v ?? 'g';
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppInputField(
                          label: AppStrings.getAmount(currentLocale),
                          hint: '0',
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsSeparatorInputFormatter()],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppStrings.getCancel(currentLocale)),
            ),
            TextButton(
              onPressed: () {
                final s = selected;
                if (s == null) return;
                final clean = amountController.text.replaceAll(',', '');
                final amount = double.tryParse(clean) ?? 0;
                if (amount <= 0) return;
                setState(() {
                  final idx = _selectedSauces.indexWhere(
                    (e) => e.sauceId == s.id,
                  );
                  if (idx >= 0) {
                    _selectedSauces[idx] = _selectedSauces[idx].copyWith(
                      amount: amount,
                      unitId: unitId,
                    );
                  } else {
                    _selectedSauces.add(
                      _PendingSauce(
                        sauceId: s.id,
                        amount: amount,
                        unitId: unitId,
                      ),
                    );
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(AppStrings.getAdd(currentLocale)),
            ),
          ],
        ),
      ),
    );
  }

  void _removePendingSauce(String sauceId) {
    setState(() {
      _selectedSauces.removeWhere((e) => e.sauceId == sauceId);
    });
  }

  Widget _buildTagsSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getRecipeTags(AppLocale.korea),
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
            future: _computeSelectedSaucesCost(),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

  void _removeIngredient(Ingredient ingredient) {
    setState(() {
      _selectedIngredients.removeWhere((i) => i.id == ingredient.id);
      _ingredientAmounts.remove(ingredient.id);
      _ingredientCosts.remove(ingredient.id);
      _calculateTotalCost();

      if (_amountControllers.containsKey(ingredient.id)) {
        _amountControllers[ingredient.id]!.dispose();
        _amountControllers.remove(ingredient.id);
      }
    });
  }

  void _saveRecipe() async {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedIngredients.isEmpty && _selectedSauces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getRecipeIngredientsRequired(currentLocale)),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final recipeIngredients = <RecipeIngredient>[];
      for (final ingredient in _selectedIngredients) {
        final amount = _ingredientAmounts[ingredient.id] ?? 0.0;
        if (amount > 0) {
          recipeIngredients.add(
            RecipeIngredient(
              id: const Uuid().v4(),
              recipeId: '',
              ingredientId: ingredient.id,
              amount: amount,
              unitId: _ingredientUnitIds[ingredient.id] ??
                  ingredient.purchaseUnitId,
              calculatedCost: _ingredientCosts[ingredient.id] ?? 0.0,
            ),
          );
        }
      }

      await context.read<RecipeCubit>().addRecipe(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            outputAmount: 1.0,
            outputUnit: '인분',
            tagIds: _selectedTagId.isNotEmpty ? [_selectedTagId] : [],
            ingredients: recipeIngredients,
            sauces: _selectedSauces
                .map(
                  (s) => RecipeSauce(
                    id: '',
                    recipeId: '',
                    sauceId: s.sauceId,
                    amount: s.amount,
                    unitId: s.unitId,
                  ),
                )
                .toList(),
          );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getRecipeAddError(currentLocale)),
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

class _PendingSauce {
  final String sauceId;
  final double amount;
  final String unitId;
  const _PendingSauce({
    required this.sauceId,
    required this.amount,
    required this.unitId,
  });

  _PendingSauce copyWith({double? amount, String? unitId}) => _PendingSauce(
        sauceId: sauceId,
        amount: amount ?? this.amount,
        unitId: unitId ?? this.unitId,
      );
}

class _PendingSauceDisplay {
  final String sauceId;
  final String sauceName;
  final double amount;
  final String unitId;
  final double cost;
  const _PendingSauceDisplay({
    required this.sauceId,
    required this.sauceName,
    required this.amount,
    required this.unitId,
    required this.cost,
  });
}
