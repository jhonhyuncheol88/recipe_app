/// 재고 스테퍼의 단위 인식 스텝.
/// kg/L = 0.5, g/ml = 100, 그 외(개/팩/봉 등 개수 단위) = 1.
double inventoryStepForUnit(String unitName) {
  switch (unitName.trim().toLowerCase()) {
    case 'kg':
    case 'l':
      return 0.5;
    case 'g':
    case 'ml':
      return 100;
    default:
      return 1;
  }
}
