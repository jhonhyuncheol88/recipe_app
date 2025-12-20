import '../app_locale.dart';

/// Ingredient 관련 문자열
mixin AppStringsIngredient {
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
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Tên nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Giá mua';
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
      case AppLocale.vietnam:
        return 'Số lượng mua';
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
      case AppLocale.vietnam:
        return 'Ngày hết hạn';
    }
  }

  static String getNoExpiryDate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 없음';
      case AppLocale.japan:
        return '消費期限なし';
      case AppLocale.china:
        return '无保质期';
      case AppLocale.usa:
        return 'No Expiry Date';
      case AppLocale.euro:
        return 'No Expiry Date';
      case AppLocale.vietnam:
        return 'Không có ngày hết hạn';
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
        return 'Expired';
      case AppLocale.vietnam:
        return 'Đã hết hạn';
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
        return 'Danger';
      case AppLocale.vietnam:
        return 'Nguy hiểm';
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
        return 'Warning';
      case AppLocale.vietnam:
        return 'Cảnh báo';
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
      case AppLocale.vietnam:
        return 'Bình thường';
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
      case AppLocale.vietnam:
        return 'Nguyên liệu';
    }
  }

  static String getAddSauce(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 추가';
      case AppLocale.vietnam:
        return 'Thêm nước sốt';
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
      case AppLocale.vietnam:
        return 'Thêm nước sốt';
    }
  }

  static String getNoRecipeSauces(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추가된 소스가 없습니다';
      case AppLocale.vietnam:
        return 'Không có nước sốt được thêm';
      default:
        return 'No sauces added';
    }
  }

  static String getSelectSauce(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 선택';
      case AppLocale.vietnam:
        return 'Chọn nước sốt';
      default:
        return 'Select Sauce';
    }
  }

  static String getEditSauceAmount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 수량 편집';
      case AppLocale.vietnam:
        return 'Chỉnh sửa số lượng nước sốt';
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
      case AppLocale.vietnam:
        return 'Nhập tên công thức';
    }
  }

  static String getSearchIngredientHint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 검색...';
      case AppLocale.japan:
        return '材料を検索...';
      case AppLocale.china:
        return '搜索材料...';
      case AppLocale.usa:
        return 'Search ingredient...';
      case AppLocale.euro:
        return 'Search ingredient...';
      case AppLocale.vietnam:
        return 'Tìm kiếm nguyên liệu...';
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
      case AppLocale.vietnam:
        return 'Không có nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu đầu tiên của bạn!';
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
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Chọn nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Chỉnh sửa số lượng nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Số lượng';
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
      case AppLocale.vietnam:
        return 'Vui lòng chọn ít nhất một nguyên liệu';
    }
  }

  /// 재료 추가/수정 관련
  static String getExpiryDateDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료의 유통기한을 선택하세요';
      case AppLocale.vietnam:
        return 'Chọn ngày hết hạn của nguyên liệu';
      default:
        return 'Select the expiry date of the ingredient';
    }
  }

  static String getSelectExpiryDate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한을 선택하세요';
      case AppLocale.vietnam:
        return 'Chọn ngày hết hạn';
      default:
        return 'Select expiry date';
    }
  }

  static String getUnitRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '단위를 선택해주세요';
      case AppLocale.vietnam:
        return 'Vui lòng chọn đơn vị';
      default:
        return 'Please select a unit';
    }
  }

  static String getIngredientAddedSuccessfully(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료가 성공적으로 추가되었습니다';
      case AppLocale.vietnam:
        return 'Đã thêm nguyên liệu thành công';
      default:
        return 'Ingredient added successfully';
    }
  }

  static String getIngredientAddFailed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 추가에 실패했습니다';
      case AppLocale.vietnam:
        return 'Không thể thêm nguyên liệu';
      default:
        return 'Failed to add ingredient';
    }
  }

  static String getEditIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 수정하기';
      case AppLocale.vietnam:
        return 'Chỉnh sửa nguyên liệu';
      default:
        return 'Edit Ingredient';
    }
  }

  static String getBasicInformation(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '기본 정보';
      case AppLocale.vietnam:
        return 'Thông tin cơ bản';
      default:
        return 'Basic Information';
    }
  }

  static String getEnterIngredientName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료명을 입력하세요';
      case AppLocale.vietnam:
        return 'Nhập tên nguyên liệu';
      default:
        return 'Enter ingredient name';
    }
  }

  static String getIngredientNameRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료명을 입력해주세요';
      case AppLocale.vietnam:
        return 'Tên nguyên liệu là bắt buộc';
      default:
        return 'Ingredient name is required';
    }
  }

  static String getEnterPrice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격을 입력하세요';
      case AppLocale.vietnam:
        return 'Nhập giá';
      default:
        return 'Enter price';
    }
  }

  static String getPriceRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격을 입력해주세요';
      case AppLocale.vietnam:
        return 'Giá là bắt buộc';
      default:
        return 'Price is required';
    }
  }

  static String getValidPriceRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '올바른 가격을 입력해주세요';
      case AppLocale.vietnam:
        return 'Nhập giá hợp lệ';
      default:
        return 'Enter a valid price';
    }
  }

  static String getEnterAmount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수량을 입력하세요';
      case AppLocale.vietnam:
        return 'Nhập số lượng';
      default:
        return 'Enter amount';
    }
  }

  static String getAmountRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수량을 입력해주세요';
      case AppLocale.vietnam:
        return 'Số lượng là bắt buộc';
      default:
        return 'Amount is required';
    }
  }

  static String getValidAmountRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '올바른 수량을 입력해주세요';
      case AppLocale.vietnam:
        return 'Nhập số lượng hợp lệ';
      default:
        return 'Enter a valid amount';
    }
  }

  static String getTags(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '태그';
      case AppLocale.vietnam:
        return 'Thẻ';
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
      case AppLocale.vietnam:
        return 'Làm lạnh';
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
      case AppLocale.vietnam:
        return 'Đông lạnh';
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
      case AppLocale.vietnam:
        return 'Nhiệt độ phòng';
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
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu hàng loạt';
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
      case AppLocale.vietnam:
        return 'Thêm nhiều nguyên liệu cùng lúc';
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
      case AppLocale.vietnam:
        return 'Danh sách nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Xóa nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Lưu hàng loạt';
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
      case AppLocale.vietnam:
        return 'Đang lưu...';
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
      case AppLocale.vietnam:
        return 'Đã thêm nguyên liệu thành công';
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
      case AppLocale.vietnam:
        return 'Không thể thêm nguyên liệu';
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
        return 'Thông tin nguyên liệu';
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
      case AppLocale.vietnam:
        return 'VD: Hành tây, Cà rốt, Khoai tây';
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
      case AppLocale.vietnam:
        return 'VD: 5000';
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
      case AppLocale.vietnam:
        return 'VD: 1.5';
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
      case AppLocale.vietnam:
        return 'Nhập từ CSV';
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
      case AppLocale.vietnam:
        return 'Xuất sang CSV';
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
      case AppLocale.vietnam:
        return 'Tải mẫu';
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
      case AppLocale.vietnam:
        return 'Tải file CSV, nhập thông tin nguyên liệu, sau đó tải lên';
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
      case AppLocale.vietnam:
        return 'Chọn tệp';
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
      case AppLocale.vietnam:
        return 'Tải tệp lên';
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
      case AppLocale.vietnam:
        return 'Định dạng tệp không hợp lệ';
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
      case AppLocale.vietnam:
        return 'Không thể đọc tệp';
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
      case AppLocale.vietnam:
        return 'Xác thực dữ liệu thất bại';
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
      case AppLocale.vietnam:
        return 'Thiếu các trường bắt buộc';
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
      case AppLocale.vietnam:
        return 'Tìm thấy tên nguyên liệu trùng lặp';
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
      case AppLocale.vietnam:
        return 'Xem trước';
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
      case AppLocale.vietnam:
        return 'Xem lại danh sách nguyên liệu sẽ được thêm';
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
      case AppLocale.vietnam:
        return 'Ẩm thực Hàn Quốc';
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
      case AppLocale.vietnam:
        return 'Người mới bắt đầu';
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
      case AppLocale.vietnam:
        return 'phút';
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
      case AppLocale.vietnam:
        return 'phần ăn';
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
      case AppLocale.vietnam:
        return 'Thêm hàng loạt';
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
      case AppLocale.vietnam:
        return 'Thêm nhiều nguyên liệu cùng lúc';
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
      case AppLocale.vietnam:
        return 'Hướng dẫn nấu ăn';
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
      case AppLocale.vietnam:
        return 'Số lượng nguyên liệu';
    }
  }
}
