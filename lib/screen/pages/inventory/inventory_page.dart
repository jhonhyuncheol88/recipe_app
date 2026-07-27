import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/index.dart';
import '../../../model/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_formatter.dart';

/// 재고 탭 메인. 위치 세그먼트 + 인라인 스테퍼 목록 + 하단 액션.
class InventoryMainPage extends StatelessWidget {
  const InventoryMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, locale) {
        return Scaffold(
          backgroundColor: tokens.bgBase,
          appBar: AppBar(
            title: Text(AppStrings.getInventory(locale),
                style: AppTypography.title2.copyWith(color: tokens.fgStrong)),
            backgroundColor: tokens.bgBase,
            elevation: 0,
          ),
          body: BlocBuilder<InventoryCubit, InventoryState>(
            builder: (context, state) {
              if (state.isLoading && state.ingredients.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  _SummaryCard(state: state, locale: locale),
                  _LocationSegments(state: state, locale: locale),
                  Expanded(
                    child: state.filteredIngredients.isEmpty
                        ? _EmptyView(locale: locale)
                        : _IngredientList(state: state, locale: locale),
                  ),
                  _BottomActions(locale: locale),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// 상단 요약: 오늘 구매 총액 · 변동 건수
class _SummaryCard extends StatelessWidget {
  final InventoryState state;
  final AppLocale locale;
  const _SummaryCard({required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final formatStyle = context.watch<NumberFormatCubit>().state;
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.s16, AppSpacing.s8, AppSpacing.s16, AppSpacing.s8),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR12,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(Icons.shopping_cart_outlined, size: 20, color: tokens.primary),
          const SizedBox(width: AppSpacing.s8),
          Text(
            '${AppStrings.getInventoryTodayPurchase(locale)} '
            '${NumberFormatter.formatCurrency(state.todayPurchaseTotal, locale, formatStyle)}',
            style: AppTypography.label1.copyWith(color: tokens.fgStrong),
          ),
          const Spacer(),
          Text(
            AppStrings.getInventoryTodayChanges(locale, state.todayTxCount),
            style: AppTypography.caption1.copyWith(color: tokens.fgTertiary),
          ),
        ],
      ),
    );
  }
}

/// 위치 세그먼트: 선반장 | 냉장고 | 냉동고 | 미분류(n)
class _LocationSegments extends StatelessWidget {
  final InventoryState state;
  final AppLocale locale;
  const _LocationSegments({required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final cubit = context.read<InventoryCubit>();

    Widget chip(String label, StorageLocation? value, {int? badge}) {
      final selected = state.selectedLocation == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => cubit.selectLocation(value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
            decoration: BoxDecoration(
              color: selected ? tokens.primary : tokens.bgMuted,
              borderRadius: AppRadius.brR8,
            ),
            alignment: Alignment.center,
            child: Text(
              badge != null && badge > 0 ? '$label($badge)' : label,
              style: AppTypography.label2.copyWith(
                color: selected ? Colors.white : tokens.fgSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16, vertical: AppSpacing.s4),
      child: Row(
        children: [
          chip(AppStrings.getInventoryShelf(locale), StorageLocation.shelf),
          const SizedBox(width: AppSpacing.s6),
          chip(AppStrings.getInventoryFridge(locale), StorageLocation.fridge),
          const SizedBox(width: AppSpacing.s6),
          chip(
              AppStrings.getInventoryFreezer(locale), StorageLocation.freezer),
          const SizedBox(width: AppSpacing.s6),
          chip(AppStrings.getInventoryUnsorted(locale), null,
              badge: state.unsortedCount),
        ],
      ),
    );
  }
}

/// 재료 목록. 분류된 세그먼트 = 스테퍼 행, 미분류 = 위치 지정 칩 행.
class _IngredientList extends StatelessWidget {
  final InventoryState state;
  final AppLocale locale;
  const _IngredientList({required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final isUnsorted = state.selectedLocation == null;
    final items = state.filteredIngredients;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
      itemBuilder: (context, index) {
        final ingredient = items[index];
        return isUnsorted
            ? _UnsortedRow(ingredient: ingredient, locale: locale)
            : _StepperRow(
                ingredient: ingredient, state: state, locale: locale);
      },
    );
  }
}

/// 분류된 재료 행: 이름 + [-] 잔량 단위 [+]
class _StepperRow extends StatelessWidget {
  final Ingredient ingredient;
  final InventoryState state;
  final AppLocale locale;
  const _StepperRow(
      {required this.ingredient, required this.state, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final cubit = context.read<InventoryCubit>();
    final qty = state.items[ingredient.id]?.currentQty ?? 0.0;
    final unitName = state.unitsById[ingredient.purchaseUnitId]?.name ?? '';
    // 소수점 불필요 시 정수 표기
    final qtyText = qty == qty.roundToDouble()
        ? qty.toInt().toString()
        : qty.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR12,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(ingredient.name,
                style: AppTypography.body1.copyWith(color: tokens.fgStrong),
                overflow: TextOverflow.ellipsis),
          ),
          _RoundIconButton(
            icon: Icons.remove,
            onTap: () =>
                _changeWithUndo(context, () => cubit.decrement(ingredient.id)),
          ),
          GestureDetector(
            onTap: () => _showQtyInputDialog(context, cubit),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              child: Text('$qtyText $unitName',
                  style:
                      AppTypography.label1.copyWith(color: tokens.fgStrong)),
            ),
          ),
          _RoundIconButton(
            icon: Icons.add,
            onTap: () =>
                _changeWithUndo(context, () => cubit.increment(ingredient.id)),
          ),
        ],
      ),
    );
  }

  /// 변경 실행 + 실행취소 스낵바 (이전 잔량으로 setQuantity 복원)
  void _changeWithUndo(
      BuildContext context, Future<void> Function() action) async {
    final cubit = context.read<InventoryCubit>();
    final previousQty = cubit.state.items[ingredient.id]?.currentQty ?? 0.0;
    await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(AppStrings.getInventoryQtyUpdated(locale)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: AppStrings.getUndo(locale),
          onPressed: () => cubit.setQuantity(ingredient.id, previousQty),
        ),
      ));
  }

  /// 숫자패드 직접 입력
  void _showQtyInputDialog(BuildContext context, InventoryCubit cubit) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppStrings.getInventoryEnterQty(locale)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText:
                cubit.state.unitsById[ingredient.purchaseUnitId]?.name ?? '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () {
              final qty = double.tryParse(controller.text);
              if (qty != null) {
                cubit.setQuantity(ingredient.id, qty);
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text(AppStrings.getConfirm(locale)),
          ),
        ],
      ),
    );
  }
}

/// 미분류 재료 행: 이름 + 위치 지정 칩 3개
class _UnsortedRow extends StatelessWidget {
  final Ingredient ingredient;
  final AppLocale locale;
  const _UnsortedRow({required this.ingredient, required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final cubit = context.read<InventoryCubit>();

    Widget chip(String label, StorageLocation location) {
      return GestureDetector(
        onTap: () => cubit.classifyIngredient(ingredient.id, location),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
          decoration: BoxDecoration(
            color: tokens.primarySoft,
            borderRadius: AppRadius.brPill,
          ),
          child: Text(label,
              style: AppTypography.caption1.copyWith(color: tokens.primary)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR12,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(ingredient.name,
                style: AppTypography.body1.copyWith(color: tokens.fgStrong),
                overflow: TextOverflow.ellipsis),
          ),
          chip(AppStrings.getInventoryShelf(locale), StorageLocation.shelf),
          const SizedBox(width: AppSpacing.s4),
          chip(AppStrings.getInventoryFridge(locale), StorageLocation.fridge),
          const SizedBox(width: AppSpacing.s4),
          chip(
              AppStrings.getInventoryFreezer(locale), StorageLocation.freezer),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brPill,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: tokens.bgMuted,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: tokens.fgSecondary),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final AppLocale locale;
  const _EmptyView({required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Center(
      child: Text(AppStrings.getInventoryEmpty(locale),
          style: AppTypography.body2.copyWith(color: tokens.fgTertiary)),
    );
  }
}

/// 하단 액션: AI 재고 스캔 · 구매 기록 (Task 7/9 에서 onPressed 연결)
class _BottomActions extends StatelessWidget {
  final AppLocale locale;
  const _BottomActions({required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.accentAi,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                ),
                onPressed: () => onAiScanPressed(context, locale),
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: Text(AppStrings.getInventoryAiScan(locale),
                    style: AppTypography.label1),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                ),
                onPressed: () => onPurchasePressed(context, locale),
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                label: Text(AppStrings.getInventoryRecordPurchase(locale),
                    style: AppTypography.label1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Task 9 에서 실제 흐름으로 교체. 이 Task 에서는 no-op.
  void onAiScanPressed(BuildContext context, AppLocale locale) {}

  /// Task 7 에서 실제 흐름으로 교체. 이 Task 에서는 no-op.
  void onPurchasePressed(BuildContext context, AppLocale locale) {}
}
