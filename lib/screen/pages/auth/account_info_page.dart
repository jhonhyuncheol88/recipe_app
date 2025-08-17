import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controller/auth/auth_bloc.dart';
import '../../../controller/auth/auth_state.dart';
import '../../../controller/auth/auth_event.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import 'package:go_router/go_router.dart';

class AccountInfoPage extends StatelessWidget {
  const AccountInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLocale = AppLocale.korea; // 기본값으로 한국어 사용

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () {
            // 뒤로가기 가능한지 확인 후 처리
            if (context.canPop()) {
              context.pop();
            } else {
              // 스택에 이전 페이지가 없으면 홈으로 이동
              context.go('/');
            }
          },
        ),
        title: Text(
          '구독 플랜 안내',
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _buildPlanComparison(context, state.user, currentLocale);
          } else if (state is Unauthenticated) {
            // 로그인되지 않은 경우 바로 로그인 화면으로 이동
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go('/login');
              }
            });
            return _buildLoadingState();
          } else {
            return _buildLoadingState();
          }
        },
      ),
    );
  }

  Widget _buildPlanComparison(
    BuildContext context,
    User user,
    AppLocale locale,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 환영 메시지
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Icon(Icons.person, size: 40, color: AppColors.accent)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '안녕하세요, ${user.displayName ?? '사용자'}님!',
                    style: AppTextStyles.headline4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 사용 중인 플랜과 업그레이드 옵션을 확인해보세요',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 무료 플랜 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '무료 플랜',
                        style: AppTextStyles.headline4.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '현재 사용 중',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 무료 플랜 기능
                  _buildFeatureItem('✅ 기본 레시피 관리', '무제한'),
                  _buildFeatureItem('✅ 재료 관리', '무제한'),
                  _buildFeatureItem('✅ 소스 관리', '무제한'),
                  _buildFeatureItem('❌ AI 레시피 생성', '하루 3번'),
                  _buildFeatureItem('❌ 광고 제거', '광고 표시'),
                  _buildFeatureItem('❌ 고급 분석', '제한적'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 프리미엄 플랜 카드
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.accent, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '프리미엄 플랜',
                        style: AppTextStyles.headline4.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '월 ₩3,300',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 프리미엄 플랜 기능
                  _buildFeatureItem('✅ 기본 레시피 관리', '무제한'),
                  _buildFeatureItem('✅ 재료 관리', '무제한'),
                  _buildFeatureItem('✅ 소스 관리', '무제한'),
                  _buildFeatureItem('✅ AI 레시피 생성', '무제한'),
                  _buildFeatureItem('✅ 광고 제거', '광고 없음'),
                  _buildFeatureItem('✅ 고급 분석', '상세 분석'),
                  _buildFeatureItem('✅ 우선 지원', '24시간 내 응답'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 프리미엄 업그레이드 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: 결제 페이지로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('결제 기능은 추후 구현 예정입니다.'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              },
              icon: Icon(Icons.upgrade, color: AppColors.buttonText, size: 24),
              label: Text('프리미엄으로 업그레이드', style: AppTextStyles.buttonLarge),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.buttonText,
                elevation: 4,
                shadowColor: AppColors.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 로그아웃 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              icon: Icon(Icons.logout, color: AppColors.error, size: 24),
              label: Text(
                AppStrings.getLogout(locale),
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              feature,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('플랜 정보를 불러오는 중...'),
        ],
      ),
    );
  }
}
