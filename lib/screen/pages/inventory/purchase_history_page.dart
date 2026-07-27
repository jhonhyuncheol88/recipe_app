import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/index.dart';
import '../../../data/index.dart';
import '../../../model/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';

/// 전체 구매 내역 페이지.
/// 날짜별 그룹(헤더: 날짜 + 일 합계) 최신순. 항목 탭 → 수량/금액 수정,
/// 스와이프 → 확인 후 삭제. 수정/삭제 시 재고 잔량이 자동 보정된다.
class PurchaseHistoryPage extends StatefulWidget {
  final AppLocale locale;
  const PurchaseHistoryPage({super.key, required this.locale});

  @override
  State<PurchaseHistoryPage> createState() => _PurchaseHistoryPageState();
}

class _PurchaseHistoryPageState extends State<PurchaseHistoryPage> {
  final InventoryRepository _repository = InventoryRepository();
  List<InventoryTransaction>? _purchases;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final purchases = await _repository.getAllPurchases();
    if (!mounted) return;
    setState(() => _purchases = purchases);
  }

  /// 수정/삭제 후: 목록 재조회 + 재고 탭 상태 동기화
  Future<void> _afterMutation() async {
    await _load();
    if (!mounted) return;
    await context.read<InventoryCubit>().load();
  }

  Future<void> _editPurchase(InventoryTransaction tx) async {
    final qtyController = TextEditingController(
      text: tx.qtyDelta == tx.qtyDelta.roundToDouble()
          ? tx.qtyDelta.toInt().toString()
          : tx.qtyDelta.toString(),
    );
    final priceController = TextEditingController(
      text: (tx.price ?? 0) == (tx.price ?? 0).roundToDouble()
          ? (tx.price ?? 0).toInt().toString()
          : (tx.price ?? 0).toString(),
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.getEdit(widget.locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: AppStrings.getInventoryEnterQty(widget.locale),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.getPurchasePrice(widget.locale),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.getCancel(widget.locale)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.getSave(widget.locale)),
          ),
        ],
      ),
    );

    if (saved == true) {
      final qty = double.tryParse(qtyController.text);
      final price = double.tryParse(priceController.text);
      if (qty != null && qty > 0 && price != null && price >= 0) {
        try {
          await _repository.updatePurchase(
              txId: tx.id, qty: qty, price: price);
          await _afterMutation();
        } catch (_) {
          _showErrorSnackBar();
        }
      }
    }
    qtyController.dispose();
    priceController.dispose();
  }

  Future<bool> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.getDelete(widget.locale)),
        content: Text(AppStrings.getDeletePurchaseConfirm(widget.locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.getCancel(widget.locale)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppStrings.getDelete(widget.locale)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _deletePurchase(InventoryTransaction tx) async {
    try {
      await _repository.deletePurchase(tx.id);
      await _afterMutation();
    } catch (_) {
      _showErrorSnackBar();
      await _load(); // Dismissible 이 이미 사라졌으므로 목록 복원
    }
  }

  void _showErrorSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppStrings.getInventoryError(widget.locale)),
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final state = context.watch<InventoryCubit>().state;
    final numberStyle = context.watch<NumberFormatCubit>().state;
    final ingredientsById = {
      for (final ingredient in state.ingredients) ingredient.id: ingredient,
    };

    // 날짜(yyyy-MM-dd)별 그룹 — getAllPurchases 가 최신순이므로 그룹도 최신순
    final grouped = <String, List<InventoryTransaction>>{};
    for (final tx in _purchases ?? const <InventoryTransaction>[]) {
      final dateKey = tx.createdAt.toIso8601String().substring(0, 10);
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }

    return Scaffold(
      backgroundColor: tokens.bgBase,
      appBar: AppBar(
        title: Text(AppStrings.getAllPurchasesTitle(widget.locale),
            style: AppTypography.title2.copyWith(color: tokens.fgStrong)),
        backgroundColor: tokens.bgBase,
        elevation: 0,
      ),
      body: _purchases == null
          ? const Center(child: CircularProgressIndicator())
          : _purchases!.isEmpty
              ? Center(
                  child: Text(AppStrings.getNoPurchaseData(widget.locale),
                      style: AppTypography.body2
                          .copyWith(color: tokens.fgTertiary)),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  children: [
                    for (final entry in grouped.entries) ...[
                      _DateHeader(
                        date: entry.key,
                        total: entry.value.fold<double>(
                            0, (sum, t) => sum + (t.price ?? 0)),
                        locale: widget.locale,
                        numberStyle: numberStyle,
                        tokens: tokens,
                      ),
                      for (final tx in entry.value)
                        Dismissible(
                          key: ValueKey(tx.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(),
                          onDismissed: (_) => _deletePurchase(tx),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                                right: AppSpacing.s16),
                            decoration: BoxDecoration(
                              color: tokens.negativeSoft,
                              borderRadius: AppRadius.brR12,
                            ),
                            child: Icon(Icons.delete_outline,
                                color: tokens.negative),
                          ),
                          child: _PurchaseRow(
                            tx: tx,
                            ingredient: ingredientsById[tx.ingredientId],
                            unitName: ingredientsById[tx.ingredientId] == null
                                ? ''
                                : state
                                        .unitsById[
                                            ingredientsById[tx.ingredientId]!
                                                .purchaseUnitId]
                                        ?.name ??
                                    '',
                            locale: widget.locale,
                            numberStyle: numberStyle,
                            tokens: tokens,
                            onTap: () => _editPurchase(tx),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.s12),
                    ],
                  ],
                ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  final double total;
  final AppLocale locale;
  final NumberFormatStyle numberStyle;
  final AppColorTokens tokens;

  const _DateHeader({
    required this.date,
    required this.total,
    required this.locale,
    required this.numberStyle,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppSpacing.s8, bottom: AppSpacing.s6),
      child: Row(
        children: [
          Text(date,
              style:
                  AppTypography.label1.copyWith(color: tokens.fgSecondary)),
          const Spacer(),
          Text(
            NumberFormatter.formatCurrency(total, locale, numberStyle),
            style: AppTypography.label1.copyWith(color: tokens.primary),
          ),
        ],
      ),
    );
  }
}

class _PurchaseRow extends StatelessWidget {
  final InventoryTransaction tx;
  final Ingredient? ingredient;
  final String unitName;
  final AppLocale locale;
  final NumberFormatStyle numberStyle;
  final AppColorTokens tokens;
  final VoidCallback onTap;

  const _PurchaseRow({
    required this.tx,
    required this.ingredient,
    required this.unitName,
    required this.locale,
    required this.numberStyle,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final qty = tx.qtyDelta == tx.qtyDelta.roundToDouble()
        ? tx.qtyDelta.toInt().toString()
        : tx.qtyDelta.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s6),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR12,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: InkWell(
        borderRadius: AppRadius.brR12,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  ingredient?.name ?? '—',
                  style:
                      AppTypography.body2.copyWith(color: tokens.fgStrong),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('$qty $unitName',
                  style: AppTypography.caption1
                      .copyWith(color: tokens.fgTertiary)),
              const SizedBox(width: AppSpacing.s12),
              Text(
                NumberFormatter.formatCurrency(
                    tx.price ?? 0, locale, numberStyle),
                style: AppTypography.label1.copyWith(color: tokens.fgStrong),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
