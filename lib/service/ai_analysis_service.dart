import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../model/ingredient.dart';
import '../util/app_locale.dart';

/// AI 분석 서비스 (식자재 인식, 레시피 구성 분석 등)
class AiAnalysisService {
  static const String _modelName = 'gemini-2.0-flash-exp';
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  AiAnalysisService() {
    _initializeModels();
  }

  void _initializeModels() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY가 설정되지 않았습니다.');
    }

    _model = GenerativeModel(model: _modelName, apiKey: apiKey);
    _visionModel = GenerativeModel(model: _modelName, apiKey: apiKey);
  }

  /// 이미지 분석을 통한 식자재 리스트 추출
  Future<List<String>> analyzeIngredientImage(List<int> imageBytes) async {
    try {
      final prompt = '이 이미지의 식자재들을 분석하여 한국어 이름만 쉼표로 구분해 나열해줘. 예: 양파, 대파, 삼겹살';
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ]),
      ];
      final response = await _visionModel.generateContent(content);
      return (response.text ?? '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('이미지 분석 실패: $e');
    }
  }

  /// AI 레시피 재료와 보유 재료 매칭 분석
  Map<String, dynamic> analyzeRecipeIngredients(
    Map<String, dynamic> recipe,
    List<Ingredient> availableIngredients,
  ) {
    final recipeIngredients = recipe['ingredients'] as List? ?? [];
    final availableForRecipe = <Map<String, dynamic>>[];
    final missingIngredients = <Map<String, dynamic>>[];

    for (final ing in recipeIngredients) {
      final name = ing['name'] as String? ?? '';
      final quantity = ing['quantity'] ?? 0.0;
      final unit = ing['unit'] as String? ?? '';

      final matched = _findMatchingIngredient(name, availableIngredients);

      if (matched != null) {
        availableForRecipe.add({
          'name': name,
          'quantity': quantity,
          'unit': unit,
          'available_amount': matched.purchaseAmount,
          'is_sufficient': true,
          'ingredient_id': matched.id,
        });
      } else {
        missingIngredients
            .add({'name': name, 'quantity': quantity, 'unit': unit});
      }
    }

    return {
      'available_ingredients': availableForRecipe,
      'missing_ingredients': missingIngredients,
      'can_make_recipe': missingIngredients.isEmpty,
    };
  }

  Ingredient? _findMatchingIngredient(String name, List<Ingredient> available) {
    final lower = name.toLowerCase();
    for (final a in available) {
      final aLower = a.name.toLowerCase();
      if (aLower == lower) return a;
      if (aLower.contains(lower) || lower.contains(aLower)) return a;
    }
    return null;
  }

  /// 텍스트 번역
  Future<String> translateText(String text,
      {required AppLocale targetLocale}) async {
    if (text.isEmpty) return text;
    final prompt = '''
Translate the following cooking-related text into ${targetLocale.nativeName}.
- Keep the original line breaks.
- Use natural terminology suitable for a professional chef in that language.
- Respond ONLY with the translated text.

Original text:
$text
''';
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? text;
    } catch (e) {
      return text;
    }
  }

  /// 단위 번역
  Future<Map<String, String>> translateUnits(List<String> units,
      {required AppLocale targetLocale}) async {
    if (units.isEmpty) return {};
    final uniqueUnits = units.toSet().toList();
    final prompt = '''
Translate the following cooking measurement units into ${targetLocale.nativeName}.
Return the result as a valid JSON object where keys are the original units and values are the translated units.
Example: {"개": "pcs", "g": "g"}

Units: ${uniqueUnits.join(", ")}
''';
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = _extractJson(response.text ?? '{}');
      return Map<String, String>.from(json.decode(jsonText));
    } catch (e) {
      return {for (var u in uniqueUnits) u: u};
    }
  }

  /// 레시피명 다국어 번역
  Future<Map<String, String>> translateRecipeNames(
    List<String> names, {
    required AppLocale targetLocale,
  }) async {
    if (names.isEmpty) return {};
    final prompt = '''
Translate the following Korean recipe names into ${targetLocale.nativeName}.
Return the result as a valid JSON object where keys are the original names and values are the translated names.

Names: ${names.join(", ")}
''';
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonText = _extractJson(response.text ?? '{}');
      return Map<String, String>.from(json.decode(jsonText));
    } catch (e) {
      return {for (var n in names) n: n};
    }
  }

  String _extractJson(String text) {
    if (text.contains('```json')) {
      final start = text.indexOf('```json') + 7;
      final end = text.lastIndexOf('```');
      return text.substring(start, end).trim();
    }
    return text.trim();
  }
}
