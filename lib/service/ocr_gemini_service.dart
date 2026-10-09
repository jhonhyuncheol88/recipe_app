import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';

/// 영수증 분석 AI (Firebase AI Logic — Gemini Developer API).
///
/// 영수증 사진 + ML Kit OCR 텍스트를 함께 Gemini 에 보내고, JSON 스키마로
/// 식재료 목록을 받는다. API 키는 앱에 두지 않는다 — Firebase 프로젝트를 통해 호출된다.
///
/// 결과 형식(`ingredients[*].name/suggested_price/suggested_amount/suggested_unit/category`)은
/// OcrResultPage 가 그대로 소비한다.
class OcrGeminiService {
  static const String _modelName = 'gemini-3-flash-preview';

  /// 앱 단위 마스터(database_helper 기본 단위 id). 드롭다운에 없는 값이 오면 안 되므로 enum 으로 제한.
  static const List<String> _units = [
    'g',
    'kg',
    'lb',
    'ml',
    'L',
    'cup',
    'tbsp',
    'tsp',
    '개',
    '마리',
    '장',
    '인분',
  ];

  static const List<String> _categories = [
    '고기',
    '채소',
    '과일',
    '해산물',
    '유제품',
    '곡물',
    '조미료',
    '음료/간식',
    '기타',
  ];

  GenerativeModel? _model;

  // Firebase.initializeApp 이후에 만들어야 하므로 첫 호출 때 생성.
  GenerativeModel get _receiptModel =>
      _model ??= FirebaseAI.googleAI().generativeModel(
        model: _modelName,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 4096,
          responseMimeType: 'application/json',
          responseSchema: _responseSchema,
        ),
      );

  static final Schema _responseSchema = Schema.object(
    properties: {
      'items': Schema.array(
        items: Schema.object(
          properties: {
            'name': Schema.string(description: '식재료명 (예: 감자, 소시지). 브랜드·용량 제외'),
            'brand': Schema.string(
              description: '브랜드/품질 정보 (예: 청정원, 국산). 없으면 빈 문자열',
            ),
            'package_info': Schema.string(
              description: '영수증에 적힌 규격 원문 (예: 300g*2). 없으면 빈 문자열',
            ),
            'price': Schema.number(
              description: '할인 반영 후 이 품목의 최종 결제 금액. 모르면 0',
            ),
            'amount': Schema.number(
              description: '총 구매량 (300g*2 이면 600). 모르면 0',
            ),
            'unit': Schema.enumString(
              enumValues: _units,
              description: 'amount 의 단위',
            ),
            'category': Schema.enumString(enumValues: _categories),
            'confidence': Schema.number(description: '이 항목 판독 확신도 0~1'),
          },
          propertyOrdering: [
            'name',
            'brand',
            'package_info',
            'price',
            'amount',
            'unit',
            'category',
            'confidence',
          ],
        ),
      ),
    },
  );

  /// 영수증 분석 (통합 메서드). [imageFile] 이 있으면 사진을 함께 보내 정확도를 높인다.
  Future<Map<String, dynamic>> processOcrTextForIngredients(
    String ocrText, {
    File? imageFile,
  }) async {
    try {
      final parts = <Part>[TextPart(_buildPrompt(ocrText))];
      if (imageFile != null) {
        parts.add(
          InlineDataPart(
            _mimeTypeOf(imageFile.path),
            await imageFile.readAsBytes(),
          ),
        );
      }

      final response = await _receiptModel.generateContent([
        Content.multi(parts),
      ]);
      final ingredients = _parseResponse(response.text ?? '');

      return {
        'success': true,
        'ingredients': ingredients,
        'total_extracted': ingredients.length,
        'total_converted': ingredients.length,
        'ocr_text_length': ocrText.length,
        'processing_timestamp': DateTime.now().toIso8601String(),
        'analysis_summary': {
          'high_confidence_count':
              ingredients
                  .where((i) => (i['confidence'] as double) >= 0.8)
                  .length,
          'medium_confidence_count':
              ingredients.where((i) {
                final c = i['confidence'] as double;
                return c >= 0.6 && c < 0.8;
              }).length,
          'low_confidence_count':
              ingredients
                  .where((i) => (i['confidence'] as double) < 0.6)
                  .length,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'ingredients': [],
        'total_extracted': 0,
        'total_converted': 0,
        'ocr_text_length': ocrText.length,
        'processing_timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  List<Map<String, dynamic>> _parseResponse(String text) {
    final decoded = jsonDecode(text) as Map<String, dynamic>;
    final items =
        (decoded['items'] as List? ?? []).cast<Map<String, dynamic>>();
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final item in items) {
      final name = (item['name'] as String? ?? '').trim().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
      if (name.isEmpty || !seen.add(name)) continue;

      final brand = (item['brand'] as String? ?? '').trim();
      final packageInfo = (item['package_info'] as String? ?? '').trim();
      final unit = item['unit'] as String? ?? '개';
      final category = item['category'] as String? ?? '기타';

      result.add({
        'name': name,
        'brand': brand.isEmpty ? null : brand,
        'package_info': packageInfo.isEmpty ? null : packageInfo,
        'category': _categories.contains(category) ? category : '기타',
        'confidence': ((item['confidence'] as num?)?.toDouble() ?? 0.5).clamp(
          0.0,
          1.0,
        ),
        'suggested_price': (item['price'] as num?)?.toDouble() ?? 0.0,
        'suggested_amount': (item['amount'] as num?)?.toDouble() ?? 0.0,
        'suggested_unit': _units.contains(unit) ? unit : '개',
      });
    }
    return result;
  }

  String _mimeTypeOf(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    if (lower.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }

  String _buildPrompt(String ocrText) {
    return '''
당신은 식당·카페 사장님의 장보기 영수증에서 식재료 구매 내역을 뽑아내는 전문가입니다.
첨부된 영수증 사진을 기준으로 읽고, 아래 OCR 텍스트는 보조 자료로만 쓰세요(OCR 은 줄이 밀리거나 글자가 틀릴 수 있음).

[OCR 텍스트]
$ocrText

[규칙]
- 실제로 구매한 식재료·식품·음료 품목만 items 에 넣는다.
- 바코드, 합계/소계/부가세/과세, 결제수단(현금·카드·포인트), 상점·날짜·시간·전화번호·사업자번호 줄은 제외한다.
- 할인 줄(-920 등)은 바로 위 품목 금액에서 빼서 price 에 반영한다. 할인 자체는 품목으로 넣지 않는다.
- 같은 품목이 여러 번 찍혔으면 하나로 합치고 수량·금액을 더한다.
- amount/unit 은 총 구매량으로 계산한다. 예: "300g*2" → 600 g, "2kg" → 2 kg, 규격이 없으면 수량을 개 단위로.
- 읽을 수 없거나 식재료인지 불확실하면 넣지 않는다. 지어내지 않는다.
''';
  }
}
