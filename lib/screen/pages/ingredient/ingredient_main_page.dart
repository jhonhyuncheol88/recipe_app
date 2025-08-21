import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
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
import '../../../router/router_helper.dart';

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
  String _searchQuery = ''; // 검색 쿼리 추가

  // 필터 옵션
  final List<String> _filterOptions = ['전체', '냉장', '냉동', '실온'];

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 재료 목록 가져오기
    context.read<IngredientCubit>().loadIngredients();
    // 소스 목록도 초기 로드
    context.read<SauceCubit>().loadSauces();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppStrings.getIngredientManagement(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => RouterHelper.goToOcrMain(context),
            icon: Icon(
              Icons.receipt_long,
              color: AppColors.textLight,
              size: 20,
            ),
            label: Text(
              AppStrings.getScanReceipt(currentLocale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
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
    final Map<String, String> localized = {
      '전체': AppStrings.getAll(currentLocale),
      '냉장': AppStrings.getIngredientTagFresh(currentLocale),
      '냉동': AppStrings.getIngredientTagFrozen(currentLocale),
      '실온': AppStrings.getIngredientTagIndoor(currentLocale),
    };
    return Column(
      children: [
        // 검색바 추가
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: '재료 검색...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
        ),
        // 기존 필터 칩들
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.buttonText
                          : AppColors.textSecondary,
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
      ],
    );
  }

  Widget _buildSauceTab() {
    return BlocBuilder<SauceCubit, SauceState>(
      builder: (context, state) {
        final currentLocale = context.watch<LocaleCubit>().state;
        if (state is SauceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SauceEmpty) {
          return Center(
            child: Text(
              AppStrings.getNoSauces(currentLocale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        if (state is SauceError) {
          return Center(child: Text(state.message));
        }
        if (state is SauceLoaded) {
          final sauces = state.sauces;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sauces.length,
            itemBuilder: (context, index) {
              final sauce = sauces[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(sauce.name, style: AppTextStyles.bodyMedium),
                  subtitle: Text(
                    '${AppStrings.getTotalWeight(currentLocale)}: ${NumberFormatter.formatNumber(sauce.totalWeight.toInt(), currentLocale)} | ${AppStrings.getTotalCost(currentLocale)}: ${NumberFormatter.formatCurrency(sauce.totalCost, currentLocale)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
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
    return FloatingActionButton.extended(
      heroTag: 'sauce_add_button',
      onPressed: _createSauce,
      backgroundColor: AppColors.buttonPrimary,
      foregroundColor: AppColors.buttonText,
      icon: const Icon(Icons.add),
      label: Text(AppStrings.getAddSauceButton(currentLocale)),
    );
  }

  void _createSauce() async {
    final currentLocale = context.read<LocaleCubit>().state;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getEnterSauceName(currentLocale)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppStrings.getSauceNameExample(currentLocale),
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

  // 선택 모드 제거됨

  Widget _buildIngredientList(IngredientState state) {
    if (state is IngredientLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is IngredientEmpty) {
      return const IngredientEmptyState();
    }

    if (state is IngredientError) {
      final currentLocale = context.watch<LocaleCubit>().state;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.getErrorOccurred(currentLocale),
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
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

      // 검색 필터링 적용
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
          // 검색 결과가 없는 경우
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  '검색 결과가 없습니다',
                  style: AppTextStyles.headline4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '다른 검색어를 입력해보세요',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        } else {
          return const IngredientEmptyState();
        }
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
    // 단위당 가격 계산
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
        unitPrice: unitPrice, // 단위당 가격 추가
        expiryDate: ingredient.expiryDate, // 유통기한 추가
        locale: currentLocale, // 로컬화 지원 추가
      ),
    );
  }

  // 선택 모드 제거됨

  Widget _buildFloatingActionButton() {
    final currentLocale = context.watch<LocaleCubit>().state;
    return FloatingActionButton.extended(
      heroTag: 'ingredient_add_button',
      onPressed: _addIngredient,
      backgroundColor: AppColors.buttonPrimary,
      foregroundColor: AppColors.buttonText,
      icon: const Icon(Icons.add),
      label: Text(
        AppStrings.getAddIngredient(currentLocale),
        style: AppTextStyles.buttonMedium,
      ),
    );
  }

  // 선택 모드 제거됨: 토글/취소/선택 메서드 삭제

  // 선택 모드 제거됨: 레시피 만들기 관련 선택 동작 삭제

  // 사용 안 함: 인라인 피커로 대체됨

  // 선택 모드 제거됨: 인라인 소스 피커 삭제

  // 선택 모드 제거됨: 선택 재료를 소스에 추가하는 보조 함수 삭제

  // void _scanReceipt() {}

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

  // void _startIngredientAnimation(Ingredient ingredient) {}

  // void _viewIngredient(Ingredient ingredient) {}

  void _showIngredientDetailBottomSheet(Ingredient ingredient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 핸들 바
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 헤더
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2,
                        color: AppColors.primary,
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
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${ingredient.purchaseAmount} ${ingredient.purchaseUnitId}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 상세 정보
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
                          valueColor: AppColors.success,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.headline4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChips(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('재료 삭제'),
        content: Text('${ingredient.name}을(를) 삭제하시겠습니까?'),
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  // void _onIngredientBallTapped(String ingredientId, List<Ingredient> ingredients) {}

  // void _onIngredientBallLongPressed(String ingredientId, List<Ingredient> ingredients) {}

  // void _onIngredientPositionSaved(Ingredient updatedIngredient) {}
}
