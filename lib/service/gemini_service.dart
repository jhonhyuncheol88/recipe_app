import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/ingredient.dart';
import '../util/app_locale.dart';

/// Gemini AI 서비스를 통한 레시피 생성 및 이미지 분석
class GeminiService {
  static const String _modelName = 'gemini-2.0-flash-exp';
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  GeminiService() {
    _initializeModels();
  }

  /// Gemini 모델 초기화
  void _initializeModels() {
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

    _visionModel = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        topK: 20,
        topP: 0.8,
        maxOutputTokens: 1024,
      ),
    );
  }

  /// 식자재 목록을 기반으로 레시피 생성
  Future<Map<String, dynamic>> generateRecipeFromIngredients(
    List<Ingredient> ingredients, {
    String? cuisineType,
    String? dietaryRestrictions,
    int servings = 10,
    int cookingTime = 30,
  }) async {
    try {
      final ingredientList = ingredients
          .map(
            (ingredient) =>
                '${ingredient.name} (${ingredient.purchaseAmount} ${ingredient.purchaseUnitId})',
          )
          .join(', ');

      final prompt = _buildRecipePrompt(
        ingredientList,
        cuisineType: cuisineType,
        dietaryRestrictions: dietaryRestrictions,
        servings: servings,
        cookingTime: cookingTime,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      // JSON 응답 파싱
      return _parseRecipeResponse(responseText);
    } catch (e) {
      throw Exception('레시피 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 같은 재료로 다른 스타일의 레시피 생성
  Future<Map<String, dynamic>> generateDifferentStyleRecipe(
    List<Ingredient> ingredients, {
    int servings = 10,
    int cookingTime = 30,
    List<String>? cuisineTypes,
  }) async {
    try {
      final ingredientList = ingredients
          .map(
            (ingredient) =>
                '${ingredient.name} (${ingredient.purchaseAmount} ${ingredient.purchaseUnitId})',
          )
          .join(', ');

      final prompt = _buildDifferentStyleRecipePrompt(
        ingredientList,
        servings: servings,
        cookingTime: cookingTime,
        cuisineTypes: cuisineTypes,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      // JSON 응답 파싱
      return _parseRecipeResponse(responseText);
    } catch (e) {
      throw Exception('다른 스타일 레시피 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 이미지 분석을 통한 식자재 인식
  Future<List<String>> analyzeIngredientImage(List<int> imageBytes) async {
    try {
      final prompt = '''
이 이미지에 있는 식자재들을 분석해주세요. 
한국어로 식자재 이름만 쉼표로 구분하여 나열해주세요.
예시: 돼지고기 삼겹살, 양파, 마늘, 대파
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ]),
      ];

      final response = await _visionModel.generateContent(content);
      final responseText = response.text ?? '';

      // 응답을 쉼표로 분리하여 식자재 목록 생성
      return responseText
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('이미지 분석 중 오류가 발생했습니다: $e');
    }
  }

  /// 레시피 생성 프롬프트 구성
  String _buildRecipePrompt(
    String ingredients, {
    String? cuisineType,
    String? dietaryRestrictions,
    int servings = 2,
    int cookingTime = 30,
  }) {
    final cuisineText = cuisineType ?? 'Korean';
    final dietaryText = dietaryRestrictions ?? 'None';
    final difficulty = cookingTime <= 20
        ? 'Beginner'
        : cookingTime <= 45
        ? 'Intermediate'
        : 'Advanced';

    return '''
You are a world-class AI Chef, an expert in global cuisines and recipe creation. Your primary function is to generate creative, delicious, and practical recipes based on user-provided ingredients and constraints. You specialize in creating restaurant-scale recipes that are suitable for commercial kitchens and large-scale food service operations.

Your response MUST be a single, valid JSON object and nothing else. Do not include any text, explanations, or markdown formatting before or after the JSON object.

---
USER REQUEST:

- Available Ingredients: $ingredients
- Cuisine Preference: $cuisineText
- Dietary Restrictions: $dietaryText
- Servings: $servings (업장용 대량 요리 기준)
- Max Cooking Time: $cookingTime minutes
- Difficulty Level: $difficulty
- Measurement System: Metric
- Currency for Cost Estimation: KRW
---

JSON OUTPUT SCHEMA:
{
  "recipe_name": "The name of the recipe in Korean.",
  "description": "A brief, enticing description of the dish in Korean.",
  "cuisine_type": "The primary cuisine style of the recipe (e.g., 'Italian', 'Korean', 'Mexican').",
  "servings": $servings,
  "prep_time_minutes": <integer>,
  "cook_time_minutes": <integer>,
  "total_time_minutes": "<integer, must be less than or equal to $cookingTime>",
  "difficulty": "A single word: 'Beginner', 'Intermediate', or 'Advanced', matching the user's request.",
  "ingredients": [
    {
      "name": "Ingredient name in Korean",
      "quantity": <number>,
      "unit": "Measurement unit (g, ml, 개, etc.)"
    }
  ],
  "instructions": [
"Ingredient Preparation and Preprocessing", 
"Basic Cooking Process", 
"Main Cooking Steps", 
"Finishing and Completion", 
"Serving and Key Points"

  ],
  "tips": [
    "Helpful tips or variations for the recipe in Korean."
  ],
  "nutritional_info_per_serving": {
    "calories": "<value> kcal",
    "protein": "<value> g",
    "carbohydrates": "<value> g",
    "fat": "<value> g"
  },
  "estimated_cost": {
    "amount": <number>,
    "currency": "KRW"
  },
  "tags": ["tag1", "tag2", "tag3"]
}

Now, generate the recipe based on the available ingredients and constraints.

IMPORTANT INSTRUCTIONS FOR COOKING STEPS:
- Each instruction should be clear, specific, and actionable
- Include exact measurements, temperatures, and timing where applicable
- Break down complex steps into simple, easy-to-follow instructions
- Use Korean cooking terminology and expressions
- Each step should be numbered sequentially (1, 2, 3, 4, 5)
- Ensure each step builds logically on the previous one
- Include safety tips and cooking tips where relevant
- Make instructions beginner-friendly but detailed enough for all skill levels

INGREDIENT QUANTITY GUIDELINES:
- Convert all ingredient quantities to grams (g) for consistency
- Ensure ingredient quantities are balanced and proportional to the serving size
- For main ingredients (meat, fish, vegetables): 100-300g per serving (업장용 대량 요리 기준)
- For seasoning ingredients (garlic, ginger, herbs): 5-20g per serving (업장용 대량 요리 기준)
- For sauce ingredients: 30-100g per serving (업장용 대량 요리 기준)
- Avoid excessive quantities that would make the dish unbalanced
- Total ingredient weight should be reasonable for the number of servings
- 업장용 대량 요리이므로 재료의 양이 적절하게 조절되어야 함

RESTAURANT-SCALE COOKING GUIDELINES:
- This recipe is designed for commercial kitchens serving 10+ people
- Consider equipment capacity and cooking space limitations
- Ensure cooking times are practical for restaurant operations
- Include batch cooking instructions where applicable
- Consider food safety and holding temperatures for large quantities
- Optimize ingredient usage to minimize waste in commercial settings

INGREDIENT HARMONY AND BALANCE REQUIREMENTS:
- Before creating the recipe, carefully analyze the harmony and compatibility of all ingredients
- Ensure no single ingredient dominates the dish - maintain proper proportions
- Consider flavor balance: sweet, salty, sour, bitter, and umami should be harmonious
- Avoid overwhelming the dish with too much of any one ingredient
- Consider texture balance: soft, crunchy, chewy elements should complement each other
- Ensure ingredients work well together both in flavor and cooking method
- Pay special attention to seasoning ingredients - they should enhance, not overpower
- Create a recipe where each ingredient contributes meaningfully without being excessive

LANGUAGE AND LOCALIZATION REQUIREMENTS:
- Respond in the SAME language as the user's input
- If user writes in Korean, respond in Korean
- If user writes in English, respond in English
- If user writes in Japanese, respond in Japanese
- Maintain consistency in language throughout the entire response
- Do not mix languages within the same response
- Use appropriate cooking terminology for the target language
''';
  }

  /// 다른 스타일 레시피 생성 프롬프트 구성
  String _buildDifferentStyleRecipePrompt(
    String ingredients, {
    int servings = 10,
    int cookingTime = 30,
    List<String>? cuisineTypes,
  }) {
    final difficulty = cookingTime <= 20
        ? 'Beginner'
        : cookingTime <= 45
        ? 'Intermediate'
        : 'Advanced';

    // 랜덤으로 선택된 요리 스타일들을 조합
    final cuisineStyleText = cuisineTypes != null && cuisineTypes.isNotEmpty
        ? '${cuisineTypes.join('-')} Fusion'
        : 'Fusion, Modern, or Unexpected combination';

    return '''
You are a creative AI Chef specializing in fusion cuisine and innovative recipe creation. Your task is to create a completely different style recipe using the same ingredients, focusing on creativity and unexpected flavor combinations. You specialize in creating restaurant-scale recipes that are suitable for commercial kitchens and large-scale food service operations.

Your response MUST be a single, valid JSON object and nothing else. Do not include any text, explanations, or markdown formatting before or after the JSON object.

---
CREATIVE CHALLENGE:

- Available Ingredients: $ingredients
- Goal: Create a COMPLETELY DIFFERENT STYLE recipe using the same ingredients
- Cuisine Style: $cuisineStyleText
- Servings: $servings
- Max Cooking Time: $cookingTime minutes
- Difficulty Level: $difficulty
- Measurement System: Metric
- Currency for Cost Estimation: KRW
- Focus: Innovation, creativity, and surprising flavor combinations
- Specific Cuisine Influences: ${cuisineTypes?.join(', ') ?? 'Creative Fusion'}
- Tag Limit: Use only 1-2 main cuisine tags plus "fusion" for a focused recipe
---

JSON OUTPUT SCHEMA:
{
  "recipe_name": "A creative, unexpected recipe name in Korean that showcases the fusion style.",
  "description": "An exciting description highlighting the innovative approach and unexpected flavors in Korean.",
  "cuisine_type": "$cuisineStyleText",
  "servings": $servings,
  "prep_time_minutes": <integer>,
  "cook_time_minutes": <integer>,
  "total_time_minutes": "<integer, must be less than or equal to $cookingTime>",
  "difficulty": "A single word: 'Beginner', 'Intermediate', or 'Advanced', matching the user's request.",
  "ingredients": [
    {
      "name": "Ingredient name in Korean",
      "quantity": <number>,
      "unit": "Measurement unit (g, ml, 개, etc.)"
    }
  ],
  "instructions": [
    "Ingredient Preparation and Preprocessing", 
    "Basic Cooking Process", 
    "Main Cooking Steps", 
    "Finishing and Completion", 
    "Serving and Key Points"
  ],
  "tips": [
    "Creative cooking tips and variations in Korean.",
    "How to adapt this recipe for different occasions."
  ],
  "nutritional_info_per_serving": {
    "calories": "<value> kcal",
    "protein": "<value> g",
    "carbohydrates": "<value> g",
    "fat": "<value> g"
  },
  "estimated_cost": {
    "amount": <number>,
    "currency": "KRW"
  },
  "tags": ${cuisineTypes != null && cuisineTypes.isNotEmpty ? '["${cuisineTypes.join('", "')}", "fusion"]' : '["fusion", "creative"]'},
  "creativity_score": "A brief explanation of what makes this recipe creative and different."
}

CREATIVITY REQUIREMENTS:
- Think outside the box and create unexpected flavor combinations
- Combine different cooking techniques from various cuisines
- Use the same ingredients in completely different ways
- Focus on modern, fusion, or innovative approaches
- Make it surprising but still delicious and practical
- Consider texture, temperature, and presentation variations
- Create a recipe that feels completely different from traditional uses of these ingredients
- Each cooking step should be numbered sequentially (1, 2, 3, 4, 5)
- Incorporate the specific cuisine influences: ${cuisineTypes?.join(', ') ?? 'Creative Fusion'}
- Blend the selected cuisine styles harmoniously while maintaining the fusion concept
- Keep the recipe focused and not overly complex by limiting the number of cuisine influences

INGREDIENT QUANTITY GUIDELINES:
- Convert all ingredient quantities to grams (g) for consistency
- Ensure ingredient quantities are balanced and proportional to the serving size
- For main ingredients (meat, fish, vegetables): 100-300g per serving (업장용 대량 요리 기준)
- For seasoning ingredients (garlic, ginger, herbs): 5-20g per serving (업장용 대량 요리 기준)
- For sauce ingredients: 30-100g per serving (업장용 대량 요리 기준)
- Avoid excessive quantities that would make the dish unbalanced
- Total ingredient weight should be reasonable for the number of servings
- 업장용 대량 요리이므로 재료의 양이 적절하게 조절되어야 함
- Analyze ingredient compatibility and balance before creating the recipe

RESTAURANT-SCALE COOKING GUIDELINES:
- This recipe is designed for commercial kitchens serving 10+ people
- Consider equipment capacity and cooking space limitations
- Ensure cooking times are practical for restaurant operations
- Include batch cooking instructions where applicable
- Consider food safety and holding temperatures for large quantities
- Optimize ingredient usage to minimize waste in commercial settings

INGREDIENT HARMONY AND BALANCE REQUIREMENTS:
- Before creating the recipe, carefully analyze the harmony and compatibility of all ingredients
- Ensure no single ingredient dominates the dish - maintain proper proportions
- Consider flavor balance: sweet, salty, sour, bitter, and umami should be harmonious
- Avoid overwhelming the dish with too much of any one ingredient
- Consider texture balance: soft, crunchy, chewy elements should complement each other
- Ensure ingredients work well together both in flavor and cooking method
- Pay special attention to seasoning ingredients - they should enhance, not overpower
- Create a recipe where each ingredient contributes meaningfully without being excessive

LANGUAGE AND LOCALIZATION REQUIREMENTS:
- Respond in the SAME language as the user's input
- If user writes in Korean, respond in Korean
- If user writes in English, respond in English
- If user writes in Japanese, respond in Japanese
- Maintain consistency in language throughout the entire response
- Do not mix languages within the same response
- Use appropriate cooking terminology for the target language
Now, generate a creative, fusion-style recipe that showcases the same ingredients in a completely new and unexpected way.
''';
  }

  /// 레시피 응답 파싱
  Map<String, dynamic> _parseRecipeResponse(String response) {
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
      final Map<String, dynamic> recipe = json.decode(jsonText);

      // 필수 필드 검증
      final requiredFields = ['recipe_name', 'ingredients', 'instructions'];

      for (final field in requiredFields) {
        if (!recipe.containsKey(field)) {
          throw Exception('필수 필드가 누락되었습니다: $field');
        }
      }

      return recipe;
    } catch (e) {
      throw Exception('레시피 응답 파싱 중 오류가 발생했습니다: $e');
    }
  }

  /// 레시피 원가 계산
  double calculateRecipeCost(
    Map<String, dynamic> recipe,
    List<Ingredient> availableIngredients,
  ) {
    try {
      final ingredients = recipe['ingredients'] as List;
      double totalCost = 0.0;

      for (final ingredient in ingredients) {
        final name = ingredient['name'] as String;
        final quantity =
            double.tryParse(ingredient['quantity'].toString()) ?? 0.0;
        final unit = ingredient['unit'] as String;

        // 사용 가능한 식자재에서 매칭되는 것 찾기
        final matchedIngredient = availableIngredients.firstWhere(
          (available) =>
              available.name.toLowerCase().contains(name.toLowerCase()) ||
              name.toLowerCase().contains(available.name.toLowerCase()),
          orElse: () => Ingredient(
            id: '0',
            name: name,
            purchasePrice: 0.0,
            purchaseAmount: 0.0,
            purchaseUnitId: unit,
            createdAt: DateTime.now(),
            tagIds: [],
          ),
        );

        // 단위 변환 및 원가 계산
        final convertedQuantity = _convertUnit(
          quantity,
          unit,
          matchedIngredient.purchaseUnitId,
        );
        final ingredientCost =
            (convertedQuantity * matchedIngredient.purchasePrice);
        totalCost += ingredientCost;
      }

      return totalCost;
    } catch (e) {
      throw Exception('원가 계산 중 오류가 발생했습니다: $e');
    }
  }

  /// 단위 변환 (간단한 변환만 지원)
  double _convertUnit(double quantity, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return quantity;

    // g <-> kg 변환
    if (fromUnit == 'g' && toUnit == 'kg') return quantity / 1000;
    if (fromUnit == 'kg' && toUnit == 'g') return quantity * 1000;

    // ml <-> L 변환
    if (fromUnit == 'ml' && toUnit == 'L') return quantity / 1000;
    if (fromUnit == 'L' && toUnit == 'ml') return quantity * 1000;

    // 기본적으로 변환 불가능한 경우 원래 수량 반환
    return quantity;
  }

  /// 추천 판매가 계산
  double calculateRecommendedPrice(double recipeCost, double targetCostRatio) {
    if (targetCostRatio <= 0 || targetCostRatio >= 100) {
      throw Exception('원가율은 0과 100 사이의 값이어야 합니다.');
    }

    return recipeCost / (targetCostRatio / 100);
  }

  /// AI 레시피의 재료 분석 및 누락된 재료 식별
  Map<String, dynamic> analyzeRecipeIngredients(
    Map<String, dynamic> recipe,
    List<Ingredient> availableIngredients,
  ) {
    try {
      final recipeIngredients = recipe['ingredients'] as List? ?? [];

      final availableForRecipe = <Map<String, dynamic>>[];
      final missingIngredients = <Map<String, dynamic>>[];
      final suggestedIngredients = <Map<String, dynamic>>[];

      for (final ingredient in recipeIngredients) {
        final name = ingredient['name'] as String? ?? '';
        final quantity = ingredient['quantity'] ?? 0.0;
        final unit = ingredient['unit'] as String? ?? '';

        if (name.isEmpty) continue;

        // 기존 재료와 매칭 시도
        final matchedIngredient = _findMatchingIngredient(
          name,
          availableIngredients,
        );

        if (matchedIngredient != null) {
          // 기존 재료로 충분한 경우
          availableForRecipe.add({
            'name': name,
            'quantity': quantity,
            'unit': unit,
            'available_amount': matchedIngredient.purchaseAmount,
            'available_unit': matchedIngredient.purchaseUnitId,
            'is_sufficient': true,
            'ingredient_id': matchedIngredient.id,
          });
        } else {
          // 누락된 재료
          missingIngredients.add({
            'name': name,
            'quantity': quantity,
            'unit': unit,
            'suggested_price': 0.0, // 기본값, 나중에 업데이트 가능
            'suggested_unit': unit,
          });

          // 유사한 재료 제안
          final suggestions = _findSimilarIngredients(
            name,
            availableIngredients,
          );
          if (suggestions.isNotEmpty) {
            suggestedIngredients.add({
              'missing_ingredient': name,
              'suggestions': suggestions,
            });
          }
        }
      }

      return {
        'available_ingredients': availableForRecipe,
        'missing_ingredients': missingIngredients,
        'suggested_ingredients': suggestedIngredients,
        'can_make_recipe': missingIngredients.isEmpty,
        'missing_count': missingIngredients.length,
        'available_count': availableForRecipe.length,
      };
    } catch (e) {
      throw Exception('재료 분석 중 오류가 발생했습니다: $e');
    }
  }

  /// 기존 재료와 매칭되는 재료 찾기
  Ingredient? _findMatchingIngredient(
    String recipeIngredientName,
    List<Ingredient> availableIngredients,
  ) {
    final normalizedName = recipeIngredientName.toLowerCase().trim();

    // 정확한 매칭 먼저 시도
    for (final ingredient in availableIngredients) {
      if (ingredient.name.toLowerCase() == normalizedName) {
        return ingredient;
      }
    }

    // 부분 매칭 시도
    for (final ingredient in availableIngredients) {
      final availableName = ingredient.name.toLowerCase();

      // 한쪽이 다른 쪽을 포함하는 경우
      if (availableName.contains(normalizedName) ||
          normalizedName.contains(availableName)) {
        return ingredient;
      }

      // 유사한 단어 매칭 (예: "돼지고기"와 "삼겹살")
      if (_calculateSimilarity(availableName, normalizedName) > 0.7) {
        return ingredient;
      }
    }

    return null;
  }

  /// 유사한 재료 찾기 (대체재 제안용)
  List<Map<String, dynamic>> _findSimilarIngredients(
    String missingIngredientName,
    List<Ingredient> availableIngredients,
  ) {
    final normalizedName = missingIngredientName.toLowerCase().trim();
    final suggestions = <Map<String, dynamic>>[];

    for (final ingredient in availableIngredients) {
      final similarity = _calculateSimilarity(
        ingredient.name.toLowerCase(),
        normalizedName,
      );

      if (similarity > 0.5) {
        // 50% 이상 유사한 경우
        suggestions.add({
          'name': ingredient.name,
          'similarity': similarity,
          'ingredient_id': ingredient.id,
          'reason': _getSimilarityReason(
            ingredient.name,
            missingIngredientName,
          ),
        });
      }
    }

    // 유사도 순으로 정렬
    suggestions.sort(
      (a, b) =>
          (b['similarity'] as double).compareTo(a['similarity'] as double),
    );

    return suggestions.take(3).toList(); // 상위 3개만 반환
  }

  /// 문자열 유사도 계산 (간단한 구현)
  double _calculateSimilarity(String str1, String str2) {
    if (str1 == str2) return 1.0;
    if (str1.isEmpty || str2.isEmpty) return 0.0;

    final longer = str1.length > str2.length ? str1 : str2;
    final shorter = str1.length > str2.length ? str2 : str1;

    if (longer.length == 0) return 1.0;

    // Levenshtein 거리 기반 유사도
    final distance = _levenshteinDistance(longer, shorter);
    return (longer.length - distance) / longer.length;
  }

  /// Levenshtein 거리 계산
  int _levenshteinDistance(String str1, String str2) {
    final matrix = List.generate(
      str1.length + 1,
      (i) => List.generate(str2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= str1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= str2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= str1.length; i++) {
      for (int j = 1; j <= str2.length; j++) {
        final cost = str1[i - 1] == str2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // 삭제
          matrix[i][j - 1] + 1, // 삽입
          matrix[i - 1][j - 1] + cost, // 교체
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[str1.length][str2.length];
  }

  /// 유사도 이유 설명
  String _getSimilarityReason(String availableName, String missingName) {
    final available = availableName.toLowerCase();
    final missing = missingName.toLowerCase();

    if (available.contains(missing) || missing.contains(available)) {
      return '이름이 유사합니다';
    }

    // 카테고리 기반 매칭
    if (_isSameCategory(available, missing)) {
      return '같은 카테고리의 재료입니다';
    }

    return '유사한 재료로 대체 가능합니다';
  }

  /// 카테고리 기반 매칭
  bool _isSameCategory(String ingredient1, String ingredient2) {
    final categories = {
      '고기': ['돼지고기', '소고기', '닭고기', '양고기', '오리고기'],
      '채소': ['양파', '마늘', '대파', '당근', '양배추', '상추'],
      '과일': ['사과', '바나나', '오렌지', '포도', '딸기'],
      '해산물': ['생선', '새우', '게', '조개', '오징어'],
    };

    for (final category in categories.entries) {
      if (category.value.any((item) => ingredient1.contains(item)) &&
          category.value.any((item) => ingredient2.contains(item))) {
        return true;
      }
    }

    return false;
  }

  /// 레시피 이름들을 대상 언어로 번역
  Future<Map<String, String>> translateRecipeNames(
    List<String> recipeNames, {
    required AppLocale targetLocale,
  }) async {
    try {
      if (recipeNames.isEmpty) {
        return {};
      }

      final prompt = _buildTranslationPrompt(recipeNames, targetLocale);
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      // JSON 응답 파싱
      return _parseTranslationResponse(responseText, recipeNames);
    } catch (e) {
      throw Exception('레시피 이름 번역 중 오류가 발생했습니다: $e');
    }
  }

  /// 번역 프롬프트 구성
  String _buildTranslationPrompt(List<String> recipeNames, AppLocale targetLocale) {
    final namesList = recipeNames
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');

    // 대상 언어명 설정
    String targetLanguage;
    String translationExample;
    switch (targetLocale) {
      case AppLocale.usa:
        targetLanguage = '영어';
        translationExample = '비빔밥 → Bibimbap';
        break;
      case AppLocale.china:
        targetLanguage = '중국어';
        translationExample = '비빔밥 → 拌饭';
        break;
      case AppLocale.japan:
        targetLanguage = '일본어';
        translationExample = '비빔밥 → ビビンバ';
        break;
      case AppLocale.vietnam:
        targetLanguage = '베트남어';
        translationExample = '비빔밥 → Cơm trộn';
        break;
      default:
        targetLanguage = '영어';
        translationExample = '비빔밥 → Bibimbap';
    }

    return '''
다음 한국어 레시피 이름들을 $targetLanguage로 번역해주세요.
레시피 이름들은 한국 음식의 전통적인 이름입니다.

레시피 이름들:
$namesList

응답은 JSON 형식으로 다음과 같이 반환해주세요:
{
  "${recipeNames[0]}": "$targetLanguage 번역",
  "${recipeNames.length > 1 ? recipeNames[1] : ''}": "$targetLanguage 번역",
  ...
}

주의사항:
- 각 레시피 이름을 $targetLanguage로 정확하게 번역해야 합니다
- 한국 음식의 전통적인 $targetLanguage 이름이 있다면 그것을 사용하세요 (예: $translationExample)
- $targetLanguage 사용자가 이해할 수 있는 자연스러운 표현을 사용하세요
- JSON 형식만 반환하고 다른 설명은 포함하지 마세요
- 모든 레시피 이름을 반드시 번역해야 합니다
''';
  }

  /// 번역 응답 파싱
  Map<String, String> _parseTranslationResponse(
    String response,
    List<String> originalNames,
  ) {
    try {
      // JSON 부분만 추출 (```json``` 블록이 있는 경우)
      String jsonText = response;
      if (response.contains('```json')) {
        final startIndex = response.indexOf('```json') + 7;
        final endIndex = response.lastIndexOf('```');
        if (endIndex > startIndex) {
          jsonText = response.substring(startIndex, endIndex).trim();
        }
      } else if (response.contains('```')) {
        // ```json이 없고 ```만 있는 경우
        final startIndex = response.indexOf('```') + 3;
        final endIndex = response.lastIndexOf('```');
        if (endIndex > startIndex) {
          jsonText = response.substring(startIndex, endIndex).trim();
        }
      }

      // JSON 파싱
      final Map<String, dynamic> translationMap =
          json.decode(jsonText) as Map<String, dynamic>;

      // String으로 변환
      final result = <String, String>{};
      for (final name in originalNames) {
        if (translationMap.containsKey(name)) {
          result[name] = translationMap[name].toString().trim();
        } else {
          // 번역되지 않은 경우 원본 이름 유지
          result[name] = name;
        }
      }

      return result;
    } catch (e) {
      // 파싱 실패 시 원본 이름 반환
      final result = <String, String>{};
      for (final name in originalNames) {
        result[name] = name;
      }
      return result;
    }
  }

  /// 텍스트를 대상 언어로 번역
  Future<String> translateText(
    String text, {
    required AppLocale targetLocale,
  }) async {
    try {
      if (text.isEmpty) {
        return text;
      }

      final prompt = _buildTextTranslationPrompt(text, targetLocale);
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      // 응답에서 번역된 텍스트 추출 (JSON 블록 제거)
      String translatedText = responseText.trim();
      if (translatedText.contains('```json')) {
        final startIndex = translatedText.indexOf('```json') + 7;
        final endIndex = translatedText.lastIndexOf('```');
        if (endIndex > startIndex) {
          translatedText = translatedText.substring(startIndex, endIndex).trim();
        }
      } else if (translatedText.contains('```')) {
        final startIndex = translatedText.indexOf('```') + 3;
        final endIndex = translatedText.lastIndexOf('```');
        if (endIndex > startIndex) {
          translatedText = translatedText.substring(startIndex, endIndex).trim();
        }
      }

      return translatedText;
    } catch (e) {
      throw Exception('텍스트 번역 중 오류가 발생했습니다: $e');
    }
  }

  /// 텍스트 번역 프롬프트 구성
  String _buildTextTranslationPrompt(String text, AppLocale targetLocale) {
    // 대상 언어명 설정
    String targetLanguage;
    switch (targetLocale) {
      case AppLocale.usa:
        targetLanguage = '영어';
        break;
      case AppLocale.china:
        targetLanguage = '중국어';
        break;
      case AppLocale.japan:
        targetLanguage = '일본어';
        break;
      case AppLocale.vietnam:
        targetLanguage = '베트남어';
        break;
      default:
        targetLanguage = '영어';
    }

    return '''
다음 한국어 텍스트를 $targetLanguage로 번역해주세요.
조리 방법이나 설명 텍스트입니다.

원본 텍스트:
$text

번역 규칙:
- 자연스럽고 이해하기 쉬운 $targetLanguage로 번역해주세요
- 줄바꿈은 그대로 유지해주세요
- 요리 용어는 $targetLanguage 사용자가 이해할 수 있도록 번역해주세요
- 번역된 텍스트만 반환하고 다른 설명은 포함하지 마세요

번역된 텍스트:
''';
  }

  /// 단위를 대상 언어로 번역
  Future<Map<String, String>> translateUnits(
    List<String> units, {
    required AppLocale targetLocale,
  }) async {
    try {
      if (units.isEmpty) {
        return {};
      }

      // 중복 제거
      final uniqueUnits = units.toSet().toList();
      
      // 국제 표준 단위는 번역 불필요
      final standardUnits = ['g', 'kg', 'ml', 'L'];
      final unitsToTranslate = uniqueUnits
          .where((unit) => !standardUnits.contains(unit))
          .toList();

      if (unitsToTranslate.isEmpty) {
        // 모든 단위가 표준 단위인 경우 원본 반환
        final result = <String, String>{};
        for (final unit in uniqueUnits) {
          result[unit] = unit;
        }
        return result;
      }

      final prompt = _buildUnitTranslationPrompt(unitsToTranslate, targetLocale);
      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      // JSON 응답 파싱
      final translations = _parseTranslationResponse(responseText, unitsToTranslate);

      // 표준 단위도 결과에 포함
      final result = <String, String>{...translations};
      for (final unit in uniqueUnits) {
        if (standardUnits.contains(unit)) {
          result[unit] = unit;
        }
      }

      return result;
    } catch (e) {
      // 번역 실패 시 원본 단위 반환
      final result = <String, String>{};
      for (final unit in units.toSet()) {
        result[unit] = unit;
      }
      return result;
    }
  }

  /// 단위 번역 프롬프트 구성
  String _buildUnitTranslationPrompt(List<String> units, AppLocale targetLocale) {
    final unitsList = units
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');

    // 대상 언어명 설정
    String targetLanguage;
    Map<String, String> unitExamples;
    switch (targetLocale) {
      case AppLocale.usa:
        targetLanguage = '영어';
        unitExamples = {
          '개': 'pieces',
          '마리': 'heads',
          '장': 'sheets',
          '인분': 'servings',
        };
        break;
      case AppLocale.china:
        targetLanguage = '중국어';
        unitExamples = {
          '개': '个',
          '마리': '只',
          '장': '张',
          '인분': '份',
        };
        break;
      case AppLocale.japan:
        targetLanguage = '일본어';
        unitExamples = {
          '개': '個',
          '마리': '匹',
          '장': '枚',
          '인분': '人前',
        };
        break;
      case AppLocale.vietnam:
        targetLanguage = '베트남어';
        unitExamples = {
          '개': 'cái',
          '마리': 'con',
          '장': 'tờ',
          '인분': 'phần',
        };
        break;
      default:
        targetLanguage = '영어';
        unitExamples = {
          '개': 'pieces',
          '마리': 'heads',
          '장': 'sheets',
          '인분': 'servings',
        };
    }

    final examplesText = unitExamples.entries
        .map((e) => '${e.key} → ${e.value}')
        .join(', ');

    return '''
다음 한국어 단위들을 $targetLanguage로 번역해주세요.
요리 재료의 수량 단위입니다.

단위 목록:
$unitsList

응답은 JSON 형식으로 다음과 같이 반환해주세요:
{
  "${units[0]}": "$targetLanguage 번역",
  "${units.length > 1 ? units[1] : ''}": "$targetLanguage 번역",
  ...
}

참고 예시:
$examplesText

주의사항:
- 각 단위를 $targetLanguage로 정확하게 번역해야 합니다
- 요리에서 사용되는 일반적인 $targetLanguage 단위 표현을 사용하세요
- JSON 형식만 반환하고 다른 설명은 포함하지 마세요
- 모든 단위를 반드시 번역해야 합니다
''';
  }
}
