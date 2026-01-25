import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';

import '../../../controller/setting/locale_cubit.dart';
import '../../../model/ingredient.dart';

import '../../../service/ai_recipe_service.dart';
import '../../../service/ai_analysis_service.dart';
import '../../../router/router_helper.dart';
import '../../widget/ai_analysis_ad_dialog.dart';
import 'package:logger/logger.dart';

class AiMainPage extends StatefulWidget {
  final Function(int)? onTabChanged;

  const AiMainPage({super.key, this.onTabChanged});

  @override
  State<AiMainPage> createState() => _AiMainPageState();
}

class _AiMainPageState extends State<AiMainPage> {
  final AiRecipeService _aiRecipeService = AiRecipeService();
  final AiAnalysisService _aiAnalysisService = AiAnalysisService();
  late final Logger _logger;
  List<Ingredient> _selectedIngredients = [];
  bool _isGeneratingRecipe = false;
  Map<String, dynamic>? _generatedRecipe;
  List<String> _missingIngredients = [];

  @override
  void initState() {
    super.initState();

    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<IngredientCubit>().loadIngredients();
    });
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
              AppStrings.getAiRecipeGeneration(currentLocale),
              style: AppTextStyles.headline3.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            backgroundColor: colorScheme.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(currentLocale),
                color: colorScheme.onSurface.withAlpha(153),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

  Widget _buildIngredientSelection(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getSelectIngredientsToUse(locale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<IngredientCubit, IngredientState>(
            builder: (context, state) {
              if (state is IngredientLoading) {
                return Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary));
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
                          color: colorScheme.onSurface.withAlpha(153),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = 100.0;
                        final spacing = 8.0;
                        final crossAxisCount =
                            ((constraints.maxWidth + spacing) /
                                    (itemWidth + spacing))
                                .floor();

                        final itemHeight = 50.0;
                        final padding = 8.0;
                        final fixedHeight =
                            3 * itemHeight + 2 * spacing + 2 * padding;

                        return SizedBox(
                          height: fixedHeight,
                          child: GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: itemWidth / itemHeight,
                              crossAxisSpacing: spacing,
                              mainAxisSpacing: spacing,
                            ),
                            itemCount: ingredients.length,
                            itemBuilder: (context, index) {
                              final ingredient = ingredients[index];
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
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.outlineVariant,
                                      width: 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: colorScheme.primary
                                                  .withAlpha(77),
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
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: isSelected
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface,
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
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedIngredients.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withAlpha(77),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${AppStrings.getSelectedIngredients(locale)}: ${_selectedIngredients.map((e) => e.name).join(', ')}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: colorScheme.primary,
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
                    color: colorScheme.onSurface.withAlpha(153),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getRecipeGeneration(locale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedIngredients.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.error.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.error, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: colorScheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.getNoIngredientsForRecipe(locale),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.error,
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
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isGeneratingRecipe)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: colorScheme.onPrimary),
                      ),
                      label: Text(
                        AppStrings.getGeneratingRecipe(locale),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: AiAnalysisButton(
                      onAnalysisRequested: () {
                        _generateRecipe(locale);
                      },
                      buttonText: AppStrings.getAiRecipeGenerationButton(
                        locale,
                      ),
                      icon: Icons.auto_awesome,
                      dialogTitle: AppStrings.getAiRecipeDialogTitle(locale),
                      dialogMessage:
                          AppStrings.getAiRecipeDialogMessage(locale),
                      dialogDescription:
                          AppStrings.getAiRecipeDialogDescription(locale),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.getGeneratedRecipe(locale),
                  style: AppTextStyles.headline4.copyWith(
                    color: colorScheme.onSurface,
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
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _generatedRecipe!['description'] ??
                AppStrings.getRecipeDescription(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withAlpha(153),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            color: colorScheme.onSurface,
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
                color: colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        Text(
          AppStrings.getCookingInstructions(locale),
          style: AppTextStyles.headline4.copyWith(
            color: colorScheme.onSurface,
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
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onPrimary,
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
                      color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_shopping_cart, color: colorScheme.secondary),
              const SizedBox(width: 12),
              Text(
                AppStrings.getAdditionalIngredientsNeeded(locale),
                style: AppTextStyles.headline4.copyWith(
                  color: colorScheme.secondary,
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
                  Icon(Icons.add_circle_outline, color: colorScheme.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ingredient,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _addIngredient(ingredient),
                    child: Text(
                      AppStrings.getAddIngredient(locale),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.primary,
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
                foregroundColor: colorScheme.secondary,
                side: BorderSide(color: colorScheme.secondary),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.getCreateDifferentStyleRecipes(locale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.getCreateDifferentStyleRecipesDescription(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _isGeneratingRecipe
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.restaurant),
                        label: Text(
                          AppStrings.getKoreanStyle(locale),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: AiAnalysisButton(
                          onAnalysisRequested: () {
                            _generateDifferentStyleRecipe(locale);
                          },
                          buttonText: AppStrings.getKoreanStyle(locale),
                          icon: Icons.restaurant,
                          isOutlined: true,
                          dialogTitle:
                              AppStrings.getAiRecipeDialogTitle(locale),
                          dialogMessage:
                              AppStrings.getAiRecipeDialogMessage(locale),
                          dialogDescription:
                              AppStrings.getKoreanStyleRecipeDialogDescription(
                                  locale),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isGeneratingRecipe
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(
                          AppStrings.getFusionStyle(locale),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: AiAnalysisButton(
                          onAnalysisRequested: () {
                            _generateDifferentStyleRecipe(locale);
                          },
                          buttonText: AppStrings.getFusionStyle(locale),
                          icon: Icons.auto_awesome,
                          isOutlined: true,
                          dialogTitle:
                              AppStrings.getAiRecipeDialogTitle(locale),
                          dialogMessage:
                              AppStrings.getAiRecipeDialogMessage(locale),
                          dialogDescription:
                              AppStrings.getFusionStyleRecipeDialogDescription(
                                  locale),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bookmark, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                AppStrings.getViewSavedAiRecipes(locale),
                style: AppTextStyles.headline4.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.getViewSavedAiRecipesDescription(locale),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (mounted) {
                  widget.onTabChanged?.call(1);
                }
              },
              icon: const Icon(Icons.list_alt),
              label: Text(
                AppStrings.getAiRecipeList(locale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withAlpha(153),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateRecipe(AppLocale locale) async {
    setState(() {
      _isGeneratingRecipe = true;
      _generatedRecipe = null;
      _missingIngredients = [];
    });

    try {
      final ingredientsToUse = _selectedIngredients;
      final result = await _aiRecipeService.generateRecipeFromIngredients(
        ingredientsToUse,
        targetLocale: locale,
      );

      if (mounted) {
        setState(() {
          _generatedRecipe = result;
          _isGeneratingRecipe = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingRecipe = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _generateDifferentStyleRecipe(AppLocale locale) async {
    setState(() {
      _isGeneratingRecipe = true;
    });

    try {
      final result = await _aiRecipeService.generateDifferentStyleRecipe(
        _selectedIngredients,
        targetLocale: locale,
      );

      if (mounted) {
        setState(() {
          _generatedRecipe = result;
          _isGeneratingRecipe = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingRecipe = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _addIngredient(String name) {
    RouterHelper.goToIngredientAddWithName(context, name);
  }

  void _addAllMissingIngredients() {
    RouterHelper.goToIngredientBulkAddWithData(
      context,
      _missingIngredients.map((e) => {'name': e}).toList(),
    );
  }

  void _showInfoDialog(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getAiRecipeGeneration(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          '보유한 식재료를 선택하여 AI가 추천하는 맞춤형 레시피를 생성할 수 있습니다.',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getConfirm(locale)),
          ),
        ],
      ),
    );
  }
}
