import '../app_locale.dart';

/// Ai 관련 문자열
mixin AppStringsAi {
  /// AI 페이지 관련
  static String getAiRecipeGeneration(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 생성';
      case AppLocale.japan:
        return 'AIレシピ生成';
      case AppLocale.china:
        return 'AI食谱生成';
      case AppLocale.usa:
        return 'AI Recipe Generation';
      case AppLocale.euro:
        return 'AI Recipe Generation';
      case AppLocale.vietnam:
        return 'Tạo công thức AI';
    }
  }

  static String getAiRecipeGenerationTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI와 함께 창의적인 레시피 만들기';
      case AppLocale.japan:
        return 'AIと一緒に創造的なレシピを作ろう';
      case AppLocale.china:
        return '与AI一起制作创意食谱';
      case AppLocale.usa:
        return 'Create Creative Recipes with AI';
      case AppLocale.euro:
        return 'Create Creative Recipes with AI';
      case AppLocale.vietnam:
        return 'Tạo công thức sáng tạo với AI';
    }
  }

  static String getAiRecipeGenerationDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '보유한 식자재를 선택하면 AI가 창의적인 레시피를 제안하고, 필요한 추가 재료도 알려드립니다.';
      case AppLocale.japan:
        return '保有している食材を選択すると、AIが創造的なレシピを提案し、必要な追加材料も教えてくれます。';
      case AppLocale.china:
        return '选择您拥有的食材，AI将建议创意食谱，并告诉您需要的额外材料。';
      case AppLocale.usa:
        return 'Select your available ingredients and AI will suggest creative recipes and tell you about any additional ingredients needed.';
      case AppLocale.euro:
        return 'Select your available ingredients and AI will suggest creative recipes and tell you about any additional ingredients needed.';
      case AppLocale.vietnam:
        return 'Chọn nguyên liệu bạn có và AI sẽ đề xuất công thức sáng tạo và cho bạn biết về các nguyên liệu bổ sung cần thiết.';
    }
  }

  static String getSelectIngredientsToUse(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '사용할 식자재 선택';
      case AppLocale.japan:
        return '使用する食材を選択';
      case AppLocale.china:
        return '选择要使用的食材';
      case AppLocale.usa:
        return 'Select Ingredients to Use';
      case AppLocale.euro:
        return 'Select Ingredients to Use';
      case AppLocale.vietnam:
        return 'Chọn nguyên liệu để sử dụng';
    }
  }

  static String getSelectedIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '선택된 재료';
      case AppLocale.japan:
        return '選択された材料';
      case AppLocale.china:
        return '已选择的材料';
      case AppLocale.usa:
        return 'Selected Ingredients';
      case AppLocale.euro:
        return 'Selected Ingredients';
      case AppLocale.vietnam:
        return 'Nguyên liệu đã chọn';
    }
  }

  static String getRecipeGeneration(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 생성';
      case AppLocale.japan:
        return 'レシピ生成';
      case AppLocale.china:
        return '食谱生成';
      case AppLocale.usa:
        return 'Recipe Generation';
      case AppLocale.euro:
        return 'Recipe Generation';
      case AppLocale.vietnam:
        return 'Tạo công thức';
    }
  }

  static String getAiRecipeGenerationButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 생성';
      case AppLocale.japan:
        return 'AIレシピ生成';
      case AppLocale.china:
        return 'AI食谱生成';
      case AppLocale.usa:
        return 'Generate AI Recipe';
      case AppLocale.euro:
        return 'Generate AI Recipe';
      case AppLocale.vietnam:
        return 'Tạo công thức AI';
    }
  }

  static String getGeneratingRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 생성 중...';
      case AppLocale.japan:
        return 'レシピ生成中...';
      case AppLocale.china:
        return '食谱生成中...';
      case AppLocale.usa:
        return 'Generating Recipe...';
      case AppLocale.euro:
        return 'Generating Recipe...';
      case AppLocale.vietnam:
        return 'Đang tạo công thức...';
    }
  }

  static String getGeneratedRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '생성된 레시피';
      case AppLocale.japan:
        return '生成されたレシピ';
      case AppLocale.china:
        return '生成的食谱';
      case AppLocale.usa:
        return 'Generated Recipe';
      case AppLocale.euro:
        return 'Generated Recipe';
      case AppLocale.vietnam:
        return 'Công thức đã tạo';
    }
  }

  static String getCookingStyle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '요리 스타일';
      case AppLocale.japan:
        return '料理スタイル';
      case AppLocale.china:
        return '烹饪风格';
      case AppLocale.usa:
        return 'Cooking Style';
      case AppLocale.euro:
        return 'Cooking Style';
      case AppLocale.vietnam:
        return 'Phong cách nấu ăn';
    }
  }

  static String getServings(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '인분';
      case AppLocale.japan:
        return '人前';
      case AppLocale.china:
        return '份数';
      case AppLocale.usa:
        return 'Servings';
      case AppLocale.euro:
        return 'Servings';
      case AppLocale.vietnam:
        return 'Phần ăn';
    }
  }

  static String getCookingTime(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '조리 시간';
      case AppLocale.japan:
        return '調理時間';
      case AppLocale.china:
        return '烹饪时间';
      case AppLocale.usa:
        return 'Cooking Time';
      case AppLocale.euro:
        return 'Cooking Time';
      case AppLocale.vietnam:
        return 'Thời gian nấu';
    }
  }

  static String getDifficulty(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '난이도';
      case AppLocale.japan:
        return '難易度';
      case AppLocale.china:
        return '难度';
      case AppLocale.usa:
        return 'Difficulty';
      case AppLocale.euro:
        return 'Difficulty';
      case AppLocale.vietnam:
        return 'Độ khó';
    }
  }

  static String getRequiredIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '필요한 재료';
      case AppLocale.japan:
        return '必要な材料';
      case AppLocale.china:
        return '所需材料';
      case AppLocale.usa:
        return 'Required Ingredients';
      case AppLocale.euro:
        return 'Required Ingredients';
      case AppLocale.vietnam:
        return 'Nguyên liệu cần thiết';
    }
  }

  static String getAdditionalIngredientsNeeded(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추가로 필요한 재료';
      case AppLocale.japan:
        return '追加で必要な材料';
      case AppLocale.china:
        return '额外需要的材料';
      case AppLocale.usa:
        return 'Additional Ingredients Needed';
      case AppLocale.euro:
        return 'Additional Ingredients Needed';
      case AppLocale.vietnam:
        return 'Nguyên liệu bổ sung cần thiết';
    }
  }

  static String getAddAllIngredientsAtOnce(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '모든 재료 한번에 추가';
      case AppLocale.japan:
        return 'すべての材料を一度に追加';
      case AppLocale.china:
        return '一次性添加所有材料';
      case AppLocale.usa:
        return 'Add All Ingredients at Once';
      case AppLocale.euro:
        return 'Add All Ingredients at Once';
      case AppLocale.vietnam:
        return 'Thêm tất cả nguyên liệu cùng lúc';
    }
  }

  static String getAiRecipeGeneratorUsage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 생성기 사용법';
      case AppLocale.japan:
        return 'AIレシピ生成機の使い方';
      case AppLocale.china:
        return 'AI食谱生成器使用方法';
      case AppLocale.usa:
        return 'AI Recipe Generator Usage';
      case AppLocale.euro:
        return 'AI Recipe Generator Usage';
      case AppLocale.vietnam:
        return 'Cách sử dụng trình tạo công thức AI';
    }
  }

  static String getAiRecipeGeneratorInstructions(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '1. 사용할 식자재를 선택하세요\n'
            '2. AI 레시피 생성 버튼을 누르세요\n'
            '3. AI가 창의적인 레시피를 제안합니다\n'
            '4. 추가로 필요한 재료가 있다면 알려드립니다';
      case AppLocale.japan:
        return '1. 使用する食材を選択してください\n'
            '2. AIレシピ生成ボタンを押してください\n'
            '3. AIが創造的なレシピを提案します\n'
            '4. 追加で必要な材料があれば教えてくれます';
      case AppLocale.china:
        return '1. 选择要使用的食材\n'
            '2. 点击AI食谱生成按钮\n'
            '3. AI将建议创意食谱\n'
            '4. 如果有额外需要的材料会告诉您';
      case AppLocale.usa:
        return '1. Select ingredients to use\n'
            '2. Press AI recipe generation button\n'
            '3. AI suggests creative recipes\n'
            '4. We\'ll let you know if additional ingredients are needed';
      case AppLocale.euro:
        return '1. Select ingredients to use\n'
            '2. Press AI recipe generation button\n'
            '3. AI suggests creative recipes\n'
            '4. We\'ll let you know if additional ingredients are needed';
      case AppLocale.vietnam:
        return '1. Chọn nguyên liệu để sử dụng\n'
            '2. Nhấn nút tạo công thức AI\n'
            '3. AI đề xuất các công thức sáng tạo\n'
            '4. Chúng tôi sẽ thông báo nếu cần thêm nguyên liệu';
      case AppLocale.usa:
        return '1. Select ingredients to use\n'
            '2. Press the AI Recipe Generation button\n'
            '3. AI suggests creative recipes\n'
            '4. Tells you about any additional ingredients needed';
      case AppLocale.euro:
        return '1. Select ingredients to use\n'
            '2. Press the AI Recipe Generation button\n'
            '3. AI suggests creative recipes\n'
            '4. Tells you about any additional ingredients needed';
    }
  }

  static String getNoIngredientsForRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 생성을 위해 최소 1개 이상의 식자재를 선택해주세요.';
      case AppLocale.japan:
        return 'レシピ生成のために最低1つ以上の食材を選択してください。';
      case AppLocale.china:
        return '为了生成食谱，请至少选择1种食材。';
      case AppLocale.usa:
        return 'Please select at least 1 ingredient to generate a recipe.';
      case AppLocale.euro:
        return 'Please select at least 1 ingredient to generate a recipe.';
      case AppLocale.vietnam:
        return 'Vui lòng chọn ít nhất 1 nguyên liệu để tạo công thức.';
    }
  }

  static String getNoRegisteredIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '등록된 식자재가 없습니다.\n먼저 식자재를 추가해주세요.';
      case AppLocale.japan:
        return '登録された食材がありません。\nまず食材を追加してください。';
      case AppLocale.china:
        return '没有已注册的食材。\n请先添加食材。';
      case AppLocale.usa:
        return 'No ingredients registered.\nPlease add ingredients first.';
      case AppLocale.euro:
        return 'No ingredients registered.\nPlease add ingredients first.';
      case AppLocale.vietnam:
        return 'Chưa có nguyên liệu nào được đăng ký.\\nVui lòng thêm nguyên liệu trước.';
    }
  }

  static String getCannotLoadIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '식자재를 불러올 수 없습니다.';
      case AppLocale.japan:
        return '食材を読み込めません。';
      case AppLocale.china:
        return '无法加载食材。';
      case AppLocale.usa:
        return 'Cannot load ingredients.';
      case AppLocale.euro:
        return 'Cannot load ingredients.';
      case AppLocale.vietnam:
        return 'Không thể tải nguyên liệu.';
    }
  }

  static String getRecipeGenerationError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 생성 중 오류가 발생했습니다';
      case AppLocale.japan:
        return 'レシピ生成中にエラーが発生しました';
      case AppLocale.china:
        return '食谱生成时发生错误';
      case AppLocale.usa:
        return 'An error occurred while generating the recipe';
      case AppLocale.euro:
        return 'An error occurred while generating the recipe';
      case AppLocale.vietnam:
        return 'Đã xảy ra lỗi khi tạo công thức';
    }
  }

  static String getFeatureComingSoon(AppLocale locale, String featureName) {
    switch (locale) {
      case AppLocale.korea:
        return '$featureName 기능은 추후 구현 예정입니다.';
      case AppLocale.japan:
        return '$featureName機能は今後の実装予定です。';
      case AppLocale.china:
        return '$featureName功能将在后续实现。';
      case AppLocale.usa:
        return '$featureName feature will be implemented later.';
      case AppLocale.euro:
        return '$featureName feature will be implemented later.';
      case AppLocale.vietnam:
        return 'Tính năng $featureName sẽ được triển khai sau.';
    }
  }

  static String getIngredientAdditionFeature(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 추가';
      case AppLocale.japan:
        return '材料追加';
      case AppLocale.china:
        return '材料添加';
      case AppLocale.usa:
        return 'Ingredient Addition';
      case AppLocale.euro:
        return 'Ingredient Addition';
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu';
    }
  }

  static String getBulkIngredientAdditionFeature(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '일괄 재료 추가';
      case AppLocale.japan:
        return '一括材料追加';
      case AppLocale.china:
        return '批量材料添加';
      case AppLocale.usa:
        return 'Bulk Ingredient Addition';
      case AppLocale.euro:
        return 'Bulk Ingredient Addition';
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu hàng loạt';
    }
  }

  /// AI 레시피 관리 페이지 관련
  static String getAiRecipeManagement(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 관리';
      case AppLocale.japan:
        return 'AIレシピ管理';
      case AppLocale.china:
        return 'AI食谱管理';
      case AppLocale.usa:
        return 'AI Recipe Management';
      case AppLocale.euro:
        return 'AI Recipe Management';
      case AppLocale.vietnam:
        return 'Quản lý công thức AI';
    }
  }

  static String getSavedAiRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '저장된 AI 레시피';
      case AppLocale.japan:
        return '保存されたAIレシピ';
      case AppLocale.china:
        return '已保存的AI食谱';
      case AppLocale.usa:
        return 'Saved AI Recipes';
      case AppLocale.euro:
        return 'Saved AI Recipes';
      case AppLocale.vietnam:
        return 'Công thức AI đã lưu';
    }
  }

  static String getAiRecipeList(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 목록';
      case AppLocale.japan:
        return 'AIレシピリスト';
      case AppLocale.china:
        return 'AI食谱列表';
      case AppLocale.usa:
        return 'AI Recipe List';
      case AppLocale.euro:
        return 'AI Recipe List';
      case AppLocale.vietnam:
        return 'Danh sách công thức AI';
    }
  }

  static String getNoSavedAiRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '저장된 AI 레시피가 없습니다';
      case AppLocale.japan:
        return '保存されたAIレシピがありません';
      case AppLocale.china:
        return '没有已保存的AI食谱';
      case AppLocale.usa:
        return 'No saved AI recipes';
      case AppLocale.euro:
        return 'No saved AI recipes';
      case AppLocale.vietnam:
        return 'Không có công thức AI đã lưu';
    }
  }

  static String getNoSavedAiRecipesDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI로 레시피를 생성하면 자동으로 저장됩니다.\n첫 번째 AI 레시피를 만들어보세요!';
      case AppLocale.japan:
        return 'AIでレシピを生成すると自動的に保存されます。\n最初のAIレシピを作ってみましょう！';
      case AppLocale.china:
        return '使用AI生成食谱时会自动保存。\n创建您的第一个AI食谱吧！';
      case AppLocale.usa:
        return 'AI-generated recipes are automatically saved.\nCreate your first AI recipe!';
      case AppLocale.euro:
        return 'AI-generated recipes are automatically saved.\nCreate your first AI recipe!';
      case AppLocale.vietnam:
        return 'Các công thức do AI tạo được tự động lưu.\\nTạo công thức AI đầu tiên của bạn!';
    }
  }

  static String getConvertToRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '일반 레시피로 변환';
      case AppLocale.japan:
        return '通常レシピに変換';
      case AppLocale.china:
        return '转换为普通食谱';
      case AppLocale.usa:
        return 'Convert to Recipe';
      case AppLocale.euro:
        return 'Convert to Recipe';
      case AppLocale.vietnam:
        return 'Chuyển đổi thành công thức';
    }
  }

  static String getConvertToRecipeDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피를 일반 레시피로 변환하여 관리할 수 있습니다';
      case AppLocale.japan:
        return 'AIレシピを通常レシピに変換して管理できます';
      case AppLocale.china:
        return '可以将AI食谱转换为普通食谱进行管理';
      case AppLocale.usa:
        return 'Convert AI recipe to regular recipe for management';
      case AppLocale.euro:
        return 'Convert AI recipe to regular recipe for management';
      case AppLocale.vietnam:
        return 'Chuyển đổi công thức AI thành công thức thông thường để quản lý';
    }
  }

  static String getAiRecipeStats(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 통계';
      case AppLocale.japan:
        return 'AIレシピ統計';
      case AppLocale.china:
        return 'AI食谱统计';
      case AppLocale.usa:
        return 'AI Recipe Stats';
      case AppLocale.euro:
        return 'AI Recipe Stats';
      case AppLocale.vietnam:
        return 'Thống kê công thức AI';
    }
  }

  static String getTotalGenerated(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총 생성된 레시피';
      case AppLocale.japan:
        return '総生成レシピ数';
      case AppLocale.china:
        return '总生成食谱数';
      case AppLocale.usa:
        return 'Total Generated';
      case AppLocale.euro:
        return 'Total Generated';
      case AppLocale.vietnam:
        return 'Tổng số đã tạo';
    }
  }

  static String getConvertedRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '변환된 레시피';
      case AppLocale.japan:
        return '変換されたレシピ';
      case AppLocale.china:
        return '已转换食谱';
      case AppLocale.usa:
        return 'Converted Recipes';
      case AppLocale.euro:
        return 'Converted Recipes';
      case AppLocale.vietnam:
        return 'Công thức đã chuyển đổi';
    }
  }

  static String getConversionRate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '변환율';
      case AppLocale.japan:
        return '変換率';
      case AppLocale.china:
        return '转换率';
      case AppLocale.usa:
        return 'Conversion Rate';
      case AppLocale.euro:
        return 'Conversion Rate';
      case AppLocale.vietnam:
        return 'Tỷ lệ chuyển đổi';
    }
  }

  static String getRecentGenerated(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '최근 생성된 레시피';
      case AppLocale.japan:
        return '最近生成されたレシピ';
      case AppLocale.china:
        return '最近生成的食谱';
      case AppLocale.usa:
        return 'Recently Generated';
      case AppLocale.euro:
        return 'Recently Generated';
      case AppLocale.vietnam:
        return 'Gần đây đã tạo';
    }
  }

  static String getFilterByCuisine(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '요리 스타일별 필터';
      case AppLocale.japan:
        return '料理スタイル別フィルター';
      case AppLocale.china:
        return '按烹饪风格筛选';
      case AppLocale.usa:
        return 'Filter by Cuisine';
      case AppLocale.euro:
        return 'Filter by Cuisine';
      case AppLocale.vietnam:
        return 'Lọc theo ẩm thực';
    }
  }

  static String getSearchAiRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 검색';
      case AppLocale.japan:
        return 'AIレシピ検索';
      case AppLocale.china:
        return '搜索AI食谱';
      case AppLocale.usa:
        return 'Search AI Recipes';
      case AppLocale.euro:
        return 'Search AI Recipes';
      case AppLocale.vietnam:
        return 'Tìm kiếm công thức AI';
    }
  }

  static String getSearchAiRecipesHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피명, 설명, 요리 스타일로 검색';
      case AppLocale.japan:
        return 'レシピ名、説明、料理スタイルで検索';
      case AppLocale.china:
        return '按食谱名称、描述、烹饪风格搜索';
      case AppLocale.usa:
        return 'Search by recipe name, description, or cuisine style';
      case AppLocale.euro:
        return 'Search by recipe name, description, or cuisine style';
      case AppLocale.vietnam:
        return 'Tìm kiếm theo tên công thức, mô tả hoặc phong cách ẩm thực';
    }
  }

  static String getDeleteAiRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 삭제';
      case AppLocale.japan:
        return 'AIレシピ削除';
      case AppLocale.china:
        return '删除AI食谱';
      case AppLocale.usa:
        return 'Delete AI Recipe';
      case AppLocale.euro:
        return 'Delete AI Recipe';
      case AppLocale.vietnam:
        return 'Xóa công thức AI';
    }
  }

  static String getDeleteAiRecipeConfirm(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이 AI 레시피를 삭제하시겠습니까?';
      case AppLocale.japan:
        return 'このAIレシピを削除しますか？';
      case AppLocale.china:
        return '确定要删除这个AI食谱吗？';
      case AppLocale.usa:
        return 'Are you sure you want to delete this AI recipe?';
      case AppLocale.euro:
        return 'Are you sure you want to delete this AI recipe?';
      case AppLocale.vietnam:
        return 'Bạn có chắc chắn muốn xóa công thức AI này không?';
    }
  }

  static String getAiRecipeDeleted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피가 삭제되었습니다';
      case AppLocale.japan:
        return 'AIレシピが削除されました';
      case AppLocale.china:
        return 'AI食谱已删除';
      case AppLocale.usa:
        return 'AI recipe has been deleted';
      case AppLocale.euro:
        return 'AI recipe has been deleted';
      case AppLocale.vietnam:
        return 'Công thức AI đã bị xóa';
    }
  }

  static String getAiRecipeSaved(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피가 자동으로 저장되었습니다';
      case AppLocale.japan:
        return 'AIレシピが自動的に保存されました';
      case AppLocale.china:
        return 'AI食谱已自动保存';
      case AppLocale.usa:
        return 'AI recipe has been automatically saved';
      case AppLocale.euro:
        return 'AI recipe has been automatically saved';
      case AppLocale.vietnam:
        return 'Công thức AI đã được tự động lưu';
    }
  }

  static String getAiRecipeDetail(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 상세';
      case AppLocale.japan:
        return 'AIレシピ詳細';
      case AppLocale.china:
        return 'AI食谱详情';
      case AppLocale.usa:
        return 'AI Recipe Detail';
      case AppLocale.euro:
        return 'AI Recipe Detail';
      case AppLocale.vietnam:
        return 'Chi tiết công thức AI';
    }
  }

  static String getIngredientsAnalysis(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 분석';
      case AppLocale.japan:
        return '材料分析';
      case AppLocale.china:
        return '材料分析';
      case AppLocale.usa:
        return 'Ingredients Analysis';
      case AppLocale.euro:
        return 'Ingredients Analysis';
      case AppLocale.vietnam:
        return 'Phân tích nguyên liệu';
    }
  }

  static String getCostInfo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원가 정보';
      case AppLocale.japan:
        return '原価情報';
      case AppLocale.china:
        return '成本信息';
      case AppLocale.usa:
        return 'Cost Information';
      case AppLocale.euro:
        return 'Cost Information';
      case AppLocale.vietnam:
        return 'Thông tin chi phí';
    }
  }

  static String getCookingInstructions(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '조리 방법';
      case AppLocale.japan:
        return '調理方法';
      case AppLocale.china:
        return '烹饪方法';
      case AppLocale.usa:
        return 'Cooking Instructions';
      case AppLocale.euro:
        return 'Cooking Instructions';
      case AppLocale.vietnam:
        return 'Hướng dẫn nấu ăn';
    }
  }

  static String getIngredientAvailability(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 가용성';
      case AppLocale.japan:
        return '材料の可用性';
      case AppLocale.china:
        return '材料可用性';
      case AppLocale.usa:
        return 'Ingredient Availability';
      case AppLocale.euro:
        return 'Ingredient Availability';
      case AppLocale.vietnam:
        return 'Tính sẵn có của nguyên liệu';
    }
  }

  static String getTotalCost(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총 원가';
      case AppLocale.japan:
        return '総原価';
      case AppLocale.china:
        return '总成本';
      case AppLocale.usa:
        return 'Total Cost';
      case AppLocale.euro:
        return 'Total Cost';
      case AppLocale.vietnam:
        return 'Tổng chi phí';
    }
  }

  static String getAiRecipeStandard(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 기준';
      case AppLocale.japan:
        return 'AIレシピ基準';
      case AppLocale.china:
        return 'AI食谱标准';
      case AppLocale.usa:
        return 'AI Recipe Standard';
      case AppLocale.euro:
        return 'AI Recipe Standard';
      case AppLocale.vietnam:
        return 'Tiêu chuẩn công thức AI';
    }
  }

  static String getAddIngredientRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이 재료를 추가해야 합니다';
      case AppLocale.japan:
        return 'この材料を追加する必要があります';
      case AppLocale.china:
        return '需要添加这种材料';
      case AppLocale.usa:
        return 'This ingredient needs to be added';
      case AppLocale.euro:
        return 'This ingredient needs to be added';
      case AppLocale.vietnam:
        return 'Nguyên liệu này cần được thêm';
    }
  }

  static String getLoadingAiRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피를 불러오는 중...';
      case AppLocale.japan:
        return 'AIレシピを読み込み中...';
      case AppLocale.china:
        return '正在加载AI食谱...';
      case AppLocale.usa:
        return 'Loading AI recipe...';
      case AppLocale.euro:
        return 'Loading AI recipe...';
      case AppLocale.vietnam:
        return 'Đang tải công thức AI...';
    }
  }

  static String getAiRecipeNotFound(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피를 찾을 수 없습니다';
      case AppLocale.japan:
        return 'AIレシピが見つかりません';
      case AppLocale.china:
        return '找不到AI食谱';
      case AppLocale.usa:
        return 'AI recipe not found';
      case AppLocale.euro:
        return 'AI recipe not found';
      case AppLocale.vietnam:
        return 'Không tìm thấy công thức AI';
    }
  }

  static String getConversionSuccess(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '일반 레시피로 변환되었습니다';
      case AppLocale.japan:
        return '通常レシピに変換されました';
      case AppLocale.china:
        return '已转换为普通食谱';
      case AppLocale.usa:
        return 'Converted to regular recipe';
      case AppLocale.euro:
        return 'Converted to regular recipe';
      case AppLocale.vietnam:
        return 'Đã chuyển đổi thành công thức thông thường';
    }
  }

  static String getConversionFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '변환에 실패했습니다';
      case AppLocale.japan:
        return '変換に失敗しました';
      case AppLocale.china:
        return '转换失败';
      case AppLocale.usa:
        return 'Conversion failed';
      case AppLocale.euro:
        return 'Conversion failed';
      case AppLocale.vietnam:
        return 'Chuyển đổi thất bại';
    }
  }

  /// AI 판매 분석 관련
  static String getAiSalesAnalysis(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 판매 분석';
      case AppLocale.japan:
        return 'AI販売分析';
      case AppLocale.china:
        return 'AI销售分析';
      case AppLocale.usa:
        return 'AI Sales Analysis';
      case AppLocale.euro:
        return 'AI Sales Analysis';
      case AppLocale.vietnam:
        return 'Phân tích bán hàng AI';
    }
  }

  static String getAiSalesAnalysisTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 판매 분석 결과';
      case AppLocale.japan:
        return 'AI販売分析結果';
      case AppLocale.china:
        return 'AI销售分析结果';
      case AppLocale.usa:
        return 'AI Sales Analysis Results';
      case AppLocale.euro:
        return 'AI Sales Analysis Results';
      case AppLocale.vietnam:
        return 'Kết quả phân tích bán hàng AI';
    }
  }

  static String getAiSalesAnalysisDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피의 판매 전략을 AI가 분석하여 최적의 가격과 마케팅 방안을 제안합니다.';
      case AppLocale.japan:
        return 'AIがレシピの販売戦略を分析し、最適な価格とマーケティング方法を提案します。';
      case AppLocale.china:
        return 'AI分析食谱的销售策略，建议最优价格和营销方案。';
      case AppLocale.usa:
        return 'AI analyzes recipe sales strategies and suggests optimal pricing and marketing approaches.';
      case AppLocale.euro:
        return 'AI analyzes recipe sales strategies and suggests optimal pricing and marketing approaches.';
      case AppLocale.vietnam:
        return 'AI phân tích chiến lược bán hàng công thức và đề xuất giá cả tối ưu và cách tiếp thị.';
    }
  }

  static String getAiSalesAnalysisDialogTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 판매 분석';
      case AppLocale.japan:
        return 'AI販売分析';
      case AppLocale.china:
        return 'AI销售分析';
      case AppLocale.usa:
        return 'AI Sales Analysis';
      case AppLocale.euro:
        return 'AI Sales Analysis';
      case AppLocale.vietnam:
        return 'Phân tích bán hàng AI';
    }
  }

  static String getAiSalesAnalysisDialogMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 판매 분석은 광고 시청 후 진행해드려요!';
      case AppLocale.japan:
        return 'AI販売分析は広告視聴後に進めさせていただきます！';
      case AppLocale.china:
        return 'AI销售分析将在观看广告后为您进行！';
      case AppLocale.usa:
        return 'AI sales analysis will proceed after watching an ad!';
      case AppLocale.euro:
        return 'AI sales analysis will proceed after watching an ad!';
      case AppLocale.vietnam:
        return 'Phân tích bán hàng AI sẽ tiến hành sau khi xem quảng cáo!';
    }
  }

  static String getAiSalesAnalysisDialogDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고 시청 후 AI가 레시피의 판매 전략을 분석하여 최적의 가격과 마케팅 방안을 제안합니다.';
      case AppLocale.japan:
        return '広告視聴後、AIがレシピの販売戦略を分析し、最適な価格とマーケティング方法を提案します。';
      case AppLocale.china:
        return '观看广告后，AI将分析食谱的销售策略，建议最优价格和营销方案。';
      case AppLocale.usa:
        return 'After watching an ad, AI will analyze the recipe\'s sales strategy and suggest optimal pricing and marketing approaches.';
      case AppLocale.euro:
        return 'After watching an ad, AI will analyze the recipe\'s sales strategy and suggest optimal pricing and marketing approaches.';
      case AppLocale.vietnam:
        return 'Sau khi xem quảng cáo, AI sẽ phân tích chiến lược bán hàng của công thức và đề xuất giá cả tối ưu và cách tiếp thị.';
    }
  }

  static String getOptimalPriceAnalysis(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '💰 최적 판매가 분석';
      case AppLocale.japan:
        return '💰 最適販売価格分析';
      case AppLocale.china:
        return '💰 最优销售价格分析';
      case AppLocale.usa:
        return '💰 Optimal Price Analysis';
      case AppLocale.euro:
        return '💰 Optimal Price Analysis';
      case AppLocale.vietnam:
        return '💰 Phân tích giá tối ưu';
    }
  }

  static String getMarketingPoints(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '📢 마케팅 포인트';
      case AppLocale.japan:
        return '📢 マーケティングポイント';
      case AppLocale.china:
        return '📢 营销要点';
      case AppLocale.usa:
        return '📢 Marketing Points';
      case AppLocale.euro:
        return '📢 Marketing Points';
      case AppLocale.vietnam:
        return '📢 Điểm tiếp thị';
    }
  }

  static String getServingGuidance(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '🎯 서빙 가이드';
      case AppLocale.japan:
        return '🎯 サービスガイド';
      case AppLocale.china:
        return '🎯 服务指南';
      case AppLocale.usa:
        return '🎯 Serving Guidance';
      case AppLocale.euro:
        return '🎯 Serving Guidance';
      case AppLocale.vietnam:
        return '🎯 Hướng dẫn phục vụ';
    }
  }

  static String getBusinessInsights(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '💡 비즈니스 인사이트';
      case AppLocale.japan:
        return '💡 ビジネスインサイト';
      case AppLocale.china:
        return '💡 商业洞察';
      case AppLocale.usa:
        return '💡 Business Insights';
      case AppLocale.euro:
        return '💡 Business Insights';
      case AppLocale.vietnam:
        return '💡 Thông tin kinh doanh';
    }
  }

  static String getRecommendedPrice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추천 판매가';
      case AppLocale.japan:
        return '推奨販売価格';
      case AppLocale.china:
        return '推荐销售价格';
      case AppLocale.usa:
        return 'Recommended Price';
      case AppLocale.euro:
        return 'Recommended Price';
      case AppLocale.vietnam:
        return 'Giá đề xuất';
    }
  }

  static String getTargetMarginRate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '목표 원가율';
      case AppLocale.japan:
        return '目標原価率';
      case AppLocale.china:
        return '目标成本率';
      case AppLocale.usa:
        return 'Target Cost Ratio';
      case AppLocale.euro:
        return 'Target Cost Ratio';
      case AppLocale.vietnam:
        return 'Tỷ lệ chi phí mục tiêu';
    }
  }

  static String getProfitPerServing(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '1인분당 예상 수익';
      case AppLocale.japan:
        return '1人前あたりの予想収益';
      case AppLocale.china:
        return '每份预期收益';
      case AppLocale.usa:
        return 'Profit per Serving';
      case AppLocale.euro:
        return 'Profit per Serving';
      case AppLocale.vietnam:
        return 'Lợi nhuận mỗi phần ăn';
    }
  }

  static String getTargetCustomers(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '타겟 고객층';
      case AppLocale.japan:
        return 'ターゲット顧客層';
      case AppLocale.china:
        return '目标客户群';
      case AppLocale.usa:
        return 'Target Customers';
      case AppLocale.euro:
        return 'Target Customers';
      case AppLocale.vietnam:
        return 'Khách hàng mục tiêu';
    }
  }

  static String getOptimalSellingSeason(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '최적 판매 시기';
      case AppLocale.japan:
        return '最適販売時期';
      case AppLocale.china:
        return '最佳销售时机';
      case AppLocale.usa:
        return 'Optimal Selling Season';
      case AppLocale.euro:
        return 'Optimal Selling Season';
      case AppLocale.vietnam:
        return 'Mùa bán hàng tối ưu';
    }
  }

  static String getUniqueSellingPoints(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '고유한 판매 포인트';
      case AppLocale.japan:
        return '独自の販売ポイント';
      case AppLocale.china:
        return '独特销售卖点';
      case AppLocale.usa:
        return 'Unique Selling Points';
      case AppLocale.euro:
        return 'Unique Selling Points';
      case AppLocale.vietnam:
        return 'Điểm bán hàng độc đáo';
    }
  }

  static String getCompetitiveAdvantages(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '경쟁 우위';
      case AppLocale.japan:
        return '競争優位';
      case AppLocale.china:
        return '竞争优势';
      case AppLocale.usa:
        return 'Competitive Advantages';
      case AppLocale.euro:
        return 'Competitive Advantages';
      case AppLocale.vietnam:
        return 'Lợi thế cạnh tranh';
    }
  }

  static String getOpeningScript(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '첫 인사 멘트';
      case AppLocale.japan:
        return '最初の挨拶メッセージ';
      case AppLocale.china:
        return '开场白';
      case AppLocale.usa:
        return 'Opening Script';
      case AppLocale.euro:
        return 'Opening Script';
      case AppLocale.vietnam:
        return 'Kịch bản mở đầu';
    }
  }

  static String getRecipeDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 설명';
      case AppLocale.japan:
        return 'レシピ説明';
      case AppLocale.china:
        return '食谱说明';
      case AppLocale.usa:
        return 'Recipe Description';
      case AppLocale.euro:
        return 'Recipe Description';
      case AppLocale.vietnam:
        return 'Mô tả công thức';
    }
  }

  static String getPriceJustification(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격 설명';
      case AppLocale.japan:
        return '価格説明';
      case AppLocale.china:
        return '价格说明';
      case AppLocale.usa:
        return 'Price Justification';
      case AppLocale.euro:
        return 'Price Justification';
      case AppLocale.vietnam:
        return 'Biện minh giá';
    }
  }

  static String getUpsellingTips(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추가 판매 팁';
      case AppLocale.japan:
        return '追加販売のコツ';
      case AppLocale.china:
        return '追加销售技巧';
      case AppLocale.usa:
        return 'Upselling Tips';
      case AppLocale.euro:
        return 'Upselling Tips';
      case AppLocale.vietnam:
        return 'Mẹo bán thêm';
    }
  }

  static String getCostEfficiency(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원가 효율성';
      case AppLocale.japan:
        return '原価効率性';
      case AppLocale.china:
        return '成本效率';
      case AppLocale.usa:
        return 'Cost Efficiency';
      case AppLocale.euro:
        return 'Cost Efficiency';
      case AppLocale.vietnam:
        return 'Hiệu quả chi phí';
    }
  }

  static String getProfitabilityTips(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수익성 향상 팁';
      case AppLocale.japan:
        return '収益性向上のコツ';
      case AppLocale.china:
        return '盈利能力提升技巧';
      case AppLocale.usa:
        return 'Profitability Tips';
      case AppLocale.euro:
        return 'Profitability Tips';
      case AppLocale.vietnam:
        return 'Mẹo sinh lợi';
    }
  }

  static String getRiskFactors(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '주의 요소';
      case AppLocale.japan:
        return '注意要素';
      case AppLocale.china:
        return '注意事项';
      case AppLocale.usa:
        return 'Risk Factors';
      case AppLocale.euro:
        return 'Risk Factors';
      case AppLocale.vietnam:
        return 'Yếu tố rủi ro';
    }
  }

  static String getClose(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '닫기';
      case AppLocale.japan:
        return '閉じる';
      case AppLocale.china:
        return '关闭';
      case AppLocale.usa:
        return 'Close';
      case AppLocale.euro:
        return 'Close';
      case AppLocale.vietnam:
        return 'Đóng';
    }
  }

  static String getAnalyzeWithAi(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI로 분석하기';
      case AppLocale.japan:
        return 'AIで分析';
      case AppLocale.china:
        return 'AI分析';
      case AppLocale.usa:
        return 'Analyze with AI';
      case AppLocale.euro:
        return 'Analyze with AI';
      case AppLocale.vietnam:
        return 'Phân tích với AI';
    }
  }

  static String getAnalyzing(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '분석 중...';
      case AppLocale.japan:
        return '分析中...';
      case AppLocale.china:
        return '分析中...';
      case AppLocale.usa:
        return 'Analyzing...';
      case AppLocale.euro:
        return 'Analyzing...';
      case AppLocale.vietnam:
        return 'Đang phân tích...';
    }
  }

  static String getAnalysisFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '분석 실패';
      case AppLocale.japan:
        return '分析失敗';
      case AppLocale.china:
        return '分析失败';
      case AppLocale.usa:
        return 'Analysis Failed';
      case AppLocale.euro:
        return 'Analysis Failed';
      case AppLocale.vietnam:
        return 'Phân tích thất bại';
    }
  }

  static String getAnalysisFailedMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 분석에 실패했습니다. 다시 시도해주세요.';
      case AppLocale.japan:
        return 'AI分析に失敗しました。再試行してください。';
      case AppLocale.china:
        return 'AI分析失败，请重试。';
      case AppLocale.usa:
        return 'AI analysis failed. Please try again.';
      case AppLocale.euro:
        return 'AI analysis failed. Please try again.';
      case AppLocale.vietnam:
        return 'Phân tích AI thất bại. Vui lòng thử lại.';
    }
  }

  static String getAnalysisResultNotFound(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '분석 결과를 가져올 수 없습니다';
      case AppLocale.japan:
        return '分析結果を取得できません';
      case AppLocale.china:
        return '无法获取分析结果';
      case AppLocale.usa:
        return 'Unable to retrieve analysis results';
      case AppLocale.euro:
        return 'Unable to retrieve analysis results';
      case AppLocale.vietnam:
        return 'Không thể lấy kết quả phân tích';
    }
  }

  static String getAnalysisError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '분석 중 오류가 발생했습니다';
      case AppLocale.japan:
        return '分析中にエラーが発生しました';
      case AppLocale.china:
        return '分析时发生错误';
      case AppLocale.usa:
        return 'An error occurred during analysis';
      case AppLocale.euro:
        return 'An error occurred during analysis';
      case AppLocale.vietnam:
        return 'Đã xảy ra lỗi trong quá trình phân tích';
    }
  }

  static String getSpecialRequest(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '특별 요청사항';
      case AppLocale.japan:
        return '特別なリクエスト';
      case AppLocale.china:
        return '特殊要求';
      case AppLocale.usa:
        return 'Special Request';
      case AppLocale.euro:
        return 'Special Request';
      case AppLocale.vietnam:
        return 'Yêu cầu đặc biệt';
    }
  }

  static String getSpecialRequestHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '예: 고급 레스토랑에 맞는 가격 전략, 특정 고객층 타겟팅 등';
      case AppLocale.japan:
        return '例: 高級レストランに適した価格戦略、特定顧客層のターゲティングなど';
      case AppLocale.china:
        return '例：适合高级餐厅的价格策略、特定客户群定位等';
      case AppLocale.usa:
        return 'e.g., Premium restaurant pricing strategy, specific customer targeting, etc.';
      case AppLocale.euro:
        return 'e.g., Premium restaurant pricing strategy, specific customer targeting, etc.';
      case AppLocale.vietnam:
        return 'VD: Chiến lược giá nhà hàng cao cấp, nhắm mục tiêu khách hàng cụ thể, v.v.';
    }
  }

  static String getStartAnalysis(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '분석 시작';
      case AppLocale.japan:
        return '分析開始';
      case AppLocale.china:
        return '开始分析';
      case AppLocale.usa:
        return 'Start Analysis';
      case AppLocale.euro:
        return 'Start Analysis';
      case AppLocale.vietnam:
        return 'Bắt đầu phân tích';
    }
  }

  /// AI 탭 라벨
  static String getAi(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI';
      case AppLocale.japan:
        return 'AI';
      case AppLocale.china:
        return 'AI';
      case AppLocale.usa:
        return 'AI';
      case AppLocale.euro:
        return 'AI';
      case AppLocale.vietnam:
        return 'AI';
    }
  }

  /// AI 레시피 변환 상태
  static String getConverted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '변환됨';
      case AppLocale.japan:
        return '変換済み';
      case AppLocale.china:
        return '已转换';
      case AppLocale.usa:
        return 'Converted';
      case AppLocale.euro:
        return 'Converted';
      case AppLocale.vietnam:
        return 'Đã chuyển đổi';
    }
  }

  /// AI 탭바 페이지 관련 텍스트
  static String getAiRecipeGenerationTab(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 생성';
      case AppLocale.japan:
        return 'AIレシピ生成';
      case AppLocale.china:
        return 'AI食谱生成';
      case AppLocale.usa:
        return 'AI Recipe Generation';
      case AppLocale.euro:
        return 'AI Recipe Generation';
      case AppLocale.vietnam:
        return 'Tạo công thức AI';
    }
  }

  /// AI 레시피 생성 다이얼로그 텍스트
  static String getAiRecipeDialogTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 생성';
      case AppLocale.japan:
        return 'AIレシピ生成';
      case AppLocale.china:
        return 'AI食谱生成';
      case AppLocale.usa:
        return 'AI Recipe Generation';
      case AppLocale.euro:
        return 'AI Recipe Generation';
      case AppLocale.vietnam:
        return 'Tạo công thức AI';
    }
  }

  static String getAiRecipeDialogMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 레시피 생성은 광고 시청 후 진행해드려요!';
      case AppLocale.japan:
        return 'AIレシピ生成は広告視聴後に進めさせていただきます！';
      case AppLocale.china:
        return 'AI食谱生成将在观看广告后为您进行！';
      case AppLocale.usa:
        return 'AI recipe generation will proceed after watching an ad!';
      case AppLocale.euro:
        return 'AI recipe generation will proceed after watching an ad!';
      case AppLocale.vietnam:
        return 'Tạo công thức AI sẽ tiến hành sau khi xem quảng cáo!';
    }
  }

  static String getAiRecipeDialogDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고 시청 후 AI가 창의적인 레시피를 생성합니다.';
      case AppLocale.japan:
        return '広告視聴後、AIが創造的なレシピを生成します。';
      case AppLocale.china:
        return '观看广告后，AI将生成创意食谱。';
      case AppLocale.usa:
        return 'After watching an ad, AI will generate creative recipes.';
      case AppLocale.euro:
        return 'After watching an ad, AI will generate creative recipes.';
      case AppLocale.vietnam:
        return 'Sau khi xem quảng cáo, AI sẽ tạo các công thức sáng tạo.';
    }
  }

  static String getKoreanStyleRecipeDialogDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고 시청 후 AI가 한식 스타일의 레시피를 생성합니다.';
      case AppLocale.japan:
        return '広告視聴後、AIが韓国料理スタイルのレシピを生成します。';
      case AppLocale.china:
        return '观看广告后，AI将生成韩餐风格的食谱。';
      case AppLocale.usa:
        return 'After watching an ad, AI will generate Korean style recipes.';
      case AppLocale.euro:
        return 'After watching an ad, AI will generate Korean style recipes.';
      case AppLocale.vietnam:
        return 'Sau khi xem quảng cáo, AI sẽ tạo các công thức phong cách Hàn Quốc.';
    }
  }

  static String getFusionStyleRecipeDialogDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고 시청 후 AI가 퓨전 스타일의 레시피를 생성합니다.';
      case AppLocale.japan:
        return '広告視聴後、AIがフュージョンスタイルのレシピを生成します。';
      case AppLocale.china:
        return '观看广告后，AI将生成融合风格的食谱。';
      case AppLocale.usa:
        return 'After watching an ad, AI will generate fusion style recipes.';
      case AppLocale.euro:
        return 'After watching an ad, AI will generate fusion style recipes.';
      case AppLocale.vietnam:
        return 'Sau khi xem quảng cáo, AI sẽ tạo các công thức phong cách fusion.';
    }
  }

  static String getGeminiAnalysisError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'Gemini 분석 중 오류가 발생했습니다';
      case AppLocale.japan:
        return 'Gemini分析中にエラーが発生しました';
      case AppLocale.china:
        return 'Gemini分析时发生错误';
      case AppLocale.usa:
        return 'An error occurred during Gemini analysis';
      case AppLocale.euro:
        return 'An error occurred during Gemini analysis';
      case AppLocale.vietnam:
        return 'Đã xảy ra lỗi trong quá trình phân tích Gemini';
    }
  }

  static String getConvertToRecipeTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 변환';
      case AppLocale.japan:
        return 'レシピ変換';
      case AppLocale.china:
        return '食谱转换';
      case AppLocale.usa:
        return 'Recipe Conversion';
      case AppLocale.euro:
        return 'Recipe Conversion';
      case AppLocale.vietnam:
        return 'Chuyển đổi công thức';
    }
  }

  static String getConvertToRecipeMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이 AI 레시피를 일반 레시피로 변환하여 저장하시겠습니까?';
      case AppLocale.japan:
        return 'このAIレシピを通常レシピに変換して保存しますか？';
      case AppLocale.china:
        return '您要将此AI食谱转换为普通食谱并保存吗？';
      case AppLocale.usa:
        return 'Do you want to convert and save this AI recipe as a regular recipe?';
      case AppLocale.euro:
        return 'Do you want to convert and save this AI recipe as a regular recipe?';
      case AppLocale.vietnam:
        return 'Bạn có muốn chuyển đổi và lưu công thức AI này dưới dạng công thức thông thường không?';
    }
  }

  static String getRecipeConverted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '일반 레시피로 변환되었습니다';
      case AppLocale.japan:
        return '通常レシピに変換されました';
      case AppLocale.china:
        return '已转换为普通食谱';
      case AppLocale.usa:
        return 'Converted to regular recipe';
      case AppLocale.euro:
        return 'Converted to regular recipe';
      case AppLocale.vietnam:
        return 'Đã chuyển đổi thành công thức thông thường';
    }
  }
}
