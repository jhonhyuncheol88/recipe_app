import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

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
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import '../../../util/recipe_margin.dart';
import '../../../util/unit_converter.dart' as uc;

/// 레시피 상세 페이지 — screens.jsx 954~1082 디자인 + 배수/공유 추가.
class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  /// 시뮬레이션용 판매가 (적용 전 미리보기).
  double? _simSellPrice;

  /// 배수 (1~50, 정수).
  double _multiplier = 1.0;

  static final Logger _log = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      lineLength: 100,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  @override
  void initState() {
    super.initState();
    context.read<IngredientCubit>().loadIngredients();
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
    if (state is IngredientAddedToRecipe) return state.recipes;
    if (state is IngredientRemovedFromRecipe) return state.recipes;
    if (state is RecipeIngredientAmountUpdated) return state.recipes;
    return const [];
  }

  Recipe? _findById(RecipeState state, String id) {
    final list = _recipesOf(state);
    if (list.isEmpty) return null;
    final match = list.where((e) => e.id == id);
    return match.isEmpty ? null : match.first;
  }

  List<Ingredient> _ingredientsOf(IngredientState s) {
    if (s is IngredientLoaded) return s.ingredients;
    if (s is IngredientAdded) return s.ingredients;
    if (s is IngredientUpdated) return s.ingredients;
    if (s is IngredientDeleted) return s.ingredients;
    if (s is IngredientFilteredByTag) return s.ingredients;
    if (s is IngredientFilteredByTags) return s.ingredients;
    if (s is IngredientFilteredByExpiry) return s.ingredients;
    if (s is IngredientSearchResult) return s.ingredients;
    return const [];
  }

  List<Sauce> _saucesOf(SauceState s) {
    if (s is SauceLoaded) return s.sauces;
    if (s is SauceAdded) return s.sauces;
    if (s is SauceUpdatedState) return s.sauces;
    if (s is SauceDeleted) return s.sauces;
    return const [];
  }

  /// 배수 단위 (배 / 倍 / x).
  String _multiplierUnit(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '배';
      case AppLocale.japan:
      case AppLocale.china:
        return '倍';
      case AppLocale.usa:
      case AppLocale.chinaTraditional:
      case AppLocale.vietnam:
        return 'x';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;

    return BlocConsumer<RecipeCubit, RecipeState>(
      listenWhen: (prev, curr) => curr is RecipeDeleted,
      listener: (context, state) {
        // 이 페이지에서 보고 있는 레시피가 삭제되면 자동 pop.
        // deletedId 를 직접 매칭해서 다른 state(Updated/Loaded) 와 섞이지 않게 함.
        if (state is RecipeDeleted &&
            state.deletedId == widget.recipe.id &&
            mounted) {
          _log.i(
            '[detail.listener] RecipeDeleted 감지 id=${state.deletedId} → pop 예약',
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && context.canPop()) {
              _log.d('[detail.listener] context.pop() 실행');
              context.pop();
            } else {
              _log.w(
                '[detail.listener] pop 조건 불만족 mounted=$mounted '
                'canPop=${context.canPop()}',
              );
            }
          });
        }
      },
      builder: (context, state) {
        final recipe = _findById(state, widget.recipe.id) ?? widget.recipe;
        final ingredients = context.watch<IngredientCubit>().state;
        final sauces = context.watch<SauceCubit>().state;

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
              recipe.name,
              style:
                  AppTypography.heading2.copyWith(color: tokens.fgStrong),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () =>
                    context.push(AppRouter.recipeEdit, extra: recipe),
                icon: Icon(Icons.edit_outlined, color: tokens.fgStrong),
                tooltip: AppStrings.getEdit(locale),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: tokens.fgStrong),
                color: tokens.bgBase,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.brR12,
                  side: BorderSide(color: tokens.borderSubtle, width: 1),
                ),
                onSelected: (value) async {
                  if (value == 'share') {
                    await _share(
                      recipe,
                      locale,
                      formatStyle,
                      _ingredientsOf(ingredients),
                      _saucesOf(sauces),
                    );
                  } else if (value == 'delete') {
                    await _confirmDelete(recipe, locale);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem<String>(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.ios_share,
                            size: 18, color: tokens.fgStrong),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          AppStrings.getShare(locale),
                          style: AppTypography.body2
                              .copyWith(color: tokens.fgStrong),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: tokens.negative),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          AppStrings.getDelete(locale),
                          style: AppTypography.body2
                              .copyWith(color: tokens.negative),
                        ),
                      ],
                    ),
                  ),
                ],
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroCard(
                  recipe: recipe,
                  locale: locale,
                  formatStyle: formatStyle,
                  simSellPrice: _simSellPrice ?? recipe.sellPrice,
                  compositionCount: recipe.ingredients.length +
                      recipe.sauces.length,
                  onSimChanged: (value) =>
                      setState(() => _simSellPrice = value),
                  onApplySim: () => _applySimSellPrice(recipe),
                ),
                const SizedBox(height: AppSpacing.s12),
                _ProductionGuideCard(
                  recipe: recipe,
                  ingredients: _ingredientsOf(ingredients),
                  sauces: _saucesOf(sauces),
                  multiplier: _multiplier,
                  unit: _multiplierUnit(locale),
                  locale: locale,
                  formatStyle: formatStyle,
                  onChanged: (v) =>
                      setState(() => _multiplier = v.roundToDouble()),
                ),
                const SizedBox(height: AppSpacing.s12),
                _CompositionCard(
                  recipe: recipe,
                  ingredients: _ingredientsOf(ingredients),
                  sauces: _saucesOf(sauces),
                  locale: locale,
                  formatStyle: formatStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _applySimSellPrice(Recipe recipe) async {
    final value = _simSellPrice;
    if (value == null) {
      _log.w('[detail._applySimSellPrice] _simSellPrice null, 무시');
      return;
    }
    _log.i(
      '[detail._applySimSellPrice] 시작 id=${recipe.id} '
      'oldSellPrice=${recipe.sellPrice} newSellPrice=$value',
    );
    await context
        .read<RecipeCubit>()
        .updateRecipe(recipe.copyWith(sellPrice: value));
    if (!mounted) return;
    _log.d('[detail._applySimSellPrice] cubit await 완료, _simSellPrice=null');
    setState(() => _simSellPrice = null);
  }

  Future<void> _share(
    Recipe recipe,
    AppLocale locale,
    NumberFormatStyle formatStyle,
    List<Ingredient> ingredients,
    List<Sauce> sauces,
  ) async {
    final m = RecipeMargin.percent(recipe.sellPrice, recipe.totalCost);
    final mult = _multiplier;
    final unit = _multiplierUnit(locale);
    final lines = <String>[
      recipe.name,
      '${AppStrings.getCost(locale)}: ${NumberFormatter.formatCurrency(recipe.totalCost, locale, formatStyle)}',
      '${AppStrings.getSellPrice(locale)}: ${NumberFormatter.formatCurrency(recipe.sellPrice, locale, formatStyle)}',
      '${AppStrings.getMarginRate(locale)}: ${m.toStringAsFixed(0)}%',
    ];

    final hasItems =
        recipe.ingredients.isNotEmpty || recipe.sauces.isNotEmpty;
    if (hasItems) {
      final scaledOutput = recipe.outputAmount * mult;
      lines.add('');
      lines.add(
        '${AppStrings.getMultiplier(locale)}: ${mult.toStringAsFixed(0)}$unit'
        ' (${_formatShareQty(scaledOutput, formatStyle)}${recipe.outputUnit})',
      );

      if (recipe.ingredients.isNotEmpty) {
        lines.add('');
        lines.add('[${AppStrings.getIngredients(locale)}]');
        for (final ri in recipe.ingredients) {
          final name = ingredients
                  .where((i) => i.id == ri.ingredientId)
                  .map((i) => i.name)
                  .firstOrNull ??
              ri.ingredientId;
          lines.add(
            '- $name: ${_formatShareQty(ri.amount * mult, formatStyle)}${ri.unitId}',
          );
        }
      }

      if (recipe.sauces.isNotEmpty) {
        lines.add('');
        lines.add('[${AppStrings.getSauces(locale)}]');
        for (final rs in recipe.sauces) {
          final name = sauces
                  .where((s) => s.id == rs.sauceId)
                  .map((s) => s.name)
                  .firstOrNull ??
              rs.sauceId;
          lines.add(
            '- $name: ${_formatShareQty(rs.amount * mult, formatStyle)}${rs.unitId}',
          );
        }
      }
    }

    await Share.share(lines.join('\n'));
  }

  String _formatShareQty(double qty, NumberFormatStyle formatStyle) {
    if (qty % 1 == 0) {
      return NumberFormatter.formatNumber(qty.round(), formatStyle);
    }
    return qty.toStringAsFixed(1);
  }

  Future<void> _confirmDelete(Recipe recipe, AppLocale locale) async {
    final tokens = AppColorTokens.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.getDelete(locale)),
        content: Text(
          '${recipe.name}${AppStrings.getDeleteRecipeConfirm(locale)}',
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
    if (confirmed != true) {
      _log.d('[detail._confirmDelete] 사용자 취소 id=${recipe.id}');
      return;
    }
    if (!mounted) return;
    _log.i('[detail._confirmDelete] cubit.deleteRecipe 호출 id=${recipe.id}');
    await context.read<RecipeCubit>().deleteRecipe(recipe.id);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Hero card: 아이콘 + 이름 + 도넛 + 통계 + 판매가 시뮬레이션 슬라이더
// ─────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final Recipe recipe;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final double simSellPrice;
  final int compositionCount;
  final ValueChanged<double> onSimChanged;
  final VoidCallback onApplySim;

  const _HeroCard({
    required this.recipe,
    required this.locale,
    required this.formatStyle,
    required this.simSellPrice,
    required this.compositionCount,
    required this.onSimChanged,
    required this.onApplySim,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    // 도넛/판매가 시뮬레이션은 항상 1배(원가) 기준 — 배수는 제작 가이드용이라 별개.
    final cost = recipe.totalCost;
    final m = RecipeMargin.percent(simSellPrice, cost);
    final profit = RecipeMargin.profit(simSellPrice, cost);
    final marginColor = simSellPrice <= 0 || m < 0
        ? tokens.fgTertiary
        : RecipeMargin.color(m, tokens);
    final isLossOrZero = simSellPrice <= 0 || m < 0;
    final isDirty =
        (simSellPrice - recipe.sellPrice).abs() > 0.0001;

    final sliderMin = math.max(cost.round(), 0).toDouble();
    final sliderMax = math.max((cost * 4).round(), 100).toDouble();
    final clamped = simSellPrice.clamp(sliderMin, sliderMax);

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
                  recipe.name,
                  style: AppTypography.title3.copyWith(
                    color: tokens.fgStrong,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormatter.formatNumber(recipe.outputAmount.round(), formatStyle)}${recipe.outputUnit} · ${AppStrings.getCompositionIngredients(locale)} $compositionCount',
                  style: AppTypography.label1.copyWith(
                    color: tokens.fgTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _MarginDonut(
                  size: 120,
                  stroke: 14,
                  marginPct: isLossOrZero ? 0 : m,
                  color: marginColor,
                  trackColor: tokens.bgMuted,
                  isLossOrZero: isLossOrZero,
                  centerLabel: AppStrings.getMarginRate(locale),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    children: [
                      _StatRow(
                        label: AppStrings.getSellPrice(locale),
                        value: NumberFormatter.formatCurrency(
                            simSellPrice, locale, formatStyle),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      _StatRow(
                        label: AppStrings.getTotalCostLabel(locale),
                        value: NumberFormatter.formatCurrency(
                            cost, locale, formatStyle),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Container(
                        height: 1,
                        color: tokens.borderSubtle,
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.getProfitPerOne(locale),
                            style: AppTypography.label1.copyWith(
                              color: tokens.fgStrong,
                            ),
                          ),
                          Text(
                            NumberFormatter.formatCurrency(
                                profit, locale, formatStyle),
                            style: AppTypography.headline2.copyWith(
                              color: tokens.primary,
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
            const SizedBox(height: AppSpacing.s20),
            // 판매가 시뮬레이션
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s12,
                AppSpacing.s12,
                AppSpacing.s12,
                AppSpacing.s8,
              ),
              decoration: BoxDecoration(
                color: tokens.bgMuted,
                borderRadius: AppRadius.brR12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          AppStrings.getSellPriceSimulation(locale),
                          style: AppTypography.label1.copyWith(
                            color: tokens.fgStrong,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            NumberFormatter.formatCurrency(
                                simSellPrice, locale, formatStyle),
                            style: AppTypography.heading2.copyWith(
                              color: tokens.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isDirty) ...[
                            const SizedBox(width: AppSpacing.s8),
                            _ApplyButton(
                              label: _applyLabel(locale),
                              onTap: onApplySim,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: tokens.primary,
                      inactiveTrackColor: tokens.borderSubtle,
                      thumbColor: tokens.primary,
                      overlayColor: tokens.primary.withValues(alpha: 0.12),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: clamped.toDouble(),
                      min: sliderMin,
                      max: sliderMax,
                      divisions: ((sliderMax - sliderMin) / 100)
                          .clamp(1, 1000)
                          .round(),
                      onChanged: (v) => onSimChanged(v.roundToDouble()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        NumberFormatter.formatCurrency(
                            sliderMin, locale, formatStyle),
                        style: AppTypography.caption2
                            .copyWith(color: tokens.fgTertiary),
                      ),
                      Text(
                        NumberFormatter.formatCurrency(
                            sliderMax, locale, formatStyle),
                        style: AppTypography.caption2
                            .copyWith(color: tokens.fgTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _applyLabel(AppLocale locale) {
    switch (locale) {
      case AppLocale.korea:
        return '적용';
      case AppLocale.japan:
        return '適用';
      case AppLocale.china:
        return '应用';
      case AppLocale.usa:
      case AppLocale.chinaTraditional:
        return 'Apply';
      case AppLocale.vietnam:
        return 'Áp dụng';
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTypography.label2.copyWith(color: tokens.fgTertiary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          value,
          style: AppTypography.label1.copyWith(
            color: tokens.fgStrong,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ApplyButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Material(
      color: tokens.primary,
      borderRadius: AppRadius.brR8,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brR8,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s8,
            vertical: AppSpacing.s4,
          ),
          child: Text(
            label,
            style: AppTypography.label2.copyWith(
              color: tokens.fgOnPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Donut chart for margin
// ─────────────────────────────────────────────────────────────────────────
class _MarginDonut extends StatelessWidget {
  final double size;
  final double stroke;
  final double marginPct; // 0 ~ 100
  final Color color;
  final Color trackColor;
  final bool isLossOrZero;
  final String centerLabel;

  const _MarginDonut({
    required this.size,
    required this.stroke,
    required this.marginPct,
    required this.color,
    required this.trackColor,
    required this.isLossOrZero,
    required this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          progress: isLossOrZero ? 0.0 : (marginPct / 100).clamp(0.0, 1.0),
          color: color,
          trackColor: trackColor,
          stroke: stroke,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel,
                style: AppTypography.caption1
                    .copyWith(color: tokens.fgTertiary),
              ),
              const SizedBox(height: 2),
              Text(
                '${marginPct.toStringAsFixed(0)}%',
                style: AppTypography.title3.copyWith(
                  color: isLossOrZero ? tokens.fgTertiary : color,
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

class _DonutPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color trackColor;
  final double stroke;

  _DonutPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.stroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = stroke / 2;
    final arcRect = Rect.fromLTRB(
      rect.left + inset,
      rect.top + inset,
      rect.right - inset,
      rect.bottom - inset,
    );

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..color = trackColor;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);

    if (progress > 0) {
      final fg = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      // 12시 방향에서 시작.
      const start = -math.pi / 2;
      canvas.drawArc(arcRect, start, math.pi * 2 * progress, false, fg);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.stroke != stroke;
}

// ─────────────────────────────────────────────────────────────────────────
// Multiplier + Share card
// ─────────────────────────────────────────────────────────────────────────
/// 제작 가이드: 배수 슬라이더 + 그 배수에 맞춰 스케일된 재료/소스 양 리스트.
/// 원가 표시 없이 "이만큼 만들려면 재료가 얼마 필요한지" 만 보여준다.
class _ProductionGuideCard extends StatelessWidget {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Sauce> sauces;
  final double multiplier;
  final String unit;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final ValueChanged<double> onChanged;

  const _ProductionGuideCard({
    required this.recipe,
    required this.ingredients,
    required this.sauces,
    required this.multiplier,
    required this.unit,
    required this.locale,
    required this.formatStyle,
    required this.onChanged,
  });

  Ingredient? _findIngredient(String id) {
    for (final i in ingredients) {
      if (i.id == id) return i;
    }
    return null;
  }

  Sauce? _findSauce(String id) {
    for (final s in sauces) {
      if (s.id == id) return s;
    }
    return null;
  }

  String _formatQty(double qty) {
    if (qty % 1 == 0) {
      return NumberFormatter.formatNumber(qty.round(), formatStyle);
    }
    return qty.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final hasItems =
        recipe.ingredients.isNotEmpty || recipe.sauces.isNotEmpty;
    final scaledOutput = recipe.outputAmount * multiplier;

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.getMultiplier(locale),
                        style: AppTypography.headline2.copyWith(
                          color: tokens.fgStrong,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s4,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.primarySoft,
                        borderRadius: AppRadius.brPill,
                        border: Border.all(
                          color: tokens.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${multiplier.toStringAsFixed(0)}$unit',
                        style: AppTypography.label1.copyWith(
                          color: tokens.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatQty(scaledOutput)}${recipe.outputUnit}',
                  style: AppTypography.label1.copyWith(
                    color: tokens.fgTertiary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: tokens.primary,
                inactiveTrackColor: tokens.borderSubtle,
                thumbColor: tokens.primary,
                overlayColor: tokens.primary.withValues(alpha: 0.12),
                trackHeight: 3,
              ),
              child: Slider(
                value: multiplier,
                min: 1,
                max: 50,
                divisions: 49,
                onChanged: onChanged,
              ),
            ),
          ),
          if (hasItems) ...[
            Container(height: 1, color: tokens.borderSubtle),
            for (int i = 0; i < recipe.ingredients.length; i++)
              _GuideRow(
                name: _findIngredient(recipe.ingredients[i].ingredientId)
                        ?.name ??
                    recipe.ingredients[i].ingredientId,
                baseQty: recipe.ingredients[i].amount,
                scaledQty: recipe.ingredients[i].amount * multiplier,
                unit: recipe.ingredients[i].unitId,
                isSauce: false,
                locale: locale,
                formatStyle: formatStyle,
                isLast: i == recipe.ingredients.length - 1 &&
                    recipe.sauces.isEmpty,
              ),
            for (int i = 0; i < recipe.sauces.length; i++)
              _GuideRow(
                name: _findSauce(recipe.sauces[i].sauceId)?.name ??
                    recipe.sauces[i].sauceId,
                baseQty: recipe.sauces[i].amount,
                scaledQty: recipe.sauces[i].amount * multiplier,
                unit: recipe.sauces[i].unitId,
                isSauce: true,
                locale: locale,
                formatStyle: formatStyle,
                isLast: i == recipe.sauces.length - 1,
              ),
          ],
        ],
      ),
    );
  }
}

/// 제작 가이드 1행: 재료/소스 이름 + (1배 양 × 배수 = 스케일된 양) 표시.
class _GuideRow extends StatelessWidget {
  final String name;
  final double baseQty;
  final double scaledQty;
  final String unit;
  final bool isSauce;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final bool isLast;

  const _GuideRow({
    required this.name,
    required this.baseQty,
    required this.scaledQty,
    required this.unit,
    required this.isSauce,
    required this.locale,
    required this.formatStyle,
    required this.isLast,
  });

  String _format(double v) {
    if (v % 1 == 0) {
      return NumberFormatter.formatNumber(v.round(), formatStyle);
    }
    return v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: tokens.borderSubtle, width: 1),
              ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    name,
                    style: AppTypography.body2.copyWith(
                      color: tokens.fgStrong,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSauce) ...[
                  const SizedBox(width: AppSpacing.s6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.positiveSoft,
                      borderRadius: AppRadius.brR8,
                    ),
                    child: Text(
                      AppStrings.getSauces(locale),
                      style: AppTypography.label2.copyWith(
                        color: tokens.positive,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_format(scaledQty)}$unit',
                style: AppTypography.label1.copyWith(
                  color: tokens.fgStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '1× ${_format(baseQty)}$unit',
                style: AppTypography.caption2.copyWith(
                  color: tokens.fgTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Composition card
// ─────────────────────────────────────────────────────────────────────────
class _CompositionCard extends StatelessWidget {
  final Recipe recipe;
  final List<Ingredient> ingredients;
  final List<Sauce> sauces;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;

  const _CompositionCard({
    required this.recipe,
    required this.ingredients,
    required this.sauces,
    required this.locale,
    required this.formatStyle,
  });

  static const _palette = <Color>[
    AppPalette.blue600,
    AppPalette.violet600,
    AppPalette.green600,
    AppPalette.orange600,
    AppPalette.cyan600,
    AppPalette.pink500,
    AppPalette.redorange600,
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final items = _buildItems();
    final totalCost = items.fold<double>(0, (sum, it) => sum + it.value);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.getCostComposition(locale),
                      style: AppTypography.headline2.copyWith(
                        color: tokens.fgStrong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      NumberFormatter.formatCurrency(
                          totalCost, locale, formatStyle),
                      style: AppTypography.label1.copyWith(
                        color: tokens.fgTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                if (totalCost > 0)
                  ClipRRect(
                    borderRadius: AppRadius.brR8,
                    child: SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          for (int i = 0; i < items.length; i++)
                            if (items[i].value > 0)
                              Expanded(
                                flex: math.max(
                                  1,
                                  (items[i].value / totalCost * 1000).round(),
                                ),
                                child: Container(
                                  color: _palette[i % _palette.length],
                                ),
                              ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: tokens.bgMuted,
                      borderRadius: AppRadius.brR8,
                    ),
                  ),
              ],
            ),
          ),
          Container(height: 1, color: tokens.borderSubtle),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s24,
              ),
              child: Text(
                AppStrings.getNotUsedAnywhere(locale),
                style:
                    AppTypography.body2.copyWith(color: tokens.fgSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          for (int i = 0; i < items.length; i++)
            _CompositionRow(
              item: items[i],
              color: _palette[i % _palette.length],
              totalCost: totalCost,
              locale: locale,
              formatStyle: formatStyle,
              isLast: i == items.length - 1,
            ),
        ],
      ),
    );
  }

  List<_CompItem> _buildItems() {
    final result = <_CompItem>[];

    // 재료 — 원가 구성은 항상 1배(원가) 기준. 배수는 _ProductionGuideCard 전용.
    for (final ri in recipe.ingredients) {
      final ing = _findIngredient(ri.ingredientId);
      result.add(
        _CompItem(
          name: ing?.name ?? ri.ingredientId,
          qty: ri.amount,
          unit: ri.unitId,
          value: ri.calculatedCost,
          isSauce: false,
        ),
      );
    }

    // 소스
    for (final rs in recipe.sauces) {
      final sauce = _findSauce(rs.sauceId);
      double cost = 0;
      if (sauce != null && sauce.totalWeight > 0) {
        final unitCost = sauce.totalCost / sauce.totalWeight;
        // 알 수 없는 unitId 방어 — 실패 시 amount 그대로 g 로 취급.
        double baseUsage;
        try {
          baseUsage = uc.UnitConverter.toBaseUnit(rs.amount, rs.unitId);
        } catch (_) {
          baseUsage = rs.amount;
        }
        cost = unitCost * baseUsage;
      }
      result.add(
        _CompItem(
          name: sauce?.name ?? rs.sauceId,
          qty: rs.amount,
          unit: rs.unitId,
          value: cost,
          isSauce: true,
        ),
      );
    }

    result.sort((a, b) => b.value.compareTo(a.value));
    return result;
  }

  Ingredient? _findIngredient(String id) {
    for (final i in ingredients) {
      if (i.id == id) return i;
    }
    return null;
  }

  Sauce? _findSauce(String id) {
    for (final s in sauces) {
      if (s.id == id) return s;
    }
    return null;
  }
}

class _CompItem {
  final String name;
  final double qty;
  final String unit;
  final double value;
  final bool isSauce;

  _CompItem({
    required this.name,
    required this.qty,
    required this.unit,
    required this.value,
    required this.isSauce,
  });
}

class _CompositionRow extends StatelessWidget {
  final _CompItem item;
  final Color color;
  final double totalCost;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final bool isLast;

  const _CompositionRow({
    required this.item,
    required this.color,
    required this.totalCost,
    required this.locale,
    required this.formatStyle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final pct = totalCost > 0 ? (item.value / totalCost) * 100 : 0.0;
    final qtyText = item.qty % 1 == 0
        ? item.qty.toStringAsFixed(0)
        : item.qty.toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: tokens.borderSubtle, width: 1),
              ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        style: AppTypography.body2.copyWith(
                          color: tokens.fgStrong,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.isSauce) ...[
                      const SizedBox(width: AppSpacing.s6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.positiveSoft,
                          borderRadius: AppRadius.brR8,
                        ),
                        child: Text(
                          AppStrings.getSauces(locale),
                          style: AppTypography.label2.copyWith(
                            color: tokens.positive,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$qtyText${item.unit}',
                  style: AppTypography.label2.copyWith(
                    color: tokens.fgTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormatter.formatCurrency(
                    item.value, locale, formatStyle),
                style: AppTypography.body2.copyWith(
                  color: tokens.fgStrong,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: AppTypography.label2.copyWith(
                  color: tokens.fgTertiary,
                ),
              ),
            ],
          ),
        ],
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
