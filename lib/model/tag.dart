import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final String id;
  final String name;
  final String color; // HEX 색상 코드 (예: "#FF5733")
  final TagType type;
  final DateTime createdAt;
  final int usageCount; // 사용된 횟수

  Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.type,
    required this.createdAt,
    this.usageCount = 0,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'usage_count': usageCount,
    };
  }

  // JSON 역직렬화
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      type: TagType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TagType.custom,
      ),
      createdAt: DateTime.parse(json['created_at']),
      usageCount: json['usage_count'] ?? 0,
    );
  }

  // 복사본 생성
  Tag copyWith({
    String? id,
    String? name,
    String? color,
    TagType? type,
    DateTime? createdAt,
    int? usageCount,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  // 사용 횟수 증가
  Tag incrementUsage() {
    return copyWith(usageCount: usageCount + 1);
  }

  // 사용 횟수 감소
  Tag decrementUsage() {
    return copyWith(usageCount: (usageCount - 1).clamp(0, usageCount));
  }

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, type: $type, usageCount: $usageCount)';
  }

  @override
  List<Object?> get props => [id, name, color, type, createdAt, usageCount];
}

enum TagType {
  ingredient, // 재료 태그
  recipe, // 레시피 태그
  custom, // 사용자 정의 태그
}

// 기본 태그들
class DefaultTags {
  // 재료 기본 태그 생성 메서드
  static List<Tag> get ingredientTags => [
    Tag(
      id: 'fresh',
      name: '냉장',
      color: '#4CAF50',
      type: TagType.ingredient,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'frozen',
      name: '냉동',
      color: '#2196F3',
      type: TagType.ingredient,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'indoor',
      name: '실온',
      color: '#FF9800',
      type: TagType.ingredient,
      createdAt: DateTime.now(),
    ),
  ];

  // 레시피 기본 태그 생성 메서드
  static List<Tag> get recipeTags => [
    Tag(
      id: 'korean',
      name: '한식',
      color: '#FF5722',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'chinese',
      name: '중식',
      color: '#F44336',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'japanese',
      name: '일식',
      color: '#E91E63',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'western',
      name: '양식',
      color: '#2196F3',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'italian',
      name: '이탈리안',
      color: '#4CAF50',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'mexican',
      name: '멕시칸',
      color: '#FF9800',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'thai',
      name: '태국음식',
      color: '#795548',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'indian',
      name: '인도음식',
      color: '#607D8B',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'vietnamese',
      name: '베트남음식',
      color: '#8BC34A',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
    Tag(
      id: 'fusion',
      name: '퓨전',
      color: '#9C27B0',
      type: TagType.recipe,
      createdAt: DateTime.now(),
    ),
  ];
}
