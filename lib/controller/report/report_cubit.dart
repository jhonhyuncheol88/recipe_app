import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../controller/ingredient/ingredient_state.dart';
import '../../controller/ingredient/ingredient_cubit.dart';
import '../../controller/recipe/recipe_state.dart';
import '../../controller/recipe/recipe_cubit.dart';
import '../../controller/setting/locale_cubit.dart';
import '../../data/ingredient_repository.dart';
import '../../data/recipe_repository.dart';
import '../../data/recipe_price_history_repository.dart';
import '../../data/unit_repository.dart';
import '../../model/report_data.dart';
import '../../service/report_service.dart';
import '../../util/app_locale.dart';
import 'report_state.dart';

final _log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

/// 리포트 Cubit.
///
/// RecipeCubit + IngredientCubit 의 스트림을 구독해 데이터 변경 시 자동 갱신.
/// 150ms 디바운스로 cascade burst 를 1회로 합침.
class ReportCubit extends Cubit<ReportState> {
  final RecipeRepository _recipeRepository;
  final IngredientRepository _ingredientRepository;
  final RecipePriceHistoryRepository _historyRepository;
  final UnitRepository _unitRepository;

  ReportPeriod _period = ReportPeriod.monthly;
  DateTime? _anchorMonth; // monthly 모드에서 고른 월의 1일 (null = 현재 월)
  StreamSubscription<RecipeState>? _recipeSub;
  StreamSubscription<IngredientState>? _ingredientSub;
  StreamSubscription<AppLocale>? _localeSub;
  Timer? _debounceTimer;

  ReportCubit({
    required RecipeRepository recipeRepository,
    required IngredientRepository ingredientRepository,
    required RecipePriceHistoryRepository historyRepository,
    required UnitRepository unitRepository,
    required RecipeCubit recipeCubit,
    required IngredientCubit ingredientCubit,
    required LocaleCubit localeCubit,
  })  : _recipeRepository = recipeRepository,
        _ingredientRepository = ingredientRepository,
        _historyRepository = historyRepository,
        _unitRepository = unitRepository,
        super(const ReportInitial()) {
    _recipeSub = recipeCubit.stream.listen(_onRecipeState);
    _ingredientSub = ingredientCubit.stream.listen(_onIngredientState);
    _localeSub = localeCubit.stream.listen((_) => _scheduleRefresh());
  }

  // ---------------------------------------------------------------------------
  // Stream listeners
  // ---------------------------------------------------------------------------

  void _onRecipeState(RecipeState state) {
    if (state is RecipeLoaded ||
        state is RecipeAdded ||
        state is RecipeUpdated ||
        state is RecipeDeleted ||
        state is RecipeCostRecalculated) {
      _scheduleRefresh();
    }
  }

  void _onIngredientState(IngredientState state) {
    if (state is IngredientLoaded ||
        state is IngredientAdded ||
        state is IngredientUpdated ||
        state is IngredientDeleted ||
        state is IngredientTagsUpdated ||
        state is TagAddedToIngredient ||
        state is TagRemovedFromIngredient) {
      _scheduleRefresh();
    }
  }

  // ---------------------------------------------------------------------------
  // Debounce
  // ---------------------------------------------------------------------------

  void _scheduleRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), refresh);
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// 현재 기간으로 데이터를 새로 불러옴.
  Future<void> refresh() async {
    // 첫 로드 시에만 Loading 표시 (이후는 데이터 업데이트 시 flicker 방지)
    if (state is ReportInitial) {
      emit(const ReportLoading());
    }

    try {
      final now = _resolveAnchor();
      final since = now.subtract(Duration(days: _period.days));

      // 병렬 로드
      final results = await Future.wait([
        _recipeRepository.getAllRecipes(),
        _ingredientRepository.getAllIngredients(),
        _historyRepository.getAllPriceHistorySince(since),
        _unitRepository.getAllUnits(),
      ]);

      final recipes = results[0] as List;
      final ingredients = results[1] as List;
      final history = results[2] as List;
      final units = results[3] as List;

      // 원가율 시계열
      final series = ReportService.computeAvgCostRatioSeries(
        history: history.cast(),
        recipes: recipes.cast(),
        now: now,
        period: _period,
      );

      final (avgCostRatio, delta) = ReportService.computeAvgAndDelta(series);

      // 마진율 순위
      final marginRanking =
          ReportService.computeMarginRanking(recipes.cast(), topN: 0);

      // 비싼 재료 TOP 5
      final expensive = ReportService.computeTopExpensiveIngredients(
        ingredients: ingredients.cast(),
        units: units.cast(),
        topN: 5,
      );

      final data = ReportData(
        costRatioSeries: series,
        avgCostRatio: avgCostRatio,
        deltaVsPrevPct: delta,
        marginRanking: marginRanking,
        expensiveIngredients: expensive,
        hasHistory: history.isNotEmpty,
      );

      emit(ReportLoaded(
        data: data,
        period: _period,
        anchorMonth: _period == ReportPeriod.monthly ? _anchorMonth : null,
      ));
    } catch (e, st) {
      _log.e('[ReportCubit] refresh error', error: e, stackTrace: st);
      emit(ReportError(e.toString()));
    }
  }

  /// 조회 기간 변경 → 즉시 refresh.
  /// monthly 외 period 로 전환 시 anchor month reset.
  void changePeriod(ReportPeriod period) {
    if (_period == period) return;
    _period = period;
    if (period != ReportPeriod.monthly) {
      _anchorMonth = null;
    }
    refresh();
  }

  /// monthly 모드 anchor month 변경. null = 현재 월.
  void changeAnchorMonth(DateTime? month) {
    final normalized =
        month == null ? null : DateTime(month.year, month.month, 1);
    if (_anchorMonth == normalized) return;
    _anchorMonth = normalized;
    refresh();
  }

  /// _anchorMonth 가 있으면 그 월의 마지막 날 23:59:59 를 기준 시각으로 사용.
  DateTime _resolveAnchor() {
    if (_period != ReportPeriod.monthly || _anchorMonth == null) {
      return DateTime.now();
    }
    final next = DateTime(_anchorMonth!.year, _anchorMonth!.month + 1, 1);
    return next.subtract(const Duration(seconds: 1));
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await _recipeSub?.cancel();
    await _ingredientSub?.cancel();
    await _localeSub?.cancel();
    return super.close();
  }

  // ---------------------------------------------------------------------------
  // Palette (차트 / 비싼 재료 막대 색상)
  // ---------------------------------------------------------------------------

  /// 리포트 시각화용 색상 팔레트. index 기반으로 사용.
  static const List<Color> palette = [
    Color(0xFF0066FF), // primary blue
    Color(0xFF49E57D), // green
    Color(0xFFFFA938), // orange
    Color(0xFFFF4242), // red
    Color(0xFF7D5EF7), // violet
    Color(0xFF28D0ED), // cyan
  ];
}
