import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/auth/auth_bloc.dart';
import '../../../controller/auth/auth_event.dart';
import '../../../controller/auth/auth_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';

class LoginScreen extends StatelessWidget {
  /// 로그인 성공 후 이동할 경로. null 이면 `/` 로.
  final String? returnTo;

  const LoginScreen({super.key, this.returnTo});

  bool get _showAppleButton => !kIsWeb && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, locale) {
        final tokens = AppColorTokens.of(context);

        return Scaffold(
          backgroundColor: tokens.bgBase,
          appBar: AppBar(
            backgroundColor: tokens.bgBase,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: tokens.fgDefault),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
          ),
          body: BlocConsumer<AuthBloc, AuthState>(
            listenWhen: (prev, curr) =>
                curr is Authenticated || curr is AuthFailure,
            listener: (context, state) {
              if (state is Authenticated) {
                final dest = returnTo ?? '/';
                context.go(dest);
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.getLoginFailureMessage(locale)),
                    backgroundColor: tokens.negative,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      _Logo(tokens: tokens),
                      const SizedBox(height: AppSpacing.s40),
                      Text(
                        AppStrings.getLoginTitle(locale),
                        style: AppTypography.title1.copyWith(
                          color: tokens.fgStrong,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Text(
                        AppStrings.getLoginSubtitle(locale),
                        style: AppTypography.body2.copyWith(
                          color: tokens.fgTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      _GoogleButton(
                        tokens: tokens,
                        locale: locale,
                        enabled: !isLoading,
                        onTap: () => context
                            .read<AuthBloc>()
                            .add(SignInWithGoogleRequested()),
                      ),
                      if (_showAppleButton) ...[
                        const SizedBox(height: AppSpacing.s12),
                        _AppleButton(
                          tokens: tokens,
                          locale: locale,
                          enabled: !isLoading,
                          onTap: () => context
                              .read<AuthBloc>()
                              .add(SignInWithAppleRequested()),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s24),
                      SizedBox(
                        height: 20,
                        child: isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: tokens.primary,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s8),
                                  Text(
                                    AppStrings.getLoginInProgress(locale),
                                    style: AppTypography.caption1.copyWith(
                                      color: tokens.fgTertiary,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.s40),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  final AppColorTokens tokens;
  const _Logo({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tokens.primarySoft,
        borderRadius: AppRadius.brR20,
      ),
      child: Icon(
        Icons.restaurant_menu,
        size: 48,
        color: tokens.primary,
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final AppColorTokens tokens;
  final AppLocale locale;
  final bool enabled;
  final VoidCallback onTap;

  const _GoogleButton({
    required this.tokens,
    required this.locale,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: enabled ? onTap : null,
        icon: const _GoogleGlyph(),
        label: Text(AppStrings.getGoogleLoginButton(locale)),
        style: OutlinedButton.styleFrom(
          backgroundColor: tokens.bgBase,
          foregroundColor: tokens.fgStrong,
          side: BorderSide(color: tokens.borderDefault),
          textStyle: AppTypography.label1,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brR12),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF4285F4),
        shape: BoxShape.circle,
      ),
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AppleButton extends StatelessWidget {
  final AppColorTokens tokens;
  final AppLocale locale;
  final bool enabled;
  final VoidCallback onTap;

  const _AppleButton({
    required this.tokens,
    required this.locale,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: enabled ? onTap : null,
        icon: const Icon(Icons.apple, size: 20),
        label: Text(AppStrings.getAppleLoginButton(locale)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          textStyle: AppTypography.label1,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.brR12),
          elevation: 0,
        ),
      ),
    );
  }
}
