import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../model/tag.dart';
import '../../../service/gemini_service.dart';
import '../../../router/router_helper.dart';

import 'dart:math';

class AiMainPage extends StatefulWidget {
  final Function(int)? onTabChanged;

  const AiMainPage({super.key, this.onTabChanged});

  @override
  State<AiMainPage> createState() => _AiMainPageState();
}

class _AiMainPageState extends State<AiMainPage> {
  final GeminiService _geminiService = GeminiService();
  List<Ingredient> _selectedIngredients = [];
  bool _isGeneratingRecipe = false;
  Map<String, dynamic>? _generatedRecipe;
  List<String> _missingIngredients = [];

  @override
  void initState() {
    super.initState();
    // 재료 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IngredientCubit>().loadIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              AppStrings.getAiRecipeGeneration(currentLocale),
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(currentLocale),
                color: AppColors.textSecondary,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(currentLocale),
                const SizedBox(height: 24),
                _buildIngredientSelection(currentLocale),
                const SizedBox(height: 24),

                _buildRecipeGeneration(currentLocale),
                if (_generatedRecipe != null) ...[
                  const SizedBox(height: 24),
                  _buildGeneratedRecipe(currentLocale),
                ],
                if (_missingIngredients.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildMissingIngredients(currentLocale),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppLocale locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.accent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.getAiRecipeGenerationTitle(locale),
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.getAiRecipeGenerationDescription(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientSelection(AppLocale locale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getSelectIngredientsToUse(locale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<IngredientCubit, IngredientState>(
            builder: (context, state) {
              if (state is IngredientLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is IngredientLoaded) {
                final ingredients = state.ingredients;

                if (ingredients.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        AppStrings.getNoRegisteredIngredients(locale),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ingredients.map((ingredient) {
                            final isSelected = _selectedIngredients.contains(
                              ingredient,
                            );

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedIngredients.remove(ingredient);
                                  } else {
                                    _selectedIngredients.add(ingredient);
                                  }
                                });
                              },
                              child: Container(
                                width: 100,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accent
                                        : AppColors.divider,
                                    width: 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.accent.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        ingredient.name,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isSelected
                                              ? AppColors.buttonText
                                              : AppColors.textPrimary,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedIngredients.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.accent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${AppStrings.getSelectedIngredients(locale)}: ${_selectedIngredients.map((e) => e.name).join(', ')}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }

              return Center(
                child: Text(
                  AppStrings.getCannotLoadIngredients(locale),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeGeneration(AppLocale locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getRecipeGeneration(locale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedIngredients.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.getNoIngredientsForRecipe(locale),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Text(
                  '${AppStrings.getSelectedIngredients(locale)}: ${_selectedIngredients.map((e) => e.name).join(', ')}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingRecipe
                        ? null
                        : () => _generateRecipe(locale),
                    icon: _isGeneratingRecipe
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isGeneratingRecipe
                          ? AppStrings.getGeneratingRecipe(locale)
                          : AppStrings.getAiRecipeGenerationButton(locale),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGeneratedRecipe(AppLocale locale) {
    if (_generatedRecipe == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.getGeneratedRecipe(locale),
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _generatedRecipe!['recipe_name'] ??
                AppStrings.getRecipeName(locale),
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _generatedRecipe!['description'] ??
                AppStrings.getRecipeDescription(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecipeDetails(locale),
          const SizedBox(height: 24),
          _buildNewRecipeButton(locale),
          const SizedBox(height: 24),
          _buildViewSavedRecipesButton(locale),
        ],
      ),
    );
  }

  Widget _buildRecipeDetails(AppLocale locale) {
    final recipe = _generatedRecipe!;

    return Column(
      children: [
        _buildInfoRow(
          AppStrings.getCookingStyle(locale),
          recipe['cuisine_type'] ?? AppStrings.getKoreanCuisine(locale),
        ),
        _buildInfoRow(
          AppStrings.getServings(locale),
          '${recipe['servings']}${AppStrings.getPeople(locale)}',
        ),
        _buildInfoRow(
          AppStrings.getCookingTime(locale),
          '${recipe['total_time_minutes']}${AppStrings.getMinutes(locale)}',
        ),
        _buildInfoRow(
          AppStrings.getDifficulty(locale),
          recipe['difficulty'] ?? AppStrings.getBeginnerLevel(locale),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.getRequiredIngredients(locale),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...(recipe['ingredients'] as List? ?? []).map((ingredient) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• ${ingredient['name']} ${ingredient['quantity']} ${ingredient['unit']}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        Text(
          AppStrings.getCookingInstructions(locale),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...(recipe['instructions'] as List? ?? []).asMap().entries.map((entry) {
          final index = entry.key + 1;
          final instruction = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
                      '$index',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.buttonText,
                        fontWeight: FontWeight.bold,
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
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMissingIngredients(AppLocale locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_shopping_cart, color: AppColors.warning),
              const SizedBox(width: 12),
              Text(
                AppStrings.getAdditionalIngredientsNeeded(locale),
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._missingIngredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _addIngredient(ingredient),
                    child: Text(
                      AppStrings.getAddIngredient(locale),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addAllMissingIngredients,
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(AppStrings.getAddAllIngredientsAtOnce(locale)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewRecipeButton(AppLocale locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getCreateDifferentStyleRecipes(locale),
            style: AppTextStyles.headline4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.getCreateDifferentStyleRecipesDescription(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGeneratingRecipe
                      ? null
                      : () => _generateDifferentStyleRecipe(locale),
                  icon: const Icon(Icons.restaurant),
                  label: Text(
                    AppStrings.getKoreanStyle(locale),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isGeneratingRecipe
                      ? null
                      : () => _generateDifferentStyleRecipe(locale),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    AppStrings.getFusionStyle(locale),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewSavedRecipesButton(AppLocale locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark, color: AppColors.accent),
              const SizedBox(width: 12),
              Text(
                AppStrings.getViewSavedAiRecipes(locale),
                style: AppTextStyles.headline4.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.getViewSavedAiRecipesDescription(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // AI 레시피 관리 페이지로 이동
                if (mounted) {
                  widget.onTabChanged?.call(1); // 두 번째 탭으로 이동
                }
              },
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                AppStrings.getViewSavedRecipes(locale),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.buttonText,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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

  Future<void> _generateRecipe(AppLocale locale) async {
    if (_selectedIngredients.isEmpty) return;

    setState(() {
      _isGeneratingRecipe = true;
      _generatedRecipe = null;
      _missingIngredients = [];
    });

    try {
      final recipe = await _geminiService.generateRecipeFromIngredients(
        _selectedIngredients,
        servings: 2,
        cookingTime: 30,
      );

      setState(() {
        _generatedRecipe = recipe;
        _isGeneratingRecipe = false;
      });

      // AI 레시피 자동 저장
      _saveAiRecipe(recipe, locale);

      // 누락된 재료 분석
      _analyzeMissingIngredients(recipe);
    } catch (e) {
      setState(() {
        _isGeneratingRecipe = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.getRecipeGenerationError(locale)}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _generateDifferentStyleRecipe(AppLocale locale) async {
    if (_selectedIngredients.isEmpty) return;

    setState(() {
      _isGeneratingRecipe = true;
      _generatedRecipe = null;
      _missingIngredients = [];
    });

    try {
      // 랜덤으로 여러 나라의 음식 스타일 선택
      final randomCuisineTypes = _getRandomCuisineTypes(locale);

      final recipe = await _geminiService.generateDifferentStyleRecipe(
        _selectedIngredients,
        servings: 2,
        cookingTime: 30,
        cuisineTypes: randomCuisineTypes,
      );

      setState(() {
        _generatedRecipe = recipe;
        _isGeneratingRecipe = false;
      });

      // AI 레시피 자동 저장
      _saveAiRecipe(recipe, locale);

      // 누락된 재료 분석
      _analyzeMissingIngredients(recipe);
    } catch (e) {
      setState(() {
        _isGeneratingRecipe = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.getRecipeGenerationError(locale)}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 랜덤으로 여러 나라의 음식 스타일을 선택하는 메서드
  List<String> _getRandomCuisineTypes(AppLocale locale) {
    final random = Random();
    final allCuisineTags = DefaultTags.recipeTagsFor(locale);

    // 퓨전 태그는 제외하고 실제 국가별 태그만 선택
    final countryTags = allCuisineTags
        .where((tag) => tag.id != 'fusion')
        .toList();

    // 1-2개의 랜덤 태그 선택
    final numberOfTags = random.nextInt(2) + 1; // 1개 또는 2개
    final selectedTags = <String>[];

    // 중복 없이 랜덤 선택
    while (selectedTags.length < numberOfTags && countryTags.isNotEmpty) {
      final randomIndex = random.nextInt(countryTags.length);
      final selectedTag = countryTags[randomIndex];

      if (!selectedTags.contains(selectedTag.name)) {
        selectedTags.add(selectedTag.name);
        countryTags.removeAt(randomIndex); // 선택된 태그는 제거하여 중복 방지
      }
    }

    // 퓨전 태그도 추가
    selectedTags.add(AppStrings.getFusion(locale));

    return selectedTags;
  }

  void _analyzeMissingIngredients(Map<String, dynamic> recipe) {
    try {
      final analysis = _geminiService.analyzeRecipeIngredients(
        recipe,
        _selectedIngredients,
      );

      final missingIngredients = analysis['missing_ingredients'] as List? ?? [];

      setState(() {
        _missingIngredients = missingIngredients
            .map((ingredient) => ingredient['name'] as String)
            .where((name) => name.isNotEmpty)
            .toList();
      });

      // 분석 결과 로그
      print('재료 분석 결과: $analysis');
    } catch (e) {
      print('재료 분석 중 오류: $e');
      // 기존 방식으로 폴백
      final recipeIngredients = recipe['ingredients'] as List? ?? [];
      final selectedIngredientNames = _selectedIngredients
          .map((e) => e.name.toLowerCase())
          .toList();

      final missing = <String>[];

      for (final ingredient in recipeIngredients) {
        final name = ingredient['name'] as String? ?? '';
        if (name.isNotEmpty) {
          final isAvailable = selectedIngredientNames.any(
            (selected) =>
                selected.contains(name.toLowerCase()) ||
                name.toLowerCase().contains(selected),
          );

          if (!isAvailable) {
            missing.add(name);
          }
        }
      }

      setState(() {
        _missingIngredients = missing;
      });
    }
  }

  // AI 레시피 자동 저장
  void _saveAiRecipe(Map<String, dynamic> recipe, AppLocale locale) {
    try {
      final sourceIngredients = _selectedIngredients
          .map((e) => e.name)
          .toList();

      // 태그 정보 확인 및 설정
      final tags = recipe['tags'] as List? ?? [];
      final cuisineType = recipe['cuisine_type'] as String? ?? '';

      // 요리 스타일이 있지만 태그가 없는 경우 기본 태그 추가
      if (cuisineType.isNotEmpty && tags.isEmpty) {
        final defaultTags = _getDefaultTagsForCuisine(cuisineType, locale);
        recipe['tags'] = defaultTags;
      }

      // RecipeCubit을 통해 AI 레시피 저장
      context.read<RecipeCubit>().saveAiRecipe(recipe, sourceIngredients);

      // 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getAiRecipeSaved(locale)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('AI 레시피 저장 중 오류: $e');
      // 오류가 발생해도 사용자 경험에 영향을 주지 않음
    }
  }

  // 요리 스타일에 따른 기본 태그 반환
  List<String> _getDefaultTagsForCuisine(String cuisineType, AppLocale locale) {
    final allTags = DefaultTags.recipeTagsFor(locale);
    final defaultTags = <String>[];

    // 요리 스타일에 맞는 태그 찾기
    for (final tag in allTags) {
      if (cuisineType.toLowerCase().contains(tag.name.toLowerCase()) ||
          tag.name.toLowerCase().contains(cuisineType.toLowerCase())) {
        defaultTags.add(tag.name);
        break; // 첫 번째 매칭되는 태그만 사용
      }
    }

    // 매칭되는 태그가 없으면 퓨전 태그 추가
    if (defaultTags.isEmpty) {
      defaultTags.add('퓨전');
    }

    return defaultTags;
  }

  void _addIngredient(String ingredientName) {
    // 재료 추가 페이지로 이동하면서 재료 이름 전달
    RouterHelper.goToIngredientAddWithName(context, ingredientName);
  }

  void _addAllMissingIngredients() {
    if (_missingIngredients.isEmpty) return;

    try {
      // 누락된 재료들을 일괄 추가 페이지로 전달
      final cubit = context.read<IngredientCubit>();
      final ingredientsForBulkAdd = cubit.prepareMissingIngredientsForBulkAdd(
        _missingIngredients,
      );

      if (ingredientsForBulkAdd.isNotEmpty) {
        // 일괄 추가 페이지로 이동하면서 데이터 전달
        RouterHelper.goToIngredientBulkAddWithData(
          context,
          ingredientsForBulkAdd,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.getBulkIngredientAdditionError(AppLocale.korea)}: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showInfoDialog(AppLocale locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.getAiRecipeGeneratorUsage(locale),
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getAiRecipeGeneratorInstructions(locale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppStrings.getConfirm(locale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
