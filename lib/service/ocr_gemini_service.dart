import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// OCR 텍스트를 분석하여 재료명만 추출하고 Ingredient 모델에 맞는 JSON으로 변환하는 서비스
class OcrGeminiService {
  static const String _modelName = 'gemini-3-flash-preview';
  late final GenerativeModel _model;

  OcrGeminiService() {
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
        temperature: 0.3, // 낮은 temperature로 일관된 결과
        topK: 20,
        topP: 0.8,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// OCR 텍스트를 분석하여 재료명만 추출
  Future<List<String>> extractIngredientsFromOcrText(String ocrText) async {
    try {
      final prompt = _buildIngredientExtractionPrompt(ocrText);

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      // 텍스트 응답을 줄 단위로 분리하여 재료명 추출
      final parsedData = _parseTextResponse(responseText);
      return parsedData.map((item) => item['name'] as String).toList();
    } catch (e) {
      throw Exception('재료명 추출 중 오류가 발생했습니다: $e');
    }
  }

  /// OCR 텍스트를 분석하여 구조화된 재료 정보 추출
  Future<List<Map<String, dynamic>>> extractStructuredIngredientsFromOcrText(
    String ocrText,
  ) async {
    try {
      final prompt = _buildIngredientExtractionPrompt(ocrText);

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';

      // 구조화된 데이터로 파싱
      return _parseTextResponse(responseText);
    } catch (e) {
      throw Exception('구조화된 재료 정보 추출 중 오류가 발생했습니다: $e');
    }
  }

  /// 텍스트 응답 파싱
  List<Map<String, dynamic>> _parseTextResponse(String response) {
    final lines = response.split('\n');
    final ingredients = <Map<String, dynamic>>[];

    for (final line in lines) {
      final trimmedLine = line.trim();

      // 빈 줄이나 너무 짧은 줄 제외
      if (trimmedLine.isEmpty || trimmedLine.length < 3) continue;

      // 마크다운이나 설명 텍스트 제외
      if (trimmedLine.startsWith('#') ||
          trimmedLine.startsWith('##') ||
          trimmedLine.startsWith('-') ||
          trimmedLine.startsWith('*') ||
          trimmedLine.startsWith('**') ||
          trimmedLine.startsWith('📋') ||
          trimmedLine.startsWith('🎯') ||
          trimmedLine.startsWith('📝') ||
          trimmedLine.startsWith('🔄') ||
          trimmedLine.startsWith('📊') ||
          trimmedLine.startsWith('주의사항') ||
          trimmedLine.startsWith('이제')) continue;

      // 파이프(|) 구분자가 있는 경우만 처리
      if (trimmedLine.contains('|')) {
        final parts =
            trimmedLine.split('|').map((part) => part.trim()).toList();

        if (parts.isNotEmpty && parts[0].isNotEmpty) {
          final ingredientInfo = <String, dynamic>{
            'name': parts[0], // 재료명
            'brand_quality': parts.length > 1 ? parts[1] : '',
            'package_info': parts.length > 2 ? parts[2] : '',
            'price_info': parts.length > 3 ? parts[3] : '', // 가격 정보 추가
            'additional_info': parts.length > 4 ? parts[4] : '',
            'full_text': trimmedLine,
          };

          // 재료명이 유효한지 확인 (너무 짧거나 숫자만 있는 경우 제외)
          if (_isValidIngredientName(parts[0])) {
            ingredients.add(ingredientInfo);
          }
        }
      }
      // 파이프가 없지만 유효한 재료명인 경우 (단순한 형태)
      else if (_isValidIngredientName(trimmedLine)) {
        final ingredientInfo = <String, dynamic>{
          'name': trimmedLine,
          'brand_quality': '',
          'package_info': '',
          'price_info': '', // 가격 정보 필드 추가
          'additional_info': '',
          'full_text': trimmedLine,
        };
        ingredients.add(ingredientInfo);
      }
    }

    return ingredients;
  }

  /// 유효한 재료명인지 확인
  bool _isValidIngredientName(String name) {
    if (name.isEmpty || name.length < 2) return false;

    // 숫자만 있는 경우 제외 (가격일 가능성 높음)
    if (RegExp(r'^[\d,\s]+$').hasMatch(name)) return false;

    // 가격 패턴 제외 (숫자 + 원, ₩, $ 등)
    if (RegExp(r'^[\d,]+원?$').hasMatch(name)) return false;
    if (RegExp(r'^₩[\d,]+$').hasMatch(name)) return false;
    if (RegExp(r'^\$[\d,]+$').hasMatch(name)) return false;
    if (RegExp(r'^[\d,]+\.\d{2}$').hasMatch(name)) return false; // 소수점 2자리 (가격)

    // 수량 패턴 제외 (숫자 + 단위)
    if (RegExp(r'^[\d.]+[gkgmlL개팩봉]+$').hasMatch(name)) return false;
    if (RegExp(r'^[\d.]+[gkgmlL개팩봉]\s*\*\s*[\d]+$').hasMatch(name))
      return false; // 300g*2

    // 바코드 패턴 제외 (13자리 숫자)
    if (RegExp(r'^\d{13}$').hasMatch(name)) return false;

    // 할인/특매 정보 제외
    if (name.contains('할인') || name.contains('특매') || name.contains('마이너스'))
      return false;

    // 요약 정보 제외
    final summaryKeywords = [
      '합계',
      '총액',
      '부가세',
      '과세',
      '영수증',
      '상점',
      '현금',
      '카드',
      '포인트',
      '소계',
      '공급가액',
      '세액',
      '결제',
      '거래',
      '매장',
      '점포',
      '영업시간',
    ];
    if (summaryKeywords.any((keyword) => name.contains(keyword))) return false;

    // 날짜 패턴 제외
    if (RegExp(r'^\d{6}$').hasMatch(name)) return false; // 251219
    if (RegExp(r'^\d{4}\.\d{2}\.\d{2}$').hasMatch(name))
      return false; // 2024.01.15
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(name))
      return false; // 2024-01-15

    // 시간 패턴 제외
    if (RegExp(r'^\d{2}:\d{2}$').hasMatch(name)) return false; // 14:30
    if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(name)) return false; // 14:30:25

    // 전화번호 패턴 제외
    if (RegExp(r'^\d{2,4}-\d{3,4}-\d{4}$').hasMatch(name)) return false;

    // 사업자번호 패턴 제외
    if (RegExp(r'^\d{3}-\d{2}-\d{5}$').hasMatch(name)) return false;

    // 가격 관련 단어가 포함된 경우 제외
    final priceKeywords = ['원', '₩', '할인', '특매', '마이너스', '가격', '비용'];
    if (priceKeywords.any((keyword) => name.contains(keyword))) return false;

    // 숫자로 시작하고 특수문자나 단위가 없는 경우 (가격일 가능성 높음)
    if (RegExp(r'^\d').hasMatch(name) &&
        name.replaceAll(',', '').replaceAll(' ', '').length > 3 &&
        RegExp(r'^[\d,\s]+$').hasMatch(name)) return false;

    return true;
  }

  /// 재료명 추출 프롬프트 구성
  String _buildIngredientExtractionPrompt(String ocrText) {
    return '''
당신은 영수증 OCR 텍스트를 분석하여 식재료명과 관련 정보를 정확하게 추출하는 전문가입니다.

## 📋 분석 대상 OCR 텍스트:
```
$ocrText
```

## 🎯 분석 목표:
1. **재료명과 상세 정보 추출**: 식재료, 식품, 음식 재료의 이름과 관련 정보를 함께 추출
2. **가격 정보 연결**: OCR에서 가격이 밀려나도 재료명과 연결하여 추출
3. **제외할 항목들**:
   - 바코드 (예: 8801284256228)
   - 과세 정보 (예: 부가세, 과세)
   - 합계 정보 (예: 합계, 총액, 소계)
   - 날짜 정보 (예: #251219, 2024.01.15)
   - 기타 상점 정보 (예: 현금, 카드, 포인트)

## 📝 추출 규칙:
1. **재료명**: "소시지", "감자", "커피", "무쌈", "사탕" 등
2. **품질/브랜드 정보 포함**: "청정원_칼집비엔나", "왕특_국산", "빙그레_아카페라_카라멜마끼아또" 등
3. **패키지 정보 포함**: "300g*2", "2kg", "12g" 등
4. **가격 정보 연결**: 재료명과 관련된 가격을 찾아서 연결
5. **중복 제거**: 같은 재료는 한 번만 추출
6. **정규화**: 비슷한 이름은 통일

## 🔄 출력 형식:
재료명과 관련 정보를 한 줄에 하나씩 나열해주세요. 
형식: "재료명 | 브랜드/품질 | 패키지정보 | 가격정보 | 기타설명"

**중요**: 
- 각 필드는 파이프(|)로 구분하고, 정보가 없는 경우 빈 공간을 두세요.
- 가격 정보는 재료명과 관련된 것을 찾아서 연결하세요.
- OCR에서 가격이 밀려나도 패턴을 분석하여 연결하세요.

예시:
소시지 | 청정원_칼집비엔나 | 300g*2 | 2,890원 | 
감자 | 왕특_국산 | 2kg | 2,900원 | 
커피 | 빙그레_아카페라 | | 990원 | 카라멜마끼아또
무쌈 | 풀무원 | | 1,190원 | 새콤한
사탕 | 솜사탕_도라에몽 | | 850원 | 컵

**주의사항**:
- 재료명이 확실하지 않은 경우 제외
- 상점 정보나 요약 정보는 제외
- 실제 식재료/식품만 추출
- 가격 정보를 재료명과 연결하여 추출
- 할인 정보(-920, -1,000 등)는 해당 재료의 할인으로 처리

이제 위 OCR 텍스트를 분석하여 재료명과 관련 정보(가격 포함)를 추출해주세요.
''';
  }

  /// 추출된 재료를 Ingredient 모델 형식으로 변환
  List<Map<String, dynamic>> convertToIngredientFormat(
    List<Map<String, dynamic>> extractedIngredients,
  ) {
    try {
      final List<Map<String, dynamic>> ingredients = [];

      for (final ingredient in extractedIngredients) {
        final name = ingredient['name'] as String? ?? '';
        final brandQuality = ingredient['brand_quality'] as String? ?? '';
        final packageInfo = ingredient['package_info'] as String? ?? '';
        final priceInfo = ingredient['price_info'] as String? ?? ''; // 가격 정보
        final additionalInfo = ingredient['additional_info'] as String? ?? '';
        final fullText = ingredient['full_text'] as String? ?? '';

        if (name.isNotEmpty) {
          // 패키지 정보에서 수량과 단위 추출
          final packageData = _extractPackageInfo(packageInfo);

          // 가격 정보에서 가격 추출
          final extractedPrice = _extractPriceFromText(priceInfo);

          // 카테고리와 신뢰도 계산
          final category = _guessCategory(name);
          final confidence = _calculateConfidence(
            name,
            brandQuality,
            packageInfo,
            additionalInfo,
            priceInfo, // 가격 정보도 신뢰도 계산에 포함
          );
          final quality = _getExtractionQuality(confidence);

          // Ingredient 모델에 맞는 형식으로 변환
          final ingredientData = {
            'name': _cleanIngredientName(name),
            'original_ocr_text': fullText,
            'brand': brandQuality.isNotEmpty ? brandQuality : null,
            'package_info': packageInfo.isNotEmpty ? packageInfo : null,
            'price_info': priceInfo.isNotEmpty ? priceInfo : null, // 가격 정보 추가
            'additional_info':
                additionalInfo.isNotEmpty ? additionalInfo : null,
            'category': category,
            'confidence': confidence,
            'suggested_price': extractedPrice, // 추출된 가격 사용
            'suggested_amount': packageData['amount'] ?? 0.0,
            'suggested_unit': packageData['unit'] ?? 'g',
            'extraction_quality': quality,
            'parsed_details': {
              'brand_quality': brandQuality,
              'package_info': packageInfo,
              'price_info': priceInfo, // 가격 정보도 상세 정보에 포함
              'additional_info': additionalInfo,
            },
          };

          ingredients.add(ingredientData);
        }
      }

      return ingredients;
    } catch (e) {
      throw Exception('Ingredient 형식 변환 중 오류가 발생했습니다: $e');
    }
  }

  /// 텍스트에서 가격 추출
  double _extractPriceFromText(String priceText) {
    if (priceText.isEmpty) return 0.0;

    try {
      // 숫자와 쉼표만 추출
      final priceMatch = RegExp(r'[\d,]+').firstMatch(priceText);
      if (priceMatch != null) {
        final priceString = priceMatch.group(0)?.replaceAll(',', '') ?? '0';
        return double.tryParse(priceString) ?? 0.0;
      }
    } catch (e) {
      print('가격 추출 중 오류: $e');
    }

    return 0.0;
  }

  /// 신뢰도 계산
  double _calculateConfidence(
    String name,
    String brandQuality,
    String packageInfo,
    String additionalInfo,
    String priceInfo, // 가격 정보도 신뢰도 계산에 포함
  ) {
    double confidence = 0.5; // 기본 신뢰도

    // 재료명 길이에 따른 신뢰도
    if (name.length >= 3) confidence += 0.1;
    if (name.length >= 5) confidence += 0.1;

    // 브랜드/품질 정보가 있으면 신뢰도 증가
    if (brandQuality.isNotEmpty) confidence += 0.15;

    // 패키지 정보가 있으면 신뢰도 증가
    if (packageInfo.isNotEmpty) confidence += 0.1;

    // 추가 정보가 있으면 신뢰도 증가
    if (additionalInfo.isNotEmpty) confidence += 0.05;

    // 가격 정보가 있으면 신뢰도 증가
    if (priceInfo.isNotEmpty) confidence += 0.1;

    // 카테고리가 명확하면 신뢰도 증가
    final category = _guessCategory(name);
    if (category != '기타') confidence += 0.1;

    return confidence.clamp(0.0, 1.0);
  }

  /// 추출 품질 평가
  String _getExtractionQuality(double confidence) {
    if (confidence >= 0.9) return 'excellent';
    if (confidence >= 0.7) return 'good';
    if (confidence >= 0.5) return 'fair';
    return 'poor';
  }

  /// 패키지 정보에서 수량과 단위 추출
  Map<String, dynamic> _extractPackageInfo(String packageInfo) {
    if (packageInfo.isEmpty) return {'amount': 0.0, 'unit': 'g'};

    // 숫자 + 단위 패턴 매칭
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*([a-zA-Z가-힣]+)');
    final match = regex.firstMatch(packageInfo);

    if (match != null) {
      final amount = double.tryParse(match.group(1) ?? '0') ?? 0.0;
      final unit = match.group(2) ?? 'g';

      // 단위 정규화
      final normalizedUnit = _normalizeUnit(unit);

      return {'amount': amount, 'unit': normalizedUnit};
    }

    // 단순 숫자만 있는 경우
    final numberRegex = RegExp(r'(\d+(?:\.\d+)?)');
    final numberMatch = numberRegex.firstMatch(packageInfo);
    if (numberMatch != null) {
      final amount = double.tryParse(numberMatch.group(1) ?? '0') ?? 0.0;
      return {'amount': amount, 'unit': 'g'};
    }

    return {'amount': 0.0, 'unit': 'g'};
  }

  /// 단위 정규화
  String _normalizeUnit(String unit) {
    final normalized = unit.toLowerCase().trim();

    switch (normalized) {
      case 'g':
      case 'gram':
      case '그램':
        return 'g';
      case 'kg':
      case 'kilo':
      case '킬로':
        return 'kg';
      case 'ml':
      case '밀리리터':
        return 'ml';
      case 'l':
      case 'liter':
      case '리터':
        return 'L';
      case '개':
      case 'ea':
      case 'piece':
        return '개';
      case '팩':
      case 'pack':
        return '팩';
      case '봉':
      case 'bag':
        return '봉';
      default:
        return normalized;
    }
  }

  /// 재료명 정리 (불필요한 문자 제거)
  String _cleanIngredientName(String name) {
    // 괄호 안의 상세 정보는 유지하되, 불필요한 특수문자만 제거
    String cleaned = name.trim();

    // 연속된 공백을 하나로
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned;
  }

  /// 카테고리 추측
  String _guessCategory(String ingredientName) {
    final name = ingredientName.toLowerCase();

    // 고기/육류
    if (name.contains('고기') ||
        name.contains('소시지') ||
        name.contains('돼지') ||
        name.contains('소') ||
        name.contains('닭') ||
        name.contains('오리') ||
        name.contains('햄') ||
        name.contains('베이컨') ||
        name.contains('치킨') ||
        name.contains('돈까스') ||
        name.contains('불고기')) {
      return '고기';
    }
    // 채소
    else if (name.contains('감자') ||
        name.contains('무') ||
        name.contains('채소') ||
        name.contains('양파') ||
        name.contains('마늘') ||
        name.contains('대파') ||
        name.contains('당근') ||
        name.contains('양배추') ||
        name.contains('상추') ||
        name.contains('깻잎') ||
        name.contains('고추') ||
        name.contains('피망') ||
        name.contains('버섯')) {
      return '채소';
    }
    // 과일
    else if (name.contains('사과') ||
        name.contains('바나나') ||
        name.contains('오렌지') ||
        name.contains('포도') ||
        name.contains('딸기') ||
        name.contains('키위') ||
        name.contains('망고') ||
        name.contains('복숭아')) {
      return '과일';
    }
    // 해산물
    else if (name.contains('생선') ||
        name.contains('고등어') ||
        name.contains('연어') ||
        name.contains('새우') ||
        name.contains('게') ||
        name.contains('조개') ||
        name.contains('오징어') ||
        name.contains('문어')) {
      return '해산물';
    }
    // 유제품
    else if (name.contains('우유') ||
        name.contains('치즈') ||
        name.contains('요거트') ||
        name.contains('버터') ||
        name.contains('크림') ||
        name.contains('생크림')) {
      return '유제품';
    }
    // 곡물/면류
    else if (name.contains('쌀') ||
        name.contains('밀') ||
        name.contains('국수') ||
        name.contains('파스타') ||
        name.contains('빵') ||
        name.contains('토스트') ||
        name.contains('떡')) {
      return '곡물';
    }
    // 조미료/양념
    else if (name.contains('소금') ||
        name.contains('설탕') ||
        name.contains('간장') ||
        name.contains('된장') ||
        name.contains('고추장') ||
        name.contains('식초') ||
        name.contains('참기름') ||
        name.contains('들기름') ||
        name.contains('후추') ||
        name.contains('카레') ||
        name.contains('케찹') ||
        name.contains('마요네즈')) {
      return '조미료';
    }
    // 음료/간식
    else if (name.contains('커피') ||
        name.contains('사탕') ||
        name.contains('음료') ||
        name.contains('주스') ||
        name.contains('탄산') ||
        name.contains('차') ||
        name.contains('우유') ||
        name.contains('초콜릿') ||
        name.contains('과자') ||
        name.contains('아이스크림')) {
      return '음료/간식';
    }

    return '기타';
  }

  /// OCR 텍스트에서 재료명 추출 및 정리 (통합 메서드)
  Future<Map<String, dynamic>> processOcrTextForIngredients(
    String ocrText,
  ) async {
    try {
      // 1단계: Gemini로 구조화된 재료 정보 추출
      final extractedIngredients =
          await extractStructuredIngredientsFromOcrText(ocrText);

      // 2단계: Ingredient 형식으로 변환
      final ingredientFormats = convertToIngredientFormat(extractedIngredients);

      // 3단계: 결과 요약
      final result = {
        'success': true,
        'ingredients': ingredientFormats,
        'total_extracted': extractedIngredients.length,
        'total_converted': ingredientFormats.length,
        'ocr_text_length': ocrText.length,
        'processing_timestamp': DateTime.now().toIso8601String(),
        'analysis_summary': {
          'high_confidence_count':
              ingredientFormats.where((i) => i['confidence'] >= 0.8).length,
          'medium_confidence_count': ingredientFormats
              .where((i) => i['confidence'] >= 0.6 && i['confidence'] < 0.8)
              .length,
          'low_confidence_count':
              ingredientFormats.where((i) => i['confidence'] < 0.6).length,
        },
      };

      return result;
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

  /// 재료명 정규화 (유사한 이름 통합)
  List<Map<String, dynamic>> normalizeIngredientNames(
    List<Map<String, dynamic>> ingredients,
  ) {
    try {
      final Map<String, Map<String, dynamic>> normalizedMap = {};

      for (final ingredient in ingredients) {
        final name = ingredient['name'] as String;
        final normalizedName = _normalizeName(name);

        if (normalizedMap.containsKey(normalizedName)) {
          // 기존 항목과 병합
          final existing = normalizedMap[normalizedName]!;
          existing['variations'] = [
            ...(existing['variations'] as List? ?? []),
            name,
          ];

          // 신뢰도가 높은 것을 선택
          if (ingredient['confidence'] > existing['confidence']) {
            existing['confidence'] = ingredient['confidence'];
            existing['original_ocr_text'] = ingredient['original_ocr_text'];
          }
        } else {
          // 새 항목 추가
          ingredient['normalized_name'] = normalizedName;
          ingredient['variations'] = [name];
          normalizedMap[normalizedName] = ingredient;
        }
      }

      return normalizedMap.values.toList();
    } catch (e) {
      throw Exception('재료명 정규화 중 오류가 발생했습니다: $e');
    }
  }

  /// 재료명 정규화 (간단한 형태로 변환)
  String _normalizeName(String name) {
    // 괄호 안의 상세 정보 제거
    String normalized = name.replaceAll(RegExp(r'\([^)]*\)'), '').trim();

    // 특수문자 제거
    normalized = normalized.replaceAll(RegExp(r'[^\w\s가-힣]'), ' ').trim();

    // 연속된 공백을 하나로
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    return normalized.toLowerCase();
  }
}
