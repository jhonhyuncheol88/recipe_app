import 'dart:async';
import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/index.dart';
import '../util/app_locale.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      developer.log('데이터베이스 초기화 시작', name: 'DatabaseHelper');
      String path = join(await getDatabasesPath(), 'recipe_app.db');
      developer.log('데이터베이스 경로: $path', name: 'DatabaseHelper');

      final database = await openDatabase(
        path,
        version: 5, // 버전 업데이트 (AI 레시피 테이블 추가)
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      developer.log('데이터베이스 초기화 완료', name: 'DatabaseHelper');
      return database;
    } catch (e) {
      developer.log('데이터베이스 초기화 실패: $e', name: 'DatabaseHelper');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      developer.log('데이터베이스 테이블 생성 시작', name: 'DatabaseHelper');

      // Tags 테이블 생성
      developer.log('Tags 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
        CREATE TABLE tags (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          color TEXT NOT NULL,
          type TEXT NOT NULL,
          created_at TEXT NOT NULL,
          usage_count INTEGER DEFAULT 0
        )
      ''');

      // Units 테이블 생성
      developer.log('Units 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
        CREATE TABLE units (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          base_unit_id TEXT,
          conversion_factor REAL NOT NULL
        )
      ''');

      // Ingredients 테이블 생성
      developer.log('Ingredients 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
        CREATE TABLE ingredients (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          purchase_price REAL NOT NULL,
          purchase_amount REAL NOT NULL,
          purchase_unit_id TEXT NOT NULL,
          expiry_date TEXT,
          created_at TEXT NOT NULL,
          tag_ids TEXT DEFAULT '[]',
          animation_x REAL,
          animation_y REAL,
          is_animation_settled INTEGER DEFAULT 0
        )
      ''');

      // Recipes 테이블 생성
      developer.log('Recipes 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
        CREATE TABLE recipes (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          output_amount REAL NOT NULL,
          output_unit TEXT NOT NULL,
          total_cost REAL NOT NULL,
          image_path TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          tag_ids TEXT DEFAULT '[]'
        )
      ''');

      // RecipeIngredients 테이블 생성
      developer.log('RecipeIngredients 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
        CREATE TABLE recipe_ingredients (
          id TEXT PRIMARY KEY,
          recipe_id TEXT NOT NULL,
          ingredient_id TEXT NOT NULL,
          amount REAL NOT NULL,
          unit_id TEXT NOT NULL,
          calculated_cost REAL NOT NULL,
          FOREIGN KEY (recipe_id) REFERENCES recipes (id),
          FOREIGN KEY (ingredient_id) REFERENCES ingredients (id),
          FOREIGN KEY (unit_id) REFERENCES units (id)
        )
      ''');

      // Sauces 테이블 생성
      developer.log('Sauces 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
        CREATE TABLE sauces (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          total_weight REAL NOT NULL,
          total_cost REAL NOT NULL,
          image_path TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      // SauceIngredients 테이블 생성
      developer.log('SauceIngredients 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
        CREATE TABLE sauce_ingredients (
          id TEXT PRIMARY KEY,
          sauce_id TEXT NOT NULL,
          ingredient_id TEXT NOT NULL,
          amount REAL NOT NULL,
          unit_id TEXT NOT NULL,
          FOREIGN KEY (sauce_id) REFERENCES sauces (id),
          FOREIGN KEY (ingredient_id) REFERENCES ingredients (id),
          FOREIGN KEY (unit_id) REFERENCES units (id)
        )
      ''');

      // RecipeSauces 테이블 생성
      developer.log('RecipeSauces 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
        CREATE TABLE recipe_sauces (
          id TEXT PRIMARY KEY,
          recipe_id TEXT NOT NULL,
          sauce_id TEXT NOT NULL,
          amount REAL NOT NULL,
          unit_id TEXT NOT NULL,
          FOREIGN KEY (recipe_id) REFERENCES recipes (id),
          FOREIGN KEY (sauce_id) REFERENCES sauces (id),
          FOREIGN KEY (unit_id) REFERENCES units (id)
        )
      ''');

      // 인덱스 생성
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sauce_ing_sauce_id ON sauce_ingredients(sauce_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_recipe_sauces_recipe_id ON recipe_sauces(recipe_id)',
      );

      // AI Recipes 테이블 생성
      developer.log('AI Recipes 테이블 생성', name: 'DatabaseHelper');
      await db.execute('''
          CREATE TABLE ai_recipes (
            id TEXT PRIMARY KEY,
            recipe_name TEXT NOT NULL,
            description TEXT,
            cuisine_type TEXT,
            servings INTEGER,
            prep_time_minutes INTEGER,
            cook_time_minutes INTEGER,
            total_time_minutes INTEGER,
            difficulty TEXT,
            ingredients TEXT NOT NULL,
            instructions TEXT NOT NULL,
            tips TEXT,
            nutritional_info TEXT,
            estimated_cost REAL,
            tags TEXT,
            creativity_score TEXT,
            generated_at TEXT NOT NULL,
            source_ingredients TEXT,
            ai_model TEXT,
            prompt_version TEXT,
            is_converted_to_recipe INTEGER DEFAULT 0,
            converted_recipe_id TEXT
          )
        ''');

      // AI Recipes 인덱스 생성
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_ai_recipes_generated_at ON ai_recipes(generated_at)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_ai_recipes_cuisine_type ON ai_recipes(cuisine_type)',
      );

      // 기본 단위 데이터 삽입
      developer.log('기본 단위 데이터 삽입', name: 'DatabaseHelper');
      await _insertDefaultUnits(db);

      // 기본 태그 데이터 삽입
      developer.log('기본 태그 데이터 삽입', name: 'DatabaseHelper');
      await _insertDefaultTags(db);

      developer.log('데이터베이스 테이블 생성 완료', name: 'DatabaseHelper');
    } catch (e) {
      developer.log('데이터베이스 테이블 생성 실패: $e', name: 'DatabaseHelper');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      developer.log(
        '데이터베이스 업그레이드: $oldVersion -> $newVersion',
        name: 'DatabaseHelper',
      );

      if (oldVersion < 2) {
        // 버전 2: 애니메이션 위치 컬럼 추가
        developer.log('애니메이션 위치 컬럼 추가', name: 'DatabaseHelper');
        await db.execute('ALTER TABLE ingredients ADD COLUMN animation_x REAL');
        await db.execute('ALTER TABLE ingredients ADD COLUMN animation_y REAL');
        await db.execute(
          'ALTER TABLE ingredients ADD COLUMN is_animation_settled INTEGER DEFAULT 0',
        );
        developer.log('애니메이션 위치 컬럼 추가 완료', name: 'DatabaseHelper');
      }

      if (oldVersion < 3) {
        // 버전 3: 단위 ID 업데이트
        developer.log('단위 ID 업데이트 시작', name: 'DatabaseHelper');

        // 기존 단위 ID를 새로운 ID로 매핑
        final unitIdMapping = {
          '1': 'g',
          '2': 'kg',
          '3': 'ml',
          '4': 'L',
          '5': '개',
          '6': '팩',
        };

        // ingredients 테이블의 purchase_unit_id 업데이트
        for (final entry in unitIdMapping.entries) {
          await db.execute(
            'UPDATE ingredients SET purchase_unit_id = ? WHERE purchase_unit_id = ?',
            [entry.value, entry.key],
          );
        }

        // units 테이블의 id 업데이트
        for (final entry in unitIdMapping.entries) {
          await db.execute('UPDATE units SET id = ?, name = ? WHERE id = ?', [
            entry.value,
            entry.value,
            entry.key,
          ]);
        }

        developer.log('단위 ID 업데이트 완료', name: 'DatabaseHelper');
      }

      if (oldVersion < 4) {
        // 버전 4: 소스 관련 테이블 추가
        developer.log('소스 테이블 추가 시작', name: 'DatabaseHelper');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS sauces (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            total_weight REAL NOT NULL,
            total_cost REAL NOT NULL,
            image_path TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS sauce_ingredients (
            sauce_id TEXT NOT NULL,
            ingredient_id TEXT NOT NULL,
            amount REAL NOT NULL,
            unit_id TEXT NOT NULL,
            FOREIGN KEY (sauce_id) REFERENCES sauces (id),
            FOREIGN KEY (ingredient_id) REFERENCES ingredients (id),
            FOREIGN KEY (unit_id) REFERENCES units (id)
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS recipe_sauces (
            id TEXT PRIMARY KEY,
            recipe_id TEXT NOT NULL,
            sauce_id TEXT NOT NULL,
            amount REAL NOT NULL,
            unit_id TEXT NOT NULL,
            FOREIGN KEY (recipe_id) REFERENCES recipes (id),
            FOREIGN KEY (sauce_id) REFERENCES sauces (id),
            FOREIGN KEY (unit_id) REFERENCES units (id)
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_sauce_ing_sauce_id ON sauce_ingredients(sauce_id)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_recipe_sauces_recipe_id ON recipe_sauces(recipe_id)',
        );

        developer.log('소스 테이블 추가 완료', name: 'DatabaseHelper');
      }

      if (oldVersion < 5) {
        // 버전 5: AI 레시피 테이블 추가
        developer.log('AI 레시피 테이블 추가 시작', name: 'DatabaseHelper');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS ai_recipes (
            id TEXT PRIMARY KEY,
            recipe_name TEXT NOT NULL,
            description TEXT,
            cuisine_type TEXT,
            servings INTEGER,
            prep_time_minutes INTEGER,
            cook_time_minutes INTEGER,
            total_time_minutes INTEGER,
            difficulty TEXT,
            ingredients TEXT NOT NULL,
            instructions TEXT NOT NULL,
            tips TEXT,
            nutritional_info TEXT,
            estimated_cost REAL,
            tags TEXT,
            creativity_score TEXT,
            generated_at TEXT NOT NULL,
            source_ingredients TEXT,
            ai_model TEXT,
            prompt_version TEXT,
            is_converted_to_recipe INTEGER DEFAULT 0,
            converted_recipe_id TEXT
          )
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_ai_recipes_generated_at ON ai_recipes(generated_at)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_ai_recipes_cuisine_type ON ai_recipes(cuisine_type)',
        );

        developer.log('AI 레시피 테이블 추가 완료', name: 'DatabaseHelper');
      }
    } catch (e) {
      developer.log('데이터베이스 업그레이드 실패: $e', name: 'DatabaseHelper');
      rethrow;
    }
  }

  Future<void> _insertDefaultUnits(Database db) async {
    final defaultUnits = [
      // 무게 단위
      {
        'id': 'g',
        'name': 'g',
        'type': 'weight',
        'base_unit_id': null,
        'conversion_factor': 1.0,
      },
      {
        'id': 'kg',
        'name': 'kg',
        'type': 'weight',
        'base_unit_id': 'g',
        'conversion_factor': 1000.0,
      },
      {
        'id': 'lb',
        'name': 'lb',
        'type': 'weight',
        'base_unit_id': 'g',
        'conversion_factor': 453.592,
      },

      // 부피 단위
      {
        'id': 'ml',
        'name': 'ml',
        'type': 'volume',
        'base_unit_id': null,
        'conversion_factor': 1.0,
      },
      {
        'id': 'L',
        'name': 'L',
        'type': 'volume',
        'base_unit_id': 'ml',
        'conversion_factor': 1000.0,
      },
      {
        'id': 'cup',
        'name': 'cup',
        'type': 'volume',
        'base_unit_id': 'ml',
        'conversion_factor': 236.588,
      },
      {
        'id': 'tbsp',
        'name': 'tbsp',
        'type': 'volume',
        'base_unit_id': 'ml',
        'conversion_factor': 14.787,
      },
      {
        'id': 'tsp',
        'name': 'tsp',
        'type': 'volume',
        'base_unit_id': 'ml',
        'conversion_factor': 4.929,
      },

      // 개수 단위
      {
        'id': '개',
        'name': '개',
        'type': 'count',
        'base_unit_id': null,
        'conversion_factor': 1.0,
      },
      {
        'id': '마리',
        'name': '마리',
        'type': 'count',
        'base_unit_id': null,
        'conversion_factor': 1.0,
      },
      {
        'id': '장',
        'name': '장',
        'type': 'count',
        'base_unit_id': null,
        'conversion_factor': 1.0,
      },
      {
        'id': '인분',
        'name': '인분',
        'type': 'count',
        'base_unit_id': null,
        'conversion_factor': 1.0,
      },
    ];

    for (final unit in defaultUnits) {
      await db.insert('units', unit);
    }
  }

  Future<void> _insertDefaultTags(Database db) async {
    // 재료 기본 태그 삽입 (기본 로케일 기준 저장)
    for (final tag in DefaultTags.ingredientTagsFor(AppLocale.defaultLocale)) {
      await db.insert('tags', tag.toJson());
    }

    // 레시피 기본 태그 삽입 (기본 로케일 기준 저장)
    for (final tag in DefaultTags.recipeTagsFor(AppLocale.defaultLocale)) {
      await db.insert('tags', tag.toJson());
    }
  }

  // 데이터베이스 연결 종료
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
