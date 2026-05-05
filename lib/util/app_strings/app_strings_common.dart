import '../app_locale.dart';

/// Common 관련 문자열
mixin AppStringsCommon {
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
      case AppLocale.chinaTraditional:
        return 'Save';
      case AppLocale.vietnam:
        return 'Lưu';
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
      case AppLocale.chinaTraditional:
        return 'Cancel';
      case AppLocale.vietnam:
        return 'Hủy';
    }
  }

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
      case AppLocale.chinaTraditional:
        return 'Cancel';
      case AppLocale.vietnam:
        return 'Hủy';
    }
  }

  static String getCopied(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '복사되었습니다';
      case AppLocale.japan:
        return 'コピーされました';
      case AppLocale.china:
        return '已复制';
      case AppLocale.usa:
        return 'Copied';
      case AppLocale.chinaTraditional:
        return 'Copied';
      case AppLocale.vietnam:
        return 'Đã sao chép';
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
      case AppLocale.chinaTraditional:
        return 'Delete';
      case AppLocale.vietnam:
        return 'Xóa';
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
      case AppLocale.chinaTraditional:
        return 'Edit';
      case AppLocale.vietnam:
        return 'Chỉnh sửa';
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
      case AppLocale.chinaTraditional:
        return 'Retry';
      case AppLocale.vietnam:
        return 'Thử lại';
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
      case AppLocale.chinaTraditional:
        return 'Delete Selected';
      case AppLocale.vietnam:
        return 'Xóa đã chọn';
    }
  }

  static String getSelectedCount(AppLocale locale, int count) {
    switch (locale) {
      case AppLocale.korea:
        return '$count개 선택됨';
      case AppLocale.japan:
        return '$count個選択されました';
      case AppLocale.china:
        return '已选择$count个';
      case AppLocale.usa:
        return '$count selected';
      case AppLocale.chinaTraditional:
        return '$count selected';
      case AppLocale.vietnam:
        return '$count đã chọn';
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
      case AppLocale.chinaTraditional:
        return 'Cost Information';
      case AppLocale.vietnam:
        return 'Thông tin chi phí';
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
      case AppLocale.chinaTraditional:
        return 'Cost per Serving';
      case AppLocale.vietnam:
        return 'Chi phí mỗi phần ăn';
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
      case AppLocale.chinaTraditional:
        return 'An error occurred';
      case AppLocale.vietnam:
        return 'Đã xảy ra lỗi';
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
      case AppLocale.chinaTraditional:
        return 'Network error occurred';
      case AppLocale.vietnam:
        return 'Đã xảy ra lỗi mạng';
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
      case AppLocale.chinaTraditional:
        return 'Try Again';
      case AppLocale.vietnam:
        return 'Thử lại';
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
      case AppLocale.chinaTraditional:
        return 'Page not found';
      case AppLocale.vietnam:
        return 'Không tìm thấy trang';
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
      case AppLocale.chinaTraditional:
        return 'The requested page does not exist or has moved.';
      case AppLocale.vietnam:
        return 'Trang được yêu cầu không tồn tại hoặc đã di chuyển.';
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
      case AppLocale.chinaTraditional:
        return 'Back to Home';
      case AppLocale.vietnam:
        return 'Về trang chủ';
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
      case AppLocale.chinaTraditional:
        return 'Ingredient Management';
      case AppLocale.vietnam:
        return 'Quản lý nguyên liệu';
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
      case AppLocale.chinaTraditional:
        return 'Recipe Management';
      case AppLocale.vietnam:
        return 'Quản lý công thức';
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
      case AppLocale.chinaTraditional:
        return 'Unit';
      case AppLocale.vietnam:
        return 'Đơn vị';
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
      case AppLocale.chinaTraditional:
        return 'Weight';
      case AppLocale.vietnam:
        return 'Trọng lượng';
    }
  }

  /// 단위 ID를 언어팩 이름으로 변환
  static String getUnitNameById(String unitId, AppLocale locale) {
    switch (unitId) {
      case '개':
        return getUnitPiece(locale);
      case '조각':
        return getUnitSlice(locale);
      case 'g':
        return 'g';
      case 'kg':
        return 'kg';
      case 'ml':
        return 'ml';
      case 'L':
        return 'L';
      default:
        return unitId;
    }
  }

  static String getUnitPiece(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '개';
      case AppLocale.japan:
        return '個';
      case AppLocale.china:
        return '个';
      case AppLocale.usa:
        return 'pcs';
      case AppLocale.chinaTraditional:
        return 'pcs';
      case AppLocale.vietnam:
        return 'pcs';
    }
  }

  static String getUnitSlice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '조각';
      case AppLocale.japan:
        return '切れ';
      case AppLocale.china:
        return '片';
      case AppLocale.usa:
        return 'slice';
      case AppLocale.chinaTraditional:
        return 'slice';
      case AppLocale.vietnam:
        return 'slice';
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
      case AppLocale.chinaTraditional:
        return 'Volume';
      case AppLocale.vietnam:
        return 'Thể tích';
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
      case AppLocale.chinaTraditional:
        return 'Count';
      case AppLocale.vietnam:
        return 'Số lượng';
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
      case AppLocale.chinaTraditional:
        return 'You have ingredients expiring soon';
      case AppLocale.vietnam:
        return 'Bạn có nguyên liệu sắp hết hạn';
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
      case AppLocale.chinaTraditional:
        return 'You have ingredients in danger of expiring';
      case AppLocale.vietnam:
        return 'Bạn có nguyên liệu đang gặp nguy hiểm về hết hạn';
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
      case AppLocale.chinaTraditional:
        return 'You have expired ingredients';
      case AppLocale.vietnam:
        return 'Bạn có nguyên liệu đã hết hạn';
    }
  }

  /// 유통기한 알림 섹션 라벨 (당일)
  static String getExpirySectionToday(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '[만료임박- 당일]';
      case AppLocale.japan:
        return '[本日期限]';
      case AppLocale.china:
        return '[当天到期]';
      case AppLocale.usa:
        return '[Expiring today]';
      case AppLocale.chinaTraditional:
        return '[Heute fällig]';
      case AppLocale.vietnam:
        return '[Hết hạn hôm nay]';
    }
  }

  /// 유통기한 알림 섹션 라벨 (1일)
  static String getExpirySectionIn1Day(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '[만료임박- 1일]';
      case AppLocale.japan:
        return '[1日後期限]';
      case AppLocale.china:
        return '[1天后到期]';
      case AppLocale.usa:
        return '[Expiring in 1 day]';
      case AppLocale.chinaTraditional:
        return '[In 1 Tag fällig]';
      case AppLocale.vietnam:
        return '[Hết hạn sau 1 ngày]';
    }
  }

  /// 유통기한 알림 섹션 라벨 (3일)
  static String getExpirySectionIn3Days(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '[만료임박- 3일]';
      case AppLocale.japan:
        return '[3日後期限]';
      case AppLocale.china:
        return '[3天后到期]';
      case AppLocale.usa:
        return '[Expiring in 3 days]';
      case AppLocale.chinaTraditional:
        return '[In 3 Tagen fällig]';
      case AppLocale.vietnam:
        return '[Hết hạn sau 3 ngày]';
    }
  }

  /// 유통기한 알림 제목
  static String getExpiryNotificationTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '[유통기한 알림]';
      case AppLocale.japan:
        return '[消費期限お知らせ]';
      case AppLocale.china:
        return '[保质期提醒]';
      case AppLocale.usa:
        return '[Expiry alert]';
      case AppLocale.chinaTraditional:
        return '[Haltbarkeitshinweis]';
      case AppLocale.vietnam:
        return '[Thông báo hết hạn]';
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
      case AppLocale.chinaTraditional:
        return 'Language Selection';
      case AppLocale.vietnam:
        return 'Chọn ngôn ngữ';
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
      case AppLocale.chinaTraditional:
        return 'Data Reset';
      case AppLocale.vietnam:
        return 'Đặt lại dữ liệu';
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
      case AppLocale.chinaTraditional:
        return 'All data will be deleted.\nThis action cannot be undone.';
      case AppLocale.vietnam:
        return 'Tất cả dữ liệu sẽ bị xóa.\\nHành động này không thể hoàn tác.';
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
      case AppLocale.chinaTraditional:
        return 'Data has been reset';
      case AppLocale.vietnam:
        return 'Dữ liệu đã được đặt lại';
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
      case AppLocale.chinaTraditional:
        return 'Confirm';
      case AppLocale.vietnam:
        return 'Xác nhận';
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
      case AppLocale.chinaTraditional:
        return 'Privacy Policy';
      case AppLocale.vietnam:
        return 'Chính sách bảo mật';
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
      case AppLocale.chinaTraditional:
        return 'Terms of Service';
      case AppLocale.vietnam:
        return 'Điều khoản dịch vụ';
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
      case AppLocale.chinaTraditional:
        return 'Wonka Team';
      case AppLocale.vietnam:
        return 'Đội Wonka';
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
      case AppLocale.chinaTraditional:
        return 'Recipe Cost Calculator App';
      case AppLocale.vietnam:
        return 'Ứng dụng tính toán chi phí công thức';
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
      case AppLocale.chinaTraditional:
        return 'Version: 1.0.0';
      case AppLocale.vietnam:
        return 'Phiên bản: 1.0.0';
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
      case AppLocale.chinaTraditional:
        return 'App Version';
      case AppLocale.vietnam:
        return 'Phiên bản ứng dụng';
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
      case AppLocale.chinaTraditional:
        return 'Developer Info';
      case AppLocale.vietnam:
        return 'Thông tin nhà phát triển';
    }
  }

  static String getPrivacyPolicyDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '개인정보 처리방침을 확인하세요';
      case AppLocale.japan:
        return 'プライバシーポリシーを確認してください';
      case AppLocale.china:
        return '请查看隐私政策';
      case AppLocale.usa:
        return 'View privacy policy';
      case AppLocale.chinaTraditional:
        return 'View privacy policy';
      case AppLocale.vietnam:
        return 'Xem chính sách bảo mật';
    }
  }

  static String getTermsOfServiceDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이용약관을 확인하세요';
      case AppLocale.japan:
        return '利用規約を確認してください';
      case AppLocale.china:
        return '请查看服务条款';
      case AppLocale.usa:
        return 'View terms of service';
      case AppLocale.chinaTraditional:
        return 'View terms of service';
      case AppLocale.vietnam:
        return 'Xem điều khoản dịch vụ';
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
      case AppLocale.chinaTraditional:
        return '$featureName feature is in progress';
      case AppLocale.vietnam:
        return '$featureName feature is in progress';
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
      case AppLocale.chinaTraditional:
        return 'All';
      case AppLocale.vietnam:
        return 'Tất cả';
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
      case AppLocale.chinaTraditional:
        return 'Ingredient Cost';
      case AppLocale.vietnam:
        return 'Chi phí nguyên liệu';
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
      case AppLocale.chinaTraditional:
        return 'Sauce Cost';
      case AppLocale.vietnam:
        return 'Chi phí nước sốt';
    }
  }

  /// 날짜 포맷 (간단 예시)
  static String formatDate(DateTime date, AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '${date.year}년 ${date.month}월 ${date.day}일';
      case AppLocale.vietnam:
        return '${date.year}-${date.month}-${date.day}';
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
      case AppLocale.chinaTraditional:
        return 'Alarm Time Setting';
      case AppLocale.vietnam:
        return 'Cài đặt thời gian báo thức';
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
      case AppLocale.chinaTraditional:
        return 'Input Amount';
      case AppLocale.vietnam:
        return 'Số lượng nhập';
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
      case AppLocale.chinaTraditional:
        return 'Cost';
      case AppLocale.vietnam:
        return 'Chi phí';
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
      case AppLocale.chinaTraditional:
        return 'Calculated Cost';
      case AppLocale.vietnam:
        return 'Chi phí đã tính';
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
      case AppLocale.chinaTraditional:
        return 'Today';
      case AppLocale.vietnam:
        return 'Hôm nay';
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
      case AppLocale.chinaTraditional:
        return 'Yesterday';
      case AppLocale.vietnam:
        return 'Hôm qua';
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
      case AppLocale.chinaTraditional:
        return '$days days ago';
      case AppLocale.vietnam:
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
      case AppLocale.chinaTraditional:
        return '${day}.${month}';
      case AppLocale.vietnam:
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
      case AppLocale.chinaTraditional:
        return 'Ingredient';
      case AppLocale.vietnam:
        return 'Nguyên liệu';
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
      case AppLocale.chinaTraditional:
        return 'Sauce';
      case AppLocale.vietnam:
        return 'Nước sốt';
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
      case AppLocale.chinaTraditional:
        return 'Create different style recipes with same ingredients';
      case AppLocale.vietnam:
        return 'Tạo công thức phong cách khác với cùng nguyên liệu';
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
      case AppLocale.chinaTraditional:
        return 'Use selected ingredients to generate recipes in different cooking styles';
      case AppLocale.vietnam:
        return 'Sử dụng nguyên liệu đã chọn để tạo công thức với các phong cách nấu ăn khác nhau';
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
      case AppLocale.chinaTraditional:
        return 'Korean Style';
      case AppLocale.vietnam:
        return 'Phong cách Hàn Quốc';
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
      case AppLocale.chinaTraditional:
        return 'Fusion Style';
      case AppLocale.vietnam:
        return 'Phong cách Fusion';
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
      case AppLocale.chinaTraditional:
        return 'View Saved AI Recipes';
      case AppLocale.vietnam:
        return 'Xem công thức AI đã lưu';
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
      case AppLocale.chinaTraditional:
        return 'You can view and manage generated AI recipes';
      case AppLocale.vietnam:
        return 'Bạn có thể xem và quản lý các công thức AI đã tạo';
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
      case AppLocale.chinaTraditional:
        return 'View Saved Recipes';
      case AppLocale.vietnam:
        return 'Xem công thức đã lưu';
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
      case AppLocale.chinaTraditional:
        return 'Fusion';
      case AppLocale.vietnam:
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
      case AppLocale.chinaTraditional:
        return 'Error occurred while preparing bulk ingredient addition';
      case AppLocale.vietnam:
        return 'Đã xảy ra lỗi khi chuẩn bị thêm nguyên liệu hàng loạt';
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
      case AppLocale.chinaTraditional:
        return 'An error occurred while deleting: $error';
      case AppLocale.vietnam:
        return 'An error occurred while deleting: $error';
    }
  }

  /// 등록 — pill 버튼 라벨 ("+ 등록")
  static String getRegister(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '등록';
      case AppLocale.japan:
        return '登録';
      case AppLocale.china:
        return '注册';
      case AppLocale.usa:
        return 'Register';
      case AppLocale.chinaTraditional:
        return 'Register';
      case AppLocale.vietnam:
        return 'Đăng ký';
    }
  }

  /// 총 — "총 ₩731,330" 와 같은 합계 prefix
  static String getTotal(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총';
      case AppLocale.japan:
        return '合計';
      case AppLocale.china:
        return '总';
      case AppLocale.usa:
        return 'Total';
      case AppLocale.chinaTraditional:
        return 'Total';
      case AppLocale.vietnam:
        return 'Tổng';
    }
  }

  /// 정렬 (버튼 라벨)
  static String getSort(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '정렬';
      case AppLocale.japan:
        return '並び替え';
      case AppLocale.china:
        return '排序';
      case AppLocale.usa:
        return 'Sort';
      case AppLocale.chinaTraditional:
        return 'Sort';
      case AppLocale.vietnam:
        return 'Sắp xếp';
    }
  }

  /// 정렬 기준 (시트 타이틀)
  static String getSortBy(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '정렬 기준';
      case AppLocale.japan:
        return '並び替え基準';
      case AppLocale.china:
        return '排序方式';
      case AppLocale.usa:
        return 'Sort By';
      case AppLocale.chinaTraditional:
        return 'Sort By';
      case AppLocale.vietnam:
        return 'Sắp xếp theo';
    }
  }

  /// 유통기한 임박순
  static String getSortExpirySoonest(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '유통기한 임박순';
      case AppLocale.japan:
        return '消費期限が近い順';
      case AppLocale.china:
        return '保质期临近';
      case AppLocale.usa:
        return 'Expiring Soonest';
      case AppLocale.chinaTraditional:
        return 'Expiring Soonest';
      case AppLocale.vietnam:
        return 'Sắp hết hạn';
    }
  }

  /// 최신 등록순
  static String getSortNewest(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '최신 등록순';
      case AppLocale.japan:
        return '新しい順';
      case AppLocale.china:
        return '最新';
      case AppLocale.usa:
        return 'Newest';
      case AppLocale.chinaTraditional:
        return 'Newest';
      case AppLocale.vietnam:
        return 'Mới nhất';
    }
  }

  /// 가격 높은순
  static String getSortPriceHigh(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격 높은순';
      case AppLocale.japan:
        return '価格が高い順';
      case AppLocale.china:
        return '价格从高到低';
      case AppLocale.usa:
        return 'Price High to Low';
      case AppLocale.chinaTraditional:
        return 'Price High to Low';
      case AppLocale.vietnam:
        return 'Giá cao nhất';
    }
  }

  /// 가격 낮은순
  static String getSortPriceLow(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격 낮은순';
      case AppLocale.japan:
        return '価格が安い順';
      case AppLocale.china:
        return '价格从低到高';
      case AppLocale.usa:
        return 'Price Low to High';
      case AppLocale.chinaTraditional:
        return 'Price Low to High';
      case AppLocale.vietnam:
        return 'Giá thấp nhất';
    }
  }

  /// 이름 가나다순
  static String getSortNameAsc(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이름순';
      case AppLocale.japan:
        return '名前順';
      case AppLocale.china:
        return '名称';
      case AppLocale.usa:
        return 'Name (A→Z)';
      case AppLocale.chinaTraditional:
        return 'Name (A→Z)';
      case AppLocale.vietnam:
        return 'Theo tên';
    }
  }

  /// 검색 결과 없음
  static String getNoSearchResults(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '검색 결과가 없습니다';
      case AppLocale.japan:
        return '検索結果がありません';
      case AppLocale.china:
        return '没有搜索结果';
      case AppLocale.usa:
        return 'No results found';
      case AppLocale.chinaTraditional:
        return 'No results found';
      case AppLocale.vietnam:
        return 'Không có kết quả';
    }
  }

  /// 다른 검색어 안내
  static String getTryDifferentKeyword(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '다른 검색어를 입력해 보세요';
      case AppLocale.japan:
        return '別のキーワードをお試しください';
      case AppLocale.china:
        return '请尝试其他关键词';
      case AppLocale.usa:
        return 'Try a different keyword';
      case AppLocale.chinaTraditional:
        return 'Try a different keyword';
      case AppLocale.vietnam:
        return 'Hãy thử từ khóa khác';
    }
  }

  /// 단위 라벨
  static String getCategory(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '분류';
      case AppLocale.japan:
        return '分類';
      case AppLocale.china:
        return '分类';
      case AppLocale.usa:
        return 'Category';
      case AppLocale.chinaTraditional:
        return 'Category';
      case AppLocale.vietnam:
        return 'Phân loại';
    }
  }

  /// 단가 라벨
  static String getUnitPrice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '단가';
      case AppLocale.japan:
        return '単価';
      case AppLocale.china:
        return '单价';
      case AppLocale.usa:
        return 'Unit Price';
      case AppLocale.chinaTraditional:
        return 'Unit Price';
      case AppLocale.vietnam:
        return 'Đơn giá';
    }
  }

  /// 현재 재고 라벨
  static String getCurrentStock(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '현재 재고';
      case AppLocale.japan:
        return '現在の在庫';
      case AppLocale.china:
        return '当前库存';
      case AppLocale.usa:
        return 'Current Stock';
      case AppLocale.chinaTraditional:
        return 'Current Stock';
      case AppLocale.vietnam:
        return 'Tồn kho';
    }
  }

  /// 재고 라벨
  static String getStock(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재고';
      case AppLocale.japan:
        return '在庫';
      case AppLocale.china:
        return '库存';
      case AppLocale.usa:
        return 'Stock';
      case AppLocale.chinaTraditional:
        return 'Stock';
      case AppLocale.vietnam:
        return 'Tồn kho';
    }
  }

  /// 구매량 (짧은 라벨 — 카드/통계 표시용)
  static String getPurchaseAmountShort(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매량';
      case AppLocale.japan:
        return '購入量';
      case AppLocale.china:
        return '购买量';
      case AppLocale.usa:
        return 'Purchased';
      case AppLocale.chinaTraditional:
        return 'Purchased';
      case AppLocale.vietnam:
        return 'Đã mua';
    }
  }

  /// 등록하기 (큰 primary 버튼)
  static String getDoRegister(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '등록하기';
      case AppLocale.japan:
        return '登録する';
      case AppLocale.china:
        return '注册';
      case AppLocale.usa:
        return 'Register';
      case AppLocale.chinaTraditional:
        return 'Register';
      case AppLocale.vietnam:
        return 'Đăng ký';
    }
  }

  /// 저장하기 (큰 primary 버튼)
  static String getSaveChanges(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '저장하기';
      case AppLocale.japan:
        return '保存する';
      case AppLocale.china:
        return '保存';
      case AppLocale.usa:
        return 'Save Changes';
      case AppLocale.chinaTraditional:
        return 'Save Changes';
      case AppLocale.vietnam:
        return 'Lưu';
    }
  }

  /// "사용 중인 곳"
  static String getUsedIn(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '사용 중인 곳';
      case AppLocale.japan:
        return '使用中';
      case AppLocale.china:
        return '使用位置';
      case AppLocale.usa:
        return 'Used In';
      case AppLocale.chinaTraditional:
        return 'Used In';
      case AppLocale.vietnam:
        return 'Đang dùng tại';
    }
  }

  /// "사용 중인 곳" 보조 — "{sauces}개 소스 · {recipes}개 레시피"
  static String getUsedInSummary(
    AppLocale locale,
    int sauceCount,
    int recipeCount,
  ) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 $sauceCount개 · 레시피 $recipeCount개';
      case AppLocale.japan:
        return 'ソース$sauceCount個 · レシピ$recipeCount個';
      case AppLocale.china:
        return '酱汁 $sauceCount · 食谱 $recipeCount';
      case AppLocale.usa:
        return '$sauceCount sauces · $recipeCount recipes';
      case AppLocale.chinaTraditional:
        return '$sauceCount sauces · $recipeCount recipes';
      case AppLocale.vietnam:
        return '$sauceCount sốt · $recipeCount công thức';
    }
  }

  /// "이 재료가 사용된 곳이 없습니다"
  static String getNotUsedAnywhere(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이 재료를 사용하는 항목이 없습니다';
      case AppLocale.japan:
        return 'この材料を使う項目はありません';
      case AppLocale.china:
        return '没有使用此食材的项目';
      case AppLocale.usa:
        return 'Not used in any sauce or recipe yet';
      case AppLocale.chinaTraditional:
        return 'Not used in any sauce or recipe yet';
      case AppLocale.vietnam:
        return 'Chưa được dùng trong sốt hoặc công thức nào';
    }
  }

  /// 이 재료 {amount} 사용 (소스/레시피 사용량 라벨)
  static String getUsesThisIngredient(AppLocale locale, String amount) {
    switch (locale) {
      case AppLocale.korea:
        return '이 재료 $amount 사용';
      case AppLocale.japan:
        return 'この材料 $amount 使用';
      case AppLocale.china:
        return '使用此食材 $amount';
      case AppLocale.usa:
        return 'Uses $amount of this ingredient';
      case AppLocale.chinaTraditional:
        return 'Uses $amount of this ingredient';
      case AppLocale.vietnam:
        return 'Dùng $amount nguyên liệu này';
    }
  }

  /// 마진율
  static String getMarginRate(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '마진율';
      case AppLocale.japan:
        return 'マージン率';
      case AppLocale.china:
        return '利润率';
      case AppLocale.usa:
        return 'Margin';
      case AppLocale.chinaTraditional:
        return 'Margin';
      case AppLocale.vietnam:
        return 'Tỷ lệ lợi nhuận';
    }
  }

  /// 예상 마진율
  static String getExpectedMargin(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '예상 마진율';
      case AppLocale.japan:
        return '予想マージン率';
      case AppLocale.china:
        return '预计利润率';
      case AppLocale.usa:
        return 'Expected Margin';
      case AppLocale.chinaTraditional:
        return 'Expected Margin';
      case AppLocale.vietnam:
        return 'Lợi nhuận dự kiến';
    }
  }

  /// 판매가
  static String getSellPrice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '판매가';
      case AppLocale.japan:
        return '販売価格';
      case AppLocale.china:
        return '销售价';
      case AppLocale.usa:
        return 'Sell Price';
      case AppLocale.chinaTraditional:
        return 'Sell Price';
      case AppLocale.vietnam:
        return 'Giá bán';
    }
  }

  /// 판매 (카드 short)
  static String getSell(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '판매';
      case AppLocale.japan:
        return '販売';
      case AppLocale.china:
        return '销售';
      case AppLocale.usa:
        return 'Sell';
      case AppLocale.chinaTraditional:
        return 'Sell';
      case AppLocale.vietnam:
        return 'Bán';
    }
  }

  /// 총 원가
  static String getTotalCostLabel(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '총 원가';
      case AppLocale.japan:
        return '合計原価';
      case AppLocale.china:
        return '总成本';
      case AppLocale.usa:
        return 'Total Cost';
      case AppLocale.chinaTraditional:
        return 'Total Cost';
      case AppLocale.vietnam:
        return 'Tổng chi phí';
    }
  }

  /// 원가 구성
  static String getCostComposition(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '원가 구성';
      case AppLocale.japan:
        return '原価構成';
      case AppLocale.china:
        return '成本构成';
      case AppLocale.usa:
        return 'Cost Composition';
      case AppLocale.chinaTraditional:
        return 'Cost Composition';
      case AppLocale.vietnam:
        return 'Cấu trúc chi phí';
    }
  }

  /// 1인 이익
  static String getProfitPerOne(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '1인 이익';
      case AppLocale.japan:
        return '1人利益';
      case AppLocale.china:
        return '单人利润';
      case AppLocale.usa:
        return 'Profit per Serving';
      case AppLocale.chinaTraditional:
        return 'Profit per Serving';
      case AppLocale.vietnam:
        return 'Lợi nhuận/suất';
    }
  }

  /// 판매가 시뮬레이션
  static String getSellPriceSimulation(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '판매가 시뮬레이션';
      case AppLocale.japan:
        return '販売価格シミュレーション';
      case AppLocale.china:
        return '售价模拟';
      case AppLocale.usa:
        return 'Sell Price Simulation';
      case AppLocale.chinaTraditional:
        return 'Sell Price Simulation';
      case AppLocale.vietnam:
        return 'Mô phỏng giá bán';
    }
  }

  /// 재료 선택 (시트 타이틀)
  static String getSelectIngredientSheet(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 선택';
      case AppLocale.japan:
        return '材料選択';
      case AppLocale.china:
        return '选择食材';
      case AppLocale.usa:
        return 'Select Ingredient';
      case AppLocale.chinaTraditional:
        return 'Select Ingredient';
      case AppLocale.vietnam:
        return 'Chọn nguyên liệu';
    }
  }

  /// 소스 선택 (시트 타이틀)
  static String getSelectSauceSheet(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 선택';
      case AppLocale.japan:
        return 'ソース選択';
      case AppLocale.china:
        return '选择酱料';
      case AppLocale.usa:
        return 'Select Sauce';
      case AppLocale.chinaTraditional:
        return 'Select Sauce';
      case AppLocale.vietnam:
        return 'Chọn nước sốt';
    }
  }

  /// 재료 추가 (섹션 헤더 버튼)
  static String getAddIngredientSection(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 추가';
      case AppLocale.japan:
        return '材料追加';
      case AppLocale.china:
        return '添加食材';
      case AppLocale.usa:
        return 'Add Ingredient';
      case AppLocale.chinaTraditional:
        return 'Add Ingredient';
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu';
    }
  }

  /// 소스 추가 (섹션 헤더 버튼)
  static String getAddSauceSection(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 추가';
      case AppLocale.japan:
        return 'ソース追加';
      case AppLocale.china:
        return '添加酱料';
      case AppLocale.usa:
        return 'Add Sauce';
      case AppLocale.chinaTraditional:
        return 'Add Sauce';
      case AppLocale.vietnam:
        return 'Thêm nước sốt';
    }
  }

  /// 추가 (짧은 버튼)
  static String getAddShort(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '추가';
      case AppLocale.japan:
        return '追加';
      case AppLocale.china:
        return '添加';
      case AppLocale.usa:
        return 'Add';
      case AppLocale.chinaTraditional:
        return 'Add';
      case AppLocale.vietnam:
        return 'Thêm';
    }
  }

  /// 재료를 1개 이상 추가하세요
  static String getAtLeastOneIngredient(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료를 1개 이상 추가하세요';
      case AppLocale.japan:
        return '材料を1つ以上追加してください';
      case AppLocale.china:
        return '请添加至少一种食材';
      case AppLocale.usa:
        return 'Add at least one ingredient';
      case AppLocale.chinaTraditional:
        return 'Add at least one ingredient';
      case AppLocale.vietnam:
        return 'Thêm ít nhất 1 nguyên liệu';
    }
  }

  /// 재료 또는 소스를 추가해주세요
  static String getAddIngredientOrSauce(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '재료 또는 소스를 추가해주세요';
      case AppLocale.japan:
        return '材料またはソースを追加してください';
      case AppLocale.china:
        return '请添加食材或酱料';
      case AppLocale.usa:
        return 'Add ingredients or sauces';
      case AppLocale.chinaTraditional:
        return 'Add ingredients or sauces';
      case AppLocale.vietnam:
        return 'Thêm nguyên liệu hoặc nước sốt';
    }
  }

  /// 소스 만들기 (페이지 타이틀)
  static String getMakeSauceTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 만들기';
      case AppLocale.japan:
        return 'ソース作成';
      case AppLocale.china:
        return '制作酱料';
      case AppLocale.usa:
        return 'Make Sauce';
      case AppLocale.chinaTraditional:
        return 'Make Sauce';
      case AppLocale.vietnam:
        return 'Tạo nước sốt';
    }
  }

  /// 구성 재료 (소스 만들기의 섹션)
  static String getCompositionIngredients(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구성 재료';
      case AppLocale.japan:
        return '構成材料';
      case AppLocale.china:
        return '配料';
      case AppLocale.usa:
        return 'Ingredients';
      case AppLocale.chinaTraditional:
        return 'Ingredients';
      case AppLocale.vietnam:
        return 'Nguyên liệu';
    }
  }

  /// 공유
  static String getShare(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '공유';
      case AppLocale.japan:
        return '共有';
      case AppLocale.china:
        return '分享';
      case AppLocale.usa:
        return 'Share';
      case AppLocale.chinaTraditional:
        return 'Share';
      case AppLocale.vietnam:
        return 'Chia sẻ';
    }
  }

  /// 소스 이름 (필드 라벨)
  static String getSauceName(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 이름';
      case AppLocale.japan:
        return 'ソース名';
      case AppLocale.china:
        return '酱料名称';
      case AppLocale.usa:
        return 'Sauce Name';
      case AppLocale.chinaTraditional:
        return 'Sauce Name';
      case AppLocale.vietnam:
        return 'Tên nước sốt';
    }
  }

  /// 소스 이름 입력 placeholder (예: 제육 양념)
  static String getSauceNamePlaceholder(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '예: 제육 양념';
      case AppLocale.japan:
        return '例: 豚肉のたれ';
      case AppLocale.china:
        return '例如:猪肉腌料';
      case AppLocale.usa:
        return 'e.g., Pork marinade';
      case AppLocale.chinaTraditional:
        return 'e.g., Pork marinade';
      case AppLocale.vietnam:
        return 'VD: Sốt thịt heo';
    }
  }

  /// 소스 수정 (페이지 타이틀)
  static String getEditSauceTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 수정';
      case AppLocale.japan:
        return 'ソース編集';
      case AppLocale.china:
        return '编辑酱料';
      case AppLocale.usa:
        return 'Edit Sauce';
      case AppLocale.chinaTraditional:
        return 'Edit Sauce';
      case AppLocale.vietnam:
        return 'Sửa nước sốt';
    }
  }

  /// 소스 삭제 (다이얼로그 타이틀 / 액션)
  static String getDeleteSauce(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 삭제';
      case AppLocale.japan:
        return 'ソース削除';
      case AppLocale.china:
        return '删除酱料';
      case AppLocale.usa:
        return 'Delete Sauce';
      case AppLocale.chinaTraditional:
        return 'Delete Sauce';
      case AppLocale.vietnam:
        return 'Xóa nước sốt';
    }
  }

  /// 소스 삭제 확인 메시지 ("'{name}' 소스를 삭제하시겠습니까?")
  static String getDeleteSauceConfirm(AppLocale locale, String name) {
    switch (locale) {
      case AppLocale.korea:
        return "'$name' 소스를 삭제하시겠습니까?";
      case AppLocale.japan:
        return "'$name' ソースを削除しますか?";
      case AppLocale.china:
        return "确定要删除 '$name' 酱料吗?";
      case AppLocale.usa:
        return "Delete sauce '$name'?";
      case AppLocale.chinaTraditional:
        return "Delete sauce '$name'?";
      case AppLocale.vietnam:
        return "Xóa nước sốt '$name'?";
    }
  }

  /// 소스를 삭제했습니다 (스낵바)
  static String getSauceDeleted(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스를 삭제했습니다';
      case AppLocale.japan:
        return 'ソースを削除しました';
      case AppLocale.china:
        return '已删除酱料';
      case AppLocale.usa:
        return 'Sauce deleted';
      case AppLocale.chinaTraditional:
        return 'Sauce deleted';
      case AppLocale.vietnam:
        return 'Đã xóa nước sốt';
    }
  }

  /// 소스 이름을 입력해주세요 (검증 메시지)
  static String getSauceNameRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '소스 이름을 입력해주세요';
      case AppLocale.japan:
        return 'ソース名を入力してください';
      case AppLocale.china:
        return '请输入酱料名称';
      case AppLocale.usa:
        return 'Please enter sauce name';
      case AppLocale.chinaTraditional:
        return 'Please enter sauce name';
      case AppLocale.vietnam:
        return 'Vui lòng nhập tên nước sốt';
    }
  }
}
