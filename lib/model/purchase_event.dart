import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// 결제·복원 이력의 결과 분류. Firestore 의 status 필드 string 으로 저장.
enum PurchaseEventStatus {
  /// 첫 결제 성공.
  success,

  /// 복원 성공 (이미 구매한 사용자가 재설치/다른 기기에서 복원).
  restored,

  /// 사용자가 IAP 다이얼로그를 닫음.
  cancelled,

  /// Ask to Buy 등 결제 보류.
  pending,

  /// 네트워크 / 스토어 / 알 수 없는 오류.
  failed;

  String get wireValue {
    switch (this) {
      case PurchaseEventStatus.success:
        return 'success';
      case PurchaseEventStatus.restored:
        return 'restored';
      case PurchaseEventStatus.cancelled:
        return 'cancelled';
      case PurchaseEventStatus.pending:
        return 'pending';
      case PurchaseEventStatus.failed:
        return 'failed';
    }
  }

  static PurchaseEventStatus fromWire(String value) {
    return PurchaseEventStatus.values.firstWhere(
      (s) => s.wireValue == value,
      orElse: () => PurchaseEventStatus.failed,
    );
  }
}

/// `purchases/{uid}/events/{eventId}` 문서 한 행.
class PurchaseEvent extends Equatable {
  final String id;
  final DateTime timestamp;
  final String productId;
  final PurchaseEventStatus status;
  final String? errorCode;
  final String platform; // 'ios' | 'android'

  const PurchaseEvent({
    required this.id,
    required this.timestamp,
    required this.productId,
    required this.status,
    this.errorCode,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': Timestamp.fromDate(timestamp),
      'productId': productId,
      'status': status.wireValue,
      if (errorCode != null) 'errorCode': errorCode,
      'platform': platform,
    };
  }

  factory PurchaseEvent.fromJson(String id, Map<String, dynamic> json) {
    final ts = json['timestamp'];
    DateTime timestamp;
    if (ts is Timestamp) {
      timestamp = ts.toDate();
    } else if (ts is String) {
      timestamp = DateTime.tryParse(ts) ?? DateTime.now();
    } else {
      timestamp = DateTime.now();
    }

    return PurchaseEvent(
      id: id,
      timestamp: timestamp,
      productId: (json['productId'] as String?) ?? '',
      status: PurchaseEventStatus.fromWire(
        (json['status'] as String?) ?? 'failed',
      ),
      errorCode: json['errorCode'] as String?,
      platform: (json['platform'] as String?) ?? 'unknown',
    );
  }

  @override
  List<Object?> get props => [id, timestamp, productId, status, errorCode, platform];
}
