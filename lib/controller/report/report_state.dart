import 'package:equatable/equatable.dart';
import '../../model/report_data.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportLoaded extends ReportState {
  final ReportData data;
  final ReportPeriod period;
  final DateTime? anchorMonth; // monthly 모드에서 사용자가 고른 월 (null = 현재)

  const ReportLoaded({
    required this.data,
    required this.period,
    this.anchorMonth,
  });

  @override
  List<Object?> get props => [data, period, anchorMonth];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
