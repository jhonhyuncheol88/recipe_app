import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/recipe.dart';
import '../model/ingredient.dart';

/// 원가 대비 수익률 옵션 (총 매출 대비 원가율 기준)
enum ProfitMargin {
  low, // 원가율 30% (수익률 70% = 원가의 2.33배)
  medium, // 원가율 25% (수익률 75% = 원가의 4.0배)
  high, // 원가율 20% (수익률 80% = 원가의 5.0배)
  premium, // 원가율 15% (수익률 85% = 원가의 6.67배)
}

/// AI 기반 판매 분석 서비스
class AiSalesAnalysisService {
  static const String _modelName = 'gemini-2.0-flash-exp';
  late final GenerativeModel _model;

  // 총 매출 대비 원가율 설정 (총 매출 중 원가가 차지하는 비율)
  // 판매가 = 원가 / 원가율
  static const Map<ProfitMargin, double> _costRatio = {
    ProfitMargin.low: 0.30, // 원가율 30% (판매가 = 원가 / 0.30)
    ProfitMargin.medium: 0.25, // 원가율 25% (판매가 = 원가 / 0.25 = 원가의 4배)
    ProfitMargin.high: 0.20, // 원가율 20% (판매가 = 원가 / 0.20 = 원가의 5배)
    ProfitMargin.premium: 0.15, // 원가율 15% (판매가 = 원가 / 0.15 = 원가의 6.67배)
  };

  // 기본 원가율 (권장: 25%)
  static const ProfitMargin _defaultProfitMargin = ProfitMargin.medium;

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
      return _parseAnalysisResponse(
          responseText, recipe, userLanguage ?? 'korea');
    } catch (e) {
      // 에러 발생 시 기본 분석 결과 반환
      return _getDefaultAnalysis(recipe, userLanguage ?? 'korea');
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
    // userLanguage는 AppLocale enum의 name 값 (korea, usa, china, japan 등)
    final language = userLanguage ?? 'korea';

    // AppLocale enum name으로 직접 비교
    final isKorean = language.toLowerCase() == 'korea';
    final isEnglish = language.toLowerCase() == 'usa';
    final isChinese = language.toLowerCase() == 'china';
    final isJapanese = language.toLowerCase() == 'japan';

    // 사용자 질문이 있는 경우 포함
    final userQuerySection = userQuery != null && userQuery.isNotEmpty
        ? '''
사용자 특별 요청사항:
$userQuery

위 요청사항을 반드시 고려하여 분석해주세요.
'''
        : '';

    // 재료 정보 구성
    final ingredientDetails = ingredients.map((ingredient) {
      final recipeIngredient = recipe.ingredients.firstWhere(
        (ri) => ri.ingredientId == ingredient.id,
        orElse: () => recipe.ingredients.first,
      );
      return '${ingredient.name} ${recipeIngredient.amount}${recipeIngredient.unitId}';
    }).join(', ');

    // 언어별 프롬프트 구성
    if (isKorean) {
      return '''
당신은 한국의 식당 경영자들을 돕는 유능한 마케팅 전문가 AI입니다. 
주어진 레시피 정보를 바탕으로 판매 전략을 분석하고 제안해주세요.

레시피 정보:
- 이름: ${recipe.name}
- 설명: ${recipe.description}
- 총 원가: ${recipe.totalCost}
- 사용 재료: $ingredientDetails

$userQuerySection

다음 항목들을 JSON 형식으로 분석해주세요. 반드시 유효한 JSON 객체만 응답해야 합니다:

{
  "optimal_price": {
    "recommended_price": "추천 판매가 (숫자만, 단위 없이)",
    "cost_ratio": "수익률 (20-50 사이의 정수, 단위 없이)",
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

가격 설정 가이드라인 (총 매출 대비 원가율 기준):
⚠️ 매우 중요: 현재 레시피의 총 원가는 ${recipe.totalCost}입니다.
   이 값은 이미 입력된 값이며, 절대로 변경하거나 환율을 적용하면 안 됩니다.
   이 값(${recipe.totalCost})으로만 계산해야 합니다!

1. 총 매출 대비 원가율 옵션:
   - 보수적: 원가율 30% (판매가 = 원가 / 0.30 = 원가의 약 3.33배)
   - 균형 (권장): 원가율 25% (판매가 = 원가 / 0.25 = 원가의 4배)
   - 적극적: 원가율 20% (판매가 = 원가 / 0.20 = 원가의 5배)
   - 프리미엄: 원가율 15% (판매가 = 원가 / 0.15 = 원가의 6.67배)

2. 핵심 공식: 판매가 = 현재 원가(${recipe.totalCost}) / 원가율
   정확한 계산:
   - 원가율 30%: 판매가 = ${recipe.totalCost} / 0.30 = ${recipe.totalCost / 0.30}
   - 원가율 25%: 판매가 = ${recipe.totalCost} / 0.25 = ${recipe.totalCost / 0.25}
   - 원가율 20%: 판매가 = ${recipe.totalCost} / 0.20 = ${recipe.totalCost / 0.20}
   - 원가율 15%: 판매가 = ${recipe.totalCost} / 0.15 = ${recipe.totalCost / 0.15}

3. 추천 판매가 4가지 제시 (원가율 30%, 25%, 20%, 15%)
4. 심리적 가격: 반올림 후 ...900/...500 끝자리 적용

⚠️ 절대 금지:
   - 원가(${recipe.totalCost})를 변경하면 안 됩니다
   - 환율 변환하면 안 됩니다
   - 위 계산 예시에 나온 값(${recipe.totalCost / 0.30}, ${recipe.totalCost / 0.25} 등)과 비슷한 값을 추천해야 합니다

분석 시 고려사항:
1. 한국 외식업계의 특성과 트렌드를 반영
2. 레시피의 고유한 특징을 활용한 마케팅 전략 제시
3. 실용적이고 실행 가능한 조언 제공
4. 원가 대비 수익성을 극대화하는 방안 제시
5. 시장 경쟁력과 고객 가치 인식을 균형있게 고려
''';
    }

    if (isEnglish) {
      // 영어 프롬프트
      return '''You are an expert marketing consultant specializing in restaurant business strategies. 
Please analyze the given recipe information and provide comprehensive sales strategy recommendations.

Recipe Information:
- Name: ${recipe.name}
- Description: ${recipe.description}
- Total Cost: ${recipe.totalCost}
- Ingredients Used: $ingredientDetails

$userQuerySection

Please analyze the following items in JSON format. You must respond with only a valid JSON object:

{
  "optimal_price": {
    "recommended_price": "Recommended selling price (numbers only, no units, no currency conversion)",
    "cost_ratio": "Profit margin percentage (20-50 integer, no units)",
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

Pricing Guidelines (Cost Ratio Based on Total Revenue):
⚠️ VERY IMPORTANT: The current recipe's total cost is ${recipe.totalCost}.
   This value is already the input value. NEVER change it or apply currency conversion!
   You MUST calculate using this value only (${recipe.totalCost})!

1. Cost Ratio Options (Cost as % of Total Revenue):
   - Conservative: 30% cost ratio (Selling Price = Cost / 0.30 = approx. 3.33x the cost)
   - Balanced (Recommended): 25% cost ratio (Selling Price = Cost / 0.25 = 4x the cost)
   - Aggressive: 20% cost ratio (Selling Price = Cost / 0.20 = 5x the cost)
   - Premium: 15% cost ratio (Selling Price = Cost / 0.15 = 6.67x the cost)

2. Core Formula: Selling Price = Current Cost(${recipe.totalCost}) / Cost Ratio
   Exact calculations:
   - 30% cost ratio: Selling Price = ${recipe.totalCost} / 0.30 = ${recipe.totalCost / 0.30}
   - 25% cost ratio: Selling Price = ${recipe.totalCost} / 0.25 = ${recipe.totalCost / 0.25}
   - 20% cost ratio: Selling Price = ${recipe.totalCost} / 0.20 = ${recipe.totalCost / 0.20}
   - 15% cost ratio: Selling Price = ${recipe.totalCost} / 0.15 = ${recipe.totalCost / 0.15}

3. Recommend ONE of the 4 cost ratios (30%, 25%, 20%, 15%)
4. Psychological Pricing: Round to ...900/...500 endings

⚠️ ABSOLUTELY FORBIDDEN:
   - You MUST NOT change the cost(${recipe.totalCost})
   - You MUST NOT apply currency conversion
   - You MUST recommend values similar to the examples above (${recipe.totalCost / 0.30}, ${recipe.totalCost / 0.25}, etc.)

Analysis Considerations:
1. Consider the characteristics and trends of the restaurant industry
2. Present marketing strategies that leverage the recipe's unique features
3. Provide practical and actionable advice
4. Suggest ways to maximize profitability relative to costs
5. Balance market competitiveness with customer value perception
''';
    }

    if (isChinese) {
      // 중국어 프롬프트
      return '''
您是一位专为餐厅经营者提供帮助的优秀市场营销专家AI。
请根据给定的食谱信息分析并建议销售策略。

食谱信息:
- 名称: ${recipe.name}
- 描述: ${recipe.description}
- 总成本: ${recipe.totalCost}
- 使用的食材: $ingredientDetails

$userQuerySection

请以JSON格式分析以下项目。必须仅以有效的JSON对象响应:

{
  "optimal_price": {
    "recommended_price": "推荐售价 (仅数字, 无单位, 不进行货币转换)",
    "cost_ratio": "利润率百分比 (20-50整数, 无单位)",
    "profit_per_serving": "每份预期利润 (仅数字, 无单位)",
    "price_analysis": "定价理由分析"
  },
  "marketing_points": {
    "unique_selling_points": ["独特卖点1", "独特卖点2", "独特卖点3"],
    "target_customers": "目标客户群",
    "competitive_advantages": ["竞争优势1", "竞争优势2"],
    "seasonal_timing": "最佳销售时机"
  },
  "serving_guidance": {
    "opening_script": "向客户打招呼的用语",
    "description_script": "介绍食谱时的说明",
    "price_justification": "价格解释用语",
    "upselling_tips": ["追加销售建议1", "追加销售建议2"]
  },
  "business_insights": {
    "cost_efficiency": "成本效率分析",
    "profitability_tips": "盈利能力提升建议",
    "risk_factors": "需要注意的风险因素"
  }
}

定价指南 (基于当前输入值的利润率):
⚠️ 非常重要: 当前食谱的总成本是${recipe.totalCost}。
   这个值已经是输入值，绝对不能更改或应用汇率转换！
   必须只使用这个值(${recipe.totalCost})进行计算！

1. 老板的利润选项:
   - 保守: 20%利润率
   - 平衡 (推荐): 30%利润率
   - 积极: 40%利润率
   - 高级: 50%利润率

2. 核心公式: 售价 = 当前成本(${recipe.totalCost}) / (1 - 利润率)
   精确计算:
   - 20%利润: 售价 = ${recipe.totalCost} / (1 - 0.20) = ${recipe.totalCost / 0.80}
   - 30%利润: 售价 = ${recipe.totalCost} / (1 - 0.30) = ${recipe.totalCost / 0.70}
   - 40%利润: 售价 = ${recipe.totalCost} / (1 - 0.40) = ${recipe.totalCost / 0.60}
   - 50%利润: 售价 = ${recipe.totalCost} / (1 - 0.50) = ${recipe.totalCost / 0.50}

3. 推荐4种利润率中的一种 (20%, 30%, 40%, 50%)
4. 心理定价: 四舍五入后调整为...900/...500结尾

⚠️ 绝对禁止:
   - 不能更改成本(${recipe.totalCost})
   - 不能进行货币转换
   - 必须推荐与上述示例相似的值(${recipe.totalCost / 0.80}, ${recipe.totalCost / 0.70}等)
''';
    }

    if (isJapanese) {
      // 일본어 프롬프트
      return '''
あなたは日本のレストラン経営者をサポートする優れたマーケティング専門家のAIです。
与えられたレシピ情報に基づいて販売戦略を分析し提案してください。

レシピ情報:
- 名前: ${recipe.name}
- 説明: ${recipe.description}
- 総原価: ${recipe.totalCost}
- 使用食材: $ingredientDetails

$userQuerySection

以下の項目をJSON形式で分析してください。有効なJSONオブジェクトのみを返答してください:

{
  "optimal_price": {
    "recommended_price": "推奨販売価格 (数字のみ, 単位なし, 通貨変換なし)",
    "cost_ratio": "利益率パーセンテージ (20-50整数, 単位なし)",
    "profit_per_serving": "1人前あたりの予想利益 (数字のみ, 単位なし)",
    "price_analysis": "価格設定の根拠"
  },
  "marketing_points": {
    "unique_selling_points": ["独自の販売ポイント1", "独自の販売ポイント2", "独自の販売ポイント3"],
    "target_customers": "ターゲット顧客層",
    "competitive_advantages": ["競争優位性1", "競争優位性2"],
    "seasonal_timing": "最適な販売時期"
  },
  "serving_guidance": {
    "opening_script": "お客様への最初の挨拶に使用するフレーズ",
    "description_script": "レシピを紹介する際の説明",
    "price_justification": "価格を説明する際のフレーズ",
    "upselling_tips": ["追加販売のヒント1", "追加販売のヒント2"]
  },
  "business_insights": {
    "cost_efficiency": "原価効率性の分析",
    "profitability_tips": "収益性向上のヒント",
    "risk_factors": "注意すべきリスク要因"
  }
}

価格設定ガイドライン (現在の入力値基準の利益率):
⚠️ 非常に重要: 現在のレシピの総原価は${recipe.totalCost}です。
   この値はすでに入力値であり、絶対に変更したり通貨変換を適用してはいけません！
   この値(${recipe.totalCost})のみを使用して計算する必要があります！

1. オーナーの利益率オプション:
   - 保守的: 20%利益率
   - バランス (推奨): 30%利益率
   - 積極的: 40%利益率
   - プレミアム: 50%利益率

2. 基本式: 販売価格 = 現在の原価(${recipe.totalCost}) / (1 - 利益率)
   正確な計算:
   - 20%利益: 販売価格 = ${recipe.totalCost} / (1 - 0.20) = ${recipe.totalCost / 0.80}
   - 30%利益: 販売価格 = ${recipe.totalCost} / (1 - 0.30) = ${recipe.totalCost / 0.70}
   - 40%利益: 販売価格 = ${recipe.totalCost} / (1 - 0.40) = ${recipe.totalCost / 0.60}
   - 50%利益: 販売価格 = ${recipe.totalCost} / (1 - 0.50) = ${recipe.totalCost / 0.50}

3. 4つの利益率 (20%, 30%, 40%, 50%) から1つを推奨
4. 心理的価格設定: ...900/...500で終わるように調整

⚠️ 絶対に禁止:
   - 原価(${recipe.totalCost})を変更してはいけません
   - 通貨変換を適用してはいけません
   - 上記の計算例に示された値(${recipe.totalCost / 0.80}, ${recipe.totalCost / 0.70}など)と類似した値を推奨する必要があります
''';
    }

    // 기본값: 영어
    return '''
You are an expert marketing consultant specializing in restaurant business strategies. 
Please analyze the given recipe information and provide comprehensive sales strategy recommendations.

Recipe Information:
- Name: ${recipe.name}
- Description: ${recipe.description}
- Total Cost: ${recipe.totalCost}
- Ingredients Used: $ingredientDetails

$userQuerySection

Please analyze the following items in JSON format. You must respond with only a valid JSON object:

{
  "optimal_price": {
    "recommended_price": "Recommended selling price (numbers only, no units, no currency conversion)",
    "cost_ratio": "Profit margin percentage (20-50 integer, no units)",
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

Pricing Guidelines (Profit Margin Based on Current Input Value):
⚠️ VERY IMPORTANT: The current recipe's total cost is ${recipe.totalCost}.
   This value is already the input value. NEVER change it or apply currency conversion!
   You MUST calculate using this value only (${recipe.totalCost})!

1. Owner's Profit Margin Options:
   - Conservative: 20% profit margin
   - Balanced (Recommended): 30% profit margin
   - Aggressive: 40% profit margin
   - Premium: 50% profit margin

2. Core Formula: Selling Price = Current Cost(${recipe.totalCost}) / (1 - Profit Margin)
   Exact calculations:
   - 20% profit: Selling Price = ${recipe.totalCost} / (1 - 0.20) = ${recipe.totalCost / 0.80}
   - 30% profit: Selling Price = ${recipe.totalCost} / (1 - 0.30) = ${recipe.totalCost / 0.70}
   - 40% profit: Selling Price = ${recipe.totalCost} / (1 - 0.40) = ${recipe.totalCost / 0.60}
   - 50% profit: Selling Price = ${recipe.totalCost} / (1 - 0.50) = ${recipe.totalCost / 0.50}

3. Recommend ONE of the 4 profit margins (20%, 30%, 40%, 50%)
4. Psychological Pricing: Round to ...900/...500 endings

⚠️ ABSOLUTELY FORBIDDEN:
   - You MUST NOT change the cost(${recipe.totalCost})
   - You MUST NOT apply currency conversion
   - You MUST recommend values similar to the examples above (${recipe.totalCost / 0.80}, ${recipe.totalCost / 0.70}, etc.)
''';
  }

  /// AI 응답 파싱
  Map<String, dynamic> _parseAnalysisResponse(
      String response, Recipe recipe, String language) {
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

      // 추천 가격과 수익 검증 및 보정
      if (analysis['optimal_price'] != null &&
          analysis['optimal_price'] is Map<String, dynamic>) {
        final optimalPrice = analysis['optimal_price'] as Map<String, dynamic>;

        // 수익률 검증 (20-50% 범위)
        if (optimalPrice.containsKey('cost_ratio')) {
          final costRatio = optimalPrice['cost_ratio'];
          if (costRatio is String) {
            final costValue = int.tryParse(costRatio);
            if (costValue != null && (costValue < 20 || costValue > 50)) {
              // 수익률이 범위를 벗어나면 기본값(30%)으로 수정
              optimalPrice['cost_ratio'] = '30';
              print('⚠️ 수익률이 범위를 벗어나 기본값 30%로 수정: $costValue%');
            }
          }
        }

        // 추천 가격 검증 및 보정 (총 매출 대비 원가율 기준)
        if (optimalPrice.containsKey('recommended_price')) {
          final recommendedPriceStr = optimalPrice['recommended_price'];
          if (recommendedPriceStr is String) {
            final recommendedPrice = double.tryParse(recommendedPriceStr);
            if (recommendedPrice != null) {
              // 예상 가격 범위 계산 (원가율 방식)
              // 원가율 30%: 원가 / 0.30 = 원가 * 3.33배
              // 원가율 15%: 원가 / 0.15 = 원가 * 6.67배
              final expectedMinPrice =
                  recipe.totalCost / 0.35; // 원가율 35% (최대 보수적)
              final expectedMaxPrice =
                  recipe.totalCost / 0.10; // 원가율 10% (최대 프리미엄)

              // 디버깅을 위한 로그
              print(
                  '🔍 가격 검증: AI 추천=$recommendedPrice, 원가=${recipe.totalCost}, '
                  '예상 범위=${expectedMinPrice.toStringAsFixed(2)}~${expectedMaxPrice.toStringAsFixed(2)}');

              if (recommendedPrice > expectedMaxPrice ||
                  recommendedPrice < expectedMinPrice) {
                print(
                    '⚠️ AI 추천 가격이 비정상적입니다: $recommendedPrice (원가: ${recipe.totalCost})');
                print('기본 계산값(원가율 25%)으로 보정합니다.');

                // 기본 25% 원가율로 재계산
                final correctedPrice = recipe.totalCost / 0.25;
                final correctedPriceFormatted =
                    _formatPriceForLocale(correctedPrice, language);
                optimalPrice['recommended_price'] =
                    correctedPriceFormatted.toString();

                // 수익도 재계산
                final correctedProfit = correctedPrice - recipe.totalCost;
                final correctedProfitFormatted =
                    _formatPriceForLocale(correctedProfit, language);
                optimalPrice['profit_per_serving'] =
                    correctedProfitFormatted.toString();

                print('✅ 보정된 가격: $correctedPrice (원가율 25%)');
              } else {
                print('✅ AI 추천 가격이 정상 범위 내입니다.');
              }
            }
          }
        }
      }

      return analysis;
    } catch (e) {
      print('AI 응답 파싱 오류: $e');
      // 파싱 실패 시 기본 분석 결과 반환
      return _getDefaultAnalysis(recipe, language);
    }
  }

  /// 개선된 가격 추천 계산 (총 매출 대비 원가율 기준)
  double _calculateRecommendedPrice({
    required double ingredientCost,
    ProfitMargin profitMargin = ProfitMargin.medium,
    double fixedPerDish = 0, // 포장/용기/연료 등 고정비
    double variableRate = 0.0, // 카드/플랫폼 수수료 등 (예: 0.05)
    int roundingStep = 500, // 반올림 단위
    bool charmEnding = true, // 심리적 가격 (900/500 끝자리)
  }) {
    // 목표 원가율 가져오기 (예: 0.25 = 25%)
    final targetCostRatio = _costRatio[profitMargin] ?? 0.25;

    // 총 매출 대비 원가율 기반 판매가 계산
    // 원가율 = (원가 + 고정비) / 판매가
    // 따라서: 판매가 = (원가 + 고정비) / 원가율
    final totalCost = ingredientCost + fixedPerDish;
    double price = totalCost / targetCostRatio;

    // 수수료 반영 (수수료는 매출 대비 비율이므로)
    // 실제 판매가 = 계산된 가격 / (1 - 수수료율)
    if (variableRate > 0) {
      price = price / (1 - variableRate);
    }

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

  /// 언어별 가격 포맷팅
  double _formatPriceForLocale(double price, String language) {
    // AppLocale enum name으로 직접 비교
    switch (language.toLowerCase()) {
      case 'china':
        // 중국어: 소수점 2자리까지 반올림
        return double.parse(price.toStringAsFixed(2));
      case 'japan':
      case 'korea':
      case 'usa':
      default:
        // 일본어, 한국어, 영어, 기타: 정수로 반올림
        return price.roundToDouble();
    }
  }

  /// 기본 분석 결과 (AI 응답 실패 시)
  Map<String, dynamic> _getDefaultAnalysis(Recipe? recipe, String language) {
    // AppLocale enum name으로 직접 비교
    final isKorean = language.toLowerCase() == 'korea';

    final basePrice = recipe?.totalCost ?? 0;

    // 기본 원가율 적용 (25%)
    final profitMargin = _defaultProfitMargin;
    final targetCostRatio = _costRatio[profitMargin]!;

    // 개선된 가격 계산 (현재 입력된 값 기준, 환율 변환 없음)
    final recommendedPrice = _calculateRecommendedPrice(
      ingredientCost: basePrice,
      profitMargin: profitMargin,
      roundingStep: 500,
      charmEnding: true,
    );

    // 원가율과 수익 계산 (현재 입력된 값 기준)
    final profitRatePercent = ((1 - targetCostRatio) * 100).round(); // 수익률
    final profitPerServing = (recommendedPrice - basePrice);

    // 언어별 반올림 방식 적용
    final recommendedPriceFormatted =
        _formatPriceForLocale(recommendedPrice, language);
    final profitPerServingFormatted =
        _formatPriceForLocale(profitPerServing, language);

    if (isKorean) {
      return {
        'optimal_price': {
          'recommended_price': recommendedPriceFormatted.toString(),
          'cost_ratio': profitRatePercent.toString(),
          'profit_per_serving': profitPerServingFormatted.toString(),
          'price_analysis': '원가 대비 ${profitRatePercent}% 수익률을 목표로 가격을 설정했습니다. '
              '이 가격은 시장 경쟁력과 사장님의 수익을 균형있게 고려한 결과입니다.',
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
          'recommended_price': recommendedPriceFormatted.toString(),
          'cost_ratio': profitRatePercent.toString(),
          'profit_per_serving': profitPerServingFormatted.toString(),
          'price_analysis':
              'Applied target profit margin of ${profitRatePercent}% based on cost. '
                  'This price balances market competitiveness with owner profitability.',
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

  /// 추천 판매가 계산 (원가 대비 수익률 기반)
  double calculateRecommendedPriceByProfitMargin({
    required double recipeCost,
    ProfitMargin profitMargin = ProfitMargin.medium,
    double fixedPerDish = 0,
    double variableRate = 0.0,
    int roundingStep = 500,
    bool charmEnding = true,
  }) {
    return _calculateRecommendedPrice(
      ingredientCost: recipeCost,
      profitMargin: profitMargin,
      fixedPerDish: fixedPerDish,
      variableRate: variableRate,
      roundingStep: roundingStep,
      charmEnding: charmEnding,
    );
  }

  /// 추천 판매가 계산 (기존 호환성 유지 - 수익률 기준)
  double calculateRecommendedPrice(double recipeCost, double targetProfitRate) {
    if (targetProfitRate <= 0 || targetProfitRate >= 1) {
      throw Exception('수익률은 0과 1 사이의 값이어야 합니다.');
    }
    // 판매가 = 원가 / (1 - 수익률)
    return recipeCost / (1 - targetProfitRate);
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
