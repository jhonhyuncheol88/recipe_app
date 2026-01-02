import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../model/encyclopedia_recipe.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../router/app_router.dart';
import '../../../router/router_helper.dart';
import '../../../service/gemini_service.dart';

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
  Map<String, String> _translatedIngredientNames = {};
  Map<String, String> _translatedSauceNames = {};
  Map<String, String> _translatedUnits = {}; // 단위 번역 맵
  String? _translatedCookingMethod;
  bool _isTranslating = false;
  final GeminiService _geminiService = GeminiService();

  @override
  void initState() {
    super.initState();
    // 메인 페이지에서 전달받은 번역 정보가 있으면 초기화
    if (widget.translationData != null) {
      final isTranslated = widget.translationData!['isTranslated'] as bool? ?? false;
      final translatedRecipeName = widget.translationData!['translatedRecipeName'] as String?;
      
      // 메인 페이지에서 번역 상태가 true이면 자동으로 번역 수행
      if (isTranslated) {
        _isTranslated = true;
        if (translatedRecipeName != null) {
          _translatedRecipeName = translatedRecipeName;
        }
        
        // 재료, 양념, 조리 방법 자동 번역
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
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              _isTranslated && _translatedRecipeName != null
                  ? _translatedRecipeName!
                  : widget.recipe.menuName,
              style: AppTextStyles.headline4
                  .copyWith(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              // 한국어가 아닐 때만 번역 버튼 표시
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
                              color: AppColors.accent,
                            ),
                          )
                        : Icon(
                            _isTranslated ? Icons.visibility : Icons.translate,
                            color: _isTranslating
                                ? AppColors.textSecondary
                                : AppColors.accent,
                          ),
                    label: Text(
                      _isTranslating
                          ? AppStrings.getTranslating(currentLocale)
                          : (_isTranslated
                              ? AppStrings.getShowOriginal(currentLocale)
                              : AppStrings.getTranslate(currentLocale)),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _isTranslating
                            ? AppColors.textSecondary
                            : AppColors.accent,
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
                _buildRecipeInfo(currentLocale),
                const SizedBox(height: 24),
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

  /// 번역하기/원본 보기 토글 핸들러
  Future<void> _handleTranslateToggle(AppLocale currentLocale) async {
    if (_isTranslated) {
      // 원본 보기
      setState(() {
        _isTranslated = false;
      });
    } else {
      // 번역하기
      await _translateRecipe(currentLocale);
    }
  }

  /// 레시피 이름, 재료, 양념, 조리 방법 번역
  Future<void> _translateRecipe(AppLocale currentLocale) async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      // 번역할 이름들 수집
      final namesToTranslate = <String>[];
      
      // 레시피 이름
      if (_translatedRecipeName == null) {
        namesToTranslate.add(widget.recipe.menuName);
      }
      
      // 재료 이름
      for (final ingredient in widget.recipe.ingredients) {
        if (!_translatedIngredientNames.containsKey(ingredient.name)) {
          namesToTranslate.add(ingredient.name);
        }
      }
      
      // 양념 이름
      for (final sauce in widget.recipe.sauces) {
        if (!_translatedSauceNames.containsKey(sauce.name)) {
          namesToTranslate.add(sauce.name);
        }
      }

      // 이름 번역 수행
      if (namesToTranslate.isNotEmpty) {
        final translations = await _geminiService.translateRecipeNames(
          namesToTranslate,
          targetLocale: currentLocale,
        );

        if (mounted) {
          setState(() {
            // 레시피 이름 번역
            if (translations.containsKey(widget.recipe.menuName) &&
                _translatedRecipeName == null) {
              _translatedRecipeName = translations[widget.recipe.menuName]!;
            }
            
            // 재료 이름 번역
            for (final ingredient in widget.recipe.ingredients) {
              if (translations.containsKey(ingredient.name)) {
                _translatedIngredientNames[ingredient.name] =
                    translations[ingredient.name]!;
              }
            }
            
            // 양념 이름 번역
            for (final sauce in widget.recipe.sauces) {
              if (translations.containsKey(sauce.name)) {
                _translatedSauceNames[sauce.name] =
                    translations[sauce.name]!;
              }
            }
          });
        }
      }

      // 단위 번역 수행
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
          final unitTranslations = await _geminiService.translateUnits(
            unitsToTranslate,
            targetLocale: currentLocale,
          );

          if (mounted) {
            setState(() {
              _translatedUnits.addAll(unitTranslations);
            });
          }
        } catch (e) {
          // 단위 번역 실패는 무시 (이름 번역은 성공했을 수 있음)
          print('단위 번역 실패: $e');
        }
      }

      // 조리 방법 번역
      if (widget.recipe.cookingMethod.isNotEmpty &&
          _translatedCookingMethod == null) {
        try {
          final translatedMethod = await _geminiService.translateText(
            widget.recipe.cookingMethod,
            targetLocale: currentLocale,
          );

          if (mounted) {
            setState(() {
              _translatedCookingMethod = translatedMethod;
            });
          }
        } catch (e) {
          // 조리 방법 번역 실패는 무시 (다른 번역은 성공했을 수 있음)
          print('조리 방법 번역 실패: $e');
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

        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '번역 중 오류가 발생했습니다: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildRecipeInfo(AppLocale currentLocale) {
    // 페이지 번호는 표시하지 않음
    return const SizedBox.shrink();
  }


  Widget _buildAddAllButton(BuildContext context, AppLocale currentLocale) {
    final hasIngredients = widget.recipe.ingredients.isNotEmpty;
    final hasSauces = widget.recipe.sauces.isNotEmpty;
    
    if (!hasIngredients && !hasSauces) {
      return const SizedBox.shrink();
    }

    return Card(
      color: AppColors.primaryLight.withOpacity(0.1),
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
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.buttonText,
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

  Widget _buildIngredientsSection(BuildContext context, AppLocale currentLocale) {
    return Card(
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
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (widget.recipe.ingredients.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _addIngredientsToApp(context, currentLocale),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: Text(
                        AppStrings.getAddIngredients(currentLocale),
                        style: AppTextStyles.buttonSmall,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.buttonText,
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
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...widget.recipe.ingredients.asMap().entries.map((entry) {
                final index = entry.key;
                final ingredient = entry.value;
                // 번역된 이름이 있으면 사용, 없으면 원본 이름 사용
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
                          color: AppColors.accent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _isTranslated && _translatedUnits.containsKey(ingredient.normalizedUnit)
                            ? '${ingredient.amount}${_translatedUnits[ingredient.normalizedUnit]!}'
                            : '${ingredient.amount}${ingredient.unit}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppColors.accent,
                        ),
                        onPressed: () {
                          // 번역된 이름이 있으면 번역된 이름 사용, 없으면 원본 이름 사용
                          final name = _isTranslated &&
                                  _translatedIngredientNames
                                      .containsKey(ingredient.name)
                              ? _translatedIngredientNames[ingredient.name]!
                              : ingredient.name;
                          
                          // 단위도 번역된 것이 있으면 사용
                          final unit = _isTranslated && _translatedUnits.containsKey(ingredient.normalizedUnit)
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
    return Card(
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
                        color: AppColors.textPrimary,
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
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.buttonText,
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
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...widget.recipe.sauces.asMap().entries.map((entry) {
                final index = entry.key;
                final sauce = entry.value;
                // 번역된 이름이 있으면 사용, 없으면 원본 이름 사용
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
                          color: AppColors.accent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _isTranslated && _translatedUnits.containsKey(sauce.normalizedUnit)
                            ? '${sauce.amount}${_translatedUnits[sauce.normalizedUnit]!}'
                            : '${sauce.amount}${sauce.unit}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppColors.accent,
                        ),
                        onPressed: () {
                          // 번역된 이름이 있으면 번역된 이름 사용, 없으면 원본 이름 사용
                          final name = _isTranslated &&
                                  _translatedSauceNames.containsKey(sauce.name)
                              ? _translatedSauceNames[sauce.name]!
                              : sauce.name;
                          
                          // 단위도 번역된 것이 있으면 사용
                          final unit = _isTranslated && _translatedUnits.containsKey(sauce.normalizedUnit)
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
    // 번역된 조리 방법이 있으면 사용, 없으면 원본 사용
    final cookingMethodText = _isTranslated && _translatedCookingMethod != null
        ? _translatedCookingMethod!
        : widget.recipe.cookingMethod;
    
    // 조리방법을 줄바꿈으로 구분하여 단계별로 나눔
    final steps = cookingMethodText
        .split('\n')
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getCookingMethod(currentLocale),
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (steps.isEmpty)
              Text(
                AppStrings.getNoCookingMethod(currentLocale),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
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
    // 번호와 점(.) 제거 (이미 있으면)
    String cleanedText = stepText.trim();
    if (cleanedText.startsWith('$stepNumber.') ||
        cleanedText.startsWith('${stepNumber}.')) {
      cleanedText = cleanedText
          .substring(cleanedText.indexOf('.') + 1)
          .trim();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.5),
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
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accent,
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
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addIngredientsToApp(BuildContext context, AppLocale currentLocale) {
    // 번역된 이름이 있으면 번역된 이름 사용, 없으면 원본 이름 사용
    final ingredients = widget.recipe.ingredients.map((ingredient) {
      final name = _isTranslated &&
              _translatedIngredientNames.containsKey(ingredient.name)
          ? _translatedIngredientNames[ingredient.name]!
          : ingredient.name;
      
      // 단위도 번역된 것이 있으면 사용
      final unit = _isTranslated && _translatedUnits.containsKey(ingredient.normalizedUnit)
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
    // 번역된 이름이 있으면 번역된 이름 사용, 없으면 원본 이름 사용
    final sauces = widget.recipe.sauces.map((sauce) {
      final name = _isTranslated &&
              _translatedSauceNames.containsKey(sauce.name)
          ? _translatedSauceNames[sauce.name]!
          : sauce.name;
      
      // 단위도 번역된 것이 있으면 사용
      final unit = _isTranslated && _translatedUnits.containsKey(sauce.normalizedUnit)
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
    // 재료와 양념을 모두 합쳐서 추가 (번역된 이름 사용)
    final allItems = [
      ...widget.recipe.ingredients.map((ingredient) {
        final name = _isTranslated &&
                _translatedIngredientNames.containsKey(ingredient.name)
            ? _translatedIngredientNames[ingredient.name]!
            : ingredient.name;
        
        // 단위도 번역된 것이 있으면 사용
        final unit = _isTranslated && _translatedUnits.containsKey(ingredient.normalizedUnit)
            ? _translatedUnits[ingredient.normalizedUnit]!
            : ingredient.normalizedUnit;
        
        return {
          'name': name.trim(),
          'amount': ingredient.amount,
          'unit': unit,
        };
      }),
      ...widget.recipe.sauces.map((sauce) {
        final name = _isTranslated &&
                _translatedSauceNames.containsKey(sauce.name)
            ? _translatedSauceNames[sauce.name]!
            : sauce.name;
        
        // 단위도 번역된 것이 있으면 사용
        final unit = _isTranslated && _translatedUnits.containsKey(sauce.normalizedUnit)
            ? _translatedUnits[sauce.normalizedUnit]!
            : sauce.normalizedUnit;
        
        return {
          'name': name.trim(),
          'amount': sauce.amount,
          'unit': unit,
        };
      }),
    ];

    if (allItems.isEmpty) {
      return;
    }

    context.push(
      AppRouter.ingredientBulkAdd,
      extra: {
        'prefilledIngredients': allItems,
      },
    );
  }

  void _addIndividualIngredient(
    BuildContext context,
    String ingredientName, {
    String? amount,
    String? unit,
  }) {
    RouterHelper.goToIngredientAddWithName(
      context,
      ingredientName,
      amount: amount,
      unit: unit,
    );
  }
}

