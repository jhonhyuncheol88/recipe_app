import '../app_locale.dart';

/// Recipe 관련 문자열
mixin AppStringsRecipe {
  /// 레시피 관련
  static String getAddRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 추가하기';
      case AppLocale.japan:
        return 'レシピを追加';
      case AppLocale.china:
        return '添加食谱';
      case AppLocale.usa:
        return 'Add Recipe';
      case AppLocale.euro:
        return 'Add Recipe';
      case AppLocale.vietnam:
        return 'Thêm công thức';
    }
  }

  static String getAddRecipeButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 추가';
      case AppLocale.japan:
        return 'レシピ追加';
      case AppLocale.china:
        return '添加食谱';
      case AppLocale.usa:
        return 'Add Recipe';
      case AppLocale.euro:
        return 'Add Recipe';
      case AppLocale.vietnam:
        return 'Thêm công thức';
    }
  }

  static String getRecipeName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피명';
      case AppLocale.japan:
        return 'レシピ名';
      case AppLocale.china:
        return '食谱名称';
      case AppLocale.usa:
        return 'Recipe Name';
      case AppLocale.euro:
        return 'Recipe Name';
      case AppLocale.vietnam:
        return 'Tên công thức';
    }
  }

  static String getRecipeNotFound(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 정보를 찾을 수 없습니다';
      case AppLocale.japan:
        return 'レシピ情報が見つかりません';
      case AppLocale.china:
        return '找不到食谱信息';
      case AppLocale.usa:
        return 'Recipe information not found';
      case AppLocale.euro:
        return 'Recipe information not found';
      case AppLocale.vietnam:
        return 'Không tìm thấy thông tin công thức';
    }
  }

  static String getRecipeNameNotFound(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 이름 없음';
      case AppLocale.japan:
        return 'レシピ名なし';
      case AppLocale.china:
        return '无食谱名称';
      case AppLocale.usa:
        return 'No Recipe Name';
      case AppLocale.euro:
        return 'No Recipe Name';
      case AppLocale.vietnam:
        return 'Không có tên công thức';
    }
  }

  static String getAiRecipeTotalCost(AppLocale locale) {
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

  /// 레시피 검색 관련
  static String getSearchRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 검색';
      case AppLocale.japan:
        return 'レシピ検索';
      case AppLocale.china:
        return '搜索食谱';
      case AppLocale.usa:
        return 'Search Recipe';
      case AppLocale.euro:
        return 'Search Recipe';
      case AppLocale.vietnam:
        return 'Tìm kiếm công thức';
    }
  }

  /// 레시피 삭제 관련
  static String getDeleteRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 삭제';
      case AppLocale.japan:
        return 'レシピ削除';
      case AppLocale.china:
        return '删除食谱';
      case AppLocale.usa:
        return 'Delete Recipe';
      case AppLocale.euro:
        return 'Delete Recipe';
      case AppLocale.vietnam:
        return 'Xóa công thức';
    }
  }

  static String getDeleteRecipeConfirm(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '을(를) 삭제하시겠습니까?';
      case AppLocale.japan:
        return 'を削除しますか？';
      case AppLocale.china:
        return '将被删除吗？';
      case AppLocale.usa:
        return 'will be deleted?';
      case AppLocale.euro:
        return 'will be deleted?';
      case AppLocale.vietnam:
        return 'sẽ bị xóa?';
    }
  }

  static String getDeleteSelectedRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '선택된 레시피 삭제';
      case AppLocale.japan:
        return '選択されたレシピ削除';
      case AppLocale.china:
        return '删除选中的食谱';
      case AppLocale.usa:
        return 'Delete Selected Recipes';
      case AppLocale.euro:
        return 'Delete Selected Recipes';
      case AppLocale.vietnam:
        return 'Xóa công thức đã chọn';
    }
  }

  /// 레시피 기본 정보 관련
  static String getBasicInfo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '기본 정보';
      case AppLocale.japan:
        return '基本情報';
      case AppLocale.china:
        return '基本信息';
      case AppLocale.usa:
        return 'Basic Information';
      case AppLocale.euro:
        return 'Basic Information';
      case AppLocale.vietnam:
        return 'Thông tin cơ bản';
    }
  }

  static String getRecipeNameHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피명을 입력하세요';
      case AppLocale.japan:
        return 'レシピ名を入力してください';
      case AppLocale.china:
        return '请输入食谱名称';
      case AppLocale.usa:
        return 'Enter recipe name';
      case AppLocale.euro:
        return 'Enter recipe name';
      case AppLocale.vietnam:
        return 'Nhập tên công thức';
    }
  }

  static String getRecipeNameRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피명을 입력해주세요';
      case AppLocale.japan:
        return 'レシピ名を入力してください';
      case AppLocale.china:
        return '请输入食谱名称';
      case AppLocale.usa:
        return 'Recipe name is required';
      case AppLocale.euro:
        return 'Recipe name is required';
      case AppLocale.vietnam:
        return 'Tên công thức là bắt buộc';
    }
  }

  static String getRecipeDescriptionScript(AppLocale locale) {
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

  static String getRecipeDescriptionHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피에 대한 설명을 입력하세요';
      case AppLocale.japan:
        return 'レシピについての説明を入力してください';
      case AppLocale.china:
        return '请输入食谱说明';
      case AppLocale.usa:
        return 'Enter recipe description';
      case AppLocale.euro:
        return 'Enter recipe description';
      case AppLocale.vietnam:
        return 'Nhập mô tả công thức';
    }
  }

  static String getOutputAmount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '생산량';
      case AppLocale.japan:
        return '生産量';
      case AppLocale.china:
        return '产量';
      case AppLocale.usa:
        return 'Output Amount';
      case AppLocale.euro:
        return 'Output Amount';
      case AppLocale.vietnam:
        return 'Số lượng đầu ra';
    }
  }

  static String getOutputAmountHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '생산량을 입력하세요';
      case AppLocale.japan:
        return '生産量を入力してください';
      case AppLocale.china:
        return '请输入产量';
      case AppLocale.usa:
        return 'Enter output amount';
      case AppLocale.euro:
        return 'Enter output amount';
      case AppLocale.vietnam:
        return 'Nhập số lượng đầu ra';
    }
  }

  static String getOutputAmountRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '생산량을 입력해주세요';
      case AppLocale.japan:
        return '生産量を入力してください';
      case AppLocale.china:
        return '请输入产量';
      case AppLocale.usa:
        return 'Output amount is required';
      case AppLocale.euro:
        return 'Output amount is required';
      case AppLocale.vietnam:
        return 'Số lượng đầu ra là bắt buộc';
    }
  }

  static String getOutputAmountInvalid(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '올바른 생산량을 입력해주세요';
      case AppLocale.japan:
        return '正しい生産量を入力してください';
      case AppLocale.china:
        return '请输入正确的产量';
      case AppLocale.usa:
        return 'Enter a valid output amount';
      case AppLocale.euro:
        return 'Enter a valid output amount';
      case AppLocale.vietnam:
        return 'Nhập số lượng đầu ra hợp lệ';
    }
  }

  static String getOutputUnit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '생산 단위';
      case AppLocale.japan:
        return '生産単位';
      case AppLocale.china:
        return '生产单位';
      case AppLocale.usa:
        return 'Output Unit';
      case AppLocale.euro:
        return 'Output Unit';
      case AppLocale.vietnam:
        return 'Đơn vị đầu ra';
    }
  }

  static String getOutputUnitRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '생산 단위를 선택해주세요';
      case AppLocale.japan:
        return '生産単位を選択してください';
      case AppLocale.china:
        return '请选择生产单位';
      case AppLocale.usa:
        return 'Please select output unit';
      case AppLocale.euro:
        return 'Please select output unit';
      case AppLocale.vietnam:
        return 'Vui lòng chọn đơn vị đầu ra';
    }
  }

  /// 레시피 재료 관련
  static String getRecipeIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 재료';
      case AppLocale.japan:
        return 'レシピ材料';
      case AppLocale.china:
        return '食谱材料';
      case AppLocale.usa:
        return 'Recipe Ingredients';
      case AppLocale.euro:
        return 'Recipe Ingredients';
      case AppLocale.vietnam:
        return 'Nguyên liệu công thức';
    }
  }

  static String getNoRecipeIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '등록된 재료가 없습니다.';
      case AppLocale.japan:
        return '登録された材料がありません。';
      case AppLocale.china:
        return '没有已登记的材料。';
      case AppLocale.usa:
        return 'No ingredients registered.';
      case AppLocale.euro:
        return 'No ingredients registered.';
      case AppLocale.vietnam:
        return 'Chưa có nguyên liệu nào được đăng ký.';
    }
  }

  static String getNoIngredientsSelected(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '선택된 재료가 없습니다';
      case AppLocale.japan:
        return '選択された材料がありません';
      case AppLocale.china:
        return '没有选中的材料';
      case AppLocale.usa:
        return 'No ingredients selected';
      case AppLocale.euro:
        return 'No ingredients selected';
      case AppLocale.vietnam:
        return 'No đã chọn';
    }
  }

  /// 레시피 태그 관련
  static String getRecipeTags(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 태그';
      case AppLocale.japan:
        return 'レシピタグ';
      case AppLocale.china:
        return '食谱标签';
      case AppLocale.usa:
        return 'Recipe Tags';
      case AppLocale.euro:
        return 'Recipe Tags';
      case AppLocale.vietnam:
        return 'Thẻ công thức';
    }
  }

  /// 레시피 저장 관련
  static String getSaveRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 저장';
      case AppLocale.japan:
        return 'レシピ保存';
      case AppLocale.china:
        return '保存食谱';
      case AppLocale.usa:
        return 'Save Recipe';
      case AppLocale.euro:
        return 'Save Recipe';
      case AppLocale.vietnam:
        return 'Lưu công thức';
    }
  }

  static String getRecipeAdded(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피가 성공적으로 추가되었습니다';
      case AppLocale.japan:
        return 'レシピが正常に追加されました';
      case AppLocale.china:
        return '食谱已成功添加';
      case AppLocale.usa:
        return 'Recipe added successfully';
      case AppLocale.euro:
        return 'Recipe added successfully';
      case AppLocale.vietnam:
        return 'Công thức đã được thêm thành công';
    }
  }

  static String getRecipeAddError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 추가에 실패했습니다';
      case AppLocale.japan:
        return 'レシピ追加に失敗しました';
      case AppLocale.china:
        return '添加食谱失败';
      case AppLocale.usa:
        return 'Failed to add recipe';
      case AppLocale.euro:
        return 'Failed to add recipe';
      case AppLocale.vietnam:
        return 'Không thể thêm công thức';
    }
  }

  static String getRecipeUpdated(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피가 성공적으로 수정되었습니다';
      case AppLocale.japan:
        return 'レシピが正常に更新されました';
      case AppLocale.china:
        return '食谱已成功修改';
      case AppLocale.usa:
        return 'Recipe updated successfully';
      case AppLocale.euro:
        return 'Recipe updated successfully';
      case AppLocale.vietnam:
        return 'Công thức đã được cập nhật thành công';
    }
  }

  static String getRecipeUpdateError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 수정에 실패했습니다';
      case AppLocale.japan:
        return 'レシピ更新に失敗しました';
      case AppLocale.china:
        return '修改食谱失败';
      case AppLocale.usa:
        return 'Failed to update recipe';
      case AppLocale.euro:
        return 'Failed to update recipe';
      case AppLocale.vietnam:
        return 'Không thể cập nhật công thức';
    }
  }

  /// 레시피 수정 관련
  static String getEditRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 수정하기';
      case AppLocale.japan:
        return 'レシピ編集';
      case AppLocale.china:
        return '编辑食谱';
      case AppLocale.usa:
        return 'Edit Recipe';
      case AppLocale.euro:
        return 'Edit Recipe';
      case AppLocale.vietnam:
        return 'Chỉnh sửa công thức';
    }
  }

  /// 레시피(탭/바텀탭 라벨용 복수형)
  static String getRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피';
      case AppLocale.japan:
        return 'レシピ';
      case AppLocale.china:
        return '食谱';
      case AppLocale.usa:
        return 'Recipes';
      case AppLocale.euro:
        return 'Recipes';
      case AppLocale.vietnam:
        return 'Công thức';
    }
  }

  static String getSettings(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '설정';
      case AppLocale.japan:
        return '設定';
      case AppLocale.china:
        return '设置';
      case AppLocale.usa:
        return 'Settings';
      case AppLocale.euro:
        return 'Settings';
      case AppLocale.vietnam:
        return 'Cài đặt';
    }
  }

  /// 레시피 목록 비어있을 때
  static String getNoRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피가 없습니다';
      case AppLocale.japan:
        return 'レシピがありません';
      case AppLocale.china:
        return '没有食谱';
      case AppLocale.usa:
        return 'No recipes';
      case AppLocale.euro:
        return 'No recipes';
      case AppLocale.vietnam:
        return 'Không có công thức';
    }
  }

  static String getNoRecipesDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '첫 번째 레시피를 만들어보세요!\n재료를 추가하고 원가를 계산해보세요.';
      case AppLocale.japan:
        return '最初のレシピを作ってみましょう！\n材料を追加して原価を計算してみてください。';
      case AppLocale.china:
        return '创建第一个食谱吧！\n添加食材并计算成本。';
      case AppLocale.usa:
        return 'Create your first recipe!\nAdd ingredients and calculate the cost.';
      case AppLocale.euro:
        return 'Create your first recipe!\nAdd ingredients and calculate the cost.';
      case AppLocale.vietnam:
        return 'Tạo công thức đầu tiên của bạn!\\nThêm nguyên liệu và tính toán chi phí.';
    }
  }

  /// 기본 태그 이름 - 레시피 태그
  static String getRecipeTagKorean(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '한식';
      case AppLocale.japan:
        return '韓国料理';
      case AppLocale.china:
        return '韩餐';
      case AppLocale.usa:
        return 'Korean';
      case AppLocale.euro:
        return 'Korean';
      case AppLocale.vietnam:
        return 'Hàn Quốc';
    }
  }

  static String getRecipeTagChinese(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '중식';
      case AppLocale.japan:
        return '中華料理';
      case AppLocale.china:
        return '中餐';
      case AppLocale.usa:
        return 'Chinese';
      case AppLocale.euro:
        return 'Chinese';
      case AppLocale.vietnam:
        return 'Trung Quốc';
    }
  }

  static String getRecipeTagJapanese(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '일식';
      case AppLocale.japan:
        return '和食';
      case AppLocale.china:
        return '日餐';
      case AppLocale.usa:
        return 'Japanese';
      case AppLocale.euro:
        return 'Japanese';
      case AppLocale.vietnam:
        return 'Nhật Bản';
    }
  }

  static String getRecipeTagWestern(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '양식';
      case AppLocale.japan:
        return '洋食';
      case AppLocale.china:
        return '西餐';
      case AppLocale.usa:
        return 'Western';
      case AppLocale.euro:
        return 'Western';
      case AppLocale.vietnam:
        return 'Phương Tây';
    }
  }

  static String getRecipeTagItalian(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이탈리안';
      case AppLocale.japan:
        return 'イタリアン';
      case AppLocale.china:
        return '意大利菜';
      case AppLocale.usa:
        return 'Italian';
      case AppLocale.euro:
        return 'Italian';
      case AppLocale.vietnam:
        return 'Ý';
    }
  }

  static String getRecipeTagMexican(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '멕시칸';
      case AppLocale.japan:
        return 'メキシカン';
      case AppLocale.china:
        return '墨西哥菜';
      case AppLocale.usa:
        return 'Mexican';
      case AppLocale.euro:
        return 'Mexican';
      case AppLocale.vietnam:
        return 'Mexico';
    }
  }

  static String getRecipeTagThai(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '태국음식';
      case AppLocale.japan:
        return 'タイ料理';
      case AppLocale.china:
        return '泰国菜';
      case AppLocale.usa:
        return 'Thai';
      case AppLocale.euro:
        return 'Thai';
      case AppLocale.vietnam:
        return 'Thái Lan';
    }
  }

  static String getRecipeTagIndian(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '인도음식';
      case AppLocale.japan:
        return 'インド料理';
      case AppLocale.china:
        return '印度菜';
      case AppLocale.usa:
        return 'Indian';
      case AppLocale.euro:
        return 'Indian';
      case AppLocale.vietnam:
        return 'Ấn Độ';
    }
  }

  static String getRecipeTagVietnamese(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '베트남음식';
      case AppLocale.japan:
        return 'ベトナム料理';
      case AppLocale.china:
        return '越南菜';
      case AppLocale.usa:
        return 'Vietnamese';
      case AppLocale.euro:
        return 'Vietnamese';
      case AppLocale.vietnam:
        return 'Việt Nam';
    }
  }

  static String getRecipeTagFusion(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '퓨전';
      case AppLocale.japan:
        return 'フュージョン';
      case AppLocale.china:
        return '融合菜';
      case AppLocale.usa:
        return 'Fusion';
      case AppLocale.euro:
        return 'Fusion';
      case AppLocale.vietnam:
        return 'Kết hợp';
    }
  }

  static String getSelectTagsDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료를 분류할 태그를 선택하세요';
      case AppLocale.vietnam:
        return 'Chọn thẻ để phân loại nguyên liệu';
      default:
        return 'Select tags to categorize the ingredient';
    }
  }

  static String getUpdateIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 수정';
      case AppLocale.vietnam:
        return 'Cập nhật nguyên liệu';
      default:
        return 'Update Ingredient';
    }
  }

  static String getIngredientUpdatedSuccessfully(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료가 성공적으로 수정되었습니다';
      case AppLocale.vietnam:
        return 'Nguyên liệu đã được cập nhật thành công';
      default:
        return 'Ingredient updated successfully';
    }
  }

  static String getIngredientUpdateFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 수정에 실패했습니다';
      case AppLocale.vietnam:
        return 'Không thể cập nhật nguyên liệu';
      default:
        return 'Failed to update ingredient';
    }
  }

  static String getIngredientDeleted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료를 삭제했습니다';
      case AppLocale.japan:
        return '材料を削除しました';
      case AppLocale.china:
        return '已删除材料';
      case AppLocale.usa:
        return 'Ingredient deleted';
      case AppLocale.euro:
        return 'Ingredient deleted';
      case AppLocale.vietnam:
        return 'Nguyên liệu đã được xóa';
    }
  }

  /// 선택된 레시피 삭제 확인 메시지
  static String getDeleteSelectedRecipesConfirm(AppLocale locale, int count) {
    switch (locale) {
      case AppLocale.korea:
        return '$count개의 레시피를 삭제하시겠습니까?';
      case AppLocale.japan:
        return '$count個のレシピを削除しますか？';
      case AppLocale.china:
        return '确定要删除$count个食谱吗？';
      case AppLocale.usa:
        return 'Are you sure you want to delete $count recipes?';
      case AppLocale.euro:
        return 'Are you sure you want to delete $count recipes?';
      case AppLocale.vietnam:
        return 'Bạn có chắc chắn muốn xóa $count công thức không?';
    }
  }

  /// 레시피 바로보기 관련
  static String getViewRecipeQuick(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피로 바로보기';
      case AppLocale.japan:
        return 'レシピで確認';
      case AppLocale.china:
        return '快速查看食谱';
      case AppLocale.usa:
        return 'View Recipe Quick';
      case AppLocale.euro:
        return 'View Recipe Quick';
      case AppLocale.vietnam:
        return 'Xem công thức nhanh';
    }
  }

  static String getRecipeMemo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 메모';
      case AppLocale.japan:
        return 'レシピメモ';
      case AppLocale.china:
        return '食谱备注';
      case AppLocale.usa:
        return 'Recipe Memo';
      case AppLocale.euro:
        return 'Recipe Memo';
      case AppLocale.vietnam:
        return 'Ghi chú công thức';
    }
  }

  static String getIngredientsAndAmounts(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 및 투입량';
      case AppLocale.japan:
        return '材料と投入量';
      case AppLocale.china:
        return '材料及投入量';
      case AppLocale.usa:
        return 'Ingredients & Amounts';
      case AppLocale.euro:
        return 'Ingredients & Amounts';
      case AppLocale.vietnam:
        return 'Nguyên liệu và số lượng';
    }
  }

  static String getMultiplier(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '배수';
      case AppLocale.japan:
        return '倍数';
      case AppLocale.china:
        return '倍数';
      case AppLocale.usa:
        return 'Multiplier';
      case AppLocale.euro:
        return 'Multiplier';
      case AppLocale.vietnam:
        return 'Hệ số nhân';
    }
  }

  static String getMultiplierDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '배수를 조정하면 재료 투입량이 자동으로 계산됩니다';
      case AppLocale.japan:
        return '倍数を調整すると材料投入量が自動計算されます';
      case AppLocale.china:
        return '调整倍数后材料投入量将自动计算';
      case AppLocale.usa:
        return 'Adjust multiplier to automatically calculate ingredient amounts';
      case AppLocale.euro:
        return 'Adjust multiplier to automatically calculate ingredient amounts';
      case AppLocale.vietnam:
        return 'Điều chỉnh hệ số nhân để tự động tính toán số lượng nguyên liệu';
    }
  }

  static String getNoMemo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '메모가 없습니다';
      case AppLocale.japan:
        return 'メモがありません';
      case AppLocale.china:
        return '暂无备注';
      case AppLocale.usa:
        return 'No memo';
      case AppLocale.euro:
        return 'No memo';
      case AppLocale.vietnam:
        return 'Không có ghi chú';
    }
  }

  static String getMultiplierRange(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '1배 ~ 50배 (정수 단위)';
      case AppLocale.japan:
        return '1倍 ~ 50倍 (整数単位)';
      case AppLocale.china:
        return '1倍 ~ 50倍 (整数单位)';
      case AppLocale.usa:
        return '1x ~ 50x (Integer units)';
      case AppLocale.euro:
        return '1x ~ 50x (Ganzzahlige Einheiten)';
      case AppLocale.vietnam:
        return '1x ~ 50x (Số nguyên)';
    }
  }
}
