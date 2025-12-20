import '../app_locale.dart';

/// Settings 관련 문자열
mixin AppStringsSettings {
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
      case AppLocale.vietnam:
        return 'Cài đặt thông báo';
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
      case AppLocale.vietnam:
        return 'Bật thông báo';
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
      case AppLocale.vietnam:
        return 'Bật hoặc tắt tất cả thông báo';
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
      case AppLocale.vietnam:
        return 'Thông báo cảnh báo hết hạn';
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
      case AppLocale.vietnam:
        return 'Thông báo 3 ngày trước khi hết hạn';
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
      case AppLocale.vietnam:
        return 'Thông báo nguy hiểm hết hạn';
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
      case AppLocale.vietnam:
        return 'Thông báo 1 ngày trước khi hết hạn';
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
      case AppLocale.vietnam:
        return 'Thông báo đã hết hạn';
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
      case AppLocale.vietnam:
        return 'Thông báo vào ngày hết hạn';
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
      case AppLocale.vietnam:
        return 'Cài đặt ứng dụng';
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
      case AppLocale.vietnam:
        return 'Cài đặt ngôn ngữ';
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
      case AppLocale.vietnam:
        return 'Xuất dữ liệu';
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
      case AppLocale.vietnam:
        return 'Sao lưu dữ liệu nguyên liệu và công thức';
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
      case AppLocale.vietnam:
        return 'Nhập dữ liệu';
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
      case AppLocale.vietnam:
        return 'Khôi phục dữ liệu đã sao lưu';
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
      case AppLocale.vietnam:
        return 'Đặt lại dữ liệu';
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
      case AppLocale.vietnam:
        return 'Xóa tất cả dữ liệu';
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
      case AppLocale.vietnam:
        return 'Lưu vào thiết bị';
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
      case AppLocale.vietnam:
        return 'Chia sẻ';
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
      case AppLocale.vietnam:
        return 'Xuất hoàn tất';
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
      case AppLocale.vietnam:
        return 'Xuất hoàn tất: Đã lưu vào $location';
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
      case AppLocale.vietnam:
        return 'Xuất thất bại';
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
      case AppLocale.vietnam:
        return 'Xuất thất bại: $error';
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
      case AppLocale.vietnam:
        return 'Chia sẻ thất bại';
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
      case AppLocale.vietnam:
        return 'Chia sẻ thất bại: $error';
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
      case AppLocale.vietnam:
        return 'Số lượng';
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
      case AppLocale.vietnam:
        return 'Xuất cơ sở dữ liệu ứng dụng công thức';
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
      case AppLocale.vietnam:
        return 'Nhập thất bại';
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
      case AppLocale.vietnam:
        return 'Nhập thất bại: $error';
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
      case AppLocale.vietnam:
        return 'Nhập dữ liệu hoàn tất';
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
      case AppLocale.vietnam:
        return 'Chỉ có thể chọn file cơ sở dữ liệu (.db).';
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
      case AppLocale.vietnam:
        return 'Đặt lại thất bại';
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
      case AppLocale.vietnam:
        return 'Đặt lại thất bại: $error';
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
      case AppLocale.vietnam:
        return 'Đặt lại';
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
      case AppLocale.vietnam:
        return 'Xem giới thiệu lại';
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
      case AppLocale.vietnam:
        return 'Xem lại cách sử dụng ứng dụng';
    }
  }

  static String getSendFeedback(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '의견 보내기';
      case AppLocale.japan:
        return 'フィードバックを送信';
      case AppLocale.china:
        return '发送反馈';
      case AppLocale.usa:
        return 'Send Feedback';
      case AppLocale.euro:
        return 'Send Feedback';
      case AppLocale.vietnam:
        return 'Gửi phản hồi';
    }
  }

  static String getSendFeedbackDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '피드백 메일을 보내주세요';
      case AppLocale.japan:
        return 'フィードバックメールを送信してください';
      case AppLocale.china:
        return '请发送反馈邮件';
      case AppLocale.usa:
        return 'Please send feedback email';
      case AppLocale.euro:
        return 'Please send feedback email';
      case AppLocale.vietnam:
        return 'Vui lòng gửi email phản hồi';
    }
  }

  static String getFeedbackEmailBody(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '문의 내용을 작성해주세요.\n\n';
      case AppLocale.japan:
        return 'お問い合わせ内容をご記入ください。\n\n';
      case AppLocale.china:
        return '请输入咨询内容。\n\n';
      case AppLocale.usa:
        return 'Please write your inquiry.\n\n';
      case AppLocale.euro:
        return 'Please write your inquiry.\n\n';
      case AppLocale.vietnam:
        return 'Vui lòng viết nội dung yêu cầu của bạn.\\n\\n';
    }
  }

  static String getFeedbackEmailSubject(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '[레시피 앱 문의]';
      case AppLocale.japan:
        return '[レシピアプリお問い合わせ]';
      case AppLocale.china:
        return '[食谱应用咨询]';
      case AppLocale.usa:
        return '[Recipe App Inquiry]';
      case AppLocale.euro:
        return '[Recipe App Inquiry]';
      case AppLocale.vietnam:
        return '[Yêu cầu ứng dụng công thức]';
    }
  }

  static String getMailAppUnavailable(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '메일 앱을 사용할 수 없습니다.';
      case AppLocale.japan:
        return 'メールアプリを使用できません。';
      case AppLocale.china:
        return '无法使用邮件应用。';
      case AppLocale.usa:
        return 'Mail app is not available.';
      case AppLocale.euro:
        return 'Mail app is not available.';
      case AppLocale.vietnam:
        return 'Ứng dụng thư không khả dụng.';
    }
  }

  static String getFeedbackEmailContactMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '아래 이메일로 문의주시면 빠른 시일 내에 답변드릴게요!\n\njeon_hyun_cheol@jalam-kr.com';
      case AppLocale.japan:
        return '以下のメールアドレスにお問い合わせいただければ、迅速に対応いたします！\n\njeon_hyun_cheol@jalam-kr.com';
      case AppLocale.china:
        return '请通过以下邮箱联系我们，我们会尽快回复！\n\njeon_hyun_cheol@jalam-kr.com';
      case AppLocale.usa:
        return 'Please contact us at the email below and we will respond promptly!\n\njeon_hyun_cheol@jalam-kr.com';
      case AppLocale.euro:
        return 'Please contact us at the email below and we will respond promptly!\n\njeon_hyun_cheol@jalam-kr.com';
      case AppLocale.vietnam:
        return 'Vui lòng liên hệ với chúng tôi qua email bên dưới và chúng tôi sẽ phản hồi nhanh chóng!\\n\\njeon_hyun_cheol@jalam-kr.com';
    }
  }

  static String getPriceChart(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격 추이';
      case AppLocale.japan:
        return '価格推移';
      case AppLocale.china:
        return '价格趋势';
      case AppLocale.usa:
        return 'Price Trend';
      case AppLocale.euro:
        return 'Price Trend';
      case AppLocale.vietnam:
        return 'Xu hướng giá';
    }
  }

  static String getDaily(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '일별';
      case AppLocale.japan:
        return '日別';
      case AppLocale.china:
        return '每日';
      case AppLocale.usa:
        return 'Daily';
      case AppLocale.euro:
        return 'Daily';
      case AppLocale.vietnam:
        return 'Hàng ngày';
    }
  }

  static String getMonthly(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '월별';
      case AppLocale.japan:
        return '月別';
      case AppLocale.china:
        return '每月';
      case AppLocale.usa:
        return 'Monthly';
      case AppLocale.euro:
        return 'Monthly';
      case AppLocale.vietnam:
        return 'Hàng tháng';
    }
  }

  static String getYearly(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '연도별';
      case AppLocale.japan:
        return '年別';
      case AppLocale.china:
        return '每年';
      case AppLocale.usa:
        return 'Yearly';
      case AppLocale.euro:
        return 'Yearly';
      case AppLocale.vietnam:
        return 'Hàng năm';
    }
  }

  static String getNoPriceData(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격 데이터가 없습니다';
      case AppLocale.japan:
        return '価格データがありません';
      case AppLocale.china:
        return '没有价格数据';
      case AppLocale.usa:
        return 'No price data available';
      case AppLocale.euro:
        return 'No price data available';
      case AppLocale.vietnam:
        return 'Không có dữ liệu giá';
    }
  }

  static String getWriteReview(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '리뷰 작성';
      case AppLocale.japan:
        return 'レビューを書く';
      case AppLocale.china:
        return '写评论';
      case AppLocale.usa:
        return 'Write Review';
      case AppLocale.euro:
        return 'Write Review';
      case AppLocale.vietnam:
        return 'Viết đánh giá';
    }
  }

  static String getWriteReviewDescription(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '앱스토어에서 별점과 리뷰를 작성해주세요';
      case AppLocale.japan:
        return 'アプリストアで評価とレビューを書いてください';
      case AppLocale.china:
        return '请在应用商店中评分和写评论';
      case AppLocale.usa:
        return 'Rate and review the app on the store';
      case AppLocale.euro:
        return 'Rate and review the app on the store';
      case AppLocale.vietnam:
        return 'Đánh giá và viết nhận xét về ứng dụng trên cửa hàng';
    }
  }

  static String getReviewError(AppLocale locale, String error) {
    switch (locale) {
      case AppLocale.korea:
        return '리뷰 작성에 실패했습니다: $error';
      case AppLocale.japan:
        return 'レビューの作成に失敗しました: $error';
      case AppLocale.china:
        return '写评论失败: $error';
      case AppLocale.usa:
        return 'Failed to write review: $error';
      case AppLocale.euro:
        return 'Failed to write review: $error';
      case AppLocale.vietnam:
        return 'Không thể viết đánh giá: $error';
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
      case AppLocale.vietnam:
        return 'Đăng nhập để đồng bộ dữ liệu của bạn';
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
      case AppLocale.vietnam:
        return 'Thư mục tải xuống';
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
      case AppLocale.vietnam:
        return 'Thư mục tài liệu';
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
      case AppLocale.vietnam:
        return 'Mẹo';
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
      case AppLocale.vietnam:
        return 'Sử dụng ảnh hóa đơn rõ ràng';
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
      case AppLocale.vietnam:
        return 'Chụp ảnh trong ánh sáng tốt';
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
      case AppLocale.vietnam:
        return 'Đảm bảo văn bản rõ ràng và dễ đọc';
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
      case AppLocale.vietnam:
        return 'Vui lòng đợi một chút...';
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
      case AppLocale.vietnam:
        return 'Hình ảnh hóa đơn';
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
      case AppLocale.vietnam:
        return '$count nguyên liệu sẽ được lưu';
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
      case AppLocale.vietnam:
        return 'Đang lưu nguyên liệu...';
    }
  }
}
