import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/recipe/recipe_state.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/recipe.dart';
import '../../../model/sauce.dart';
import '../../../router/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import '../../../util/recipe_margin.dart';
import '../../widget/segment_control.dart';

enum _Tab { recipe, sauce }

/// 레시피 + 소스 통합 메인 페이지.
///
/// 상단 sticky 헤더(흰색): 제목 "레시피" + 합계 부제 + + 등록 pill 버튼,
/// 그 아래 세그먼트 컨트롤로 레시피/소스 리스트 토글.
class RecipeMainPage extends StatefulWidget {
  const RecipeMainPage({super.key});

  @override
  State<RecipeMainPage> createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage> {
  _Tab _tab = _Tab.recipe;

  @override
  void initState() {
    super.initState();
    context.read<RecipeCubit>().loadRecipes();
    context.read<SauceCubit>().loadSauces();
  }

  List<Recipe> _recipesOf(RecipeState state) {
    if (state is RecipeLoaded) return state.recipes;
    if (state is RecipeAdded) return state.recipes;
    if (state is RecipeUpdated) return state.recipes;
    if (state is RecipeDeleted) return state.recipes;
    if (state is RecipeFilteredByTag) return state.recipes;
    if (state is RecipeFilteredByTags) return state.recipes;
    if (state is RecipeSearchResult) return state.recipes;
    if (state is RecipeCostRecalculated) return state.recipes;
    return const [];
  }

  List<Sauce> _saucesOf(SauceState state) {
    if (state is SauceLoaded) return state.sauces;
    if (state is SauceAdded) return state.sauces;
    if (state is SauceUpdatedState) return state.sauces;
    if (state is SauceDeleted) return state.sauces;
    return const [];
  }

  void _openCreate(AppLocale locale) {
    if (_tab == _Tab.recipe) {
      context.push(AppRouter.recipeCreate);
    } else {
      context.push(AppRouter.sauceCreate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;

    return Scaffold(
      backgroundColor: tokens.bgElev2,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, recipeState) {
            return BlocBuilder<SauceCubit, SauceState>(
              builder: (context, sauceState) {
                final recipes = _recipesOf(recipeState);
                final sauces = _saucesOf(sauceState);
                final recipeLoading = recipeState is RecipeLoading;
                final sauceLoading = sauceState is SauceLoading;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StickyHeader(
                      recipeCount: recipes.length,
                      sauceCount: sauces.length,
                      tab: _tab,
                      locale: locale,
                      onTabChanged: (t) => setState(() => _tab = t),
                      onAdd: () => _openCreate(locale),
                    ),
                    Expanded(
                      child: _tab == _Tab.recipe
                          ? _RecipeList(
                              recipes: recipes,
                              isLoading: recipeLoading && recipes.isEmpty,
                              locale: locale,
                              formatStyle: formatStyle,
                              onTap: (r) => context.push(
                                AppRouter.recipeDetail,
                                extra: r,
                              ),
                              onAdd: () =>
                                  context.push(AppRouter.recipeCreate),
                            )
                          : _SauceList(
                              sauces: sauces,
                              isLoading: sauceLoading && sauces.isEmpty,
                              locale: locale,
                              formatStyle: formatStyle,
                              onTap: (s) => context.push(
                                AppRouter.sauceEdit,
                                extra: s,
                              ),
                              onAdd: () =>
                                  context.push(AppRouter.sauceCreate),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StickyHeader extends StatelessWidget {
  final int recipeCount;
  final int sauceCount;
  final _Tab tab;
  final AppLocale locale;
  final ValueChanged<_Tab> onTabChanged;
  final VoidCallback onAdd;

  const _StickyHeader({
    required this.recipeCount,
    required this.sauceCount,
    required this.tab,
    required this.locale,
    required this.onTabChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final actionLabel = tab == _Tab.recipe
        ? AppStrings.getRecipes(locale)
        : AppStrings.getSauces(locale);

    return Container(
      color: tokens.bgBase,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s8,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.getRecipes(locale),
                      style: AppTypography.display3.copyWith(
                        color: tokens.fgStrong,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.getRecipes(locale)} $recipeCount${_unit(locale)} · ${AppStrings.getSauces(locale)} $sauceCount${_unit(locale)}',
                      style: AppTypography.label1.copyWith(
                        color: tokens.fgTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              _AddPillButton(label: actionLabel, onPressed: onAdd),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          SegmentControl<_Tab>(
            items: [
              SegmentItem(
                value: _Tab.recipe,
                label: '${AppStrings.getRecipes(locale)} $recipeCount',
              ),
              SegmentItem(
                value: _Tab.sauce,
                label: '${AppStrings.getSauces(locale)} $sauceCount',
              ),
            ],
            selected: tab,
            onChanged: onTabChanged,
          ),
        ],
      ),
    );
  }

  String _unit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '개';
      case AppLocale.japan:
        return '個';
      case AppLocale.china:
        return '个';
      case AppLocale.usa:
      case AppLocale.chinaTraditional:
        return '';
      case AppLocale.vietnam:
        return '';
    }
  }
}

class _AddPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _AddPillButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Material(
      color: tokens.primary,
      borderRadius: AppRadius.brPill,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.brPill,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16, color: tokens.fgOnPrimary),
              const SizedBox(width: 2),
              Text(
                label,
                style: AppTypography.label2.copyWith(
                  color: tokens.fgOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeList extends StatelessWidget {
  final List<Recipe> recipes;
  final bool isLoading;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final ValueChanged<Recipe> onTap;
  final VoidCallback onAdd;

  const _RecipeList({
    required this.recipes,
    required this.isLoading,
    required this.locale,
    required this.formatStyle,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (recipes.isEmpty) {
      return _EmptyState(
        icon: Icons.menu_book_outlined,
        title: AppStrings.getNoRecipes(locale),
        ctaLabel: AppStrings.getRecipes(locale),
        onAdd: onAdd,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s32,
      ),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
      itemBuilder: (context, index) {
        final r = recipes[index];
        return _RecipeCard(
          recipe: r,
          locale: locale,
          formatStyle: formatStyle,
          onTap: () => onTap(r),
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.recipe,
    required this.locale,
    required this.formatStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final ingredientCount = recipe.ingredients.length;
    final sauceCount = recipe.sauces.length;
    final servings =
        '${NumberFormatter.formatNumber(recipe.outputAmount.round(), formatStyle)}${recipe.outputUnit}';
    final costText = NumberFormatter.formatCurrency(
      recipe.totalCost,
      locale,
      formatStyle,
    );
    final sellText = NumberFormatter.formatCurrency(
      recipe.sellPrice,
      locale,
      formatStyle,
    );
    final marginPct = RecipeMargin.percent(recipe.sellPrice, recipe.totalCost);
    final marginColor = recipe.sellPrice <= 0
        ? tokens.fgTertiary
        : RecipeMargin.color(marginPct, tokens);
    final marginText = recipe.sellPrice <= 0
        ? '-'
        : '${marginPct.toStringAsFixed(0)}%';

    return Material(
      color: tokens.bgBase,
      borderRadius: AppRadius.brR16,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brR16,
        child: Container(
          decoration: BoxDecoration(
            color: tokens.bgBase,
            borderRadius: AppRadius.brR16,
            border: Border.all(color: tokens.borderSubtle, width: 1),
          ),
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: AppTypography.headline2.copyWith(
                        color: tokens.fgStrong,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppStrings.getIngredients(locale)} $ingredientCount · ${AppStrings.getSauces(locale)} $sauceCount · $servings',
                      style: AppTypography.label2.copyWith(
                        color: tokens.fgTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Row(
                      children: [
                        Flexible(
                          child: _CostSellPair(
                            label: AppStrings.getCost(locale),
                            value: costText,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: _CostSellPair(
                            label: AppStrings.getSell(locale),
                            value: sellText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    marginText,
                    style: AppTypography.title3.copyWith(
                      color: marginColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.getMarginRate(locale),
                    style: AppTypography.label2.copyWith(
                      color: tokens.fgTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CostSellPair extends StatelessWidget {
  final String label;
  final String value;

  const _CostSellPair({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTypography.label2.copyWith(color: tokens.fgTertiary),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: AppTypography.label2.copyWith(
              color: tokens.fgStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SauceList extends StatelessWidget {
  final List<Sauce> sauces;
  final bool isLoading;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final ValueChanged<Sauce> onTap;
  final VoidCallback onAdd;

  const _SauceList({
    required this.sauces,
    required this.isLoading,
    required this.locale,
    required this.formatStyle,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (sauces.isEmpty) {
      return _EmptyState(
        icon: Icons.blender_outlined,
        title: AppStrings.getNoSauces(locale),
        ctaLabel: AppStrings.getSauces(locale),
        onAdd: onAdd,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s32,
      ),
      itemCount: sauces.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
      itemBuilder: (context, index) {
        final s = sauces[index];
        return _SauceCard(
          sauce: s,
          locale: locale,
          formatStyle: formatStyle,
          onTap: () => onTap(s),
        );
      },
    );
  }
}

class _SauceCard extends StatelessWidget {
  final Sauce sauce;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final VoidCallback onTap;

  const _SauceCard({
    required this.sauce,
    required this.locale,
    required this.formatStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final costText = NumberFormatter.formatCurrency(
      sauce.totalCost,
      locale,
      formatStyle,
    );

    return Material(
      color: tokens.bgBase,
      borderRadius: AppRadius.brR16,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brR16,
        child: Container(
          decoration: BoxDecoration(
            color: tokens.bgBase,
            borderRadius: AppRadius.brR16,
            border: Border.all(color: tokens.borderSubtle, width: 1),
          ),
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sauce.name,
                      style: AppTypography.headline2.copyWith(
                        color: tokens.fgStrong,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppStrings.getTotalWeight(locale)} ${NumberFormatter.formatNumber(sauce.totalWeight.round(), formatStyle)}g',
                      style: AppTypography.label2.copyWith(
                        color: tokens.fgTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    costText,
                    style: AppTypography.headline2.copyWith(
                      color: tokens.fgStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.getSauceCostLabel(locale),
                    style: AppTypography.label2.copyWith(
                      color: tokens.fgTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String ctaLabel;
  final VoidCallback onAdd;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.ctaLabel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: tokens.fgDisabled),
            const SizedBox(height: AppSpacing.s12),
            Text(
              title,
              style:
                  AppTypography.heading2.copyWith(color: tokens.fgStrong),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(ctaLabel),
            ),
          ],
        ),
      ),
    );
  }
}
