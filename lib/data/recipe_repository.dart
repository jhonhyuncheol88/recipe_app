import 'package:sqflite/sqflite.dart';
import '../model/index.dart';
import 'database_helper.dart';

class RecipeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 레시피 추가
  Future<void> insertRecipe(Recipe recipe) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // 레시피 추가
      await txn.insert(
        'recipes',
        recipe.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 레시피 재료들 추가
      for (final ingredient in recipe.ingredients) {
        await txn.insert(
          'recipe_ingredients',
          ingredient.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // 모든 레시피 조회 (재료 정보 포함)
  Future<List<Recipe>> getAllRecipes() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> recipeMaps = await db.query('recipes');

    final recipes = <Recipe>[];
    for (final recipeMap in recipeMaps) {
      final recipe = Recipe.fromJson(recipeMap);
      final ingredients = await _getRecipeIngredients(recipe.id);
      recipes.add(recipe.copyWith(ingredients: ingredients));
    }

    return recipes;
  }

  // 레시피 ID로 조회
  Future<Recipe?> getRecipeById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final recipe = Recipe.fromJson(maps.first);
      final ingredients = await _getRecipeIngredients(id);
      return recipe.copyWith(ingredients: ingredients);
    }
    return null;
  }

  // 레시피 이름으로 검색
  Future<List<Recipe>> searchRecipesByName(String name) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );

    final recipes = <Recipe>[];
    for (final recipeMap in maps) {
      final recipe = Recipe.fromJson(recipeMap);
      final ingredients = await _getRecipeIngredients(recipe.id);
      recipes.add(recipe.copyWith(ingredients: ingredients));
    }

    return recipes;
  }

  // 레시피 업데이트
  Future<void> updateRecipe(Recipe recipe) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // 레시피 업데이트
      await txn.update(
        'recipes',
        recipe.toJson(),
        where: 'id = ?',
        whereArgs: [recipe.id],
      );

      // 기존 재료들 삭제
      await txn.delete(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [recipe.id],
      );

      // 새로운 재료들 추가
      for (final ingredient in recipe.ingredients) {
        await txn.insert(
          'recipe_ingredients',
          ingredient.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // 레시피 삭제
  Future<void> deleteRecipe(String id) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // 레시피 재료들 먼저 삭제
      await txn.delete(
        'recipe_ingredients',
        where: 'recipe_id = ?',
        whereArgs: [id],
      );

      // 레시피 삭제
      await txn.delete('recipes', where: 'id = ?', whereArgs: [id]);
    });
  }

  // 레시피에 재료 추가
  Future<void> addIngredientToRecipe(
    String recipeId,
    RecipeIngredient ingredient,
  ) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'recipe_ingredients',
      ingredient.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 레시피에서 재료 제거
  Future<void> removeIngredientFromRecipe(
    String recipeId,
    String ingredientId,
  ) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'recipe_ingredients',
      where: 'recipe_id = ? AND ingredient_id = ?',
      whereArgs: [recipeId, ingredientId],
    );
  }

  // 레시피 재료 수량 업데이트
  Future<void> updateRecipeIngredientAmount(
    String recipeId,
    String ingredientId,
    double newAmount,
    double newCalculatedCost,
  ) async {
    final db = await _databaseHelper.database;
    await db.update(
      'recipe_ingredients',
      {'amount': newAmount, 'calculated_cost': newCalculatedCost},
      where: 'recipe_id = ? AND ingredient_id = ?',
      whereArgs: [recipeId, ingredientId],
    );
  }

  // ===== 소스 연동: 레시피-소스 CRUD =====
  Future<void> addSauceToRecipe(
    String recipeId,
    RecipeSauce recipeSauce,
  ) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'recipe_sauces',
      recipeSauce.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeSauceFromRecipe(String recipeId, String sauceId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'recipe_sauces',
      where: 'recipe_id = ? AND sauce_id = ?',
      whereArgs: [recipeId, sauceId],
    );
  }

  Future<void> updateRecipeSauceAmount(
    String recipeId,
    String sauceId,
    double newAmount,
  ) async {
    final db = await _databaseHelper.database;
    await db.update(
      'recipe_sauces',
      {'amount': newAmount},
      where: 'recipe_id = ? AND sauce_id = ?',
      whereArgs: [recipeId, sauceId],
    );
  }

  Future<void> updateRecipeSauceUnit(
    String recipeId,
    String sauceId,
    String newUnitId,
  ) async {
    final db = await _databaseHelper.database;
    await db.update(
      'recipe_sauces',
      {'unit_id': newUnitId},
      where: 'recipe_id = ? AND sauce_id = ?',
      whereArgs: [recipeId, sauceId],
    );
  }

  Future<void> updateRecipeIngredientUnit(
    String recipeId,
    String ingredientId,
    String newUnitId,
    double newCalculatedCost,
  ) async {
    final db = await _databaseHelper.database;
    await db.update(
      'recipe_ingredients',
      {'unit_id': newUnitId, 'calculated_cost': newCalculatedCost},
      where: 'recipe_id = ? AND ingredient_id = ?',
      whereArgs: [recipeId, ingredientId],
    );
  }

  Future<List<RecipeSauce>> getRecipeSauces(String recipeId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipe_sauces',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );
    return List.generate(maps.length, (i) => RecipeSauce.fromJson(maps[i]));
  }

  // 특정 소스를 사용하는 레시피 ID 목록 조회
  Future<List<String>> getRecipeIdsBySauce(String sauceId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT recipe_id FROM recipe_sauces WHERE sauce_id = ?',
      [sauceId],
    );
    return maps.map((m) => m['recipe_id'] as String).toList();
  }

  // 모든 레시피에서 특정 재료 항목 제거
  Future<void> removeRecipeIngredientsByIngredientId(
    String ingredientId,
  ) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'recipe_ingredients',
      where: 'ingredient_id = ?',
      whereArgs: [ingredientId],
    );
  }

  // 모든 레시피에서 특정 소스 항목 제거
  Future<void> removeRecipeSaucesBySauceId(String sauceId) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'recipe_sauces',
      where: 'sauce_id = ?',
      whereArgs: [sauceId],
    );
  }

  // 레시피 재료들 조회 (내부 메서드)
  Future<List<RecipeIngredient>> _getRecipeIngredients(String recipeId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipe_ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
    );

    return List.generate(maps.length, (i) {
      return RecipeIngredient.fromJson(maps[i]);
    });
  }

  // 원가별 레시피 정렬
  Future<List<Recipe>> getRecipesByCost({bool ascending = true}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      orderBy: ascending ? 'total_cost ASC' : 'total_cost DESC',
    );

    final recipes = <Recipe>[];
    for (final recipeMap in maps) {
      final recipe = Recipe.fromJson(recipeMap);
      final ingredients = await _getRecipeIngredients(recipe.id);
      recipes.add(recipe.copyWith(ingredients: ingredients));
    }

    return recipes;
  }

  // 최근 생성된 레시피 조회
  Future<List<Recipe>> getRecentRecipes({int limit = 10}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    final recipes = <Recipe>[];
    for (final recipeMap in maps) {
      final recipe = Recipe.fromJson(recipeMap);
      final ingredients = await _getRecipeIngredients(recipe.id);
      recipes.add(recipe.copyWith(ingredients: ingredients));
    }

    return recipes;
  }

  // 레시피 통계 정보
  Future<Map<String, dynamic>> getRecipeStats() async {
    final allRecipes = await getAllRecipes();

    if (allRecipes.isEmpty) {
      return {
        'total': 0,
        'average_cost': 0.0,
        'total_value': 0.0,
        'most_expensive': null,
        'least_expensive': null,
      };
    }

    final totalCost = allRecipes.fold(
      0.0,
      (sum, recipe) => sum + recipe.totalCost,
    );
    final averageCost = totalCost / allRecipes.length;

    // 가장 비싼 레시피
    final mostExpensive = allRecipes.reduce(
      (a, b) => a.totalCost > b.totalCost ? a : b,
    );

    // 가장 싼 레시피
    final leastExpensive = allRecipes.reduce(
      (a, b) => a.totalCost < b.totalCost ? a : b,
    );

    return {
      'total': allRecipes.length,
      'average_cost': averageCost,
      'total_value': totalCost,
      'most_expensive': mostExpensive,
      'least_expensive': leastExpensive,
    };
  }

  // 특정 재료를 사용하는 레시피 조회
  Future<List<Recipe>> getRecipesByIngredient(String ingredientId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT DISTINCT r.* FROM recipes r
      INNER JOIN recipe_ingredients ri ON r.id = ri.recipe_id
      WHERE ri.ingredient_id = ?
    ''',
      [ingredientId],
    );

    final recipes = <Recipe>[];
    for (final recipeMap in maps) {
      final recipe = Recipe.fromJson(recipeMap);
      final ingredients = await _getRecipeIngredients(recipe.id);
      recipes.add(recipe.copyWith(ingredients: ingredients));
    }

    return recipes;
  }
}
