import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../model/index.dart';
import '../../../theme/app_text_styles.dart';
import '../../widget/index.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_formatter.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../router/router_helper.dart';

class SauceEditPage extends StatefulWidget {
  final Sauce sauce;
  const SauceEditPage({super.key, required this.sauce});

  @override
  State<SauceEditPage> createState() => _SauceEditPageState();
}

class _SauceEditPageState extends State<SauceEditPage> {
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.sauce.name,
            style: TextStyle(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: colorScheme.error),
            onPressed: _confirmDeleteSauce,
            tooltip: AppStrings.getDelete(currentLocale),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getSauceComposition(currentLocale),
              style: AppTextStyles.headline4
                  .copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Expanded(child: _SauceIngredientList(sauceId: widget.sauce.id)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: AppStrings.getAddIngredient(currentLocale),
                type: AppButtonType.primary,
                onPressed: () => RouterHelper.goToSauceIngredientSelect(
                  context,
                  widget.sauce.id,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: AppStrings.getSave(currentLocale),
                type: AppButtonType.primary,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteSauce() async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getDelete(context.read<LocaleCubit>().state),
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          '${widget.sauce.name} ${AppStrings.getDeleteRecipeConfirm(context.read<LocaleCubit>().state)}',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppStrings.getCancel(context.read<LocaleCubit>().state),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: Text(
              AppStrings.getDelete(context.read<LocaleCubit>().state),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await context.read<SauceCubit>().deleteSauce(widget.sauce.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('소스를 삭제했습니다')));
    }
  }
}

class _SauceIngredientList extends StatefulWidget {
  final String sauceId;
  const _SauceIngredientList({required this.sauceId});

  @override
  State<_SauceIngredientList> createState() => _SauceIngredientListState();
}

class _SauceIngredientListState extends State<_SauceIngredientList> {
  final Map<String, TextEditingController> _amountControllers = {};

  @override
  void dispose() {
    for (final controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
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

  TextEditingController _getAmountController(
      String ingredientId, double amount) {
    if (!_amountControllers.containsKey(ingredientId)) {
      _amountControllers[ingredientId] = TextEditingController(
        text: amount > 0
            ? NumberFormatter.formatNumber(
                amount.toInt(),
                context.read<NumberFormatCubit>().state,
              )
            : '',
      );
    }
    return _amountControllers[ingredientId]!;
  }

  int _extractNumberFromText(String text) {
    final cleanText = text.replaceAll(',', '');
    return int.tryParse(cleanText) ?? 0;
  }

  double _calculateIngredientCost(
      Ingredient ingredient, double amount, String unitId) {
    final purchaseBase = uc.UnitConverter.toBaseUnit(
      ingredient.purchaseAmount,
      ingredient.purchaseUnitId,
    );
    final baseUnitPrice = ingredient.purchasePrice / purchaseBase;
    final baseUsage = uc.UnitConverter.toBaseUnit(amount, unitId);
    return baseUnitPrice * baseUsage;
  }

  double _calculateUnitPrice(Ingredient ingredient) {
    final basePurchase = uc.UnitConverter.toBaseUnit(
      ingredient.purchaseAmount,
      ingredient.purchaseUnitId,
    );
    if (basePurchase == 0) return 0.0;
    return ingredient.purchasePrice / basePurchase;
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<SauceCubit, SauceState>(
      builder: (context, sauceState) {
        return FutureBuilder<List<SauceIngredient>>(
          future:
              context.read<SauceCubit>().getIngredientsForSauce(widget.sauceId),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Center(
                child: Text(
                  AppStrings.getNoSauceIngredients(currentLocale),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              );
            }
            final ingredientState = context.read<IngredientCubit>().state;
            final ingredients = ingredientState is IngredientLoaded
                ? ingredientState.ingredients
                : <Ingredient>[];
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final ing = ingredients.firstWhere(
                  (i) => i.id == item.ingredientId,
                  orElse: () => Ingredient(
                    id: item.ingredientId,
                    name: '재료(${item.ingredientId})',
                    purchasePrice: 0,
                    purchaseAmount: 1,
                    purchaseUnitId: item.unitId,
                    createdAt: DateTime.now(),
                  ),
                );
                final unitOptions = _unitsFor(ing);
                final currentUnitId = item.unitId;
                final currentAmount = item.amount;
                final amountController =
                    _getAmountController(ing.id, currentAmount);
                final unitPrice = _calculateUnitPrice(ing);
                final cost =
                    _calculateIngredientCost(ing, currentAmount, currentUnitId);

                return Card(
                  color: colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 12),
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
                                      ing.name,
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
                                      '1${_getUnitName(ing.purchaseUnitId)}당 ${NumberFormatter.formatCurrency(unitPrice, currentLocale, context.watch<NumberFormatCubit>().state)}',
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
                              onPressed: () => context
                                  .read<SauceCubit>()
                                  .removeSauceIngredientById(
                                    sauceId: widget.sauceId,
                                    sauceIngredientId: item.id,
                                  ),
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
                              value: currentUnitId,
                              isExpanded: true,
                              dropdownColor: colorScheme.surface,
                              style: TextStyle(color: colorScheme.onSurface),
                              items: unitOptions
                                  .map((u) => DropdownMenuItem(
                                        value: u,
                                        child: Text(u),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                final prevUnitId = currentUnitId;
                                final currentAmountValue =
                                    _extractNumberFromText(
                                  amountController.text,
                                ).toDouble();
                                final baseUsage = uc.UnitConverter.toBaseUnit(
                                  currentAmountValue,
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
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted &&
                                      amountController.text != formattedText) {
                                    final textLength = formattedText.length;
                                    amountController.value = TextEditingValue(
                                      text: formattedText,
                                      selection: TextSelection.collapsed(
                                        offset: textLength,
                                      ),
                                    );
                                  }
                                });
                                context
                                    .read<SauceCubit>()
                                    .updateSauceIngredient(
                                      sauceId: widget.sauceId,
                                      ingredientId: item.ingredientId,
                                      amount: converted,
                                      unitId: v,
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
                              controller: amountController,
                              onChanged: (value) {
                                final newAmount =
                                    _extractNumberFromText(value).toDouble();
                                context
                                    .read<SauceCubit>()
                                    .updateSauceIngredient(
                                      sauceId: widget.sauceId,
                                      ingredientId: item.ingredientId,
                                      amount: newAmount,
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
                                          .withValues(alpha: 0.6),
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
            );
          },
        );
      },
    );
  }

  String _getUnitName(String unitId) {
    return unitId;
  }
}
