import 'package:equatable/equatable.dart';

class OcrResult extends Equatable {
  final String id;
  final String originalText;
  final List<ScannedItem> scannedItems;
  final DateTime scannedAt;
  final String? imagePath;

  OcrResult({
    required this.id,
    required this.originalText,
    required this.scannedItems,
    required this.scannedAt,
    this.imagePath,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_text': originalText,
      'scanned_items': scannedItems.map((item) => item.toJson()).toList(),
      'scanned_at': scannedAt.toIso8601String(),
      'image_path': imagePath,
    };
  }

  // JSON 역직렬화
  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      id: json['id'],
      originalText: json['original_text'],
      scannedItems: (json['scanned_items'] as List)
          .map((item) => ScannedItem.fromJson(item))
          .toList(),
      scannedAt: DateTime.parse(json['scanned_at']),
      imagePath: json['image_path'],
    );
  }

  // 복사본 생성
  OcrResult copyWith({
    String? id,
    String? originalText,
    List<ScannedItem>? scannedItems,
    DateTime? scannedAt,
    String? imagePath,
  }) {
    return OcrResult(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      scannedItems: scannedItems ?? this.scannedItems,
      scannedAt: scannedAt ?? this.scannedAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // 스캔된 아이템 추가
  OcrResult addScannedItem(ScannedItem item) {
    final updatedItems = List<ScannedItem>.from(scannedItems)..add(item);
    return copyWith(scannedItems: updatedItems);
  }

  // 스캔된 아이템 제거
  OcrResult removeScannedItem(String itemId) {
    final updatedItems = scannedItems
        .where((item) => item.id != itemId)
        .toList();
    return copyWith(scannedItems: updatedItems);
  }

  // 스캔된 아이템 업데이트
  OcrResult updateScannedItem(ScannedItem updatedItem) {
    final updatedItems = scannedItems.map((item) {
      if (item.id == updatedItem.id) {
        return updatedItem;
      }
      return item;
    }).toList();
    return copyWith(scannedItems: updatedItems);
  }

  // 총 금액 계산
  double get totalAmount {
    return scannedItems.fold(0.0, (total, item) => total + item.price);
  }

  // 유효한 아이템 개수
  int get validItemCount {
    return scannedItems.where((item) => item.isValid).length;
  }

  @override
  String toString() {
    return 'OcrResult(id: $id, items: ${scannedItems.length}, total: $totalAmount)';
  }

  @override
  List<Object?> get props => [
    id,
    originalText,
    scannedItems,
    scannedAt,
    imagePath,
  ];
}

class ScannedItem extends Equatable {
  final String id;
  final String name;
  final double price;
  final double? quantity;
  final String? unit;
  final bool isValid;
  final String? confidence;

  ScannedItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity,
    this.unit,
    this.isValid = true,
    this.confidence,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'is_valid': isValid,
      'confidence': confidence,
    };
  }

  // JSON 역직렬화
  factory ScannedItem.fromJson(Map<String, dynamic> json) {
    return ScannedItem(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity']?.toDouble(),
      unit: json['unit'],
      isValid: json['is_valid'] ?? true,
      confidence: json['confidence'],
    );
  }

  // 복사본 생성
  ScannedItem copyWith({
    String? id,
    String? name,
    double? price,
    double? quantity,
    String? unit,
    bool? isValid,
    String? confidence,
  }) {
    return ScannedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isValid: isValid ?? this.isValid,
      confidence: confidence ?? this.confidence,
    );
  }

  // 아이템 유효성 검증
  ScannedItem validate() {
    return copyWith(isValid: name.isNotEmpty && price > 0);
  }

  // 단위당 가격 계산
  double? get pricePerUnit {
    if (quantity == null || quantity! <= 0) return null;
    return price / quantity!;
  }

  @override
  String toString() {
    return 'ScannedItem(id: $id, name: $name, price: $price, valid: $isValid)';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    quantity,
    unit,
    isValid,
    confidence,
  ];
}
