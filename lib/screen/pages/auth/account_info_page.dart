import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/auth/auth_bloc.dart';
import '../../../controller/auth/auth_event.dart';
import '../../../controller/auth/auth_state.dart';
import '../../../controller/premium/premium_cubit.dart';
import '../../../controller/premium/premium_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../router/app_router.dart';
import '../../../router/router_helper.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';

class AccountInfoPage extends StatelessWidget {
  const AccountInfoPage({super.key});

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
                  context.go(AppRouter.home);
                }
              },
            ),
            title: Text(
              AppStrings.getAccountInfo(locale),
              style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
            ),
            centerTitle: true,
          ),
          body: BlocConsumer<AuthBloc, AuthState>(
            listenWhen: (prev, curr) => curr is AuthFailure,
            listener: (ctx, state) =>
                _onAuthFailure(ctx, state as AuthFailure, locale, tokens),
            builder: (ctx, auth) => _buildBody(ctx, auth, locale, tokens),
          ),
        );
      },
    );
  }

  void _onAuthFailure(
    BuildContext ctx,
    AuthFailure state,
    AppLocale locale,
    AppColorTokens tokens,
  ) {
    if (state.error == authReauthRequiredSentinel) {
      _showReauthDialog(ctx, locale, tokens);
      return;
    }
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(AppStrings.getLoginFailureMessage(locale)),
      backgroundColor: tokens.negative,
    ));
  }

  Future<void> _showReauthDialog(
    BuildContext ctx,
    AppLocale locale,
    AppColorTokens tokens,
  ) async {
    final shouldReauth = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: tokens.bgBase,
        title: Text(
          AppStrings.getDeleteAccount(locale),
          style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        ),
        content: Text(
          AppStrings.getDeleteAccountReauthRequired(locale),
          style: AppTypography.body2.copyWith(color: tokens.fgDefault),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppStrings.getSignIn(locale),
              style: TextStyle(color: tokens.primary),
            ),
          ),
        ],
      ),
    );

    if (shouldReauth != true || !ctx.mounted) return;
    // 로그아웃 후 다시 로그인 안내. 로그인 후 자동으로 이 페이지로 복귀.
    ctx.read<AuthBloc>().add(SignOutRequested());
    ctx.go(AppRouter.login, extra: AppRouter.accountInfo);
  }

  Widget _buildBody(
    BuildContext ctx,
    AuthState auth,
    AppLocale locale,
    AppColorTokens tokens,
  ) {
    if (auth is AuthLoading || auth is AuthInitial) {
      return Center(child: CircularProgressIndicator(color: tokens.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (auth is Authenticated)
            _ProfileHeader(user: auth.user, locale: locale, tokens: tokens)
          else
            _SignedOutHeader(locale: locale, tokens: tokens),
          const SizedBox(height: AppSpacing.s16),
          _PremiumCard(locale: locale, tokens: tokens),
          if (auth is Authenticated) ...[
            const SizedBox(height: AppSpacing.s24),
            _AccountActions(locale: locale, tokens: tokens),
          ],
          const SizedBox(height: AppSpacing.s32),
        ],
      ),
    );
  }
}

// ============================================================================
// Profile header (signed in / signed out)
// ============================================================================

class _ProfileHeader extends StatelessWidget {
  final User user;
  final AppLocale locale;
  final AppColorTokens tokens;

  const _ProfileHeader({
    required this.user,
    required this.locale,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final initial = (user.displayName?.isNotEmpty ?? false)
        ? user.displayName!.characters.first.toUpperCase()
        : (user.email?.isNotEmpty ?? false)
            ? user.email!.characters.first.toUpperCase()
            : '?';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR16,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: tokens.primarySoft,
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Text(
                    initial,
                    style: AppTypography.title3.copyWith(
                      color: tokens.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? AppStrings.getUser(locale),
                  style: AppTypography.heading2.copyWith(
                    color: tokens.fgStrong,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.email != null) ...[
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    user.email!,
                    style: AppTypography.body2.copyWith(
                      color: tokens.fgTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedOutHeader extends StatelessWidget {
  final AppLocale locale;
  final AppColorTokens tokens;

  const _SignedOutHeader({required this.locale, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR16,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: tokens.bgMuted,
                child: Icon(Icons.person_outline, color: tokens.fgTertiary),
              ),
              const SizedBox(width: AppSpacing.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.getNotSignedIn(locale),
                      style: AppTypography.heading2.copyWith(
                        color: tokens.fgStrong,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      AppStrings.getSignInRequiredForFeature(locale),
                      style: AppTypography.body2.copyWith(
                        color: tokens.fgTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          ElevatedButton.icon(
            onPressed: () => context.go(
              AppRouter.login,
              extra: AppRouter.accountInfo,
            ),
            icon: const Icon(Icons.login),
            label: Text(AppStrings.getSignIn(locale)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: tokens.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brR12),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Premium status card
// ============================================================================

class _PremiumCard extends StatelessWidget {
  final AppLocale locale;
  final AppColorTokens tokens;

  const _PremiumCard({required this.locale, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumCubit, PremiumState>(
      builder: (ctx, state) {
        if (state is PremiumActive) {
          return _ActiveCard(state: state, locale: locale, tokens: tokens);
        }
        // Unknown / Checking / Free / Purchasing / Restoring / Error 모두 Free 표시 (구매 가능)
        return _FreeCard(locale: locale, tokens: tokens);
      },
    );
  }
}

class _ActiveCard extends StatelessWidget {
  final PremiumActive state;
  final AppLocale locale;
  final AppColorTokens tokens;

  const _ActiveCard({
    required this.state,
    required this.locale,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: tokens.positiveSoft,
        borderRadius: AppRadius.brR16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: tokens.positive, size: 24),
              const SizedBox(width: AppSpacing.s8),
              Text(
                AppStrings.getPremiumAlreadyOwnedTitle(locale),
                style: AppTypography.heading2.copyWith(
                  color: tokens.fgStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            AppStrings.getPremiumAlreadyOwnedSubtitle(locale),
            style: AppTypography.body2.copyWith(color: tokens.fgSecondary),
          ),
          if (state.originalPurchaseDate != null) ...[
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Text(
                  '${AppStrings.getPremiumPurchasedAt(locale)} · ',
                  style: AppTypography.caption1
                      .copyWith(color: tokens.fgTertiary),
                ),
                Text(
                  _formatDate(state.originalPurchaseDate!),
                  style: AppTypography.label2
                      .copyWith(color: tokens.fgDefault),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}

class _FreeCard extends StatelessWidget {
  final AppLocale locale;
  final AppColorTokens tokens;

  const _FreeCard({required this.locale, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR16,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined,
                  color: tokens.primary, size: 24),
              const SizedBox(width: AppSpacing.s8),
              Text(
                AppStrings.getPremiumMenuTitle(locale),
                style: AppTypography.heading2.copyWith(
                  color: tokens.fgStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            AppStrings.getPremiumMenuSubtitle(locale),
            style: AppTypography.body2.copyWith(color: tokens.fgSecondary),
          ),
          const SizedBox(height: AppSpacing.s16),
          ElevatedButton(
            onPressed: () => RouterHelper.goToPremium(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: tokens.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brR12),
            ),
            child: Text(AppStrings.getUpgradeToPremium(locale)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Account actions (sign out + delete)
// ============================================================================

class _AccountActions extends StatelessWidget {
  final AppLocale locale;
  final AppColorTokens tokens;

  const _AccountActions({required this.locale, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () => _confirmSignOut(context),
          icon: Icon(Icons.logout, color: tokens.fgDefault),
          label: Text(
            AppStrings.getLogout(locale),
            style: TextStyle(color: tokens.fgDefault),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: BorderSide(color: tokens.borderDefault),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brR12),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        TextButton.icon(
          onPressed: () => _confirmDelete(context),
          icon: Icon(Icons.delete_forever, color: tokens.negative),
          label: Text(
            AppStrings.getDeleteAccount(locale),
            style: TextStyle(color: tokens.negative),
          ),
          style: TextButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.brR12),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tokens.bgBase,
        title: Text(AppStrings.getLogout(locale),
            style: AppTypography.heading2.copyWith(color: tokens.fgStrong)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.getLogout(locale),
              style: TextStyle(color: tokens.negative),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<AuthBloc>().add(SignOutRequested());
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tokens.bgBase,
        title: Text(
          AppStrings.getDeleteAccountConfirmTitle(locale),
          style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
        ),
        content: Text(
          AppStrings.getDeleteAccountConfirmMessage(locale),
          style: AppTypography.body2.copyWith(color: tokens.fgDefault),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.getDeleteAccount(locale),
              style: TextStyle(color: tokens.negative),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<AuthBloc>().add(DeleteAccountRequested());
    // 성공 시 authStateChanges → Unauthenticated → 빌더가 SignedOutHeader 로 자동 전환.
    // reauth 필요 시 listener 가 다이얼로그 노출.
  }
}
