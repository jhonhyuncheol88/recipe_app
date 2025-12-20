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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
        return 'You have expired ingredients';
      case AppLocale.vietnam:
        return 'Bạn có nguyên liệu đã hết hạn';
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
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
      case AppLocale.euro:
        return 'An error occurred while deleting: $error';
      case AppLocale.vietnam:
        return 'An error occurred while deleting: $error';
    }
  }
}
