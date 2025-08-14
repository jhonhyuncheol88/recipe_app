import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/tag_repository.dart';
import '../../data/ingredient_repository.dart';
import '../../data/recipe_repository.dart';
import '../../model/tag.dart';
import '../../model/ingredient.dart';
import '../../model/recipe.dart';
import 'tag_state.dart';
import '../../util/app_locale.dart';

class TagCubit extends Cubit<TagState> {
  final TagRepository _tagRepository;
  final IngredientRepository _ingredientRepository;
  final RecipeRepository _recipeRepository;
  final Uuid _uuid = const Uuid();

  TagCubit({
    required TagRepository tagRepository,
    required IngredientRepository ingredientRepository,
    required RecipeRepository recipeRepository,
  }) : _tagRepository = tagRepository,
       _ingredientRepository = ingredientRepository,
       _recipeRepository = recipeRepository,
       super(const TagInitial());

  // 모든 태그 로드
  Future<void> loadAllTags() async {
    try {
      emit(const TagLoading());
      final tags = await _tagRepository.getAllTags();
      emit(TagsLoaded(tags));
    } catch (e) {
      emit(TagError('태그 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  // 타입별 태그 로드
  Future<void> loadTagsByType(TagType type) async {
    try {
      emit(const TagLoading());
      final tags = await _tagRepository.getTagsByType(type);
      emit(TagsLoaded(tags, filterType: type));
    } catch (e) {
      emit(TagError('태그 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  // 태그 검색
  Future<void> searchTags(String query) async {
    try {
      if (query.trim().isEmpty) {
        emit(const TagsSearched([], ''));
        return;
      }

      emit(const TagLoading());
      final searchResults = await _tagRepository.searchTags(query);
      emit(TagsSearched(searchResults, query));
    } catch (e) {
      emit(TagError('태그 검색에 실패했습니다: $e'));
    }
  }

  // 태그 추가
  Future<void> addTag(Tag tag) async {
    try {
      emit(const TagLoading());

      // ID가 없으면 새로 생성
      final newTag = tag.id.isEmpty ? tag.copyWith(id: _uuid.v4()) : tag;

      await _tagRepository.insertTag(newTag);
      emit(TagAdded(newTag));
    } catch (e) {
      emit(TagError('태그 추가에 실패했습니다: $e'));
    }
  }

  // 태그 업데이트
  Future<void> updateTag(Tag tag) async {
    try {
      emit(const TagLoading());
      await _tagRepository.updateTag(tag);
      emit(TagUpdated(tag));
    } catch (e) {
      emit(TagError('태그 업데이트에 실패했습니다: $e'));
    }
  }

  // 태그 삭제
  Future<void> deleteTag(String tagId) async {
    try {
      emit(const TagLoading());
      await _tagRepository.deleteTag(tagId);
      emit(TagDeleted(tagId));
    } catch (e) {
      emit(TagError('태그 삭제에 실패했습니다: $e'));
    }
  }

  // 재료에 태그 추가
  Future<void> addTagToIngredient(String ingredientId, String tagId) async {
    try {
      emit(const TagLoading());
      await _tagRepository.addTagToIngredient(ingredientId, tagId);
      emit(TagAddedToIngredientState(ingredientId, tagId));
    } catch (e) {
      emit(TagError('재료에 태그 추가에 실패했습니다: $e'));
    }
  }

  // 재료에서 태그 제거
  Future<void> removeTagFromIngredient(
    String ingredientId,
    String tagId,
  ) async {
    try {
      emit(const TagLoading());
      await _tagRepository.removeTagFromIngredient(ingredientId, tagId);
      emit(TagRemovedFromIngredientState(ingredientId, tagId));
    } catch (e) {
      emit(TagError('재료에서 태그 제거에 실패했습니다: $e'));
    }
  }

  // 레시피에 태그 추가
  Future<void> addTagToRecipe(String recipeId, String tagId) async {
    try {
      emit(const TagLoading());
      await _tagRepository.addTagToRecipe(recipeId, tagId);
      emit(TagAddedToRecipeState(recipeId, tagId));
    } catch (e) {
      emit(TagError('레시피에 태그 추가에 실패했습니다: $e'));
    }
  }

  // 레시피에서 태그 제거
  Future<void> removeTagFromRecipe(String recipeId, String tagId) async {
    try {
      emit(const TagLoading());
      await _tagRepository.removeTagFromRecipe(recipeId, tagId);
      emit(TagRemovedFromRecipeState(recipeId, tagId));
    } catch (e) {
      emit(TagError('레시피에서 태그 제거에 실패했습니다: $e'));
    }
  }

  // 태그로 재료 검색
  Future<void> searchIngredientsByTag(String tagId) async {
    try {
      emit(const TagLoading());

      final tag = await _tagRepository.getTagById(tagId);
      if (tag == null) {
        emit(const TagError('태그를 찾을 수 없습니다.'));
        return;
      }

      final ingredientIds = await _tagRepository.getIngredientIdsByTag(tagId);
      final ingredients = <Ingredient>[];

      for (final id in ingredientIds) {
        final ingredient = await _ingredientRepository.getIngredientById(id);
        if (ingredient != null) {
          ingredients.add(ingredient);
        }
      }

      emit(IngredientsFoundByTag(ingredients, tag));
    } catch (e) {
      emit(TagError('태그로 재료 검색에 실패했습니다: $e'));
    }
  }

  // 태그로 레시피 검색
  Future<void> searchRecipesByTag(String tagId) async {
    try {
      emit(const TagLoading());

      final tag = await _tagRepository.getTagById(tagId);
      if (tag == null) {
        emit(const TagError('태그를 찾을 수 없습니다.'));
        return;
      }

      final recipeIds = await _tagRepository.getRecipeIdsByTag(tagId);
      final recipes = <Recipe>[];

      for (final id in recipeIds) {
        final recipe = await _recipeRepository.getRecipeById(id);
        if (recipe != null) {
          recipes.add(recipe);
        }
      }

      emit(RecipesFoundByTag(recipes, tag));
    } catch (e) {
      emit(TagError('태그로 레시피 검색에 실패했습니다: $e'));
    }
  }

  // 인기 태그 로드
  Future<void> loadPopularTags({int limit = 10}) async {
    try {
      emit(const TagLoading());
      final popularTags = await _tagRepository.getPopularTags(limit: limit);
      emit(PopularTagsLoaded(popularTags));
    } catch (e) {
      emit(TagError('인기 태그 로드에 실패했습니다: $e'));
    }
  }

  // 태그 통계 로드
  Future<void> loadTagStats() async {
    try {
      emit(const TagLoading());
      final stats = await _tagRepository.getTagStats();
      emit(TagStatsLoaded(stats));
    } catch (e) {
      emit(TagError('태그 통계 로드에 실패했습니다: $e'));
    }
  }

  // 기본 태그 초기화
  Future<void> initializeDefaultTags() async {
    try {
      emit(const TagLoading());

      final defaultTags = <Tag>[];

      // 재료 기본 태그 추가 (기본 로케일 기준)
      for (final tag in DefaultTags.ingredientTagsFor(
        AppLocale.defaultLocale,
      )) {
        await _tagRepository.insertTag(tag);
        defaultTags.add(tag);
      }

      // 레시피 기본 태그 추가 (기본 로케일 기준)
      for (final tag in DefaultTags.recipeTagsFor(AppLocale.defaultLocale)) {
        await _tagRepository.insertTag(tag);
        defaultTags.add(tag);
      }

      emit(DefaultTagsInitialized(defaultTags));
    } catch (e) {
      emit(TagError('기본 태그 초기화에 실패했습니다: $e'));
    }
  }

  // 새 태그 생성 (사용자 정의)
  Future<void> createCustomTag({
    required String name,
    required String color,
    TagType type = TagType.custom,
  }) async {
    try {
      final newTag = Tag(
        id: _uuid.v4(),
        name: name,
        color: color,
        type: type,
        createdAt: DateTime.now(),
      );

      await addTag(newTag);
    } catch (e) {
      emit(TagError('사용자 정의 태그 생성에 실패했습니다: $e'));
    }
  }

  // 태그 사용 횟수 증가
  Future<void> incrementTagUsage(String tagId) async {
    try {
      await _tagRepository.incrementTagUsage(tagId);
    } catch (e) {
      emit(TagError('태그 사용 횟수 증가에 실패했습니다: $e'));
    }
  }

  // 태그 사용 횟수 감소
  Future<void> decrementTagUsage(String tagId) async {
    try {
      await _tagRepository.decrementTagUsage(tagId);
    } catch (e) {
      emit(TagError('태그 사용 횟수 감소에 실패했습니다: $e'));
    }
  }
}
