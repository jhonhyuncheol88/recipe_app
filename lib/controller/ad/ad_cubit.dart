import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// 광고 상태를 관리하는 Cubit
class AdCubit extends Cubit<AdState> {
  late final Logger _logger;

  AdCubit() : super(AdInitial()) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }

  /// 광고 로딩 시작
  void startAdLoading() {
    _logger.i('광고 로딩 시작');
    print('AdCubit: 광고 로딩 시작');
    emit(AdLoading());
  }

  /// 광고 로딩 완료
  void adLoaded() {
    _logger.i('광고 로딩 완료');
    print('AdCubit: 광고 로딩 완료');
    emit(AdLoaded());
  }

  /// 광고 표시 시작
  void startAdShowing() {
    _logger.i('광고 표시 시작');
    print('AdCubit: 광고 표시 시작');
    emit(AdShowing());
  }

  /// 광고 시청 완료
  void adWatched() {
    _logger.i('광고 시청 완료');
    print('AdCubit: 광고 시청 완료');
    emit(AdWatched());
  }

  /// 광고 실패
  void adFailed(String error) {
    _logger.e('광고 실패: $error');
    print('AdCubit: 광고 실패 - $error');
    emit(AdFailed(error));
  }

  /// 광고 상태 초기화
  void reset() {
    _logger.d('광고 상태 초기화');
    print('AdCubit: 광고 상태 초기화');
    emit(AdInitial());
  }

  @override
  void onChange(Change<AdState> change) {
    super.onChange(change);
    _logger.d(
      '광고 상태 변경: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
    );
    print(
      'AdCubit 상태 변경: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
    );
  }
}

/// 광고 상태를 나타내는 추상 클래스
abstract class AdState {
  const AdState();
}

/// 초기 상태
class AdInitial extends AdState {
  const AdInitial();
}

/// 광고 로딩 중
class AdLoading extends AdState {
  const AdLoading();
}

/// 광고 로딩 완료
class AdLoaded extends AdState {
  const AdLoaded();
}

/// 광고 표시 중
class AdShowing extends AdState {
  const AdShowing();
}

/// 광고 시청 완료
class AdWatched extends AdState {
  const AdWatched();
}

/// 광고 실패
class AdFailed extends AdState {
  final String error;
  const AdFailed(this.error);
}
