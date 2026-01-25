import '../entities/ingredient.dart';

abstract class IngredientRepository {
  Future<List<Ingredient>> getIngredients();
  Future<void> updateIngredient(Ingredient ingredient);
  Future<void> deleteIngredient(String id);
  Future<void> updateIngredientsBatch(
      List<Ingredient> ingredients, List<String> idsToDelete);
}
