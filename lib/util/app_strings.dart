import 'app_locale.dart';

/// 국가별 언어 대응을 위한 문자열 관리
class AppStrings {
  /// 앱 제목
  static String getAppTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원까';
      case AppLocale.japan:
        return '原価カ';
      case AppLocale.china:
        return '原价卡';
      case AppLocale.usa:
        return 'Wonka';
      case AppLocale.euro:
        return 'Wonka';
    }
  }

  /// 재료 관련
  static String getAddIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 추가하기';
      case AppLocale.japan:
        return '材料を追加';
      case AppLocale.china:
        return '添加材料';
      case AppLocale.usa:
        return 'Add Ingredient';
      case AppLocale.euro:
        return 'Add Ingredient';
    }
  }

  static String getIngredientName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료명';
      case AppLocale.japan:
        return '材料名';
      case AppLocale.china:
        return '材料名称';
      case AppLocale.usa:
        return 'Ingredient Name';
      case AppLocale.euro:
        return 'Ingredient Name';
    }
  }

  static String getPurchasePrice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매 가격';
      case AppLocale.japan:
        return '購入価格';
      case AppLocale.china:
        return '购买价格';
      case AppLocale.usa:
        return 'Purchase Price';
      case AppLocale.euro:
        return 'Purchase Price';
    }
  }

  static String getPurchaseAmount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매 수량';
      case AppLocale.japan:
        return '購入数量';
      case AppLocale.china:
        return '购买数量';
      case AppLocale.usa:
        return 'Purchase Amount';
      case AppLocale.euro:
        return 'Purchase Amount';
    }
  }

  static String getExpiryDate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한';
      case AppLocale.japan:
        return '消費期限';
      case AppLocale.china:
        return '保质期';
      case AppLocale.usa:
        return 'Expiry Date';
      case AppLocale.euro:
        return 'Expiry Date';
    }
  }

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
    }
  }

  static String getSearchRecipeHint(AppLocale locale) {
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
    }
  }

  /// 재시도 관련
  static String getRetry(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '다시 시도';
      case AppLocale.japan:
        return '再試行';
      case AppLocale.china:
        return '重试';
      case AppLocale.usa:
        return 'Retry';
      case AppLocale.euro:
        return 'Retry';
    }
  }

  /// 선택 모드 관련
  static String getDeleteSelected(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '선택 삭제';
      case AppLocale.japan:
        return '選択削除';
      case AppLocale.china:
        return '删除选中';
      case AppLocale.usa:
        return 'Delete Selected';
      case AppLocale.euro:
        return 'Delete Selected';
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
    }
  }

  static String getSelectIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 선택';
      case AppLocale.japan:
        return '材料選択';
      case AppLocale.china:
        return '选择材料';
      case AppLocale.usa:
        return 'Select Ingredient';
      case AppLocale.euro:
        return 'Select Ingredient';
    }
  }

  static String getEditIngredientAmount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 수량 편집';
      case AppLocale.japan:
        return '材料数量編集';
      case AppLocale.china:
        return '编辑材料数量';
      case AppLocale.usa:
        return 'Edit Ingredient Amount';
      case AppLocale.euro:
        return 'Edit Ingredient Amount';
    }
  }

  static String getAmount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수량';
      case AppLocale.japan:
        return '数量';
      case AppLocale.china:
        return '数量';
      case AppLocale.usa:
        return 'Amount';
      case AppLocale.euro:
        return 'Amount';
    }
  }

  static String getRecipeIngredientsRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '최소 하나의 재료를 선택해주세요';
      case AppLocale.japan:
        return '最低1つの材料を選択してください';
      case AppLocale.china:
        return '请至少选择一个材料';
      case AppLocale.usa:
        return 'Please select at least one ingredient';
      case AppLocale.euro:
        return 'Please select at least one ingredient';
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
    }
  }

  /// 원가 정보 관련
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
    }
  }

  static String getCostPerServing(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '1인분당 원가';
      case AppLocale.japan:
        return '1人前あたりの原価';
      case AppLocale.china:
        return '每份成本';
      case AppLocale.usa:
        return 'Cost per Serving';
      case AppLocale.euro:
        return 'Cost per Serving';
    }
  }

  /// 버튼 텍스트
  static String getSave(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '저장';
      case AppLocale.japan:
        return '保存';
      case AppLocale.china:
        return '保存';
      case AppLocale.usa:
        return 'Save';
      case AppLocale.euro:
        return 'Save';
    }
  }

  static String getCancelSelection(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '취소';
      case AppLocale.japan:
        return 'キャンセル';
      case AppLocale.china:
        return '取消';
      case AppLocale.usa:
        return 'Cancel';
      case AppLocale.euro:
        return 'Cancel';
    }
  }

  static String getDelete(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '삭제';
      case AppLocale.japan:
        return '削除';
      case AppLocale.china:
        return '删除';
      case AppLocale.usa:
        return 'Delete';
      case AppLocale.euro:
        return 'Delete';
    }
  }

  static String getEdit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수정';
      case AppLocale.japan:
        return '編集';
      case AppLocale.china:
        return '编辑';
      case AppLocale.usa:
        return 'Edit';
      case AppLocale.euro:
        return 'Edit';
    }
  }

  /// OCR 관련
  static String getScanReceiptButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증 스캔';
      case AppLocale.japan:
        return 'レシートスキャン';
      case AppLocale.china:
        return '扫描收据';
      case AppLocale.usa:
        return 'Scan Receipt';
      case AppLocale.euro:
        return 'Scan Receipt';
    }
  }

  static String getCorrectData(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '데이터 수정';
      case AppLocale.japan:
        return 'データ修正';
      case AppLocale.china:
        return '数据修正';
      case AppLocale.usa:
        return 'Correct Data';
      case AppLocale.euro:
        return 'Correct Data';
    }
  }

  /// 알림 메시지
  static String getExpiryWarning(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한이 임박한 재료가 있습니다';
      case AppLocale.japan:
        return '消費期限が近い材料があります';
      case AppLocale.china:
        return '有即将过期的材料';
      case AppLocale.usa:
        return 'You have ingredients expiring soon';
      case AppLocale.euro:
        return 'You have ingredients expiring soon';
    }
  }

  static String getExpiryDanger(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한이 위험한 재료가 있습니다';
      case AppLocale.japan:
        return '消費期限が危険な材料があります';
      case AppLocale.china:
        return '有危险期的材料';
      case AppLocale.usa:
        return 'You have ingredients in danger of expiring';
      case AppLocale.euro:
        return 'You have ingredients in danger of expiring';
    }
  }

  static String getExpiryExpired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '만료된 재료가 있습니다';
      case AppLocale.japan:
        return '期限切れの材料があります';
      case AppLocale.china:
        return '有过期的材料';
      case AppLocale.usa:
        return 'You have expired ingredients';
      case AppLocale.euro:
        return 'You have expired ingredients';
    }
  }

  /// 단위 관련
  static String getUnit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '단위';
      case AppLocale.japan:
        return '単位';
      case AppLocale.china:
        return '单位';
      case AppLocale.usa:
        return 'Unit';
      case AppLocale.euro:
        return 'Unit';
    }
  }

  static String getWeight(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '무게';
      case AppLocale.japan:
        return '重量';
      case AppLocale.china:
        return '重量';
      case AppLocale.usa:
        return 'Weight';
      case AppLocale.euro:
        return 'Weight';
    }
  }

  static String getVolume(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '부피';
      case AppLocale.japan:
        return '体積';
      case AppLocale.china:
        return '体积';
      case AppLocale.usa:
        return 'Volume';
      case AppLocale.euro:
        return 'Volume';
    }
  }

  static String getCount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '개수';
      case AppLocale.japan:
        return '個数';
      case AppLocale.china:
        return '数量';
      case AppLocale.usa:
        return 'Count';
      case AppLocale.euro:
        return 'Count';
    }
  }

  /// 에러 메시지
  static String getErrorOccurred(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '오류가 발생했습니다';
      case AppLocale.japan:
        return 'エラーが発生しました';
      case AppLocale.china:
        return '发生错误';
      case AppLocale.usa:
        return 'An error occurred';
      case AppLocale.euro:
        return 'An error occurred';
    }
  }

  static String getNetworkError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '네트워크 오류가 발생했습니다';
      case AppLocale.japan:
        return 'ネットワークエラーが発生しました';
      case AppLocale.china:
        return '网络错误';
      case AppLocale.usa:
        return 'Network error occurred';
      case AppLocale.euro:
        return 'Network error occurred';
    }
  }

  static String getTryAgain(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '다시 시도';
      case AppLocale.japan:
        return '再試行';
      case AppLocale.china:
        return '重试';
      case AppLocale.usa:
        return 'Try Again';
      case AppLocale.euro:
        return 'Try Again';
    }
  }

  /// 페이지 제목
  static String getIngredientManagement(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 관리';
      case AppLocale.japan:
        return '材料管理';
      case AppLocale.china:
        return '材料管理';
      case AppLocale.usa:
        return 'Ingredient Management';
      case AppLocale.euro:
        return 'Ingredient Management';
    }
  }

  static String getRecipeManagement(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 관리';
      case AppLocale.japan:
        return 'レシピ管理';
      case AppLocale.china:
        return '食谱管理';
      case AppLocale.usa:
        return 'Recipe Management';
      case AppLocale.euro:
        return 'Recipe Management';
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
    }
  }

  /// 선택 모드 관련
  static String getCancel(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '취소';
      case AppLocale.japan:
        return 'キャンセル';
      case AppLocale.china:
        return '取消';
      case AppLocale.usa:
        return 'Cancel';
      case AppLocale.euro:
        return 'Cancel';
    }
  }

  static String getSelectedCount(AppLocale locale, int count) {
    switch (locale) {
      case AppLocale.korea:
        return '$count개 선택됨';
      case AppLocale.japan:
        return '$count個選択済み';
      case AppLocale.china:
        return '已选择$count个';
      case AppLocale.usa:
        return '$count selected';
      case AppLocale.euro:
        return '$count selected';
    }
  }

  static String getCreateRecipeFromIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피로 만들기';
      case AppLocale.japan:
        return 'レシピを作成';
      case AppLocale.china:
        return '制作食谱';
      case AppLocale.usa:
        return 'Create Recipe';
      case AppLocale.euro:
        return 'Create Recipe';
    }
  }

  static String getScanReceipt(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증 스캔';
      case AppLocale.japan:
        return 'レシートスキャン';
      case AppLocale.china:
        return '扫描收据';
      case AppLocale.usa:
        return 'Scan Receipt';
      case AppLocale.euro:
        return 'Scan Receipt';
    }
  }

  static String getAddRecipeButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 추가';
      case AppLocale.japan:
        return '레シピ追加';
      case AppLocale.china:
        return '添加食谱';
      case AppLocale.usa:
        return 'Add Recipe';
      case AppLocale.euro:
        return 'Add Recipe';
    }
  }

  static String getSelectedIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '선택된 재료들';
      case AppLocale.japan:
        return '選択された材料';
      case AppLocale.china:
        return '已选材料';
      case AppLocale.usa:
        return 'Selected Ingredients';
      case AppLocale.euro:
        return 'Selected Ingredients';
    }
  }

  /// 알림 설정
  static String getNotificationSettings(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '알림 설정';
      case AppLocale.japan:
        return '通知設定';
      case AppLocale.china:
        return '通知设置';
      case AppLocale.usa:
        return 'Notification Settings';
      case AppLocale.euro:
        return 'Notification Settings';
    }
  }

  static String getEnableNotifications(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '알림 활성화';
      case AppLocale.japan:
        return '通知を有効にする';
      case AppLocale.china:
        return '启用通知';
      case AppLocale.usa:
        return 'Enable Notifications';
      case AppLocale.euro:
        return 'Enable Notifications';
    }
  }

  static String getEnableNotificationsDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '모든 알림을 켜거나 끕니다';
      case AppLocale.japan:
        return 'すべての通知をオンまたはオフにします';
      case AppLocale.china:
        return '开启或关闭所有通知';
      case AppLocale.usa:
        return 'Turn all notifications on or off';
      case AppLocale.euro:
        return 'Turn all notifications on or off';
    }
  }

  static String getExpiryWarningNotification(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 경고 알림';
      case AppLocale.japan:
        return '消費期限警告通知';
      case AppLocale.china:
        return '保质期警告通知';
      case AppLocale.usa:
        return 'Expiry Warning Notification';
      case AppLocale.euro:
        return 'Expiry Warning Notification';
    }
  }

  static String getExpiryWarningDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 3일 전 알림';
      case AppLocale.japan:
        return '消費期限3日前の通知';
      case AppLocale.china:
        return '保质期前3天通知';
      case AppLocale.usa:
        return 'Notification 3 days before expiry';
      case AppLocale.euro:
        return 'Notification 3 days before expiry';
    }
  }

  static String getExpiryDangerNotification(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 위험 알림';
      case AppLocale.japan:
        return '消費期限危険通知';
      case AppLocale.china:
        return '保质期危险通知';
      case AppLocale.usa:
        return 'Expiry Danger Notification';
      case AppLocale.euro:
        return 'Expiry Danger Notification';
    }
  }

  static String getExpiryDangerDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 1일 전 알림';
      case AppLocale.japan:
        return '消費期限1日前の通知';
      case AppLocale.china:
        return '保质期前1天通知';
      case AppLocale.usa:
        return 'Notification 1 day before expiry';
      case AppLocale.euro:
        return 'Notification 1 day before expiry';
    }
  }

  static String getExpiryExpiredNotification(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 만료 알림';
      case AppLocale.japan:
        return '消費期限切れ通知';
      case AppLocale.china:
        return '保质期过期通知';
      case AppLocale.usa:
        return 'Expiry Expired Notification';
      case AppLocale.euro:
        return 'Expiry Expired Notification';
    }
  }

  static String getExpiryExpiredDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 당일 알림';
      case AppLocale.japan:
        return '消費期限当日の通知';
      case AppLocale.china:
        return '保质期当天通知';
      case AppLocale.usa:
        return 'Notification on expiry date';
      case AppLocale.euro:
        return 'Notification on expiry date';
    }
  }

  /// 앱 설정
  static String getAppSettings(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '앱 설정';
      case AppLocale.japan:
        return 'アプリ設定';
      case AppLocale.china:
        return '应用设置';
      case AppLocale.usa:
        return 'App Settings';
      case AppLocale.euro:
        return 'App Settings';
    }
  }

  static String getLanguageSettings(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '언어 설정';
      case AppLocale.japan:
        return '言語設定';
      case AppLocale.china:
        return '语言设置';
      case AppLocale.usa:
        return 'Language Settings';
      case AppLocale.euro:
        return 'Language Settings';
    }
  }

  static String getExportData(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '데이터 내보내기';
      case AppLocale.japan:
        return 'データエクスポート';
      case AppLocale.china:
        return '导出数据';
      case AppLocale.usa:
        return 'Export Data';
      case AppLocale.euro:
        return 'Export Data';
    }
  }

  static String getExportDataDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 및 레시피 데이터를 백업합니다';
      case AppLocale.japan:
        return '材料とレシピデータをバックアップします';
      case AppLocale.china:
        return '备份材料和食谱数据';
      case AppLocale.usa:
        return 'Backup ingredient and recipe data';
      case AppLocale.euro:
        return 'Backup ingredient and recipe data';
    }
  }

  static String getImportData(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '데이터 가져오기';
      case AppLocale.japan:
        return 'データインポート';
      case AppLocale.china:
        return '导入数据';
      case AppLocale.usa:
        return 'Import Data';
      case AppLocale.euro:
        return 'Import Data';
    }
  }

  static String getImportDataDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '백업된 데이터를 복원합니다';
      case AppLocale.japan:
        return 'バックアップされたデータを復元します';
      case AppLocale.china:
        return '恢复备份数据';
      case AppLocale.usa:
        return 'Restore backed up data';
      case AppLocale.euro:
        return 'Restore backed up data';
    }
  }

  static String getResetData(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '데이터 초기화';
      case AppLocale.japan:
        return 'データリセット';
      case AppLocale.china:
        return '数据重置';
      case AppLocale.usa:
        return 'Reset Data';
      case AppLocale.euro:
        return 'Reset Data';
    }
  }

  static String getResetDataDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '모든 데이터를 삭제합니다';
      case AppLocale.japan:
        return 'すべてのデータを削除します';
      case AppLocale.china:
        return '删除所有数据';
      case AppLocale.usa:
        return 'Delete all data';
      case AppLocale.euro:
        return 'Delete all data';
    }
  }

  /// 정보
  static String getInformation(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '정보';
      case AppLocale.japan:
        return '情報';
      case AppLocale.china:
        return '信息';
      case AppLocale.usa:
        return 'Information';
      case AppLocale.euro:
        return 'Information';
    }
  }

  static String getAppVersion(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '앱 버전';
      case AppLocale.japan:
        return 'アプリバージョン';
      case AppLocale.china:
        return '应用版本';
      case AppLocale.usa:
        return 'App Version';
      case AppLocale.euro:
        return 'App Version';
    }
  }

  static String getDeveloperInfo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '개발자 정보';
      case AppLocale.japan:
        return '開発者情報';
      case AppLocale.china:
        return '开发者信息';
      case AppLocale.usa:
        return 'Developer Info';
      case AppLocale.euro:
        return 'Developer Info';
    }
  }

  static String getPrivacyPolicy(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '개인정보 처리방침';
      case AppLocale.japan:
        return 'プライバシーポリシー';
      case AppLocale.china:
        return '隐私政策';
      case AppLocale.usa:
        return 'Privacy Policy';
      case AppLocale.euro:
        return 'Privacy Policy';
    }
  }

  static String getPrivacyPolicyDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '개인정보 수집 및 이용에 관한 안내';
      case AppLocale.japan:
        return '個人情報の収集と利用に関する案内';
      case AppLocale.china:
        return '关于个人信息收集和使用的说明';
      case AppLocale.usa:
        return 'Information about personal data collection and usage';
      case AppLocale.euro:
        return 'Information about personal data collection and usage';
    }
  }

  static String getTermsOfService(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이용약관';
      case AppLocale.japan:
        return '利用規約';
      case AppLocale.china:
        return '服务条款';
      case AppLocale.usa:
        return 'Terms of Service';
      case AppLocale.euro:
        return 'Terms of Service';
    }
  }

  static String getTermsOfServiceDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '서비스 이용에 관한 약관';
      case AppLocale.japan:
        return 'サービス利用に関する規約';
      case AppLocale.china:
        return '关于服务使用的条款';
      case AppLocale.usa:
        return 'Terms for service usage';
      case AppLocale.euro:
        return 'Terms for service usage';
    }
  }

  /// 다이얼로그
  static String getLanguageSelection(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '언어 선택';
      case AppLocale.japan:
        return '言語選択';
      case AppLocale.china:
        return '语言选择';
      case AppLocale.usa:
        return 'Language Selection';
      case AppLocale.euro:
        return 'Language Selection';
    }
  }

  static String getDataReset(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '데이터 초기화';
      case AppLocale.japan:
        return 'データリセット';
      case AppLocale.china:
        return '数据重置';
      case AppLocale.usa:
        return 'Data Reset';
      case AppLocale.euro:
        return 'Data Reset';
    }
  }

  static String getDataResetWarning(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '모든 데이터가 삭제됩니다.\n이 작업은 되돌릴 수 없습니다.';
      case AppLocale.japan:
        return 'すべてのデータが削除されます。\nこの操作は元に戻せません。';
      case AppLocale.china:
        return '所有数据将被删除。\n此操作无法撤销。';
      case AppLocale.usa:
        return 'All data will be deleted.\nThis action cannot be undone.';
      case AppLocale.euro:
        return 'All data will be deleted.\nThis action cannot be undone.';
    }
  }

  static String getDataResetSuccess(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '데이터가 초기화되었습니다';
      case AppLocale.japan:
        return 'データがリセットされました';
      case AppLocale.china:
        return '数据已重置';
      case AppLocale.usa:
        return 'Data has been reset';
      case AppLocale.euro:
        return 'Data has been reset';
    }
  }

  static String getConfirm(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '확인';
      case AppLocale.japan:
        return '確認';
      case AppLocale.china:
        return '确认';
      case AppLocale.usa:
        return 'Confirm';
      case AppLocale.euro:
        return 'Confirm';
    }
  }

  /// 개발자 정보
  static String getDeveloperTeam(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원까 팀';
      case AppLocale.japan:
        return 'ウォンカチーム';
      case AppLocale.china:
        return '元卡团队';
      case AppLocale.usa:
        return 'Wonka Team';
      case AppLocale.euro:
        return 'Wonka Team';
    }
  }

  static String getAppDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 원가 계산 앱';
      case AppLocale.japan:
        return 'レシピ原価計算アプリ';
      case AppLocale.china:
        return '食谱成本计算应用';
      case AppLocale.usa:
        return 'Recipe Cost Calculator App';
      case AppLocale.euro:
        return 'Recipe Cost Calculator App';
    }
  }

  static String getVersion(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '버전: 1.0.0';
      case AppLocale.japan:
        return 'バージョン: 1.0.0';
      case AppLocale.china:
        return '版本: 1.0.0';
      case AppLocale.usa:
        return 'Version: 1.0.0';
      case AppLocale.euro:
        return 'Version: 1.0.0';
    }
  }

  /// 준비 중 메시지
  static String getFeatureInProgress(AppLocale locale, String featureName) {
    switch (locale) {
      case AppLocale.korea:
        return '$featureName 기능이 준비 중입니다';
      case AppLocale.japan:
        return '$featureName機能が準備中です';
      case AppLocale.china:
        return '$featureName功能正在准备中';
      case AppLocale.usa:
        return '$featureName feature is in progress';
      case AppLocale.euro:
        return '$featureName feature is in progress';
    }
  }

  /// 재료 추가/수정 관련
  static String getExpiryDateDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료의 유통기한을 선택하세요';
      default:
        return 'Select the expiry date of the ingredient';
    }
  }

  static String getSelectExpiryDate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한을 선택하세요';
      default:
        return 'Select expiry date';
    }
  }

  static String getUnitRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '단위를 선택해주세요';
      default:
        return 'Please select a unit';
    }
  }

  static String getIngredientAddedSuccessfully(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료가 성공적으로 추가되었습니다';
      default:
        return 'Ingredient added successfully';
    }
  }

  static String getIngredientAddFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 추가에 실패했습니다';
      default:
        return 'Failed to add ingredient';
    }
  }

  static String getEditIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 수정하기';
      default:
        return 'Edit Ingredient';
    }
  }

  static String getBasicInformation(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '기본 정보';
      default:
        return 'Basic Information';
    }
  }

  static String getEnterIngredientName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료명을 입력하세요';
      default:
        return 'Enter ingredient name';
    }
  }

  static String getIngredientNameRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료명을 입력해주세요';
      default:
        return 'Ingredient name is required';
    }
  }

  static String getEnterPrice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격을 입력하세요';
      default:
        return 'Enter price';
    }
  }

  static String getPriceRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격을 입력해주세요';
      default:
        return 'Price is required';
    }
  }

  static String getValidPriceRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '올바른 가격을 입력해주세요';
      default:
        return 'Enter a valid price';
    }
  }

  static String getEnterAmount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수량을 입력하세요';
      default:
        return 'Enter amount';
    }
  }

  static String getAmountRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수량을 입력해주세요';
      default:
        return 'Amount is required';
    }
  }

  static String getValidAmountRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '올바른 수량을 입력해주세요';
      default:
        return 'Enter a valid amount';
    }
  }

  static String getTags(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '태그';
      default:
        return 'Tags';
    }
  }

  static String getSelectTagsDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료를 분류할 태그를 선택하세요';
      default:
        return 'Select tags to categorize the ingredient';
    }
  }

  static String getUpdateIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 수정';
      default:
        return 'Update Ingredient';
    }
  }

  static String getIngredientUpdatedSuccessfully(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료가 성공적으로 수정되었습니다';
      default:
        return 'Ingredient updated successfully';
    }
  }

  static String getIngredientUpdateFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 수정에 실패했습니다';
      default:
        return 'Failed to update ingredient';
    }
  }

  /// 날짜 포맷 (간단 예시)
  static String formatDate(DateTime date, AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '${date.year}년 ${date.month}월 ${date.day}일';
      default:
        return '${date.year}-${date.month}-${date.day}';
    }
  }
}
