import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/auth/auth_bloc.dart';
import '../../../controller/auth/auth_event.dart';
import '../../../controller/auth/auth_state.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        title: Text(
          AppStrings.getLoginTitle(AppLocale.korea),
          style: AppTextStyles.headline4.copyWith(
            color: colorScheme.onPrimary,
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
                    color: colorScheme.onPrimary,
                    size: 28,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primaryContainer,
                          backgroundImage: state.user.photoURL != null
                              ? NetworkImage(state.user.photoURL!)
                              : null,
                          child: state.user.photoURL == null
                              ? Icon(Icons.person,
                                  color: colorScheme.onPrimaryContainer)
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
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: colorScheme.error,
                        ),
                        title: Text(
                          AppStrings.getLogout(AppLocale.korea),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.error,
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
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface, // Solid Color
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
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(70),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withAlpha(10),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  AppStrings.getWelcomeMessage(AppLocale.korea),
                  style: AppTextStyles.headline2.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.getHomeSubtitle(AppLocale.korea),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.getLoginComplete(AppLocale.korea),
                        style: AppTextStyles.headline4.copyWith(
                          color: colorScheme.primary,
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
