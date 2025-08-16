import 'dart:math';
import '../model/ai_recipe.dart';
import '../model/ingredient.dart';
import '../data/ingredient_repository.dart';

/// AI 레시피의 재료와 보유 재료를 비교하는 서비스
class IngredientComparisonService {
  final IngredientRepository _ingredientRepository;

  IngredientComparisonService(this._ingredientRepository);

  /// AI 레시피의 재료와 보유 재료를 비교하여 결과 반환
  Future<List<IngredientComparisonResult>> compareIngredients(
    AiRecipe aiRecipe,
  ) async {
    try {
      // AI 레시피에서 재료 정보 추출
      final aiIngredients = aiRecipe.extractIngredients();

      // 보유 재료 목록 가져오기
      final availableIngredients = await _ingredientRepository
          .getAllIngredients();

      // 각 AI 재료에 대해 보유 재료와 매칭
      final comparisonResults = <IngredientComparisonResult>[];

      for (final aiIngredient in aiIngredients) {
        final matchedIngredient = _findMatchingIngredient(
          aiIngredient,
          availableIngredients,
        );

        if (matchedIngredient != null) {
          // 보유 재료가 있는 경우
          final unitCost = _calculateUnitCost(matchedIngredient);
          final convertedAmount = _convertAmount(
            aiIngredient.quantity,
            aiIngredient.unit,
            matchedIngredient.purchaseUnitId,
          );
          final calculatedCost = unitCost * convertedAmount;

          comparisonResults.add(
            IngredientComparisonResult(
              aiIngredient: aiIngredient,
              matchedIngredient: matchedIngredient,
              isAvailable: true,
              unitCost: unitCost,
              calculatedCost: calculatedCost,
            ),
          );
        } else {
          // 보유 재료가 없는 경우
          comparisonResults.add(
            IngredientComparisonResult(
              aiIngredient: aiIngredient,
              matchedIngredient: null,
              isAvailable: false,
              unitCost: null,
              calculatedCost: null,
            ),
          );
        }
      }

      return comparisonResults;
    } catch (e) {
      print('재료 비교 실패: $e');
      return [];
    }
  }

  /// AI 재료와 가장 유사한 보유 재료 찾기
  Ingredient? _findMatchingIngredient(
    AiRecipeIngredient aiIngredient,
    List<Ingredient> availableIngredients,
  ) {
    Ingredient? bestMatch;
    double bestScore = 0.0;

    for (final ingredient in availableIngredients) {
      final score = _calculateSimilarityScore(
        aiIngredient.normalizedName,
        ingredient.name,
      );

      if (score > bestScore && score > 0.7) {
        // 70% 이상 유사도
        bestScore = score;
        bestMatch = ingredient;
      }
    }

    return bestMatch;
  }

  /// 재료명 유사도 점수 계산 (간단한 문자열 매칭)
  double _calculateSimilarityScore(String aiName, String availableName) {
    final normalizedAvailable = availableName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s가-힣]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');

    if (aiName == normalizedAvailable) return 1.0;

    // 부분 포함 여부 확인
    if (aiName.contains(normalizedAvailable) ||
        normalizedAvailable.contains(aiName)) {
      return 0.8;
    }

    // 공통 단어 수 확인
    final aiWords = aiName.split(' ');
    final availableWords = normalizedAvailable.split(' ');
    final commonWords = aiWords.where((word) => availableWords.contains(word));

    if (commonWords.isNotEmpty) {
      return commonWords.length / max(aiWords.length, availableWords.length);
    }

    return 0.0;
  }

  /// 보유 재료의 단위당 가격 계산
  double _calculateUnitCost(Ingredient ingredient) {
    return ingredient.purchasePrice / ingredient.purchaseAmount;
  }

  /// AI 레시피의 수량을 보유 재료 단위로 변환하여 투입량 제안
  double? getSuggestedInputAmount(
    AiRecipeIngredient aiIngredient,
    Ingredient matchedIngredient,
  ) {
    try {
      // AI 레시피 단위를 기본 단위로 변환
      final baseAmount = _convertToBaseUnit(
        aiIngredient.quantity,
        aiIngredient.unit,
      );
      // 기본 단위를 보유 재료 단위로 변환
      final suggestedAmount = _convertFromBaseUnit(
        baseAmount,
        matchedIngredient.purchaseUnitId,
      );

      // 보유 수량을 초과하지 않도록 제한
      final maxAmount = matchedIngredient.purchaseAmount;
      return suggestedAmount > maxAmount ? maxAmount : suggestedAmount;
    } catch (e) {
      print('투입량 제안 계산 실패: $e');
      return null;
    }
  }

  /// AI 레시피의 수량을 보유 재료 단위로 변환
  double _convertAmount(double aiAmount, String aiUnit, String targetUnit) {
    try {
      // AI 단위를 기본 단위로 변환
      final baseAmount = _convertToBaseUnit(aiAmount, aiUnit);
      // 기본 단위를 목표 단위로 변환
      return _convertFromBaseUnit(baseAmount, targetUnit);
    } catch (e) {
      print('단위 변환 실패: $e');
      return aiAmount; // 변환 실패 시 원래 수량 반환
    }
  }

  /// 단위를 기본 단위로 변환
  double _convertToBaseUnit(double amount, String unit) {
    switch (unit.toLowerCase()) {
      case 'kg':
        return amount * 1000; // kg → g
      case 'l':
      case 'liter':
        return amount * 1000; // L → ml
      case 'ml':
      case 'g':
      case '개':
      case '조각':
      case '인분':
        return amount;
      default:
        return amount;
    }
  }

  /// 기본 단위에서 단위로 변환
  double _convertFromBaseUnit(double baseAmount, String targetUnit) {
    switch (targetUnit.toLowerCase()) {
      case 'kg':
        return baseAmount / 1000; // g → kg
      case 'l':
      case 'liter':
        return baseAmount / 1000; // ml → L
      case 'ml':
      case 'g':
      case '개':
      case '조각':
      case '인분':
        return baseAmount;
      default:
        return baseAmount;
    }
  }

  /// 전체 비교 결과 요약
  Map<String, dynamic> getComparisonSummary(
    List<IngredientComparisonResult> results,
  ) {
    final totalIngredients = results.length;
    final availableIngredients = results.where((r) => r.isAvailable).length;
    final unavailableIngredients = totalIngredients - availableIngredients;

    double totalCost = 0.0;
    for (final result in results) {
      if (result.calculatedCost != null) {
        totalCost += result.calculatedCost!;
      }
    }

    return {
      'totalIngredients': totalIngredients,
      'availableIngredients': availableIngredients,
      'unavailableIngredients': unavailableIngredients,
      'availabilityRate': totalIngredients > 0
          ? availableIngredients / totalIngredients
          : 0.0,
      'totalCost': totalCost,
      'canConvert': unavailableIngredients == 0, // 모든 재료가 있으면 변환 가능
    };
  }
}
