import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/recipe/recipe_state.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../model/recipe.dart';
import '../../../model/sauce.dart';
import '../../../router/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_strings.dart';
import '../../widget/ingredient_list_tile.dart';
import '../../widget/recipe_summary_card.dart';
import '../../widget/sauce_summary_card.dart';
import '../../widget/segment_control.dart';

enum _FavTab { ingredient, recipe, sauce }

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  _FavTab _tab = _FavTab.ingredient;

  @override
  void initState() {
    super.initState();
    context.read<IngredientCubit>().loadIngredients();
    context.read<RecipeCubit>().loadRecipes();
    context.read<SauceCubit>().loadSauces();
  }

  List<Ingredient> _ingredientsOf(IngredientState s) =>
      s is IngredientLoaded ? s.ingredients : const [];
  List<Recipe> _recipesOf(RecipeState s) =>
      s is RecipeLoaded ? s.recipes : const [];
  List<Sauce> _saucesOf(SauceState s) =>
      s is SauceLoaded ? s.sauces : const [];

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;

    return Scaffold(
      backgroundColor: tokens.bgElev2,
      appBar: AppBar(
        backgroundColor: tokens.bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.getFavorites(locale),
          style: AppTypography.heading1.copyWith(color: tokens.fgStrong),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: tokens.bgBase,
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16, 0, AppSpacing.s16, AppSpacing.s12),
            child: SegmentControl<_FavTab>(
              items: [
                SegmentItem(
                  value: _FavTab.ingredient,
                  label: AppStrings.getIngredients(locale),
                ),
                SegmentItem(
                  value: _FavTab.recipe,
                  label: AppStrings.getRecipes(locale),
                ),
                SegmentItem(
                  value: _FavTab.sauce,
                  label: AppStrings.getSauces(locale),
                ),
              ],
              selected: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
          ),
          Expanded(
            child: switch (_tab) {
              _FavTab.ingredient => BlocBuilder<IngredientCubit, IngredientState>(
                  builder: (context, state) {
                    final favs = _ingredientsOf(state)
                        .where((e) => e.isFavorite)
                        .toList();
                    if (favs.isEmpty) {
                      return _Empty(
                          message: AppStrings.getNoFavoriteIngredients(locale));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.s16,
                          AppSpacing.s16, AppSpacing.s16, AppSpacing.s32),
                      itemCount: favs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.s8),
                      itemBuilder: (context, i) => IngredientListTile(
                        ingredient: favs[i],
                        locale: locale,
                        formatStyle: formatStyle,
                        onTap: () => context.push(
                            AppRouter.ingredientDetail, extra: favs[i]),
                        onToggleFavorite: () => context
                            .read<IngredientCubit>()
                            .toggleFavorite(favs[i]),
                      ),
                    );
                  },
                ),
              _FavTab.recipe => BlocBuilder<RecipeCubit, RecipeState>(
                  builder: (context, state) {
                    final favs =
                        _recipesOf(state).where((e) => e.isFavorite).toList();
                    if (favs.isEmpty) {
                      return _Empty(
                          message: AppStrings.getNoFavoriteRecipes(locale));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.s16,
                          AppSpacing.s16, AppSpacing.s16, AppSpacing.s32),
                      itemCount: favs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.s8),
                      itemBuilder: (context, i) => RecipeSummaryCard(
                        recipe: favs[i],
                        locale: locale,
                        formatStyle: formatStyle,
                        onTap: () => context.push(
                            AppRouter.recipeDetail, extra: favs[i]),
                        onToggleFavorite: () => context
                            .read<RecipeCubit>()
                            .toggleFavorite(favs[i]),
                      ),
                    );
                  },
                ),
              _FavTab.sauce => BlocBuilder<SauceCubit, SauceState>(
                  builder: (context, state) {
                    final favs =
                        _saucesOf(state).where((e) => e.isFavorite).toList();
                    if (favs.isEmpty) {
                      return _Empty(
                          message: AppStrings.getNoFavoriteSauces(locale));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.s16,
                          AppSpacing.s16, AppSpacing.s16, AppSpacing.s32),
                      itemCount: favs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.s8),
                      itemBuilder: (context, i) => SauceSummaryCard(
                        sauce: favs[i],
                        locale: locale,
                        formatStyle: formatStyle,
                        onTap: () =>
                            context.push(AppRouter.sauceEdit, extra: favs[i]),
                        onToggleFavorite: () =>
                            context.read<SauceCubit>().toggleFavorite(favs[i]),
                      ),
                    );
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 56, color: tokens.fgDisabled),
            const SizedBox(height: AppSpacing.s12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
            ),
          ],
        ),
      ),
    );
  }
}
