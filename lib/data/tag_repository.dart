import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../model/index.dart';
import 'database_helper.dart';

class TagRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // 태그 추가
  Future<void> insertTag(Tag tag) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'tags',
      tag.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 모든 태그 조회
  Future<List<Tag>> getAllTags() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tags');
    
    return List.generate(maps.length, (i) {
      return Tag.fromJson(maps[i]);
    });
  }

  // 태그 ID로 조회
  Future<Tag?> getTagById(String id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Tag.fromJson(maps.first);
    }
    return null;
  }

  // 타입별 태그 조회
  Future<List<Tag>> getTagsByType(TagType type) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'type = ?',
      whereArgs: [type.name],
      orderBy: 'usage_count DESC, name ASC',
    );

    return List.generate(maps.length, (i) {
      return Tag.fromJson(maps[i]);
    });
  }

  // 재료 태그 조회
  Future<List<Tag>> getIngredientTags() async {
    return getTagsByType(TagType.ingredient);
  }

  // 레시피 태그 조회
  Future<List<Tag>> getRecipeTags() async {
    return getTagsByType(TagType.recipe);
  }

  // 사용자 정의 태그 조회
  Future<List<Tag>> getCustomTags() async {
    return getTagsByType(TagType.custom);
  }

  // 태그 업데이트
  Future<void> updateTag(Tag tag) async {
    final db = await _databaseHelper.database;
    await db.update(
      'tags',
      tag.toJson(),
      where: 'id = ?',
      whereArgs: [tag.id],
    );
  }

  // 태그 삭제
  Future<void> deleteTag(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  // 태그 사용 횟수 증가
  Future<void> incrementTagUsage(String tagId) async {
    final tag = await getTagById(tagId);
    if (tag != null) {
      final updatedTag = tag.incrementUsage();
      await updateTag(updatedTag);
    }
  }

  // 태그 사용 횟수 감소
  Future<void> decrementTagUsage(String tagId) async {
    final tag = await getTagById(tagId);
    if (tag != null) {
      final updatedTag = tag.decrementUsage();
      await updateTag(updatedTag);
    }
  }

  // 태그 검색
  Future<List<Tag>> searchTags(String query) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'usage_count DESC, name ASC',
    );

    return List.generate(maps.length, (i) {
      return Tag.fromJson(maps[i]);
    });
  }

  // 인기 태그 조회 (사용 횟수 기준)
  Future<List<Tag>> getPopularTags({int limit = 10}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      orderBy: 'usage_count DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Tag.fromJson(maps[i]);
    });
  }

  // 태그 통계 정보
  Future<Map<String, dynamic>> getTagStats() async {
    final allTags = await getAllTags();
    
    return {
      'total': allTags.length,
      'ingredient': allTags.where((t) => t.type == TagType.ingredient).length,
      'recipe': allTags.where((t) => t.type == TagType.recipe).length,
      'custom': allTags.where((t) => t.type == TagType.custom).length,
      'most_used': allTags.isNotEmpty ? allTags.reduce((a, b) => a.usageCount > b.usageCount ? a : b) : null,
    };
  }

  // 태그 ID 목록을 JSON 문자열로 변환
  String tagIdsToJson(List<String> tagIds) {
    return jsonEncode(tagIds);
  }

  // JSON 문자열을 태그 ID 목록으로 변환
  List<String> jsonToTagIds(String json) {
    try {
      final List<dynamic> list = jsonDecode(json);
      return list.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // 재료에 태그 추가
  Future<void> addTagToIngredient(String ingredientId, String tagId) async {
    final db = await _databaseHelper.database;
    
    // 현재 태그 목록 가져오기
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'id = ?',
      whereArgs: [ingredientId],
    );

    if (maps.isNotEmpty) {
      final currentTagIds = jsonToTagIds(maps.first['tag_ids'] ?? '[]');
      if (!currentTagIds.contains(tagId)) {
        currentTagIds.add(tagId);
        final newTagIdsJson = tagIdsToJson(currentTagIds);
        
        await db.update(
          'ingredients',
          {'tag_ids': newTagIdsJson},
          where: 'id = ?',
          whereArgs: [ingredientId],
        );

        // 태그 사용 횟수 증가
        await incrementTagUsage(tagId);
      }
    }
  }

  // 재료에서 태그 제거
  Future<void> removeTagFromIngredient(String ingredientId, String tagId) async {
    final db = await _databaseHelper.database;
    
    // 현재 태그 목록 가져오기
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'id = ?',
      whereArgs: [ingredientId],
    );

    if (maps.isNotEmpty) {
      final currentTagIds = jsonToTagIds(maps.first['tag_ids'] ?? '[]');
      currentTagIds.remove(tagId);
      final newTagIdsJson = tagIdsToJson(currentTagIds);
      
      await db.update(
        'ingredients',
        {'tag_ids': newTagIdsJson},
        where: 'id = ?',
        whereArgs: [ingredientId],
      );

      // 태그 사용 횟수 감소
      await decrementTagUsage(tagId);
    }
  }

  // 레시피에 태그 추가
  Future<void> addTagToRecipe(String recipeId, String tagId) async {
    final db = await _databaseHelper.database;
    
    // 현재 태그 목록 가져오기
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );

    if (maps.isNotEmpty) {
      final currentTagIds = jsonToTagIds(maps.first['tag_ids'] ?? '[]');
      if (!currentTagIds.contains(tagId)) {
        currentTagIds.add(tagId);
        final newTagIdsJson = tagIdsToJson(currentTagIds);
        
        await db.update(
          'recipes',
          {'tag_ids': newTagIdsJson},
          where: 'id = ?',
          whereArgs: [recipeId],
        );

        // 태그 사용 횟수 증가
        await incrementTagUsage(tagId);
      }
    }
  }

  // 레시피에서 태그 제거
  Future<void> removeTagFromRecipe(String recipeId, String tagId) async {
    final db = await _databaseHelper.database;
    
    // 현재 태그 목록 가져오기
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [recipeId],
    );

    if (maps.isNotEmpty) {
      final currentTagIds = jsonToTagIds(maps.first['tag_ids'] ?? '[]');
      currentTagIds.remove(tagId);
      final newTagIdsJson = tagIdsToJson(currentTagIds);
      
      await db.update(
        'recipes',
        {'tag_ids': newTagIdsJson},
        where: 'id = ?',
        whereArgs: [recipeId],
      );

      // 태그 사용 횟수 감소
      await decrementTagUsage(tagId);
    }
  }

  // 특정 태그를 가진 재료 조회
  Future<List<String>> getIngredientIdsByTag(String tagId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ingredients',
      where: 'tag_ids LIKE ?',
      whereArgs: ['%$tagId%'],
    );

    return maps.map((map) => map['id'] as String).toList();
  }

  // 특정 태그를 가진 레시피 조회
  Future<List<String>> getRecipeIdsByTag(String tagId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'tag_ids LIKE ?',
      whereArgs: ['%$tagId%'],
    );

    return maps.map((map) => map['id'] as String).toList();
  }
} 