import 'package:equatable/equatable.dart';
import 'recipe.dart';
import 'ingredient.dart';

/// 리포트 조회 기간 enum
enum ReportPeriod {
  weekly,
  monthly,
  quarterly;

  /// 기간 전체 일수
  int get days {
    switch (this) {
      case ReportPeriod.weekly:
        return 7;
      case ReportPeriod.monthly:
        return 30;
      case ReportPeriod.quarterly:
        return 90;
    }
  }

  /// 버킷 단위 일수 (weekly/monthly = 1일, quarterly = 7일)
  int get bucketDays {
    switch (this) {
      case ReportPeriod.weekly:
        return 1;
      case ReportPeriod.monthly:
        return 1;
      case ReportPeriod.quarterly:
        return 7;
    }
  }

  /// 버킷 수 = days / bucketDays
  int get bucketCount => days ~/ bucketDays;
}

/// 시계열 원가율 버킷 한 점
class CostRatioPoint extends Equatable {
  final DateTime date;
  final double? avgCostRatio; // null = 해당 버킷에 데이터 없음

  const CostRatioPoint({required this.date, this.avgCostRatio});

  @override
  List<Object?> get props => [date, avgCostRatio];
}

/// 마진율 순위 항목
class MarginRankItem extends Equatable {
  final Recipe recipe;
  final double cost;
  final double sellPrice;
  final double marginPct;

  const MarginRankItem({
    required this.recipe,
    required this.cost,
    required this.sellPrice,
    required this.marginPct,
  });

  @override
  List<Object?> get props => [recipe.id, cost, sellPrice, marginPct];
}

/// 비싼 재료 TOP 항목
class ExpensiveIngredientItem extends Equatable {
  final Ingredient ingredient;
  final double unitPrice; // 기본단위(g/ml/개)당 가격
  final String unitDisplay; // "g" | "ml" | 단위 심볼

  const ExpensiveIngredientItem({
    required this.ingredient,
    required this.unitPrice,
    required this.unitDisplay,
  });

  @override
  List<Object?> get props => [ingredient.id, unitPrice, unitDisplay];
}

/// 리포트 페이지의 전체 데이터 집합
class ReportData extends Equatable {
  final List<CostRatioPoint> costRatioSeries;
  final double avgCostRatio;
  final double? deltaVsPrevPct; // 이전 기간 대비 변화 (null = 비교 불가)
  final List<MarginRankItem> marginRanking;
  final List<ExpensiveIngredientItem> expensiveIngredients;
  final bool hasHistory;

  const ReportData({
    required this.costRatioSeries,
    required this.avgCostRatio,
    this.deltaVsPrevPct,
    required this.marginRanking,
    required this.expensiveIngredients,
    required this.hasHistory,
  });

  static const empty = ReportData(
    costRatioSeries: [],
    avgCostRatio: 0,
    deltaVsPrevPct: null,
    marginRanking: [],
    expensiveIngredients: [],
    hasHistory: false,
  );

  @override
  List<Object?> get props => [
        costRatioSeries,
        avgCostRatio,
        deltaVsPrevPct,
        marginRanking,
        expensiveIngredients,
        hasHistory,
      ];
}
