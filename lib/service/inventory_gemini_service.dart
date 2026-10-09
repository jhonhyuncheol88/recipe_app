import 'package:firebase_ai/firebase_ai.dart';
import 'gemini_model.dart';

/// AI 재고 스캔 결과 1행.
class InventoryAiRow {
  final String name;
  final double qty;
  final String unit;
  final String note;

  const InventoryAiRow({
    required this.name,
    required this.qty,
    required this.unit,
    this.note = '',
  });
}

/// 사진 속 텍스트(OCR 결과)를 분석해 재고 수량을 추측하는 서비스.
/// [OcrGeminiService] 와 같은 패턴 — 별도 프롬프트/파서를 가진 독립 클래스.
class InventoryGeminiService {
  late final GenerativeModel _model = createGeminiModel(
    generationConfig: GenerationConfig(
      temperature: 0.3,
      topK: 20,
      topP: 0.8,
      maxOutputTokens: 2048,
    ),
  );

  /// OCR 텍스트에서 재고 추측 목록 추출
  Future<List<InventoryAiRow>> analyzeInventoryText(String ocrText) async {
    final prompt = _buildPrompt(ocrText);
    final response = await _model.generateContent([Content.text(prompt)]);
    return parseResponse(response.text ?? '');
  }

  /// `재료명 | 수량 | 단위 | 비고` 형식 응답 파싱. 수량 파싱 불가 행은 무시.
  static List<InventoryAiRow> parseResponse(String text) {
    final rows = <InventoryAiRow>[];
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || !trimmed.contains('|')) continue;
      if (trimmed.startsWith('#') || trimmed.startsWith('-')) continue;

      final parts = trimmed.split('|').map((p) => p.trim()).toList();
      if (parts.length < 2 || parts[0].isEmpty) continue;

      final qty = double.tryParse(parts[1].replaceAll(',', ''));
      if (qty == null || qty < 0) continue;

      rows.add(
        InventoryAiRow(
          name: parts[0],
          qty: qty,
          unit: parts.length > 2 ? parts[2] : '',
          note: parts.length > 3 ? parts[3] : '',
        ),
      );
    }
    return rows;
  }

  String _buildPrompt(String ocrText) {
    return '''
당신은 매장 재고 사진에서 추출된 텍스트를 분석하여 재료별 현재 재고 수량을 추측하는 전문가입니다.

## 분석 대상 텍스트 (사진 OCR 결과):
```
$ocrText
```

## 목표:
- 텍스트에 보이는 식재료의 이름과 수량을 추측합니다.
- 박스/포장 라벨의 용량 표기 (예: 300g*2, 2kg) 와 개수를 활용합니다.
- 식재료가 아닌 것 (날짜, 가격표, 바코드, 매장 정보) 은 제외합니다.

## 출력 형식 (한 줄에 하나, 파이프 구분):
재료명 | 수량 | 단위 | 비고

규칙:
- 수량은 숫자만 (예: 4, 2.5). 추측 불가 시 그 행은 출력하지 않습니다.
- 단위는 kg, g, L, ml, 개, 팩, 봉 중 텍스트에서 확인되는 것. 불명확하면 개.
- 설명 문장, 헤더, 마크다운 없이 데이터 행만 출력합니다.

예시:
양파 | 4 | kg | 박스 라벨
소시지 | 2 | 팩 |
''';
  }
}
