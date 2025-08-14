import 'dart:developer' as developer;
import '../data/sauce_repository.dart';
import '../data/ingredient_repository.dart';
import '../util/unit_converter.dart' as uc;

class SauceAggregation {
  final double totalCost;
  final double totalBaseAmount; // g 또는 ml 기준
  final uc.UnitType unitType; // weight 또는 volume

  const SauceAggregation({
    required this.totalCost,
    required this.totalBaseAmount,
    required this.unitType,
  });
}

class SauceCostService {
  final SauceRepository sauceRepository;
  final IngredientRepository ingredientRepository;

  SauceCostService({
    required this.sauceRepository,
    required this.ingredientRepository,
  });

  /// 소스의 총원가/총중량 집계 (기본 단위: 무게는 g, 부피는 ml)
  Future<SauceAggregation> aggregateSauce(String sauceId) async {
    final parts = await sauceRepository.getIngredientsForSauce(sauceId);
    if (parts.isEmpty) {
      // 기본: weight/g 기준 0 집계
      return const SauceAggregation(
        totalCost: 0,
        totalBaseAmount: 0,
        unitType: uc.UnitType.weight,
      );
    }

    // 모든 구성 재료의 단위 타입이 동일한지 검사 (weight 또는 volume)
    uc.UnitType? dominantType;
    double totalBaseAmount = 0.0;
    double totalCost = 0.0;

    for (final item in parts) {
      final ingredient = await ingredientRepository.getIngredientById(
        item.ingredientId,
      );
      if (ingredient == null) {
        developer.log(
          'Ingredient not found: ${item.ingredientId}',
          name: 'SauceCostService',
        );
        continue;
      }

      // 해당 재료의 구매 단위를 기본 단위로 변환하여 g/ml/개 당 단가 계산
      final purchaseBaseAmount = uc.UnitConverter.toBaseUnit(
        ingredient.purchaseAmount,
        ingredient.purchaseUnitId,
      );
      if (purchaseBaseAmount <= 0) continue;
      final unitPrice = ingredient.purchasePrice / purchaseBaseAmount;

      // 소스 내 사용량을 기본 단위로 변환
      final usageBase = uc.UnitConverter.toBaseUnit(item.amount, item.unitId);

      // 단위 타입 확인
      final itemType = uc.UnitConverter.getUnitType(item.unitId);
      if (itemType == null) {
        // 타입 불명은 스킵
        continue;
      }
      // dominantType 설정 및 일관성 체크 (count 타입은 합산에서 제외)
      if (itemType != uc.UnitType.count) {
        if (dominantType == null) {
          dominantType = itemType;
        } else if (dominantType != itemType) {
          // 서로 다른 타입 혼합 시, 비용은 합산하되, 중량은 dominantType과 동일한 타입만 합산
        }
      }

      // 비용 합산
      totalCost += unitPrice * usageBase;

      // 총중량 합산: weight/volume만 (count는 총량 집계에서 제외)
      if (itemType == uc.UnitType.weight || itemType == uc.UnitType.volume) {
        if (dominantType == null || itemType == dominantType) {
          totalBaseAmount += usageBase;
        }
      }
    }

    return SauceAggregation(
      totalCost: totalCost,
      totalBaseAmount: totalBaseAmount,
      unitType: dominantType ?? uc.UnitType.weight,
    );
  }

  /// g/ml 당 단가 (총원가 / 총중량). 총중량이 0이면 0 반환
  Future<double> getSauceUnitCost(String sauceId) async {
    final agg = await aggregateSauce(sauceId);
    if (agg.totalBaseAmount <= 0) return 0.0;
    return agg.totalCost / agg.totalBaseAmount;
  }

  /// 소스 총원가/총중량을 재계산하여 sauces 테이블에 반영
  Future<void> recomputeAndSaveSauce(String sauceId) async {
    final sauce = await sauceRepository.getSauceById(sauceId);
    if (sauce == null) return;
    final agg = await aggregateSauce(sauceId);
    final updated = sauce.copyWith(
      totalWeight: agg.totalBaseAmount,
      totalCost: agg.totalCost,
    );
    await sauceRepository.updateSauce(updated);
  }
}
