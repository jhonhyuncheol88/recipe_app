import '../app_locale.dart';

/// Onboarding 관련 문자열
mixin AppStringsOnboarding {
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
      case AppLocale.vietnam:
        return 'Quản lý chi phí nhà hàng dễ dàng và chính xác';
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
      case AppLocale.vietnam:
        return 'Chỉ cần chụp ảnh để đăng ký nguyên liệu tự động và \\nđề xuất công thức AI để tối đa hóa lợi nhuận';
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
      case AppLocale.vietnam:
        return 'Đăng ký tự động với hình ảnh nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Nhận dạng nguyên liệu chính xác với AI';
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
      case AppLocale.vietnam:
        return 'Đề xuất công thức sáng tạo với nguyên liệu có sẵn';
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
      case AppLocale.vietnam:
        return 'Gemini AI đề xuất kết hợp tối ưu';
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
      case AppLocale.vietnam:
        return 'Tính toán chi phí và phân tích lợi nhuận theo thời gian thực';
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
      case AppLocale.vietnam:
        return 'Áp dụng tỷ lệ chi phí tiêu chuẩn ngành';
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
      case AppLocale.vietnam:
        return 'Theo dõi và thông báo ngày hết hạn cụ thể cho từng nguyên liệu';
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
      case AppLocale.vietnam:
        return 'Ngăn chặn lãng phí và bảo vệ lợi nhuận';
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
        return 'Set Target Cost Ratio';
    }
  }

  static String getOnboardingAdNoticeTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '앱 시작 시 전면 광고가 한 번 표시돼요';
      case AppLocale.japan:
        return 'アプリ起動時に全画面広告が1回表示されます';
      case AppLocale.china:
        return '启动应用时会显示一次全屏广告';
      case AppLocale.usa:
        return 'A full-screen ad appears once on app start';
      case AppLocale.euro:
        return 'A full-screen ad appears once on app start';
      case AppLocale.vietnam:
        return 'A full-screen ad appears once on app start';
    }
  }

  static String getOnboardingAdNoticeDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '서비스 유지와 무료 제공을 위해 앱을 열 때 전면 광고가 한 번 노출됩니다. 광고가 끝나면 바로 서비스로 이동합니다.';
      case AppLocale.japan:
        return 'サービス維持と無料提供のため、アプリ起動時に全画面広告が1回表示されます。終了後すぐにサービスに進みます。';
      case AppLocale.china:
        return '为维持服务与免费使用，启动应用时会显示一次全屏广告。广告结束后会立即进入服务。';
      case AppLocale.usa:
        return 'To keep the service free, one full-screen ad shows when you open the app. After it finishes, you’ll go straight into the app.';
      case AppLocale.euro:
        return 'To keep the service free, one full-screen ad shows when you open the app. After it finishes, you’ll go straight into the app.';
      case AppLocale.vietnam:
        return 'To keep the service free, one full-screen ad shows when you open the app. After it finishes, you’ll go straight into the app.';
    }
  }

  static String getOnboardingAdNoticePoint(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고 종료 후 바로 사용 가능합니다.';
      case AppLocale.japan:
        return '広告終了後、すぐに利用できます。';
      case AppLocale.china:
        return '广告结束后即可立即使用。';
      case AppLocale.usa:
        return 'You can use the app right after the ad.';
      case AppLocale.euro:
        return 'You can use the app right after the ad.';
      case AppLocale.vietnam:
        return 'You can use the app right after the ad.';
    }
  }

  static String getOnboardingAdNoticeFooter(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '테스트 중에는 Google 테스트 광고가 표시될 수 있습니다.';
      case AppLocale.japan:
        return 'テスト中は Google のテスト広告が表示される場合があります。';
      case AppLocale.china:
        return '测试期间可能会显示 Google 测试广告。';
      case AppLocale.usa:
        return 'During testing, Google test ads may appear.';
      case AppLocale.euro:
        return 'During testing, Google test ads may appear.';
      case AppLocale.vietnam:
        return 'During testing, Google test ads may appear.';
    }
  }

  static String getRecipeShareCopied(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '레시피 텍스트를 복사했어요.';
      case AppLocale.japan:
        return 'レシピのテキストをコピーしました。';
      case AppLocale.china:
        return '已复制食谱文本。';
      case AppLocale.usa:
        return 'Recipe text copied.';
      case AppLocale.euro:
        return 'Recipe text copied.';
      case AppLocale.vietnam:
        return 'Recipe text copied.';
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
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
      case AppLocale.vietnam:
        return 'Next';
    }
  }

  static String getOnboardingReady(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '준비 완료!';
      case AppLocale.japan:
        return '準備完了！';
      case AppLocale.china:
        return '准备就绪！';
      case AppLocale.usa:
        return 'Ready!';
      case AppLocale.euro:
        return 'Ready!';
      case AppLocale.vietnam:
        return 'Ready!';
    }
  }

  static String getOnboardingReadyMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이제 원까와 함께 식당 경영을 시작해보세요!';
      case AppLocale.japan:
        return 'ワンカと一緒にレストラン経営を始めましょう！';
      case AppLocale.china:
        return '现在开始使用元卡进行餐厅管理吧！';
      case AppLocale.usa:
        return 'Start managing your restaurant with Wonka!';
      case AppLocale.euro:
        return 'Start managing your restaurant with Wonka!';
      case AppLocale.vietnam:
        return 'Start managing your restaurant with Wonka!';
    }
  }

  static String getOnboardingOptionalSettings(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '선택 설정 (선택사항)';
      case AppLocale.japan:
        return '選択設定（オプション）';
      case AppLocale.china:
        return '可选设置';
      case AppLocale.usa:
        return 'Optional Settings';
      case AppLocale.euro:
        return 'Optional Settings';
      case AppLocale.vietnam:
        return 'Optional Settings';
    }
  }

  static String getOnboardingMainFeatures(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '주요 기능';
      case AppLocale.japan:
        return '主な機能';
      case AppLocale.china:
        return '主要功能';
      case AppLocale.usa:
        return 'Main Features';
      case AppLocale.euro:
        return 'Main Features';
      case AppLocale.vietnam:
        return 'Main Features';
    }
  }

  static String getOnboardingBeforeAfter(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'Before & After';
      case AppLocale.japan:
        return 'Before & After';
      case AppLocale.china:
        return 'Before & After';
      case AppLocale.usa:
        return 'Before & After';
      case AppLocale.euro:
        return 'Before & After';
      case AppLocale.vietnam:
        return 'Before & After';
    }
  }

  static String getOnboardingUsageExample(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '사용 예시';
      case AppLocale.japan:
        return '使用例';
      case AppLocale.china:
        return '使用示例';
      case AppLocale.usa:
        return 'Usage Example';
      case AppLocale.euro:
        return 'Usage Example';
      case AppLocale.vietnam:
        return 'Usage Example';
    }
  }

  // 권한 요청 페이지
  static String getPermissionSetup(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '권한 설정';
      case AppLocale.japan:
        return '権限設定';
      case AppLocale.china:
        return '权限设置';
      case AppLocale.usa:
        return 'Permission Setup';
      case AppLocale.euro:
        return 'Permission Setup';
      case AppLocale.vietnam:
        return 'Permission Setup';
    }
  }

  static String getNotificationPermissionTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '알림 권한';
      case AppLocale.japan:
        return '通知権限';
      case AppLocale.china:
        return '通知权限';
      case AppLocale.usa:
        return 'Notification Permission';
      case AppLocale.euro:
        return 'Notification Permission';
      case AppLocale.vietnam:
        return 'Notification Permission';
    }
  }

  static String getNotificationPermissionDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '식자재 유통기한이 다가오면\n알림을 보내드립니다';
      case AppLocale.japan:
        return '食材の賞味期限が近づくと\n通知をお送りします';
      case AppLocale.china:
        return '食材保质期临近时\n向您发送通知';
      case AppLocale.usa:
        return 'We\'ll send you notifications\nwhen ingredients expire soon';
      case AppLocale.euro:
        return 'We\'ll send you notifications\nwhen ingredients expire soon';
      case AppLocale.vietnam:
        return 'Chúng tôi sẽ gửi thông báo cho bạn\\nkhi nguyên liệu sắp hết hạn';
    }
  }

  static String getCameraPermissionTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '카메라 권한';
      case AppLocale.japan:
        return 'カメラ権限';
      case AppLocale.china:
        return '相机权限';
      case AppLocale.usa:
        return 'Camera Permission';
      case AppLocale.euro:
        return 'Camera Permission';
      case AppLocale.vietnam:
        return 'Camera Permission';
    }
  }

  static String getCameraPermissionDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증을 촬영하여\n식자재를 빠르게 등록할 수 있습니다';
      case AppLocale.japan:
        return 'レシートを撮影して\n食材を素早く登録できます';
      case AppLocale.china:
        return '拍摄收据\n快速登记食材';
      case AppLocale.usa:
        return 'Take photos of receipts to\nquickly add ingredients';
      case AppLocale.euro:
        return 'Take photos of receipts to\nquickly add ingredients';
      case AppLocale.vietnam:
        return 'Take photos of receipts to\\nquickly add ingredients';
    }
  }

  static String getGalleryPermissionTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '사진 라이브러리 권한';
      case AppLocale.japan:
        return '写真ライブラリ権限';
      case AppLocale.china:
        return '照片库权限';
      case AppLocale.usa:
        return 'Photo Library Permission';
      case AppLocale.euro:
        return 'Photo Library Permission';
      case AppLocale.vietnam:
        return 'Photo Library Permission';
    }
  }

  static String getGalleryPermissionDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '사진에서 영수증을 선택하여\n식자재를 빠르게 등록할 수 있습니다';
      case AppLocale.japan:
        return '写真からレシートを選択して\n食材を素早く登録できます';
      case AppLocale.china:
        return '从照片中选择收据\n快速登记食材';
      case AppLocale.usa:
        return 'Select receipts from photos to\nquickly add ingredients';
      case AppLocale.euro:
        return 'Select receipts from photos to\nquickly add ingredients';
      case AppLocale.vietnam:
        return 'Select receipts from photos to\\nquickly add ingredients';
    }
  }

  static String getPermissionBenefitTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이 권한으로 가능한 기능';
      case AppLocale.japan:
        return 'この権限で可能な機能';
      case AppLocale.china:
        return '该权限可实现的功能';
      case AppLocale.usa:
        return 'Available features';
      case AppLocale.euro:
        return 'Available features';
      case AppLocale.vietnam:
        return 'Available features';
    }
  }

  static String getExpiryNotificationBenefit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 알림';
      case AppLocale.japan:
        return '賞味期限通知';
      case AppLocale.china:
        return '保质期通知';
      case AppLocale.usa:
        return 'Expiry notifications';
      case AppLocale.euro:
        return 'Expiry notifications';
      case AppLocale.vietnam:
        return 'Expiry notifications';
    }
  }

  static String getImportantUpdatesBenefit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '중요한 업데이트 알림';
      case AppLocale.japan:
        return '重要な更新通知';
      case AppLocale.china:
        return '重要更新通知';
      case AppLocale.usa:
        return 'Important updates';
      case AppLocale.euro:
        return 'Important updates';
      case AppLocale.vietnam:
        return 'Important updates';
    }
  }

  static String getPersonalizedNotificationBenefit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '개인 맞춤 알림';
      case AppLocale.japan:
        return 'パーソナライズされた通知';
      case AppLocale.china:
        return '个性化通知';
      case AppLocale.usa:
        return 'Personalized notifications';
      case AppLocale.euro:
        return 'Personalized notifications';
      case AppLocale.vietnam:
        return 'Personalized notifications';
    }
  }

  static String getReceiptOcrBenefit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '영수증 OCR 인식';
      case AppLocale.japan:
        return 'レシートOCR認識';
      case AppLocale.china:
        return '收据OCR识别';
      case AppLocale.usa:
        return 'Receipt OCR recognition';
      case AppLocale.euro:
        return 'Receipt OCR recognition';
      case AppLocale.vietnam:
        return 'Receipt OCR recognition';
    }
  }

  static String getIngredientPhotosBenefit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '식자재 사진 촬영';
      case AppLocale.japan:
        return '食材写真撮影';
      case AppLocale.china:
        return '食材拍照';
      case AppLocale.usa:
        return 'Take ingredient photos';
      case AppLocale.euro:
        return 'Take ingredient photos';
      case AppLocale.vietnam:
        return 'Take ingredient photos';
    }
  }

  static String getQuickRegistrationBenefit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '빠른 식자재 등록';
      case AppLocale.japan:
        return '食材の素早い登録';
      case AppLocale.china:
        return '快速登记食材';
      case AppLocale.usa:
        return 'Quick ingredient registration';
      case AppLocale.euro:
        return 'Quick ingredient registration';
      case AppLocale.vietnam:
        return 'Quick ingredient registration';
    }
  }

  static String getChangeLaterInfo(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '나중에 설정에서 언제든지 변경할 수 있습니다';
      case AppLocale.japan:
        return '設定でいつでも変更できます';
      case AppLocale.china:
        return '可随时在设置中更改';
      case AppLocale.usa:
        return 'You can change this anytime in settings';
      case AppLocale.euro:
        return 'You can change this anytime in settings';
      case AppLocale.vietnam:
        return 'You can change this anytime in settings';
    }
  }

  static String getAllowPermission(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '권한 허용';
      case AppLocale.japan:
        return '権限を許可';
      case AppLocale.china:
        return '允许权限';
      case AppLocale.usa:
        return 'Allow Permission';
      case AppLocale.euro:
        return 'Allow Permission';
      case AppLocale.vietnam:
        return 'Allow Permission';
    }
  }

  static String getSkipForNow(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '나중에 하기';
      case AppLocale.japan:
        return '後で行う';
      case AppLocale.china:
        return '稍后进行';
      case AppLocale.usa:
        return 'Skip for now';
      case AppLocale.euro:
        return 'Skip for now';
      case AppLocale.vietnam:
        return 'Skip for now';
    }
  }

  static String getPermissionDeniedTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '권한이 거부되었습니다';
      case AppLocale.japan:
        return '権限が拒否されました';
      case AppLocale.china:
        return '权限被拒绝';
      case AppLocale.usa:
        return 'Permission Denied';
      case AppLocale.euro:
        return 'Permission Denied';
      case AppLocale.vietnam:
        return 'Quyền bị từ chối';
    }
  }

  static String getPermissionDeniedMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '일부 기능이 제한될 수 있습니다.\n설정에서 언제든지 권한을 변경할 수 있습니다.';
      case AppLocale.japan:
        return '一部の機能が制限される可能性があります。\n設定でいつでも権限を変更できます。';
      case AppLocale.china:
        return '部分功能可能受限。\n可随时在设置中更改权限。';
      case AppLocale.usa:
        return 'Some features may be limited.\nYou can change permissions anytime in settings.';
      case AppLocale.euro:
        return 'Some features may be limited.\nYou can change permissions anytime in settings.';
      case AppLocale.vietnam:
        return 'Some features may be limited.\\nYou can change permissions anytime in settings.';
    }
  }

  // 설정 페이지용 문자열
  static String getAllowed(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '허용됨';
      case AppLocale.japan:
        return '許可済み';
      case AppLocale.china:
        return '已允许';
      case AppLocale.usa:
        return 'Allowed';
      case AppLocale.euro:
        return 'Allowed';
      case AppLocale.vietnam:
        return 'Allowed';
    }
  }

  static String getDenied(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '거부됨';
      case AppLocale.japan:
        return '拒否済み';
      case AppLocale.china:
        return '已拒绝';
      case AppLocale.usa:
        return 'Denied';
      case AppLocale.euro:
        return 'Denied';
      case AppLocale.vietnam:
        return 'Denied';
    }
  }

  static String getCameraPermissionAlreadyGranted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '카메라 권한이 이미 허용되어 있습니다';
      case AppLocale.japan:
        return 'カメラ権限は既に許可されています';
      case AppLocale.china:
        return '相机权限已允许';
      case AppLocale.usa:
        return 'Camera permission already granted';
      case AppLocale.euro:
        return 'Camera permission already granted';
      case AppLocale.vietnam:
        return 'Camera permission already granted';
    }
  }

  static String getCameraPermissionGranted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '카메라 권한이 허용되었습니다';
      case AppLocale.japan:
        return 'カメラ権限が許可されました';
      case AppLocale.china:
        return '相机权限已允许';
      case AppLocale.usa:
        return 'Camera permission granted';
      case AppLocale.euro:
        return 'Camera permission granted';
      case AppLocale.vietnam:
        return 'Camera permission granted';
    }
  }

  static String getCameraPermissionDenied(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '카메라 권한이 거부되었습니다';
      case AppLocale.japan:
        return 'カメラ権限が拒否されました';
      case AppLocale.china:
        return '相机权限已拒绝';
      case AppLocale.usa:
        return 'Camera permission denied';
      case AppLocale.euro:
        return 'Camera permission denied';
      case AppLocale.vietnam:
        return 'Camera permission denied';
    }
  }

  static String getCameraPermissionPermanentlyDenied(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '카메라 권한이 영구적으로 거부되었습니다.\n설정 앱에서 권한을 허용해주세요.';
      case AppLocale.japan:
        return 'カメラ権限が永続的に拒否されました。\n設定アプリで権限を許可してください。';
      case AppLocale.china:
        return '相机权限已被永久拒绝。\n请在设置应用中允许权限。';
      case AppLocale.usa:
        return 'Camera permission permanently denied.\nPlease allow permission in the Settings app.';
      case AppLocale.euro:
        return 'Camera permission permanently denied.\nPlease allow permission in the Settings app.';
      case AppLocale.vietnam:
        return 'Camera permission permanently denied.\\nPlease allow permission in the Settings app.';
    }
  }
}
