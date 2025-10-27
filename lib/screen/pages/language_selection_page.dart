import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../util/app_locale.dart';
import '../../controller/setting/locale_cubit.dart';

/// 언어 선택 페이지
class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  AppLocale? _selectedLocale;

  @override
  Widget build(BuildContext context) {
    // 기본 언어를 선택되지 않았다면 현재 시스템 언어 또는 한국어 설정
    _selectedLocale ??= AppLocale.korea;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고/아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Icons.language,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // 타이틀
                Text(
                  _getTitleText(),
                  style: AppTextStyles.headline2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 부제목
                Text(
                  _getSubtitleText(),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // 언어 선택 리스트
                _buildLanguageList(),

                const SizedBox(height: 32),

                // 다음 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedLocale != null ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _getNextButtonText(),
                      style: AppTextStyles.buttonLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageList() {
    final languages = [
      AppLocale.korea,
      AppLocale.usa,
      AppLocale.china,
      AppLocale.japan,
    ];

    return Column(
      children: languages.map((locale) {
        final isSelected = _selectedLocale == locale;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedLocale = locale;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.displayName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          locale.nativeName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleNext() async {
    if (_selectedLocale == null) return;

    if (!mounted) return;

    try {
      // 1. 언어 선택 완료 플래그 먼저 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('language_selected', true);

      if (!mounted) return;

      // 2. LocaleCubit에 선택한 언어 저장 및 상태 업데이트
      final localeCubit = context.read<LocaleCubit>();
      await localeCubit.setLocale(_selectedLocale!);

      // 3. SharedPreferences 변경사항 반영을 위한 짧은 대기
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // 4. 온보딩으로 이동
      context.go('/onboarding');
    } catch (e) {
      // 에러 처리
      print('언어 선택 처리 중 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다. 다시 시도해주세요.'),
          ),
        );
      }
    }
  }

  // 현재 선택된 언어에 따라 텍스트 반환
  String _getTitleText() {
    switch (_selectedLocale) {
      case AppLocale.korea:
        return '언어를 선택해주세요';
      case AppLocale.japan:
        return '言語を選択してください';
      case AppLocale.china:
        return '请选择语言';
      case AppLocale.usa:
        return 'Select a language';
      default:
        return '언어를 선택해주세요';
    }
  }

  String _getSubtitleText() {
    switch (_selectedLocale) {
      case AppLocale.korea:
        return '원하는 언어를 선택하면\n앱이 해당 언어로 표시됩니다';
      case AppLocale.japan:
        return '好きな言語を選択すると\nアプリがその言語で表示されます';
      case AppLocale.china:
        return '选择语言后\n应用将以该语言显示';
      case AppLocale.usa:
        return 'Choose your language\nand the app will display in that language';
      default:
        return '원하는 언어를 선택하면\n앱이 해당 언어로 표시됩니다';
    }
  }

  String _getNextButtonText() {
    switch (_selectedLocale) {
      case AppLocale.korea:
        return '다음';
      case AppLocale.japan:
        return '次へ';
      case AppLocale.china:
        return '下一步';
      case AppLocale.usa:
        return 'Next';
      default:
        return '다음';
    }
  }
}
