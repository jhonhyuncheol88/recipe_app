import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

final _log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// RevenueCat SDK 를 wrap 하는 싱글톤. 모든 결제/entitlement 흐름은 이걸로만
/// 호출한다. configure 가 끝나기 전에 다른 메서드를 부르면 [StateError].
///
/// API key 가 .env 에 없으면 [initialize] 가 silent skip 한다 ([isReady] = false).
/// 이 경우 호출자(PremiumCubit)는 광고 제거 기능을 비활성으로 둔다.
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  /// RevenueCat 대시보드의 entitlement / offering / package 식별자.
  /// 코드와 대시보드가 정확히 일치해야 한다.
  static const String premiumEntitlementId = 'premium';
  static const String defaultOfferingId = 'default';

  bool _initialized = false;
  final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  /// SDK 의 `addCustomerInfoUpdateListener` 를 wrap 한 stream. 백그라운드에서
  /// entitlement 가 바뀌어도 (다른 기기 결제 / webhook 갱신) 동일하게 emit.
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  /// configure 성공 여부. false 면 결제 기능을 노출하지 말 것.
  bool get isReady => _initialized;

  /// 앱 부팅 시 1회 호출. 이미 초기화됐으면 no-op.
  /// [initialAppUserId] 가 주어지면 anonymous 단계 없이 바로 그 ID 로 시작 —
  /// Firebase Auth 가 cached user 를 가진 부팅 시 race 를 방지한다.
  Future<void> initialize({String? initialAppUserId}) async {
    if (_initialized) return;

    final apiKey = _resolveApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      _log.w('[RevenueCat] API key 미설정 — 결제 기능 비활성');
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.warn);
      final config = PurchasesConfiguration(apiKey);
      if (initialAppUserId != null && initialAppUserId.isNotEmpty) {
        config.appUserID = initialAppUserId;
      }
      await Purchases.configure(config);
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      _initialized = true;
      _log.i(
        '[RevenueCat] configured (initialAppUserId=${initialAppUserId ?? "anon"})',
      );
    } catch (e, st) {
      _log.e('[RevenueCat] configure failed', error: e, stackTrace: st);
      // 부팅을 막지 않는다.
    }
  }

  /// 로그인된 Firebase UID 와 RevenueCat App User ID 를 매핑.
  /// 익명 사용자의 구매 이력이 있으면 SDK 가 자동 alias merge.
  Future<CustomerInfo> identify(String firebaseUid) async {
    _ensureReady();
    final result = await Purchases.logIn(firebaseUid);
    _log.i('[RevenueCat] logIn uid=$firebaseUid created=${result.created}');
    return result.customerInfo;
  }

  /// 현재 사용자를 익명으로 되돌림. 로그아웃 시 호출.
  Future<CustomerInfo> logout() async {
    _ensureReady();
    final info = await Purchases.logOut();
    _log.i('[RevenueCat] logOut');
    return info;
  }

  /// 기본 Offering 조회. ID 매칭 실패 시 current 로 fallback.
  Future<Offering?> fetchDefaultOffering() async {
    _ensureReady();
    final offerings = await Purchases.getOfferings();
    return offerings.getOffering(defaultOfferingId) ?? offerings.current;
  }

  Future<CustomerInfo> getCustomerInfo() {
    _ensureReady();
    return Purchases.getCustomerInfo();
  }

  /// 결제 진행. 사용자 취소·네트워크 등은 PlatformException 으로 던져지며
  /// 호출자(PremiumCubit) 가 [PurchasesErrorHelper.getErrorCode] 로 분류한다.
  Future<CustomerInfo> purchasePackage(Package package) async {
    _ensureReady();
    return Purchases.purchasePackage(package);
  }

  Future<CustomerInfo> restorePurchases() {
    _ensureReady();
    return Purchases.restorePurchases();
  }

  bool isEntitlementActive(
    CustomerInfo info, [
    String entitlementId = premiumEntitlementId,
  ]) {
    return info.entitlements.active.containsKey(entitlementId);
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    _log.d(
      '[RevenueCat] customerInfo updated active=${info.entitlements.active.keys.toList()}',
    );
    _customerInfoController.add(info);
  }

  String? _resolveApiKey() {
    if (kIsWeb) return null;
    if (Platform.isIOS || Platform.isMacOS) {
      return dotenv.env['REVENUECAT_IOS_KEY'];
    }
    if (Platform.isAndroid) {
      return dotenv.env['REVENUECAT_ANDROID_KEY'];
    }
    return null;
  }

  void _ensureReady() {
    if (!_initialized) {
      throw StateError(
        'RevenueCatService not initialized — call initialize() first',
      );
    }
  }
}
