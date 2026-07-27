import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/index.dart';
import '../../../model/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';

/// 구매 기록 바텀시트.
/// 재료 검색 선택 → 수량/금액이 구매단위량·구매가로 프리필 → 저장 (2탭 목표).
void showPurchaseRecordSheet(BuildContext context, AppLocale locale) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<InventoryCubit>(),
      child: _PurchaseSheetBody(locale: locale),
    ),
  );
}

class _PurchaseSheetBody extends StatefulWidget {
  final AppLocale locale;
  const _PurchaseSheetBody({required this.locale});

  @override
  State<_PurchaseSheetBody> createState() => _PurchaseSheetBodyState();
}

class _PurchaseSheetBodyState extends State<_PurchaseSheetBody> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  Ingredient? _selected;

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _select(Ingredient ingredient) {
    setState(() {
      _selected = ingredient;
      // 프리필: 구매단위량 / 구매가 — 반복 구매는 그대로 저장만 누르면 됨
      _qtyController.text = ingredient.purchaseAmount ==
              ingredient.purchaseAmount.roundToDouble()
          ? ingredient.purchaseAmount.toInt().toString()
          : ingredient.purchaseAmount.toString();
      _priceController.text = ingredient.purchasePrice ==
              ingredient.purchasePrice.roundToDouble()
          ? ingredient.purchasePrice.toInt().toString()
          : ingredient.purchasePrice.toString();
    });
  }

  Future<void> _save() async {
    final ingredient = _selected;
    if (ingredient == null) return;
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    if (qty <= 0) return;

    final cubit = context.read<InventoryCubit>();
    await cubit.recordPurchase(
        ingredientId: ingredient.id, qty: qty, price: price);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppStrings.getInventoryPurchaseSaved(widget.locale)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final state = context.watch<InventoryCubit>().state;
    final query = _searchController.text.trim();
    final candidates = query.isEmpty
        ? state.ingredients
        : state.ingredients
            .where((i) => i.name.contains(query))
            .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: tokens.bgElev1,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.r16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.getInventoryRecordPurchase(widget.locale),
                style:
                    AppTypography.title3.copyWith(color: tokens.fgStrong)),
            const SizedBox(height: AppSpacing.s12),
            if (_selected == null) ...[
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText:
                      AppStrings.getInventorySelectIngredient(widget.locale),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              SizedBox(
                height: 240,
                child: ListView.builder(
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
                    final ingredient = candidates[index];
                    final unitName =
                        state.unitsById[ingredient.purchaseUnitId]?.name ??
                            '';
                    return ListTile(
                      dense: true,
                      title: Text(ingredient.name,
                          style: AppTypography.body1
                              .copyWith(color: tokens.fgStrong)),
                      subtitle: Text(
                          '${ingredient.purchaseAmount} $unitName · '
                          '${ingredient.purchasePrice}',
                          style: AppTypography.caption1
                              .copyWith(color: tokens.fgTertiary)),
                      onTap: () => _select(ingredient),
                    );
                  },
                ),
              ),
            ] else ...[
              // 선택된 재료 + 프리필된 수량/금액
              Row(
                children: [
                  Expanded(
                    child: Text(_selected!.name,
                        style: AppTypography.heading1
                            .copyWith(color: tokens.fgStrong)),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selected = null),
                    child: Text(AppStrings.getCancel(widget.locale)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText:
                            AppStrings.getInventoryEnterQty(widget.locale),
                        suffixText: state
                                .unitsById[_selected!.purchaseUnitId]?.name ??
                            '',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            AppStrings.getInventoryTodayPurchase(widget.locale),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                ),
                onPressed: _save,
                child: Text(AppStrings.getSave(widget.locale),
                    style: AppTypography.label1),
              ),
            ],
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }
}
