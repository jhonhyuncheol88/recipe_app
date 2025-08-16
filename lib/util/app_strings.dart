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
        return 'Add Ing';
      case AppLocale.euro:
        return 'Add Ing';
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

  /// 소스(Sauce) 관련
  static String getSauceManagement(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 관리';
      default:
        return 'Sauce Management';
    }
  }

  static String getNoSauces(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '등록된 소스가 없습니다';
      default:
        return 'No sauces found';
    }
  }

  static String getEnterSauceName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 이름 입력';
      default:
        return 'Enter sauce name';
    }
  }

  static String getSauceNameExample(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '예: 데미글라스 소스';
      default:
        return 'e.g., Demi-glace sauce';
    }
  }

  static String getCreate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '생성';
      default:
        return 'Create';
    }
  }

  static String getSauceComposition(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구성 재료';
      default:
        return 'Composition';
    }
  }

  static String getAddIngredientToSauce(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스에 재료 추가';
      default:
        return 'Add ingredient to sauce';
    }
  }

  static String getNoSauceIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구성 재료가 없습니다.';
      default:
        return 'No composition ingredients.';
    }
  }

  static String getTotalWeight(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총중량';
      default:
        return 'Total Weight';
    }
  }

  static String getAdd(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추가';
      default:
        return 'Add';
    }
  }

  static String getSauces(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스';
      default:
        return 'Sauces';
    }
  }

  /// 재료(탭 라벨용 복수형)
  static String getIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료';
      case AppLocale.japan:
        return '材料';
      case AppLocale.china:
        return '材料';
      case AppLocale.usa:
        return 'Ingredients';
      case AppLocale.euro:
        return 'Ingredients';
    }
  }

  static String getAddSauce(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 추가';
      default:
        return 'Add Sauce';
    }
  }

  static String getAddSauceButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 추가';
      case AppLocale.japan:
        return 'ソースを追加';
      case AppLocale.china:
        return '添加酱汁';
      case AppLocale.usa:
        return 'Add Sauce';
      case AppLocale.euro:
        return 'Add Sauce';
    }
  }

  static String getNoRecipeSauces(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추가된 소스가 없습니다';
      default:
        return 'No sauces added';
    }
  }

  static String getSelectSauce(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 선택';
      default:
        return 'Select Sauce';
    }
  }

  static String getEditSauceAmount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 수량 편집';
      default:
        return 'Edit Sauce Amount';
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

  /// 재료 목록 비어있을 때
  static String getNoIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료가 없습니다';
      case AppLocale.japan:
        return '材料がありません';
      case AppLocale.china:
        return '没有材料';
      case AppLocale.usa:
        return 'No ingredients';
      case AppLocale.euro:
        return 'No ingredients';
    }
  }

  static String getNoIngredientsDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '첫 번째 재료를 추가해보세요!';
      case AppLocale.japan:
        return '最初の材料を追加しましょう！';
      case AppLocale.china:
        return '试着添加第一种材料吧！';
      case AppLocale.usa:
        return 'Add your first ingredient!';
      case AppLocale.euro:
        return 'Add your first ingredient!';
    }
  }

  static String getAddIngredientButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 추가';
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
  static String getAiRecipeCostInfo(AppLocale locale) {
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

  /// 공통 - 페이지 미발견 에러
  static String getPageNotFoundTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '페이지를 찾을 수 없습니다';
      case AppLocale.japan:
        return 'ページが見つかりません';
      case AppLocale.china:
        return '无法找到页面';
      case AppLocale.usa:
        return 'Page not found';
      case AppLocale.euro:
        return 'Page not found';
    }
  }

  static String getPageNotFoundSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '요청하신 페이지가 존재하지 않거나 이동되었습니다.';
      case AppLocale.japan:
        return '要求されたページは存在しないか移動されました。';
      case AppLocale.china:
        return '请求的页面不存在或已被移动。';
      case AppLocale.usa:
        return 'The requested page does not exist or has moved.';
      case AppLocale.euro:
        return 'The requested page does not exist or has moved.';
    }
  }

  static String getBackToHome(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '홈으로 돌아가기';
      case AppLocale.japan:
        return 'ホームに戻る';
      case AppLocale.china:
        return '返回首页';
      case AppLocale.usa:
        return 'Back to Home';
      case AppLocale.euro:
        return 'Back to Home';
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

  /// 기본 태그 이름 - 재료 태그
  static String getIngredientTagFresh(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '냉장';
      case AppLocale.japan:
        return '冷蔵';
      case AppLocale.china:
        return '冷藏';
      case AppLocale.usa:
        return 'Refrigerated';
      case AppLocale.euro:
        return 'Refrigerated';
    }
  }

  static String getIngredientTagFrozen(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '냉동';
      case AppLocale.japan:
        return '冷凍';
      case AppLocale.china:
        return '冷冻';
      case AppLocale.usa:
        return 'Frozen';
      case AppLocale.euro:
        return 'Frozen';
    }
  }

  static String getIngredientTagIndoor(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '실온';
      case AppLocale.japan:
        return '常温';
      case AppLocale.china:
        return '常温';
      case AppLocale.usa:
        return 'Room Temp';
      case AppLocale.euro:
        return 'Room Temp';
    }
  }

  /// 목록 필터 - 전체
  static String getAll(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '전체';
      case AppLocale.japan:
        return 'すべて';
      case AppLocale.china:
        return '全部';
      case AppLocale.usa:
        return 'All';
      case AppLocale.euro:
        return 'All';
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
    }
  }

  /// 원가 섹션 레이블
  static String getIngredientCostLabel(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 원가';
      case AppLocale.japan:
        return '材料原価';
      case AppLocale.china:
        return '材料成本';
      case AppLocale.usa:
        return 'Ingredient Cost';
      case AppLocale.euro:
        return 'Ingredient Cost';
    }
  }

  static String getSauceCostLabel(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 원가';
      case AppLocale.japan:
        return 'ソース原価';
      case AppLocale.china:
        return '酱汁成本';
      case AppLocale.usa:
        return 'Sauce Cost';
      case AppLocale.euro:
        return 'Sauce Cost';
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

  /// 알람 시간 설정
  static String getAlarmTimeSetting(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '알람 시간 설정';
      case AppLocale.japan:
        return 'アラーム時間設定';
      case AppLocale.china:
        return '闹钟时间设置';
      case AppLocale.usa:
        return 'Alarm Time Setting';
      case AppLocale.euro:
        return 'Alarm Time Setting';
    }
  }

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
      default:
        return 'Servings';
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
    }
  }

  /// 일괄 재료 추가 페이지 제목
  static String getBulkAddIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 일괄 추가';
      case AppLocale.japan:
        return '材料一括追加';
      case AppLocale.china:
        return '材料批量添加';
      case AppLocale.usa:
        return 'Bulk Add Ingredients';
      case AppLocale.euro:
        return 'Bulk Add Ingredients';
    }
  }

  /// 일괄 재료 추가 설명
  static String getBulkAddIngredientsDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '여러 재료를 한 번에 추가할 수 있습니다';
      case AppLocale.japan:
        return '複数の材料を一度に追加できます';
      case AppLocale.china:
        return '可以一次性添加多种材料';
      case AppLocale.usa:
        return 'Add multiple ingredients at once';
      case AppLocale.euro:
        return 'Add multiple ingredients at once';
    }
  }

  /// 재료 목록
  static String getIngredientList(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 목록';
      case AppLocale.japan:
        return '材料リスト';
      case AppLocale.china:
        return '材料列表';
      case AppLocale.usa:
        return 'Ingredient List';
      case AppLocale.euro:
        return 'Ingredient List';
    }
  }

  /// 재료 추가
  static String getAddIngredientToList(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 추가';
      case AppLocale.japan:
        return '材料追加';
      case AppLocale.china:
        return '添加材料';
      case AppLocale.usa:
        return 'Add Ingredient';
      case AppLocale.euro:
        return 'Add Ingredient';
    }
  }

  /// 재료 제거
  static String getRemoveIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 제거';
      case AppLocale.japan:
        return '材料削除';
      case AppLocale.china:
        return '移除材料';
      case AppLocale.usa:
        return 'Remove Ingredient';
      case AppLocale.euro:
        return 'Remove Ingredient';
    }
  }

  /// 일괄 저장
  static String getBulkSave(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '일괄 저장';
      case AppLocale.japan:
        return '一括保存';
      case AppLocale.china:
        return '批量保存';
      case AppLocale.usa:
        return 'Bulk Save';
      case AppLocale.euro:
        return 'Bulk Save';
    }
  }

  /// 저장 중
  static String getSaving(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '저장 중...';
      case AppLocale.japan:
        return '保存中...';
      case AppLocale.china:
        return '保存中...';
      case AppLocale.usa:
        return 'Saving...';
      case AppLocale.euro:
        return 'Saving...';
    }
  }

  /// 일괄 저장 성공
  static String getBulkSaveSuccess(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료가 성공적으로 추가되었습니다';
      case AppLocale.japan:
        return '材料が正常に追加されました';
      case AppLocale.china:
        return '材料已成功添加';
      case AppLocale.usa:
        return 'Ingredients added successfully';
      case AppLocale.euro:
        return 'Ingredients added successfully';
    }
  }

  /// 일괄 저장 실패
  static String getBulkSaveFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 추가에 실패했습니다';
      case AppLocale.japan:
        return '材料追加に失敗しました';
      case AppLocale.china:
        return '添加材料失败';
      case AppLocale.usa:
        return 'Failed to add ingredients';
      case AppLocale.euro:
        return 'Failed to add ingredients';
    }
  }

  /// 재료 개수
  static String getIngredientCount(AppLocale locale, int count) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 $count개';
      case AppLocale.japan:
        return '材料$count個';
      case AppLocale.china:
        return '材料$count个';
      case AppLocale.usa:
        return '$count Ingredients';
      case AppLocale.euro:
        return '$count Ingredients';
    }
  }

  /// 재료 정보
  static String getIngredientInfo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 정보';
      case AppLocale.japan:
        return '材料情報';
      case AppLocale.china:
        return '材料信息';
      case AppLocale.usa:
        return 'Ingredient Info';
      case AppLocale.euro:
        return 'Ingredient Info';
    }
  }

  /// 재료명 입력 힌트
  static String getEnterIngredientNameHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '예: 양파, 당근, 감자';
      case AppLocale.japan:
        return '例: 玉ねぎ、にんじん、じゃがいも';
      case AppLocale.china:
        return '例: 洋葱、胡萝卜、土豆';
      case AppLocale.usa:
        return 'e.g., Onion, Carrot, Potato';
      case AppLocale.euro:
        return 'e.g., Onion, Carrot, Potato';
    }
  }

  /// 가격 입력 힌트
  static String getEnterPriceHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '예: 5000';
      case AppLocale.japan:
        return '例: 5000';
      case AppLocale.china:
        return '例: 5000';
      case AppLocale.usa:
        return 'e.g., 5000';
      case AppLocale.euro:
        return 'e.g., 5000';
    }
  }

  /// 수량 입력 힌트
  static String getEnterAmountHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '예: 1.5';
      case AppLocale.japan:
        return '例: 1.5';
      case AppLocale.china:
        return '例: 1.5';
      case AppLocale.usa:
        return 'e.g., 1.5';
      case AppLocale.euro:
        return 'e.g., 1.5';
    }
  }

  /// CSV 가져오기
  static String getImportFromCsv(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'CSV 가져오기';
      case AppLocale.japan:
        return 'CSVインポート';
      case AppLocale.china:
        return 'CSV导入';
      case AppLocale.usa:
        return 'Import from CSV';
      case AppLocale.euro:
        return 'Import from CSV';
    }
  }

  /// CSV 내보내기
  static String getExportToCsv(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'CSV 내보내기';
      case AppLocale.japan:
        return 'CSVエクスポート';
      case AppLocale.china:
        return 'CSV导出';
      case AppLocale.usa:
        return 'Export to CSV';
      case AppLocale.euro:
        return 'Export to CSV';
    }
  }

  /// 템플릿 다운로드
  static String getDownloadTemplate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '템플릿 다운로드';
      case AppLocale.japan:
        return 'テンプレートダウンロード';
      case AppLocale.china:
        return '模板下载';
      case AppLocale.usa:
        return 'Download Template';
      case AppLocale.euro:
        return 'Download Template';
    }
  }

  /// 템플릿 설명
  static String getTemplateDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'CSV 파일을 다운로드하여 재료 정보를 입력한 후 업로드하세요';
      case AppLocale.japan:
        return 'CSVファイルをダウンロードして材料情報を入力し、アップロードしてください';
      case AppLocale.china:
        return '下载CSV文件，输入材料信息后上传';
      case AppLocale.usa:
        return 'Download CSV file, enter ingredient info, then upload';
      case AppLocale.euro:
        return 'Download CSV file, enter ingredient info, then upload';
    }
  }

  /// 파일 선택
  static String getSelectFile(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '파일 선택';
      case AppLocale.japan:
        return 'ファイル選択';
      case AppLocale.china:
        return '选择文件';
      case AppLocale.usa:
        return 'Select File';
      case AppLocale.euro:
        return 'Select File';
    }
  }

  /// 파일 업로드
  static String getUploadFile(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '파일 업로드';
      case AppLocale.japan:
        return 'ファイルアップロード';
      case AppLocale.china:
        return '文件上传';
      case AppLocale.usa:
        return 'Upload File';
      case AppLocale.euro:
        return 'Upload File';
    }
  }

  /// 파일 형식 오류
  static String getInvalidFileFormat(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '올바르지 않은 파일 형식입니다';
      case AppLocale.japan:
        return '正しくないファイル形式です';
      case AppLocale.china:
        return '文件格式不正确';
      case AppLocale.usa:
        return 'Invalid file format';
      case AppLocale.euro:
        return 'Invalid file format';
    }
  }

  /// 파일 읽기 오류
  static String getFileReadError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '파일을 읽을 수 없습니다';
      case AppLocale.japan:
        return 'ファイルを読むことができません';
      case AppLocale.china:
        return '无法读取文件';
      case AppLocale.usa:
        return 'Cannot read file';
      case AppLocale.euro:
        return 'Cannot read file';
    }
  }

  /// 데이터 검증 오류
  static String getDataValidationError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '데이터 검증에 실패했습니다';
      case AppLocale.japan:
        return 'データ検証に失敗しました';
      case AppLocale.china:
        return '数据验证失败';
      case AppLocale.usa:
        return 'Data validation failed';
      case AppLocale.euro:
        return 'Data validation failed';
    }
  }

  /// 필수 필드 누락
  static String getRequiredFieldMissing(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '필수 필드가 누락되었습니다';
      case AppLocale.japan:
        return '必須フィールドが不足しています';
      case AppLocale.china:
        return '缺少必填字段';
      case AppLocale.usa:
        return 'Required fields are missing';
      case AppLocale.euro:
        return 'Required fields are missing';
    }
  }

  /// 재료명 중복
  static String getDuplicateIngredientName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '중복된 재료명이 있습니다';
      case AppLocale.japan:
        return '重複した材料名があります';
      case AppLocale.china:
        return '有重复的材料名称';
      case AppLocale.usa:
        return 'Duplicate ingredient names found';
      case AppLocale.euro:
        return 'Duplicate ingredient names found';
    }
  }

  /// 미리보기
  static String getPreview(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '미리보기';
      case AppLocale.japan:
        return 'プレビュー';
      case AppLocale.china:
        return '预览';
      case AppLocale.usa:
        return 'Preview';
      case AppLocale.euro:
        return 'Preview';
    }
  }

  /// 미리보기 설명
  static String getPreviewDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추가될 재료 목록을 확인하세요';
      case AppLocale.japan:
        return '追加される材料リストを確認してください';
      case AppLocale.china:
        return '确认将要添加的材料列表';
      case AppLocale.usa:
        return 'Review the list of ingredients to be added';
      case AppLocale.euro:
        return 'Review the list of ingredients to be added';
    }
  }

  static String getKoreanCuisine(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '한국 요리';
      case AppLocale.japan:
        return '韓国料理';
      case AppLocale.china:
        return '韩国料理';
      case AppLocale.usa:
        return 'Korean Cuisine';
      case AppLocale.euro:
        return 'Korean Cuisine';
    }
  }

  static String getBeginnerLevel(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '초급';
      case AppLocale.japan:
        return '初級';
      case AppLocale.china:
        return '初级';
      case AppLocale.usa:
        return 'Beginner';
      case AppLocale.euro:
        return 'Beginner';
    }
  }

  static String getMinutes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '분';
      case AppLocale.japan:
        return '分';
      case AppLocale.china:
        return '分钟';
      case AppLocale.usa:
        return 'min';
      case AppLocale.euro:
        return 'min';
    }
  }

  static String getPeople(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '인분';
      case AppLocale.japan:
        return '人前';
      case AppLocale.china:
        return '人份';
      case AppLocale.usa:
        return 'servings';
      case AppLocale.euro:
        return 'servings';
    }
  }

  /// 대량등록 버튼 텍스트
  static String getBulkAdd(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '대량등록';
      case AppLocale.japan:
        return '一括登録';
      case AppLocale.china:
        return '批量注册';
      case AppLocale.usa:
        return 'Bulk Add';
      case AppLocale.euro:
        return 'Bulk Add';
    }
  }

  /// 대량등록 버튼 툴팁
  static String getBulkAddTooltip(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '여러 재료를 한 번에 추가';
      case AppLocale.japan:
        return '複数の材料を一度に追加';
      case AppLocale.china:
        return '一次性添加多种材料';
      case AppLocale.usa:
        return 'Add multiple ingredients at once';
      case AppLocale.euro:
        return 'Add multiple ingredients at once';
    }
  }

  /// 조리 방법
  static String getAiRecipeCookingInstructions(AppLocale locale) {
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
    }
  }
}
