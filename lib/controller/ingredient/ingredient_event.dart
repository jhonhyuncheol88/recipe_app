import 'package:equatable/equatable.dart';
import '../../model/index.dart';

// 재료 이벤트 기본 클래스
abstract class IngredientEvent extends Equatable {
  const IngredientEvent();

  @override
  List<Object?> get props => [];
}

// 재료 목록 로드
class LoadIngredients extends IngredientEvent {
  const LoadIngredients();
}

// 재료 추가
class AddIngredient extends IngredientEvent {
  final Ingredient ingredient;

  const AddIngredient(this.ingredient);

  @override
  List<Object?> get props => [ingredient];
}

// 재료 업데이트
class UpdateIngredient extends IngredientEvent {
  final Ingredient ingredient;

  const UpdateIngredient(this.ingredient);

  @override
  List<Object?> get props => [ingredient];
}

// 재료 삭제
class DeleteIngredient extends IngredientEvent {
  final String id;

  const DeleteIngredient(this.id);

  @override
  List<Object?> get props => [id];
}

// 재료 검색
class SearchIngredients extends IngredientEvent {
  final String query;

  const SearchIngredients(this.query);

  @override
  List<Object?> get props => [query];
}

// 유통기한 상태별 필터링
class FilterIngredientsByExpiryStatus extends IngredientEvent {
  final ExpiryStatus status;

  const FilterIngredientsByExpiryStatus(this.status);

  @override
  List<Object?> get props => [status];
}

// 태그별 필터링
class FilterIngredientsByTag extends IngredientEvent {
  final String tagId;

  const FilterIngredientsByTag(this.tagId);

  @override
  List<Object?> get props => [tagId];
}

// 여러 태그로 필터링
class FilterIngredientsByTags extends IngredientEvent {
  final List<String> tagIds;

  const FilterIngredientsByTags(this.tagIds);

  @override
  List<Object?> get props => [tagIds];
}

// 재료에 태그 추가
class AddTagToIngredient extends IngredientEvent {
  final String ingredientId;
  final String tagId;

  const AddTagToIngredient({required this.ingredientId, required this.tagId});

  @override
  List<Object?> get props => [ingredientId, tagId];
}

// 재료에서 태그 제거
class RemoveTagFromIngredient extends IngredientEvent {
  final String ingredientId;
  final String tagId;

  const RemoveTagFromIngredient({
    required this.ingredientId,
    required this.tagId,
  });

  @override
  List<Object?> get props => [ingredientId, tagId];
}

// 재료 태그 업데이트
class UpdateIngredientTags extends IngredientEvent {
  final String ingredientId;
  final List<String> tagIds;

  const UpdateIngredientTags({
    required this.ingredientId,
    required this.tagIds,
  });

  @override
  List<Object?> get props => [ingredientId, tagIds];
}

// 유통기한이 임박한 재료 조회
class LoadExpiringIngredients extends IngredientEvent {
  final int days;

  const LoadExpiringIngredients({this.days = 7});

  @override
  List<Object?> get props => [days];
}

// 만료된 재료 조회
class LoadExpiredIngredients extends IngredientEvent {
  const LoadExpiredIngredients();
}

// 재료 통계 로드
class LoadIngredientStats extends IngredientEvent {
  const LoadIngredientStats();
}

// 재료 새로고침
class RefreshIngredients extends IngredientEvent {
  const RefreshIngredients();
}
