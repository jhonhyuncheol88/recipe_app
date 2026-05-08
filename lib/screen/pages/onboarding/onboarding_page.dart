import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../../../controller/onboarding/onboarding_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../router/app_router.dart';
import '../../../router/router_helper.dart';
import '../../../service/startup_app_open_ad.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalPages = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() => _currentPage++);
      _pageController.jumpToPage(_currentPage);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.jumpToPage(_currentPage);
    }
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
    _pageController.jumpToPage(page);
  }

  Future<void> _completeOnboarding({bool goToPremium = false}) async {
    final onboardingCubit = context.read<OnboardingCubit>();
    await onboardingCubit.completeOnboarding();

    final logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );

    // 프리미엄 결제로 진입하는 경로에서는 앱 오픈 광고를 스킵 — 결제 흐름 직전에 전면 광고를 띄우면 UX 이상.
    if (!goToPremium) {
      await StartupAppOpenAd.runAppOpenFlow(logger, loadGrace: Duration.zero);
    }

    if (!mounted) return;
    if (goToPremium) {
      // 온보딩 플래그는 이미 저장됐으므로, 결제 페이지로 직접 이동.
      // 비로그인 상태면 PremiumPage 자체 가드가 /login 으로 redirect.
      context.go(AppRouter.premium);
    } else {
      RouterHelper.completeOnboarding(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => _completeOnboarding(),
                  child: Text(
                    AppStrings.getOnboardingSkip(locale),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomePage(locale),
                  _buildAdNoticePage(locale),
                  _buildPremiumPitchPage(locale),
                ],
              ),
            ),
            _buildBottomNavigation(locale),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 56,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.getOnboardingWelcome(locale),
            style: AppTextStyles.headline2.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getOnboardingSubtitle(locale),
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAdNoticePage(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.ads_click,
            size: 44,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getOnboardingAdsHeading(locale),
            style: AppTextStyles.headline3.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          _AdInfoCard(
            icon: Icons.view_carousel_outlined,
            title: AppStrings.getOnboardingAdBannerTitle(locale),
            description: AppStrings.getOnboardingAdBannerDesc(locale),
          ),
          const SizedBox(height: 12),
          _AdInfoCard(
            icon: Icons.fullscreen,
            title: AppStrings.getOnboardingAdNoticeTitle(locale),
            description: AppStrings.getOnboardingAdNoticePoint(locale),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getOnboardingAdNoticeFooter(locale),
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 12,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPitchPage(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium,
              size: 36,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            AppStrings.getOnboardingPremiumPitchTitle(locale),
            style: AppTextStyles.headline3.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.getOnboardingPremiumPitchSubtitle(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 22),
          _BenefitRow(
            icon: Icons.block,
            text: AppStrings.getPremiumBenefitNoAds(locale),
          ),
          const SizedBox(height: 10),
          _BenefitRow(
            icon: Icons.all_inclusive,
            text: AppStrings.getPremiumBenefitForever(locale),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _completeOnboarding(goToPremium: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                AppStrings.getPremiumPurchaseButton(locale),
                style: AppTextStyles.buttonLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => _completeOnboarding(),
              child: Text(
                AppStrings.getOnboardingContinueFree(locale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages, (index) {
              return GestureDetector(
                onTap: () => _goToPage(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == index
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: _previousPage,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 18, color: colorScheme.onSurface),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.getOnboardingPrevious(locale),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(width: 80),
              if (_currentPage < _totalPages - 1)
                TextButton(
                  onPressed: _nextPage,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.getOnboardingNext(locale),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 18, color: colorScheme.onSurface),
                    ],
                  ),
                )
              else
                const SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AdInfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.check_circle, size: 20, color: colorScheme.primary),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
