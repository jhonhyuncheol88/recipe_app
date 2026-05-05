import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../model/ingredient.dart';
import '../../../router/index.dart';
import '../../../theme/tokens/tokens.dart';
import '../../../util/app_locale.dart';
import '../../../util/app_strings.dart';
import '../../../util/number_format_style.dart';
import '../../../util/number_formatter.dart';
import '../../widget/ingredient_list_tile.dart';
import '../../widget/ingredient_tag_chip.dart';

enum _SortMode { expirySoonest, newest, priceHigh, priceLow, nameAsc }

const _allTagId = 'all';

/// 재료 메인 페이지 — 신규 디자인.
class IngredientMainPage extends StatefulWidget {
  const IngredientMainPage({super.key});

  @override
  State<IngredientMainPage> createState() => _IngredientMainPageState();
}

class _IngredientMainPageState extends State<IngredientMainPage> {
  String _selectedTag = _allTagId;
  String _searchQuery = '';
  _SortMode _sortMode = _SortMode.expirySoonest;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<IngredientCubit>().loadIngredients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Ingredient> _ingredientsOf(IngredientState state) {
    if (state is IngredientLoaded) return state.ingredients;
    if (state is IngredientFilteredByTag) return state.ingredients;
    if (state is IngredientFilteredByTags) return state.ingredients;
    if (state is IngredientFilteredByExpiry) return state.ingredients;
    if (state is IngredientSearchResult) return state.ingredients;
    if (state is IngredientAdded) return state.ingredients;
    if (state is IngredientUpdated) return state.ingredients;
    if (state is IngredientDeleted) return state.ingredients;
    return const [];
  }

  List<Ingredient> _filteredAndSorted(List<Ingredient> all) {
    Iterable<Ingredient> result = all;

    if (_selectedTag != _allTagId) {
      result = result.where((i) => i.tagIds.contains(_selectedTag));
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where(
        (i) =>
            i.name.toLowerCase().contains(query) ||
            i.purchaseUnitId.toLowerCase().contains(query),
      );
    }

    final list = result.toList();
    switch (_sortMode) {
      case _SortMode.expirySoonest:
        list.sort((a, b) {
          final ax = a.expiryDate;
          final bx = b.expiryDate;
          if (ax == null && bx == null) return a.name.compareTo(b.name);
          if (ax == null) return 1;
          if (bx == null) return -1;
          return ax.compareTo(bx);
        });
        break;
      case _SortMode.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortMode.priceHigh:
        list.sort((a, b) => b.purchasePrice.compareTo(a.purchasePrice));
        break;
      case _SortMode.priceLow:
        list.sort((a, b) => a.purchasePrice.compareTo(b.purchasePrice));
        break;
      case _SortMode.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }

  String _sortLabel(AppLocale locale) {
    switch (_sortMode) {
      case _SortMode.expirySoonest:
        return AppStrings.getSortExpirySoonest(locale);
      case _SortMode.newest:
        return AppStrings.getSortNewest(locale);
      case _SortMode.priceHigh:
        return AppStrings.getSortPriceHigh(locale);
      case _SortMode.priceLow:
        return AppStrings.getSortPriceLow(locale);
      case _SortMode.nameAsc:
        return AppStrings.getSortNameAsc(locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.watch<LocaleCubit>().state;
    final formatStyle = context.watch<NumberFormatCubit>().state;

    return Scaffold(
      backgroundColor: tokens.bgBase,
      appBar: AppBar(
        backgroundColor: tokens.bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            onPressed: () => RouterHelper.goToOcrMain(context),
            icon: Icon(Icons.receipt_long_outlined, color: tokens.fgStrong),
            tooltip: AppStrings.getScanReceipt(locale),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: AppSpacing.s16,
              left: AppSpacing.s4,
            ),
            child: _RegisterPillButton(
              label: AppStrings.getRegister(locale),
              onPressed: () => context.push(AppRouter.ingredientAdd),
            ),
          ),
        ],
      ),
      body: BlocBuilder<IngredientCubit, IngredientState>(
        builder: (context, state) {
          final allIngredients = _ingredientsOf(state);
          final visible = _filteredAndSorted(allIngredients);
          final isLoading = state is IngredientLoading;
          final isError = state is IngredientError;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s20,
                  AppSpacing.s8,
                  AppSpacing.s20,
                  AppSpacing.s12,
                ),
                child: _Header(
                  ingredients: allIngredients,
                  locale: locale,
                  formatStyle: formatStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s20,
                ),
                child: _SearchField(
                  controller: _searchController,
                  hint: AppStrings.getSearchIngredientHint(locale),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              _FilterChipsRow(
                selectedTag: _selectedTag,
                locale: locale,
                onSelect: (tag) => setState(() => _selectedTag = tag),
              ),
              const SizedBox(height: AppSpacing.s12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: tokens.bgElev2,
                  child: Column(
                    children: [
                      if (allIngredients.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.s20,
                            AppSpacing.s12,
                            AppSpacing.s20,
                            AppSpacing.s4,
                          ),
                          child: _SortBar(
                            label: _sortLabel(locale),
                            onTap: () => _showSortSheet(context, locale),
                          ),
                        ),
                      Expanded(
                        child: _Body(
                          isLoading: isLoading,
                          isError: isError,
                          errorMessage: isError ? state.message : null,
                          allCount: allIngredients.length,
                          visible: visible,
                          searchQuery: _searchQuery,
                          selectedTag: _selectedTag,
                          locale: locale,
                          formatStyle: formatStyle,
                          onTapIngredient: _openDetail,
                          onAdd: () =>
                              context.push(AppRouter.ingredientAdd),
                          onRetry: () => context
                              .read<IngredientCubit>()
                              .loadIngredients(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openDetail(Ingredient ingredient) {
    context.push(AppRouter.ingredientDetail, extra: ingredient);
  }

  Future<void> _showSortSheet(BuildContext context, AppLocale locale) async {
    final tokens = AppColorTokens.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.bgBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
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
                for (final mode in _SortMode.values)
                  _SortOptionTile(
                    label: _labelFor(mode, locale),
                    selected: mode == _sortMode,
                    onTap: () {
                      setState(() => _sortMode = mode);
                      Navigator.of(sheetCtx).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _labelFor(_SortMode mode, AppLocale locale) {
    switch (mode) {
      case _SortMode.expirySoonest:
        return AppStrings.getSortExpirySoonest(locale);
      case _SortMode.newest:
        return AppStrings.getSortNewest(locale);
      case _SortMode.priceHigh:
        return AppStrings.getSortPriceHigh(locale);
      case _SortMode.priceLow:
        return AppStrings.getSortPriceLow(locale);
      case _SortMode.nameAsc:
        return AppStrings.getSortNameAsc(locale);
    }
  }
}

class _RegisterPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _RegisterPillButton({required this.label, required this.onPressed});

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
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18, color: tokens.fgOnPrimary),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.label1.copyWith(
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

class _Header extends StatelessWidget {
  final List<Ingredient> ingredients;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;

  const _Header({
    required this.ingredients,
    required this.locale,
    required this.formatStyle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final count = ingredients.length;
    final total = ingredients.fold<double>(
      0,
      (sum, i) => sum + i.purchasePrice,
    );
    final countText =
        NumberFormatter.formatQuantity(count, locale, formatStyle);
    final totalText =
        '${AppStrings.getTotal(locale)} ${NumberFormatter.formatCurrency(total, locale, formatStyle)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getIngredients(locale),
          style: AppTypography.display3.copyWith(color: tokens.fgStrong),
        ),
        const SizedBox(height: 4),
        Text(
          '$countText · $totalText',
          style: AppTypography.label1.copyWith(color: tokens.fgTertiary),
        ),
      ],
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
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close, color: tokens.fgTertiary, size: 20),
                onPressed: onClear,
              ),
        filled: true,
        fillColor: tokens.bgBase,
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

class _FilterChipsRow extends StatelessWidget {
  final String selectedTag;
  final AppLocale locale;
  final ValueChanged<String> onSelect;

  const _FilterChipsRow({
    required this.selectedTag,
    required this.locale,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      (_allTagId, AppStrings.getAll(locale)),
      (
        IngredientTagPalette.fresh,
        AppStrings.getIngredientTagFresh(locale),
      ),
      (
        IngredientTagPalette.frozen,
        AppStrings.getIngredientTagFrozen(locale),
      ),
      (
        IngredientTagPalette.indoor,
        AppStrings.getIngredientTagIndoor(locale),
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
      child: Row(
        children: [
          for (final entry in entries) ...[
            IngredientSelectableChip(
              label: entry.$2,
              selected: selectedTag == entry.$1,
              onTap: () => onSelect(entry.$1),
            ),
            if (entry != entries.last) const SizedBox(width: AppSpacing.s8),
          ],
        ],
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

class _Body extends StatelessWidget {
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final int allCount;
  final List<Ingredient> visible;
  final String searchQuery;
  final String selectedTag;
  final AppLocale locale;
  final NumberFormatStyle formatStyle;
  final ValueChanged<Ingredient> onTapIngredient;
  final VoidCallback onAdd;
  final VoidCallback onRetry;

  const _Body({
    required this.isLoading,
    required this.isError,
    required this.errorMessage,
    required this.allCount,
    required this.visible,
    required this.searchQuery,
    required this.selectedTag,
    required this.locale,
    required this.formatStyle,
    required this.onTapIngredient,
    required this.onAdd,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);

    if (isLoading && visible.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 56, color: tokens.negative),
              const SizedBox(height: AppSpacing.s12),
              Text(
                AppStrings.getErrorOccurred(locale),
                style:
                    AppTypography.heading2.copyWith(color: tokens.fgStrong),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.s8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTypography.body2
                      .copyWith(color: tokens.fgSecondary),
                ),
              ],
              const SizedBox(height: AppSpacing.s16),
              FilledButton(
                onPressed: onRetry,
                child: Text(AppStrings.getRetry(locale)),
              ),
            ],
          ),
        ),
      );
    }

    if (visible.isEmpty) {
      final isSearching =
          searchQuery.isNotEmpty || selectedTag != _allTagId;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSearching ? Icons.search_off : Icons.inventory_2_outlined,
                size: 56,
                color: tokens.fgDisabled,
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                isSearching
                    ? AppStrings.getNoSearchResults(locale)
                    : AppStrings.getNoIngredients(locale),
                style:
                    AppTypography.heading2.copyWith(color: tokens.fgStrong),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                isSearching
                    ? AppStrings.getTryDifferentKeyword(locale)
                    : AppStrings.getNoIngredientsDescription(locale),
                textAlign: TextAlign.center,
                style:
                    AppTypography.body2.copyWith(color: tokens.fgSecondary),
              ),
              if (!isSearching && allCount == 0) ...[
                const SizedBox(height: AppSpacing.s20),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: Text(AppStrings.getAddIngredient(locale)),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s8,
        AppSpacing.s20,
        AppSpacing.s24,
      ),
      itemCount: visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s8),
      itemBuilder: (context, index) {
        final ingredient = visible[index];
        return IngredientListTile(
          ingredient: ingredient,
          locale: locale,
          formatStyle: formatStyle,
          onTap: () => onTapIngredient(ingredient),
        );
      },
    );
  }
}
