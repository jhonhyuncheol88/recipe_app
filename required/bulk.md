import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/theme_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/headers/month_navigator.dart';
import '../cubit/bulk_edit_cubit.dart';
import '../cubit/bulk_edit_state.dart';
import '../widgets/bulk_edit_transaction_item.dart';

/// 일괄 수정 페이지
///
/// 월별 거래 내역을 일괄적으로 수정할 수 있는 페이지입니다.
class BulkEditPage extends StatelessWidget {
  final String ledgerId;
  final DateTime? month;

  const BulkEditPage({
    super.key,
    required this.ledgerId,
    this.month,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BulkEditCubit()
        ..loadMonthlyRecords(
          month ?? DateTime.now(),
          ledgerId,
        ),
      child: _BulkEditView(ledgerId: ledgerId, initialMonth: month ?? DateTime.now()),
    );
  }
}

class _BulkEditView extends StatelessWidget {
  final String ledgerId;
  final DateTime initialMonth;

  const _BulkEditView({
    required this.ledgerId,
    required this.initialMonth,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ThemeHelper.getColors(context);
    final fonts = ThemeHelper.getFonts(context);
    final l10n = AppLocalizations.of(context);

    return BlocListener<BulkEditCubit, BulkEditState>(
      listener: (context, state) {
        if (state is BulkEditSaved) {
          // 저장 완료 시 이전 페이지로 복귀 (결과를 true로 전달하여 새로고침 트리거)
          if (context.mounted) {
            context.pop(true);
          }
        } else if (state is BulkEditError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n?.bulkEditTitle ?? '월별 내역 일괄 수정',
            style: fonts.headlineMedium,
          ),
          actions: [
            BlocBuilder<BulkEditCubit, BulkEditState>(
              builder: (context, state) {
                final cubit = context.read<BulkEditCubit>();
                final isLoading = state is BulkEditSaving;
                final hasChanges = state is BulkEditLoaded &&
                    state.modifiedRecords.isNotEmpty;

                return TextButton(
                  onPressed: (isLoading || !hasChanges)
                      ? null
                      : () => cubit.saveAll(),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.primary,
                            ),
                          ),
                        )
                      : Text(
                          l10n?.save ?? '저장',
                          style: fonts.bodyLarge.copyWith(
                            color: hasChanges
                                ? colors.primary
                                : colors.textSecondary,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<BulkEditCubit, BulkEditState>(
          builder: (context, state) {
            if (state is BulkEditLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is BulkEditError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: colors.loss),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: fonts.bodyLarge.copyWith(
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final cubit = context.read<BulkEditCubit>();
                        if (state.previousState is BulkEditLoaded) {
                          final prevState = state.previousState as BulkEditLoaded;
                          cubit.loadMonthlyRecords(
                            prevState.month,
                            prevState.ledgerId,
                          );
                        }
                      },
                      child: Text(l10n?.btnCancel ?? '취소'),
                    ),
                  ],
                ),
              );
            } else if (state is BulkEditLoaded) {
              return Column(
                children: [
                  // 월 네비게이션
                  MonthNavigator(
                    currentMonth: state.month,
                    onPreviousMonth: () {
                      final prevMonth = DateTime(
                        state.month.year,
                        state.month.month - 1,
                      );
                      context.read<BulkEditCubit>().loadMonthlyRecords(
                            prevMonth,
                            ledgerId,
                          );
                    },
                    onNextMonth: () {
                      final nextMonth = DateTime(
                        state.month.year,
                        state.month.month + 1,
                      );
                      context.read<BulkEditCubit>().loadMonthlyRecords(
                            nextMonth,
                            ledgerId,
                          );
                    },
                    onMonthSelected: (selectedMonth) {
                      context.read<BulkEditCubit>().loadMonthlyRecords(
                            selectedMonth,
                            ledgerId,
                          );
                    },
                  ),
                  // 거래 목록
                  Expanded(
                    child: state.records.isEmpty
                        ? Center(
                            child: Text(
                              l10n?.noTransactions ?? '거래 내역이 없습니다',
                              style: fonts.bodyMedium.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.records.length,
                            itemBuilder: (context, index) {
                              final record = state.records[index];
                              // 수정된 버전이 있으면 그것을 사용, 없으면 원본 사용
                              final displayRecord =
                                  state.modifiedRecords[record.id] ?? record;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: BulkEditTransactionItem(
                                  key: ValueKey('${record.id}_${displayRecord.updatedAt.millisecondsSinceEpoch}'),
                                  record: displayRecord,
                                  originalRecord: record,
                                  ledgerId: ledgerId,
                                  onFieldChanged: (field, value) {
                                    context.read<BulkEditCubit>().updateRecordField(
                                          record.id,
                                          field,
                                          value,
                                        );
                                  },
                                  onDelete: () {
                                    // 삭제 기능은 나중에 구현
                                  },
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
      ),
    );
  }
}

