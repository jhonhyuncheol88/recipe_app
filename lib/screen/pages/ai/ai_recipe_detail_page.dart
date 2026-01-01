import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/recipe/recipe_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ai_recipe.dart';
import '../../../model/ingredient.dart';
import '../../../service/ingredient_comparison_service.dart';
import '../../../data/ingredient_repository.dart';
import '../../../util/number_formatter.dart';
import '../../../util/number_format_style.dart';
import '../../widget/index.dart';

/// AI 레시피 상세 페이지
class AiRecipeDetailPage extends StatefulWidget {
  final String aiRecipeId;

  const AiRecipeDetailPage({super.key, required this.aiRecipeId});

  @override
  State<AiRecipeDetailPage> createState() => _AiRecipeDetailPageState();
}

class _AiRecipeDetailPageState extends State<AiRecipeDetailPage> {
  AiRecipe? _aiRecipe;
  List<IngredientComparisonResult> _comparisonResults = [];
  Map<String, double> _inputAmounts = {}; // 사용자 입력 투입량
  bool _isLoading = true;
  bool _isAnalyzing = false;
  String? _errorMessage;
  late IngredientComparisonService _comparisonService;

  @override
  void initState() {
    super.initState();
    _comparisonService = IngredientComparisonService(IngredientRepository());
    _loadAiRecipe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 페이지가 다시 포커스될 때 재료 분석 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _aiRecipe != null && _comparisonResults.isNotEmpty) {
        _refreshIngredientAnalysis();
      }
    });
  }

  Future<void> _loadAiRecipe() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // RecipeCubit에서 AI 레시피 상세 정보 로드
      final aiRecipe = await context.read<RecipeCubit>().getAiRecipeDetail(
            widget.aiRecipeId,
          );

      if (aiRecipe != null) {
        _aiRecipe = aiRecipe;
        await _analyzeIngredients();
      } else {
        // 실제 데이터가 없는 경우 더미 데이터 사용 (테스트용)
        _aiRecipe = _createDummyAiRecipe();
        await _analyzeIngredients();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'AI 레시피를 불러오는데 실패했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeIngredients() async {
    if (_aiRecipe == null) return;

    try {
      setState(() {
        _isAnalyzing = true;
      });

      final results = await _comparisonService.compareIngredients(_aiRecipe!);

      setState(() {
        _comparisonResults = results;
        _isAnalyzing = false;
      });

      // 초기 투입량 설정 (보유 재료가 있는 경우)
      _initializeInputAmounts();
    } catch (e) {
      setState(() {
        _errorMessage = '재료 분석에 실패했습니다: $e';
        _isAnalyzing = false;
      });
    }
  }

  void _initializeInputAmounts() {
    for (final result in _comparisonResults) {
      if (result.isAvailable && result.matchedIngredient != null) {
        // 제안된 투입량으로 초기화
        final suggestedAmount = _comparisonService.getSuggestedInputAmount(
          result.aiIngredient,
          result.matchedIngredient!,
        );
        if (suggestedAmount != null) {
          _inputAmounts[result.aiIngredient.name] = suggestedAmount;
        }
      }
    }
  }

  // 임시 더미 AI 레시피 생성 (테스트용)
  AiRecipe _createDummyAiRecipe() {
    return AiRecipe(
      id: widget.aiRecipeId,
      recipeName: '김치찌개',
      description: '매콤하고 얼큰한 김치찌개입니다. 김치의 신맛과 돼지고기의 고소함이 어우러진 한국의 대표적인 요리입니다.',
      cuisineType: '한식',
      servings: 4,
      prepTimeMinutes: 15,
      cookTimeMinutes: 25,
      totalTimeMinutes: 40,
      difficulty: '초급',
      ingredients: [
        {'name': '김치', 'quantity': 300, 'unit': 'g'},
        {'name': '돼지고기', 'quantity': 200, 'unit': 'g'},
        {'name': '두부', 'quantity': 1, 'unit': '개'},
        {'name': '양파', 'quantity': 1, 'unit': '개'},
        {'name': '대파', 'quantity': 2, 'unit': '대'},
        {'name': '고춧가루', 'quantity': 2, 'unit': '큰술'},
        {'name': '다진마늘', 'quantity': 1, 'unit': '큰술'},
        {'name': '참기름', 'quantity': 1, 'unit': '작은술'},
      ],
      instructions: [
        '김치를 적당한 크기로 썰어주세요.',
        '돼지고기를 한입 크기로 썰어주세요.',
        '양파와 대파를 썰어주세요.',
        '냄비에 참기름을 두르고 돼지고기를 볶아주세요.',
        '김치를 넣고 볶아주세요.',
        '물을 넣고 끓여주세요.',
        '두부와 양파, 대파를 넣고 끓여주세요.',
        '고춧가루와 다진마늘을 넣고 간을 맞춰주세요.',
      ],
      estimatedCost: 15000.0,
      tags: ['한식', '김치', '찌개', '매운맛'],
      generatedAt: DateTime.now(),
      sourceIngredients: ['김치', '돼지고기', '두부', '양파', '대파'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              AppStrings.getAiRecipeDetail(currentLocale),
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              onPressed: () async {
                // 목록 페이지로 돌아가기 전에 데이터 새로고침
                context.read<RecipeCubit>().loadAiRecipes();
                context.pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textSecondary,
              ),
            ),
            actions: [
              if (_canConvertToRecipe())
                TextButton(
                  onPressed: _convertToRecipe,
                  child: Text(
                    AppStrings.getConvertToRecipe(currentLocale),
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          body: _buildBody(currentLocale),
        );
      },
    );
  }

  Widget _buildBody(AppLocale locale) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppStrings.getLoadingAiRecipe(locale)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState(_errorMessage!, locale);
    }

    if (_aiRecipe == null) {
      return _buildErrorState(AppStrings.getAiRecipeNotFound(locale), locale);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoSection(locale),
          const SizedBox(height: 24),
          _buildIngredientsAnalysisSection(locale),
          const SizedBox(height: 24),
          _buildCostSection(locale),
          const SizedBox(height: 24),
          _buildInstructionsSection(locale),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(AppLocale locale) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getBasicInfo(locale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('레시피명', _aiRecipe!.recipeName),
          if (_aiRecipe!.cuisineType != null)
            _buildInfoRow('요리 스타일', _aiRecipe!.cuisineType!),
          _buildInfoRow('인분', '${_aiRecipe!.servings}인분'),
          _buildInfoRow('조리 시간', '${_aiRecipe!.totalTimeMinutes}분'),
          _buildInfoRow('난이도', _aiRecipe!.difficulty),
          const SizedBox(height: 16),
          Text(
            _aiRecipe!.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsAnalysisSection(AppLocale locale) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.getIngredientsAnalysis(locale),
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isAnalyzing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 재료 관리 안내
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '필요 없는 재료는 제거할 수 있습니다. 재료 옆의 - 버튼을 눌러 제거하세요.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.info,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_comparisonResults.isEmpty && !_isAnalyzing)
            _buildEmptyIngredientsState(locale)
          else
            _buildIngredientsList(locale),
        ],
      ),
    );
  }

  Widget _buildEmptyIngredientsState(AppLocale locale) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            '재료 분석 중입니다...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(AppLocale locale) {
    return Column(
      children: _comparisonResults.map((result) {
        return _buildIngredientCard(result, locale);
      }).toList(),
    );
  }

  Widget _buildIngredientCard(
    IngredientComparisonResult result,
    AppLocale locale,
  ) {
    final isAvailable = result.isAvailable;
    final matchedIngredient = result.matchedIngredient;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.warning,
                  color: isAvailable ? AppColors.success : AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.aiIngredient.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isAvailable
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (isAvailable)
                  Text(
                    '${result.aiIngredient.quantity}${result.aiIngredient.unit}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(width: 8),
                // 재료 제거 버튼
                IconButton(
                  onPressed: () => _showRemoveConfirmation(result, locale),
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
                  tooltip: '재료 제거',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isAvailable && matchedIngredient != null) ...[
              // 보유 재료 정보
              Row(
                children: [
                  Text(
                    '보유: ${matchedIngredient.name}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${NumberFormatter.formatCurrency(result.unitCost!, locale, context.watch<NumberFormatCubit>().state)}/${matchedIngredient.purchaseUnitId}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 투입량 입력
              Row(
                children: [
                  Expanded(
                    child: AppInputField(
                      label: '투입량 (${matchedIngredient.purchaseUnitId})',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: _inputAmounts[result.aiIngredient.name]
                                ?.toString() ??
                            '',
                      ),
                      onChanged: (value) {
                        final amount = double.tryParse(value) ?? 0.0;
                        setState(() {
                          _inputAmounts[result.aiIngredient.name] = amount;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '원가',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            NumberFormatter.formatCurrency(
                              _calculateIngredientCost(result),
                              locale,
                              NumberFormatStyle.defaultStyle,
                            ),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 투입량 제안 정보
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${AppStrings.getAiRecipeStandard(locale)}: ${result.aiIngredient.quantity}${result.aiIngredient.unit}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 재료 부족 안내
              InkWell(
                onTap: () => _goToAddIngredient(result.aiIngredient.name),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppStrings.getAddIngredientRequired(locale),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.add_circle_outline,
                        color: AppColors.warning,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _calculateIngredientCost(IngredientComparisonResult result) {
    if (!result.isAvailable || result.matchedIngredient == null) return 0.0;

    final amount = _inputAmounts[result.aiIngredient.name] ?? 0.0;
    final unitCost = result.unitCost ?? 0.0;

    return amount * unitCost;
  }

  Widget _buildCostSection(AppLocale locale) {
    final summary = _getCurrentComparisonSummary();
    final totalCost = summary['totalCost'] as double;
    final availabilityRate = summary['availabilityRate'] as double;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getAiRecipeCostInfo(locale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.getIngredientAvailability(locale)),
                    Text(
                      '${(availabilityRate * 100).toInt()}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.getAiRecipeTotalCost(locale)),
                    Text(
                      NumberFormatter.formatCurrency(totalCost, locale,
                          context.watch<NumberFormatCubit>().state),
                      style: AppTextStyles.headline4.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection(AppLocale locale) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getAiRecipeCookingInstructions(locale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _aiRecipe!.instructions.length,
            itemBuilder: (context, index) {
              final instruction = _aiRecipe!.instructions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.buttonText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        instruction,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, AppLocale locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadAiRecipe,
              child: Text(AppStrings.getRetry(locale)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 현재 투입량을 반영한 비교 결과 요약
  Map<String, dynamic> _getCurrentComparisonSummary() {
    final totalIngredients = _comparisonResults.length;
    final availableIngredients =
        _comparisonResults.where((r) => r.isAvailable).length;
    final unavailableIngredients = totalIngredients - availableIngredients;

    double totalCost = 0.0;
    for (final result in _comparisonResults) {
      if (result.isAvailable && result.matchedIngredient != null) {
        final amount = _inputAmounts[result.aiIngredient.name] ?? 0.0;
        final unitCost = result.unitCost ?? 0.0;
        totalCost += amount * unitCost;
      }
    }

    return {
      'totalIngredients': totalIngredients,
      'availableIngredients': availableIngredients,
      'unavailableIngredients': unavailableIngredients,
      'availabilityRate':
          totalIngredients > 0 ? availableIngredients / totalIngredients : 0.0,
      'totalCost': totalCost,
      'canConvert': unavailableIngredients == 0 &&
          totalIngredients > 0, // 모든 재료가 있고 최소 1개 이상이면 변환 가능
    };
  }

  bool _canConvertToRecipe() {
    if (_comparisonResults.isEmpty) return false;

    final summary = _getCurrentComparisonSummary();
    final canConvert = summary['canConvert'] as bool;

    // 모든 보유 재료에 대해 투입량이 입력되었는지 확인
    if (canConvert) {
      for (final result in _comparisonResults) {
        if (result.isAvailable && result.matchedIngredient != null) {
          final amount = _inputAmounts[result.aiIngredient.name] ?? 0.0;
          if (amount <= 0) {
            return false; // 투입량이 0 이하면 변환 불가
          }
        }
      }
    }

    return canConvert;
  }

  /// 재료 추가 페이지로 이동
  void _goToAddIngredient(String ingredientName) async {
    final result = await context.push(
      '/ingredient/add',
      extra: {'preFilledIngredientName': ingredientName},
    );

    // 재료 추가 페이지에서 돌아온 후 재료 분석 새로고침
    if (result == true && mounted) {
      await _refreshIngredientAnalysis();

      // 사용자에게 알림
      final currentLocale = context.read<LocaleCubit>().state;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('재료가 추가되었습니다. 재료 분석을 새로고침했습니다.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// 재료 분석 새로고침
  Future<void> _refreshIngredientAnalysis() async {
    if (_aiRecipe == null) return;

    try {
      setState(() {
        _isAnalyzing = true;
      });

      final results = await _comparisonService.compareIngredients(_aiRecipe!);

      setState(() {
        _comparisonResults = results;
        _isAnalyzing = false;
      });

      // 투입량 재설정
      _initializeInputAmounts();
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      print('재료 분석 새로고침 실패: $e');
    }
  }

  /// 재료 제거 확인 다이얼로그 표시
  void _showRemoveConfirmation(
    IngredientComparisonResult result,
    AppLocale locale,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '재료 제거',
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${result.aiIngredient.name}을(를) 레시피에서 제거하시겠습니까?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeIngredient(result);
            },
            child: Text(
              '제거',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 재료 제거
  void _removeIngredient(IngredientComparisonResult result) {
    setState(() {
      _comparisonResults.removeWhere(
        (r) => r.aiIngredient.name == result.aiIngredient.name,
      );
      _inputAmounts.remove(result.aiIngredient.name);
    });

    // 사용자에게 알림
    final currentLocale = context.read<LocaleCubit>().state;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.aiIngredient.name}이(가) 제거되었습니다.'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: '실행 취소',
          onPressed: () => _undoRemoveIngredient(result),
        ),
      ),
    );
  }

  /// 재료 제거 실행 취소
  void _undoRemoveIngredient(IngredientComparisonResult result) {
    setState(() {
      _comparisonResults.add(result);
      if (result.isAvailable && result.matchedIngredient != null) {
        final suggestedAmount = _comparisonService.getSuggestedInputAmount(
          result.aiIngredient,
          result.matchedIngredient!,
        );
        if (suggestedAmount != null) {
          _inputAmounts[result.aiIngredient.name] = suggestedAmount;
        }
      }
    });

    // 사용자에게 알림
    final currentLocale = context.read<LocaleCubit>().state;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.aiIngredient.name}이(가) 다시 추가되었습니다.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _convertToRecipe() async {
    try {
      // RecipeCubit을 통해 AI 레시피를 일반 레시피로 변환
      await context.read<RecipeCubit>().convertAiRecipeToRecipe(_aiRecipe!.id);

      if (mounted) {
        final currentLocale = context.read<LocaleCubit>().state;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getConversionSuccess(currentLocale)),
            backgroundColor: AppColors.success,
          ),
        );

        // 상세 페이지 닫고 목록으로 돌아가기
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final currentLocale = context.read<LocaleCubit>().state;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.getConversionFailed(currentLocale)}: $e',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
