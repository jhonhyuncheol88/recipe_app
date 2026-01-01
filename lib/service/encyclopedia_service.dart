import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../model/encyclopedia_recipe.dart';

/// 백과사전 서비스
class EncyclopediaService {
  static const String _jsonPath = 'assets/json/korea_recipe.json';
  List<EncyclopediaRecipe>? _cachedRecipes;

  /// 레시피 목록 로드 (매번 랜덤으로 섞어서 반환)
  Future<List<EncyclopediaRecipe>> loadRecipes() async {
    // 캐시가 없으면 먼저 로드
    if (_cachedRecipes == null) {
      try {
        final String jsonString = await rootBundle.loadString(_jsonPath);

        if (jsonString.isEmpty) {
          throw Exception('레시피 파일이 비어있습니다. 파일을 확인해주세요.');
        }

        final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

        if (jsonList.isEmpty) {
          throw Exception('레시피 데이터가 없습니다.');
        }

        _cachedRecipes = jsonList
            .map((json) =>
                EncyclopediaRecipe.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        final errorMessage = e.toString();
        if (errorMessage.contains('Unable to load asset')) {
          throw Exception('레시피 파일을 찾을 수 없습니다.\n'
              'assets/json/korea_recipe.json 파일이 존재하는지 확인하고,\n'
              'pubspec.yaml에 등록되어 있는지 확인해주세요.\n'
              '변경 후에는 앱을 완전히 종료하고 다시 실행해주세요.\n'
              '오류: $e');
        }
        throw Exception('레시피 로드 실패: $e');
      }
    }

    // 매번 호출할 때마다 새로운 리스트를 만들어서 랜덤으로 섞어서 반환
    final shuffledRecipes = List<EncyclopediaRecipe>.from(_cachedRecipes!);
    shuffledRecipes.shuffle(Random());

    return shuffledRecipes;
  }

  /// 레시피 검색 (메뉴명, 재료명 기반)
  Future<List<EncyclopediaRecipe>> searchRecipes(String query) async {
    if (query.isEmpty) {
      return await loadRecipes();
    }

    // 검색 시에는 원본 캐시에서 검색 (순서 보장)
    if (_cachedRecipes == null) {
      await loadRecipes();
    }

    final lowerQuery = query.toLowerCase();
    final filteredRecipes = _cachedRecipes!.where((recipe) {
      // 메뉴명으로 검색
      if (recipe.menuName.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // 재료명으로 검색
      for (final ingredient in recipe.ingredients) {
        if (ingredient.name.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }

      // 양념명으로 검색
      for (final sauce in recipe.sauces) {
        if (sauce.name.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }

      return false;
    }).toList();

    // 검색 결과도 랜덤으로 섞어서 반환
    filteredRecipes.shuffle(Random());

    return filteredRecipes;
  }

  /// 특정 번호의 레시피 찾기
  Future<EncyclopediaRecipe?> getRecipeByNumber(int number) async {
    final recipes = await loadRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.number == number);
    } catch (e) {
      return null;
    }
  }

  /// 캐시 초기화
  void clearCache() {
    _cachedRecipes = null;
  }
}
