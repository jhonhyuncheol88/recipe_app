import '../app_locale.dart';

/// 광고 제거 일회성 결제 (RevenueCat) 관련 라벨. 6 로케일.
mixin AppStringsPremium {
  static String getPremiumMenuTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고 제거';
      case AppLocale.japan:
        return '広告を削除';
      case AppLocale.china:
        return '移除广告';
      case AppLocale.usa:
        return 'Remove Ads';
      case AppLocale.chinaTraditional:
        return 'Werbung entfernen';
      case AppLocale.vietnam:
        return 'Xóa quảng cáo';
    }
  }

  static String getPremiumMenuSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '일회성 결제로 평생 광고 없이';
      case AppLocale.japan:
        return '一度の購入で永久に広告なし';
      case AppLocale.china:
        return '一次付费，永久无广告';
      case AppLocale.usa:
        return 'One-time purchase, ad-free forever';
      case AppLocale.chinaTraditional:
        return 'Einmalkauf, für immer werbefrei';
      case AppLocale.vietnam:
        return 'Mua một lần, không quảng cáo trọn đời';
    }
  }

  static String getPremiumPageTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고 제거 구매';
      case AppLocale.japan:
        return '広告削除を購入';
      case AppLocale.china:
        return '购买移除广告';
      case AppLocale.usa:
        return 'Remove Ads';
      case AppLocale.chinaTraditional:
        return 'Werbung entfernen';
      case AppLocale.vietnam:
        return 'Mua xóa quảng cáo';
    }
  }

  static String getPremiumBenefitNoAds(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '모든 광고 제거';
      case AppLocale.japan:
        return 'すべての広告を削除';
      case AppLocale.china:
        return '移除所有广告';
      case AppLocale.usa:
        return 'Remove all ads';
      case AppLocale.chinaTraditional:
        return 'Alle Werbung entfernen';
      case AppLocale.vietnam:
        return 'Xóa toàn bộ quảng cáo';
    }
  }

  static String getPremiumBenefitForever(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '평생 사용 (한 번 결제)';
      case AppLocale.japan:
        return '永久に使用 (一度の支払い)';
      case AppLocale.china:
        return '永久使用 (一次付款)';
      case AppLocale.usa:
        return 'Lifetime access (single payment)';
      case AppLocale.chinaTraditional:
        return 'Lebenslanger Zugriff (einmalige Zahlung)';
      case AppLocale.vietnam:
        return 'Sử dụng trọn đời (thanh toán một lần)';
    }
  }

  static String getPremiumBenefitFamilyShare(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가족 공유 지원';
      case AppLocale.japan:
        return 'ファミリー共有対応';
      case AppLocale.china:
        return '支持家庭共享';
      case AppLocale.usa:
        return 'Family Sharing supported';
      case AppLocale.chinaTraditional:
        return 'Familienfreigabe unterstützt';
      case AppLocale.vietnam:
        return 'Hỗ trợ chia sẻ gia đình';
    }
  }

  static String getPremiumLoadingPrice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격을 불러오는 중...';
      case AppLocale.japan:
        return '価格を読み込み中...';
      case AppLocale.china:
        return '正在加载价格...';
      case AppLocale.usa:
        return 'Loading price...';
      case AppLocale.chinaTraditional:
        return 'Preis wird geladen...';
      case AppLocale.vietnam:
        return 'Đang tải giá...';
    }
  }

  static String getPremiumPriceUnavailable(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '가격을 불러올 수 없습니다';
      case AppLocale.japan:
        return '価格を読み込めません';
      case AppLocale.china:
        return '无法加载价格';
      case AppLocale.usa:
        return 'Unable to load price';
      case AppLocale.chinaTraditional:
        return 'Preis konnte nicht geladen werden';
      case AppLocale.vietnam:
        return 'Không tải được giá';
    }
  }

  static String getPremiumPurchaseButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매하기';
      case AppLocale.japan:
        return '購入する';
      case AppLocale.china:
        return '立即购买';
      case AppLocale.usa:
        return 'Purchase';
      case AppLocale.chinaTraditional:
        return 'Kaufen';
      case AppLocale.vietnam:
        return 'Mua ngay';
    }
  }

  static String getPremiumRestoreButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매 복원';
      case AppLocale.japan:
        return '購入を復元';
      case AppLocale.china:
        return '恢复购买';
      case AppLocale.usa:
        return 'Restore Purchase';
      case AppLocale.chinaTraditional:
        return 'Kauf wiederherstellen';
      case AppLocale.vietnam:
        return 'Khôi phục mua hàng';
    }
  }

  static String getPremiumPurchasing(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매 진행 중...';
      case AppLocale.japan:
        return '購入処理中...';
      case AppLocale.china:
        return '正在购买...';
      case AppLocale.usa:
        return 'Processing purchase...';
      case AppLocale.chinaTraditional:
        return 'Kauf wird verarbeitet...';
      case AppLocale.vietnam:
        return 'Đang xử lý...';
    }
  }

  static String getPremiumRestoring(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '복원 중...';
      case AppLocale.japan:
        return '復元中...';
      case AppLocale.china:
        return '正在恢复...';
      case AppLocale.usa:
        return 'Restoring...';
      case AppLocale.chinaTraditional:
        return 'Wird wiederhergestellt...';
      case AppLocale.vietnam:
        return 'Đang khôi phục...';
    }
  }

  static String getPremiumAlreadyOwnedTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이미 구매하셨습니다';
      case AppLocale.japan:
        return 'すでに購入済みです';
      case AppLocale.china:
        return '您已购买';
      case AppLocale.usa:
        return 'You already own this';
      case AppLocale.chinaTraditional:
        return 'Sie besitzen dies bereits';
      case AppLocale.vietnam:
        return 'Bạn đã sở hữu';
    }
  }

  static String getPremiumAlreadyOwnedSubtitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '광고가 표시되지 않습니다. 다른 기기에서도 같은 계정으로 로그인하면 자동 적용됩니다.';
      case AppLocale.japan:
        return '広告は表示されません。他のデバイスでも同じアカウントでログインすると自動適用されます。';
      case AppLocale.china:
        return '已无广告。在其他设备上使用相同账户登录会自动应用。';
      case AppLocale.usa:
        return 'Ads are removed. Sign in with the same account on other devices to apply automatically.';
      case AppLocale.chinaTraditional:
        return 'Werbung ist entfernt. Melden Sie sich auf anderen Geräten mit demselben Konto an, um die Funktion zu übernehmen.';
      case AppLocale.vietnam:
        return 'Quảng cáo đã bị xóa. Đăng nhập cùng tài khoản trên thiết bị khác để áp dụng tự động.';
    }
  }

  static String getPremiumPurchasedAt(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매일';
      case AppLocale.japan:
        return '購入日';
      case AppLocale.china:
        return '购买日期';
      case AppLocale.usa:
        return 'Purchased on';
      case AppLocale.chinaTraditional:
        return 'Gekauft am';
      case AppLocale.vietnam:
        return 'Ngày mua';
    }
  }

  static String getPremiumLoginRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '결제는 로그인 후 가능합니다';
      case AppLocale.japan:
        return 'お支払いはログイン後に可能です';
      case AppLocale.china:
        return '请登录后再付款';
      case AppLocale.usa:
        return 'Sign in to continue with purchase';
      case AppLocale.chinaTraditional:
        return 'Bitte melden Sie sich an, um fortzufahren';
      case AppLocale.vietnam:
        return 'Vui lòng đăng nhập để tiếp tục thanh toán';
    }
  }

  static String getPremiumErrorPending(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '결제가 대기 중입니다. 보호자 승인을 기다리는 중일 수 있습니다.';
      case AppLocale.japan:
        return '支払いが保留中です。保護者の承認を待っている可能性があります。';
      case AppLocale.china:
        return '付款待处理中,可能正在等待家长批准。';
      case AppLocale.usa:
        return 'Payment is pending — it may be waiting for parental approval.';
      case AppLocale.chinaTraditional:
        return 'Zahlung ausstehend — wartet möglicherweise auf elterliche Genehmigung.';
      case AppLocale.vietnam:
        return 'Thanh toán đang chờ — có thể đang chờ phụ huynh phê duyệt.';
    }
  }

  static String getPremiumErrorNetwork(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '네트워크 오류 — 다시 시도해주세요';
      case AppLocale.japan:
        return 'ネットワークエラー — もう一度お試しください';
      case AppLocale.china:
        return '网络错误 — 请重试';
      case AppLocale.usa:
        return 'Network error — please try again';
      case AppLocale.chinaTraditional:
        return 'Netzwerkfehler — bitte erneut versuchen';
      case AppLocale.vietnam:
        return 'Lỗi mạng — vui lòng thử lại';
    }
  }

  static String getPremiumErrorStore(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '스토어 연결에 실패했습니다. 잠시 후 다시 시도해주세요.';
      case AppLocale.japan:
        return 'ストアへの接続に失敗しました。しばらく経ってから再度お試しください。';
      case AppLocale.china:
        return '连接商店失败,请稍后重试。';
      case AppLocale.usa:
        return 'Could not connect to the store. Please try again later.';
      case AppLocale.chinaTraditional:
        return 'Verbindung zum Store fehlgeschlagen. Bitte versuchen Sie es später erneut.';
      case AppLocale.vietnam:
        return 'Không kết nối được đến cửa hàng. Vui lòng thử lại sau.';
    }
  }

  static String getPremiumErrorAlready(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이미 구매한 상품입니다. 복원 버튼을 눌러주세요.';
      case AppLocale.japan:
        return 'すでに購入済みの商品です。復元ボタンをタップしてください。';
      case AppLocale.china:
        return '此商品已购买。请点击恢复按钮。';
      case AppLocale.usa:
        return 'You already purchased this. Please tap "Restore Purchase".';
      case AppLocale.chinaTraditional:
        return 'Sie haben dies bereits gekauft. Bitte tippen Sie auf "Kauf wiederherstellen".';
      case AppLocale.vietnam:
        return 'Bạn đã mua sản phẩm này. Vui lòng nhấn "Khôi phục mua hàng".';
    }
  }

  static String getPremiumErrorNotReady(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '결제 시스템이 준비되지 않았습니다. 잠시 후 다시 시도해주세요.';
      case AppLocale.japan:
        return '決済システムの準備ができていません。しばらく経ってから再度お試しください。';
      case AppLocale.china:
        return '支付系统尚未就绪,请稍后重试。';
      case AppLocale.usa:
        return 'Payment system not ready. Please try again later.';
      case AppLocale.chinaTraditional:
        return 'Zahlungssystem ist nicht bereit. Bitte versuchen Sie es später erneut.';
      case AppLocale.vietnam:
        return 'Hệ thống thanh toán chưa sẵn sàng. Vui lòng thử lại sau.';
    }
  }

  static String getPremiumErrorUnknown(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '알 수 없는 오류가 발생했습니다';
      case AppLocale.japan:
        return '不明なエラーが発生しました';
      case AppLocale.china:
        return '发生未知错误';
      case AppLocale.usa:
        return 'An unknown error occurred';
      case AppLocale.chinaTraditional:
        return 'Ein unbekannter Fehler ist aufgetreten';
      case AppLocale.vietnam:
        return 'Đã xảy ra lỗi không xác định';
    }
  }

  static String getPremiumRestoreSuccess(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '구매 내역을 복원했습니다';
      case AppLocale.japan:
        return '購入履歴を復元しました';
      case AppLocale.china:
        return '已恢复购买记录';
      case AppLocale.usa:
        return 'Purchases restored';
      case AppLocale.chinaTraditional:
        return 'Käufe wiederhergestellt';
      case AppLocale.vietnam:
        return 'Đã khôi phục mua hàng';
    }
  }

  static String getPremiumRestoreNoPurchase(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '복원할 구매 내역이 없습니다';
      case AppLocale.japan:
        return '復元する購入履歴がありません';
      case AppLocale.china:
        return '没有可恢复的购买记录';
      case AppLocale.usa:
        return 'No purchases to restore';
      case AppLocale.chinaTraditional:
        return 'Keine Käufe zum Wiederherstellen';
      case AppLocale.vietnam:
        return 'Không có giao dịch nào để khôi phục';
    }
  }

  static String getPremiumTermsNotice(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '결제는 Apple ID 또는 Google 계정으로 청구됩니다.';
      case AppLocale.japan:
        return 'お支払いは Apple ID または Google アカウントに請求されます。';
      case AppLocale.china:
        return '付款将通过您的 Apple ID 或 Google 账户结算。';
      case AppLocale.usa:
        return 'Payment will be charged to your Apple ID or Google account.';
      case AppLocale.chinaTraditional:
        return 'Die Zahlung erfolgt über Ihre Apple-ID oder Ihr Google-Konto.';
      case AppLocale.vietnam:
        return 'Khoản thanh toán sẽ được tính vào Apple ID hoặc tài khoản Google của bạn.';
    }
  }
}
