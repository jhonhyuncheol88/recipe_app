import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            // 뒤로가기 버튼 처리
            if (Navigator.canPop(context)) {
              context.go('/');
            } else {
              // 스택에 이전 페이지가 없으면 홈으로 이동
              context.go('/');
            }
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background, // Solid Color (깨끗한 화이트)
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 앱 아이콘 또는 로고
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 60,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(height: 40),

                  // 앱 제목
                  Text(
                    AppStrings.getLoginTitle(AppLocale.korea), // 기본값으로 한국어 사용
                    style: AppTextStyles.headline1.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 20),

                  // 부제목
                  Text(
                    AppStrings.getLoginSubtitle(AppLocale.korea),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60),

                  // 로그인 기능이 필요한 경우 여기에 추가하세요
                  Text(
                    '로그인 기능이 준비 중입니다.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
