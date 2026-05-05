import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../data/recipe_repository.dart';
import '../../../data/sauce_repository.dart';
import '../../../model/ingredient.dart';
import '../../../model/recipe.dart';
import '../../../model/sauce.dart';
import '../../../router/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/date_formatter.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import '../../../util/unit_converter.dart' as uc;
import '../../widget/ingredient_tag_chip.dart';

/// 재료 상세 페이지 — 이미지 3.
class IngredientDetailPage extends StatefulWidget {
  final Ingredient ingredient;

  const IngredientDetailPage({super.key, required this.ingredient});

  @override
  State<IngredientDetailPage> createState() => _IngredientDetailPageState();
}

class _IngredientDetailPageState extends State<IngredientDetailPage> {
  late Future<_UsageData> _usageFuture;

  @override
  void initState() {
    super.initState();
    _usageFuture = _loadUsage();
  }

  Future<_UsageData> _loadUsage() async {
    final sauceRepo = context.read<SauceRepository>();
    final recipeRepo = context.read<RecipeRepository>();
    final ingredientId = widget.ingredient.id;

    final sauces = await sauceRepo.getAllSauces();
    final usingSauces = <_SauceUsage>[];
    for (final s in sauces) {
      final items = await sauceRepo.getIngredientsForSauce(s.id);
      final match = items.where((i) => i.ingredientId == ingredientId).toList();
      if (match.isNotEmpty) {
        usingSauces.add(
          _SauceUsage(
            sauce: s,
            amount: match.first.amount,
            unitId: match.first.unitId,
          ),
        );
      }
    }

    final recipes = await recipeRepo.getRecipesByIngredient(ingredientId);
    final usingRecipes = <_RecipeUsage>[];
    for (final r in recipes) {
      final ri = r.ingredients
          .where((e) => e.ingredientId == ingredientId)
          .toList();
      if (ri.isEmpty) {
        usingRecipes.add(_RecipeUsage(recipe: r, amount: 0, unitId: ''));
      } else {
        usingRecipes.add(
          _RecipeUsage(
            recipe: r,
            amount: ri.first.amount,
            unitId: ri.first.unitId,
          ),
        );
      }
    }

    return _UsageData(sauces: usingSauces, recipes: usingRecipes);
  }

  List<Ingredient> _ingredientsOf(IngredientState state) {
    if (state is IngredientLoaded) return state.ingredients;
    if (state is IngredientUpdated) return state.ingredients;
    if (state is IngredientAdded) return state.ingredients;
    if (state is IngredientDeleted) return state.ingredients;
    if (state is IngredientFilteredByTag) return state.ingredients;
    if (state is IngredientFilteredByTags) return state.ingredients;
    if (state is IngredientFilteredByExpiry) return state.ingredients;
    if (state is IngredientSearchResult) return state.ingredients;
    return const [];
  }

  Ingredient? _findById(IngredientState state, String id) {
    final list = _ingredientsOf(state);
    if (list.isEmpty) return null;
    final match = list.where((e) => e.id == id);
    return match.isEmpty ? null : match.first;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;

    return BlocConsumer<IngredientCubit, IngredientState>(
      listenWhen: (prev, curr) => curr is IngredientLoaded,
      listener: (context, state) {
        // 이 재료가 (이 페이지/다른 페이지에서) 삭제되면 자동 pop.
        if (state is IngredientLoaded) {
          final hasIngredient =
              state.ingredients.any((e) => e.id == widget.ingredient.id);
          if (!hasIngredient && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && context.canPop()) context.pop();
            });
          }
        }
      },
      builder: (context, state) {
        final ing = _findById(state, widget.ingredient.id) ??
            widget.ingredient;

        return Scaffold(
          backgroundColor: tokens.bgElev2,
          appBar: AppBar(
            backgroundColor: tokens.bgBase,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(Icons.arrow_back, color: tokens.fgStrong),
            ),
            title: Text(
              ing.name,
              style: AppTypography.heading2.copyWith(color: tokens.fgStrong),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () =>
                    context.push(AppRouter.ingredientEdit, extra: ing),
                icon: Icon(Icons.edit_outlined, color: tokens.fgStrong),
                tooltip: AppStrings.getEdit(locale),
              ),
              IconButton(
                onPressed: () => _confirmDelete(locale),
                icon: Icon(Icons.delete_outline, color: tokens.fgStrong),
                tooltip: AppStrings.getDelete(locale),
              ),
              const SizedBox(width: AppSpacing.s4),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatCard(
                  ingredient: ing,
                  locale: locale,
                  formatStyle: formatStyle,
                ),
                const SizedBox(height: AppSpacing.s12),
                FutureBuilder<_UsageData>(
                  future: _usageFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const _UsageSkeleton();
                    }
                    final data = snapshot.data ?? _UsageData.empty;
                    return _UsageCard(
                      data: data,
                      ingredientUnitId: ing.purchaseUnitId,
                      locale: locale,
                      formatStyle: formatStyle,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(AppLocale locale) async {
    final tokens = AppColorTokens.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.getDelete(locale)),
        content: Text(
          '${widget.ingredient.name}${AppStrings.getDeleteRecipeConfirm(locale)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: tokens.negative),
            child: Text(AppStrings.getDelete(locale)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await context.read<IngredientCubit>().deleteIngredient(
          widget.ingredient.id,
        );
    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.getIngredientDeleted(locale))),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Ingredient ingredient;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;

  const _StatCard({
    required this.ingredient,
    required this.locale,
    required this.formatStyle,
  });

  int? get _daysLeft {
    final exp = ingredient.expiryDate;
    if (exp == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(exp.year, exp.month, exp.day);
    return target.difference(today).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final tagId = IngredientTagPalette.firstKnownTagId(ingredient.tagIds);
    final unit = uc.UnitConverter.getUnit(ingredient.purchaseUnitId);
    final factor = unit?.conversionFactor ?? 1.0;
    final pricePerBase = ingredient.purchaseAmount * factor == 0
        ? 0.0
        : ingredient.purchasePrice / (ingredient.purchaseAmount * factor);
    final unitType = uc.UnitConverter.getUnitType(ingredient.purchaseUnitId);
    final baseUnit = unitType == uc.UnitType.weight
        ? 'g'
        : (unitType == uc.UnitType.volume ? 'ml' : '개');
    final categoryLabel = IngredientTagPalette.label(tagId, locale);

    final days = _daysLeft;
    final hasExpiry = ingredient.expiryDate != null;
    final expiryColors = hasExpiry && days != null
        ? (days < 0
            ? (fg: tokens.negative, label: 'D+${-days}')
            : days <= 7
                ? (fg: tokens.negative, label: 'D-$days')
                : (fg: tokens.fgStrong, label: 'D-$days'))
        : (fg: tokens.fgTertiary, label: '-');

    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: AppTypography.title3.copyWith(
                    color: tokens.fgStrong,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (categoryLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    categoryLabel,
                    style: AppTypography.label1.copyWith(
                      color: tokens.fgTertiary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StatColumn(
                    label: AppStrings.getUnitPrice(locale),
                    value: NumberFormatter.formatCurrency(
                      pricePerBase,
                      locale,
                      formatStyle,
                    ),
                    suffix: '/$baseUnit',
                    valueColor: tokens.fgStrong,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: AppStrings.getPurchaseAmountShort(locale),
                    value:
                        '${NumberFormatter.formatNumber(ingredient.purchaseAmount.round(), formatStyle)}${ingredient.purchaseUnitId}',
                    secondary: NumberFormatter.formatCurrency(
                      ingredient.purchasePrice,
                      locale,
                      formatStyle,
                    ),
                    valueColor: tokens.fgStrong,
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: AppStrings.getExpiryDate(locale),
                    value: expiryColors.label,
                    secondary: hasExpiry
                        ? DateFormatter.formatDate(
                            ingredient.expiryDate!,
                            locale,
                          )
                        : '',
                    valueColor: expiryColors.fg,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final String? secondary;
  final Color valueColor;

  const _StatColumn({
    required this.label,
    required this.value,
    this.suffix,
    this.secondary,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.label2.copyWith(color: tokens.fgTertiary),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                value,
                style: AppTypography.heading1.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (suffix != null && suffix!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 2, left: 1),
                child: Text(
                  suffix!,
                  style: AppTypography.label2.copyWith(
                    color: tokens.fgTertiary,
                  ),
                ),
              ),
          ],
        ),
        if (secondary != null && secondary!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            secondary!,
            style: AppTypography.label2.copyWith(color: tokens.fgTertiary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _UsageCard extends StatelessWidget {
  final _UsageData data;
  final String ingredientUnitId;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;

  const _UsageCard({
    required this.data,
    required this.ingredientUnitId,
    required this.locale,
    required this.formatStyle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final hasAny = data.sauces.isNotEmpty || data.recipes.isNotEmpty;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s20,
              AppSpacing.s16,
              AppSpacing.s20,
              AppSpacing.s8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.getUsedIn(locale),
                  style: AppTypography.heading2.copyWith(
                    color: tokens.fgStrong,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppStrings.getUsedInSummary(
                    locale,
                    data.sauces.length,
                    data.recipes.length,
                  ),
                  style: AppTypography.label1.copyWith(
                    color: tokens.fgTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (!hasAny)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s8,
                AppSpacing.s20,
                AppSpacing.s24,
              ),
              child: Text(
                AppStrings.getNotUsedAnywhere(locale),
                style: AppTypography.body2.copyWith(
                  color: tokens.fgSecondary,
                ),
              ),
            ),
          for (final s in data.sauces)
            _UsageRow(
              icon: Icons.blender_outlined,
              iconColor: tokens.positive,
              iconBg: tokens.positiveSoft,
              title: s.sauce.name,
              subtitle: AppStrings.getUsesThisIngredient(
                locale,
                '${NumberFormatter.formatNumber(s.amount.round(), formatStyle)}${s.unitId}',
              ),
              onTap: () => context.push('/sauce/edit', extra: s.sauce),
            ),
          for (final r in data.recipes)
            _UsageRow(
              icon: Icons.restaurant_menu,
              iconColor: tokens.warning,
              iconBg: tokens.warningSoft,
              title: r.recipe.name,
              subtitle: r.amount > 0
                  ? AppStrings.getUsesThisIngredient(
                      locale,
                      '${NumberFormatter.formatNumber(r.amount.round(), formatStyle)}${r.unitId}',
                    )
                  : '',
              onTap: () {},
            ),
          const SizedBox(height: AppSpacing.s4),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _UsageRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: AppRadius.brR8,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headline2.copyWith(
                      color: tokens.fgStrong,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.label2.copyWith(
                      color: tokens.fgTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: tokens.fgTertiary),
          ],
        ),
      ),
    );
  }
}

class _UsageSkeleton extends StatelessWidget {
  const _UsageSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return _CardShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s20,
          vertical: AppSpacing.s24,
        ),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: tokens.fgTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tokens.bgBase,
        borderRadius: AppRadius.brR16,
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: child,
    );
  }
}

class _UsageData {
  final List<_SauceUsage> sauces;
  final List<_RecipeUsage> recipes;
  const _UsageData({required this.sauces, required this.recipes});
  static const empty = _UsageData(sauces: [], recipes: []);
}

class _SauceUsage {
  final Sauce sauce;
  final double amount;
  final String unitId;
  const _SauceUsage({
    required this.sauce,
    required this.amount,
    required this.unitId,
  });
}

class _RecipeUsage {
  final Recipe recipe;
  final double amount;
  final String unitId;
  const _RecipeUsage({
    required this.recipe,
    required this.amount,
    required this.unitId,
  });
}
