import 'unit_converter.dart';

/// 단위 검증 유틸리티
class UnitValidation {
  /// 유효한 단위인지 확인
  static bool isValidUnit(String unitId) {
    return UnitConverter.getUnit(unitId) != null;
  }

  /// 단위 타입이 일치하는지 확인
  static bool areSameType(String unit1, String unit2) {
    final type1 = UnitConverter.getUnitType(unit1);
    final type2 = UnitConverter.getUnitType(unit2);
    return type1 != null && type2 != null && type1 == type2;
  }

  /// 무게 단위인지 확인
  static bool isWeightUnit(String unitId) {
    final unit = UnitConverter.getUnit(unitId);
    return unit?.type == UnitType.weight;
  }

  /// 부피 단위인지 확인
  static bool isVolumeUnit(String unitId) {
    final unit = UnitConverter.getUnit(unitId);
    return unit?.type == UnitType.volume;
  }

  /// 개수 단위인지 확인
  static bool isCountUnit(String unitId) {
    final unit = UnitConverter.getUnit(unitId);
    return unit?.type == UnitType.count;
  }

  /// 양수인지 확인
  static bool isPositive(double value) {
    return value > 0;
  }

  /// 음수가 아닌지 확인
  static bool isNonNegative(double value) {
    return value >= 0;
  }

  /// 유효한 범위 내의 값인지 확인
  static bool isInRange(double value, double min, double max) {
    return value >= min && value <= max;
  }

  /// 단위 변환이 가능한지 확인
  static bool canConvert(String fromUnit, String toUnit) {
    if (!isValidUnit(fromUnit) || !isValidUnit(toUnit)) {
      return false;
    }
    return areSameType(fromUnit, toUnit);
  }

  /// 단위별 최대값 검증
  static bool isValidAmount(double amount, String unitId) {
    final unit = UnitConverter.getUnit(unitId);
    if (unit == null) return false;

    // 단위별 최대값 설정
    switch (unit.type) {
      case UnitType.weight:
        return amount <= 10000; // 10kg
      case UnitType.volume:
        return amount <= 100; // 100L
      case UnitType.count:
        return amount <= 1000; // 1000개
    }
  }

  /// 단위별 최소값 검증
  static bool isValidMinAmount(double amount, String unitId) {
    final unit = UnitConverter.getUnit(unitId);
    if (unit == null) return false;

    // 단위별 최소값 설정
    switch (unit.type) {
      case UnitType.weight:
        return amount >= 0.1; // 0.1g
      case UnitType.volume:
        return amount >= 0.1; // 0.1ml
      case UnitType.count:
        return amount >= 0.1; // 0.1개
    }
  }

  /// 가격 검증
  static bool isValidPrice(double price) {
    return price >= 0 && price <= 1000000; // 100만원
  }

  /// 수량 검증
  static bool isValidQuantity(double quantity, String unitId) {
    return isValidMinAmount(quantity, unitId) &&
        isValidAmount(quantity, unitId);
  }

  /// 단위 변환 가능 여부 메시지
  static String getConversionMessage(String fromUnit, String toUnit) {
    if (!isValidUnit(fromUnit)) {
      return '유효하지 않은 출발 단위입니다.';
    }
    if (!isValidUnit(toUnit)) {
      return '유효하지 않은 도착 단위입니다.';
    }
    if (!areSameType(fromUnit, toUnit)) {
      return '서로 다른 타입의 단위는 변환할 수 없습니다.';
    }
    return '변환 가능합니다.';
  }

  /// 단위별 추천 단위 목록
  static List<String> getRecommendedUnits(UnitType type) {
    switch (type) {
      case UnitType.weight:
        return ['g', 'kg']; // 그램, 킬로그램
      case UnitType.volume:
        return ['ml', 'L', 'cup', 'tbsp', 'tsp']; // 밀리리터, 리터, 컵, 큰술, 작은술
      case UnitType.count:
        return ['pcs']; // 개
    }
  }

  /// 단위별 표시 형식
  static String formatUnitDisplay(String unitId, double value) {
    final unit = UnitConverter.getUnit(unitId);
    if (unit == null) return '$value $unitId';

    // 소수점 자릿수 결정
    int decimalPlaces;
    if (value < 1) {
      decimalPlaces = 2;
    } else if (value < 10) {
      decimalPlaces = 1;
    } else {
      decimalPlaces = 0;
    }

    final formattedValue = value.toStringAsFixed(decimalPlaces);
    return '$formattedValue ${unit.symbol}';
  }

  /// 단위별 입력 힌트
  static String getInputHint(String unitId) {
    final unit = UnitConverter.getUnit(unitId);
    if (unit == null) return '수량을 입력하세요';

    switch (unit.type) {
      case UnitType.weight:
        return '무게를 입력하세요 (g, kg)';
      case UnitType.volume:
        return '부피를 입력하세요 (ml, L, cup)';
      case UnitType.count:
        return '개수를 입력하세요';
    }
  }

  /// 단위별 오류 메시지
  static String getErrorMessage(String unitId, double value) {
    if (!isValidMinAmount(value, unitId)) {
      return '최소값보다 작습니다.';
    }
    if (!isValidAmount(value, unitId)) {
      return '최대값을 초과했습니다.';
    }
    return '';
  }
}
