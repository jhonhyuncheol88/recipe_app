import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/service/inventory_gemini_service.dart';

void main() {
  test('파이프 응답 파싱: 정상 행', () {
    const response = '''
양파 | 4 | kg | 박스 라벨 기준
소시지 | 2 | 팩 |
''';
    final rows = InventoryGeminiService.parseResponse(response);
    expect(rows.length, 2);
    expect(rows[0].name, '양파');
    expect(rows[0].qty, 4);
    expect(rows[0].unit, 'kg');
    expect(rows[1].name, '소시지');
    expect(rows[1].unit, '팩');
  });

  test('잘못된 행 무시: 헤더/빈 줄/수량 파싱 불가', () {
    const response = '''
# 분석 결과
양파 | abc | kg |

감자 | 3 | kg |
''';
    final rows = InventoryGeminiService.parseResponse(response);
    expect(rows.length, 1);
    expect(rows[0].name, '감자');
  });
}
