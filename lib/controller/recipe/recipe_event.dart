import 'package:equatable/equatable.dart';
import '../../model/index.dart';

// 레시피 이벤트 기본 클래스
abstract class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object?> get props => [];
}

// 레시피 목록 로드
class LoadRecipes extends RecipeEvent {
  const LoadRecipes();
}

// 레시피 추가
class AddRecipe extends RecipeEvent {
  final Recipe recipe;

  const AddRecipe(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

// 레시피 업데이트
class UpdateRecipe extends RecipeEvent {
  final Recipe recipe;

  const UpdateRecipe(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

// 레시피 삭제
class DeleteRecipe extends RecipeEvent {
  final String id;

  const DeleteRecipe(this.id);

  @override
  List<Object?> get props => [id];
}

// 레시피 검색
class SearchRecipes extends RecipeEvent {
  final String query;

  const SearchRecipes(this.query);

  @override
  List<Object?> get props => [query];
}

// 태그별 필터링
class FilterRecipesByTag extends RecipeEvent {
  final String tagId;

  const FilterRecipesByTag(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

// 여러 태그로 필터링
class FilterRecipesByTags extends RecipeEvent {
  final List<String> tagIds;

  const FilterRecipesByTags(this.tagIds);

  @override
  List<Object?> get props => [tagIds];
}

// 레시피에 태그 추가
class AddTagToRecipe extends RecipeEvent {
  final String recipeId;
  final String tagId;

  const AddTagToRecipe({required this.recipeId, required this.tagId});

  @override
  List<Object?> get props => [recipeId, tagId];
}

// 레시피에서 태그 제거
class RemoveTagFromRecipe extends RecipeEvent {
  final String recipeId;
  final String tagId;

  const RemoveTagFromRecipe({required this.recipeId, required this.tagId});

  @override
  List<Object?> get props => [recipeId, tagId];
}

// 레시피 태그 업데이트
class UpdateRecipeTags extends RecipeEvent {
  final String recipeId;
  final List<String> tagIds;

  const UpdateRecipeTags({required this.recipeId, required this.tagIds});

  @override
  List<Object?> get props => [recipeId, tagIds];
}

// 레시피에 재료 추가
class AddIngredientToRecipe extends RecipeEvent {
  final String recipeId;
  final RecipeIngredient ingredient;

  const AddIngredientToRecipe({
    required this.recipeId,
    required this.ingredient,
  });

  @override
  List<Object?> get props => [recipeId, ingredient];
}

// 레시피에서 재료 제거
class RemoveIngredientFromRecipe extends RecipeEvent {
  final String recipeId;
  final String ingredientId;

  const RemoveIngredientFromRecipe({
    required this.recipeId,
    required this.ingredientId,
  });

  @override
  List<Object?> get props => [recipeId, ingredientId];
}

// 레시피 재료 수량 업데이트
class UpdateRecipeIngredientAmount extends RecipeEvent {
  final String recipeId;
  final String ingredientId;
  final double newAmount;
  final double newCalculatedCost;

  const UpdateRecipeIngredientAmount({
    required this.recipeId,
    required this.ingredientId,
    required this.newAmount,
    required this.newCalculatedCost,
  });

  @override
  List<Object?> get props => [
    recipeId,
    ingredientId,
    newAmount,
    newCalculatedCost,
  ];
}

// 원가별 레시피 정렬
class SortRecipesByCost extends RecipeEvent {
  final bool ascending;

  const SortRecipesByCost({this.ascending = true});

  @override
  List<Object?> get props => [ascending];
}

// 최근 레시피 조회
class LoadRecentRecipes extends RecipeEvent {
  final int limit;

  const LoadRecentRecipes({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

// 특정 재료를 사용하는 레시피 조회
class LoadRecipesByIngredient extends RecipeEvent {
  final String ingredientId;

  const LoadRecipesByIngredient(this.ingredientId);

  @override
  List<Object?> get props => [ingredientId];
}

// 레시피 통계 로드
class LoadRecipeStats extends RecipeEvent {
  const LoadRecipeStats();
}

// 레시피 새로고침
class RefreshRecipes extends RecipeEvent {
  const RefreshRecipes();
}

// 레시피 원가 재계산
class RecalculateRecipeCost extends RecipeEvent {
  final String recipeId;

  const RecalculateRecipeCost(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}
