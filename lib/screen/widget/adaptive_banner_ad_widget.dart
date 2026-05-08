import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

import '../../controller/premium/premium_cubit.dart';
import '../../controller/premium/premium_state.dart';
import '../../service/banner_ad_service.dart';
import '../../theme/tokens/app_color_tokens.dart';

/// 메인 탭 Scaffold 하단에 깔리는 적응형 배너 광고.
///
/// 정책 안전성:
///   1. Premium 사용자 → 미노출 (BlocBuilder 가 SizedBox.shrink 반환).
///   2. 키보드 노출 중 → 미노출 (사고 클릭 위험).
///   3. 광고 로드 전에도 사이즈만큼 자리 확보 (placeholder) → 레이아웃 점프
///      방지로 인한 사고 클릭 회피.
///   4. 위/아래 1px borderSubtle 구분선으로 콘텐츠/탭바와 시각 분리.
///   5. dispose 에서 BannerAd 해제.
///
/// 자동 새로고침은 AdMob 콘솔 기본값(60초) 사용. 코드에서 강제 재로드 X.
class AdaptiveBannerAdWidget extends StatefulWidget {
  const AdaptiveBannerAdWidget({super.key});

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  static final _log = Logger(
    printer: PrettyPrinter(methodCount: 0, printEmojis: true),
  );

  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _isLoaded = false;
  bool _isLoading = false;
  // 로딩 전 layout jump 방지용 placeholder 높이. 적응형 배너 표준 50dp.
  static const double _placeholderHeight = 50.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Premium 사용자면 로드하지 않음.
    if (BannerAdService.instance.isPremium) return;
    if (_isLoaded || _isLoading || _bannerAd != null) return;
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (!mounted) return;
    _isLoading = true;

    // 메인 탭은 부팅 시퀀스의 AdMob 초기화보다 먼저 마운트될 수 있다.
    // 초기화 전 BannerAd.load() 는 무음 실패하므로 여기서 보장.
    await BannerAdService.instance.ensureInitialized();
    if (!mounted) {
      _isLoading = false;
      return;
    }

    final width = MediaQuery.of(context).size.width.truncate();
    final size =
        await BannerAdService.instance.resolveAdaptiveSize(width);
    if (!mounted) {
      _isLoading = false;
      return;
    }
    if (size == null) {
      _log.w('⚠️ 적응형 배너 사이즈 산출 실패 (width=$width)');
      _isLoading = false;
      return;
    }

    final adUnitId = BannerAdService.instance.resolveBannerAdUnitId();
    if (adUnitId.isEmpty) {
      _log.w('⚠️ 배너 광고 단위 ID 가 비어있어 로드 스킵');
      _isLoading = false;
      return;
    }
    _log.i('📥 배너 광고 로드 시작 (id=$adUnitId, size=${size.width}x${size.height})');

    final ad = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _log.i('✅ 배너 광고 로드 성공');
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _isLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (ad, error) {
          _log.w('⚠️ 배너 광고 로드 실패: code=${error.code} msg=${error.message}');
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
          });
        },
      ),
    );

    _bannerAd = ad;
    ad.load();
    _isLoading = false;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumCubit, PremiumState>(
      buildWhen: (prev, curr) => prev.isPremium != curr.isPremium,
      builder: (context, premiumState) {
        // Premium 사용자: 광고 영역 자체를 제거 (높이 0).
        if (premiumState.isPremium) {
          return const SizedBox.shrink();
        }

        // 키보드 노출 중: 사고 클릭 방지를 위해 숨김.
        final isKeyboardVisible =
            MediaQuery.of(context).viewInsets.bottom > 0;
        if (isKeyboardVisible) {
          return const SizedBox.shrink();
        }

        final tokens = AppColorTokens.of(context);
        final size = _adSize;

        // 로딩 전: placeholder 자리만 확보 (구분선 포함).
        if (!_isLoaded || _bannerAd == null || size == null) {
          return _wrapWithDividers(
            tokens: tokens,
            child: SizedBox(
              height: _placeholderHeight,
              width: double.infinity,
            ),
          );
        }

        return _wrapWithDividers(
          tokens: tokens,
          child: SizedBox(
            width: size.width.toDouble(),
            height: size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        );
      },
    );
  }

  Widget _wrapWithDividers({
    required AppColorTokens tokens,
    required Widget child,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 1, color: tokens.borderSubtle),
        Container(
          color: tokens.bgBase,
          alignment: Alignment.center,
          child: child,
        ),
        Container(height: 1, color: tokens.borderSubtle),
      ],
    );
  }
}
