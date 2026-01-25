import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controller/auth/auth_bloc.dart';
import '../../../controller/auth/auth_state.dart';
import '../../../controller/auth/auth_event.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import 'package:go_router/go_router.dart';

class AccountInfoPage extends StatelessWidget {
  const AccountInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLocale = AppLocale.korea;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          '구독 플랜 안내',
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _buildPlanComparison(context, state.user, currentLocale);
          } else if (state is Unauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.go('/login');
              }
            });
            return _buildLoadingState(context);
          } else {
            return _buildLoadingState(context);
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
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.primary,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Icon(Icons.person,
                            size: 40, color: colorScheme.onPrimary)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '안녕하세요, ${user.displayName ?? '사용자'}님!',
                    style: AppTextStyles.headline4.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '현재 사용 중인 플랜과 업그레이드 옵션을 확인해보세요',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '무료 플랜',
                        style: AppTextStyles.headline4.copyWith(
                          color: colorScheme.primary,
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
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '현재 사용 중',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(context, '✅ 기본 레시피 관리', '무제한'),
                  _buildFeatureItem(context, '✅ 재료 관리', '무제한'),
                  _buildFeatureItem(context, '✅ 소스 관리', '무제한'),
                  _buildFeatureItem(context, '❌ AI 레시피 생성', '하루 3번'),
                  _buildFeatureItem(context, '❌ 광고 제거', '광고 표시'),
                  _buildFeatureItem(context, '❌ 고급 분석', '제한적'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: colorScheme.secondary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '프리미엄 플랜',
                        style: AppTextStyles.headline4.copyWith(
                          color: colorScheme.secondary,
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
                          color: colorScheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '월 ₩3,300',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureItem(context, '✅ 기본 레시피 관리', '무제한'),
                  _buildFeatureItem(context, '✅ 재료 관리', '무제한'),
                  _buildFeatureItem(context, '✅ 소스 관리', '무제한'),
                  _buildFeatureItem(context, '✅ AI 레시피 생성', '무제한'),
                  _buildFeatureItem(context, '✅ 광고 제거', '광고 없음'),
                  _buildFeatureItem(context, '✅ 고급 분석', '상세 분석'),
                  _buildFeatureItem(context, '✅ 우선 지원', '24시간 내 응답'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('결제 기능은 추후 구현 예정입니다.'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              },
              icon: Icon(Icons.upgrade, color: colorScheme.onPrimary, size: 24),
              label: Text('프리미엄으로 업그레이드',
                  style: AppTextStyles.buttonLarge
                      .copyWith(color: colorScheme.onPrimary)),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 4,
                shadowColor: colorScheme.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(SignOutRequested());
              },
              icon: Icon(Icons.logout, color: colorScheme.error, size: 24),
              label: Text(
                AppStrings.getLogout(locale),
                style: AppTextStyles.buttonLarge.copyWith(
                  color: colorScheme.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
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

  Widget _buildFeatureItem(
      BuildContext context, String feature, String description) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              feature,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text('플랜 정보를 불러오는 중...',
              style: TextStyle(color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}
