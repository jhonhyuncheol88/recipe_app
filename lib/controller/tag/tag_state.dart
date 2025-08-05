import 'package:equatable/equatable.dart';
import '../../model/tag.dart';
import '../../model/ingredient.dart';
import '../../model/recipe.dart';

abstract class TagState extends Equatable {
  const TagState();

  @override
  List<Object?> get props => [];
}

// 초기 상태
class TagInitial extends TagState {
  const TagInitial();
}

// 로딩 상태
class TagLoading extends TagState {
  const TagLoading();
}

// 태그 목록 로드 성공
class TagsLoaded extends TagState {
  final List<Tag> tags;
  final TagType? filterType;

  const TagsLoaded(this.tags, {this.filterType});

  @override
  List<Object?> get props => [tags, filterType];
}

// 태그 검색 결과
class TagsSearched extends TagState {
  final List<Tag> searchResults;
  final String query;

  const TagsSearched(this.searchResults, this.query);

  @override
  List<Object?> get props => [searchResults, query];
}

// 태그 추가 성공
class TagAdded extends TagState {
  final Tag tag;

  const TagAdded(this.tag);

  @override
  List<Object?> get props => [tag];
}

// 태그 업데이트 성공
class TagUpdated extends TagState {
  final Tag tag;

  const TagUpdated(this.tag);

  @override
  List<Object?> get props => [tag];
}

// 태그 삭제 성공
class TagDeleted extends TagState {
  final String tagId;

  const TagDeleted(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

// 재료에 태그 추가 성공
class TagAddedToIngredientState extends TagState {
  final String ingredientId;
  final String tagId;

  const TagAddedToIngredientState(this.ingredientId, this.tagId);

  @override
  List<Object?> get props => [ingredientId, tagId];
}

// 재료에서 태그 제거 성공
class TagRemovedFromIngredientState extends TagState {
  final String ingredientId;
  final String tagId;

  const TagRemovedFromIngredientState(this.ingredientId, this.tagId);

  @override
  List<Object?> get props => [ingredientId, tagId];
}

// 레시피에 태그 추가 성공
class TagAddedToRecipeState extends TagState {
  final String recipeId;
  final String tagId;

  const TagAddedToRecipeState(this.recipeId, this.tagId);

  @override
  List<Object?> get props => [recipeId, tagId];
}

// 레시피에서 태그 제거 성공
class TagRemovedFromRecipeState extends TagState {
  final String recipeId;
  final String tagId;

  const TagRemovedFromRecipeState(this.recipeId, this.tagId);

  @override
  List<Object?> get props => [recipeId, tagId];
}

// 태그로 재료 검색 결과
class IngredientsFoundByTag extends TagState {
  final List<Ingredient> ingredients;
  final Tag tag;

  const IngredientsFoundByTag(this.ingredients, this.tag);

  @override
  List<Object?> get props => [ingredients, tag];
}

// 태그로 레시피 검색 결과
class RecipesFoundByTag extends TagState {
  final List<Recipe> recipes;
  final Tag tag;

  const RecipesFoundByTag(this.recipes, this.tag);

  @override
  List<Object?> get props => [recipes, tag];
}

// 인기 태그 로드 성공
class PopularTagsLoaded extends TagState {
  final List<Tag> popularTags;

  const PopularTagsLoaded(this.popularTags);

  @override
  List<Object?> get props => [popularTags];
}

// 태그 통계 로드 성공
class TagStatsLoaded extends TagState {
  final Map<String, dynamic> stats;

  const TagStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

// 기본 태그 초기화 성공
class DefaultTagsInitialized extends TagState {
  final List<Tag> defaultTags;

  const DefaultTagsInitialized(this.defaultTags);

  @override
  List<Object?> get props => [defaultTags];
}

// 에러 상태
class TagError extends TagState {
  final String message;

  const TagError(this.message);

  @override
  List<Object?> get props => [message];
}
