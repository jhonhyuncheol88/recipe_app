import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../controller/auth/auth_bloc.dart';
import '../../../controller/auth/auth_state.dart';
import '../../../controller/premium/premium_cubit.dart';
import '../../../controller/premium/premium_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../router/app_router.dart';
import '../../../service/revenue_cat_service.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  Offering? _offering;
  bool _offeringLoading = true;
  bool _offeringFailed = false;
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoad();
    });
  }

  Future<void> _checkAuthAndLoad() async {
    if (!mounted) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) {
      setState(() => _redirecting = true);
      final locale = context.read<LocaleCubit>().state;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getPremiumLoginRequired(locale))),
      );
      context.go(AppRouter.login, extra: AppRouter.premium);
      return;
    }
    await _loadOffering();
  }

  Future<void> _loadOffering() async {
    final rc = RevenueCatService.instance;
    if (!rc.isReady) {
      if (!mounted) return;
      setState(() {
        _offering = null;
        _offeringLoading = false;
        _offeringFailed = true;
      });
      return;
    }
    try {
      final off = await rc.fetchDefaultOffering();
      if (!mounted) return;
      setState(() {
        _offering = off;
        _offeringLoading = false;
        _offeringFailed = off == null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offeringLoading = false;
        _offeringFailed = true;
      });
    }
  }

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
              AppStrings.getPremiumPageTitle(locale),
              style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
            ),
            centerTitle: true,
          ),
          body: BlocConsumer<PremiumCubit, PremiumState>(
            listenWhen: (prev, curr) =>
                curr is PremiumError ||
                (prev is PremiumRestoring &&
                    (curr is PremiumFree || curr is PremiumActive)),
            listener: (ctx, state) =>
                _handleListener(ctx, state, locale, tokens),
            builder: (ctx, premium) =>
                _buildBody(ctx, premium, locale, tokens),
          ),
        );
      },
    );
  }

  void _handleListener(
    BuildContext ctx,
    PremiumState state,
    AppLocale locale,
    AppColorTokens tokens,
  ) {
    final messenger = ScaffoldMessenger.of(ctx);

    if (state is PremiumError) {
      if (state.kind == PremiumErrorKind.userCancelled) return;
      messenger.showSnackBar(SnackBar(
        content: Text(_errorMessage(state.kind, locale)),
        backgroundColor: tokens.negative,
      ));
      return;
    }

    // 복원 직후 결과 안내
    if (state is PremiumActive) {
      messenger.showSnackBar(SnackBar(
        content: Text(AppStrings.getPremiumRestoreSuccess(locale)),
        backgroundColor: tokens.positive,
      ));
    } else if (state is PremiumFree) {
      messenger.showSnackBar(SnackBar(
        content: Text(AppStrings.getPremiumRestoreNoPurchase(locale)),
      ));
    }
  }

  String _errorMessage(PremiumErrorKind kind, AppLocale locale) {
    switch (kind) {
      case PremiumErrorKind.paymentPending:
        return AppStrings.getPremiumErrorPending(locale);
      case PremiumErrorKind.network:
        return AppStrings.getPremiumErrorNetwork(locale);
      case PremiumErrorKind.store:
        return AppStrings.getPremiumErrorStore(locale);
      case PremiumErrorKind.alreadyPurchased:
        return AppStrings.getPremiumErrorAlready(locale);
      case PremiumErrorKind.notReady:
        return AppStrings.getPremiumErrorNotReady(locale);
      case PremiumErrorKind.userCancelled:
      case PremiumErrorKind.unknown:
        return AppStrings.getPremiumErrorUnknown(locale);
    }
  }

  Widget _buildBody(
    BuildContext ctx,
    PremiumState premium,
    AppLocale locale,
    AppColorTokens tokens,
  ) {
    if (_redirecting) {
      return Center(child: CircularProgressIndicator(color: tokens.primary));
    }

    if (premium is PremiumUnknown || premium is PremiumChecking) {
      return Center(child: CircularProgressIndicator(color: tokens.primary));
    }

    if (premium is PremiumActive) {
      return _AlreadyOwnedView(
        premium: premium,
        locale: locale,
        tokens: tokens,
        onRestore: () => ctx.read<PremiumCubit>().restore(),
        busy: false,
      );
    }

    // Free / Purchasing / Restoring / Error 모두 결제 화면 + 진행 overlay 분기
    final busy = premium is PremiumPurchasing || premium is PremiumRestoring;

    return Stack(
      children: [
        _PurchaseView(
          locale: locale,
          tokens: tokens,
          offering: _offering,
          offeringLoading: _offeringLoading,
          offeringFailed: _offeringFailed,
          busy: busy,
          onPurchase: () {
            final pkg = _offering?.lifetime ?? _offering?.availablePackages.firstOrNull;
            if (pkg == null) return;
            ctx.read<PremiumCubit>().purchase(pkg);
          },
          onRestore: () => ctx.read<PremiumCubit>().restore(),
          onRetryOffering: _loadOffering,
        ),
        if (busy) _BusyOverlay(locale: locale, tokens: tokens, premium: premium),
      ],
    );
  }
}

// ============================================================================
// Already owned (PremiumActive) view
// ============================================================================

class _AlreadyOwnedView extends StatelessWidget {
  final PremiumActive premium;
  final AppLocale locale;
  final AppColorTokens tokens;
  final VoidCallback onRestore;
  final bool busy;

  const _AlreadyOwnedView({
    required this.premium,
    required this.locale,
    required this.tokens,
    required this.onRestore,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s24),
            decoration: BoxDecoration(
              color: tokens.positiveSoft,
              borderRadius: AppRadius.brR16,
            ),
            child: Column(
              children: [
                Icon(Icons.verified, size: 56, color: tokens.positive),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  AppStrings.getPremiumAlreadyOwnedTitle(locale),
                  style: AppTypography.title3.copyWith(
                    color: tokens.fgStrong,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  AppStrings.getPremiumAlreadyOwnedSubtitle(locale),
                  style: AppTypography.body2.copyWith(color: tokens.fgSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (premium.originalPurchaseDate != null) ...[
            const SizedBox(height: AppSpacing.s16),
            _InfoRow(
              label: AppStrings.getPremiumPurchasedAt(locale),
              value: _formatDate(premium.originalPurchaseDate!),
              tokens: tokens,
            ),
          ],
          const SizedBox(height: AppSpacing.s32),
          OutlinedButton(
            onPressed: busy ? null : onRestore,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: tokens.fgStrong,
              side: BorderSide(color: tokens.borderDefault),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brR12),
            ),
            child: Text(AppStrings.getPremiumRestoreButton(locale)),
          ),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColorTokens tokens;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.label2.copyWith(color: tokens.fgTertiary)),
          Text(value,
              style: AppTypography.label1.copyWith(color: tokens.fgDefault)),
        ],
      ),
    );
  }
}

// ============================================================================
// Purchase (PremiumFree) view
// ============================================================================

class _PurchaseView extends StatelessWidget {
  final AppLocale locale;
  final AppColorTokens tokens;
  final Offering? offering;
  final bool offeringLoading;
  final bool offeringFailed;
  final bool busy;
  final VoidCallback onPurchase;
  final VoidCallback onRestore;
  final VoidCallback onRetryOffering;

  const _PurchaseView({
    required this.locale,
    required this.tokens,
    required this.offering,
    required this.offeringLoading,
    required this.offeringFailed,
    required this.busy,
    required this.onPurchase,
    required this.onRestore,
    required this.onRetryOffering,
  });

  @override
  Widget build(BuildContext context) {
    final pkg = offering?.lifetime ?? offering?.availablePackages.firstOrNull;
    final priceText = pkg?.storeProduct.priceString;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(locale: locale, tokens: tokens),
          const SizedBox(height: AppSpacing.s24),
          _BenefitList(locale: locale, tokens: tokens),
          const SizedBox(height: AppSpacing.s24),
          _PriceCard(
            locale: locale,
            tokens: tokens,
            priceText: priceText,
            loading: offeringLoading,
            failed: offeringFailed,
            onRetry: onRetryOffering,
          ),
          const SizedBox(height: AppSpacing.s24),
          ElevatedButton(
            onPressed: (busy || pkg == null) ? null : onPurchase,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: tokens.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brR12),
              textStyle: AppTypography.label1.copyWith(fontWeight: FontWeight.w700),
            ),
            child: Text(AppStrings.getPremiumPurchaseButton(locale)),
          ),
          const SizedBox(height: AppSpacing.s8),
          OutlinedButton(
            onPressed: busy ? null : onRestore,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: tokens.fgStrong,
              side: BorderSide(color: tokens.borderDefault),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brR12),
            ),
            child: Text(AppStrings.getPremiumRestoreButton(locale)),
          ),
          const SizedBox(height: AppSpacing.s24),
          Text(
            AppStrings.getPremiumTermsNotice(locale),
            style: AppTypography.caption2.copyWith(color: tokens.fgTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s24),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final AppLocale locale;
  final AppColorTokens tokens;
  const _Hero({required this.locale, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: tokens.primarySoft,
            borderRadius: AppRadius.brR20,
          ),
          child: Icon(Icons.block, size: 44, color: tokens.primary),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          AppStrings.getPremiumMenuTitle(locale),
          style: AppTypography.title2.copyWith(
            color: tokens.fgStrong,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          AppStrings.getPremiumMenuSubtitle(locale),
          style: AppTypography.body2.copyWith(color: tokens.fgTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _BenefitList extends StatelessWidget {
  final AppLocale locale;
  final AppColorTokens tokens;
  const _BenefitList({required this.locale, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      AppStrings.getPremiumBenefitNoAds(locale),
      AppStrings.getPremiumBenefitForever(locale),
      AppStrings.getPremiumBenefitFamilyShare(locale),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: tokens.bgElev1,
        borderRadius: AppRadius.brR12,
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        children: benefits
            .map((b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: tokens.positive, size: 20),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          b,
                          style: AppTypography.body2.copyWith(
                            color: tokens.fgDefault,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final AppLocale locale;
  final AppColorTokens tokens;
  final String? priceText;
  final bool loading;
  final bool failed;
  final VoidCallback onRetry;

  const _PriceCard({
    required this.locale,
    required this.tokens,
    required this.priceText,
    required this.loading,
    required this.failed,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Text(
            AppStrings.getPremiumLoadingPrice(locale),
            style: AppTypography.body2.copyWith(color: tokens.fgTertiary),
          ),
        ),
      );
    }

    if (failed || priceText == null) {
      return Center(
        child: Column(
          children: [
            Text(
              AppStrings.getPremiumPriceUnavailable(locale),
              style: AppTypography.body2.copyWith(color: tokens.fgTertiary),
            ),
            const SizedBox(height: AppSpacing.s8),
            TextButton(
              onPressed: onRetry,
              child: Text(
                AppStrings.getRetry(locale),
                style: TextStyle(color: tokens.primary),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s24,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: tokens.primarySoft,
          borderRadius: AppRadius.brR12,
        ),
        child: Text(
          priceText!,
          style: AppTypography.title2.copyWith(
            color: tokens.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _BusyOverlay extends StatelessWidget {
  final AppLocale locale;
  final AppColorTokens tokens;
  final PremiumState premium;

  const _BusyOverlay({
    required this.locale,
    required this.tokens,
    required this.premium,
  });

  @override
  Widget build(BuildContext context) {
    final label = premium is PremiumPurchasing
        ? AppStrings.getPremiumPurchasing(locale)
        : AppStrings.getPremiumRestoring(locale);

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s24),
            decoration: BoxDecoration(
              color: tokens.bgBase,
              borderRadius: AppRadius.brR16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: tokens.primary),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  label,
                  style:
                      AppTypography.body2.copyWith(color: tokens.fgDefault),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
