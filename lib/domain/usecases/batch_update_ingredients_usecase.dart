import '../entities/ingredient.dart';
import '../repositories/ingredient_repository.dart';

class BatchUpdateIngredientsUseCase {
  final IngredientRepository repository;

  BatchUpdateIngredientsUseCase(this.repository);

  Future<void> call({
    required List<Ingredient> ingredientsToUpdate,
    required List<String> idsToDelete,
  }) async {
    return await repository.updateIngredientsBatch(
        ingredientsToUpdate, idsToDelete);
  }
}
