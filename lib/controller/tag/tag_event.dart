import 'package:equatable/equatable.dart';
import '../../model/tag.dart';

abstract class TagEvent extends Equatable {
  const TagEvent();

  @override
  List<Object?> get props => [];
}

// 모든 태그 로드
class LoadAllTags extends TagEvent {
  const LoadAllTags();
}

// 타입별 태그 로드
class LoadTagsByType extends TagEvent {
  final TagType type;

  const LoadTagsByType(this.type);

  @override
  List<Object?> get props => [type];
}

// 태그 검색
class SearchTags extends TagEvent {
  final String query;

  const SearchTags(this.query);

  @override
  List<Object?> get props => [query];
}

// 태그 추가
class AddTag extends TagEvent {
  final Tag tag;

  const AddTag(this.tag);

  @override
  List<Object?> get props => [tag];
}

// 태그 업데이트
class UpdateTag extends TagEvent {
  final Tag tag;

  const UpdateTag(this.tag);

  @override
  List<Object?> get props => [tag];
}

// 태그 삭제
class DeleteTag extends TagEvent {
  final String tagId;

  const DeleteTag(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

// 재료에 태그 추가
class AddTagToIngredientEvent extends TagEvent {
  final String ingredientId;
  final String tagId;

  const AddTagToIngredientEvent(this.ingredientId, this.tagId);

  @override
  List<Object?> get props => [ingredientId, tagId];
}

// 재료에서 태그 제거
class RemoveTagFromIngredientEvent extends TagEvent {
  final String ingredientId;
  final String tagId;

  const RemoveTagFromIngredientEvent(this.ingredientId, this.tagId);

  @override
  List<Object?> get props => [ingredientId, tagId];
}

// 레시피에 태그 추가
class AddTagToRecipeEvent extends TagEvent {
  final String recipeId;
  final String tagId;

  const AddTagToRecipeEvent(this.recipeId, this.tagId);

  @override
  List<Object?> get props => [recipeId, tagId];
}

// 레시피에서 태그 제거
class RemoveTagFromRecipeEvent extends TagEvent {
  final String recipeId;
  final String tagId;

  const RemoveTagFromRecipeEvent(this.recipeId, this.tagId);

  @override
  List<Object?> get props => [recipeId, tagId];
}

// 태그로 재료 검색
class SearchIngredientsByTag extends TagEvent {
  final String tagId;

  const SearchIngredientsByTag(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

// 태그로 레시피 검색
class SearchRecipesByTag extends TagEvent {
  final String tagId;

  const SearchRecipesByTag(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

// 인기 태그 로드
class LoadPopularTags extends TagEvent {
  final int limit;

  const LoadPopularTags({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

// 태그 통계 로드
class LoadTagStats extends TagEvent {
  const LoadTagStats();
}

// 태그 초기화 (기본 태그들 추가)
class InitializeDefaultTags extends TagEvent {
  const InitializeDefaultTags();
}
