import 'package:equatable/equatable.dart';
import '../../model/index.dart';

// 재료 상태 기본 클래스
abstract class IngredientState extends Equatable {
  const IngredientState();

  @override
  List<Object?> get props => [];
}

// 초기 상태
class IngredientInitial extends IngredientState {
  const IngredientInitial();
}

// 로딩 상태
class IngredientLoading extends IngredientState {
  const IngredientLoading();
}

// 재료 목록 로드 성공
class IngredientLoaded extends IngredientState {
  final List<Ingredient> ingredients;
  final Map<String, dynamic>? stats;

  const IngredientLoaded({required this.ingredients, this.stats});

  @override
  List<Object?> get props => [ingredients, stats];
}

// 재료 추가 성공
class IngredientAdded extends IngredientState {
  final Ingredient ingredient;
  final List<Ingredient> ingredients;

  const IngredientAdded({required this.ingredient, required this.ingredients});

  @override
  List<Object?> get props => [ingredient, ingredients];
}

// 재료 업데이트 성공
class IngredientUpdated extends IngredientState {
  final Ingredient ingredient;
  final List<Ingredient> ingredients;

  const IngredientUpdated({
    required this.ingredient,
    required this.ingredients,
  });

  @override
  List<Object?> get props => [ingredient, ingredients];
}

// 재료 삭제 성공
class IngredientDeleted extends IngredientState {
  final String deletedId;
  final List<Ingredient> ingredients;

  const IngredientDeleted({required this.deletedId, required this.ingredients});

  @override
  List<Object?> get props => [deletedId, ingredients];
}

// 검색 결과
class IngredientSearchResult extends IngredientState {
  final List<Ingredient> ingredients;
  final String query;

  const IngredientSearchResult({
    required this.ingredients,
    required this.query,
  });

  @override
  List<Object?> get props => [ingredients, query];
}

// 유통기한 필터링 결과
class IngredientFilteredByExpiry extends IngredientState {
  final List<Ingredient> ingredients;
  final ExpiryStatus status;

  const IngredientFilteredByExpiry({
    required this.ingredients,
    required this.status,
  });

  @override
  List<Object?> get props => [ingredients, status];
}

// 태그별 필터링 결과
class IngredientFilteredByTag extends IngredientState {
  final List<Ingredient> ingredients;
  final String tagId;

  const IngredientFilteredByTag({
    required this.ingredients,
    required this.tagId,
  });

  @override
  List<Object?> get props => [ingredients, tagId];
}

// 여러 태그로 필터링 결과
class IngredientFilteredByTags extends IngredientState {
  final List<Ingredient> ingredients;
  final List<String> tagIds;

  const IngredientFilteredByTags({
    required this.ingredients,
    required this.tagIds,
  });

  @override
  List<Object?> get props => [ingredients, tagIds];
}

// 태그 추가 성공
class TagAddedToIngredient extends IngredientState {
  final String ingredientId;
  final String tagId;
  final List<Ingredient> ingredients;

  const TagAddedToIngredient({
    required this.ingredientId,
    required this.tagId,
    required this.ingredients,
  });

  @override
  List<Object?> get props => [ingredientId, tagId, ingredients];
}

// 태그 제거 성공
class TagRemovedFromIngredient extends IngredientState {
  final String ingredientId;
  final String tagId;
  final List<Ingredient> ingredients;

  const TagRemovedFromIngredient({
    required this.ingredientId,
    required this.tagId,
    required this.ingredients,
  });

  @override
  List<Object?> get props => [ingredientId, tagId, ingredients];
}

// 태그 업데이트 성공
class IngredientTagsUpdated extends IngredientState {
  final String ingredientId;
  final List<String> tagIds;
  final List<Ingredient> ingredients;

  const IngredientTagsUpdated({
    required this.ingredientId,
    required this.tagIds,
    required this.ingredients,
  });

  @override
  List<Object?> get props => [ingredientId, tagIds, ingredients];
}

// 유통기한 임박 재료
class ExpiringIngredientsLoaded extends IngredientState {
  final List<Ingredient> ingredients;
  final int days;

  const ExpiringIngredientsLoaded({
    required this.ingredients,
    required this.days,
  });

  @override
  List<Object?> get props => [ingredients, days];
}

// 만료된 재료
class ExpiredIngredientsLoaded extends IngredientState {
  final List<Ingredient> ingredients;

  const ExpiredIngredientsLoaded({required this.ingredients});

  @override
  List<Object?> get props => [ingredients];
}

// 재료 통계 로드 성공
class IngredientStatsLoaded extends IngredientState {
  final Map<String, dynamic> stats;

  const IngredientStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

// 에러 상태
class IngredientError extends IngredientState {
  final String message;

  const IngredientError(this.message);

  @override
  List<Object?> get props => [message];
}

// 빈 상태 (재료가 없을 때)
class IngredientEmpty extends IngredientState {
  const IngredientEmpty();
}
