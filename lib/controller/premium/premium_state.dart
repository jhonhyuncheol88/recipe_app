import 'package:equatable/equatable.dart';

/// 결제/entitlement 흐름의 실패 분류. UI 가 SnackBar/다이얼로그 메시지를
/// 결정하는 데 사용한다.
enum PremiumErrorKind {
  /// 사용자가 IAP 다이얼로그에서 취소. 조용히 처리.
  userCancelled,

  /// 보호자 승인 대기 등 결제 보류.
  paymentPending,

  /// 네트워크 단절 / 일시 오류.
  network,

  /// 스토어 자체 문제 (App Store / Play Store).
  store,

  /// 같은 product 가 이미 구매됨 — 복원 안내.
  alreadyPurchased,

  /// RevenueCat SDK 초기화 실패 (.env 키 미설정 등).
  notReady,

  /// 분류 불가.
  unknown,
}

abstract class PremiumState extends Equatable {
  const PremiumState();

  /// UI 가 광고/리포트 게이팅에 사용. PremiumActive 만 true.
  bool get isPremium => this is PremiumActive;

  @override
  List<Object?> get props => [];
}

/// 부팅 직후, getCustomerInfo 호출 전.
class PremiumUnknown extends PremiumState {
  const PremiumUnknown();
}

/// getCustomerInfo 진행 중.
class PremiumChecking extends PremiumState {
  const PremiumChecking();
}

/// 결제하지 않은 일반 사용자 또는 entitlement 만료.
class PremiumFree extends PremiumState {
  const PremiumFree();
}

/// premium entitlement 활성. 광고 미노출.
class PremiumActive extends PremiumState {
  final String? productId;
  final DateTime? originalPurchaseDate;

  const PremiumActive({this.productId, this.originalPurchaseDate});

  @override
  List<Object?> get props => [productId, originalPurchaseDate];
}

/// 결제 다이얼로그가 열려 있고 결과 대기 중. UI 잠금.
class PremiumPurchasing extends PremiumState {
  const PremiumPurchasing();
}

/// restorePurchases 진행 중. UI 잠금.
class PremiumRestoring extends PremiumState {
  const PremiumRestoring();
}

/// 일시적 에러. UI 가 listener 로 SnackBar 한 번 띄우고, cubit 은 자동으로
/// 마지막 알려진 entitlement 상태로 settle 한다.
class PremiumError extends PremiumState {
  final PremiumErrorKind kind;
  final String? message;

  const PremiumError(this.kind, [this.message]);

  @override
  List<Object?> get props => [kind, message];
}
