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
    return scannedItems.fold(0.0, (total, item) => total + item.price!);
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
  final String name;           // 재료명 (OCR에서 추출된 실제 텍스트)
  final double? price;         // 가격 (사용자 입력용, null 가능)
  final double? quantity;      // 수량 (사용자 입력용, null 가능)
  final String? unit;          // 단위 (사용자 입력용, null 가능)
  final bool isValid;          // 유효성 (재료명이 있으면 true)
  final String? confidence;    // OCR 신뢰도
  final String? originalOcrText; // 해당 재료와 관련된 OCR 원본 텍스트

  ScannedItem({
    required this.id,
    required this.name,
    this.price,                // 가격은 선택사항
    this.quantity,             // 수량은 선택사항
    this.unit,                 // 단위는 선택사항
    this.isValid = true,
    this.confidence,
    this.originalOcrText,      // OCR 원본 텍스트 추가
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
      'original_ocr_text': originalOcrText,
    };
  }

  // JSON 역직렬화
  factory ScannedItem.fromJson(Map<String, dynamic> json) {
    return ScannedItem(
      id: json['id'],
      name: json['name'],
      price: json['price']?.toDouble(),  // null 가능
      quantity: json['quantity']?.toDouble(),
      unit: json['unit'],
      isValid: json['is_valid'] ?? true,
      confidence: json['confidence'],
      originalOcrText: json['original_ocr_text'],
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
    String? originalOcrText,
  }) {
    return ScannedItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isValid: isValid ?? this.isValid,
      confidence: confidence ?? this.confidence,
      originalOcrText: originalOcrText ?? this.originalOcrText,
    );
  }

  // 아이템 유효성 검증 (재료명만 있으면 유효)
  ScannedItem validate() {
    return copyWith(isValid: name.isNotEmpty);
  }

  // 단위당 가격 계산 (가격과 수량이 모두 있을 때만)
  double? get pricePerUnit {
    if (price == null || quantity == null || quantity! <= 0) return null;
    return price! / quantity!;
  }

  // 사용자 입력 완료 여부 확인
  bool get isUserInputComplete {
    return price != null && price! > 0 && 
           quantity != null && quantity! > 0 && 
           unit != null && unit!.isNotEmpty;
  }

  // OCR 원본 텍스트가 있는지 확인
  bool get hasOriginalOcrText {
    return originalOcrText != null && originalOcrText!.isNotEmpty;
  }

  @override
  String toString() {
    return 'ScannedItem(id: $id, name: $name, price: $price, quantity: $quantity, unit: $unit, valid: $isValid)';
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
    originalOcrText,
  ];
}
