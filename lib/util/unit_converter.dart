/// 단위 타입 정의
enum UnitType {
  weight, // 무게
  volume, // 부피
  count, // 개수
}

/// 단위 정보 클래스
class Unit {
  final String id;
  final String name;
  final String symbol;
  final UnitType type;
  final double conversionFactor; // 기본 단위로의 변환 계수
  final String baseUnit; // 기본 단위

  const Unit({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.conversionFactor,
    required this.baseUnit,
  });
}

/// 단위 변환 유틸리티
class UnitConverter {
  // 무게 단위 (기본: g)
  static const Unit gram = Unit(
    id: 'g',
    name: '그램',
    symbol: 'g',
    type: UnitType.weight,
    conversionFactor: 1.0,
    baseUnit: 'g',
  );

  static const Unit kilogram = Unit(
    id: 'kg',
    name: '킬로그램',
    symbol: 'kg',
    type: UnitType.weight,
    conversionFactor: 1000.0,
    baseUnit: 'g',
  );

  static const Unit pound = Unit(
    id: 'lb',
    name: '파운드',
    symbol: 'lb',
    type: UnitType.weight,
    conversionFactor: 453.592,
    baseUnit: 'g',
  );

  static const Unit ounce = Unit(
    id: 'oz',
    name: '온스',
    symbol: 'oz',
    type: UnitType.weight,
    conversionFactor: 28.3495,
    baseUnit: 'g',
  );

  // 부피 단위 (기본: ml)
  static const Unit milliliter = Unit(
    id: 'ml',
    name: '밀리리터',
    symbol: 'ml',
    type: UnitType.volume,
    conversionFactor: 1.0,
    baseUnit: 'ml',
  );

  static const Unit liter = Unit(
    id: 'L',
    name: '리터',
    symbol: 'L',
    type: UnitType.volume,
    conversionFactor: 1000.0,
    baseUnit: 'ml',
  );

  static const Unit cup = Unit(
    id: 'cup',
    name: '컵',
    symbol: 'cup',
    type: UnitType.volume,
    conversionFactor: 236.588,
    baseUnit: 'ml',
  );

  static const Unit tablespoon = Unit(
    id: 'tbsp',
    name: '큰술',
    symbol: 'tbsp',
    type: UnitType.volume,
    conversionFactor: 14.7868,
    baseUnit: 'ml',
  );

  static const Unit teaspoon = Unit(
    id: 'tsp',
    name: '작은술',
    symbol: 'tsp',
    type: UnitType.volume,
    conversionFactor: 4.92892,
    baseUnit: 'ml',
  );

  // 개수 단위 (기본: 개)
  static const Unit piece = Unit(
    id: 'pcs',
    name: '개',
    symbol: '개',
    type: UnitType.count,
    conversionFactor: 1.0,
    baseUnit: 'pcs',
  );

  static const Unit dozen = Unit(
    id: 'dozen',
    name: '다스',
    symbol: 'dozen',
    type: UnitType.count,
    conversionFactor: 12.0,
    baseUnit: 'pcs',
  );

  // 한글 개수 단위 동의어들 (pcs와 동일한 베이스)
  static const Unit gae = Unit(
    id: '개',
    name: '개',
    symbol: '개',
    type: UnitType.count,
    conversionFactor: 1.0,
    baseUnit: 'pcs',
  );

  static const Unit inbun = Unit(
    id: '인분',
    name: '인분',
    symbol: '인분',
    type: UnitType.count,
    conversionFactor: 1.0,
    baseUnit: 'pcs',
  );

  static const Unit jogak = Unit(
    id: '조각',
    name: '조각',
    symbol: '조각',
    type: UnitType.count,
    conversionFactor: 1.0,
    baseUnit: 'pcs',
  );

  static const Unit mari = Unit(
    id: '마리',
    name: '마리',
    symbol: '마리',
    type: UnitType.count,
    conversionFactor: 1.0,
    baseUnit: 'pcs',
  );

  static const Unit jang = Unit(
    id: '장',
    name: '장',
    symbol: '장',
    type: UnitType.count,
    conversionFactor: 1.0,
    baseUnit: 'pcs',
  );

  // 모든 단위 목록
  static final List<Unit> allUnits = [
    // 무게 단위
    gram,
    kilogram,
    pound,
    ounce,
    // 부피 단위
    milliliter,
    liter,
    cup,
    tablespoon,
    teaspoon,
    // 개수 단위
    piece,
    dozen,
    gae,
    inbun,
    jogak,
    mari,
    jang,
  ];

  // 타입별 단위 목록
  static List<Unit> getUnitsByType(UnitType type) {
    return allUnits.where((unit) => unit.type == type).toList();
  }

  /// 단위 변환
  static double convert(double value, Unit fromUnit, Unit toUnit) {
    if (fromUnit.type != toUnit.type) {
      throw ArgumentError('서로 다른 타입의 단위는 변환할 수 없습니다.');
    }

    // 기본 단위로 변환
    final baseValue = value * fromUnit.conversionFactor;

    // 목표 단위로 변환
    return baseValue / toUnit.conversionFactor;
  }

  /// 무게 변환
  static double convertWeight(double value, String fromUnit, String toUnit) {
    final from = _findUnit(fromUnit);
    final to = _findUnit(toUnit);

    if (from == null || to == null) {
      throw ArgumentError('유효하지 않은 단위입니다.');
    }

    return convert(value, from, to);
  }

  /// 부피 변환
  static double convertVolume(double value, String fromUnit, String toUnit) {
    final from = _findUnit(fromUnit);
    final to = _findUnit(toUnit);

    if (from == null || to == null) {
      throw ArgumentError('유효하지 않은 단위입니다.');
    }

    return convert(value, from, to);
  }

  /// 개수 변환
  static double convertCount(double value, String fromUnit, String toUnit) {
    final from = _findUnit(fromUnit);
    final to = _findUnit(toUnit);

    if (from == null || to == null) {
      throw ArgumentError('유효하지 않은 단위입니다.');
    }

    return convert(value, from, to);
  }

  /// 단위 찾기
  static Unit? _findUnit(String unitId) {
    try {
      return allUnits.firstWhere((unit) => unit.id == unitId);
    } catch (e) {
      return null;
    }
  }

  /// 단위 정보 가져오기
  static Unit? getUnit(String unitId) {
    return _findUnit(unitId);
  }

  /// 기본 단위 가져오기
  static String getBaseUnit(UnitType type) {
    switch (type) {
      case UnitType.weight:
        return 'g';
      case UnitType.volume:
        return 'ml';
      case UnitType.count:
        return 'pcs';
    }
  }

  /// 단위 타입 확인
  static UnitType? getUnitType(String unitId) {
    final unit = _findUnit(unitId);
    return unit?.type;
  }

  /// 호환 가능한 단위인지 확인
  static bool areCompatible(String unit1, String unit2) {
    final type1 = getUnitType(unit1);
    final type2 = getUnitType(unit2);
    return type1 != null && type2 != null && type1 == type2;
  }

  /// 기본 단위로 변환
  static double toBaseUnit(double value, String unitId) {
    final unit = _findUnit(unitId);
    if (unit == null) {
      throw ArgumentError('유효하지 않은 단위입니다.');
    }
    return value * unit.conversionFactor;
  }

  /// 기본 단위에서 변환
  static double fromBaseUnit(double value, String unitId) {
    final unit = _findUnit(unitId);
    if (unit == null) {
      throw ArgumentError('유효하지 않은 단위입니다.');
    }
    return value / unit.conversionFactor;
  }

  /// 단위별 가격 계산 (기본 단위당 가격)
  static double calculateUnitPrice(
    double totalPrice,
    double amount,
    String unitId,
  ) {
    final baseAmount = toBaseUnit(amount, unitId);
    return totalPrice / baseAmount;
  }

  /// 단위별 가격으로 총 가격 계산
  static double calculateTotalPrice(
    double unitPrice,
    double amount,
    String unitId,
  ) {
    final baseAmount = toBaseUnit(amount, unitId);
    return unitPrice * baseAmount;
  }

  /// 단위별 사용량으로 원가 계산
  static double calculateCost(
    double unitPrice,
    double usageAmount,
    String usageUnit,
  ) {
    final baseUsage = toBaseUnit(usageAmount, usageUnit);
    return unitPrice * baseUsage;
  }

  /// 단위 변환 문자열 생성
  static String formatConversion(double value, String fromUnit, String toUnit) {
    try {
      final convertedValue = convertWeight(value, fromUnit, toUnit);
      return '$value $fromUnit = ${convertedValue.toStringAsFixed(2)} $toUnit';
    } catch (e) {
      try {
        final convertedValue = convertVolume(value, fromUnit, toUnit);
        return '$value $fromUnit = ${convertedValue.toStringAsFixed(2)} $toUnit';
      } catch (e) {
        try {
          final convertedValue = convertCount(value, fromUnit, toUnit);
          return '$value $fromUnit = ${convertedValue.toStringAsFixed(2)} $toUnit';
        } catch (e) {
          return '변환할 수 없는 단위입니다.';
        }
      }
    }
  }
}
