import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_formatter.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../model/tag.dart';
import '../../../model/unit.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../widget/index.dart';

/// 레시피 재료 선택 페이지
class RecipeIngredientSelectPage extends StatefulWidget {
  final List<Ingredient>? currentSelectedIngredients;
  final Map<String, double>? currentIngredientAmounts;
  final Map<String, String>? currentIngredientUnitIds;

  const RecipeIngredientSelectPage({
    super.key,
    this.currentSelectedIngredients,
    this.currentIngredientAmounts,
    this.currentIngredientUnitIds,
  });

  @override
  State<RecipeIngredientSelectPage> createState() =>
      _RecipeIngredientSelectPageState();
}

class _RecipeIngredientSelectPageState
    extends State<RecipeIngredientSelectPage> {
  final List<Ingredient> _availableIngredients = [];
  List<Ingredient> _selectedIngredients = [];
  Map<String, double> _ingredientAmounts = {};
  Map<String, String> _ingredientUnitIds = {};
  final Map<String, TextEditingController> _amountControllers = {};
  String _searchQuery = '';
  String _selectedFilterTag = '';
  List<Tag> _availableTags = [];
  List<Unit> _availableUnits = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    if (widget.currentSelectedIngredients != null) {
      _selectedIngredients = List.from(widget.currentSelectedIngredients!);
      if (widget.currentIngredientAmounts != null) {
        _ingredientAmounts = Map.from(widget.currentIngredientAmounts!);
      }
      if (widget.currentIngredientUnitIds != null) {
        _ingredientUnitIds = Map.from(widget.currentIngredientUnitIds!);

        for (final ing in _selectedIngredients) {
          final amount = _ingredientAmounts[ing.id] ?? 0.0;
          _amountControllers[ing.id] = TextEditingController(
            text: amount > 0 ? amount.toString() : '',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadInitialData() {
    _loadTags();
    _loadUnits();
    context.read<IngredientCubit>().loadIngredients();
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

  List<String> _unitsFor(Ingredient ing) {
    final type = uc.UnitConverter.getUnitType(ing.purchaseUnitId);
    switch (type) {
      case uc.UnitType.weight:
        return ['g', 'kg'];
      case uc.UnitType.volume:
        return ['ml', 'L'];
      case uc.UnitType.count:
        return ['개', '마리', '장', '인분'];
      default:
        return ['g'];
    }
  }

  List<Ingredient> _getFilteredIngredients() {
    return _availableIngredients.where((ing) {
      final matchesSearch =
          _searchQuery.isEmpty || ing.name.contains(_searchQuery);
      final matchesTag =
          _selectedFilterTag.isEmpty || ing.tagIds.contains(_selectedFilterTag);
      return matchesSearch && matchesTag;
    }).toList();
  }

  void _toggleIngredientSelection(Ingredient ingredient) {
    setState(() {
      final isSelected = _selectedIngredients.any((i) => i.id == ingredient.id);

      if (isSelected) {
        _selectedIngredients.removeWhere((i) => i.id == ingredient.id);
        _ingredientAmounts.remove(ingredient.id);
        _ingredientUnitIds.remove(ingredient.id);
        if (_amountControllers.containsKey(ingredient.id)) {
          _amountControllers[ingredient.id]!.dispose();
          _amountControllers.remove(ingredient.id);
        }
      } else {
        _selectedIngredients.add(ingredient);
        _ingredientAmounts[ingredient.id] = 0.0;
        _ingredientUnitIds[ingredient.id] = ingredient.purchaseUnitId;
        _amountControllers[ingredient.id] = TextEditingController();
      }
    });
  }

  void _completeSelection() {
    final result = {
      'ingredients': _selectedIngredients,
      'amounts': _ingredientAmounts,
      'unitIds': _ingredientUnitIds,
    };
    context.pop(result);
  }

  String _formatNumber(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _getUnitName(String unitId) {
    final unit = _availableUnits.firstWhere(
      (u) => u.id == unitId,
      orElse: () =>
          Unit(id: unitId, name: unitId, type: 'count', conversionFactor: 1.0),
    );
    return unit.name;
  }

  double _calculateUnitPrice(Ingredient ing) {
    final basePurchase = uc.UnitConverter.toBaseUnit(
      ing.purchaseAmount,
      ing.purchaseUnitId,
    );
    if (basePurchase == 0) return 0.0;
    return ing.purchasePrice / basePurchase;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final filteredIngredients = _getFilteredIngredients();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          AppStrings.getSelectRecipeIngredients(currentLocale),
          style: AppTextStyles.headline4.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _completeSelection,
            child: Text(
              AppStrings.getComplete(currentLocale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<IngredientCubit, IngredientState>(
        builder: (context, state) {
          if (state is IngredientLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IngredientError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is IngredientLoaded || state is IngredientEmpty) {
            if (state is IngredientLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted &&
                    _availableIngredients.length != state.ingredients.length) {
                  setState(() {
                    _availableIngredients.clear();
                    _availableIngredients.addAll(state.ingredients);
                  });
                }
              });
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppInputField(
                    label: AppStrings.getSelectIngredient(currentLocale),
                    hint: AppStrings.getSelectIngredient(currentLocale),
                    controller: TextEditingController(text: _searchQuery)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: _searchQuery.length),
                      ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text(AppStrings.getAll(currentLocale)),
                          selected: _selectedFilterTag.isEmpty,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilterTag = '';
                            });
                          },
                          selectedColor:
                              colorScheme.primary.withValues(alpha: 0.2),
                          checkmarkColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: _selectedFilterTag.isEmpty
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ..._availableTags.map((tag) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(tag.name),
                                selected: _selectedFilterTag == tag.id,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilterTag = selected ? tag.id : '';
                                  });
                                },
                                selectedColor:
                                    colorScheme.primary.withValues(alpha: 0.2),
                                checkmarkColor: colorScheme.primary,
                                labelStyle: TextStyle(
                                  color: _selectedFilterTag == tag.id
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredIngredients.isEmpty
                      ? Center(
                          child: Text(
                            AppStrings.getNoIngredientsSelected(currentLocale),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredIngredients.length,
                          itemBuilder: (context, index) {
                            final ing = filteredIngredients[index];
                            final isSelected =
                                _selectedIngredients.any((i) => i.id == ing.id);
                            final unitPrice = _calculateUnitPrice(ing);
                            final unitOptions = _unitsFor(ing);
                            final currentUnitId = _ingredientUnitIds[ing.id] ??
                                ing.purchaseUnitId;
                            final currentAmount =
                                _ingredientAmounts[ing.id] ?? 0.0;

                            return Card(
                              color: colorScheme.surface,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        ing.name,
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    subtitle: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${NumberFormatter.formatCurrency(ing.purchasePrice, currentLocale, context.watch<NumberFormatCubit>().state)} / ${_formatNumber(ing.purchaseAmount)} ${_getUnitName(ing.purchaseUnitId)} (1${_getUnitName(ing.purchaseUnitId)}당 ${NumberFormatter.formatCurrency(unitPrice, currentLocale, context.watch<NumberFormatCubit>().state)})',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    onTap: () =>
                                        _toggleIngredientSelection(ing),
                                  ),
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16, 0, 16, 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      AppStrings.getUnit(
                                                          currentLocale),
                                                      style: AppTextStyles
                                                          .bodyMedium
                                                          .copyWith(
                                                        color: colorScheme
                                                            .onSurface,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    DropdownButton<String>(
                                                      value: currentUnitId,
                                                      isExpanded: true,
                                                      dropdownColor:
                                                          colorScheme.surface,
                                                      style: TextStyle(
                                                          color: colorScheme
                                                              .onSurface),
                                                      items: unitOptions
                                                          .map((u) =>
                                                              DropdownMenuItem(
                                                                value: u,
                                                                child: Text(u),
                                                              ))
                                                          .toList(),
                                                      onChanged: (v) {
                                                        if (v != null) {
                                                          setState(() {
                                                            _ingredientUnitIds[
                                                                ing.id] = v;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                flex: 3,
                                                child: AppInputField(
                                                  label: AppStrings.getAmount(
                                                      currentLocale),
                                                  hint: '0',
                                                  controller:
                                                      _amountControllers[
                                                              ing.id] ??
                                                          TextEditingController(
                                                            text: currentAmount >
                                                                    0
                                                                ? currentAmount
                                                                    .toString()
                                                                : '',
                                                          ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: [
                                                    ThousandsSeparatorInputFormatter()
                                                  ],
                                                  onChanged: (value) {
                                                    var txt = value.replaceAll(
                                                        ',', '');
                                                    final cleaned =
                                                        txt.replaceAll(
                                                            RegExp('[^0-9\.]'),
                                                            '');
                                                    final parts =
                                                        cleaned.split('.');
                                                    final normalized =
                                                        parts.length <= 1
                                                            ? cleaned
                                                            : parts.first +
                                                                '.' +
                                                                parts
                                                                    .sublist(1)
                                                                    .join();
                                                    final amount =
                                                        double.tryParse(
                                                                normalized) ??
                                                            0.0;
                                                    setState(() {
                                                      _ingredientAmounts[
                                                          ing.id] = amount;
                                                    });
                                                  },
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
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
