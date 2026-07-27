import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/util/inventory_step.dart';

void main() {
  test('단위별 스테퍼 스텝', () {
    expect(inventoryStepForUnit('kg'), 0.5);
    expect(inventoryStepForUnit('L'), 0.5);
    expect(inventoryStepForUnit('l'), 0.5);
    expect(inventoryStepForUnit('g'), 100);
    expect(inventoryStepForUnit('ml'), 100);
    expect(inventoryStepForUnit('개'), 1);
    expect(inventoryStepForUnit('팩'), 1);
    expect(inventoryStepForUnit('봉'), 1);
    expect(inventoryStepForUnit('unknown'), 1);
  });
}
