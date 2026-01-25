import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../model/encyclopedia_recipe.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../router/app_router.dart';
import '../../../router/router_helper.dart';
import '../../../service/ai_analysis_service.dart';

/// 백과사전 레시피 상세 페이지
class EncyclopediaRecipeDetailPage extends StatefulWidget {
  final EncyclopediaRecipe recipe;
  final Map<String, dynamic>? translationData;

  const EncyclopediaRecipeDetailPage({
    super.key,
    required this.recipe,
    this.translationData,
  });

  @override
  State<EncyclopediaRecipeDetailPage> createState() =>
      _EncyclopediaRecipeDetailPageState();
}

class _EncyclopediaRecipeDetailPageState
    extends State<EncyclopediaRecipeDetailPage> {
  bool _isTranslated = false;
  String? _translatedRecipeName;
  final Map<String, String> _translatedIngredientNames = {};
  final Map<String, String> _translatedSauceNames = {};
  final Map<String, String> _translatedUnits = {};
  String? _translatedCookingMethod;
  bool _isTranslating = false;
  final AiAnalysisService _aiAnalysisService = AiAnalysisService();

  @override
  void initState() {
    super.initState();
    if (widget.translationData != null) {
      final isTranslated =
          widget.translationData!['isTranslated'] as bool? ?? false;
      final translatedRecipeName =
          widget.translationData!['translatedRecipeName'] as String?;

      if (isTranslated) {
        _isTranslated = true;
        if (translatedRecipeName != null) {
          _translatedRecipeName = translatedRecipeName;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentLocale = context.read<LocaleCubit>().state;
          if (currentLocale != AppLocale.korea) {
            _translateRecipe(currentLocale);
          }
        });
      }
    }
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
              _isTranslated && _translatedRecipeName != null
                  ? _translatedRecipeName!
                  : widget.recipe.menuName,
              style: AppTextStyles.headline4
                  .copyWith(color: colorScheme.onSurface),
            ),
            backgroundColor: colorScheme.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
            actions: [
              if (currentLocale != AppLocale.korea)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton.icon(
                    onPressed: _isTranslating
                        ? null
                        : () => _handleTranslateToggle(currentLocale),
                    icon: _isTranslating
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        : Icon(
                            _isTranslated ? Icons.visibility : Icons.translate,
                            color: _isTranslating
                                ? colorScheme.onSurface.withAlpha(102)
                                : colorScheme.primary,
                          ),
                    label: Text(
                      _isTranslating
                          ? AppStrings.getTranslating(currentLocale)
                          : (_isTranslated
                              ? AppStrings.getShowOriginal(currentLocale)
                              : AppStrings.getTranslate(currentLocale)),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _isTranslating
                            ? colorScheme.onSurface.withAlpha(102)
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddAllButton(context, currentLocale),
                const SizedBox(height: 24),
                _buildIngredientsSection(context, currentLocale),
                const SizedBox(height: 24),
                _buildSaucesSection(context, currentLocale),
                const SizedBox(height: 24),
                _buildCookingMethodSection(currentLocale),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleTranslateToggle(AppLocale currentLocale) async {
    if (_isTranslated) {
      setState(() {
        _isTranslated = false;
      });
    } else {
      await _translateRecipe(currentLocale);
    }
  }

  Future<void> _translateRecipe(AppLocale currentLocale) async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final namesToTranslate = <String>[];

      if (_translatedRecipeName == null) {
        namesToTranslate.add(widget.recipe.menuName);
      }

      for (final ingredient in widget.recipe.ingredients) {
        if (!_translatedIngredientNames.containsKey(ingredient.name)) {
          namesToTranslate.add(ingredient.name);
        }
      }

      for (final sauce in widget.recipe.sauces) {
        if (!_translatedSauceNames.containsKey(sauce.name)) {
          namesToTranslate.add(sauce.name);
        }
      }

      if (namesToTranslate.isNotEmpty) {
        final translations = await _aiAnalysisService.translateRecipeNames(
          namesToTranslate,
          targetLocale: currentLocale,
        );

        if (mounted) {
          setState(() {
            if (translations.containsKey(widget.recipe.menuName) &&
                _translatedRecipeName == null) {
              _translatedRecipeName = translations[widget.recipe.menuName]!;
            }

            for (final ingredient in widget.recipe.ingredients) {
              if (translations.containsKey(ingredient.name)) {
                _translatedIngredientNames[ingredient.name] =
                    translations[ingredient.name]!;
              }
            }

            for (final sauce in widget.recipe.sauces) {
              if (translations.containsKey(sauce.name)) {
                _translatedSauceNames[sauce.name] = translations[sauce.name]!;
              }
            }
          });
        }
      }

      final unitsToTranslate = <String>[];
      for (final ingredient in widget.recipe.ingredients) {
        final unit = ingredient.normalizedUnit;
        if (unit.isNotEmpty && !_translatedUnits.containsKey(unit)) {
          unitsToTranslate.add(unit);
        }
      }
      for (final sauce in widget.recipe.sauces) {
        final unit = sauce.normalizedUnit;
        if (unit.isNotEmpty && !_translatedUnits.containsKey(unit)) {
          unitsToTranslate.add(unit);
        }
      }

      if (unitsToTranslate.isNotEmpty) {
        try {
          final unitTranslations = await _aiAnalysisService.translateUnits(
            unitsToTranslate,
            targetLocale: currentLocale,
          );

          if (mounted) {
            setState(() {
              _translatedUnits.addAll(unitTranslations);
            });
          }
        } catch (e) {
          debugPrint('단위 번역 실패: $e');
        }
      }

      if (widget.recipe.cookingMethod.isNotEmpty &&
          _translatedCookingMethod == null) {
        try {
          final translatedMethod = await _aiAnalysisService.translateText(
            widget.recipe.cookingMethod,
            targetLocale: currentLocale,
          );

          if (mounted) {
            setState(() {
              _translatedCookingMethod = translatedMethod;
            });
          }
        } catch (e) {
          debugPrint('조리 방법 번역 실패: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isTranslated = true;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });

        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '번역 중 오류가 발생했습니다: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildAddAllButton(BuildContext context, AppLocale currentLocale) {
    final hasIngredients = widget.recipe.ingredients.isNotEmpty;
    final hasSauces = widget.recipe.sauces.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    if (!hasIngredients && !hasSauces) {
      return const SizedBox.shrink();
    }

    return Card(
      color: colorScheme.primary.withAlpha(13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withAlpha(26)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _addAllToApp(context, currentLocale),
            icon: const Icon(Icons.add_circle, size: 24),
            label: Text(
              AppStrings.getAddAll(currentLocale),
              style: AppTextStyles.buttonMedium.copyWith(
                fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildIngredientsSection(
      BuildContext context, AppLocale currentLocale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.getIngredientsList(currentLocale),
                      style: AppTextStyles.headline4.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (widget.recipe.ingredients.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _addIngredientsToApp(context, currentLocale),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: Text(
                        AppStrings.getAddIngredients(currentLocale),
                        style: AppTextStyles.buttonSmall,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.recipe.ingredients.isEmpty)
              Text(
                AppStrings.getNoIngredients(currentLocale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withAlpha(153),
                ),
              )
            else
              ...widget.recipe.ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                final displayName = _isTranslated &&
                        _translatedIngredientNames.containsKey(ingredient.name)
                    ? _translatedIngredientNames[ingredient.name]!
                    : ingredient.name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.caption.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          displayName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        _isTranslated &&
                                _translatedUnits
                                    .containsKey(ingredient.normalizedUnit)
                            ? '${ingredient.amount}${_translatedUnits[ingredient.normalizedUnit]!}'
                            : '${ingredient.amount}${ingredient.unit}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          final name = _isTranslated &&
                                  _translatedIngredientNames
                                      .containsKey(ingredient.name)
                              ? _translatedIngredientNames[ingredient.name]!
                              : ingredient.name;

                          final unit = _isTranslated &&
                                  _translatedUnits
                                      .containsKey(ingredient.normalizedUnit)
                              ? _translatedUnits[ingredient.normalizedUnit]!
                              : ingredient.normalizedUnit;

                          _addIndividualIngredient(
                            context,
                            name,
                            amount: ingredient.amount,
                            unit: unit,
                          );
                        },
                        tooltip: AppStrings.getAddIndividual(currentLocale),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSaucesSection(BuildContext context, AppLocale currentLocale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.getSaucesList(currentLocale),
                      style: AppTextStyles.headline4.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (widget.recipe.sauces.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _addSaucesToApp(context, currentLocale),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: Text(
                        AppStrings.getAddSauces(currentLocale),
                        style: AppTextStyles.buttonSmall,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.recipe.sauces.isEmpty)
              Text(
                AppStrings.getNoSauces(currentLocale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withAlpha(153),
                ),
              )
            else
              ...widget.recipe.sauces.asMap().entries.map((entry) {
                final index = entry.key;
                final sauce = entry.value;
                final displayName = _isTranslated &&
                        _translatedSauceNames.containsKey(sauce.name)
                    ? _translatedSauceNames[sauce.name]!
                    : sauce.name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.caption.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          displayName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        _isTranslated &&
                                _translatedUnits
                                    .containsKey(sauce.normalizedUnit)
                            ? '${sauce.amount}${_translatedUnits[sauce.normalizedUnit]!}'
                            : '${sauce.amount}${sauce.unit}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        onPressed: () {
                          final name = _isTranslated &&
                                  _translatedSauceNames.containsKey(sauce.name)
                              ? _translatedSauceNames[sauce.name]!
                              : sauce.name;

                          final unit = _isTranslated &&
                                  _translatedUnits
                                      .containsKey(sauce.normalizedUnit)
                              ? _translatedUnits[sauce.normalizedUnit]!
                              : sauce.normalizedUnit;

                          _addIndividualIngredient(
                            context,
                            name,
                            amount: sauce.amount,
                            unit: unit,
                          );
                        },
                        tooltip: AppStrings.getAddIndividual(currentLocale),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCookingMethodSection(AppLocale currentLocale) {
    final colorScheme = Theme.of(context).colorScheme;
    final cookingMethodText = _isTranslated && _translatedCookingMethod != null
        ? _translatedCookingMethod!
        : widget.recipe.cookingMethod;

    final steps = cookingMethodText
        .split('\n')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    return Card(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getCookingMethod(currentLocale),
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (steps.isEmpty)
              Text(
                AppStrings.getNoCookingMethod(currentLocale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withAlpha(153),
                ),
              )
            else
              ...steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCookingStep(
                    index + 1,
                    step,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCookingStep(int stepNumber, String stepText) {
    final colorScheme = Theme.of(context).colorScheme;
    String cleanedText = stepText.trim();
    if (cleanedText.startsWith('$stepNumber.') ||
        cleanedText.startsWith('${stepNumber}.')) {
      cleanedText = cleanedText.substring(cleanedText.indexOf('.') + 1).trim();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cleanedText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addIngredientsToApp(BuildContext context, AppLocale currentLocale) {
    final ingredients = widget.recipe.ingredients.map((ingredient) {
      final name = _isTranslated &&
              _translatedIngredientNames.containsKey(ingredient.name)
          ? _translatedIngredientNames[ingredient.name]!
          : ingredient.name;

      final unit = _isTranslated &&
              _translatedUnits.containsKey(ingredient.normalizedUnit)
          ? _translatedUnits[ingredient.normalizedUnit]!
          : ingredient.normalizedUnit;

      return {
        'name': name.trim(),
        'amount': ingredient.amount,
        'unit': unit,
      };
    }).toList();

    context.push(
      AppRouter.ingredientBulkAdd,
      extra: {
        'prefilledIngredients': ingredients,
      },
    );
  }

  void _addSaucesToApp(BuildContext context, AppLocale currentLocale) {
    final sauces = widget.recipe.sauces.map((sauce) {
      final name =
          _isTranslated && _translatedSauceNames.containsKey(sauce.name)
              ? _translatedSauceNames[sauce.name]!
              : sauce.name;

      final unit =
          _isTranslated && _translatedUnits.containsKey(sauce.normalizedUnit)
              ? _translatedUnits[sauce.normalizedUnit]!
              : sauce.normalizedUnit;

      return {
        'name': name.trim(),
        'amount': sauce.amount,
        'unit': unit,
      };
    }).toList();

    context.push(
      AppRouter.ingredientBulkAdd,
      extra: {
        'prefilledIngredients': sauces,
      },
    );
  }

  void _addAllToApp(BuildContext context, AppLocale currentLocale) {
    final allItems = [
      ...widget.recipe.ingredients.map((ingredient) {
        final name = _isTranslated &&
                _translatedIngredientNames.containsKey(ingredient.name)
            ? _translatedIngredientNames[ingredient.name]!
            : ingredient.name;

        final unit = _isTranslated &&
                _translatedUnits.containsKey(ingredient.normalizedUnit)
            ? _translatedUnits[ingredient.normalizedUnit]!
            : ingredient.normalizedUnit;

        return {
          'name': name.trim(),
          'amount': ingredient.amount,
          'unit': unit,
        };
      }),
      ...widget.recipe.sauces.map((sauce) {
        final name =
            _isTranslated && _translatedSauceNames.containsKey(sauce.name)
                ? _translatedSauceNames[sauce.name]!
                : sauce.name;

        final unit =
            _isTranslated && _translatedUnits.containsKey(sauce.normalizedUnit)
                ? _translatedUnits[sauce.normalizedUnit]!
                : sauce.normalizedUnit;

        return {
          'name': name.trim(),
          'amount': sauce.amount,
          'unit': unit,
        };
      }),
    ];

    context.push(
      AppRouter.ingredientBulkAdd,
      extra: {
        'prefilledIngredients': allItems,
      },
    );
  }

  void _addIndividualIngredient(BuildContext context, String name,
      {required String amount, required String unit}) {
    RouterHelper.goToIngredientAddWithName(
      context,
      name,
      amount: amount,
      unit: unit,
    );
  }
}
