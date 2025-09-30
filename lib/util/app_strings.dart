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

  // OCR 메인 화면 관련
  static String getOcrMainTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증 OCR';
      case AppLocale.japan:
        return 'レシートOCR';
      case AppLocale.china:
        return '收据OCR';
      case AppLocale.usa:
        return 'Receipt OCR';
      case AppLocale.euro:
        return 'Receipt OCR';
    }
  }

  static String getSelectReceiptFromGallery(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '갤러리에서 영수증 선택';
      case AppLocale.japan:
        return 'ギャラリーからレシート選択';
      case AppLocale.china:
        return '从相册选择收据';
      case AppLocale.usa:
        return 'Select Receipt from Gallery';
      case AppLocale.euro:
        return 'Select Receipt from Gallery';
    }
  }

  static String getOcrProcessing(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'OCR 처리 중...';
      case AppLocale.japan:
        return 'OCR処理中...';
      case AppLocale.china:
        return 'OCR处理中...';
      case AppLocale.usa:
        return 'Processing OCR...';
      case AppLocale.euro:
        return 'Processing OCR...';
    }
  }

  static String getOcrCompleted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'OCR 완료';
      case AppLocale.japan:
        return 'OCR完了';
      case AppLocale.china:
        return 'OCR完成';
      case AppLocale.usa:
        return 'OCR Completed';
      case AppLocale.euro:
        return 'OCR Completed';
    }
  }

  static String getOcrFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'OCR 실패';
      case AppLocale.japan:
        return 'OCR失敗';
      case AppLocale.china:
        return 'OCR失败';
      case AppLocale.usa:
        return 'OCR Failed';
      case AppLocale.euro:
        return 'OCR Failed';
    }
  }

  static String getOcrFailedMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '텍스트 인식에 실패했습니다. 다시 시도해주세요.';
      case AppLocale.japan:
        return 'テキスト認識に失敗しました。再試行してください。';
      case AppLocale.china:
        return '文本识别失败，请重试。';
      case AppLocale.usa:
        return 'Text recognition failed. Please try again.';
      case AppLocale.euro:
        return 'Text recognition failed. Please try again.';
    }
  }

  // OCR 결과 관련
  static String getRecognizedText(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '인식된 텍스트';
      case AppLocale.japan:
        return '認識されたテキスト';
      case AppLocale.china:
        return '识别的文本';
      case AppLocale.usa:
        return 'Recognized Text';
      case AppLocale.euro:
        return 'Recognized Text';
    }
  }

  static String getParsedIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '파싱된 재료';
      case AppLocale.japan:
        return '解析された材料';
      case AppLocale.china:
        return '解析的材料';
      case AppLocale.usa:
        return 'Parsed Ingredients';
      case AppLocale.euro:
        return 'Parsed Ingredients';
    }
  }

  static String getConfirmAndSave(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '확인 및 저장';
      case AppLocale.japan:
        return '確認・保存';
      case AppLocale.china:
        return '确认并保存';
      case AppLocale.usa:
        return 'Confirm & Save';
      case AppLocale.euro:
        return 'Confirm & Save';
    }
  }

  static String getSaveIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 저장';
      case AppLocale.japan:
        return '材料保存';
      case AppLocale.china:
        return '保存材料';
      case AppLocale.usa:
        return 'Save Ingredients';
      case AppLocale.euro:
        return 'Save Ingredients';
    }
  }

  static String getIngredientsSaved(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료가 저장되었습니다';
      case AppLocale.japan:
        return '材料が保存されました';
      case AppLocale.china:
        return '材料已保存';
      case AppLocale.usa:
        return 'Ingredients saved successfully';
      case AppLocale.euro:
        return 'Ingredients saved successfully';
    }
  }

  static String getSaveFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '저장 실패';
      case AppLocale.japan:
        return '保存失敗';
      case AppLocale.china:
        return '保存失败';
      case AppLocale.usa:
        return 'Save Failed';
      case AppLocale.euro:
        return 'Save Failed';
    }
  }

  static String getSaveFailedMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 저장에 실패했습니다. 다시 시도해주세요.';
      case AppLocale.japan:
        return '材料保存に失敗しました。再試行してください。';
      case AppLocale.china:
        return '保存材料失败，请重试。';
      case AppLocale.usa:
        return 'Failed to save ingredients. Please try again.';
      case AppLocale.euro:
        return 'Failed to save ingredients. Please try again.';
    }
  }

  // 권한 관련
  static String getGalleryPermissionRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '갤러리 접근 권한이 필요합니다';
      case AppLocale.japan:
        return 'ギャラリーアクセス権限が必要です';
      case AppLocale.china:
        return '需要相册访问权限';
      case AppLocale.usa:
        return 'Gallery access permission required';
      case AppLocale.euro:
        return 'Gallery access permission required';
    }
  }

  static String getPermissionDenied(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '권한이 거부되었습니다';
      case AppLocale.japan:
        return '権限が拒否されました';
      case AppLocale.china:
        return '权限被拒绝';
      case AppLocale.usa:
        return 'Permission denied';
      case AppLocale.euro:
        return 'Permission denied';
    }
  }

  static String getOpenSettings(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '설정 열기';
      case AppLocale.japan:
        return '設定を開く';
      case AppLocale.china:
        return '打开设置';
      case AppLocale.usa:
        return 'Open Settings';
      case AppLocale.euro:
        return 'Open Settings';
    }
  }

  // 파싱 관련
  static String getParsingSummary(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '파싱 요약';
      case AppLocale.japan:
        return '解析サマリー';
      case AppLocale.china:
        return '解析摘要';
      case AppLocale.usa:
        return 'Parsing Summary';
      case AppLocale.euro:
        return 'Parsing Summary';
    }
  }

  static String getTotalItems(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총 항목 수';
      case AppLocale.japan:
        return '総項目数';
      case AppLocale.china:
        return '总项目数';
      case AppLocale.usa:
        return 'Total Items';
      case AppLocale.euro:
        return 'Total Items';
    }
  }

  static String getTotalPrice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총 가격';
      case AppLocale.japan:
        return '総価格';
      case AppLocale.china:
        return '总价格';
      case AppLocale.usa:
        return 'Total Price';
      case AppLocale.euro:
        return 'Total Price';
    }
  }

  static String getItemsWithoutPrice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격 정보 없는 항목';
      case AppLocale.japan:
        return '価格情報なし項目';
      case AppLocale.china:
        return '无价格信息项目';
      case AppLocale.usa:
        return 'Items without Price';
      case AppLocale.euro:
        return 'Items without Price';
    }
  }

  static String getEditIngredientInfo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 정보 편집';
      case AppLocale.japan:
        return '材料情報編集';
      case AppLocale.china:
        return '编辑材料信息';
      case AppLocale.usa:
        return 'Edit Ingredient Info';
      case AppLocale.euro:
        return 'Edit Ingredient Info';
    }
  }

  static String getNoIngredientsFound(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '인식된 재료가 없습니다';
      case AppLocale.japan:
        return '認識された材料がありません';
      case AppLocale.china:
        return '没有识别到材料';
      case AppLocale.usa:
        return 'No ingredients found';
      case AppLocale.euro:
        return 'No ingredients found';
    }
  }

  static String getTryDifferentImage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '다른 이미지를 시도해보세요';
      case AppLocale.japan:
        return '別の画像を試してみてください';
      case AppLocale.china:
        return '请尝试其他图片';
      case AppLocale.usa:
        return 'Try a different image';
      case AppLocale.euro:
        return 'Try a different image';
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

  /// 로그인 관련
  static String getLoginTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'Recipe App';
      case AppLocale.japan:
        return 'レシピアプリ';
      case AppLocale.china:
        return '食谱应用';
      case AppLocale.usa:
        return 'Recipe App';
      case AppLocale.euro:
        return 'Recipe App';
    }
  }

  static String getLoginSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피를 관리하고 AI 요리법을 받아보세요';
      case AppLocale.japan:
        return 'レシピを管理し、AI料理法を受け取りましょう';
      case AppLocale.china:
        return '管理食谱并获取AI烹饪方法';
      case AppLocale.usa:
        return 'Manage recipes and get AI cooking methods';
      case AppLocale.euro:
        return 'Manage recipes and get AI cooking methods';
    }
  }

  static String getGoogleLoginButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'Google로 로그인';
      case AppLocale.japan:
        return 'Googleでログイン';
      case AppLocale.china:
        return '使用Google登录';
      case AppLocale.usa:
        return 'Sign in with Google';
      case AppLocale.euro:
        return 'Sign in with Google';
    }
  }

  static String getLoginFailure(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '로그인 실패';
      case AppLocale.japan:
        return 'ログイン失敗';
      case AppLocale.china:
        return '登录失败';
      case AppLocale.usa:
        return 'Login Failed';
      case AppLocale.euro:
        return 'Login Failed';
    }
  }

  static String getLoginFailureMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '로그인에 실패했습니다';
      case AppLocale.japan:
        return 'ログインに失敗しました';
      case AppLocale.china:
        return '登录失败';
      case AppLocale.usa:
        return 'Failed to sign in';
      case AppLocale.euro:
        return 'Failed to sign in';
    }
  }

  /// 홈 화면 관련
  static String getWelcomeMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '환영합니다!';
      case AppLocale.japan:
        return 'ようこそ！';
      case AppLocale.china:
        return '欢迎！';
      case AppLocale.usa:
        return 'Welcome!';
      case AppLocale.euro:
        return 'Welcome!';
    }
  }

  static String getHomeSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 앱을 사용할 준비가 되었습니다.';
      case AppLocale.japan:
        return 'レシピアプリを使用する準備ができました。';
      case AppLocale.china:
        return '食谱应用已准备就绪。';
      case AppLocale.usa:
        return 'You are ready to use the recipe app.';
      case AppLocale.euro:
        return 'You are ready to use the recipe app.';
    }
  }

  static String getLogout(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '로그아웃';
      case AppLocale.japan:
        return 'ログアウト';
      case AppLocale.china:
        return '退出登录';
      case AppLocale.usa:
        return 'Logout';
      case AppLocale.euro:
        return 'Logout';
    }
  }

  static String getUser(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '사용자';
      case AppLocale.japan:
        return 'ユーザー';
      case AppLocale.china:
        return '用户';
      case AppLocale.usa:
        return 'User';
      case AppLocale.euro:
        return 'User';
    }
  }

  static String getLoginComplete(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '로그인 완료';
      case AppLocale.japan:
        return 'ログイン完了';
      case AppLocale.china:
        return '登录完成';
      case AppLocale.usa:
        return 'Login Complete';
      case AppLocale.euro:
        return 'Login Complete';
    }
  }

  static String getGoogleAccountLogin(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'Google 계정으로 간편하게 로그인하세요';
      case AppLocale.japan:
        return 'Googleアカウントで簡単にログインしてください';
      case AppLocale.china:
        return '使用Google账户轻松登录';
      case AppLocale.usa:
        return 'Sign in easily with your Google account';
      case AppLocale.euro:
        return 'Sign in easily with your Google account';
    }
  }

  /// 계정 관련
  static String getAccount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '계정';
      case AppLocale.japan:
        return 'アカウント';
      case AppLocale.china:
        return '账户';
      case AppLocale.usa:
        return 'Account';
      case AppLocale.euro:
        return 'Account';
    }
  }

  static String getAccountSettings(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '계정 설정';
      case AppLocale.japan:
        return 'アカウント設定';
      case AppLocale.china:
        return '账户设置';
      case AppLocale.usa:
        return 'Account Settings';
      case AppLocale.euro:
        return 'Account Settings';
    }
  }

  static String getSignIn(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '로그인';
      case AppLocale.japan:
        return 'ログイン';
      case AppLocale.china:
        return '登录';
      case AppLocale.usa:
        return 'Sign In';
      case AppLocale.euro:
        return 'Sign In';
    }
  }

  static String getSignOut(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '로그아웃';
      case AppLocale.japan:
        return 'ログアウ트';
      case AppLocale.china:
        return '退出登录';
      case AppLocale.usa:
        return 'Sign Out';
      case AppLocale.euro:
        return 'Sign Out';
    }
  }

  static String getNotSignedIn(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '로그인되지 않음';
      case AppLocale.japan:
        return 'ログインされていません';
      case AppLocale.china:
        return '未登录';
      case AppLocale.usa:
        return 'Not signed in';
      case AppLocale.euro:
        return 'Not signed in';
    }
  }

  static String getSignedInAs(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '다음으로 로그인됨';
      case AppLocale.japan:
        return '以下でログイン中';
      case AppLocale.china:
        return '已登录为';
      case AppLocale.usa:
        return 'Signed in as';
      case AppLocale.euro:
        return 'Signed in as';
    }
  }

  /// 계정 정보 페이지 관련
  static String getAccountInfo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '계정 정보';
      case AppLocale.japan:
        return 'アカウント情報';
      case AppLocale.china:
        return '账户信息';
      case AppLocale.usa:
        return 'Account Information';
      case AppLocale.euro:
        return 'Account Information';
    }
  }

  static String getSubscriptionStatus(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구독 상태';
      case AppLocale.japan:
        return 'サブスクリプション状態';
      case AppLocale.china:
        return '订阅状态';
      case AppLocale.usa:
        return 'Subscription Status';
      case AppLocale.euro:
        return 'Subscription Status';
    }
  }

  static String getFreeUser(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '무료 사용자';
      case AppLocale.japan:
        return '無料ユーザー';
      case AppLocale.china:
        return '免费用户';
      case AppLocale.usa:
        return 'Free User';
      case AppLocale.euro:
        return 'Free User';
    }
  }

  static String getPremiumUser(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '프리미엄 사용자';
      case AppLocale.japan:
        return 'プレミアムユーザー';
      case AppLocale.china:
        return '高级用户';
      case AppLocale.usa:
        return 'Premium User';
      case AppLocale.euro:
        return 'Premium User';
    }
  }

  static String getFreeUserFeatures(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '• 광고 있음\n• AI 레시피 하루 3번';
      case AppLocale.japan:
        return '• 広告あり\n• AIレシピ1日3回';
      case AppLocale.china:
        return '• 有广告\n• AI食谱每日3次';
      case AppLocale.usa:
        return '• Ads included\n• AI recipes: 3 per day';
      case AppLocale.euro:
        return '• Ads included\n• AI recipes: 3 per day';
    }
  }

  static String getPremiumUserFeatures(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '• 광고 없음\n• AI 레시피 무제한';
      case AppLocale.japan:
        return '• 広告なし\n• AIレシピ無制限';
      case AppLocale.china:
        return '• 无广告\n• AI食谱无限制';
      case AppLocale.usa:
        return '• No ads\n• Unlimited AI recipes';
      case AppLocale.euro:
        return '• No ads\n• Unlimited AI recipes';
    }
  }

  static String getUpgradeToPremium(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '프리미엄으로 업그레이드';
      case AppLocale.japan:
        return 'プレミアムにアップグレード';
      case AppLocale.china:
        return '升级到高级版';
      case AppLocale.usa:
        return 'Upgrade to Premium';
      case AppLocale.euro:
        return 'Upgrade to Premium';
    }
  }

  static String getCurrentPlan(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '현재 플랜';
      case AppLocale.japan:
        return '現在のプラン';
      case AppLocale.china:
        return '当前计划';
      case AppLocale.usa:
        return 'Current Plan';
      case AppLocale.euro:
        return 'Current Plan';
    }
  }

  static String getUserEmail(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이메일';
      case AppLocale.japan:
        return 'メールアドレス';
      case AppLocale.china:
        return '邮箱';
      case AppLocale.usa:
        return 'Email';
      case AppLocale.euro:
        return 'Email';
    }
  }

  static String getUserName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '사용자명';
      case AppLocale.japan:
        return 'ユーザー名';
      case AppLocale.china:
        return '用户名';
      case AppLocale.usa:
        return 'Username';
      case AppLocale.euro:
        return 'Username';
    }
  }

  static String getJoinDate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가입일';
      case AppLocale.japan:
        return '登録日';
      case AppLocale.china:
        return '注册日期';
      case AppLocale.usa:
        return 'Join Date';
      case AppLocale.euro:
        return 'Join Date';
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
    }
  }

  /// 삭제 에러 메시지
  static String getDeleteError(AppLocale locale, String error) {
    switch (locale) {
      case AppLocale.korea:
        return '삭제 중 오류가 발생했습니다: $error';
      case AppLocale.japan:
        return '削除中にエラーが発生しました: $error';
      case AppLocale.china:
        return '删除时发生错误: $error';
      case AppLocale.usa:
        return 'An error occurred while deleting: $error';
      case AppLocale.euro:
        return 'An error occurred while deleting: $error';
    }
  }

  /// 재료 개수 (단순 표시용)
  static String getIngredientCountSimple(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 개수';
      case AppLocale.japan:
        return '材料数';
      case AppLocale.china:
        return '材料数量';
      case AppLocale.usa:
        return 'Ingredient Count';
      case AppLocale.euro:
        return 'Ingredient Count';
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
    }
  }

  /// 투입량 관련 텍스트
  static String getInputAmount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '투입량';
      case AppLocale.japan:
        return '投入量';
      case AppLocale.china:
        return '投入量';
      case AppLocale.usa:
        return 'Input Amount';
      case AppLocale.euro:
        return 'Input Amount';
    }
  }

  static String getCost(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원가';
      case AppLocale.japan:
        return '原価';
      case AppLocale.china:
        return '成本';
      case AppLocale.usa:
        return 'Cost';
      case AppLocale.euro:
        return 'Cost';
    }
  }

  static String getCalculatedCost(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '계산된 원가';
      case AppLocale.japan:
        return '計算された原価';
      case AppLocale.china:
        return '计算成本';
      case AppLocale.usa:
        return 'Calculated Cost';
      case AppLocale.euro:
        return 'Calculated Cost';
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
    }
  }

  /// 날짜 관련 텍스트
  static String getToday(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '오늘';
      case AppLocale.japan:
        return '今日';
      case AppLocale.china:
        return '今天';
      case AppLocale.usa:
        return 'Today';
      case AppLocale.euro:
        return 'Today';
    }
  }

  static String getYesterday(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '어제';
      case AppLocale.japan:
        return '昨日';
      case AppLocale.china:
        return '昨天';
      case AppLocale.usa:
        return 'Yesterday';
      case AppLocale.euro:
        return 'Yesterday';
    }
  }

  static String getDaysAgo(AppLocale locale, int days) {
    switch (locale) {
      case AppLocale.korea:
        return '${days}일 전';
      case AppLocale.japan:
        return '${days}日前';
      case AppLocale.china:
        return '${days}天前';
      case AppLocale.usa:
        return '$days days ago';
      case AppLocale.euro:
        return '$days days ago';
    }
  }

  static String getMonthDay(AppLocale locale, int month, int day) {
    switch (locale) {
      case AppLocale.korea:
        return '${month}월 ${day}일';
      case AppLocale.japan:
        return '${month}月${day}日';
      case AppLocale.china:
        return '${month}月${day}日';
      case AppLocale.usa:
        return '${month}/${day}';
      case AppLocale.euro:
        return '${day}.${month}';
    }
  }

  /// 폴백 텍스트 (기본값)
  static String getIngredientFallback(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료';
      case AppLocale.japan:
        return '材料';
      case AppLocale.china:
        return '材料';
      case AppLocale.usa:
        return 'Ingredient';
      case AppLocale.euro:
        return 'Ingredient';
    }
  }

  static String getSauceFallback(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스';
      case AppLocale.japan:
        return 'ソース';
      case AppLocale.china:
        return '酱汁';
      case AppLocale.usa:
        return 'Sauce';
      case AppLocale.euro:
        return 'Sauce';
    }
  }

  static String getCreateDifferentStyleRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '같은 재료로 다른 스타일의 레시피 만들기';
      case AppLocale.japan:
        return '同じ材料で異なるスタイルのレシピを作成';
      case AppLocale.china:
        return '用相同材料制作不同风格的食谱';
      case AppLocale.usa:
        return 'Create different style recipes with same ingredients';
      case AppLocale.euro:
        return 'Create different style recipes with same ingredients';
    }
  }

  static String getCreateDifferentStyleRecipesDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '선택한 재료를 활용해서 다른 요리 스타일의 레시피를 생성해보세요';
      case AppLocale.japan:
        return '選択した材料を活用して異なる料理スタイルのレシピを生成してみましょう';
      case AppLocale.china:
        return '利用选定的材料生成不同烹饪风格的食谱';
      case AppLocale.usa:
        return 'Use selected ingredients to generate recipes in different cooking styles';
      case AppLocale.euro:
        return 'Use selected ingredients to generate recipes in different cooking styles';
    }
  }

  static String getKoreanStyle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '한식 스타일';
      case AppLocale.japan:
        return '韓国料理スタイル';
      case AppLocale.china:
        return '韩餐风格';
      case AppLocale.usa:
        return 'Korean Style';
      case AppLocale.euro:
        return 'Korean Style';
    }
  }

  static String getFusionStyle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '퓨전 스타일';
      case AppLocale.japan:
        return 'フュージョンスタイル';
      case AppLocale.china:
        return '融合风格';
      case AppLocale.usa:
        return 'Fusion Style';
      case AppLocale.euro:
        return 'Fusion Style';
    }
  }

  static String getViewSavedAiRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '저장된 AI 레시피 보기';
      case AppLocale.japan:
        return '保存されたAIレシピを表示';
      case AppLocale.china:
        return '查看已保存的AI食谱';
      case AppLocale.usa:
        return 'View Saved AI Recipes';
      case AppLocale.euro:
        return 'View Saved AI Recipes';
    }
  }

  static String getViewSavedAiRecipesDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '생성된 AI 레시피를 확인하고 관리할 수 있습니다';
      case AppLocale.japan:
        return '生成されたAIレシピを確認・管理できます';
      case AppLocale.china:
        return '您可以查看和管理生成的AI食谱';
      case AppLocale.usa:
        return 'You can view and manage generated AI recipes';
      case AppLocale.euro:
        return 'You can view and manage generated AI recipes';
    }
  }

  static String getViewSavedRecipes(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '저장된 레시피 보기';
      case AppLocale.japan:
        return '保存されたレシピを表示';
      case AppLocale.china:
        return '查看已保存的食谱';
      case AppLocale.usa:
        return 'View Saved Recipes';
      case AppLocale.euro:
        return 'View Saved Recipes';
    }
  }

  static String getFusion(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '퓨전';
      case AppLocale.japan:
        return 'フュージョン';
      case AppLocale.china:
        return '融合';
      case AppLocale.usa:
        return 'Fusion';
      case AppLocale.euro:
        return 'Fusion';
    }
  }

  static String getBulkIngredientAdditionError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 일괄 추가 준비 중 오류가 발생했습니다';
      case AppLocale.japan:
        return '材料一括追加の準備中にエラーが発生しました';
      case AppLocale.china:
        return '准备批量添加材料时发生错误';
      case AppLocale.usa:
        return 'Error occurred while preparing bulk ingredient addition';
      case AppLocale.euro:
        return 'Error occurred while preparing bulk ingredient addition';
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
    }
  }

  /// 설정 페이지 관련 텍스트
  static String getSaveToDevice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '기기에 저장';
      case AppLocale.japan:
        return 'デバイスに保存';
      case AppLocale.china:
        return '保存到设备';
      case AppLocale.usa:
        return 'Save to Device';
      case AppLocale.euro:
        return 'Save to Device';
    }
  }

  static String getShare(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '공유하기';
      case AppLocale.japan:
        return '共有';
      case AppLocale.china:
        return '分享';
      case AppLocale.usa:
        return 'Share';
      case AppLocale.euro:
        return 'Share';
    }
  }

  static String getExportComplete(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '내보내기 완료';
      case AppLocale.japan:
        return 'エクスポート完了';
      case AppLocale.china:
        return '导出完成';
      case AppLocale.usa:
        return 'Export Complete';
      case AppLocale.euro:
        return 'Export Complete';
    }
  }

  static String getExportCompleteMessage(AppLocale locale, String location) {
    switch (locale) {
      case AppLocale.korea:
        return '내보내기 완료: $location에 저장됨';
      case AppLocale.japan:
        return 'エクスポート完了: $locationに保存されました';
      case AppLocale.china:
        return '导出完成：已保存到$location';
      case AppLocale.usa:
        return 'Export complete: Saved to $location';
      case AppLocale.euro:
        return 'Export complete: Saved to $location';
    }
  }

  static String getExportFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '내보내기 실패';
      case AppLocale.japan:
        return 'エクスポート失敗';
      case AppLocale.china:
        return '导出失败';
      case AppLocale.usa:
        return 'Export Failed';
      case AppLocale.euro:
        return 'Export Failed';
    }
  }

  static String getExportFailedMessage(AppLocale locale, String error) {
    switch (locale) {
      case AppLocale.korea:
        return '내보내기 실패: $error';
      case AppLocale.japan:
        return 'エクスポート失敗: $error';
      case AppLocale.china:
        return '导出失败：$error';
      case AppLocale.usa:
        return 'Export failed: $error';
      case AppLocale.euro:
        return 'Export failed: $error';
    }
  }

  static String getShareFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '공유 실패';
      case AppLocale.japan:
        return '共有失敗';
      case AppLocale.china:
        return '分享失败';
      case AppLocale.usa:
        return 'Share Failed';
      case AppLocale.euro:
        return 'Share Failed';
    }
  }

  static String getShareFailedMessage(AppLocale locale, String error) {
    switch (locale) {
      case AppLocale.korea:
        return '공유 실패: $error';
      case AppLocale.japan:
        return '共有失敗: $error';
      case AppLocale.china:
        return '分享失败：$error';
      case AppLocale.usa:
        return 'Share failed: $error';
      case AppLocale.euro:
        return 'Share failed: $error';
    }
  }

  static String getQuantity(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수량';
      case AppLocale.japan:
        return '数量';
      case AppLocale.china:
        return '数量';
      case AppLocale.usa:
        return 'Quantity';
      case AppLocale.euro:
        return 'Quantity';
    }
  }

  static String getDatabaseFile(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 앱 데이터베이스 내보내기';
      case AppLocale.japan:
        return 'レシピアプリデータベースエクスポート';
      case AppLocale.china:
        return '食谱应用数据库导出';
      case AppLocale.usa:
        return 'Recipe App Database Export';
      case AppLocale.euro:
        return 'Recipe App Database Export';
    }
  }

  static String getImportFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가져오기 실패';
      case AppLocale.japan:
        return 'インポート失敗';
      case AppLocale.china:
        return '导入失败';
      case AppLocale.usa:
        return 'Import Failed';
      case AppLocale.euro:
        return 'Import Failed';
    }
  }

  static String getImportFailedMessage(AppLocale locale, String error) {
    switch (locale) {
      case AppLocale.korea:
        return '가져오기 실패: $error';
      case AppLocale.japan:
        return 'インポート失敗: $error';
      case AppLocale.china:
        return '导入失败：$error';
      case AppLocale.usa:
        return 'Import failed: $error';
      case AppLocale.euro:
        return 'Import failed: $error';
    }
  }

  static String getImportComplete(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '데이터 가져오기 완료';
      case AppLocale.japan:
        return 'データインポート完了';
      case AppLocale.china:
        return '数据导入完成';
      case AppLocale.usa:
        return 'Data Import Complete';
      case AppLocale.euro:
        return 'Data Import Complete';
    }
  }

  static String getDatabaseFileOnly(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '데이터베이스 파일(.db)만 선택할 수 있습니다.';
      case AppLocale.japan:
        return 'データベースファイル(.db)のみ選択できます。';
      case AppLocale.china:
        return '只能选择数据库文件(.db)。';
      case AppLocale.usa:
        return 'Only database files (.db) can be selected.';
      case AppLocale.euro:
        return 'Only database files (.db) can be selected.';
    }
  }

  static String getResetFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '초기화 실패';
      case AppLocale.japan:
        return 'リセット失敗';
      case AppLocale.china:
        return '重置失败';
      case AppLocale.usa:
        return 'Reset Failed';
      case AppLocale.euro:
        return 'Reset Failed';
    }
  }

  static String getResetFailedMessage(AppLocale locale, String error) {
    switch (locale) {
      case AppLocale.korea:
        return '초기화 실패: $error';
      case AppLocale.japan:
        return 'リセット失敗: $error';
      case AppLocale.china:
        return '重置失败：$error';
      case AppLocale.usa:
        return 'Reset failed: $error';
      case AppLocale.euro:
        return 'Reset failed: $error';
    }
  }

  static String getReset(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '초기화';
      case AppLocale.japan:
        return 'リセット';
      case AppLocale.china:
        return '重置';
      case AppLocale.usa:
        return 'Reset';
      case AppLocale.euro:
        return 'Reset';
    }
  }

  static String getOnboarding(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '온보딩 다시보기';
      case AppLocale.japan:
        return 'オンボーディング再表示';
      case AppLocale.china:
        return '重新查看引导页';
      case AppLocale.usa:
        return 'View Onboarding Again';
      case AppLocale.euro:
        return 'View Onboarding Again';
    }
  }

  static String getOnboardingDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '앱 사용법을 다시 확인할 수 있습니다';
      case AppLocale.japan:
        return 'アプリの使い方を再確認できます';
      case AppLocale.china:
        return '可以重新查看应用使用方法';
      case AppLocale.usa:
        return 'Review how to use the app';
      case AppLocale.euro:
        return 'Review how to use the app';
    }
  }

  static String getLoginRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '로그인하여 데이터를 동기화하세요';
      case AppLocale.japan:
        return 'ログインしてデータを同期してください';
      case AppLocale.china:
        return '请登录以同步数据';
      case AppLocale.usa:
        return 'Sign in to sync your data';
      case AppLocale.euro:
        return 'Sign in to sync your data';
    }
  }

  static String getDownloadFolder(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '다운로드 폴더';
      case AppLocale.japan:
        return 'ダウンロードフォルダ';
      case AppLocale.china:
        return '下载文件夹';
      case AppLocale.usa:
        return 'Download folder';
      case AppLocale.euro:
        return 'Download folder';
    }
  }

  static String getDocumentsFolder(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'Documents 폴더';
      case AppLocale.japan:
        return 'Documentsフォルダ';
      case AppLocale.china:
        return 'Documents文件夹';
      case AppLocale.usa:
        return 'Documents folder';
      case AppLocale.euro:
        return 'Documents folder';
    }
  }

  // OCR 관련 추가 텍스트
  static String getTips(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '팁';
      case AppLocale.japan:
        return 'ヒント';
      case AppLocale.china:
        return '提示';
      case AppLocale.usa:
        return 'Tips';
      case AppLocale.euro:
        return 'Tipps';
    }
  }

  static String getTipClearPhoto(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '명확한 영수증 사진을 사용하세요';
      case AppLocale.japan:
        return '明確なレシート写真を使用してください';
      case AppLocale.china:
        return '请使用清晰的收据照片';
      case AppLocale.usa:
        return 'Use clear receipt photos';
      case AppLocale.euro:
        return 'Verwenden Sie klare Kassenbon-Fotos';
    }
  }

  static String getTipGoodLighting(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '밝은 조명에서 촬영하세요';
      case AppLocale.japan:
        return '明るい照明で撮影してください';
      case AppLocale.china:
        return '请在明亮的光线下拍摄';
      case AppLocale.usa:
        return 'Take photos in good lighting';
      case AppLocale.euro:
        return 'Machen Sie Fotos bei gutem Licht';
    }
  }

  static String getTipClearText(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '텍스트가 선명하게 보이는지 확인하세요';
      case AppLocale.japan:
        return 'テキストが鮮明に見えるか確認してください';
      case AppLocale.china:
        return '请确认文本是否清晰可见';
      case AppLocale.usa:
        return 'Make sure text is clearly visible';
      case AppLocale.euro:
        return 'Stellen Sie sicher, dass der Text klar sichtbar ist';
    }
  }

  static String getPleaseWait(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '잠시만 기다려주세요...';
      case AppLocale.japan:
        return 'しばらくお待ちください...';
      case AppLocale.china:
        return '请稍等...';
      case AppLocale.usa:
        return 'Please wait a moment...';
      case AppLocale.euro:
        return 'Bitte warten Sie einen Moment...';
    }
  }

  static String getReceiptImage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증 이미지';
      case AppLocale.japan:
        return 'レシート画像';
      case AppLocale.china:
        return '收据图像';
      case AppLocale.usa:
        return 'Receipt Image';
      case AppLocale.euro:
        return 'Kassenbon-Bild';
    }
  }

  static String getIngredientsToBeSaved(AppLocale locale, int count) {
    switch (locale) {
      case AppLocale.korea:
        return '$count개의 재료가 저장됩니다';
      case AppLocale.japan:
        return '$count個の材料が保存されます';
      case AppLocale.china:
        return '将保存$count个材料';
      case AppLocale.usa:
        return '$count ingredients will be saved';
      case AppLocale.euro:
        return '$count Zutaten werden gespeichert';
    }
  }

  static String getSavingIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료를 저장하고 있습니다...';
      case AppLocale.japan:
        return '材料を保存しています...';
      case AppLocale.china:
        return '正在保存材料...';
      case AppLocale.usa:
        return 'Saving ingredients...';
      case AppLocale.euro:
        return 'Zutaten werden gespeichert...';
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
    }
  }

  /// 유통기한 관련
  static String getNoExpiryDate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 없음';
      case AppLocale.japan:
        return '消費期限なし';
      case AppLocale.china:
        return '无保质期';
      case AppLocale.usa:
        return 'No expiry date';
      case AppLocale.euro:
        return 'Kein Verfallsdatum';
    }
  }

  static String getExpired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '만료됨';
      case AppLocale.japan:
        return '期限切れ';
      case AppLocale.china:
        return '已过期';
      case AppLocale.usa:
        return 'Expired';
      case AppLocale.euro:
        return 'Abgelaufen';
    }
  }

  static String getDanger(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '위험';
      case AppLocale.japan:
        return '危険';
      case AppLocale.china:
        return '危险';
      case AppLocale.usa:
        return 'Danger';
      case AppLocale.euro:
        return 'Gefahr';
    }
  }

  static String getWarning(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '경고';
      case AppLocale.japan:
        return '警告';
      case AppLocale.china:
        return '警告';
      case AppLocale.usa:
        return 'Warning';
      case AppLocale.euro:
        return 'Warnung';
    }
  }

  static String getNormal(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '정상';
      case AppLocale.japan:
        return '正常';
      case AppLocale.china:
        return '正常';
      case AppLocale.usa:
        return 'Normal';
      case AppLocale.euro:
        return 'Normal';
    }
  }

  /// 온보딩 관련 텍스트
  static String getOnboardingWelcome(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 원가를 까보자';
      case AppLocale.japan:
        return 'レストラン原価を簡単かつ正確に';
      case AppLocale.china:
        return '让餐厅成本计算变得简单准确';
      case AppLocale.usa:
        return 'Easy and Accurate Restaurant Cost Management';
      case AppLocale.euro:
        return 'Easy and Accurate Restaurant Cost Management';
    }
  }

  static String getOnboardingSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이미지만 촬영하면 식자재 자동 등록,\nAI 레시피 추천으로 수익 극대화';
      case AppLocale.japan:
        return '画像を撮影するだけで食材自動登録、\nAIレシピ提案で収益最大化';
      case AppLocale.china:
        return '只需拍照即可自动注册食材，\nAI食谱推荐实现收益最大化';
      case AppLocale.usa:
        return 'Just take a photo for automatic ingredient registration and \nAI recipe recommendations to maximize profits';
      case AppLocale.euro:
        return 'Just take a photo for automatic ingredient registration and \nAI recipe recommendations to maximize profits';
    }
  }

  static String getOnboardingImageScan(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '식자재 이미지로 자동 등록';
      case AppLocale.japan:
        return '食材画像で自動登録';
      case AppLocale.china:
        return '食材图像自动注册';
      case AppLocale.usa:
        return 'Automatic Registration with Ingredient Images';
      case AppLocale.euro:
        return 'Automatic Registration with Ingredient Images';
    }
  }

  static String getOnboardingImageScanSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI로 정확한 식자재 인식';
      case AppLocale.japan:
        return 'AIで正確な食材認識';
      case AppLocale.china:
        return 'AI准确识别食材';
      case AppLocale.usa:
        return 'Accurate Ingredient Recognition with AI';
      case AppLocale.euro:
        return 'Accurate Ingredient Recognition with AI';
    }
  }

  static String getOnboardingAiRecipe(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료로 창의적인 레시피 제안';
      case AppLocale.japan:
        return '保有材料で創造的なレシピ提案';
      case AppLocale.china:
        return '用现有食材提出创意食谱';
      case AppLocale.usa:
        return 'Creative Recipe Suggestions with Available Ingredients';
      case AppLocale.euro:
        return 'Creative Recipe Suggestions with Available Ingredients';
    }
  }

  static String getOnboardingAiRecipeSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'Gemini AI가 최적의 조합 제시';
      case AppLocale.japan:
        return 'Gemini AIが最適な組み合わせを提案';
      case AppLocale.china:
        return 'Gemini AI提供最佳组合';
      case AppLocale.usa:
        return 'Gemini AI Suggests Optimal Combinations';
      case AppLocale.euro:
        return 'Gemini AI Suggests Optimal Combinations';
    }
  }

  static String getOnboardingCostCalculation(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '실시간 원가 계산 및 수익 분석';
      case AppLocale.japan:
        return 'リアルタイム原価計算と収益分析';
      case AppLocale.china:
        return '实时成本计算和收益分析';
      case AppLocale.usa:
        return 'Real-time Cost Calculation and Profit Analysis';
      case AppLocale.euro:
        return 'Real-time Cost Calculation and Profit Analysis';
    }
  }

  static String getOnboardingCostCalculationSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '업계 표준 원가율 적용';
      case AppLocale.japan:
        return '業界標準原価率適用';
      case AppLocale.china:
        return '应用行业标准成本率';
      case AppLocale.usa:
        return 'Industry Standard Cost Ratio Applied';
      case AppLocale.euro:
        return 'Industry Standard Cost Ratio Applied';
    }
  }

  static String getOnboardingExpiryManagement(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '식자재별 유통기한 추적 및 알림';
      case AppLocale.japan:
        return '食材別消費期限追跡と通知';
      case AppLocale.china:
        return '按食材追踪保质期和通知';
      case AppLocale.usa:
        return 'Ingredient-specific Expiry Date Tracking and Notifications';
      case AppLocale.euro:
        return 'Ingredient-specific Expiry Date Tracking and Notifications';
    }
  }

  static String getOnboardingExpiryManagementSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '폐기 손실 방지로 수익 보호';
      case AppLocale.japan:
        return '廃棄ロス防止で収益保護';
      case AppLocale.china:
        return '防止废弃损失保护收益';
      case AppLocale.usa:
        return 'Prevent Waste Loss and Protect Profits';
      case AppLocale.euro:
        return 'Prevent Waste Loss and Protect Profits';
    }
  }

  static String getOnboardingBefore(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수작업으로 원가 계산하는 복잡한 과정';
      case AppLocale.japan:
        return '手作業で原価計算する複雑な過程';
      case AppLocale.china:
        return '手工计算成本的复杂过程';
      case AppLocale.usa:
        return 'Complex manual cost calculation process';
      case AppLocale.euro:
        return 'Complex manual cost calculation process';
    }
  }

  static String getOnboardingAfter(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI로 자동화된 간단한 원가 관리';
      case AppLocale.japan:
        return 'AIで自動化された簡単な原価管理';
      case AppLocale.china:
        return 'AI自动化简单成本管理';
      case AppLocale.usa:
        return 'AI-automated simple cost management';
      case AppLocale.euro:
        return 'AI-automated simple cost management';
    }
  }

  static String getOnboardingExample(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '삼겹살 500g + 양파 2개 + 소스 → AI 레시피 생성';
      case AppLocale.japan:
        return '豚バラ500g + 玉ねぎ2個 + ソース → AIレシピ生成';
      case AppLocale.china:
        return '五花肉500g + 洋葱2个 + 酱汁 → AI食谱生成';
      case AppLocale.usa:
        return 'Pork belly 500g + Onion 2pcs + Sauce → AI Recipe Generation';
      case AppLocale.euro:
        return 'Pork belly 500g + Onion 2pcs + Sauce → AI Recipe Generation';
    }
  }

  static String getOnboardingCostExample(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총 원가 8,500원 → 추천 판매가 24,000원';
      case AppLocale.japan:
        return '総原価8,500円 → 推奨販売価格24,000円';
      case AppLocale.china:
        return '总成本8,500元 → 推荐售价24,000元';
      case AppLocale.usa:
        return 'Total cost 8,500 won → Recommended selling price 24,000 won';
      case AppLocale.euro:
        return 'Total cost 8,500 won → Recommended selling price 24,000 won';
    }
  }

  static String getOnboardingExpiryExample(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 3일 전 알림 → 폐기 손실 0원, 수익 보호';
      case AppLocale.japan:
        return '消費期限3日前通知 → 廃棄ロス0円、収益保護';
      case AppLocale.china:
        return '保质期前3天通知 → 废弃损失0元，收益保护';
      case AppLocale.usa:
        return 'Notification 3 days before expiry → Zero waste loss, profit protection';
      case AppLocale.euro:
        return 'Notification 3 days before expiry → Zero waste loss, profit protection';
    }
  }

  static String getOnboardingTargetCostRatio(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '목표 원가율 설정';
      case AppLocale.japan:
        return '目標原価率設定';
      case AppLocale.china:
        return '设置目标成本率';
      case AppLocale.usa:
        return 'Set Target Cost Ratio';
      case AppLocale.euro:
        return 'Set Target Cost Ratio';
    }
  }

  static String getOnboardingIngredientCategory(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '주요 취급 식자재 카테고리';
      case AppLocale.japan:
        return '主要取扱食材カテゴリー';
      case AppLocale.china:
        return '主要经营食材类别';
      case AppLocale.usa:
        return 'Main Ingredient Categories';
      case AppLocale.euro:
        return 'Main Ingredient Categories';
    }
  }

  static String getOnboardingStart(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원까 시작하기';
      case AppLocale.japan:
        return 'ウォンカを始めよう';
      case AppLocale.china:
        return '开始使用元卡';
      case AppLocale.usa:
        return 'Start Wonka';
      case AppLocale.euro:
        return 'Start Wonka';
    }
  }

  static String getOnboardingSkip(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '건너뛰기';
      case AppLocale.japan:
        return 'スキップ';
      case AppLocale.china:
        return '跳过';
      case AppLocale.usa:
        return 'Skip';
      case AppLocale.euro:
        return 'Skip';
    }
  }

  static String getOnboardingNext(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '다음';
      case AppLocale.japan:
        return '次へ';
      case AppLocale.china:
        return '下一步';
      case AppLocale.usa:
        return 'Next';
      case AppLocale.euro:
        return 'Next';
    }
  }
}
