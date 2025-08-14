import '../data/recipe_repository.dart';
import '../data/sauce_repository.dart';
import '../model/index.dart';
import '../util/unit_converter.dart' as uc;
import 'sauce_cost_service.dart';

class RecipeCostService {
  final RecipeRepository recipeRepository;
  final SauceRepository sauceRepository;
  final SauceCostService sauceCostService;

  RecipeCostService({
    required this.recipeRepository,
    required this.sauceRepository,
    required this.sauceCostService,
  });

  /// 레시피 총원가 = 재료 원가 합 + 소스 원가 합
  Future<double> computeRecipeTotalCost(Recipe recipe) async {
    double total = 0.0;

    // 재료 원가 합산 (이미 calculated_cost가 반영되어 있다고 가정)
    for (final item in recipe.ingredients) {
      total += item.calculatedCost;
    }

    // 소스 원가 합산
    final recipeSauces = await recipeRepository.getRecipeSauces(recipe.id);
    for (final rs in recipeSauces) {
      final unitCost = await sauceCostService.getSauceUnitCost(rs.sauceId);
      final baseUsage = uc.UnitConverter.toBaseUnit(rs.amount, rs.unitId);
      total += unitCost * baseUsage;
    }

    return total;
  }
}
