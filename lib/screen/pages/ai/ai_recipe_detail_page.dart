import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ai_recipe.dart';
import '../../../service/ingredient_comparison_service.dart';
import '../../../data/ingredient_repository.dart';
import '../../../util/number_formatter.dart';
import '../../../util/number_format_style.dart';
import '../../widget/index.dart';
import '../../../router/router_helper.dart';

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
  final Map<String, double> _inputAmounts = {};
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

      final aiRecipe = await context.read<RecipeCubit>().getAiRecipeDetail(
            widget.aiRecipeId,
          );

      if (aiRecipe != null) {
        _aiRecipe = aiRecipe;
        await _analyzeIngredients();
      } else {
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
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(
              AppStrings.getAiRecipeDetail(currentLocale),
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              onPressed: () async {
                context.read<RecipeCubit>().loadAiRecipes();
                context.pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
              ),
            ),
            actions: [
              if (_canConvertToRecipe())
                TextButton(
                  onPressed: _convertToRecipe,
                  child: Text(
                    AppStrings.getConvertToRecipe(currentLocale),
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(AppStrings.getLoadingAiRecipe(locale),
                style: TextStyle(color: colorScheme.onSurface)),
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
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getBasicInfo(locale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
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
              color: colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withAlpha(153),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsAnalysisSection(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppStrings.getIngredientsAnalysis(locale),
                style: AppTextStyles.headline4.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isAnalyzing)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: colorScheme.primary),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 4),
          if (_comparisonResults.isEmpty && !_isAnalyzing)
            _buildEmptyIngredientsState(locale)
          else
            _buildIngredientsList(locale),
        ],
      ),
    );
  }

  Widget _buildEmptyIngredientsState(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: colorScheme.onSurface.withAlpha(102),
          ),
          const SizedBox(height: 16),
          Text(
            '재료 분석 중입니다...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withAlpha(153),
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
    final colorScheme = Theme.of(context).colorScheme;
    final formatStyle = context.watch<NumberFormatCubit>().state;

    return Card(
      color: colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isAvailable
              ? colorScheme.outlineVariant
              : Colors.orange.withAlpha(76),
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 재료명 행
            Row(
              children: [
                Icon(
                  isAvailable ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                  color: isAvailable ? Colors.green : Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.aiIngredient.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${result.aiIngredient.quantity}${result.aiIngredient.unit}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurface.withAlpha(120),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showRemoveConfirmation(result, locale),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: colorScheme.onSurface.withAlpha(100),
                  ),
                ),
              ],
            ),
            // 보유 재료 정보
            if (isAvailable && matchedIngredient != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  // 단가
                  Expanded(
                    child: Text(
                      '${matchedIngredient.name}  ·  ${NumberFormatter.formatCurrency(result.unitCost!, locale, formatStyle)}/${matchedIngredient.purchaseUnitId}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.green.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 투입량 + 원가 한 행
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppInputField(
                      label: '투입량 (${matchedIngredient.purchaseUnitId})',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: _inputAmounts[result.aiIngredient.name]?.toString() ?? '',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _inputAmounts[result.aiIngredient.name] =
                              double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '원가',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurface.withAlpha(120),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          NumberFormatter.formatCurrency(
                            _calculateIngredientCost(result),
                            locale,
                            NumberFormatStyle.defaultStyle,
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              // 미보유 재료 — 추가 유도
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _goToAddIngredient(result.aiIngredient.name),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 15, color: Colors.orange),
                    const SizedBox(width: 6),
                    Text(
                      AppStrings.getAddIngredientRequired(locale),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getAiRecipeCostInfo(locale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary.withAlpha(76)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.getIngredientAvailability(locale),
                        style: TextStyle(color: colorScheme.onSurface)),
                    Text(
                      '${(availabilityRate * 100).toInt()}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.getAiRecipeTotalCost(locale),
                        style: TextStyle(color: colorScheme.onSurface)),
                    Text(
                      NumberFormatter.formatCurrency(totalCost, locale,
                          context.watch<NumberFormatCubit>().state),
                      style: AppTextStyles.headline4.copyWith(
                        color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getAiRecipeCookingInstructions(locale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
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
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onPrimary,
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
                          color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: colorScheme.error),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loadAiRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(AppStrings.getRetry(locale)),
            ),
          ],
        ),
      ),
    );
  }

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
      'canConvert': unavailableIngredients == 0 && totalIngredients > 0,
    };
  }

  bool _canConvertToRecipe() {
    if (_comparisonResults.isEmpty) return false;

    final summary = _getCurrentComparisonSummary();
    return summary['canConvert'] as bool;
  }

  void _convertToRecipe() {
    final locale = context.read<LocaleCubit>().state;
    _showConversionConfirmDialog(locale);
  }

  void _showConversionConfirmDialog(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getConvertToRecipeTitle(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(AppStrings.getConvertToRecipeMessage(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performConversion();
            },
            child: Text(AppStrings.getConfirm(locale)),
          ),
        ],
      ),
    );
  }

  Future<void> _performConversion() async {
    try {
      final ingredients = _comparisonResults.map((result) {
        final amount = _inputAmounts[result.aiIngredient.name] ?? 0.0;
        return {
          'ingredientId': result.matchedIngredient!.id,
          'amount': amount,
          'unitId': result.matchedIngredient!.purchaseUnitId,
        };
      }).toList();

      final success = await context.read<RecipeCubit>().convertAiRecipeToRecipe(
            _aiRecipe!,
            ingredients,
          );

      if (success && mounted) {
        final locale = context.read<LocaleCubit>().state;
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getRecipeConverted(locale)),
            backgroundColor: colorScheme.secondary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('변환 실패: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  void _showRemoveConfirmation(
      IngredientComparisonResult result, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('재료 제거', style: TextStyle(color: colorScheme.onSurface)),
        content: Text('${result.aiIngredient.name} 재료를 레시피에서 제거하시겠습니까?',
            style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeIngredient(result);
            },
            child: Text('제거', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _removeIngredient(IngredientComparisonResult result) {
    setState(() {
      _comparisonResults.remove(result);
      _inputAmounts.remove(result.aiIngredient.name);
    });
  }

  void _refreshIngredientAnalysis() {
    _analyzeIngredients();
  }

  void _goToAddIngredient(String name) {
    RouterHelper.goToIngredientAddWithName(context, name);
  }
}
