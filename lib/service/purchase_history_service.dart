import 'dart:io' show Platform;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';

import '../model/purchase_event.dart';

final _log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// 결제·복원 이력을 Firestore `purchases/{uid}/events/{eventId}` 에 적재.
///
/// **클라이언트 적재는 디버깅·UX 용도** — 진실원천(SoT) 은 RevenueCat 서버.
/// Phase 7 의 webhook 이 같은 컬렉션에 적재하며, 클라이언트가 적재한 행과
/// webhook 행이 공존할 수 있다 (eventId 가 다르므로 충돌 X).
///
/// 비로그인 상태에서 호출되면 silent skip. 결제 흐름 자체에 영향을 주지
/// 않도록 모든 메서드가 Firestore 에러를 swallow 한다.
class PurchaseHistoryService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  PurchaseHistoryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> recordEvent({
    required String productId,
    required PurchaseEventStatus status,
    String? errorCode,
  }) async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) {
      _log.d('[PurchaseHistory] uid 없음 — skip ($productId / $status)');
      return;
    }

    final event = PurchaseEvent(
      id: _generateEventId(productId),
      timestamp: DateTime.now(),
      productId: productId,
      status: status,
      errorCode: errorCode,
      platform: _platform(),
    );

    try {
      await _firestore
          .collection('purchases')
          .doc(uid)
          .collection('events')
          .doc(event.id)
          .set(event.toJson());
      _log.i('[PurchaseHistory] recorded ${status.wireValue} ($productId)');
    } catch (e) {
      // 결제 흐름에 영향 X — 로그만.
      _log.w('[PurchaseHistory] write failed: $e');
    }
  }

  /// 사용자 본인의 이력 stream. `purchases/{uid}/events` 에서 timestamp DESC.
  Stream<List<PurchaseEvent>> watch() {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('purchases')
        .doc(uid)
        .collection('events')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PurchaseEvent.fromJson(d.id, d.data()))
            .toList());
  }

  String _generateEventId(String productId) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(0x7fffffff).toRadixString(36);
    final safeProduct = productId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return 'cli_${ts}_${safeProduct}_$rand';
  }

  String _platform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    return 'unknown';
  }
}
