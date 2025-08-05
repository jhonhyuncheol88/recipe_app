import 'package:equatable/equatable.dart';
import '../../model/index.dart';

// 레시피 상태 기본 클래스
abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

// 초기 상태
class RecipeInitial extends RecipeState {
  const RecipeInitial();
}

// 로딩 상태
class RecipeLoading extends RecipeState {
  const RecipeLoading();
}

// 레시피 목록 로드 성공
class RecipeLoaded extends RecipeState {
  final List<Recipe> recipes;
  final Map<String, dynamic>? stats;

  const RecipeLoaded({required this.recipes, this.stats});

  @override
  List<Object?> get props => [recipes, stats];
}

// 레시피 추가 성공
class RecipeAdded extends RecipeState {
  final Recipe recipe;
  final List<Recipe> recipes;

  const RecipeAdded({required this.recipe, required this.recipes});

  @override
  List<Object?> get props => [recipe, recipes];
}

// 레시피 업데이트 성공
class RecipeUpdated extends RecipeState {
  final Recipe recipe;
  final List<Recipe> recipes;

  const RecipeUpdated({required this.recipe, required this.recipes});

  @override
  List<Object?> get props => [recipe, recipes];
}

// 레시피 삭제 성공
class RecipeDeleted extends RecipeState {
  final String deletedId;
  final List<Recipe> recipes;

  const RecipeDeleted({required this.deletedId, required this.recipes});

  @override
  List<Object?> get props => [deletedId, recipes];
}

// 검색 결과
class RecipeSearchResult extends RecipeState {
  final List<Recipe> recipes;
  final String query;

  const RecipeSearchResult({required this.recipes, required this.query});

  @override
  List<Object?> get props => [recipes, query];
}

// 태그별 필터링 결과
class RecipeFilteredByTag extends RecipeState {
  final List<Recipe> recipes;
  final String tagId;

  const RecipeFilteredByTag({required this.recipes, required this.tagId});

  @override
  List<Object?> get props => [recipes, tagId];
}

// 여러 태그로 필터링 결과
class RecipeFilteredByTags extends RecipeState {
  final List<Recipe> recipes;
  final List<String> tagIds;

  const RecipeFilteredByTags({required this.recipes, required this.tagIds});

  @override
  List<Object?> get props => [recipes, tagIds];
}

// 태그 추가 성공
class TagAddedToRecipe extends RecipeState {
  final String recipeId;
  final String tagId;
  final List<Recipe> recipes;

  const TagAddedToRecipe({
    required this.recipeId,
    required this.tagId,
    required this.recipes,
  });

  @override
  List<Object?> get props => [recipeId, tagId, recipes];
}

// 태그 제거 성공
class TagRemovedFromRecipe extends RecipeState {
  final String recipeId;
  final String tagId;
  final List<Recipe> recipes;

  const TagRemovedFromRecipe({
    required this.recipeId,
    required this.tagId,
    required this.recipes,
  });

  @override
  List<Object?> get props => [recipeId, tagId, recipes];
}

// 태그 업데이트 성공
class RecipeTagsUpdated extends RecipeState {
  final String recipeId;
  final List<String> tagIds;
  final List<Recipe> recipes;

  const RecipeTagsUpdated({
    required this.recipeId,
    required this.tagIds,
    required this.recipes,
  });

  @override
  List<Object?> get props => [recipeId, tagIds, recipes];
}

// 레시피에 재료 추가 성공
class IngredientAddedToRecipe extends RecipeState {
  final Recipe recipe;
  final RecipeIngredient ingredient;
  final List<Recipe> recipes;

  const IngredientAddedToRecipe({
    required this.recipe,
    required this.ingredient,
    required this.recipes,
  });

  @override
  List<Object?> get props => [recipe, ingredient, recipes];
}

// 레시피에서 재료 제거 성공
class IngredientRemovedFromRecipe extends RecipeState {
  final Recipe recipe;
  final String removedIngredientId;
  final List<Recipe> recipes;

  const IngredientRemovedFromRecipe({
    required this.recipe,
    required this.removedIngredientId,
    required this.recipes,
  });

  @override
  List<Object?> get props => [recipe, removedIngredientId, recipes];
}

// 레시피 재료 수량 업데이트 성공
class RecipeIngredientAmountUpdated extends RecipeState {
  final Recipe recipe;
  final String ingredientId;
  final double newAmount;
  final double newCalculatedCost;
  final List<Recipe> recipes;

  const RecipeIngredientAmountUpdated({
    required this.recipe,
    required this.ingredientId,
    required this.newAmount,
    required this.newCalculatedCost,
    required this.recipes,
  });

  @override
  List<Object?> get props => [
    recipe,
    ingredientId,
    newAmount,
    newCalculatedCost,
    recipes,
  ];
}

// 원가별 정렬된 레시피
class RecipesSortedByCost extends RecipeState {
  final List<Recipe> recipes;
  final bool ascending;

  const RecipesSortedByCost({required this.recipes, required this.ascending});

  @override
  List<Object?> get props => [recipes, ascending];
}

// 최근 레시피
class RecentRecipesLoaded extends RecipeState {
  final List<Recipe> recipes;
  final int limit;

  const RecentRecipesLoaded({required this.recipes, required this.limit});

  @override
  List<Object?> get props => [recipes, limit];
}

// 특정 재료를 사용하는 레시피
class RecipesByIngredientLoaded extends RecipeState {
  final List<Recipe> recipes;
  final String ingredientId;

  const RecipesByIngredientLoaded({
    required this.recipes,
    required this.ingredientId,
  });

  @override
  List<Object?> get props => [recipes, ingredientId];
}

// 레시피 통계 로드 성공
class RecipeStatsLoaded extends RecipeState {
  final Map<String, dynamic> stats;

  const RecipeStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

// 레시피 원가 재계산 성공
class RecipeCostRecalculated extends RecipeState {
  final Recipe recipe;
  final double newTotalCost;
  final List<Recipe> recipes;

  const RecipeCostRecalculated({
    required this.recipe,
    required this.newTotalCost,
    required this.recipes,
  });

  @override
  List<Object?> get props => [recipe, newTotalCost, recipes];
}

// 에러 상태
class RecipeError extends RecipeState {
  final String message;

  const RecipeError(this.message);

  @override
  List<Object?> get props => [message];
}

// 빈 상태 (레시피가 없을 때)
class RecipeEmpty extends RecipeState {
  const RecipeEmpty();
}
