import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/recipe.dart';
import '../model/ingredient.dart';

/// 메뉴 타입별 목표 원가율 정의
enum MenuType {
  snack, // 분식/라면/한끼 간편
  main, // 덮밥/면/대표 단품
  stewShare, // 찌개·탕(공유/2인)
  premium, // 프리미엄 단품(스테이크/해산물/수제버거)
  dessert, // 디저트/사이드
  beverage, // 음료(커피/에이드)
}

/// AI 기반 판매 분석 서비스
class AiSalesAnalysisService {
  static const String _modelName = 'gemini-1.5-flash';
  late final GenerativeModel _model;

  // 메뉴 타입별 목표 원가율 (제품 원가비중)
  static const Map<MenuType, double> _targetCostRatio = {
    MenuType.snack: 0.42, // 42% (40~45%)
    MenuType.main: 0.33, // 33% (33~35%) - 기준 사례 5,000→15,000
    MenuType.stewShare: 0.35, // 35% (33~38%)
    MenuType.premium: 0.30, // 30% (30~32%)
    MenuType.dessert: 0.35, // 35% (30~35%)
    MenuType.beverage: 0.32, // 32% (30~35%)
  };

  // 메뉴 타입별 곱셈계수 (1 / 목표 원가율)
  static const Map<MenuType, double> _multiplierRatio = {
    MenuType.snack: 2.38, // 1 / 0.42
    MenuType.main: 3.03, // 1 / 0.33
    MenuType.stewShare: 2.86, // 1 / 0.35
    MenuType.premium: 3.33, // 1 / 0.30
    MenuType.dessert: 2.86, // 1 / 0.35
    MenuType.beverage: 3.13, // 1 / 0.32
  };

  AiSalesAnalysisService() {
    _initializeModel();
  }

  /// Gemini 모델 초기화
  void _initializeModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY가 설정되지 않았습니다.');
    }

    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// 레시피 판매 분석 수행
  Future<Map<String, dynamic>> analyzeRecipeSales(
    Recipe recipe,
    List<Ingredient> ingredients, {
    String? userQuery,
    String? userLanguage,
  }) async {
    try {
      // AI에게 전달할 프롬프트 구성
      final prompt = _buildAnalysisPrompt(
        recipe,
        ingredients,
        userQuery: userQuery,
        userLanguage: userLanguage,
      );

      // Gemini API 호출
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      // 응답 파싱 및 반환
      return _parseAnalysisResponse(responseText);
    } catch (e) {
      // 에러 발생 시 기본 분석 결과 반환
      return _getDefaultAnalysis(recipe, userLanguage ?? 'Korean');
    }
  }

  /// AI 분석 프롬프트 구성
  String _buildAnalysisPrompt(
    Recipe recipe,
    List<Ingredient> ingredients, {
    String? userQuery,
    String? userLanguage,
  }) {
    // 사용자 언어 감지 (기본값: 한국어)
    final language = userLanguage ?? 'Korean';
    final isKorean =
        language.toLowerCase().contains('ko') ||
        language.toLowerCase().contains('korean') ||
        language.toLowerCase().contains('한국어');

    // 사용자 질문이 있는 경우 포함
    final userQuerySection = userQuery != null && userQuery.isNotEmpty
        ? '''
사용자 특별 요청사항:
$userQuery

위 요청사항을 반드시 고려하여 분석해주세요.
'''
        : '';

    // 재료 정보 구성
    final ingredientDetails = ingredients
        .map((ingredient) {
          final recipeIngredient = recipe.ingredients.firstWhere(
            (ri) => ri.ingredientId == ingredient.id,
            orElse: () => recipe.ingredients.first,
          );
          return '${ingredient.name} ${recipeIngredient.amount}${recipeIngredient.unitId}';
        })
        .join(', ');

    // 언어별 프롬프트 구성
    if (isKorean) {
      return '''
당신은 한국의 식당 경영자들을 돕는 유능한 마케팅 전문가 AI입니다. 
주어진 레시피 정보를 바탕으로 판매 전략을 분석하고 제안해주세요.

레시피 정보:
- 이름: ${recipe.name}
- 설명: ${recipe.description}
- 총 원가: ${recipe.totalCost}원
- 사용 재료: $ingredientDetails

$userQuerySection

다음 항목들을 JSON 형식으로 분석해주세요. 반드시 유효한 JSON 객체만 응답해야 합니다:

{
  "optimal_price": {
    "recommended_price": "추천 판매가 (숫자만, 단위 없이)",
    "cost_ratio": "목표 원가율 (30-45 사이의 정수, 단위 없이)",
    "profit_per_serving": "1인분당 예상 수익 (숫자만, 단위 없이)",
    "price_analysis": "가격 설정 근거 설명"
  },
  "marketing_points": {
    "unique_selling_points": ["고유한 판매 포인트 1", "고유한 판매 포인트 2", "고유한 판매 포인트 3"],
    "target_customers": "타겟 고객층",
    "competitive_advantages": ["경쟁 우위 1", "경쟁 우위 2"],
    "seasonal_timing": "최적 판매 시기"
  },
  "serving_guidance": {
    "opening_script": "고객에게 첫 인사를 할 때 사용할 멘트",
    "description_script": "레시피를 소개할 때 사용할 설명",
    "price_justification": "가격을 설명할 때 사용할 멘트",
    "upselling_tips": ["추가 판매 팁 1", "추가 판매 팁 2"]
  },
  "business_insights": {
    "cost_efficiency": "원가 효율성 분석",
    "profitability_tips": "수익성 향상 팁",
    "risk_factors": "주의해야 할 위험 요소"
  }
}

가격 설정 가이드라인 (개선된 원가율 기반):
1. 메뉴 타입별 목표 원가율 적용:
   - 분식/간편: 42% (곱셈계수 2.38) - 원가 × 2.38
   - 대표 단품: 33% (곱셈계수 3.03) - 원가 × 3.03 (기준: 5,000원→15,000원)
   - 찌개/탕: 35% (곱셈계수 2.86) - 원가 × 2.86
   - 프리미엄: 30% (곱셈계수 3.33) - 원가 × 3.33
   - 디저트/사이드: 35% (곱셈계수 2.86) - 원가 × 2.86
   - 음료: 32% (곱셈계수 3.13) - 원가 × 3.13

2. 핵심 공식: 판매가 = 원가 × 곱셈계수 (2.3~3.3배)
3. 심리적 가격: 1천/5백 단위 반올림 후 ...900/...500으로 매무새 정리
4. 예시: 원가 5,000원 → 대표 단품 기준 15,000원 (3배, 원가율 33%)
5. 예시: 원가 27,000원 → 대표 단품 기준 81,000원 (3배, 원가율 33%)

⚠️ 중요: 목표 원가율은 30-45% 사이의 정수로 설정해야 합니다.
   - 판매가 = 원가 × 곱셈계수 (2.3~3.3배)
   - 원가율 = 원가 ÷ 판매가 × 100
   - 예: 원가 5,000원 → 판매가 15,000원 (3배) → 원가율 = 5,000÷15,000×100 = 33%
   - 예: 원가 27,000원 → 판매가 81,000원 (3배) → 원가율 = 27,000÷81,000×100 = 33%

분석 시 고려사항:
1. 한국 외식업계의 특성과 트렌드를 반영
2. 레시피의 고유한 특징을 활용한 마케팅 전략 제시
3. 실용적이고 실행 가능한 조언 제공
4. 원가 대비 수익성을 극대화하는 방안 제시
5. 시장 경쟁력과 고객 가치 인식을 균형있게 고려
''';
    } else {
      // 영어 프롬프트
      return '''
You are an expert marketing consultant specializing in restaurant business strategies. 
Please analyze the given recipe information and provide comprehensive sales strategy recommendations.

Recipe Information:
- Name: ${recipe.name}
- Description: ${recipe.description}
- Total Cost: ${recipe.totalCost} KRW
- Ingredients Used: $ingredientDetails

$userQuerySection

Please analyze the following items in JSON format. You must respond with only a valid JSON object:

{
  "optimal_price": {
    "recommended_price": "Recommended selling price (numbers only, no units)",
    "cost_ratio": "Target cost ratio (30-45 integer, no units)",
    "profit_per_serving": "Expected profit per serving (numbers only, no units)",
    "price_analysis": "Price setting rationale"
  },
  "marketing_points": {
    "unique_selling_points": ["Unique selling point 1", "Unique selling point 2", "Unique selling point 3"],
    "target_customers": "Target customer segment",
    "competitive_advantages": ["Competitive advantage 1", "Competitive advantage 2"],
    "seasonal_timing": "Optimal selling season"
  },
  "serving_guidance": {
    "opening_script": "Opening script for customers",
    "description_script": "Recipe introduction script",
    "price_justification": "Price justification script",
    "upselling_tips": ["Upselling tip 1", "Upselling tip 2"]
  },
  "business_insights": {
    "cost_efficiency": "Cost efficiency analysis",
    "profitability_tips": "Profitability improvement tips",
    "risk_factors": "Risk factors to consider"
  }
}

Pricing Guidelines (Enhanced Cost Ratio Based):
1. Menu Type-Specific Target Cost Ratios:
   - Snack/Quick: 42% (multiplier 2.38) - Cost × 2.38
   - Main Dish: 33% (multiplier 3.03) - Cost × 3.03 (Standard: 5,000→15,000 KRW)
   - Stew/Soup: 35% (multiplier 2.86) - Cost × 2.86
   - Premium: 30% (multiplier 3.33) - Cost × 3.33
   - Dessert/Side: 35% (multiplier 2.86) - Cost × 2.86
   - Beverage: 32% (multiplier 3.13) - Cost × 3.13

2. Core Formula: Selling Price = Cost × Multiplier (2.3~3.3x)
3. Psychological Pricing: Round to 1K/500 units, then adjust to ...900/...500 endings
4. Example: Cost 5,000 KRW → Main dish standard 15,000 KRW (3x, 33% cost ratio)
5. Example: Cost 27,000 KRW → Main dish standard 81,000 KRW (3x, 33% cost ratio)

⚠️ Important: Target cost ratio must be set as an integer between 30-45%.
   - Selling Price = Cost × Multiplier (2.3~3.3x)
   - Cost Ratio = Cost ÷ Selling Price × 100
   - Example: Cost 5,000 KRW → Selling Price 15,000 KRW (3x) → Cost Ratio = 5,000÷15,000×100 = 33%
   - Example: Cost 27,000 KRW → Selling Price 81,000 KRW (3x) → Cost Ratio = 27,000÷81,000×100 = 33%

Analysis Considerations:
1. Consider the characteristics and trends of the restaurant industry
2. Present marketing strategies that leverage the recipe's unique features
3. Provide practical and actionable advice
4. Suggest ways to maximize profitability relative to costs
5. Balance market competitiveness with customer value perception
''';
    }
  }

  /// AI 응답 파싱
  Map<String, dynamic> _parseAnalysisResponse(String response) {
    try {
      // JSON 부분만 추출 (```json``` 블록이 있는 경우)
      String jsonText = response;
      if (response.contains('```json')) {
        final startIndex = response.indexOf('```json') + 7;
        final endIndex = response.lastIndexOf('```');
        if (endIndex > startIndex) {
          jsonText = response.substring(startIndex, endIndex).trim();
        }
      }

      // JSON 파싱
      final Map<String, dynamic> analysis = json.decode(jsonText);

      // 필수 필드 검증
      final requiredFields = [
        'optimal_price',
        'marketing_points',
        'serving_guidance',
        'business_insights',
      ];
      for (final field in requiredFields) {
        if (!analysis.containsKey(field)) {
          throw Exception('필수 필드가 누락되었습니다: $field');
        }
      }

      // 원가율 값 검증 및 수정
      if (analysis['optimal_price'] != null &&
          analysis['optimal_price'] is Map<String, dynamic>) {
        final optimalPrice = analysis['optimal_price'] as Map<String, dynamic>;
        if (optimalPrice.containsKey('cost_ratio')) {
          final costRatio = optimalPrice['cost_ratio'];
          if (costRatio is String) {
            final costValue = int.tryParse(costRatio);
            if (costValue != null && (costValue < 30 || costValue > 45)) {
              // 원가율이 범위를 벗어나면 기본값으로 수정
              optimalPrice['cost_ratio'] = '33';
              print('⚠️ 원가율이 범위를 벗어나 기본값 33%로 수정: $costValue%');
            }
          }
        }
      }

      return analysis;
    } catch (e) {
      print('AI 응답 파싱 오류: $e');
      // 파싱 실패 시 기본 분석 결과 반환
      return _getDefaultAnalysis(null, 'Korean');
    }
  }

  /// 메뉴 타입을 자동으로 판단하는 메서드
  MenuType _determineMenuType(Recipe recipe, List<Ingredient> ingredients) {
    final name = recipe.name.toLowerCase();
    final description = recipe.description.toLowerCase();

    // 프리미엄 메뉴 판단
    if (name.contains('스테이크') ||
        name.contains('steak') ||
        name.contains('해산물') ||
        name.contains('seafood') ||
        name.contains('수제') ||
        name.contains('handmade') ||
        name.contains('프리미엄') ||
        name.contains('premium')) {
      return MenuType.premium;
    }

    // 음료 판단
    if (name.contains('커피') ||
        name.contains('coffee') ||
        name.contains('에이드') ||
        name.contains('ade') ||
        name.contains('음료') ||
        name.contains('drink') ||
        name.contains('차') ||
        name.contains('tea')) {
      return MenuType.beverage;
    }

    // 디저트/사이드 판단
    if (name.contains('디저트') ||
        name.contains('dessert') ||
        name.contains('사이드') ||
        name.contains('side') ||
        name.contains('후식') ||
        name.contains('간식')) {
      return MenuType.dessert;
    }

    // 찌개/탕 판단 (공유 메뉴)
    if (name.contains('찌개') ||
        name.contains('탕') ||
        name.contains('전골') ||
        name.contains('hotpot') ||
        name.contains('공유') ||
        name.contains('share')) {
      return MenuType.stewShare;
    }

    // 분식/간편 메뉴 판단
    if (name.contains('분식') ||
        name.contains('라면') ||
        name.contains('간편') ||
        name.contains('한끼') ||
        name.contains('스낵') ||
        name.contains('snack')) {
      return MenuType.snack;
    }

    // 기본값: 대표 단품
    return MenuType.main;
  }

  /// 개선된 가격 추천 계산
  double _calculateRecommendedPrice({
    required double ingredientCost,
    required MenuType menuType,
    double fixedPerDish = 0, // 포장/용기/연료 등 고정비
    double variableRate = 0.0, // 카드/플랫폼 수수료 등 (예: 0.05)
    int roundingStep = 500, // 반올림 단위
    bool charmEnding = true, // 심리적 가격 (900/500 끝자리)
  }) {
    final targetRatio = _targetCostRatio[menuType]!;
    final effectiveRatio = targetRatio - variableRate;

    if (effectiveRatio <= 0.18) {
      throw Exception('유효 원가율이 너무 낮습니다. 목표 원가율 또는 수수료를 재설정하세요.');
    }

    // 핵심 공식: P = (C + F) ÷ (r - v)
    double price = (ingredientCost + fixedPerDish) / effectiveRatio;

    // 반올림 적용
    price = (price / roundingStep).roundToDouble() * roundingStep;

    // 심리적 가격 적용 (900/500 끝자리)
    if (charmEnding) {
      final mod = price % 1000;
      if (mod == 0) {
        price -= 100; // 10,000 → 9,900
      } else if (mod == 500) {
        price += 0; // 500 유지
      }
    }

    return price;
  }

  /// 메뉴 타입 이름을 반환하는 헬퍼 메서드
  String _getMenuTypeName(MenuType type, bool isKorean) {
    if (isKorean) {
      switch (type) {
        case MenuType.snack:
          return '분식/간편';
        case MenuType.main:
          return '대표 단품';
        case MenuType.stewShare:
          return '찌개/탕';
        case MenuType.premium:
          return '프리미엄';
        case MenuType.dessert:
          return '디저트/사이드';
        case MenuType.beverage:
          return '음료';
      }
    } else {
      switch (type) {
        case MenuType.snack:
          return 'Snack/Quick';
        case MenuType.main:
          return 'Main Dish';
        case MenuType.stewShare:
          return 'Stew/Soup';
        case MenuType.premium:
          return 'Premium';
        case MenuType.dessert:
          return 'Dessert/Side';
        case MenuType.beverage:
          return 'Beverage';
      }
    }
  }

  /// 기본 분석 결과 (AI 응답 실패 시)
  Map<String, dynamic> _getDefaultAnalysis(Recipe? recipe, String language) {
    final isKorean =
        language.toLowerCase().contains('ko') ||
        language.toLowerCase().contains('korean') ||
        language.toLowerCase().contains('한국어');

    final basePrice = recipe?.totalCost ?? 0;

    // 메뉴 타입 자동 판단
    final menuType = recipe != null
        ? _determineMenuType(recipe, [])
        : MenuType.main;
    final targetRatio = _targetCostRatio[menuType]!;
    final multiplier = _multiplierRatio[menuType]!;

    // 개선된 가격 계산
    final recommendedPrice = _calculateRecommendedPrice(
      ingredientCost: basePrice,
      menuType: menuType,
      roundingStep: 500,
      charmEnding: true,
    );

    // 원가율을 퍼센트로 변환 (소수점 없이)
    final costRatioPercent = (targetRatio * 100).round();
    final marginRatePercent = (100 - costRatioPercent).round();
    final profitPerServing = (recommendedPrice - basePrice).round();

    if (isKorean) {
      return {
        'optimal_price': {
          'recommended_price': recommendedPrice.toString(),
          'cost_ratio': costRatioPercent.toString(),
          'profit_per_serving': profitPerServing.toString(),
          'price_analysis':
              '메뉴 타입(${_getMenuTypeName(menuType, true)})에 맞는 목표 원가율 ${costRatioPercent}%를 적용했습니다. '
              '원가 대비 ${multiplier.toStringAsFixed(2)}배로 시장 경쟁력과 수익성을 균형있게 고려한 가격입니다.',
        },
        'marketing_points': {
          'unique_selling_points': ['신선한 재료 사용', '정성스러운 조리', '합리적인 가격'],
          'target_customers': '가성비를 중시하는 고객',
          'competitive_advantages': ['합리적인 가격', '신선한 재료'],
          'seasonal_timing': '연중 판매 가능',
        },
        'serving_guidance': {
          'opening_script':
              '안녕하세요! 오늘은 특별히 준비한 ${recipe?.name ?? '요리'}를 추천드립니다.',
          'description_script': '신선한 재료로 정성스럽게 조리한 요리입니다.',
          'price_justification': '퀄리티 대비 합리적인 가격으로 제공하고 있습니다.',
          'upselling_tips': ['사이드 메뉴 추가', '음료와 함께 주문'],
        },
        'business_insights': {
          'cost_efficiency': '기본적인 원가 관리가 잘 되어 있습니다.',
          'profitability_tips': '재료 구매량을 늘려 단가를 낮추는 것을 고려해보세요.',
          'risk_factors': '재료 가격 변동에 주의가 필요합니다.',
        },
      };
    } else {
      // 영어 기본 분석
      return {
        'optimal_price': {
          'recommended_price': recommendedPrice.toString(),
          'cost_ratio': costRatioPercent.toString(),
          'profit_per_serving': profitPerServing.toString(),
          'price_analysis':
              'Applied target cost ratio of ${costRatioPercent}% for menu type (${_getMenuTypeName(menuType, false)}). '
              'Priced at ${multiplier.toStringAsFixed(2)}x cost ratio, balancing market competitiveness and profitability.',
        },
        'marketing_points': {
          'unique_selling_points': [
            'Fresh ingredients',
            'Careful preparation',
            'Reasonable pricing',
          ],
          'target_customers': 'Value-conscious customers',
          'competitive_advantages': [
            'Competitive pricing',
            'Fresh ingredients',
          ],
          'seasonal_timing': 'Year-round availability',
        },
        'serving_guidance': {
          'opening_script':
              'Hello! Today I recommend our specially prepared ${recipe?.name ?? 'dish'}.',
          'description_script':
              'This dish is carefully prepared with fresh ingredients.',
          'price_justification': 'We offer quality at a reasonable price.',
          'upselling_tips': ['Add side dishes', 'Order with beverages'],
        },
        'business_insights': {
          'cost_efficiency': 'Basic cost management is well maintained.',
          'profitability_tips':
              'Consider increasing ingredient purchase volume to reduce unit costs.',
          'risk_factors': 'Be aware of ingredient price fluctuations.',
        },
      };
    }
  }

  /// 사용자 언어 감지 (간단한 구현)
  String _detectLanguage(String text) {
    if (text.isEmpty) return 'Korean';

    // 한국어 문자 포함 여부로 판단
    final koreanPattern = RegExp(r'[가-힣]');
    if (koreanPattern.hasMatch(text)) return 'Korean';

    // 영어 패턴 확인
    final englishPattern = RegExp(r'[a-zA-Z]');
    if (englishPattern.hasMatch(text)) return 'English';

    // 기본값
    return 'Korean';
  }

  /// 추천 판매가 계산 (메뉴 타입 기반)
  double calculateRecommendedPriceByMenuType({
    required double recipeCost,
    required MenuType menuType,
    double fixedPerDish = 0,
    double variableRate = 0.0,
    int roundingStep = 500,
    bool charmEnding = true,
  }) {
    return _calculateRecommendedPrice(
      ingredientCost: recipeCost,
      menuType: menuType,
      fixedPerDish: fixedPerDish,
      variableRate: variableRate,
      roundingStep: roundingStep,
      charmEnding: charmEnding,
    );
  }

  /// 추천 판매가 계산 (수동 계산용 - 기존 호환성)
  double calculateRecommendedPrice(double recipeCost, double targetCostRatio) {
    if (targetCostRatio <= 0 || targetCostRatio >= 100) {
      throw Exception('원가율은 0과 100 사이의 값이어야 합니다.');
    }
    return recipeCost / (targetCostRatio / 100);
  }

  /// 마진율 계산
  double calculateMarginRate(double cost, double sellingPrice) {
    if (sellingPrice <= 0) return 0;
    return ((sellingPrice - cost) / sellingPrice) * 100;
  }

  /// 수익성 분석
  Map<String, dynamic> analyzeProfitability(double cost, double sellingPrice) {
    final margin = sellingPrice - cost;
    final marginRate = calculateMarginRate(cost, sellingPrice);
    final breakEvenQuantity = cost > 0 ? (cost / margin).ceil() : 0;

    return {
      'total_margin': margin,
      'margin_rate': marginRate,
      'break_even_quantity': breakEvenQuantity,
      'profitability_level': _getProfitabilityLevel(marginRate),
    };
  }

  /// 수익성 수준 판단
  String _getProfitabilityLevel(double marginRate) {
    if (marginRate >= 50) return '매우 높음';
    if (marginRate >= 35) return '높음';
    if (marginRate >= 25) return '보통';
    if (marginRate >= 15) return '낮음';
    return '매우 낮음';
  }
}
