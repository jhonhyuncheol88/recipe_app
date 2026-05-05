import '../app_locale.dart';

/// Auth 관련 문자열
mixin AppStringsAuth {
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
      case AppLocale.chinaTraditional:
        return 'Recipe App';
      case AppLocale.vietnam:
        return 'Ứng dụng công thức';
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
      case AppLocale.chinaTraditional:
        return 'Manage recipes and get AI cooking methods';
      case AppLocale.vietnam:
        return 'Quản lý công thức và nhận phương pháp nấu ăn AI';
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
      case AppLocale.chinaTraditional:
        return 'Sign in with Google';
      case AppLocale.vietnam:
        return 'Đăng nhập bằng Google';
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
      case AppLocale.chinaTraditional:
        return 'Login Failed';
      case AppLocale.vietnam:
        return 'Đăng nhập thất bại';
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
      case AppLocale.chinaTraditional:
        return 'Failed to sign in';
      case AppLocale.vietnam:
        return 'Không thể đăng nhập';
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
      case AppLocale.chinaTraditional:
        return 'Welcome!';
      case AppLocale.vietnam:
        return 'Chào mừng!';
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
      case AppLocale.chinaTraditional:
        return 'You are ready to use the recipe app.';
      case AppLocale.vietnam:
        return 'Bạn đã sẵn sàng sử dụng ứng dụng công thức.';
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
      case AppLocale.chinaTraditional:
        return 'Logout';
      case AppLocale.vietnam:
        return 'Đăng xuất';
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
      case AppLocale.chinaTraditional:
        return 'User';
      case AppLocale.vietnam:
        return 'Người dùng';
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
      case AppLocale.chinaTraditional:
        return 'Login Complete';
      case AppLocale.vietnam:
        return 'Đăng nhập hoàn tất';
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
      case AppLocale.chinaTraditional:
        return 'Sign in easily with your Google account';
      case AppLocale.vietnam:
        return 'Sign in easily with your Google account';
    }
  }

  static String getAppleLoginButton(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return 'Apple로 로그인';
      case AppLocale.japan:
        return 'Appleでサインイン';
      case AppLocale.china:
        return '使用 Apple 登录';
      case AppLocale.usa:
        return 'Sign in with Apple';
      case AppLocale.chinaTraditional:
        return 'Mit Apple anmelden';
      case AppLocale.vietnam:
        return 'Đăng nhập bằng Apple';
    }
  }

  static String getLoginInProgress(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '로그인 중...';
      case AppLocale.japan:
        return 'ログイン中...';
      case AppLocale.china:
        return '正在登录...';
      case AppLocale.usa:
        return 'Signing in...';
      case AppLocale.chinaTraditional:
        return 'Anmeldung läuft...';
      case AppLocale.vietnam:
        return 'Đang đăng nhập...';
    }
  }

  static String getSignInRequiredForFeature(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '이 기능은 로그인 후 이용할 수 있습니다';
      case AppLocale.japan:
        return 'この機能はログイン後にご利用いただけます';
      case AppLocale.china:
        return '此功能需要登录后使用';
      case AppLocale.usa:
        return 'Please sign in to use this feature';
      case AppLocale.chinaTraditional:
        return 'Bitte melden Sie sich an, um diese Funktion zu nutzen';
      case AppLocale.vietnam:
        return 'Vui lòng đăng nhập để sử dụng tính năng này';
    }
  }

  static String getDeleteAccount(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '계정 탈퇴';
      case AppLocale.japan:
        return 'アカウント削除';
      case AppLocale.china:
        return '注销账户';
      case AppLocale.usa:
        return 'Delete Account';
      case AppLocale.chinaTraditional:
        return 'Konto löschen';
      case AppLocale.vietnam:
        return 'Xóa tài khoản';
    }
  }

  static String getDeleteAccountConfirmTitle(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '정말 탈퇴하시겠습니까?';
      case AppLocale.japan:
        return '本当に退会しますか？';
      case AppLocale.china:
        return '确定要注销账户吗？';
      case AppLocale.usa:
        return 'Delete your account?';
      case AppLocale.chinaTraditional:
        return 'Konto wirklich löschen?';
      case AppLocale.vietnam:
        return 'Bạn có chắc muốn xóa tài khoản?';
    }
  }

  static String getDeleteAccountConfirmMessage(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '계정과 클라우드 동기화 데이터가 삭제됩니다. 이 작업은 되돌릴 수 없습니다.';
      case AppLocale.japan:
        return 'アカウントとクラウド同期データが削除されます。この操作は取り消せません。';
      case AppLocale.china:
        return '账户及云端同步数据将被删除，此操作无法恢复。';
      case AppLocale.usa:
        return 'Your account and synced cloud data will be deleted. This cannot be undone.';
      case AppLocale.chinaTraditional:
        return 'Ihr Konto und synchronisierte Cloud-Daten werden gelöscht. Dies kann nicht rückgängig gemacht werden.';
      case AppLocale.vietnam:
        return 'Tài khoản và dữ liệu đồng bộ trên đám mây sẽ bị xóa. Không thể hoàn tác.';
    }
  }

  static String getDeleteAccountReauthRequired(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '보안을 위해 다시 로그인 후 탈퇴해주세요';
      case AppLocale.japan:
        return 'セキュリティのため再度ログインしてから退会してください';
      case AppLocale.china:
        return '为了安全，请重新登录后再注销';
      case AppLocale.usa:
        return 'Please sign in again before deleting your account';
      case AppLocale.chinaTraditional:
        return 'Bitte melden Sie sich erneut an, bevor Sie Ihr Konto löschen';
      case AppLocale.vietnam:
        return 'Vui lòng đăng nhập lại trước khi xóa tài khoản';
    }
  }

  static String getDeleteAccountSuccess(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '탈퇴가 완료되었습니다';
      case AppLocale.japan:
        return '退会が完了しました';
      case AppLocale.china:
        return '注销已完成';
      case AppLocale.usa:
        return 'Your account has been deleted';
      case AppLocale.chinaTraditional:
        return 'Ihr Konto wurde gelöscht';
      case AppLocale.vietnam:
        return 'Đã xóa tài khoản';
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
      case AppLocale.chinaTraditional:
        return 'Account';
      case AppLocale.vietnam:
        return 'Tài khoản';
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
      case AppLocale.chinaTraditional:
        return 'Account Settings';
      case AppLocale.vietnam:
        return 'Cài đặt tài khoản';
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
      case AppLocale.chinaTraditional:
        return 'Sign In';
      case AppLocale.vietnam:
        return 'Đăng nhập';
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
      case AppLocale.chinaTraditional:
        return 'Sign Out';
      case AppLocale.vietnam:
        return 'Đăng xuất';
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
      case AppLocale.chinaTraditional:
        return 'Not signed in';
      case AppLocale.vietnam:
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
      case AppLocale.chinaTraditional:
        return 'Signed in as';
      case AppLocale.vietnam:
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
      case AppLocale.chinaTraditional:
        return 'Account Information';
      case AppLocale.vietnam:
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
      case AppLocale.chinaTraditional:
        return 'Subscription Status';
      case AppLocale.vietnam:
        return 'Trạng thái đăng ký';
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
      case AppLocale.chinaTraditional:
        return 'Free User';
      case AppLocale.vietnam:
        return 'Người dùng miễn phí';
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
      case AppLocale.chinaTraditional:
        return 'Premium User';
      case AppLocale.vietnam:
        return 'Người dùng cao cấp';
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
      case AppLocale.chinaTraditional:
        return '• Ads included\n• AI recipes: 3 per day';
      case AppLocale.vietnam:
        return '• Ads included\\n• AI recipes: 3 per day';
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
      case AppLocale.chinaTraditional:
        return '• No ads\n• Unlimited AI recipes';
      case AppLocale.vietnam:
        return '• No ads\\n• Unlimited AI recipes';
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
      case AppLocale.chinaTraditional:
        return 'Upgrade to Premium';
      case AppLocale.vietnam:
        return 'Nâng cấp lên cao cấp';
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
      case AppLocale.chinaTraditional:
        return 'Current Plan';
      case AppLocale.vietnam:
        return 'Gói hiện tại';
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
      case AppLocale.chinaTraditional:
        return 'Email';
      case AppLocale.vietnam:
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
      case AppLocale.chinaTraditional:
        return 'Username';
      case AppLocale.vietnam:
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
      case AppLocale.chinaTraditional:
        return 'Join Date';
      case AppLocale.vietnam:
        return 'Ngày tham gia';
    }
  }
}
