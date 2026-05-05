import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/ingredient_repository.dart';
import '../data/recipe_repository.dart';
import '../data/unit_repository.dart';
import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../model/recipe_ingredient.dart';
import '../util/app_locale.dart';

class InitialDataService {
  final IngredientRepository _ingredientRepository;
  final RecipeRepository _recipeRepository;
  final UnitRepository _unitRepository;

  static const String _initialDataKey = 'initial_data_inserted';
  final Uuid _uuid = const Uuid();

  InitialDataService({
    required IngredientRepository ingredientRepository,
    required RecipeRepository recipeRepository,
    required UnitRepository unitRepository,
  })  : _ingredientRepository = ingredientRepository,
        _recipeRepository = recipeRepository,
        _unitRepository = unitRepository;

  /// 초기 데이터가 이미 삽입되었는지 확인
  Future<bool> isInitialDataInserted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_initialDataKey) ?? false;
  }

  /// 초기 데이터 삽입 완료 표시
  Future<void> markInitialDataInserted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_initialDataKey, true);
  }

  /// 초기 데이터 삽입 (재료 + 레시피)
  Future<void> insertInitialData() async {
    print('📦 초기 데이터 삽입 시작');

    try {
      // 1. 선택된 언어 확인
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString('app_locale_code') ?? 'ko_KR';
      final locale = AppLocale.fromLocaleCode(localeCode) ?? AppLocale.korea;
      print('📦 선택된 언어: ${locale.displayName}');

      // 2. 재료 삽입
      final ingredientIds = await _insertInitialIngredients(locale);
      print('✅ 재료 ${ingredientIds.length}개 삽입 완료');

      // 3. 레시피 삽입
      await _insertInitialRecipes(ingredientIds, locale);
      print('✅ 레시피 삽입 완료');

      // 4. 완료 표시
      await markInitialDataInserted();
      print('✅ 초기 데이터 삽입 완료');
    } catch (e) {
      print('❌ 초기 데이터 삽입 실패: $e');
      rethrow;
    }
  }

  /// 환율 적용 (원화 기준)
  double _getExchangeRate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 1.0; // 원화 1:1
      case AppLocale.usa:
        return 1.0 / 1300.0; // 1달러 = 1,300원
      case AppLocale.china:
        return 1.0 / 200.0; // 1위안 = 200원
      case AppLocale.japan:
        return 1.0 / 9.0; // 1엔 = 9원
      case AppLocale.chinaTraditional:
        return 1.0 / 45.0; // 대략 1 TWD ≈ 45원 (데모용)
      case AppLocale.vietnam:
        return 1.0 / 23000.0; // 1동 = 23,000원
    }
  }

  /// 초기 재료 15개 삽입
  Future<Map<String, String>> _insertInitialIngredients(
      AppLocale locale) async {
    final now = DateTime.now();
    final expiryDate = now.add(const Duration(days: 3)); // 3일 후

    // 환율 적용
    final exchangeRate = _getExchangeRate(locale);

    // 단위 ID 가져오기
    final units = await _unitRepository.getAllUnits();
    final gramUnit =
        units.firstWhere((u) => u.name == 'g', orElse: () => units.first);
    final mlUnit =
        units.firstWhere((u) => u.name == 'ml', orElse: () => units.first);
    final countUnit = locale == AppLocale.korea ||
            locale == AppLocale.japan ||
            locale == AppLocale.china ||
            locale == AppLocale.chinaTraditional
        ? units.firstWhere((u) => u.name == '개', orElse: () => units.first)
        : units.firstWhere((u) => u.name == 'count', orElse: () => units.first);

    final Map<String, String> ingredientIds = {};

    // === 유통기한 있는 재료 (5개) - 언어별 매핑 + 환율 적용 ===
    final ingredientsWithExpiryData = _getIngredientsWithExpiry(locale);
    final ingredientsWithExpiry = [
      {
        'name': ingredientsWithExpiryData[0],
        'price': (1500.0 * exchangeRate), // 환율 적용
        'amount': 500.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithExpiryData[1],
        'price': (1200.0 * exchangeRate), // 환율 적용
        'amount': 300.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithExpiryData[2],
        'price': (800.0 * exchangeRate), // 환율 적용
        'amount': 200.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithExpiryData[3],
        'price': (3500.0 * exchangeRate), // 환율 적용
        'amount': 10.0,
        'unitId': countUnit.id
      },
      {
        'name': ingredientsWithExpiryData[4],
        'price': (1800.0 * exchangeRate), // 환율 적용
        'amount': 300.0,
        'unitId': gramUnit.id
      },
    ];

    for (final data in ingredientsWithExpiry) {
      final id = _uuid.v4();
      final ingredient = Ingredient(
        id: id,
        name: data['name'] as String,
        purchasePrice: data['price'] as double,
        purchaseAmount: data['amount'] as double,
        purchaseUnitId: data['unitId'] as String,
        expiryDate: expiryDate,
        createdAt: now,
      );

      await _ingredientRepository.insertIngredient(ingredient);
      ingredientIds[data['name'] as String] = id;
      print(
          '✅ ${data['name']} 추가 (유통기한: ${expiryDate.toLocal().toString().split(' ')[0]})');
    }

    // === 유통기한 없는 재료 (10개) - 언어별 매핑 + 환율 적용 ===
    final ingredientsWithoutExpiryData = _getIngredientsWithoutExpiry(locale);
    final ingredientsWithoutExpiry = [
      {
        'name': ingredientsWithoutExpiryData[0],
        'price': (3000.0 * exchangeRate), // 환율 적용
        'amount': 1000.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithoutExpiryData[1],
        'price': (4500.0 * exchangeRate), // 환율 적용
        'amount': 500.0,
        'unitId': mlUnit.id
      },
      {
        'name': ingredientsWithoutExpiryData[2],
        'price': (5000.0 * exchangeRate), // 환율 적용
        'amount': 200.0,
        'unitId': mlUnit.id
      },
      {
        'name': ingredientsWithoutExpiryData[3],
        'price': (4000.0 * exchangeRate), // 환율 적용
        'amount': 500.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithoutExpiryData[4],
        'price': (3800.0 * exchangeRate), // 환율 적용
        'amount': 500.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithoutExpiryData[5],
        'price': (2500.0 * exchangeRate), // 환율 적용
        'amount': 1000.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithoutExpiryData[6],
        'price': (1000.0 * exchangeRate), // 환율 적용
        'amount': 1000.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithoutExpiryData[7],
        'price': (2800.0 * exchangeRate), // 환율 적용
        'amount': 200.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithoutExpiryData[8],
        'price': (3200.0 * exchangeRate), // 환율 적용
        'amount': 100.0,
        'unitId': gramUnit.id
      },
      {
        'name': ingredientsWithoutExpiryData[9],
        'price': (3500.0 * exchangeRate), // 환율 적용
        'amount': 500.0,
        'unitId': mlUnit.id
      },
    ];

    for (final data in ingredientsWithoutExpiry) {
      final id = _uuid.v4();
      final ingredient = Ingredient(
        id: id,
        name: data['name'] as String,
        purchasePrice: data['price'] as double,
        purchaseAmount: data['amount'] as double,
        purchaseUnitId: data['unitId'] as String,
        expiryDate: null, // 유통기한 없음
        createdAt: now,
      );

      await _ingredientRepository.insertIngredient(ingredient);
      ingredientIds[data['name'] as String] = id;
      print('✅ ${data['name']} 추가');
    }

    return ingredientIds;
  }

  /// 초기 레시피 3개 삽입
  Future<void> _insertInitialRecipes(
      Map<String, String> ingredientIds, AppLocale locale) async {
    final now = DateTime.now();

    // 환율 적용
    final exchangeRate = _getExchangeRate(locale);

    // 단위 ID 가져오기
    final units = await _unitRepository.getAllUnits();
    final gramUnit =
        units.firstWhere((u) => u.name == 'g', orElse: () => units.first);
    final mlUnit =
        units.firstWhere((u) => u.name == 'ml', orElse: () => units.first);
    final countUnit = locale == AppLocale.korea ||
            locale == AppLocale.japan ||
            locale == AppLocale.china ||
            locale == AppLocale.chinaTraditional
        ? units.firstWhere((u) => u.name == '개', orElse: () => units.first)
        : units.firstWhere((u) => u.name == 'count', orElse: () => units.first);
    final servingUnit = locale == AppLocale.korea ||
            locale == AppLocale.japan ||
            locale == AppLocale.china ||
            locale == AppLocale.chinaTraditional
        ? units.firstWhere((u) => u.name == '인분', orElse: () => units.first)
        : units.firstWhere((u) => u.name == 'serving',
            orElse: () => units.first);

    // 레시피 이름 가져오기
    final recipeNames = _getRecipeNames(locale);

    // 1. 첫 번째 레시피
    final recipe1Id = _uuid.v4();
    final recipe1 = Recipe(
      id: recipe1Id,
      name: recipeNames['recipe1']!,
      description: recipeNames['recipe1_desc']!,
      outputAmount: 1.0,
      outputUnit: servingUnit.id,
      totalCost: 0.0, // 나중에 계산됨
      createdAt: now,
      updatedAt: now,
    );

    // 재료 이름 (언어별 첫 번째 재료는 쌀, 두 번째는 간장 등)
    final ingredientsWithoutExpiryData = _getIngredientsWithoutExpiry(locale);
    final ingredientsWithExpiryData = _getIngredientsWithExpiry(locale);

    final recipe1Ingredients = [
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds[ingredientsWithoutExpiryData[0]]!, // 쌀
        amount: 200.0,
        unitId: gramUnit.id,
        calculatedCost: (600.0 * exchangeRate), // 200g * (3000/1000) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds[ingredientsWithoutExpiryData[1]]!, // 간장
        amount: 15.0,
        unitId: mlUnit.id,
        calculatedCost: (135.0 * exchangeRate), // 15ml * (4500/500) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds[ingredientsWithoutExpiryData[2]]!, // 참기름
        amount: 10.0,
        unitId: mlUnit.id,
        calculatedCost: (250.0 * exchangeRate), // 10ml * (5000/200) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds[ingredientsWithExpiryData[3]]!, // 계란
        amount: 1.0,
        unitId: countUnit.id,
        calculatedCost: (350.0 * exchangeRate), // 1개 * (3500/10) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds[ingredientsWithoutExpiryData[8]]!, // 참깨
        amount: 5.0,
        unitId: gramUnit.id,
        calculatedCost: (160.0 * exchangeRate), // 5g * (3200/100) * 환율
      ),
    ];

    final totalCost1 =
        recipe1Ingredients.fold(0.0, (sum, ing) => sum + ing.calculatedCost);
    await _recipeRepository
        .insertRecipe(recipe1.copyWith(totalCost: totalCost1));

    for (final ingredient in recipe1Ingredients) {
      await _recipeRepository.addIngredientToRecipe(recipe1Id, ingredient);
    }
    print('✅ 김치볶음밥 레시피 추가 (원가: ${totalCost1.toStringAsFixed(0)}원)');

    // 2. 두 번째 레시피 (된장찌개)
    final recipe2Id = _uuid.v4();
    final recipe2 = Recipe(
      id: recipe2Id,
      name: recipeNames['recipe2']!,
      description: recipeNames['recipe2_desc']!,
      outputAmount: 2.0,
      outputUnit: servingUnit.id,
      totalCost: 0.0,
      createdAt: now,
      updatedAt: now,
    );

    final recipe2Ingredients = [
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe2Id,
        ingredientId: ingredientIds[ingredientsWithoutExpiryData[4]]!, // 된장
        amount: 30.0,
        unitId: gramUnit.id,
        calculatedCost: (228.0 * exchangeRate), // 30g * (3800/500) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe2Id,
        ingredientId: ingredientIds[ingredientsWithExpiryData[4]]!, // 두부
        amount: 150.0,
        unitId: gramUnit.id,
        calculatedCost: (900.0 * exchangeRate), // 150g * (1800/300) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe2Id,
        ingredientId: ingredientIds[ingredientsWithExpiryData[0]]!, // 양파
        amount: 100.0,
        unitId: gramUnit.id,
        calculatedCost: (300.0 * exchangeRate), // 100g * (1500/500) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe2Id,
        ingredientId: ingredientIds[ingredientsWithExpiryData[2]]!, // 대파
        amount: 50.0,
        unitId: gramUnit.id,
        calculatedCost: (200.0 * exchangeRate), // 50g * (800/200) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe2Id,
        ingredientId: ingredientIds[ingredientsWithoutExpiryData[7]]!, // 다진마늘
        amount: 10.0,
        unitId: gramUnit.id,
        calculatedCost: (140.0 * exchangeRate), // 10g * (2800/200) * 환율
      ),
    ];

    final totalCost2 =
        recipe2Ingredients.fold(0.0, (sum, ing) => sum + ing.calculatedCost);
    await _recipeRepository
        .insertRecipe(recipe2.copyWith(totalCost: totalCost2));

    for (final ingredient in recipe2Ingredients) {
      await _recipeRepository.addIngredientToRecipe(recipe2Id, ingredient);
    }
    print('✅ 된장찌개 레시피 추가 (원가: ${totalCost2.toStringAsFixed(0)}원)');

    // 3. 세 번째 레시피 (계란말이)
    final recipe3Id = _uuid.v4();
    final recipe3 = Recipe(
      id: recipe3Id,
      name: recipeNames['recipe3']!,
      description: recipeNames['recipe3_desc']!,
      outputAmount: 1.0,
      outputUnit: servingUnit.id,
      totalCost: 0.0,
      createdAt: now,
      updatedAt: now,
    );

    final recipe3Ingredients = [
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe3Id,
        ingredientId: ingredientIds[ingredientsWithExpiryData[3]]!, // 계란
        amount: 3.0,
        unitId: countUnit.id,
        calculatedCost: (1050.0 * exchangeRate), // 3개 * (3500/10) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe3Id,
        ingredientId: ingredientIds[ingredientsWithExpiryData[1]]!, // 당근
        amount: 50.0,
        unitId: gramUnit.id,
        calculatedCost: (200.0 * exchangeRate), // 50g * (1200/300) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe3Id,
        ingredientId: ingredientIds[ingredientsWithoutExpiryData[6]]!, // 소금
        amount: 2.0,
        unitId: gramUnit.id,
        calculatedCost: (2.0 * exchangeRate), // 2g * (1000/1000) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe3Id,
        ingredientId: ingredientIds[ingredientsWithoutExpiryData[9]]!, // 식용유
        amount: 10.0,
        unitId: mlUnit.id,
        calculatedCost: (70.0 * exchangeRate), // 10ml * (3500/500) * 환율
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe3Id,
        ingredientId: ingredientIds[ingredientsWithExpiryData[2]]!, // 대파
        amount: 30.0,
        unitId: gramUnit.id,
        calculatedCost: (120.0 * exchangeRate), // 30g * (800/200) * 환율
      ),
    ];

    final totalCost3 =
        recipe3Ingredients.fold(0.0, (sum, ing) => sum + ing.calculatedCost);
    await _recipeRepository
        .insertRecipe(recipe3.copyWith(totalCost: totalCost3));

    for (final ingredient in recipe3Ingredients) {
      await _recipeRepository.addIngredientToRecipe(recipe3Id, ingredient);
    }
    print('✅ 계란말이 레시피 추가 (원가: ${totalCost3.toStringAsFixed(0)}원)');
  }

  /// 초기 데이터 삭제 (테스트용)
  Future<void> clearInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_initialDataKey);
    print('🗑️ 초기 데이터 플래그 삭제 완료');
  }

  /// 유통기한 있는 재료 이름 (언어별)
  List<String> _getIngredientsWithExpiry(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return ['양파', '당근', '대파', '계란', '두부'];
      case AppLocale.japan:
        return ['玉ねぎ', 'ニンジン', 'ねぎ', '卵', '豆腐'];
      case AppLocale.china:
        return ['洋葱', '胡萝卜', '大葱', '鸡蛋', '豆腐'];
      case AppLocale.chinaTraditional:
        return ['洋蔥', '胡蘿蔔', '大蔥', '雞蛋', '豆腐'];
      case AppLocale.usa:
        return ['Onion', 'Carrot', 'Green onion', 'Egg', 'Tofu'];
      default:
        return ['양파', '당근', '대파', '계란', '두부'];
    }
  }

  /// 유통기한 없는 재료 이름 (언어별)
  List<String> _getIngredientsWithoutExpiry(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return ['쌀', '간장', '참기름', '고추장', '된장', '설탕', '소금', '다진마늘', '참깨', '식용유'];
      case AppLocale.japan:
        return [
          '米',
          '醤油',
          'ごま油',
          'コチュジャン',
          '味噌',
          '砂糖',
          '塩',
          'ニンニクみじん切り',
          'ごま',
          '食用油'
        ];
      case AppLocale.china:
        return ['大米', '酱油', '香油', '辣椒酱', '大酱', '糖', '盐', '蒜蓉', '芝麻', '食用油'];
      case AppLocale.chinaTraditional:
        return [
          '大米',
          '醬油',
          '香油',
          '辣椒醬',
          '大醬',
          '糖',
          '鹽',
          '蒜蓉',
          '芝麻',
          '食用油'
        ];
      case AppLocale.usa:
        return [
          'Rice',
          'Soy sauce',
          'Sesame oil',
          'Gochujang',
          'Miso',
          'Sugar',
          'Salt',
          'Minced garlic',
          'Sesame',
          'Cooking oil'
        ];
      default:
        return ['쌀', '간장', '참기름', '고추장', '된장', '설탕', '소금', '다진마늘', '참깨', '식용유'];
    }
  }

  /// 레시피 이름 (언어별)
  Map<String, String> _getRecipeNames(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return {
          'recipe1': '김치볶음밥',
          'recipe1_desc': '간단하고 맛있는 한식 요리',
          'recipe2': '된장찌개',
          'recipe2_desc': '구수한 한국의 대표 국물 요리',
          'recipe3': '계란말이',
          'recipe3_desc': '부드럽고 영양 만점 반찬',
        };
      case AppLocale.japan:
        return {
          'recipe1': 'キムチチャーハン',
          'recipe1_desc': 'シンプルで美味しい韓国料理',
          'recipe2': '味噌汁',
          'recipe2_desc': 'コクのある日本の代表的な汁物',
          'recipe3': '卵焼き',
          'recipe3_desc': 'ふわふわで栄養満点のおかず',
        };
      case AppLocale.china:
        return {
          'recipe1': '泡菜炒饭',
          'recipe1_desc': '简单美味的韩式料理',
          'recipe2': '大酱汤',
          'recipe2_desc': '浓郁的韩国代表性汤料理',
          'recipe3': '鸡蛋卷',
          'recipe3_desc': '柔软营养丰富的配菜',
        };
      case AppLocale.chinaTraditional:
        return {
          'recipe1': '泡菜炒飯',
          'recipe1_desc': '簡單美味的韓式料理',
          'recipe2': '大醬湯',
          'recipe2_desc': '濃郁的韓國代表性湯料理',
          'recipe3': '雞蛋卷',
          'recipe3_desc': '柔軟營養豐富的配菜',
        };
      case AppLocale.usa:
        return {
          'recipe1': 'Kimchi fried rice',
          'recipe1_desc': 'Simple and delicious Korean dish',
          'recipe2': 'Miso soup',
          'recipe2_desc': 'Rich Korean representative soup',
          'recipe3': 'Rolled egg',
          'recipe3_desc': 'Soft and nutritious side dish',
        };
      default:
        return {
          'recipe1': '김치볶음밥',
          'recipe1_desc': '간단하고 맛있는 한식 요리',
          'recipe2': '된장찌개',
          'recipe2_desc': '구수한 한국의 대표 국물 요리',
          'recipe3': '계란말이',
          'recipe3_desc': '부드럽고 영양 만점 반찬',
        };
    }
  }
}
