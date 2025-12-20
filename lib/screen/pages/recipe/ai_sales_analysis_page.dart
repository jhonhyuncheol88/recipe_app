import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';
import '../../../service/admob_service.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/ad/ad_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../model/recipe.dart';
import '../../widget/ai_sales_analysis_widget.dart';
import '../../widget/index.dart';
import '../../widget/ai_analysis_ad_dialog.dart';

/// AI 판매 분석 페이지
class AiSalesAnalysisPage extends StatefulWidget {
  final Recipe? recipe;

  const AiSalesAnalysisPage({super.key, this.recipe});

  @override
  State<AiSalesAnalysisPage> createState() => _AiSalesAnalysisPageState();
}

class _AiSalesAnalysisPageState extends State<AiSalesAnalysisPage> {
  final TextEditingController _specialRequestController =
      TextEditingController();
  late final AdCubit _adCubit;
  Map<String, dynamic>? _analysisResult;
  bool _isAnalyzing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // AdCubit 초기화
    _adCubit = AdCubit();

    // AdMobService에 AdCubit 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdMobService.instance.setAdCubit(_adCubit);
    });
  }

  @override
  void dispose() {
    _specialRequestController.dispose();
    _adCubit.close();
    // 🔴 추가: 페이지 종료 시 레시피 목록 새로고침
    // AI 분석 후 뒤로가기 시 레시피 상태 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecipeCubit>().loadRecipes();
      }
    });
    super.dispose();
  }

  /// 광고 표시 후 AI 분석 진행
  Future<void> _showAdAndAnalyze() async {
    try {
      // 전면 광고 표시 시도
      await AdMobService.instance.showInterstitialAd();

      // 광고 성공/실패와 관계없이 AI 분석 진행
      if (mounted) {
        _startAnalysis();
      }
    } catch (e) {
      // 광고 오류 발생 시에도 AI 분석 진행
      if (mounted) {
        _startAnalysis();
      }
    }
  }

  /// AI 분석 시작
  Future<void> _startAnalysis() async {
    if (_isAnalyzing) return;

    final currentLocale = context.read<LocaleCubit>().state;

    // Recipe 객체가 없으면 분석할 수 없음
    if (widget.recipe == null) {
      setState(() {
        _errorMessage = AppStrings.getRecipeNotFound(currentLocale);
        _isAnalyzing = false;
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    try {
      final result = await context.read<RecipeCubit>().performAiSalesAnalysis(
            widget.recipe!.id,
            userQuery: _specialRequestController.text.trim().isEmpty
                ? null
                : _specialRequestController.text.trim(),
            userLanguage: currentLocale.name,
          );

      if (result != null) {
        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
        });
      } else {
        setState(() {
          _errorMessage = AppStrings.getAnalysisResultNotFound(currentLocale);
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${AppStrings.getAnalysisError(currentLocale)}: $e';
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getAiSalesAnalysis(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 레시피 정보 카드
            _buildRecipeInfoCard(currentLocale),
            const SizedBox(height: 20),

            // 특별 요청사항 입력
            _buildSpecialRequestSection(currentLocale),
            const SizedBox(height: 20),

            // 분석 시작 버튼
            _buildAnalysisButton(currentLocale),
            const SizedBox(height: 20),

            // 분석 결과 또는 로딩/에러 상태
            if (_isAnalyzing) _buildLoadingState(currentLocale),
            if (_errorMessage != null) _buildErrorState(currentLocale),
            if (_analysisResult != null) _buildAnalysisResult(currentLocale),
          ],
        ),
      ),
    );
  }

  /// 레시피 정보 카드
  Widget _buildRecipeInfoCard(AppLocale locale) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipe?.name ?? AppStrings.getRecipeNameNotFound(locale),
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.recipe?.description.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                widget.recipe!.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.attach_money,
                    AppStrings.getTotalCost(locale),
                    NumberFormatter.formatCurrency(
                      (widget.recipe?.totalCost ?? 0).toDouble(),
                      locale,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.restaurant,
                    AppStrings.getIngredientCountSimple(locale),
                    NumberFormatter.formatQuantity(
                      widget.recipe?.ingredients.length ?? 0,
                      locale,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 정보 아이템
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 특별 요청사항 입력 섹션
  Widget _buildSpecialRequestSection(AppLocale locale) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getSpecialRequest(locale),
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.getSpecialRequestHint(locale),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _specialRequestController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppStrings.getSpecialRequestHint(locale),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 분석 시작 버튼
  Widget _buildAnalysisButton(AppLocale locale) {
    if (_isAnalyzing) {
      return SizedBox(
        width: double.infinity,
        child: AppButton(
          text: AppStrings.getAnalyzing(locale),
          type: AppButtonType.primary,
          onPressed: null,
          isLoading: true,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: BlocBuilder<AdCubit, AdState>(
        bloc: _adCubit,
        builder: (context, adState) {
          // 광고 시청 완료 상태일 때 AI 분석 실행
          if (adState is AdWatched) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _adCubit.reset(); // 상태 초기화
              _startAnalysis();
            });
          }

          // 광고 실패 상태일 때도 AI 분석 실행 (광고 없이 진행)
          if (adState is AdFailed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _adCubit.reset(); // 상태 초기화
              _startAnalysis();
            });
          }

          return AiAnalysisButton(
            onAnalysisRequested: () {
              // 🔴 수동으로 광고 시도 후 분석 진행
              _showAdAndAnalyze();
            },
            buttonText: AppStrings.getStartAnalysis(locale),
            icon: Icons.analytics,
            dialogTitle: AppStrings.getAiSalesAnalysisDialogTitle(locale),
            dialogMessage: AppStrings.getAiSalesAnalysisDialogMessage(locale),
            dialogDescription:
                AppStrings.getAiSalesAnalysisDialogDescription(locale),
          );
        },
      ),
    );
  }

  /// 로딩 상태
  Widget _buildLoadingState(AppLocale locale) {
    return SizedBox(
      width: double.infinity,
      child: AppCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '${AppStrings.getAnalyzing(locale)}...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState(AppLocale locale) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.getAnalysisFailed(locale),
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? AppStrings.getAnalysisFailedMessage(locale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: AppStrings.getRetry(locale),
              type: AppButtonType.secondary,
              onPressed: _startAnalysis,
            ),
          ],
        ),
      ),
    );
  }

  /// 분석 결과
  Widget _buildAnalysisResult(AppLocale locale) {
    if (_analysisResult == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getAiSalesAnalysisTitle(locale),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getAiSalesAnalysisDescription(locale),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        AiSalesAnalysisWidget(analysisResult: _analysisResult!, locale: locale),
      ],
    );
  }
}
