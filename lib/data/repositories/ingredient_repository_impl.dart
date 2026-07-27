import '../../domain/entities/ingredient.dart';
import '../../domain/repositories/ingredient_repository.dart';
import '../database_helper.dart';
import '../models/ingredient_model.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  final DatabaseHelper databaseHelper;

  IngredientRepositoryImpl(this.databaseHelper);

  @override
  Future<List<Ingredient>> getIngredients() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('ingredients');

    return List.generate(maps.length, (i) {
      return IngredientModel.fromJson(maps[i]);
    });
  }

  @override
  Future<void> updateIngredient(Ingredient ingredient) async {
    final db = await databaseHelper.database;
    final model = IngredientModel.fromEntity(ingredient);
    await db.update(
      'ingredients',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [ingredient.id],
    );
  }

  @override
  Future<void> deleteIngredient(String id) async {
    final db = await databaseHelper.database;
    await db.transaction((txn) async {
      // 재고·이력 명시 정리 (PRAGMA foreign_keys 미사용 — FK CASCADE 대체)
      // 자식(inventory) 먼저 → 부모(ingredients) 나중
      await txn.delete(
        'inventory_transactions',
        where: 'ingredient_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'inventory_items',
        where: 'ingredient_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'ingredients',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  @override
  Future<void> updateIngredientsBatch(
      List<Ingredient> ingredients, List<String> idsToDelete) async {
    final db = await databaseHelper.database;

    await db.transaction((txn) async {
      // Delete marked items
      for (final id in idsToDelete) {
        // 재고·이력 명시 정리 (PRAGMA foreign_keys 미사용 — FK CASCADE 대체)
        // 자식(inventory) 먼저 → 부모(ingredients) 나중
        await txn.delete(
          'inventory_transactions',
          where: 'ingredient_id = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'inventory_items',
          where: 'ingredient_id = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'ingredients',
          where: 'id = ?',
          whereArgs: [id],
        );
      }

      // Update midifed items
      for (final ingredient in ingredients) {
        final model = IngredientModel.fromEntity(ingredient);
        await txn.update(
          'ingredients',
          model.toJson(),
          where: 'id = ?',
          whereArgs: [ingredient.id],
        );
      }
    });
  }
}
