import 'package:equatable/equatable.dart';

class ExpiryNotification extends Equatable {
  final String id;
  final String ingredientId;
  final String ingredientName;
  final DateTime expiryDate;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  ExpiryNotification({
    required this.id,
    required this.ingredientId,
    required this.ingredientName,
    required this.expiryDate,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredient_id': ingredientId,
      'ingredient_name': ingredientName,
      'expiry_date': expiryDate.toIso8601String(),
      'type': type.name,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory ExpiryNotification.fromJson(Map<String, dynamic> json) {
    return ExpiryNotification(
      id: json['id'],
      ingredientId: json['ingredient_id'],
      ingredientName: json['ingredient_name'],
      expiryDate: DateTime.parse(json['expiry_date']),
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.warning,
      ),
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // 복사본 생성
  ExpiryNotification copyWith({
    String? id,
    String? ingredientId,
    String? ingredientName,
    DateTime? expiryDate,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return ExpiryNotification(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientName: ingredientName ?? this.ingredientName,
      expiryDate: expiryDate ?? this.expiryDate,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // 읽음 상태로 변경
  ExpiryNotification markAsRead() {
    return copyWith(isRead: true);
  }

  // 남은 일수 계산
  int get daysUntilExpiry {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  // 긴급도 레벨 (1: 낮음, 3: 높음)
  int get urgencyLevel {
    switch (type) {
      case NotificationType.warning:
        return 1;
      case NotificationType.danger:
        return 2;
      case NotificationType.expired:
        return 3;
    }
  }

  // 알림 메시지 생성
  String get message {
    switch (type) {
      case NotificationType.warning:
        return '$ingredientName의 유통기한이 ${daysUntilExpiry}일 후에 만료됩니다.';
      case NotificationType.danger:
        return '$ingredientName의 유통기한이 ${daysUntilExpiry}일 후에 만료됩니다!';
      case NotificationType.expired:
        return '$ingredientName의 유통기한이 만료되었습니다.';
    }
  }

  @override
  String toString() {
    return 'ExpiryNotification(id: $id, ingredient: $ingredientName, type: $type, daysLeft: $daysUntilExpiry)';
  }

  @override
  List<Object?> get props => [
    id,
    ingredientId,
    ingredientName,
    expiryDate,
    type,
    isRead,
    createdAt,
  ];
}

enum NotificationType {
  warning, // 경고 (3-7일 전)
  danger, // 위험 (1-3일 전)
  expired, // 만료
}
