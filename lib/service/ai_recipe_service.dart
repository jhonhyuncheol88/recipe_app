import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/ingredient.dart';
import '../util/app_locale.dart';

/// AI 레시피 생성 서비스 (Gemini API 기반)
class AiRecipeService {
  static const String _modelName = 'gemini-3-flash-preview';
  late final GenerativeModel _model;

  AiRecipeService() {
    _initializeModel();
  }

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
        maxOutputTokens: 4096, // 대량 메뉴 생성을 위해 토큰 제한 확장
      ),
    );
  }

  /// 식자재 목록을 기반으로 전문가용 레시피 생성
  Future<Map<String, dynamic>> generateRecipeFromIngredients(
    List<Ingredient> ingredients, {
    required AppLocale targetLocale,
    String? cuisineType,
    String? dietaryRestrictions,
    int servings = 10,
    int cookingTime = 30,
  }) async {
    try {
      final ingredientList = ingredients
          .map((i) => '${i.name} (${i.purchaseAmount} ${i.purchaseUnitId})')
          .join(', ');

      final prompt = _buildProfessionalRecipePrompt(
        ingredientList,
        targetLocale: targetLocale,
        cuisineType: cuisineType,
        dietaryRestrictions: dietaryRestrictions,
        servings: servings,
        cookingTime: cookingTime,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseRecipeResponse(response.text ?? '');
    } catch (e) {
      throw Exception('전문가 레시피 생성 중 오류 발생: $e');
    }
  }

  /// 동일 재료 기반 퓨전/창의적 레시피 생성
  Future<Map<String, dynamic>> generateDifferentStyleRecipe(
    List<Ingredient> ingredients, {
    required AppLocale targetLocale,
    int servings = 10,
    int cookingTime = 30,
    List<String>? cuisineTypes,
  }) async {
    try {
      final ingredientList = ingredients
          .map((i) => '${i.name} (${i.purchaseAmount} ${i.purchaseUnitId})')
          .join(', ');

      final prompt = _buildFusionRecipePrompt(
        ingredientList,
        targetLocale: targetLocale,
        servings: servings,
        cookingTime: cookingTime,
        cuisineTypes: cuisineTypes,
      );

      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseRecipeResponse(response.text ?? '');
    } catch (e) {
      throw Exception('퓨전 레시피 생성 중 오류 발생: $e');
    }
  }

  String _buildProfessionalRecipePrompt(
    String ingredients, {
    required AppLocale targetLocale,
    String? cuisineType,
    String? dietaryRestrictions,
    int servings = 10,
    int cookingTime = 30,
  }) {
    return '''
You are a world-class Executive Chef. 
Create a professional RESTAURANT MANUAL for a dish using the provided ingredients.

### LANGUAGE REQUIREMENT (CRITICAL)
- The entire response MUST be in ${targetLocale.nativeName}.
- All fields in the JSON (recipe_name, description, unit, instructions, tips, etc.) MUST be written in ${targetLocale.nativeName}.
- Do NOT use English unless it's a globally recognized culinary term that has no equivalent in ${targetLocale.nativeName}.

### CONSTRAINTS
- Ingredients: $ingredients
- Cuisine Style: ${cuisineType ?? 'Professional'}
- Servings: $servings (Commercial Scale)
- Time Limit: $cookingTime minutes

### OPERATIONAL GUIDELINES
1. **Commercial Feasibility**: Practical for heavy-volume service.
2. **Standardization**: Use precise metric units (g, ml).
3. **NO NUMBERING**: Do NOT start instruction strings with "1. ", "2. ", etc.
4. **Output Format**: Valid JSON only.

### JSON OUTPUT SCHEMA
{
  "recipe_name": "Name in ${targetLocale.nativeName}",
  "description": "Description in ${targetLocale.nativeName}",
  "cuisine_type": "Main influence",
  "servings": $servings,
  "prep_time_minutes": <int>,
  "cook_time_minutes": <int>,
  "total_time_minutes": <int>,
  "difficulty": "Beginner|Intermediate|Advanced",
  "ingredients": [
    {"name": "Name in ${targetLocale.nativeName}", "quantity": <num>, "unit": "Unit in ${targetLocale.nativeName}"}
  ],
  "instructions": [
    "Step details in ${targetLocale.nativeName}",
    "Step details in ${targetLocale.nativeName}"
  ],
  "tips": ["Tip in ${targetLocale.nativeName}"],
  "nutritional_info": {
    "calories": "X kcal", "protein": "X g", "carbohydrates": "X g", "fat": "X g"
  },
  "estimated_cost": {"amount": <num>, "currency": "KRW"},
  "tags": ["tag in ${targetLocale.nativeName}"]
}
''';
  }

  String _buildFusionRecipePrompt(
    String ingredients, {
    required AppLocale targetLocale,
    int servings = 10,
    int cookingTime = 30,
    List<String>? cuisineTypes,
  }) {
    final influence = cuisineTypes?.join(', ') ?? 'Modern Fusion';
    return '''
You are a R&D Chef. 
Create an unexpected yet professional Fusion Manual using the same ingredients.

### LANGUAGE REQUIREMENT (CRITICAL)
- The entire response MUST be in ${targetLocale.nativeName}.
- All fields in the JSON (recipe_name, description, unit, instructions, tips, etc.) MUST be written in ${targetLocale.nativeName}.

### CHALLENGE
- Ingredients: $ingredients
- Influences: $influence
- Focus: Creativity + Commercial Efficiency.

### MANUAL REQUIREMENTS
1. **Innovation**: Repurpose ingredients in a surprisingly different way.
2. **Professional Workflow**: Steps must be efficient for a line cook.
3. **NO NUMBERING**: Instruction text strings must NOT contain prefixes like "1. ".
4. **Visuals**: Describe garnish/plating in ${targetLocale.nativeName}.

(Use the same JSON Schema as the Professional Manual, ensuring all values are in ${targetLocale.nativeName})
''';
  }

  Map<String, dynamic> _parseRecipeResponse(String response) {
    try {
      String jsonText = response;
      if (response.contains('```json')) {
        final startIndex = response.indexOf('```json') + 7;
        final endIndex = response.lastIndexOf('```');
        if (endIndex > startIndex) {
          jsonText = response.substring(startIndex, endIndex).trim();
        }
      }
      final recipe = json.decode(jsonText);
      if (!recipe.containsKey('recipe_name') ||
          !recipe.containsKey('instructions')) {
        throw Exception('Invalid JSON structure from AI');
      }
      return recipe;
    } catch (e) {
      throw Exception('레시피 파싱 실패: $e');
    }
  }
}
