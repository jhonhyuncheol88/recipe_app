import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../widget/index.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../controller/sauce/sauce_cubit.dart';
import '../../../controller/sauce/sauce_state.dart';
import '../../../model/ingredient.dart';
import '../../../model/index.dart';
import '../../../util/number_formatter.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../controller/setting/number_format_cubit.dart';
import '../../../controller/setting/view_mode_cubit.dart';
import '../../../router/index.dart';

/// 재료 메인 페이지
class IngredientMainPage extends StatefulWidget {
  const IngredientMainPage({super.key});

  @override
  State<IngredientMainPage> createState() => _IngredientMainPageState();
}

class _IngredientMainPageState extends State<IngredientMainPage>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = '전체';
  late final TabController _tabController;
  String _searchQuery = '';

  final List<String> _filterOptions = ['전체', '냉장', '냉동', '실온'];

  @override
  void initState() {
    super.initState();
    context.read<IngredientCubit>().loadIngredients();
    context.read<SauceCubit>().loadSauces();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppStrings.getIngredientManagement(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRouter.ingredientBatchEdit),
            icon: Icon(Icons.edit_note, color: colorScheme.onSurface),
            tooltip: '일괄 수정',
          ),
          TextButton.icon(
            onPressed: () => RouterHelper.goToOcrMain(context),
            icon: Icon(
              Icons.receipt_long,
              color: colorScheme.primary,
              size: 20,
            ),
            label: Text(
              AppStrings.getScanReceipt(currentLocale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorColor: colorScheme.primary,
          tabs: [
            Tab(text: AppStrings.getIngredients(currentLocale)),
            Tab(text: AppStrings.getSauces(currentLocale)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocBuilder<IngredientCubit, IngredientState>(
            builder: (context, ingredientState) {
              return Column(
                children: [
                  _buildFilterSection(),
                  Expanded(child: _buildIngredientList(ingredientState)),
                ],
              );
            },
          ),
          _buildSauceTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? _buildFloatingActionButton()
          : _buildSauceFab(),
    );
  }

  Widget _buildFilterSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    final Map<String, String> localized = {
      '전체': AppStrings.getAll(currentLocale),
      '냉장': AppStrings.getIngredientTagFresh(currentLocale),
      '냉동': AppStrings.getIngredientTagFrozen(currentLocale),
      '실온': AppStrings.getIngredientTagIndoor(currentLocale),
    };
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: AppStrings.getSearchIngredientHint(currentLocale),
              hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5)),
              prefixIcon: Icon(Icons.search,
                  color: colorScheme.onSurface.withValues(alpha: 0.5)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          color: colorScheme.onSurface.withValues(alpha: 0.5)),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
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
              filled: true,
              fillColor: colorScheme.surface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(localized[filter] ?? filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                            _applyFilter(filter);
                          },
                          backgroundColor: colorScheme.surface,
                          selectedColor:
                              colorScheme.primary.withValues(alpha: 0.2),
                          checkmarkColor: colorScheme.primary,
                          labelStyle: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              BlocBuilder<ViewModeCubit, IngredientViewMode>(
                builder: (context, viewMode) {
                  final isCompact = viewMode == IngredientViewMode.compact;
                  return IconButton(
                    icon: Icon(
                      isCompact ? Icons.grid_view : Icons.view_list,
                      color: isCompact
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    tooltip: isCompact
                        ? AppStrings.getSwitchToCard(currentLocale)
                        : AppStrings.getSwitchToCompact(currentLocale),
                    onPressed: () =>
                        context.read<ViewModeCubit>().toggle(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSauceTab() {
    return BlocBuilder<SauceCubit, SauceState>(
      builder: (context, state) {
        final currentLocale = context.watch<LocaleCubit>().state;
        final colorScheme = Theme.of(context).colorScheme;
        if (state is SauceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SauceEmpty) {
          return Center(
            child: Text(
              AppStrings.getNoSauces(currentLocale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          );
        }
        if (state is SauceError) {
          return Center(
              child: Text(state.message,
                  style: TextStyle(color: colorScheme.error)));
        }
        if (state is SauceLoaded) {
          final sauces = state.sauces;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sauces.length,
            itemBuilder: (context, index) {
              final sauce = sauces[index];
              return Card(
                color: colorScheme.surface,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: ListTile(
                  title: Text(sauce.name,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: colorScheme.onSurface)),
                  subtitle: Text(
                    '${AppStrings.getTotalWeight(currentLocale)}: ${NumberFormatter.formatNumber(sauce.totalWeight.toInt(), context.watch<NumberFormatCubit>().state)} | ${AppStrings.getTotalCost(currentLocale)}: ${NumberFormatter.formatCurrency(sauce.totalCost, currentLocale, context.watch<NumberFormatCubit>().state)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: Icon(Icons.chevron_right,
                      color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  onTap: () => context.push('/sauce/edit', extra: sauce),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSauceFab() {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      heroTag: 'sauce_add_button',
      onPressed: _createSauce,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      icon: const Icon(Icons.add),
      label: Text(AppStrings.getAddSauceButton(currentLocale)),
    );
  }

  void _createSauce() async {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    final controller = TextEditingController();
    if (!mounted) return;
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getEnterSauceName(currentLocale),
            style: TextStyle(color: colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: AppStrings.getSauceNameExample(currentLocale),
            hintStyle:
                TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getCancel(currentLocale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(AppStrings.getCreate(currentLocale)),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await context.read<SauceCubit>().addSauce(name: name);
      if (!mounted) return;
      final state = context.read<SauceCubit>().state;
      if (state is SauceAdded) {
        context.push('/sauce/edit', extra: state.sauce);
      }
    }
  }

  Widget _buildIngredientList(IngredientState state) {
    if (state is IngredientLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is IngredientEmpty) {
      return const IngredientEmptyState();
    }

    if (state is IngredientError) {
      final currentLocale = context.watch<LocaleCubit>().state;
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.getErrorOccurred(currentLocale),
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: AppStrings.getRetry(currentLocale),
              type: AppButtonType.primary,
              onPressed: () {
                context.read<IngredientCubit>().loadIngredients();
              },
            ),
          ],
        ),
      );
    }

    if (state is IngredientLoaded) {
      final ingredients = state.ingredients;
      final colorScheme = Theme.of(context).colorScheme;

      final filteredIngredients = _searchQuery.isEmpty
          ? ingredients
          : ingredients
              .where(
                (ingredient) =>
                    ingredient.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                    ingredient.purchaseUnitId.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
              )
              .toList();

      if (filteredIngredients.isEmpty) {
        if (_searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '검색 결과가 없습니다',
                  style: AppTextStyles.headline4.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '다른 검색어를 입력해보세요',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const IngredientEmptyState();
        }
      }

      final viewMode = context.watch<ViewModeCubit>().state;

      if (viewMode == IngredientViewMode.compact) {
        return IngredientCompactGrid(
          ingredients: filteredIngredients,
          onTap: _editIngredient,
          onLongPress: _showIngredientDetailBottomSheet,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredIngredients.length,
        itemBuilder: (context, index) {
          final ingredient = filteredIngredients[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildIngredientCard(ingredient),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    final unitPrice = ingredient.purchasePrice / ingredient.purchaseAmount;
    final currentLocale = context.watch<LocaleCubit>().state;

    return GestureDetector(
      onTap: () => _editIngredient(ingredient),
      onLongPress: () => _showIngredientDetailBottomSheet(ingredient),
      child: IngredientCard(
        name: ingredient.name,
        price: ingredient.purchasePrice,
        amount: ingredient.purchaseAmount,
        unit: ingredient.purchaseUnitId,
        unitPrice: unitPrice,
        expiryDate: ingredient.expiryDate,
        locale: currentLocale,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      heroTag: 'ingredient_add_button',
      onPressed: _addIngredient,
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      label: Text(
        AppStrings.getAddIngredient(currentLocale),
        style: AppTextStyles.buttonMedium,
      ),
    );
  }

  void _addIngredient() {
    context.push('/ingredient/add');
  }

  void _applyFilter(String filter) {
    switch (filter) {
      case '전체':
        context.read<IngredientCubit>().loadIngredients();
        break;
      case '냉장':
        context.read<IngredientCubit>().filterIngredientsByTag('fresh');
        break;
      case '냉동':
        context.read<IngredientCubit>().filterIngredientsByTag('frozen');
        break;
      case '실온':
        context.read<IngredientCubit>().filterIngredientsByTag('indoor');
        break;
    }
  }

  void _showIngredientDetailBottomSheet(Ingredient ingredient) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ingredient.name,
                            style: AppTextStyles.headline4.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ingredient.purchaseAmount} ${ingredient.purchaseUnitId}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('구매 정보', [
                        _buildDetailRow(
                          '구매 가격',
                          '₩${ingredient.purchasePrice}',
                        ),
                        _buildDetailRow(
                          '구매 수량',
                          '${ingredient.purchaseAmount} ${ingredient.purchaseUnitId}',
                        ),
                        _buildDetailRow(
                          '단위당 가격',
                          '₩${(ingredient.purchasePrice / ingredient.purchaseAmount).toStringAsFixed(0)}/${ingredient.purchaseUnitId}',
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('태그', [
                        _buildTagChips(['곡물', '베이킹']),
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailSection('유통기한', [
                        _buildDetailRow(
                          '만료일',
                          '2024년 12월 31일',
                          valueColor: colorScheme.primary,
                        ),
                      ]),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: '수정',
                              type: AppButtonType.primary,
                              onPressed: () {
                                Navigator.of(context).pop();
                                _editIngredient(ingredient);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: '삭제',
                              type: AppButtonType.secondary,
                              onPressed: () {
                                Navigator.of(context).pop();
                                _deleteIngredient(ingredient);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headline4.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChips(List<String> tags) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _editIngredient(Ingredient ingredient) {
    context.push('/ingredient/edit', extra: ingredient);
  }

  void _deleteIngredient(Ingredient ingredient) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('재료 삭제', style: TextStyle(color: colorScheme.onSurface)),
        content: Text('${ingredient.name}을(를) 삭제하시겠습니까?',
            style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<IngredientCubit>().deleteIngredient(ingredient.id);
            },
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
