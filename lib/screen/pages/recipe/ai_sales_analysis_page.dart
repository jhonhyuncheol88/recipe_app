import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';
import '../../../service/admob_forward.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/ad/ad_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
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
    _adCubit = AdCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdMobForwardService.instance.setAdCubit(_adCubit);
    });
  }

  @override
  void dispose() {
    _specialRequestController.dispose();
    _adCubit.close();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RecipeCubit>().loadRecipes();
      }
    });
    super.dispose();
  }

  Future<void> _showAdAndAnalyze() async {
    try {
      await AdMobForwardService.instance.showInterstitialAd();
      if (mounted) {
        _startAnalysis();
      }
    } catch (e) {
      if (mounted) {
        _startAnalysis();
      }
    }
  }

  Future<void> _startAnalysis() async {
    if (_isAnalyzing) return;

    final currentLocale = context.read<LocaleCubit>().state;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppStrings.getAiSalesAnalysis(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecipeInfoCard(currentLocale),
            const SizedBox(height: 20),
            _buildSpecialRequestSection(currentLocale),
            const SizedBox(height: 20),
            _buildAnalysisButton(currentLocale),
            const SizedBox(height: 20),
            if (_isAnalyzing) _buildLoadingState(currentLocale),
            if (_errorMessage != null) _buildErrorState(currentLocale),
            if (_analysisResult != null) _buildAnalysisResult(currentLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInfoCard(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.recipe?.name ?? AppStrings.getRecipeNameNotFound(locale),
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.recipe?.description.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                widget.recipe!.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
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
                      context.watch<NumberFormatCubit>().state,
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
                      context.watch<NumberFormatCubit>().state,
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

  Widget _buildInfoItem(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRequestSection(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getSpecialRequest(locale),
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.getSpecialRequestHint(locale),
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _specialRequestController,
              maxLines: 3,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: AppStrings.getSpecialRequestHint(locale),
                hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          if (adState is AdWatched) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _adCubit.reset();
              _startAnalysis();
            });
          }

          if (adState is AdFailed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _adCubit.reset();
              _startAnalysis();
            });
          }

          return AiAnalysisButton(
            onAnalysisRequested: () {
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

  Widget _buildLoadingState(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
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
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.getAnalysisFailed(locale),
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? AppStrings.getAnalysisFailedMessage(locale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
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

  Widget _buildAnalysisResult(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    if (_analysisResult == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getAiSalesAnalysisTitle(locale),
          style: AppTextStyles.headline4.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getAiSalesAnalysisDescription(locale),
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
        AiSalesAnalysisWidget(analysisResult: _analysisResult!, locale: locale),
      ],
    );
  }
}
