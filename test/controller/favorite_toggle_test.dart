import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/controller/sauce/sauce_cubit.dart';
import 'package:recipe_app/controller/sauce/sauce_state.dart';
import 'package:recipe_app/data/ingredient_repository.dart';
import 'package:recipe_app/data/sauce_repository.dart';
import 'package:recipe_app/model/sauce.dart';
import 'package:recipe_app/service/sauce_cost_service.dart';

class _FakeSauceRepo extends SauceRepository {
  final Map<String, bool> favs = {};
  List<Sauce> items;
  _FakeSauceRepo(this.items);

  @override
  Future<void> setFavorite(String id, bool value) async => favs[id] = value;

  @override
  Future<List<Sauce>> getAllSauces() async => [
        for (final s in items)
          s.copyWith(isFavorite: favs[s.id] ?? s.isFavorite),
      ];
}

Sauce _sauce(String id) => Sauce(
      id: id, name: id, totalWeight: 10, totalCost: 5,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  test('SauceCubit.toggleFavorite 가 저장하고 Loaded 로 반영한다', () async {
    final repo = _FakeSauceRepo([_sauce('a')]);
    final ingredientRepo = IngredientRepository();
    final cubit = SauceCubit(
      sauceRepository: repo,
      ingredientRepository: ingredientRepo,
      sauceCostService: SauceCostService(
        sauceRepository: repo,
        ingredientRepository: ingredientRepo,
      ),
    );

    await cubit.toggleFavorite(_sauce('a'));

    expect(repo.favs['a'], isTrue);
    final state = cubit.state as SauceLoaded;
    expect(state.sauces.firstWhere((e) => e.id == 'a').isFavorite, isTrue);
    await cubit.close();
  });
}
