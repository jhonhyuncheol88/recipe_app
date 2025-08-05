import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../widget/index.dart';
import '../../../controller/ingredient/ingredient_cubit.dart';
import '../../../controller/ingredient/ingredient_state.dart';
import '../../../model/ingredient.dart';

/// 재료 메인 페이지
class IngredientMainPage extends StatefulWidget {
  const IngredientMainPage({super.key});

  @override
  State<IngredientMainPage> createState() => _IngredientMainPageState();
}

class _IngredientMainPageState extends State<IngredientMainPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedIngredients = {};
  String _selectedFilter = '전체';

  // 필터 옵션
  final List<String> _filterOptions = ['전체', '냉장', '냉동', '실온'];

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 재료 목록 가져오기
    context.read<IngredientCubit>().loadIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppStrings.getIngredientManagement(AppLocale.korea),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: _cancelSelection,
              child: Text(
                AppStrings.getCancelSelection(AppLocale.korea),
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: _toggleSelectionMode,
              icon: const Icon(
                Icons.select_all,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      body: BlocBuilder<IngredientCubit, IngredientState>(
        builder: (context, ingredientState) {
          return Column(
            children: [
              if (_isSelectionMode) _buildSelectionHeader(),
              _buildFilterSection(),
              Expanded(child: _buildIngredientList(ingredientState)),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSelectionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primaryLight,
      child: Row(
        children: [
          Text(
            AppStrings.getSelectedCount(
              AppLocale.korea,
              _selectedIngredients.length,
            ),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (_selectedIngredients.isNotEmpty)
            AppButton(
              text: AppStrings.getCreateRecipeFromIngredients(AppLocale.korea),
              type: AppButtonType.success,
              size: AppButtonSize.small,
              onPressed: _createRecipeFromIngredients,
            ),
        ],
      ),
    );
  }

  Widget _buildIngredientList(IngredientState state) {
    if (state is IngredientLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is IngredientEmpty) {
      return IngredientEmptyState(
        // onScanPressed: _scanReceipt,
        onAddPressed: _addIngredient,
      );
    }

    if (state is IngredientError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
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
              text: '다시 시도',
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

      if (ingredients.isEmpty) {
        return IngredientEmptyState(
          // onScanPressed: _scanReceipt,
          onAddPressed: _addIngredient,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];

          if (_isSelectionMode) {
            final isSelected = _selectedIngredients.contains(ingredient.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSelectableIngredientCard(ingredient, isSelected),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildIngredientCard(ingredient),
            );
          }
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    return GestureDetector(
      onTap: () => _editIngredient(ingredient),
      onLongPress: () => _showIngredientDetailBottomSheet(ingredient),
      child: IngredientCard(
        name: ingredient.name,
        price: ingredient.purchasePrice,
        amount: ingredient.purchaseAmount,
        unit: ingredient.purchaseUnitId,
      ),
    );
  }

  Widget _buildSelectableIngredientCard(
    Ingredient ingredient,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _toggleIngredientSelection(ingredient.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.accent, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            IngredientCard(
              name: ingredient.name,
              price: ingredient.purchasePrice,
              amount: ingredient.purchaseAmount,
              unit: ingredient.purchaseUnitId,
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_isSelectionMode) {
      if (_selectedIngredients.isEmpty) {
        return const SizedBox.shrink();
      }

      return FloatingActionButton.extended(
        heroTag: 'ingredient_create_recipe_button',
        onPressed: _createRecipeFromIngredients,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.buttonText,
        icon: const Icon(Icons.restaurant_menu),
        label: Text(
          AppStrings.getCreateRecipeFromIngredients(AppLocale.korea),
          style: AppTextStyles.buttonMedium,
        ),
      );
    }

    return FloatingActionButton.extended(
      heroTag: 'ingredient_add_button',
      onPressed: _addIngredient,
      backgroundColor: AppColors.buttonPrimary,
      foregroundColor: AppColors.buttonText,
      icon: const Icon(Icons.add),
      label: Text(
        AppStrings.getAddIngredient(AppLocale.korea),
        style: AppTextStyles.buttonMedium,
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIngredients.clear();
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedIngredients.clear();
    });
  }

  void _toggleIngredientSelection(String ingredientId) {
    setState(() {
      if (_selectedIngredients.contains(ingredientId)) {
        _selectedIngredients.remove(ingredientId);
      } else {
        _selectedIngredients.add(ingredientId);
      }
    });
  }

  void _createRecipeFromIngredients() {
    if (_selectedIngredients.isEmpty) return;

    // 선택된 재료들의 실제 데이터를 가져오기
    final currentState = context.read<IngredientCubit>().state;
    if (currentState is IngredientLoaded) {
      final selectedIngredientsData = currentState.ingredients
          .where((ingredient) => _selectedIngredients.contains(ingredient.id))
          .toList();

      // 선택 모드 종료
      _cancelSelection();

      // 레시피 생성 페이지로 이동
      context.push(
        '/recipe/create',
        extra: {
          'selectedIngredients': selectedIngredientsData,
          'animateFromIngredients': true,
        },
      );
    }
  }

  void _scanReceipt() {
    // TODO: OCR 스캔 기능 구현
    context.push('/scan-receipt');
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

  /// 재료 추가 후 애니메이션 시작 (향후 구현 예정)
  void _startIngredientAnimation(Ingredient ingredient) {
    // TODO: 애니메이션 기능 구현
  }

  void _viewIngredient(Ingredient ingredient) {
    _editIngredient(ingredient);
  }

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

  /// 재료 볼 터치 처리 (향후 구현 예정)
  void _onIngredientBallTapped(
    String ingredientId,
    List<Ingredient> ingredients,
  ) {
    final ingredient = ingredients.firstWhere((i) => i.id == ingredientId);
    _editIngredient(ingredient);
  }

  /// 재료 볼 길게 누름 처리 (향후 구현 예정)
  void _onIngredientBallLongPressed(
    String ingredientId,
    List<Ingredient> ingredients,
  ) {
    // TODO: 애니메이션 볼 길게 누름 기능 구현
  }

  /// 재료 볼 위치 저장 처리 (향후 구현 예정)
  void _onIngredientPositionSaved(Ingredient updatedIngredient) {
    // TODO: 데이터베이스에 위치 정보 저장
  }
}
