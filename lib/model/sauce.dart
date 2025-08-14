import 'package:equatable/equatable.dart';

class Sauce extends Equatable {
  final String id;
  final String name;
  final String description;
  final double totalWeight; // g 또는 ml 기준 총중량
  final double totalCost; // 총 원가 (₩)
  final String? imagePath;
  final DateTime createdAt;

  const Sauce({
    required this.id,
    required this.name,
    this.description = '',
    required this.totalWeight,
    required this.totalCost,
    this.imagePath,
    required this.createdAt,
  });

  // JSON 직렬화 (DB 컬럼명 스키마에 맞춤)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'total_weight': totalWeight,
      'total_cost': totalCost,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory Sauce.fromJson(Map<String, dynamic> json) {
    return Sauce(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      totalWeight: (json['total_weight'] is int)
          ? (json['total_weight'] as int).toDouble()
          : json['total_weight'].toDouble(),
      totalCost: (json['total_cost'] is int)
          ? (json['total_cost'] as int).toDouble()
          : json['total_cost'].toDouble(),
      imagePath: json['image_path'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // 복사본 생성
  Sauce copyWith({
    String? id,
    String? name,
    String? description,
    double? totalWeight,
    double? totalCost,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Sauce(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalWeight: totalWeight ?? this.totalWeight,
      totalCost: totalCost ?? this.totalCost,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // g/ml 당 단가 (총원가 / 총중량)
  double get unitCost {
    if (totalWeight <= 0) return 0.0;
    return totalCost / totalWeight;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    totalWeight,
    totalCost,
    imagePath,
    createdAt,
  ];
}
