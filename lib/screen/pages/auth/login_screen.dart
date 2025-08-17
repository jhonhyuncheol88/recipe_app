import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/auth/auth_bloc.dart';
import '../../../controller/auth/auth_event.dart';
import '../../../controller/auth/auth_state.dart';
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryLight, AppColors.background],
          ),
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

                  // Google 로그인 버튼
                  BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${AppStrings.getLoginFailure(AppLocale.korea)}: ${state.error}',
                            ),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      } else if (state is Authenticated) {
                        // 로그인 성공 시 홈 페이지로 이동
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (context.mounted) {
                            context.go('/');
                          }
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<AuthBloc>().add(GoogleSignInRequested());
                        },
                        icon: Icon(
                          Icons.login,
                          color: AppColors.buttonText,
                          size: 24,
                        ),
                        label: Text(
                          AppStrings.getGoogleLoginButton(AppLocale.korea),
                          style: AppTextStyles.buttonLarge,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          foregroundColor: AppColors.buttonText,
                          elevation: 2,
                          shadowColor: AppColors.shadow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // 추가 정보
                  Text(
                    AppStrings.getGoogleAccountLogin(AppLocale.korea),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textLight,
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
