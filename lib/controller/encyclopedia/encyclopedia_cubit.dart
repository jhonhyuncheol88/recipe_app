import 'package:flutter_bloc/flutter_bloc.dart';
import '../../service/encyclopedia_service.dart';
import 'encyclopedia_state.dart';

/// 백과사전 Cubit
class EncyclopediaCubit extends Cubit<EncyclopediaState> {
  final EncyclopediaService _service;

  EncyclopediaCubit({
    required EncyclopediaService service,
  })  : _service = service,
        super(const EncyclopediaInitial());

  /// 레시피 목록 로드
  Future<void> loadRecipes() async {
    try {
      emit(const EncyclopediaLoading());
      final recipes = await _service.loadRecipes();

      if (recipes.isEmpty) {
        emit(const EncyclopediaEmpty());
      } else {
        emit(EncyclopediaLoaded(recipes: recipes));
      }
    } catch (e) {
      emit(EncyclopediaError('레시피를 불러오는데 실패했습니다: $e'));
    }
  }

  /// 레시피 검색
  Future<void> searchRecipes(String query) async {
    try {
      if (query.isEmpty) {
        await loadRecipes();
        return;
      }

      emit(const EncyclopediaLoading());
      final recipes = await _service.searchRecipes(query);

      if (recipes.isEmpty) {
        emit(const EncyclopediaEmpty());
      } else {
        emit(EncyclopediaSearchResult(recipes: recipes, query: query));
      }
    } catch (e) {
      emit(EncyclopediaError('레시피 검색에 실패했습니다: $e'));
    }
  }

  /// 특정 번호의 레시피 찾기
  Future<void> loadRecipeByNumber(int number) async {
    try {
      emit(const EncyclopediaLoading());
      final recipe = await _service.getRecipeByNumber(number);

      if (recipe == null) {
        emit(const EncyclopediaEmpty());
      } else {
        emit(EncyclopediaLoaded(recipes: [recipe]));
      }
    } catch (e) {
      emit(EncyclopediaError('레시피를 불러오는데 실패했습니다: $e'));
    }
  }
}

