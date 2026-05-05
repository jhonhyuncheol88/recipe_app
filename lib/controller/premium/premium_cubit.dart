import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../model/purchase_event.dart';
import '../../service/purchase_history_service.dart';
import '../../service/revenue_cat_service.dart';
import 'premium_state.dart';

final _log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// 광고 제거 entitlement 의 현재 상태를 보유하는 전역 Cubit.
///
/// 진실원천(SoT) 우선순위:
///   1. RevenueCat SDK 의 entitlement (RC 서버 검증 결과)
///   2. SDK 의 customerInfoStream (백그라운드 변경 감지)
///   3. (Phase 6 이후) Firestore isPremium 캐시 — 오프라인 fallback only
///
/// AuthBloc 변화는 main.dart 의 BlocListener 가 RC.identify/logout 호출 →
/// SDK 의 customerInfoStream emit → 이 cubit 이 자동 갱신. 즉 PremiumCubit
/// 는 AuthBloc 에 직접 의존하지 않는다.
class PremiumCubit extends Cubit<PremiumState> {
  final RevenueCatService _rc;
  final PurchaseHistoryService? _history;
  StreamSubscription<CustomerInfo>? _streamSub;

  PremiumCubit({
    required RevenueCatService rc,
    PurchaseHistoryService? history,
  })  : _rc = rc,
        _history = history,
        super(const PremiumUnknown()) {
    if (rc.isReady) {
      _streamSub = rc.customerInfoStream.listen(_onCustomerInfoUpdated);
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// 앱 부팅 시 1회 호출. RC SDK 가 ready 가 아니면 즉시 Free 로 emit.
  Future<void> bootstrap() async {
    if (!_rc.isReady) {
      emit(const PremiumFree());
      return;
    }
    emit(const PremiumChecking());
    try {
      final info = await _rc.getCustomerInfo();
      _emitFromCustomerInfo(info);
    } catch (e, st) {
      _log.w('[bootstrap] $e', stackTrace: st);
      emit(const PremiumFree());
    }
  }

  /// 사용자가 명시적 새로고침 (e.g. 결제 페이지 재진입).
  Future<void> refreshFromStore() async {
    if (!_rc.isReady) return;
    try {
      final info = await _rc.getCustomerInfo();
      _emitFromCustomerInfo(info);
    } catch (e) {
      _log.w('[refreshFromStore] $e');
    }
  }

  /// 결제 진행. 진행 중 중복 호출은 무시 (요구 5/6 — 이중 탭 방지).
  Future<void> purchase(Package package) async {
    if (!_rc.isReady) {
      emit(const PremiumError(PremiumErrorKind.notReady));
      await _settleAfterError();
      return;
    }
    if (state is PremiumPurchasing || state is PremiumRestoring) {
      _log.d('[purchase] busy — ignored');
      return;
    }

    final productId = package.storeProduct.identifier;
    emit(const PremiumPurchasing());
    try {
      final info = await _rc.purchasePackage(package);
      _emitFromCustomerInfo(info);
      await _history?.recordEvent(
        productId: productId,
        status: PurchaseEventStatus.success,
      );
    } catch (e) {
      final kind = _classifyError(e);
      _log.w('[purchase] kind=$kind error=$e');
      emit(PremiumError(kind, e.toString()));
      await _history?.recordEvent(
        productId: productId,
        status: _statusForErrorKind(kind),
        errorCode: kind.name,
      );
      await _settleAfterError();
    }
  }

  /// 다른 기기 / 재설치 환경에서 이전 구매 복원.
  Future<void> restore() async {
    if (!_rc.isReady) {
      emit(const PremiumError(PremiumErrorKind.notReady));
      await _settleAfterError();
      return;
    }
    if (state is PremiumPurchasing || state is PremiumRestoring) {
      _log.d('[restore] busy — ignored');
      return;
    }

    emit(const PremiumRestoring());
    try {
      final info = await _rc.restorePurchases();
      _emitFromCustomerInfo(info);
      // entitlement 활성 시에만 복원 이벤트로 기록 — Free 결과는 의미 없음
      if (_rc.isEntitlementActive(info)) {
        final entitlement = info
            .entitlements.active[RevenueCatService.premiumEntitlementId];
        await _history?.recordEvent(
          productId: entitlement?.productIdentifier ?? '',
          status: PurchaseEventStatus.restored,
        );
      }
    } catch (e) {
      final kind = _classifyError(e);
      _log.w('[restore] kind=$kind error=$e');
      emit(PremiumError(kind, e.toString()));
      await _history?.recordEvent(
        productId: '',
        status: _statusForErrorKind(kind),
        errorCode: kind.name,
      );
      await _settleAfterError();
    }
  }

  PurchaseEventStatus _statusForErrorKind(PremiumErrorKind kind) {
    switch (kind) {
      case PremiumErrorKind.userCancelled:
        return PurchaseEventStatus.cancelled;
      case PremiumErrorKind.paymentPending:
        return PurchaseEventStatus.pending;
      case PremiumErrorKind.network:
      case PremiumErrorKind.store:
      case PremiumErrorKind.alreadyPurchased:
      case PremiumErrorKind.notReady:
      case PremiumErrorKind.unknown:
        return PurchaseEventStatus.failed;
    }
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// SDK 의 customerInfoStream 콜백. 진행 중 상태에서 들어온 emit 은
  /// 무시 — 진행 중인 메서드가 결과를 직접 처리한다.
  void _onCustomerInfoUpdated(CustomerInfo info) {
    if (state is PremiumPurchasing || state is PremiumRestoring) return;
    _emitFromCustomerInfo(info);
  }

  void _emitFromCustomerInfo(CustomerInfo info) {
    final entitlement =
        info.entitlements.active[RevenueCatService.premiumEntitlementId];
    if (entitlement == null) {
      emit(const PremiumFree());
      return;
    }
    emit(PremiumActive(
      productId: entitlement.productIdentifier,
      originalPurchaseDate: DateTime.tryParse(entitlement.originalPurchaseDate),
    ));
  }

  /// 에러 emit 직후 마지막 알려진 entitlement 으로 settle. 사용자 취소면
  /// 이전 상태(Free 또는 Active) 로 자연스럽게 복귀한다.
  Future<void> _settleAfterError() async {
    if (!_rc.isReady) {
      emit(const PremiumFree());
      return;
    }
    try {
      final info = await _rc.getCustomerInfo();
      _emitFromCustomerInfo(info);
    } catch (_) {
      emit(const PremiumFree());
    }
  }

  PremiumErrorKind _classifyError(Object e) {
    if (e is PlatformException) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      switch (code) {
        case PurchasesErrorCode.purchaseCancelledError:
          return PremiumErrorKind.userCancelled;
        case PurchasesErrorCode.paymentPendingError:
          return PremiumErrorKind.paymentPending;
        case PurchasesErrorCode.networkError:
          return PremiumErrorKind.network;
        case PurchasesErrorCode.storeProblemError:
          return PremiumErrorKind.store;
        case PurchasesErrorCode.productAlreadyPurchasedError:
          return PremiumErrorKind.alreadyPurchased;
        default:
          return PremiumErrorKind.unknown;
      }
    }
    return PremiumErrorKind.unknown;
  }

  @override
  Future<void> close() async {
    await _streamSub?.cancel();
    return super.close();
  }
}
