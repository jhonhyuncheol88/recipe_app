import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../service/admob_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// AI 기능을 위한 광고 시청 알럿 다이얼로그 (공통)
class AiAnalysisAdDialog extends StatelessWidget {
  final VoidCallback? onAdWatched;
  final VoidCallback? onCancel;
  final String customTitle;
  final String customMessage;
  final String customDescription;

  const AiAnalysisAdDialog({
    super.key,
    this.onAdWatched,
    this.onCancel,
    this.customTitle = 'AI 분석',
    this.customMessage = 'AI 분석은 광고 시청 후 진행해드려요!',
    this.customDescription = '광고 시청 후 AI가 분석을 진행합니다.',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.accent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customTitle,
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        customDescription,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(
                AppStrings.getCancel(currentLocale),
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _showAdAndAnalyze(context, currentLocale);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '광고 시청하기',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 광고를 표시하고 분석을 진행하는 메서드
  Future<void> _showAdAndAnalyze(BuildContext context, AppLocale locale) async {
    print('_showAdAndAnalyze 시작');
    try {
      // 전면 광고 표시
      print('전면 광고 표시 시작');
      final adWatched = await AdMobService.instance.showInterstitialAd();
      print('전면 광고 결과: $adWatched');

      if (adWatched) {
        // 광고 시청 완료 후 분석 진행
        print('광고 시청 완료, 콜백 호출 시작');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('광고 시청 완료! AI 분석을 시작합니다.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );

          // 콜백 호출
          print(
            'onAdWatched 콜백 호출: ${onAdWatched != null ? "콜백 존재" : "콜백 없음"}',
          );

          if (onAdWatched != null) {
            print('onAdWatched 콜백 실행 시작');
            try {
              onAdWatched?.call();
              print('onAdWatched 콜백 실행 성공');
            } catch (e) {
              print('onAdWatched 콜백 실행 중 오류: $e');
            }
            print('onAdWatched 콜백 호출 완료');
          } else {
            print('onAdWatched 콜백이 null이므로 실행하지 않음');
          }
        }
      } else {
        // 광고 시청 실패 시 처리
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('광고 로드에 실패했습니다. 잠시 후 다시 시도해주세요.'),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // 에러 발생 시 처리
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// AI 기능을 위한 광고 시청 버튼 위젯 (공통)
class AiAnalysisButton extends StatelessWidget {
  final VoidCallback? onAnalysisRequested;
  final String? buttonText;
  final IconData? icon;
  final bool isOutlined;
  final String dialogTitle;
  final String dialogMessage;
  final String dialogDescription;

  const AiAnalysisButton({
    super.key,
    this.onAnalysisRequested,
    this.buttonText,
    this.icon,
    this.isOutlined = false,
    this.dialogTitle = 'AI 분석',
    this.dialogMessage = 'AI 분석은 광고 시청 후 진행해드려요!',
    this.dialogDescription = '광고 시청 후 AI가 분석을 진행합니다.',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        if (isOutlined) {
          return OutlinedButton.icon(
            onPressed: () => _showAnalysisDialog(context, currentLocale),
            icon: Icon(icon ?? Icons.auto_awesome, size: 20),
            label: Text(
              buttonText ?? AppStrings.getAnalyzeWithAi(currentLocale),
              style: AppTextStyles.buttonMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }

        return ElevatedButton.icon(
          onPressed: () => _showAnalysisDialog(context, currentLocale),
          icon: Icon(icon ?? Icons.auto_awesome, size: 20),
          label: Text(
            buttonText ?? AppStrings.getAnalyzeWithAi(currentLocale),
            style: AppTextStyles.buttonMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.buttonText,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  /// 분석 다이얼로그를 표시하는 메서드
  void _showAnalysisDialog(BuildContext context, AppLocale locale) {
    print('_showAnalysisDialog 호출됨');
    print(
      'onAnalysisRequested 콜백: ${onAnalysisRequested != null ? "존재" : "없음"}',
    );

    showDialog(
      context: context,
      builder: (context) => AiAnalysisAdDialog(
        onAdWatched: () {
          print('AiAnalysisAdDialog onAdWatched 콜백 실행');
          print(
            'onAnalysisRequested 콜백: ${onAnalysisRequested != null ? "존재" : "없음"}',
          );
          print('onAnalysisRequested 콜백 호출 시작');
          try {
            onAnalysisRequested?.call();
            print('onAnalysisRequested 콜백 호출 성공');
          } catch (e) {
            print('onAnalysisRequested 콜백 호출 중 오류: $e');
          }
          print('onAnalysisRequested 콜백 호출 완료');
        },
        onCancel: () {
          print('사용자가 취소함');
          // 취소 시 아무것도 하지 않음
        },
        customTitle: dialogTitle,
        customMessage: dialogMessage,
        customDescription: dialogDescription,
      ),
    );
  }
}
