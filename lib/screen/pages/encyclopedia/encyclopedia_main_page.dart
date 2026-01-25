import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../controller/encyclopedia/encyclopedia_cubit.dart';
import '../../../controller/encyclopedia/encyclopedia_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../model/encyclopedia_recipe.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../service/admob_forward.dart';
import '../../../service/ai_analysis_service.dart';

/// 백과사전 메인 페이지
class EncyclopediaMainPage extends StatefulWidget {
  const EncyclopediaMainPage({super.key});

  @override
  State<EncyclopediaMainPage> createState() => _EncyclopediaMainPageState();
}

class _EncyclopediaMainPageState extends State<EncyclopediaMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _displayCount = 10;
  bool _isTranslated = false;
  final Map<String, String> _translatedNames = {};
  bool _isTranslating = false;
  final AiAnalysisService _aiAnalysisService = AiAnalysisService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EncyclopediaCubit>().loadRecipes();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query;
        _displayCount = 10;
        _isTranslated = false;
        _translatedNames.clear();
      });
      context.read<EncyclopediaCubit>().searchRecipes(query);
    }
  }

  Future<void> _handleLoadMore(AppLocale currentLocale) async {
    final adWatched = await AdMobForwardService.instance.showInterstitialAd();

    if (adWatched && mounted) {
      setState(() {
        _displayCount += 10;
      });

      if (_isTranslated && _translatedNames.isNotEmpty) {
        _translateDisplayedRecipes(currentLocale);
      }
    }
  }

  Future<void> _handleTranslateToggle(AppLocale currentLocale) async {
    if (_isTranslated) {
      setState(() {
        _isTranslated = false;
      });
    } else {
      await _translateDisplayedRecipes(currentLocale);
    }
  }

  Future<void> _translateDisplayedRecipes(AppLocale currentLocale) async {
    if (_isTranslating) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final recipes = context.read<EncyclopediaCubit>().state;
      List<EncyclopediaRecipe> displayedRecipes = [];

      if (recipes is EncyclopediaLoaded) {
        displayedRecipes = recipes.recipes.take(_displayCount).toList();
      } else if (recipes is EncyclopediaSearchResult) {
        displayedRecipes = recipes.recipes.take(_displayCount).toList();
      }

      if (displayedRecipes.isEmpty) {
        setState(() {
          _isTranslating = false;
        });
        return;
      }

      final namesToTranslate = <String>[];
      for (final recipe in displayedRecipes) {
        if (!_translatedNames.containsKey(recipe.menuName)) {
          namesToTranslate.add(recipe.menuName);
        }
      }

      if (namesToTranslate.isNotEmpty) {
        final translations = await _aiAnalysisService.translateRecipeNames(
          namesToTranslate,
          targetLocale: currentLocale,
        );

        if (mounted) {
          setState(() {
            _translatedNames.addAll(translations);
            _isTranslated = true;
            _isTranslating = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isTranslated = true;
            _isTranslating = false;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppStrings.getEncyclopedia(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
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
                            ? colorScheme.onSurface.withValues(alpha: 0.4)
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
                        ? colorScheme.onSurface.withValues(alpha: 0.4)
                        : colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(currentLocale),
          Expanded(
            child: BlocBuilder<EncyclopediaCubit, EncyclopediaState>(
              builder: (context, state) {
                if (state is EncyclopediaLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                if (state is EncyclopediaError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<EncyclopediaCubit>().loadRecipes();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                          child: Text(AppStrings.getRetry(currentLocale)),
                        ),
                      ],
                    ),
                  );
                }

                if (state is EncyclopediaEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.getNoRecipes(currentLocale),
                          style: AppTextStyles.headline4.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List<EncyclopediaRecipe> recipes = [];
                if (state is EncyclopediaLoaded) {
                  recipes = state.recipes;
                } else if (state is EncyclopediaSearchResult) {
                  recipes = state.recipes;
                }

                if (recipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.getNoRecipes(currentLocale),
                          style: AppTextStyles.headline4.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildRecipeList(recipes, currentLocale);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocale currentLocale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.getSearchRecipeHint(currentLocale),
          prefixIcon: Icon(Icons.search,
              color: colorScheme.onSurface.withValues(alpha: 0.4)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear,
                      color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
      ),
    );
  }

  Widget _buildRecipeList(
    List<EncyclopediaRecipe> recipes,
    AppLocale currentLocale,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayedRecipes = recipes.take(_displayCount).toList();
    final hasMore = recipes.length > _displayCount;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayedRecipes.length,
            itemBuilder: (context, index) {
              return _buildRecipeCard(displayedRecipes[index], currentLocale);
            },
          ),
        ),
        if (hasMore)
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _handleLoadMore(currentLocale),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.getLoadMore(currentLocale),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_downward,
                    color: colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecipeCard(EncyclopediaRecipe recipe, AppLocale currentLocale) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName =
        _isTranslated && _translatedNames.containsKey(recipe.menuName)
            ? _translatedNames[recipe.menuName]!
            : recipe.menuName;

    return Card(
      color: colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          final translationData = _isTranslated
              ? {
                  'translatedRecipeName': _translatedNames[recipe.menuName],
                  'isTranslated': true,
                }
              : {
                  'isTranslated': false,
                };

          context.push(
            '/encyclopedia/recipe/${recipe.number}',
            extra: {
              'recipe': recipe,
              'translationData': translationData,
            },
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: AppTextStyles.headline4.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppStrings.getIngredientsList(currentLocale)}: ${recipe.ingredients.length}개 | ${AppStrings.getSaucesList(currentLocale)}: ${recipe.sauces.length}개',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
