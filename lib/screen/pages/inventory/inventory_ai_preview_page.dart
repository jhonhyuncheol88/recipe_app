import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/index.dart';
import '../../../model/index.dart';
import '../../../service/inventory_gemini_service.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';

/// AI 재고 스캔 미리보기. 행별 체크 → 확인 시 일괄 반영.
class InventoryAiPreviewPage extends StatefulWidget {
  final List<InventoryAiRow> rows;
  final AppLocale locale;

  const InventoryAiPreviewPage({
    super.key,
    required this.rows,
    required this.locale,
  });

  @override
  State<InventoryAiPreviewPage> createState() =>
      _InventoryAiPreviewPageState();
}

class _InventoryAiPreviewPageState extends State<InventoryAiPreviewPage> {
  late final List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(widget.rows.length, true);
  }

  /// 이름으로 기존 재료 매칭 (정확 일치 우선, 없으면 contains)
  Ingredient? _match(InventoryState state, String name) {
    final exact =
        state.ingredients.where((i) => i.name == name).firstOrNull;
    if (exact != null) return exact;
    return state.ingredients
        .where((i) => i.name.contains(name) || name.contains(i.name))
        .firstOrNull;
  }

  Future<void> _apply() async {
    final cubit = context.read<InventoryCubit>();
    final state = cubit.state;
    final items = <InventoryAiApplyItem>[];
    for (var i = 0; i < widget.rows.length; i++) {
      if (!_checked[i]) continue;
      final row = widget.rows[i];
      final matched = _match(state, row.name);
      items.add(InventoryAiApplyItem(
        ingredientId: matched?.id,
        name: row.name,
        qty: row.qty,
        unitName: row.unit,
      ));
    }
    await cubit.applyAiAdjustments(items);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final state = context.watch<InventoryCubit>().state;
    final locale = widget.locale;

    return Scaffold(
      backgroundColor: tokens.bgBase,
      appBar: AppBar(
        title: Text(AppStrings.getInventoryAiPreviewTitle(locale),
            style: AppTypography.title2.copyWith(color: tokens.fgStrong)),
        backgroundColor: tokens.bgBase,
        elevation: 0,
      ),
      body: widget.rows.isEmpty
          ? Center(
              child: Text(AppStrings.getInventoryNoAiResults(locale),
                  style:
                      AppTypography.body2.copyWith(color: tokens.fgTertiary)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.s16),
              itemCount: widget.rows.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.s8),
              itemBuilder: (context, index) {
                final row = widget.rows[index];
                final matched = _match(state, row.name);
                final currentQty = matched == null
                    ? null
                    : (state.items[matched.id]?.currentQty ?? 0.0);

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12, vertical: AppSpacing.s4),
                  decoration: BoxDecoration(
                    color: tokens.bgElev1,
                    borderRadius: AppRadius.brR12,
                    border: Border.all(color: tokens.borderSubtle),
                  ),
                  child: CheckboxListTile(
                    value: _checked[index],
                    onChanged: (v) =>
                        setState(() => _checked[index] = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(row.name,
                              style: AppTypography.body1
                                  .copyWith(color: tokens.fgStrong),
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (matched == null) ...[
                          const SizedBox(width: AppSpacing.s6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s6,
                                vertical: AppSpacing.s2),
                            decoration: BoxDecoration(
                              color: tokens.accentAiSoft,
                              borderRadius: AppRadius.brPill,
                            ),
                            child: Text(
                                AppStrings.getInventoryNewIngredient(locale),
                                style: AppTypography.caption2
                                    .copyWith(color: tokens.accentAi)),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      matched == null
                          ? '${AppStrings.getInventoryAiGuess(locale)} '
                              '${row.qty} ${row.unit}'
                          : '${AppStrings.getInventoryCurrent(locale)} '
                              '$currentQty → '
                              '${AppStrings.getInventoryAiGuess(locale)} '
                              '${row.qty}',
                      style: AppTypography.caption1
                          .copyWith(color: tokens.fgTertiary),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: tokens.primary,
              padding:
                  const EdgeInsets.symmetric(vertical: AppSpacing.s12),
            ),
            onPressed: widget.rows.isEmpty ? null : _apply,
            child: Text(AppStrings.getInventoryApply(locale),
                style: AppTypography.label1),
          ),
        ),
      ),
    );
  }
}
