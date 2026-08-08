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
import '../../widget/recipe_summary_card.dart';
import '../../widget/sauce_summary_card.dart';
import '../../widget/segment_control.dart';

enum _Tab { recipe, sauce }

/// 레시피 정렬 모드 — 판매가/원가 각각 지원.
enum _RecipeSort {
  newest,
  sellPriceHigh,
  sellPriceLow,
  costHigh,
  costLow,
  nameAsc,
}

/// 소스 정렬 모드 — 소스는 원가만 존재.
enum _SauceSort { newest, costHigh, costLow, nameAsc }

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
  late final TextEditingController _searchController;
  String _recipeQuery = '';
  String _sauceQuery = '';
  _RecipeSort _recipeSort = _RecipeSort.newest;
  _SauceSort _sauceSort = _SauceSort.newest;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<RecipeCubit>().loadRecipes();
    context.read<SauceCubit>().loadSauces();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged(_Tab t) {
    setState(() {
      _tab = t;
      final q = t == _Tab.recipe ? _recipeQuery : _sauceQuery;
      _searchController.text = q;
      _searchController.selection = TextSelection.collapsed(offset: q.length);
    });
  }

  void _onSearchChanged(String v) {
    setState(() {
      if (_tab == _Tab.recipe) {
        _recipeQuery = v;
      } else {
        _sauceQuery = v;
      }
    });
  }

  void _onSearchClear() {
    _searchController.clear();
    setState(() {
      if (_tab == _Tab.recipe) {
        _recipeQuery = '';
      } else {
        _sauceQuery = '';
      }
    });
  }

  List<Recipe> _visibleRecipes(List<Recipe> all) {
    Iterable<Recipe> result = all;
    final query = _recipeQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((r) => r.name.toLowerCase().contains(query));
    }
    final list = result.toList();
    switch (_recipeSort) {
      case _RecipeSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _RecipeSort.sellPriceHigh:
        list.sort((a, b) => b.sellPrice.compareTo(a.sellPrice));
        break;
      case _RecipeSort.sellPriceLow:
        list.sort((a, b) => a.sellPrice.compareTo(b.sellPrice));
        break;
      case _RecipeSort.costHigh:
        list.sort((a, b) => b.totalCost.compareTo(a.totalCost));
        break;
      case _RecipeSort.costLow:
        list.sort((a, b) => a.totalCost.compareTo(b.totalCost));
        break;
      case _RecipeSort.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }

  List<Sauce> _visibleSauces(List<Sauce> all) {
    Iterable<Sauce> result = all;
    final query = _sauceQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((s) => s.name.toLowerCase().contains(query));
    }
    final list = result.toList();
    switch (_sauceSort) {
      case _SauceSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SauceSort.costHigh:
        list.sort((a, b) => b.totalCost.compareTo(a.totalCost));
        break;
      case _SauceSort.costLow:
        list.sort((a, b) => a.totalCost.compareTo(b.totalCost));
        break;
      case _SauceSort.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }

  String _recipeSortLabel(_RecipeSort mode, AppLocale locale) {
    switch (mode) {
      case _RecipeSort.newest:
        return AppStrings.getSortNewest(locale);
      case _RecipeSort.sellPriceHigh:
        return AppStrings.getSortSellPriceHigh(locale);
      case _RecipeSort.sellPriceLow:
        return AppStrings.getSortSellPriceLow(locale);
      case _RecipeSort.costHigh:
        return AppStrings.getSortCostHigh(locale);
      case _RecipeSort.costLow:
        return AppStrings.getSortCostLow(locale);
      case _RecipeSort.nameAsc:
        return AppStrings.getSortNameAsc(locale);
    }
  }

  String _sauceSortLabel(_SauceSort mode, AppLocale locale) {
    switch (mode) {
      case _SauceSort.newest:
        return AppStrings.getSortNewest(locale);
      case _SauceSort.costHigh:
        return AppStrings.getSortCostHigh(locale);
      case _SauceSort.costLow:
        return AppStrings.getSortCostLow(locale);
      case _SauceSort.nameAsc:
        return AppStrings.getSortNameAsc(locale);
    }
  }

  String _currentSortLabel(AppLocale locale) =>
      _tab == _Tab.recipe
          ? _recipeSortLabel(_recipeSort, locale)
          : _sauceSortLabel(_sauceSort, locale);

  String _searchHint(AppLocale locale) =>
      _tab == _Tab.recipe
          ? AppStrings.getSearchRecipeHint(locale)
          : AppStrings.getSearchSauceHint(locale);

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

  Future<void> _showSortSheet(BuildContext context, AppLocale locale) async {
    final tokens = AppColorTokens.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.bgBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r20),
        ),
      ),
      builder: (sheetCtx) {
        final options = <(String, bool, VoidCallback)>[
          if (_tab == _Tab.recipe)
            for (final mode in _RecipeSort.values)
              (
                _recipeSortLabel(mode, locale),
                mode == _recipeSort,
                () {
                  setState(() => _recipeSort = mode);
                  Navigator.of(sheetCtx).pop();
                },
              )
          else
            for (final mode in _SauceSort.values)
              (
                _sauceSortLabel(mode, locale),
                mode == _sauceSort,
                () {
                  setState(() => _sauceSort = mode);
                  Navigator.of(sheetCtx).pop();
                },
              ),
        ];
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20,
                      AppSpacing.s4,
                      AppSpacing.s20,
                      AppSpacing.s12,
                    ),
                    child: Text(
                      AppStrings.getSortBy(locale),
                      style: AppTypography.heading2.copyWith(
                        color: tokens.fgStrong,
                      ),
                    ),
                  ),
                  for (final option in options)
                    _SortOptionTile(
                      label: option.$1,
                      selected: option.$2,
                      onTap: option.$3,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
                final visibleRecipes = _visibleRecipes(recipes);
                final visibleSauces = _visibleSauces(sauces);
                final activeAllCount =
                    _tab == _Tab.recipe ? recipes.length : sauces.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StickyHeader(
                      recipeCount: recipes.length,
                      sauceCount: sauces.length,
                      tab: _tab,
                      locale: locale,
                      onTabChanged: _onTabChanged,
                      onAdd: () => _openCreate(locale),
                      onOpenFavorites: () => context.push(AppRouter.favorites),
                    ),
                    Container(
                      color: tokens.bgBase,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.s20,
                        0,
                        AppSpacing.s20,
                        AppSpacing.s12,
                      ),
                      child: _SearchField(
                        controller: _searchController,
                        hint: _searchHint(locale),
                        onChanged: _onSearchChanged,
                        onClear: _onSearchClear,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (activeAllCount > 0)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.s16,
                                AppSpacing.s12,
                                AppSpacing.s16,
                                AppSpacing.s4,
                              ),
                              child: _SortBar(
                                label: _currentSortLabel(locale),
                                onTap: () => _showSortSheet(context, locale),
                              ),
                            ),
                          Expanded(
                            child:
                                _tab == _Tab.recipe
                                    ? _RecipeList(
                                      recipes: visibleRecipes,
                                      allCount: recipes.length,
                                      isLoading:
                                          recipeLoading && recipes.isEmpty,
                                      locale: locale,
                                      formatStyle: formatStyle,
                                      onTap:
                                          (r) => context.push(
                                            AppRouter.recipeDetail,
                                            extra: r,
                                          ),
                                      onAdd:
                                          () => context.push(
                                            AppRouter.recipeCreate,
                                          ),
                                    )
                                    : _SauceList(
                                      sauces: visibleSauces,
                                      allCount: sauces.length,
                                      isLoading: sauceLoading && sauces.isEmpty,
                                      locale: locale,
                                      formatStyle: formatStyle,
                                      onTap:
                                          (s) => context.push(
                                            AppRouter.sauceEdit,
                                            extra: s,
                                          ),
                                      onAdd:
                                          () => context.push(
                                            AppRouter.sauceCreate,
                                          ),
                                    ),
                          ),
                        ],
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
  final VoidCallback onOpenFavorites;

  const _StickyHeader({
    required this.recipeCount,
    required this.sauceCount,
    required this.tab,
    required this.locale,
    required this.onTabChanged,
    required this.onAdd,
    required this.onOpenFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final actionLabel =
        tab == _Tab.recipe
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
              IconButton(
                onPressed: onOpenFavorites,
                icon: Icon(Icons.star_border, color: tokens.fgStrong),
                tooltip: AppStrings.getFavorites(locale),
              ),
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
  final int allCount;
  final bool isLoading;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final ValueChanged<Recipe> onTap;
  final VoidCallback onAdd;

  const _RecipeList({
    required this.recipes,
    required this.allCount,
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
      if (allCount == 0) {
        return _EmptyState(
          icon: Icons.menu_book_outlined,
          title: AppStrings.getNoRecipes(locale),
          ctaLabel: AppStrings.getRecipes(locale),
          onAdd: onAdd,
        );
      }
      return _SearchEmptyState(locale: locale);
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
        return RecipeSummaryCard(
          recipe: r,
          locale: locale,
          formatStyle: formatStyle,
          onTap: () => onTap(r),
          onToggleFavorite: () => context.read<RecipeCubit>().toggleFavorite(r),
        );
      },
    );
  }
}

class _SauceList extends StatelessWidget {
  final List<Sauce> sauces;
  final int allCount;
  final bool isLoading;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final ValueChanged<Sauce> onTap;
  final VoidCallback onAdd;

  const _SauceList({
    required this.sauces,
    required this.allCount,
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
      if (allCount == 0) {
        return _EmptyState(
          icon: Icons.blender_outlined,
          title: AppStrings.getNoSauces(locale),
          ctaLabel: AppStrings.getSauces(locale),
          onAdd: onAdd,
        );
      }
      return _SearchEmptyState(locale: locale);
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
        return SauceSummaryCard(
          sauce: s,
          locale: locale,
          formatStyle: formatStyle,
          onTap: () => onTap(s),
          onToggleFavorite: () => context.read<SauceCubit>().toggleFavorite(s),
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTypography.body1.copyWith(color: tokens.fgDefault),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.body1.copyWith(color: tokens.fgTertiary),
        prefixIcon: Icon(Icons.search, color: tokens.fgTertiary, size: 20),
        suffixIcon:
            controller.text.isEmpty
                ? null
                : IconButton(
                  icon: Icon(Icons.close, color: tokens.fgTertiary, size: 20),
                  onPressed: onClear,
                ),
        filled: true,
        fillColor: tokens.bgElev2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.brPill,
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.brPill,
          borderSide: BorderSide(color: tokens.borderDefault, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.brPill,
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SortBar({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.label1.copyWith(color: tokens.fgTertiary),
        ),
        const Spacer(),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.brR8,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8,
              vertical: AppSpacing.s4,
            ),
            child: Row(
              children: [
                Icon(Icons.sort, size: 16, color: tokens.fgSecondary),
                const SizedBox(width: 4),
                Text(
                  AppStrings.getSort(context.read<LocaleCubit>().state),
                  style: AppTypography.label1.copyWith(
                    color: tokens.fgSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.body1.copyWith(
                  color: selected ? tokens.primary : tokens.fgDefault,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, color: tokens.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final AppLocale locale;

  const _SearchEmptyState({required this.locale});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: tokens.fgDisabled),
            const SizedBox(height: AppSpacing.s12),
            Text(
              AppStrings.getNoSearchResults(locale),
              style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
            ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              AppStrings.getTryDifferentKeyword(locale),
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(color: tokens.fgSecondary),
            ),
          ],
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
              style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
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
