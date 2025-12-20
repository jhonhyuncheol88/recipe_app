import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controller/auth/auth_bloc.dart';
import '../../../controller/auth/auth_event.dart';
import '../../../controller/auth/auth_state.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          AppStrings.getLoginTitle(AppLocale.korea),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return PopupMenuButton(
                  icon: Icon(
                    Icons.account_circle,
                    color: AppColors.accent,
                    size: 28,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          backgroundImage: state.user.photoURL != null
                              ? NetworkImage(state.user.photoURL!)
                              : null,
                          child: state.user.photoURL == null
                              ? Icon(Icons.person, color: AppColors.accent)
                              : null,
                        ),
                        title: Text(
                          state.user.displayName ??
                              AppStrings.getUser(AppLocale.korea),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          state.user.email ?? '',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: AppColors.error,
                        ),
                        title: Text(
                          AppStrings.getLogout(AppLocale.korea),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                        onTap: () {
                          context.read<AuthBloc>().add(SignOutRequested());
                        },
                      ),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background, // Solid Color (깨끗한 화이트)
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(70),
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
                    size: 80,
                    color: AppColors.accent,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  AppStrings.getWelcomeMessage(AppLocale.korea),
                  style: AppTextStyles.headline2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  AppStrings.getHomeSubtitle(AppLocale.korea),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 60),
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: AppColors.success,
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppStrings.getLoginComplete(AppLocale.korea),
                        style: AppTextStyles.headline4.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
