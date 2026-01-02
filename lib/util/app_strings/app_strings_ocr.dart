import '../app_locale.dart';

/// Ocr 관련 문자열
mixin AppStringsOcr {
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
      case AppLocale.vietnam:
        return 'Quét hóa đơn';
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
      case AppLocale.vietnam:
        return 'Quét hóa đơn';
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
      case AppLocale.vietnam:
        return 'Sửa dữ liệu';
    }
  }

  // OCR 메인 화면 관련
  static String getOcrMainTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증을 찍어서 재료를 쉽게 추가하세요';
      case AppLocale.japan:
        return 'レシートを撮影して材料を簡単に追加';
      case AppLocale.china:
        return '拍摄收据，轻松添加材料';
      case AppLocale.usa:
        return 'Take a photo of your receipt to easily add ingredients';
      case AppLocale.euro:
        return 'Fotografieren Sie Ihren Beleg, um Zutaten einfach hinzuzufügen';
      case AppLocale.vietnam:
        return 'Chụp ảnh hóa đơn để dễ dàng thêm nguyên liệu';
    }
  }

  static String getSelectReceiptFromGallery(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증 사진 선택하기';
      case AppLocale.japan:
        return 'レシート写真を選択';
      case AppLocale.china:
        return '选择收据照片';
      case AppLocale.usa:
        return 'Select Receipt Photo';
      case AppLocale.euro:
        return 'Kassenbon-Foto auswählen';
      case AppLocale.vietnam:
        return 'Chọn ảnh hóa đơn';
    }
  }

  static String getOcrProcessing(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증 분석 중...';
      case AppLocale.japan:
        return 'レシート分析中...';
      case AppLocale.china:
        return '收据分析中...';
      case AppLocale.usa:
        return 'Analyzing receipt...';
      case AppLocale.euro:
        return 'Beleg wird analysiert...';
      case AppLocale.vietnam:
        return 'Đang phân tích hóa đơn...';
    }
  }

  static String getOcrCompleted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증에서 재료를 자동으로 인식해드립니다';
      case AppLocale.japan:
        return 'レシートから材料を自動認識します';
      case AppLocale.china:
        return '自动识别收据中的材料';
      case AppLocale.usa:
        return 'Automatically recognizes ingredients from your receipt';
      case AppLocale.euro:
        return 'Erkennt automatisch Zutaten aus Ihrem Beleg';
      case AppLocale.vietnam:
        return 'Tự động nhận diện nguyên liệu từ hóa đơn';
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
      case AppLocale.vietnam:
        return 'OCR thất bại';
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
      case AppLocale.vietnam:
        return 'Nhận dạng văn bản thất bại. Vui lòng thử lại.';
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
      case AppLocale.vietnam:
        return 'Văn bản đã nhận dạng';
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
      case AppLocale.vietnam:
        return 'Nguyên liệu đã phân tích';
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
        return 'Lưu nguyên liệu';
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
        return 'Lưu thất bại';
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
        return 'Mở cài đặt';
    }
  }

  // 파싱 관련
  static String getParsingSummary(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이렇게 작동해요';
      case AppLocale.japan:
        return '使い方';
      case AppLocale.china:
        return '使用方法';
      case AppLocale.usa:
        return 'How It Works';
      case AppLocale.euro:
        return 'So funktioniert es';
      case AppLocale.vietnam:
        return 'Cách hoạt động';
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
      case AppLocale.vietnam:
        return 'Tổng số mục';
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
      case AppLocale.vietnam:
        return 'Tổng giá';
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
        return 'Chỉnh sửa thông tin nguyên liệu';
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
        return 'Try a different image';
    }
  }

  static String getImageSelectError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이미지 선택 중 오류가 발생했습니다';
      case AppLocale.japan:
        return '画像選択中にエラーが発生しました';
      case AppLocale.china:
        return '选择图像时发生错误';
      case AppLocale.usa:
        return 'An error occurred while selecting image';
      case AppLocale.euro:
        return 'An error occurred while selecting image';
      case AppLocale.vietnam:
        return 'An error occurred while selecting image';
    }
  }

  static String getOcrProcessingError(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'OCR 처리 중 오류가 발생했습니다';
      case AppLocale.japan:
        return 'OCR処理中にエラーが発生しました';
      case AppLocale.china:
        return 'OCR处理时发生错误';
      case AppLocale.usa:
        return 'An error occurred while processing OCR';
      case AppLocale.euro:
        return 'An error occurred while processing OCR';
      case AppLocale.vietnam:
        return 'An error occurred while processing OCR';
    }
  }

  static String getOcrResultNotGenerated(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'OCR 결과가 생성되지 않은 상태에서 Gemini 분석을 시작할 수 없습니다';
      case AppLocale.japan:
        return 'OCR結果が生成されていない状態ではGemini分析を開始できません';
      case AppLocale.china:
        return 'OCR结果未生成，无法开始Gemini分析';
      case AppLocale.usa:
        return 'Cannot start Gemini analysis without OCR result';
      case AppLocale.euro:
        return 'Cannot start Gemini analysis without OCR result';
      case AppLocale.vietnam:
        return 'Cannot start Gemini analysis without OCR result';
    }
  }
}
