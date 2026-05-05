import 'package:flutter/material.dart';

import '../theme/tokens/tokens.dart';

/// 레시피 마진율 계산 + 색상 단계.
///
/// 디자인 기준:
/// - margin = (sellPrice - cost) / sellPrice * 100
/// - sellPrice <= 0 이면 0 (의미 없음)
/// - >=60 positive(green) / >=40 warning(orange) / <40 negative(red)
class RecipeMargin {
  RecipeMargin._();

  /// 마진율 percent (0 if sellPrice <= 0).
  static double percent(double sellPrice, double cost) {
    if (sellPrice <= 0) return 0;
    return ((sellPrice - cost) / sellPrice) * 100;
  }

  /// 1인 이익 = sellPrice - cost.
  static double profit(double sellPrice, double cost) {
    return sellPrice - cost;
  }

  /// 마진율 색상 — 토큰 기반 단계 색.
  static Color color(double marginPercent, AppColorTokens tokens) {
    if (marginPercent >= 60) return tokens.positive;
    if (marginPercent >= 40) return tokens.warning;
    return tokens.negative;
  }

  /// 마진율 soft 색상 — 배경 등 옅은 톤이 필요할 때.
  static Color softColor(double marginPercent, AppColorTokens tokens) {
    if (marginPercent >= 60) return tokens.positiveSoft;
    if (marginPercent >= 40) return tokens.warningSoft;
    return tokens.negativeSoft;
  }
}
