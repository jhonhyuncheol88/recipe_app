import 'package:sqflite/sqflite.dart';
import '../model/ai_recipe.dart';
import 'database_helper.dart';

/// AI 레시피 데이터 접근을 위한 리포지토리
class AiRecipeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// AI 레시피 저장
  Future<void> insertAiRecipe(AiRecipe aiRecipe) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert('ai_recipes', aiRecipe.toJson());
    } catch (e) {
      throw Exception('AI 레시피 저장에 실패했습니다: $e');
    }
  }

  /// 모든 AI 레시피 조회
  Future<List<AiRecipe>> getAllAiRecipes() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ai_recipes',
        orderBy: 'generated_at DESC',
      );

      return List.generate(maps.length, (i) {
        return AiRecipe.fromJson(maps[i]);
      });
    } catch (e) {
      throw Exception('AI 레시피 목록 조회에 실패했습니다: $e');
    }
  }

  /// ID로 AI 레시피 조회
  Future<AiRecipe?> getAiRecipeById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ai_recipes',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return AiRecipe.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('AI 레시피 조회에 실패했습니다: $e');
    }
  }

  /// 요리 스타일별 AI 레시피 조회
  Future<List<AiRecipe>> getAiRecipesByCuisineType(String cuisineType) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ai_recipes',
        where: 'cuisine_type = ?',
        whereArgs: [cuisineType],
        orderBy: 'generated_at DESC',
      );

      return List.generate(maps.length, (i) {
        return AiRecipe.fromJson(maps[i]);
      });
    } catch (e) {
      throw Exception('요리 스타일별 AI 레시피 조회에 실패했습니다: $e');
    }
  }

  /// 변환되지 않은 AI 레시피만 조회
  Future<List<AiRecipe>> getUnconvertedAiRecipes() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ai_recipes',
        where: 'is_converted_to_recipe = 0',
        orderBy: 'generated_at DESC',
      );

      return List.generate(maps.length, (i) {
        return AiRecipe.fromJson(maps[i]);
      });
    } catch (e) {
      throw Exception('미변환 AI 레시피 조회에 실패했습니다: $e');
    }
  }

  /// AI 레시피 업데이트
  Future<void> updateAiRecipe(AiRecipe aiRecipe) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'ai_recipes',
        aiRecipe.toJson(),
        where: 'id = ?',
        whereArgs: [aiRecipe.id],
      );
    } catch (e) {
      throw Exception('AI 레시피 업데이트에 실패했습니다: $e');
    }
  }

  /// AI 레시피 삭제
  Future<void> deleteAiRecipe(String id) async {
    try {
      final db = await _databaseHelper.database;
      await db.delete(
        'ai_recipes',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('AI 레시피 삭제에 실패했습니다: $e');
    }
  }

  /// AI 레시피를 일반 레시피로 변환 표시
  Future<void> markAsConverted(String aiRecipeId, String recipeId) async {
    try {
      final db = await _databaseHelper.database;
      await db.update(
        'ai_recipes',
        {
          'is_converted_to_recipe': 1,
          'converted_recipe_id': recipeId,
        },
        where: 'id = ?',
        whereArgs: [aiRecipeId],
      );
    } catch (e) {
      throw Exception('AI 레시피 변환 상태 업데이트에 실패했습니다: $e');
    }
  }

  /// AI 레시피 통계 조회
  Future<Map<String, dynamic>> getAiRecipeStats() async {
    try {
      final db = await _databaseHelper.database;
      
      // 전체 AI 레시피 수
      final totalCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ai_recipes'),
      ) ?? 0;

      // 변환된 AI 레시피 수
      final convertedCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM ai_recipes WHERE is_converted_to_recipe = 1',
        ),
      ) ?? 0;

      // 요리 스타일별 통계
      final cuisineStats = await db.rawQuery('''
        SELECT cuisine_type, COUNT(*) as count 
        FROM ai_recipes 
        WHERE cuisine_type IS NOT NULL 
        GROUP BY cuisine_type 
        ORDER BY count DESC
      ''');

      // 최근 생성된 AI 레시피 수 (7일)
      final recentCount = Sqflite.firstIntValue(
        await db.rawQuery('''
          SELECT COUNT(*) FROM ai_recipes 
          WHERE generated_at >= datetime('now', '-7 days')
        '''),
      ) ?? 0;

      return {
        'total_count': totalCount,
        'converted_count': convertedCount,
        'unconverted_count': totalCount - convertedCount,
        'cuisine_stats': cuisineStats,
        'recent_count': recentCount,
        'conversion_rate': totalCount > 0 ? (convertedCount / totalCount) : 0.0,
      };
    } catch (e) {
      throw Exception('AI 레시피 통계 조회에 실패했습니다: $e');
    }
  }

  /// 특정 재료를 사용한 AI 레시피 조회
  Future<List<AiRecipe>> getAiRecipesBySourceIngredient(String ingredientName) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ai_recipes',
        where: 'source_ingredients LIKE ?',
        whereArgs: ['%$ingredientName%'],
        orderBy: 'generated_at DESC',
      );

      return List.generate(maps.length, (i) {
        return AiRecipe.fromJson(maps[i]);
      });
    } catch (e) {
      throw Exception('재료별 AI 레시피 조회에 실패했습니다: $e');
    }
  }

  /// AI 레시피 검색
  Future<List<AiRecipe>> searchAiRecipes(String query) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'ai_recipes',
        where: 'recipe_name LIKE ? OR description LIKE ? OR cuisine_type LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'generated_at DESC',
      );

      return List.generate(maps.length, (i) {
        return AiRecipe.fromJson(maps[i]);
      });
    } catch (e) {
      throw Exception('AI 레시피 검색에 실패했습니다: $e');
    }
  }
}
