import '../app_locale.dart';

/// 한국 쉐프의 레시피 관련 문자열
mixin AppStringsEncyclopedia {
  /// 한국 쉐프의 레시피 탭 이름 (앱바 제목용)
  static String getEncyclopedia(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '한국 쉐프의 레시피';
      case AppLocale.japan:
        return '韓国シェフのレシピ';
      case AppLocale.china:
        return '韩国厨师食谱';
      case AppLocale.usa:
        return "Korean Chef's Recipes";
      case AppLocale.euro:
        return 'Rezepte koreanischer Köche';
      case AppLocale.vietnam:
        return 'Công thức của đầu bếp Hàn Quốc';
    }
  }

  /// 바텀 네비게이션 탭 이름 (K-Food)
  static String getEncyclopediaTab(AppLocale locale) {
    return 'K-Food';
  }

  /// 레시피 검색 힌트
  static String getSearchRecipeHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 검색...';
      case AppLocale.japan:
        return 'レシピを検索...';
      case AppLocale.china:
        return '搜索食谱...';
      case AppLocale.usa:
        return 'Search recipes...';
      case AppLocale.euro:
        return 'Rezepte suchen...';
      case AppLocale.vietnam:
        return 'Tìm kiếm công thức...';
    }
  }

  /// 재료 추가 버튼
  static String getAddIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 모두 추가';
      case AppLocale.japan:
        return '材料をすべて追加';
      case AppLocale.china:
        return '添加所有材料';
      case AppLocale.usa:
        return 'Add All Ingredients';
      case AppLocale.euro:
        return 'Alle Zutaten hinzufügen';
      case AppLocale.vietnam:
        return 'Thêm tất cả nguyên liệu';
    }
  }

  /// 양념 추가 버튼
  static String getAddSauces(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '양념 모두 추가';
      case AppLocale.japan:
        return '調味料をすべて追加';
      case AppLocale.china:
        return '添加所有调料';
      case AppLocale.usa:
        return 'Add All Sauces';
      case AppLocale.euro:
        return 'Alle Gewürze hinzufügen';
      case AppLocale.vietnam:
        return 'Thêm tất cả gia vị';
    }
  }

  /// 재료와 양념 모두 추가
  static String getAddAll(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료와 양념 모두 추가';
      case AppLocale.japan:
        return '材料と調味料をすべて追加';
      case AppLocale.china:
        return '添加所有材料和调料';
      case AppLocale.usa:
        return 'Add All Ingredients & Sauces';
      case AppLocale.euro:
        return 'Alle Zutaten und Gewürze hinzufügen';
      case AppLocale.vietnam:
        return 'Thêm tất cả nguyên liệu và gia vị';
    }
  }

  /// 개별 추가
  static String getAddIndividual(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추가';
      case AppLocale.japan:
        return '追加';
      case AppLocale.china:
        return '添加';
      case AppLocale.usa:
        return 'Add';
      case AppLocale.euro:
        return 'Hinzufügen';
      case AppLocale.vietnam:
        return 'Thêm';
    }
  }

  /// 레시피 정보
  static String getRecipeInfo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 정보';
      case AppLocale.japan:
        return 'レシピ情報';
      case AppLocale.china:
        return '食谱信息';
      case AppLocale.usa:
        return 'Recipe Info';
      case AppLocale.euro:
        return 'Rezeptinformationen';
      case AppLocale.vietnam:
        return 'Thông tin công thức';
    }
  }

  /// 재료 목록
  static String getIngredientsList(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 목록';
      case AppLocale.japan:
        return '材料リスト';
      case AppLocale.china:
        return '材料列表';
      case AppLocale.usa:
        return 'Ingredients';
      case AppLocale.euro:
        return 'Zutaten';
      case AppLocale.vietnam:
        return 'Nguyên liệu';
    }
  }

  /// 양념 목록
  static String getSaucesList(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '양념 목록';
      case AppLocale.japan:
        return '調味料リスト';
      case AppLocale.china:
        return '调料列表';
      case AppLocale.usa:
        return 'Sauces';
      case AppLocale.euro:
        return 'Gewürze';
      case AppLocale.vietnam:
        return 'Gia vị';
    }
  }

  /// 조리방법
  static String getCookingMethod(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '조리방법';
      case AppLocale.japan:
        return '調理方法';
      case AppLocale.china:
        return '烹饪方法';
      case AppLocale.usa:
        return 'Cooking Method';
      case AppLocale.euro:
        return 'Kochmethode';
      case AppLocale.vietnam:
        return 'Phương pháp nấu';
    }
  }

  /// 레시피 번호
  static String getRecipeNumber(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 번호';
      case AppLocale.japan:
        return 'レシピ番号';
      case AppLocale.china:
        return '食谱编号';
      case AppLocale.usa:
        return 'Recipe Number';
      case AppLocale.euro:
        return 'Rezeptnummer';
      case AppLocale.vietnam:
        return 'Số công thức';
    }
  }

  /// 페이지
  static String getPage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '페이지';
      case AppLocale.japan:
        return 'ページ';
      case AppLocale.china:
        return '页面';
      case AppLocale.usa:
        return 'Page';
      case AppLocale.euro:
        return 'Seite';
      case AppLocale.vietnam:
        return 'Trang';
    }
  }

  /// 레시피 없음
  static String getNoRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피가 없습니다';
      case AppLocale.japan:
        return 'レシピがありません';
      case AppLocale.china:
        return '没有食谱';
      case AppLocale.usa:
        return 'No recipes found';
      case AppLocale.euro:
        return 'Keine Rezepte gefunden';
      case AppLocale.vietnam:
        return 'Không tìm thấy công thức';
    }
  }

  /// 레시피 로딩 중
  static String getLoadingRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피를 불러오는 중...';
      case AppLocale.japan:
        return 'レシピを読み込んでいます...';
      case AppLocale.china:
        return '正在加载食谱...';
      case AppLocale.usa:
        return 'Loading recipes...';
      case AppLocale.euro:
        return 'Rezepte werden geladen...';
      case AppLocale.vietnam:
        return 'Đang tải công thức...';
    }
  }

  /// 레시피 로드 실패
  static String getLoadRecipesFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피를 불러오는데 실패했습니다';
      case AppLocale.japan:
        return 'レシピの読み込みに失敗しました';
      case AppLocale.china:
        return '加载食谱失败';
      case AppLocale.usa:
        return 'Failed to load recipes';
      case AppLocale.euro:
        return 'Rezepte konnten nicht geladen werden';
      case AppLocale.vietnam:
        return 'Không thể tải công thức';
    }
  }

  /// 조리방법 없음
  static String getNoCookingMethod(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '조리방법이 없습니다';
      case AppLocale.japan:
        return '調理方法がありません';
      case AppLocale.china:
        return '没有烹饪方法';
      case AppLocale.usa:
        return 'No cooking method available';
      case AppLocale.euro:
        return 'Keine Kochmethode verfügbar';
      case AppLocale.vietnam:
        return 'Không có phương pháp nấu';
    }
  }

  /// 10개 더보기 버튼
  static String getLoadMore(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '10개 더보기';
      case AppLocale.japan:
        return 'あと10件を見る';
      case AppLocale.china:
        return '查看更多10条';
      case AppLocale.usa:
        return 'Load 10 More';
      case AppLocale.euro:
        return '10 weitere laden';
      case AppLocale.vietnam:
        return 'Xem thêm 10';
    }
  }

  /// 번역하기 버튼
  static String getTranslate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '번역하기';
      case AppLocale.japan:
        return '翻訳';
      case AppLocale.china:
        return '翻译';
      case AppLocale.usa:
        return 'Translate';
      case AppLocale.euro:
        return 'Übersetzen';
      case AppLocale.vietnam:
        return 'Dịch';
    }
  }

  /// 원본 보기 버튼
  static String getShowOriginal(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원본 보기';
      case AppLocale.japan:
        return '原文を見る';
      case AppLocale.china:
        return '查看原文';
      case AppLocale.usa:
        return 'Show Original';
      case AppLocale.euro:
        return 'Original anzeigen';
      case AppLocale.vietnam:
        return 'Xem bản gốc';
    }
  }

  /// 번역 중
  static String getTranslating(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '번역 중...';
      case AppLocale.japan:
        return '翻訳中...';
      case AppLocale.china:
        return '翻译中...';
      case AppLocale.usa:
        return 'Translating...';
      case AppLocale.euro:
        return 'Wird übersetzt...';
      case AppLocale.vietnam:
        return 'Đang dịch...';
    }
  }
}
