import 'package:equatable/equatable.dart';

class Unit extends Equatable {
  final String id;
  final String name;
  final String type;
  final String? baseUnitId;
  final double conversionFactor;

  Unit({
    required this.id,
    required this.name,
    required this.type,
    this.baseUnitId,
    required this.conversionFactor,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'base_unit_id': baseUnitId,
      'conversion_factor': conversionFactor,
    };
  }

  // JSON 역직렬화
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      baseUnitId: json['base_unit_id'],
      conversionFactor: json['conversion_factor'].toDouble(),
    );
  }

  // 복사본 생성
  Unit copyWith({
    String? id,
    String? name,
    String? type,
    String? baseUnitId,
    double? conversionFactor,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      baseUnitId: baseUnitId ?? this.baseUnitId,
      conversionFactor: conversionFactor ?? this.conversionFactor,
    );
  }

  // 단위 변환 메서드
  double convert(double value, Unit targetUnit) {
    // 현재 단위를 기본 단위로 변환
    double baseValue = value * conversionFactor;
    // 기본 단위에서 목표 단위로 변환
    return baseValue / targetUnit.conversionFactor;
  }

  // 단위 타입 확인 메서드들
  bool get isWeight => type == 'weight';
  bool get isVolume => type == 'volume';
  bool get isCount => type == 'count';

  @override
  String toString() {
    return 'Unit(id: $id, name: $name, type: $type, conversionFactor: $conversionFactor)';
  }

  @override
  List<Object?> get props => [id, name, type, baseUnitId, conversionFactor];
}

enum UnitType {
  weight, // 무게 (g, kg, lb 등)
  volume, // 부피 (ml, L, cup 등)
  count, // 개수 (개, 마리, 장 등)
}
