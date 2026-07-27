import 'package:equatable/equatable.dart';

/// 재고 변동 유형. DB 에는 dbValue 문자열로 저장.
enum InventoryTxType {
  purchase('purchase'),
  consume('consume'),
  adjust('adjust'),
  aiAdjust('ai_adjust');

  const InventoryTxType(this.dbValue);
  final String dbValue;

  static InventoryTxType fromDb(String value) {
    for (final type in InventoryTxType.values) {
      if (type.dbValue == value) return type;
    }
    return InventoryTxType.adjust;
  }
}

/// 재고 변동 이력 1건.
class InventoryTransaction extends Equatable {
  final String id;
  final String ingredientId;
  final InventoryTxType type;
  final double qtyDelta;
  final double resultingQty;
  final double? price; // purchase 일 때 구매 금액
  final DateTime createdAt;

  const InventoryTransaction({
    required this.id,
    required this.ingredientId,
    required this.type,
    required this.qtyDelta,
    required this.resultingQty,
    this.price,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'ingredient_id': ingredientId,
        'type': type.dbValue,
        'qty_delta': qtyDelta,
        'resulting_qty': resultingQty,
        'price': price,
        'created_at': createdAt.toIso8601String(),
      };

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) =>
      InventoryTransaction(
        id: json['id'],
        ingredientId: json['ingredient_id'],
        type: InventoryTxType.fromDb(json['type']),
        qtyDelta: (json['qty_delta'] as num).toDouble(),
        resultingQty: (json['resulting_qty'] as num).toDouble(),
        price: (json['price'] as num?)?.toDouble(),
        createdAt: DateTime.parse(json['created_at']),
      );

  @override
  List<Object?> get props =>
      [id, ingredientId, type, qtyDelta, resultingQty, price, createdAt];
}
