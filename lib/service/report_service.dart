import 'package:logger/logger.dart';

import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../model/recipe_price_history.dart';
import '../model/report_data.dart';
import '../model/unit.dart' hide UnitType;
import '../util/recipe_margin.dart';
import '../util/unit_converter.dart' show UnitConverter, UnitType;

final _log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// 리포트 페이지에서 사용하는 순수 계산 함수 모음.
/// 모든 메서드는 static — 상태를 보유하지 않음.
class ReportService {
  ReportService._();

  // ---------------------------------------------------------------------------
  // 원가율 시계열
  // ---------------------------------------------------------------------------

  /// 기간별 LOCF 버킷팅.
  ///
  /// 각 버킷 경계 시점에 존재하던 레시피별 최신 history 행을 골라 평균.
  /// 판매가가 0이거나 데이터가 없으면 해당 레시피는 그 버킷에서 제외.
  /// 버킷에 유효 레시피가 하나도 없으면 avgCostRatio = null (차트 갭).
  static List<CostRatioPoint> computeAvgCostRatioSeries({
    required List<RecipePriceHistory> history,
    required List<Recipe> recipes,
    required DateTime now,
    required ReportPeriod period,
  }) {
    final bucketCount = period.bucketCount;
    final bucketDays = period.bucketDays;
    final start = now.subtract(Duration(days: period.days));

    // recipeId → 해당 레시피 history 행 목록 (정렬된 상태 assumed — repo 가 ASC)
    final Map<String, List<RecipePriceHistory>> byRecipe = {};
    for (final h in history) {
      byRecipe.putIfAbsent(h.recipeId, () => []).add(h);
    }

    final List<CostRatioPoint> series = [];
    for (int i = 0; i < bucketCount; i++) {
      final bucketEnd = start.add(Duration(days: (i + 1) * bucketDays));
      final ratios = <double>[];

      for (final recipe in recipes) {
        final rows = byRecipe[recipe.id];
        if (rows == null) continue;

        // 해당 버킷 경계 이전 중 가장 최신 행
        RecipePriceHistory? latest;
        for (final row in rows) {
          if (row.recordedAt.isBefore(bucketEnd) ||
              row.recordedAt.isAtSameMomentAs(bucketEnd)) {
            latest = row;
          }
        }

        if (latest == null) continue;
        if (latest.sellPrice <= 0) continue;

        ratios.add(latest.price / latest.sellPrice * 100);
      }

      series.add(CostRatioPoint(
        date: bucketEnd,
        avgCostRatio: ratios.isEmpty
            ? null
            : ratios.reduce((a, b) => a + b) / ratios.length,
      ));
    }

    return series;
  }

  /// 시계열에서 현재 기간 평균 + 이전 기간 대비 delta 계산.
  ///
  /// series 를 후반부(현재)와 전반부(이전)로 절반 분할 후 각 비-null 값 평균.
  /// 이전 기간에 데이터가 없으면 delta = null.
  static (double avg, double? delta) computeAvgAndDelta(
    List<CostRatioPoint> series,
  ) {
    final valid = series.where((p) => p.avgCostRatio != null).toList();
    if (valid.isEmpty) return (0, null);

    final half = (valid.length / 2).ceil();
    final curr = valid.skip(valid.length - half).toList();
    final prev = valid.take(valid.length - half).toList();

    double mean(List<CostRatioPoint> pts) {
      if (pts.isEmpty) return 0;
      return pts.map((p) => p.avgCostRatio!).reduce((a, b) => a + b) /
          pts.length;
    }

    final currAvg = mean(curr);
    final prevAvg = prev.isEmpty ? null : mean(prev);
    final delta = prevAvg == null ? null : currAvg - prevAvg;
    return (currAvg, delta);
  }

  // ---------------------------------------------------------------------------
  // 마진율 순위
  // ---------------------------------------------------------------------------

  /// sellPrice > 0 인 레시피를 마진율 내림차순으로 정렬.
  static List<MarginRankItem> computeMarginRanking(
    List<Recipe> recipes, {
    int topN = 0,
  }) {
    final items = recipes
        .where((r) => r.sellPrice > 0)
        .map((r) {
          final pct = RecipeMargin.percent(r.sellPrice, r.totalCost);
          return MarginRankItem(
            recipe: r,
            cost: r.totalCost,
            sellPrice: r.sellPrice,
            marginPct: pct,
          );
        })
        .toList()
      ..sort((a, b) => b.marginPct.compareTo(a.marginPct));

    if (topN > 0 && items.length > topN) return items.take(topN).toList();
    return items;
  }

  // ---------------------------------------------------------------------------
  // 비싼 재료 TOP 5
  // ---------------------------------------------------------------------------

  /// 재료별 기본단위(g/ml/개) 당 단가를 계산해 내림차순 정렬.
  /// UnitConverter.toBaseUnit 은 ArgumentError 를 던질 수 있으므로 try/catch wrap.
  static List<ExpensiveIngredientItem> computeTopExpensiveIngredients({
    required List<Ingredient> ingredients,
    required List<Unit> units,
    int topN = 5,
  }) {
    final List<ExpensiveIngredientItem> items = [];

    for (final ing in ingredients) {
      try {
        final baseAmount = UnitConverter.toBaseUnit(
          ing.purchaseAmount,
          ing.purchaseUnitId,
        );

        if (baseAmount <= 0) continue;
        if (ing.purchasePrice <= 0) continue;

        final unitPrice = ing.purchasePrice / baseAmount;
        final unitType = UnitConverter.getUnitType(ing.purchaseUnitId);
        final String unitDisplay;
        switch (unitType) {
          case UnitType.weight:
            unitDisplay = 'g';
          case UnitType.volume:
            unitDisplay = 'ml';
          case UnitType.count:
            // count 기본 단위는 구매 단위 이름 그대로
            final u = units.where((u) => u.id == ing.purchaseUnitId).firstOrNull;
            unitDisplay = u?.name ?? '개';
          case null:
            // 알 수 없는 단위 — skip
            continue;
        }

        items.add(ExpensiveIngredientItem(
          ingredient: ing,
          unitPrice: unitPrice,
          unitDisplay: unitDisplay,
        ));
      } catch (e) {
        _log.d('[ReportService] computeTopExpensiveIngredients skip ${ing.name}: $e');
      }
    }

    items.sort((a, b) => b.unitPrice.compareTo(a.unitPrice));
    if (topN > 0 && items.length > topN) return items.take(topN).toList();
    return items;
  }
}
