import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../model/index.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../widget/index.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../../controller/setting/locale_cubit.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.sauce.name}'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: _confirmDeleteSauce,
            tooltip: AppStrings.getDelete(currentLocale),
          ),
        ],
      ),
      body: BlocBuilder<IngredientCubit, IngredientState>(
        builder: (context, ingredientState) {
          final ingredients = ingredientState is IngredientLoaded
              ? ingredientState.ingredients
              : <Ingredient>[];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.getSauceComposition(currentLocale),
                  style: AppTextStyles.headline4,
                ),
                const SizedBox(height: 12),
                Expanded(child: _SauceIngredientList(sauceId: widget.sauce.id)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: AppStrings.getAddIngredient(currentLocale),
                    type: AppButtonType.primary,
                    onPressed: () => _showAddIngredientDialog(ingredients),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteSauce() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getDelete(context.read<LocaleCubit>().state)),
        content: Text(
          '${widget.sauce.name} ${AppStrings.getDeleteRecipeConfirm(context.read<LocaleCubit>().state)}',
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
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

  void _showAddIngredientDialog(List<Ingredient> ingredients) {
    Ingredient? selected;
    final amountController = TextEditingController(text: '0');
    final searchController = TextEditingController();
    List<Ingredient> filtered = List.of(ingredients);
    String unitId = ingredients.isNotEmpty
        ? ingredients.first.purchaseUnitId
        : 'g';

    List<String> _unitsFor(Ingredient? ing) {
      if (ing == null) return ['g', 'kg', 'ml', 'L', '개'];
      final type = uc.UnitConverter.getUnitType(ing.purchaseUnitId);
      switch (type) {
        case uc.UnitType.weight:
          return ['g', 'kg'];
        case uc.UnitType.volume:
          return ['ml', 'L'];
        case uc.UnitType.count:
          return ['개'];
        default:
          return ['g'];
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final unitOptions = _unitsFor(selected);
          if (!unitOptions.contains(unitId)) {
            unitId = unitOptions.first;
          }
          return AlertDialog(
            title: Text(AppStrings.getAddIngredientToSauce(AppLocale.korea)),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 검색 입력
                  AppInputField(
                    label: AppStrings.getSelectIngredient(AppLocale.korea),
                    hint: AppStrings.getSelectIngredient(AppLocale.korea),
                    controller: searchController,
                    onChanged: (value) {
                      setModalState(() {
                        final q = value.trim();
                        if (q.isEmpty) {
                          filtered = List.of(ingredients);
                        } else {
                          filtered = ingredients
                              .where((e) => e.name.contains(q))
                              .toList();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  // 재료 목록
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final ing = filtered[index];
                        final isSelected = selected?.id == ing.id;
                        return ListTile(
                          selected: isSelected,
                          title: Text(ing.name),
                          subtitle: Text(
                            '구매단위: ${ing.purchaseAmount} ${ing.purchaseUnitId}',
                          ),
                          onTap: () => setModalState(() {
                            selected = ing;
                            unitId = ing.purchaseUnitId;
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selected != null)
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Chip(label: Text(selected!.name)),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: unitId,
                          items: unitOptions
                              .map(
                                (u) =>
                                    DropdownMenuItem(value: u, child: Text(u)),
                              )
                              .toList(),
                          onChanged: (v) => setModalState(() {
                            if (v != null) unitId = v;
                          }),
                        ),
                        SizedBox(
                          width: 140,
                          child: NumberInputField(
                            label: AppStrings.getAmount(AppLocale.korea),
                            controller: amountController,
                            locale: AppLocale.korea,
                            allowDecimal: true,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.getCancel(AppLocale.korea)),
              ),
              TextButton(
                onPressed: () {
                  final ing = selected;
                  // 소수점 허용: 숫자와 점만 남김 (첫 점만 유지)
                  var txt = amountController.text;
                  txt = txt.replaceAll(',', '');
                  final cleaned = txt.replaceAll(RegExp('[^0-9\.]'), '');
                  final parts = cleaned.split('.');
                  String normalized;
                  if (parts.length <= 1) {
                    normalized = cleaned;
                  } else {
                    normalized = parts.first + '.' + parts.sublist(1).join();
                  }
                  final amount = double.tryParse(normalized) ?? 0;
                  if (ing != null && amount > 0) {
                    context.read<SauceCubit>().addIngredientToSauce(
                      sauceId: widget.sauce.id,
                      ingredientId: ing.id,
                      amount: amount,
                      unitId: unitId,
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(AppStrings.getAdd(AppLocale.korea)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SauceIngredientList extends StatelessWidget {
  final String sauceId;
  const _SauceIngredientList({required this.sauceId});

  @override
  Widget build(BuildContext context) {
    // SauceCubit 상태 변화를 구독해 삭제/추가 직후 자동 갱신되도록 처리
    return BlocBuilder<SauceCubit, SauceState>(
      builder: (context, sauceState) {
        // 로딩 상태에서도 기존 리스트를 유지하여 화면 깜빡임을 방지
        return FutureBuilder<List<SauceIngredient>>(
          future: context.read<SauceCubit>().getIngredientsForSauce(sauceId),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return const Center(child: Text('구성 재료가 없습니다.'));
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
                return ListTile(
                  title: Text(ing.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.amount} ${item.unitId}'),
                      _PerUnitPriceText(ingredient: ing),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () =>
                        context.read<SauceCubit>().removeSauceIngredientById(
                          sauceId: sauceId,
                          sauceIngredientId: item.id,
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
}

class _PerUnitPriceText extends StatelessWidget {
  final Ingredient ingredient;
  const _PerUnitPriceText({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    // 구매 단위 기준으로 기본 단위로 환산 후 단가 계산
    final baseAmount = uc.UnitConverter.toBaseUnit(
      ingredient.purchaseAmount,
      ingredient.purchaseUnitId,
    );
    final unitType = uc.UnitConverter.getUnitType(ingredient.purchaseUnitId);
    if (baseAmount <= 0 || unitType == null) {
      return const SizedBox.shrink();
    }
    final unitPrice = ingredient.purchasePrice / baseAmount;
    // 레이블과 심볼은 NumberFormatter 헬퍼에서 처리
    return Text(
      '(${NumberFormatter.formatPerUnitText(unitPrice, ingredient.purchaseUnitId, AppLocale.korea)}: ${NumberFormatter.formatPerBaseUnitPrice(unitPrice, ingredient.purchaseUnitId, AppLocale.korea)})',
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
    );
  }
}
