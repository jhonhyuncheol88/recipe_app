import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/sauce/sauce_cubit.dart';
import '../../controller/sauce/sauce_state.dart';
import '../../controller/setting/locale_cubit.dart';
import '../../controller/setting/number_format_cubit.dart';
import '../../model/sauce.dart';
import '../../theme/tokens/tokens.dart';
import '../../util/app_strings.dart';
import '../../util/number_formatter.dart';

/// 소스 선택 바텀 시트.
///
/// 이미 선택된 소스는 [excludeIds] 로 전달해서 목록에서 제외한다.
/// 사용자가 한 항목을 탭하면 해당 [Sauce] 가 반환되고, X 또는 바깥 영역을
/// 탭해 닫으면 `null` 이 반환된다.
Future<Sauce?> showSaucePickerSheet(
  BuildContext context, {
  required List<String> excludeIds,
}) {
  final tokens = AppColorTokens.of(context);
  return showModalBottomSheet<Sauce>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: tokens.fgStrong.withValues(alpha: 0.4),
    builder: (sheetCtx) {
      return _SaucePickerSheet(excludeIds: excludeIds);
    },
  );
}

class _SaucePickerSheet extends StatelessWidget {
  final List<String> excludeIds;

  const _SaucePickerSheet({required this.excludeIds});

  List<Sauce> _saucesOf(SauceState state) {
    if (state is SauceLoaded) return state.sauces;
    if (state is SauceAdded) return state.sauces;
    if (state is SauceUpdatedState) return state.sauces;
    if (state is SauceDeleted) return state.sauces;
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.read<LocaleCubit>().state;
    final formatStyle = context.read<NumberFormatCubit>().state;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetCtx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: tokens.bgBase,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.r20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // 드래그 핸들
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.borderDefault,
                      borderRadius: AppRadius.brPill,
                    ),
                  ),
                ),
                // 타이틀 + X 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s12,
                    AppSpacing.s8,
                    AppSpacing.s8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.getSelectSauceSheet(locale),
                          style: AppTypography.heading2.copyWith(
                            color: tokens.fgStrong,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: tokens.fgSecondary),
                        tooltip: AppStrings.getClose(locale),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<SauceCubit, SauceState>(
                    builder: (ctx, state) {
                      if (state is SauceLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final all = _saucesOf(state);
                      final visible = all
                          .where((s) => !excludeIds.contains(s.id))
                          .toList();

                      if (visible.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.s24),
                            child: Text(
                              '추가할 소스가 없습니다',
                              style: AppTypography.body2.copyWith(
                                color: tokens.fgTertiary,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s20,
                          AppSpacing.s4,
                          AppSpacing.s20,
                          AppSpacing.s24,
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 6),
                        itemBuilder: (_, index) {
                          final sauce = visible[index];
                          // g 당 단가 표시 (소스 사용량은 g 기준).
                          final perGram =
                              '${NumberFormatter.formatCurrency(sauce.unitCost, locale, formatStyle)}/g';
                          return _SauceRow(
                            name: sauce.name,
                            subtitle: perGram,
                            onTap: () => Navigator.of(context).pop(sauce),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SauceRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  const _SauceRow({
    required this.name,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Material(
      color: tokens.bgMuted,
      borderRadius: AppRadius.brR12,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brR12,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: AppSpacing.s12,
          ),
          child: Row(
            children: [
              Icon(
                Icons.blender_outlined,
                size: 18,
                color: tokens.positive,
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTypography.headline2.copyWith(
                        color: tokens.fgStrong,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.label2.copyWith(
                        color: tokens.fgTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Icon(Icons.add, color: tokens.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
