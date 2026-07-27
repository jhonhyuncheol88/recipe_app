import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/inventory_repository.dart';
import '../../model/index.dart';

/// 리포트 탭 "구매 지출" 카드 전용 상태.
class PurchaseReportState extends Equatable {
  final bool isLoading;
  final PurchasePeriod period;
  final List<({String label, double total})> totals;
  final String? error;

  const PurchaseReportState({
    this.isLoading = true,
    this.period = PurchasePeriod.daily,
    this.totals = const [],
    this.error,
  });

  /// 표시 중인 기간 전체 합계
  double get periodTotal =>
      totals.fold<double>(0, (sum, row) => sum + row.total);

  PurchaseReportState copyWith({
    bool? isLoading,
    PurchasePeriod? period,
    List<({String label, double total})>? totals,
    String? Function()? error,
  }) {
    return PurchaseReportState(
      isLoading: isLoading ?? this.isLoading,
      period: period ?? this.period,
      totals: totals ?? this.totals,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, period, totals, error];
}

/// 구매 지출 집계 로드. 리포트 페이지 로컬 BlocProvider 로 생성된다.
class PurchaseReportCubit extends Cubit<PurchaseReportState> {
  final InventoryRepository _repository;

  PurchaseReportCubit({InventoryRepository? repository})
      : _repository = repository ?? InventoryRepository(),
        super(const PurchaseReportState());

  Future<void> load([PurchasePeriod? period]) async {
    final target = period ?? state.period;
    emit(state.copyWith(isLoading: true, period: target, error: () => null));
    try {
      final totals = await _repository.getPurchaseTotals(target);
      emit(state.copyWith(isLoading: false, totals: totals));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: () => e.toString()));
    }
  }
}
