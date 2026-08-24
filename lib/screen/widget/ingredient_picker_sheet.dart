import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controller/ingredient/ingredient_cubit.dart';
import '../../controller/ingredient/ingredient_state.dart';
import '../../controller/setting/locale_cubit.dart';
import '../../model/ingredient.dart';
import '../../theme/tokens/tokens.dart';
import '../../util/app_strings.dart';
import 'segment_control.dart';

/// 재료 선택 바텀 시트.
///
/// 이미 선택된 재료는 [excludeIds] 로 전달해서 목록에서 제외한다.
/// 사용자가 한 항목을 탭하면 해당 [Ingredient] 가 반환되고, X 또는
/// 바깥 영역을 탭해 닫으면 `null` 이 반환된다.
Future<Ingredient?> showIngredientPickerSheet(
  BuildContext context, {
  required List<String> excludeIds,
}) {
  final tokens = AppColorTokens.of(context);
  return showModalBottomSheet<Ingredient>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: tokens.fgStrong.withValues(alpha: 0.4),
    builder: (sheetCtx) {
      return _IngredientPickerSheet(excludeIds: excludeIds);
    },
  );
}

class _IngredientPickerSheet extends StatefulWidget {
  final List<String> excludeIds;

  const _IngredientPickerSheet({required this.excludeIds});

  @override
  State<_IngredientPickerSheet> createState() => _IngredientPickerSheetState();
}

class _IngredientPickerSheetState extends State<_IngredientPickerSheet> {
  bool _favoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

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

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    final locale = context.read<LocaleCubit>().state;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetCtx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: tokens.bgBase,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.r20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // 드래그 핸들
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.s8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.borderDefault,
                      borderRadius: AppRadius.brPill,
                    ),
                  ),
                ),
                // 타이틀 + X 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s12,
                    AppSpacing.s8,
                    AppSpacing.s8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.getSelectIngredientSheet(locale),
                          style: AppTypography.heading2.copyWith(
                            color: tokens.fgStrong,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: tokens.fgSecondary),
                        tooltip: AppStrings.getClose(locale),
                      ),
                    ],
                  ),
                ),
                // 검색 필드 + 전체 / 즐겨찾기 탭
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    0,
                    AppSpacing.s20,
                    AppSpacing.s8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: tokens.bgMuted,
                            borderRadius: AppRadius.brR12,
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) =>
                                setState(() => _query = v.trim()),
                            style: AppTypography.label1.copyWith(
                              color: tokens.fgStrong,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  AppStrings.getSearchIngredientHint(locale),
                              hintStyle: AppTypography.label1.copyWith(
                                color: tokens.fgTertiary,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 18,
                                color: tokens.fgTertiary,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 38,
                                minHeight: 38,
                              ),
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                      child: Icon(
                                        Icons.cancel,
                                        size: 16,
                                        color: tokens.fgTertiary,
                                      ),
                                    ),
                              suffixIconConstraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 38,
                              ),
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.s12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      IntrinsicWidth(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 132),
                          child: SegmentControl<bool>(
                            items: [
                              SegmentItem(
                                value: false,
                                label: AppStrings.getAll(locale),
                              ),
                              SegmentItem(
                                value: true,
                                label: AppStrings.getFavorites(locale),
                              ),
                            ],
                            selected: _favoritesOnly,
                            onChanged: (v) =>
                                setState(() => _favoritesOnly = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocBuilder<IngredientCubit, IngredientState>(
                    builder: (ctx, state) {
                      if (state is IngredientLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final all = _ingredientsOf(state);
                      final query = _query.toLowerCase();
                      final visible = all
                          .where((i) => !widget.excludeIds.contains(i.id))
                          .where((i) => !_favoritesOnly || i.isFavorite)
                          .where((i) =>
                              query.isEmpty ||
                              i.name.toLowerCase().contains(query))
                          .toList();

                      if (visible.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.s24),
                            child: Text(
                              query.isNotEmpty
                                  ? AppStrings.getNoSearchResults(locale)
                                  : _favoritesOnly
                                      ? AppStrings
                                          .getNoFavoriteIngredients(locale)
                                      : '추가할 재료가 없습니다',
                              style: AppTypography.body2.copyWith(
                                color: tokens.fgTertiary,
                              ),
                            ),
                          ),
                        );
                      }

                      return GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s20,
                          AppSpacing.s4,
                          AppSpacing.s20,
                          AppSpacing.s24,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          mainAxisExtent: 44,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (_, index) {
                          final ing = visible[index];
                          return _IngredientCell(
                            name: ing.name,
                            onTap: () => Navigator.of(context).pop(ing),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IngredientCell extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _IngredientCell({
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);
    return Material(
      color: tokens.bgMuted,
      borderRadius: AppRadius.brR12,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.brR12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.headline2.copyWith(
                    color: tokens.fgStrong,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.s4),
              Icon(Icons.add, color: tokens.primary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
