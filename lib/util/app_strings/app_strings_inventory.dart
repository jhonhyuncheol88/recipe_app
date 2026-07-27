import '../app_locale.dart';

/// 재고조사 관련 문자열
mixin AppStringsInventory {
  static String getInventory(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재고';
      case AppLocale.japan:
        return '在庫';
      case AppLocale.china:
        return '库存';
      case AppLocale.chinaTraditional:
        return '庫存';
      case AppLocale.usa:
        return 'Inventory';
      case AppLocale.vietnam:
        return 'Tồn kho';
    }
  }

  static String getInventoryShelf(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '선반장';
      case AppLocale.japan:
        return '棚';
      case AppLocale.china:
        return '货架';
      case AppLocale.chinaTraditional:
        return '貨架';
      case AppLocale.usa:
        return 'Shelf';
      case AppLocale.vietnam:
        return 'Kệ';
    }
  }

  static String getInventoryFridge(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '냉장고';
      case AppLocale.japan:
        return '冷蔵庫';
      case AppLocale.china:
        return '冷藏';
      case AppLocale.chinaTraditional:
        return '冷藏';
      case AppLocale.usa:
        return 'Fridge';
      case AppLocale.vietnam:
        return 'Tủ lạnh';
    }
  }

  static String getInventoryFreezer(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '냉동고';
      case AppLocale.japan:
        return '冷凍庫';
      case AppLocale.china:
        return '冷冻';
      case AppLocale.chinaTraditional:
        return '冷凍';
      case AppLocale.usa:
        return 'Freezer';
      case AppLocale.vietnam:
        return 'Tủ đông';
    }
  }

  static String getInventoryUnsorted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '미분류';
      case AppLocale.japan:
        return '未分類';
      case AppLocale.china:
        return '未分类';
      case AppLocale.chinaTraditional:
        return '未分類';
      case AppLocale.usa:
        return 'Unsorted';
      case AppLocale.vietnam:
        return 'Chưa phân loại';
    }
  }

  static String getInventoryTodayPurchase(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '오늘 구매';
      case AppLocale.japan:
        return '本日購入';
      case AppLocale.china:
        return '今日采购';
      case AppLocale.chinaTraditional:
        return '今日採購';
      case AppLocale.usa:
        return 'Today\'s purchases';
      case AppLocale.vietnam:
        return 'Mua hôm nay';
    }
  }

  static String getInventoryAiScan(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 재고 스캔';
      case AppLocale.japan:
        return 'AI在庫スキャン';
      case AppLocale.china:
        return 'AI库存扫描';
      case AppLocale.chinaTraditional:
        return 'AI庫存掃描';
      case AppLocale.usa:
        return 'AI Stock Scan';
      case AppLocale.vietnam:
        return 'Quét kho AI';
    }
  }

  static String getInventoryRecordPurchase(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매 기록';
      case AppLocale.japan:
        return '購入記録';
      case AppLocale.china:
        return '采购记录';
      case AppLocale.chinaTraditional:
        return '採購記錄';
      case AppLocale.usa:
        return 'Record Purchase';
      case AppLocale.vietnam:
        return 'Ghi mua hàng';
    }
  }

  static String getInventoryQtyUpdated(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재고가 변경되었습니다';
      case AppLocale.japan:
        return '在庫を更新しました';
      case AppLocale.china:
        return '库存已更新';
      case AppLocale.chinaTraditional:
        return '庫存已更新';
      case AppLocale.usa:
        return 'Stock updated';
      case AppLocale.vietnam:
        return 'Đã cập nhật kho';
    }
  }

  static String getUndo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '실행취소';
      case AppLocale.japan:
        return '元に戻す';
      case AppLocale.china:
        return '撤销';
      case AppLocale.chinaTraditional:
        return '復原';
      case AppLocale.usa:
        return 'Undo';
      case AppLocale.vietnam:
        return 'Hoàn tác';
    }
  }

  static String getInventoryEnterQty(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '수량 입력';
      case AppLocale.japan:
        return '数量入力';
      case AppLocale.china:
        return '输入数量';
      case AppLocale.chinaTraditional:
        return '輸入數量';
      case AppLocale.usa:
        return 'Enter quantity';
      case AppLocale.vietnam:
        return 'Nhập số lượng';
    }
  }

  static String getInventoryEmpty(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이 위치에 재료가 없습니다';
      case AppLocale.japan:
        return 'この場所に材料がありません';
      case AppLocale.china:
        return '此位置没有食材';
      case AppLocale.chinaTraditional:
        return '此位置沒有食材';
      case AppLocale.usa:
        return 'No ingredients here';
      case AppLocale.vietnam:
        return 'Không có nguyên liệu ở đây';
    }
  }

  static String getInventorySelectIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 선택';
      case AppLocale.japan:
        return '材料選択';
      case AppLocale.china:
        return '选择食材';
      case AppLocale.chinaTraditional:
        return '選擇食材';
      case AppLocale.usa:
        return 'Select ingredient';
      case AppLocale.vietnam:
        return 'Chọn nguyên liệu';
    }
  }

  static String getInventoryPurchaseSaved(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매가 기록되었습니다';
      case AppLocale.japan:
        return '購入を記録しました';
      case AppLocale.china:
        return '已记录采购';
      case AppLocale.chinaTraditional:
        return '已記錄採購';
      case AppLocale.usa:
        return 'Purchase recorded';
      case AppLocale.vietnam:
        return 'Đã ghi mua hàng';
    }
  }

  static String getInventoryAiPreviewTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'AI 재고 미리보기';
      case AppLocale.japan:
        return 'AI在庫プレビュー';
      case AppLocale.china:
        return 'AI库存预览';
      case AppLocale.chinaTraditional:
        return 'AI庫存預覽';
      case AppLocale.usa:
        return 'AI Stock Preview';
      case AppLocale.vietnam:
        return 'Xem trước kho AI';
    }
  }

  static String getInventoryNewIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '새 재료';
      case AppLocale.japan:
        return '新しい材料';
      case AppLocale.china:
        return '新食材';
      case AppLocale.chinaTraditional:
        return '新食材';
      case AppLocale.usa:
        return 'New';
      case AppLocale.vietnam:
        return 'Mới';
    }
  }

  static String getInventoryApply(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '반영';
      case AppLocale.japan:
        return '反映';
      case AppLocale.china:
        return '应用';
      case AppLocale.chinaTraditional:
        return '套用';
      case AppLocale.usa:
        return 'Apply';
      case AppLocale.vietnam:
        return 'Áp dụng';
    }
  }

  static String getInventoryCurrent(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '현재';
      case AppLocale.japan:
        return '現在';
      case AppLocale.china:
        return '当前';
      case AppLocale.chinaTraditional:
        return '目前';
      case AppLocale.usa:
        return 'Now';
      case AppLocale.vietnam:
        return 'Hiện tại';
    }
  }

  static String getInventoryAiGuess(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추측';
      case AppLocale.japan:
        return '推測';
      case AppLocale.china:
        return '推测';
      case AppLocale.chinaTraditional:
        return '推測';
      case AppLocale.usa:
        return 'Est.';
      case AppLocale.vietnam:
        return 'Ước tính';
    }
  }

  static String getInventoryAnalyzing(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재고 분석 중...';
      case AppLocale.japan:
        return '在庫分析中...';
      case AppLocale.china:
        return '库存分析中...';
      case AppLocale.chinaTraditional:
        return '庫存分析中...';
      case AppLocale.usa:
        return 'Analyzing stock...';
      case AppLocale.vietnam:
        return 'Đang phân tích kho...';
    }
  }

  static String getInventoryNoAiResults(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '인식된 재료가 없습니다';
      case AppLocale.japan:
        return '認識された材料がありません';
      case AppLocale.china:
        return '未识别到食材';
      case AppLocale.chinaTraditional:
        return '未識別到食材';
      case AppLocale.usa:
        return 'No items recognized';
      case AppLocale.vietnam:
        return 'Không nhận diện được nguyên liệu';
    }
  }

  static String getInventoryStorageLocation(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '보관 위치';
      case AppLocale.japan:
        return '保管場所';
      case AppLocale.china:
        return '存放位置';
      case AppLocale.chinaTraditional:
        return '存放位置';
      case AppLocale.usa:
        return 'Storage location';
      case AppLocale.vietnam:
        return 'Vị trí bảo quản';
    }
  }

  static String getInventoryPickImage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '사진 선택';
      case AppLocale.japan:
        return '写真選択';
      case AppLocale.china:
        return '选择照片';
      case AppLocale.chinaTraditional:
        return '選擇照片';
      case AppLocale.usa:
        return 'Choose photo';
      case AppLocale.vietnam:
        return 'Chọn ảnh';
    }
  }

  static String getInventoryTakePhoto(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '사진 촬영';
      case AppLocale.japan:
        return '写真撮影';
      case AppLocale.china:
        return '拍照';
      case AppLocale.chinaTraditional:
        return '拍照';
      case AppLocale.usa:
        return 'Take photo';
      case AppLocale.vietnam:
        return 'Chụp ảnh';
    }
  }

  static String getInventoryError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재고 처리 중 오류가 발생했습니다';
      case AppLocale.japan:
        return '在庫処理中にエラーが発生しました';
      case AppLocale.china:
        return '库存处理时发生错误';
      case AppLocale.chinaTraditional:
        return '庫存處理時發生錯誤';
      case AppLocale.usa:
        return 'Inventory error occurred';
      case AppLocale.vietnam:
        return 'Lỗi xử lý kho';
    }
  }

  /// 변동 건수 (파라미터 포함)
  static String getInventoryTodayChanges(AppLocale locale, int count) {
    switch (locale) {
      case AppLocale.korea:
        return '변동 $count건';
      case AppLocale.japan:
        return '変動 $count件';
      case AppLocale.china:
        return '变动 $count条';
      case AppLocale.chinaTraditional:
        return '變動 $count筆';
      case AppLocale.usa:
        return '$count changes';
      case AppLocale.vietnam:
        return '$count thay đổi';
    }
  }
}
