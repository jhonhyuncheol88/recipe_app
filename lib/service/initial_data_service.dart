import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/ingredient_repository.dart';
import '../data/recipe_repository.dart';
import '../data/unit_repository.dart';
import '../model/ingredient.dart';
import '../model/recipe.dart';
import '../model/recipe_ingredient.dart';

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
      // 1. 재료 삽입
      final ingredientIds = await _insertInitialIngredients();
      print('✅ 재료 ${ingredientIds.length}개 삽입 완료');

      // 2. 레시피 삽입
      await _insertInitialRecipes(ingredientIds);
      print('✅ 레시피 삽입 완료');

      // 3. 완료 표시
      await markInitialDataInserted();
      print('✅ 초기 데이터 삽입 완료');
    } catch (e) {
      print('❌ 초기 데이터 삽입 실패: $e');
      rethrow;
    }
  }

  /// 초기 재료 15개 삽입
  Future<Map<String, String>> _insertInitialIngredients() async {
    final now = DateTime.now();
    final expiryDate = now.add(const Duration(days: 3)); // 3일 후

    // 단위 ID 가져오기
    final units = await _unitRepository.getAllUnits();
    final gramUnit =
        units.firstWhere((u) => u.name == 'g', orElse: () => units.first);
    final mlUnit =
        units.firstWhere((u) => u.name == 'ml', orElse: () => units.first);
    final countUnit =
        units.firstWhere((u) => u.name == '개', orElse: () => units.first);

    final Map<String, String> ingredientIds = {};

    // === 유통기한 있는 재료 (5개) ===
    final ingredientsWithExpiry = [
      {'name': '양파', 'price': 1500.0, 'amount': 500.0, 'unitId': gramUnit.id},
      {'name': '당근', 'price': 1200.0, 'amount': 300.0, 'unitId': gramUnit.id},
      {'name': '대파', 'price': 800.0, 'amount': 200.0, 'unitId': gramUnit.id},
      {'name': '계란', 'price': 3500.0, 'amount': 10.0, 'unitId': countUnit.id},
      {'name': '두부', 'price': 1800.0, 'amount': 300.0, 'unitId': gramUnit.id},
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

    // === 유통기한 없는 재료 (10개) ===
    final ingredientsWithoutExpiry = [
      {'name': '쌀', 'price': 3000.0, 'amount': 1000.0, 'unitId': gramUnit.id},
      {'name': '간장', 'price': 4500.0, 'amount': 500.0, 'unitId': mlUnit.id},
      {'name': '참기름', 'price': 5000.0, 'amount': 200.0, 'unitId': mlUnit.id},
      {'name': '고추장', 'price': 4000.0, 'amount': 500.0, 'unitId': gramUnit.id},
      {'name': '된장', 'price': 3800.0, 'amount': 500.0, 'unitId': gramUnit.id},
      {'name': '설탕', 'price': 2500.0, 'amount': 1000.0, 'unitId': gramUnit.id},
      {'name': '소금', 'price': 1000.0, 'amount': 1000.0, 'unitId': gramUnit.id},
      {'name': '다진마늘', 'price': 2800.0, 'amount': 200.0, 'unitId': gramUnit.id},
      {'name': '참깨', 'price': 3200.0, 'amount': 100.0, 'unitId': gramUnit.id},
      {'name': '식용유', 'price': 3500.0, 'amount': 500.0, 'unitId': mlUnit.id},
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
  Future<void> _insertInitialRecipes(Map<String, String> ingredientIds) async {
    final now = DateTime.now();

    // 단위 ID 가져오기
    final units = await _unitRepository.getAllUnits();
    final gramUnit =
        units.firstWhere((u) => u.name == 'g', orElse: () => units.first);
    final mlUnit =
        units.firstWhere((u) => u.name == 'ml', orElse: () => units.first);
    final countUnit =
        units.firstWhere((u) => u.name == '개', orElse: () => units.first);
    final servingUnit =
        units.firstWhere((u) => u.name == '인분', orElse: () => units.first);

    // 1. 김치볶음밥
    final recipe1Id = _uuid.v4();
    final recipe1 = Recipe(
      id: recipe1Id,
      name: '김치볶음밥',
      description: '간단하고 맛있는 한식 요리',
      outputAmount: 1.0,
      outputUnit: servingUnit.id,
      totalCost: 0.0, // 나중에 계산됨
      createdAt: now,
      updatedAt: now,
    );

    final recipe1Ingredients = [
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds['쌀']!,
        amount: 200.0,
        unitId: gramUnit.id,
        calculatedCost: 600.0, // 200g * (3000/1000)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds['간장']!,
        amount: 15.0,
        unitId: mlUnit.id,
        calculatedCost: 135.0, // 15ml * (4500/500)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds['참기름']!,
        amount: 10.0,
        unitId: mlUnit.id,
        calculatedCost: 250.0, // 10ml * (5000/200)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds['계란']!,
        amount: 1.0,
        unitId: countUnit.id,
        calculatedCost: 350.0, // 1개 * (3500/10)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe1Id,
        ingredientId: ingredientIds['참깨']!,
        amount: 5.0,
        unitId: gramUnit.id,
        calculatedCost: 160.0, // 5g * (3200/100)
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

    // 2. 된장찌개
    final recipe2Id = _uuid.v4();
    final recipe2 = Recipe(
      id: recipe2Id,
      name: '된장찌개',
      description: '구수한 한국의 대표 국물 요리',
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
        ingredientId: ingredientIds['된장']!,
        amount: 30.0,
        unitId: gramUnit.id,
        calculatedCost: 228.0, // 30g * (3800/500)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe2Id,
        ingredientId: ingredientIds['두부']!,
        amount: 150.0,
        unitId: gramUnit.id,
        calculatedCost: 900.0, // 150g * (1800/300)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe2Id,
        ingredientId: ingredientIds['양파']!,
        amount: 100.0,
        unitId: gramUnit.id,
        calculatedCost: 300.0, // 100g * (1500/500)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe2Id,
        ingredientId: ingredientIds['대파']!,
        amount: 50.0,
        unitId: gramUnit.id,
        calculatedCost: 200.0, // 50g * (800/200)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe2Id,
        ingredientId: ingredientIds['다진마늘']!,
        amount: 10.0,
        unitId: gramUnit.id,
        calculatedCost: 140.0, // 10g * (2800/200)
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

    // 3. 계란말이
    final recipe3Id = _uuid.v4();
    final recipe3 = Recipe(
      id: recipe3Id,
      name: '계란말이',
      description: '부드럽고 영양 만점 반찬',
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
        ingredientId: ingredientIds['계란']!,
        amount: 3.0,
        unitId: countUnit.id,
        calculatedCost: 1050.0, // 3개 * (3500/10)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe3Id,
        ingredientId: ingredientIds['당근']!,
        amount: 50.0,
        unitId: gramUnit.id,
        calculatedCost: 200.0, // 50g * (1200/300)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe3Id,
        ingredientId: ingredientIds['소금']!,
        amount: 2.0,
        unitId: gramUnit.id,
        calculatedCost: 2.0, // 2g * (1000/1000)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe3Id,
        ingredientId: ingredientIds['식용유']!,
        amount: 10.0,
        unitId: mlUnit.id,
        calculatedCost: 70.0, // 10ml * (3500/500)
      ),
      RecipeIngredient(
        id: _uuid.v4(),
        recipeId: recipe3Id,
        ingredientId: ingredientIds['대파']!,
        amount: 30.0,
        unitId: gramUnit.id,
        calculatedCost: 120.0, // 30g * (800/200)
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
}
