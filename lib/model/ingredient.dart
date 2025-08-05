import 'dart:developer' as developer;
import 'package:equatable/equatable.dart';
import 'dart:convert';

class Ingredient extends Equatable {
  final String id;
  final String name;
  final double purchasePrice;
  final double purchaseAmount;
  final String purchaseUnitId;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final List<String> tagIds; // 태그 ID 목록
  final double? animationX; // 애니메이션 X 위치
  final double? animationY; // 애니메이션 Y 위치
  final bool isAnimationSettled; // 애니메이션 정착 상태

  Ingredient({
    required this.id,
    required this.name,
    required this.purchasePrice,
    required this.purchaseAmount,
    required this.purchaseUnitId,
    this.expiryDate,
    required this.createdAt,
    this.tagIds = const [],
    this.animationX,
    this.animationY,
    this.isAnimationSettled = false,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    try {
      final json = {
        'id': id,
        'name': name,
        'purchase_price': purchasePrice,
        'purchase_amount': purchaseAmount,
        'purchase_unit_id': purchaseUnitId,
        'expiry_date': expiryDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'tag_ids': jsonEncode(tagIds), // List<String>을 JSON 문자열로 변환
        'animation_x': animationX,
        'animation_y': animationY,
        'is_animation_settled': isAnimationSettled ? 1 : 0,
      };

      return json;
    } catch (e) {
      rethrow;
    }
  }

  // JSON 역직렬화
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Ingredient fromJson 시작: $json', name: 'Ingredient');

      List<String> tagIds = [];

      // tag_ids가 문자열인 경우 JSON으로 파싱
      if (json['tag_ids'] != null) {
        if (json['tag_ids'] is String) {
          try {
            tagIds = List<String>.from(jsonDecode(json['tag_ids']));
          } catch (e) {
            // JSON 파싱 실패 시 쉼표로 구분된 문자열로 파싱 (하위 호환성)
            if (json['tag_ids'].toString().isNotEmpty) {
              tagIds = json['tag_ids'].toString().split(',');
            }
          }
        } else if (json['tag_ids'] is List) {
          // 기존 List 형태 지원 (하위 호환성)
          tagIds = List<String>.from(json['tag_ids']);
        }
      }

      final ingredient = Ingredient(
        id: json['id'],
        name: json['name'],
        purchasePrice: json['purchase_price'].toDouble(),
        purchaseAmount: json['purchase_amount'].toDouble(),
        purchaseUnitId: json['purchase_unit_id'],
        expiryDate: json['expiry_date'] != null
            ? DateTime.parse(json['expiry_date'])
            : null,
        createdAt: DateTime.parse(json['created_at']),
        tagIds: tagIds,
        animationX: json['animation_x']?.toDouble(),
        animationY: json['animation_y']?.toDouble(),
        isAnimationSettled: json['is_animation_settled'] == 1,
      );

      developer.log('Ingredient fromJson 완료', name: 'Ingredient');
      return ingredient;
    } catch (e) {
      developer.log('Ingredient fromJson 실패: $e', name: 'Ingredient');
      rethrow;
    }
  }

  // 복사본 생성 (수정 시 사용)
  Ingredient copyWith({
    String? id,
    String? name,
    double? purchasePrice,
    double? purchaseAmount,
    String? purchaseUnitId,
    DateTime? expiryDate,
    DateTime? createdAt,
    List<String>? tagIds,
    double? animationX,
    double? animationY,
    bool? isAnimationSettled,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseAmount: purchaseAmount ?? this.purchaseAmount,
      purchaseUnitId: purchaseUnitId ?? this.purchaseUnitId,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      tagIds: tagIds ?? this.tagIds,
      animationX: animationX ?? this.animationX,
      animationY: animationY ?? this.animationY,
      isAnimationSettled: isAnimationSettled ?? this.isAnimationSettled,
    );
  }

  // 태그 추가
  Ingredient addTag(String tagId) {
    if (!tagIds.contains(tagId)) {
      return copyWith(tagIds: [...tagIds, tagId]);
    }
    return this;
  }

  // 태그 제거
  Ingredient removeTag(String tagId) {
    return copyWith(tagIds: tagIds.where((id) => id != tagId).toList());
  }

  // 태그가 있는지 확인
  bool hasTag(String tagId) {
    return tagIds.contains(tagId);
  }

  // 태그 목록 업데이트
  Ingredient updateTags(List<String> newTagIds) {
    return copyWith(tagIds: newTagIds);
  }

  // 유통기한 상태 확인
  ExpiryStatus get expiryStatus {
    if (expiryDate == null) return ExpiryStatus.normal;

    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;

    if (daysUntilExpiry < 0) return ExpiryStatus.expired;
    if (daysUntilExpiry <= 1) return ExpiryStatus.danger;
    if (daysUntilExpiry <= 7) return ExpiryStatus.warning;
    return ExpiryStatus.normal;
  }

  // 기본 단위당 가격 계산
  double getPricePerBaseUnit(double conversionFactor) {
    return purchasePrice / (purchaseAmount * conversionFactor);
  }

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, price: $purchasePrice, amount: $purchaseAmount, tags: $tagIds)';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    purchasePrice,
    purchaseAmount,
    purchaseUnitId,
    expiryDate,
    createdAt,
    tagIds,
  ];
}

enum ExpiryStatus {
  normal, // 정상 (7일 이상)
  warning, // 경고 (3-7일)
  danger, // 위험 (1-3일)
  expired, // 만료
}
