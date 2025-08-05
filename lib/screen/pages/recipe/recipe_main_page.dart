import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../util/number_formatter.dart';
import '../../widget/index.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/recipe/recipe_state.dart';
import '../../../model/recipe.dart';

/// 레시피 메인 페이지
class RecipeMainPage extends StatefulWidget {
  const RecipeMainPage({super.key});

  @override
  State<RecipeMainPage> createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage> {
  bool _isSelectionMode = false;
  final Set<String> _selectedRecipes = {};
  String _selectedFilter = '전체';
  final TextEditingController _searchController = TextEditingController();

  // 필터 옵션
  final List<String> _filterOptions = ['전체', '빵', '케이크', '쿠키', '기타'];

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 레시피 목록 가져오기
    context.read<RecipeCubit>().loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 레시피의 재료 정보 계산
  Map<String, dynamic> _calculateRecipeInfo(Recipe recipe) {
    final ingredientCount = recipe.ingredients.length;
    double totalWeight = 0.0;
    String weightUnit = 'g';

    // 모든 재료의 투입량을 g 단위로 변환
    for (final ingredient in recipe.ingredients) {
      // 단위별 변환 (간단한 예시)
      switch (ingredient.unitId) {
        case 'g':
          totalWeight += ingredient.amount;
          break;
        case 'kg':
          totalWeight += ingredient.amount * 1000;
          break;
        case 'ml':
          totalWeight += ingredient.amount; // ml를 g으로 간주
          break;
        case 'L':
          totalWeight += ingredient.amount * 1000;
          break;
        case '개':
        case '조각':
          totalWeight += ingredient.amount * 50; // 개당 50g으로 간주
          break;
        default:
          totalWeight += ingredient.amount;
      }
    }

    // 1kg 이상이면 kg 단위로 표시
    if (totalWeight >= 1000) {
      totalWeight = totalWeight / 1000;
      weightUnit = 'kg';
    }

    return {
      'ingredientCount': ingredientCount,
      'totalWeight': totalWeight,
      'weightUnit': weightUnit,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          AppStrings.getRecipeManagement(AppLocale.korea),
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
      body: BlocBuilder<RecipeCubit, RecipeState>(
        builder: (context, recipeState) {
          return Column(
            children: [
              if (_isSelectionMode) _buildSelectionHeader(),
              _buildSearchSection(),
              _buildFilterSection(),
              Expanded(child: _buildRecipeList(recipeState)),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AppInputField(
        label: AppStrings.getSearchRecipe(AppLocale.korea),
        hint: AppStrings.getSearchRecipeHint(AppLocale.korea),
        controller: _searchController,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        onChanged: (value) {
          context.read<RecipeCubit>().searchRecipes(value);
        },
      ),
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
                selectedColor: AppColors.accent.withOpacity(0.2),
                checkmarkColor: AppColors.accent,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? AppColors.accent
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
          Icon(Icons.check_circle, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            '${_selectedRecipes.length}개 선택됨',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _deleteSelectedRecipes,
            child: Text(
              AppStrings.getDeleteSelected(AppLocale.korea),
              style: AppTextStyles.buttonSmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(RecipeState state) {
    if (state is RecipeLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is RecipeEmpty) {
      return RecipeEmptyState();
    }

    if (state is RecipeError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: AppStrings.getRetry(AppLocale.korea),
              type: AppButtonType.primary,
              onPressed: () {
                context.read<RecipeCubit>().loadRecipes();
              },
            ),
          ],
        ),
      );
    }

    List<Recipe> recipes = [];
    if (state is RecipeLoaded) {
      recipes = state.recipes;
    } else if (state is RecipeSearchResult) {
      recipes = state.recipes;
    } else if (state is RecipeFilteredByTag) {
      recipes = state.recipes;
    } else if (state is RecipeFilteredByTags) {
      recipes = state.recipes;
    }

    if (recipes.isEmpty) {
      return RecipeEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final isSelected = _selectedRecipes.contains(recipe.id);

        final recipeInfo = _calculateRecipeInfo(recipe);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RecipeCard(
            name: recipe.name,
            description: recipe.description,
            totalCost: recipe.totalCost,
            ingredientCount: recipeInfo['ingredientCount'],
            totalWeight: recipeInfo['totalWeight'],
            weightUnit: recipeInfo['weightUnit'],
            isSelected: isSelected,
            onTap: () => _viewRecipe(recipe),
            onEdit: () => _editRecipe(recipe),
            onDelete: () => _deleteRecipe(recipe),
            onLongPress: () => _toggleRecipeSelection(recipe.id),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    if (_isSelectionMode) {
      return FloatingActionButton(
        heroTag: 'recipe_delete_button',
        onPressed: _deleteSelectedRecipes,
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.buttonText,
        child: const Icon(Icons.delete),
      );
    }

    return FloatingActionButton.extended(
      heroTag: 'recipe_add_button',
      onPressed: _addRecipe,
      backgroundColor: AppColors.buttonPrimary,
      foregroundColor: AppColors.buttonText,
      icon: const Icon(Icons.add),
      label: Text(
        AppStrings.getAddRecipeButton(AppLocale.korea),
        style: AppTextStyles.buttonMedium,
      ),
    );
  }

  void _applyFilter(String filter) {
    if (filter == '전체') {
      context.read<RecipeCubit>().loadRecipes();
    } else {
      // TODO: 태그 기반 필터링 구현
      // context.read<RecipeCubit>().filterRecipesByTag(filter);
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedRecipes.clear();
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedRecipes.clear();
    });
  }

  void _toggleRecipeSelection(String recipeId) {
    setState(() {
      if (_selectedRecipes.contains(recipeId)) {
        _selectedRecipes.remove(recipeId);
      } else {
        _selectedRecipes.add(recipeId);
      }
    });
  }

  void _addRecipe() {
    context.push('/recipe/create');
  }

  void _editRecipe(Recipe recipe) {
    context.push('/recipe/edit', extra: recipe);
  }

  void _viewRecipe(Recipe recipe) {
    context.push('/recipe/detail', extra: recipe);
  }

  void _deleteRecipe(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getDeleteRecipe(AppLocale.korea)),
        content: Text(
          '${recipe.name} ${AppStrings.getDeleteRecipeConfirm(AppLocale.korea)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(AppLocale.korea)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<RecipeCubit>().deleteRecipe(recipe.id);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 중 오류가 발생했습니다: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppStrings.getDelete(AppLocale.korea),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedRecipes() {
    if (_selectedRecipes.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getDeleteSelectedRecipes(AppLocale.korea)),
        content: Text('${_selectedRecipes.length}개의 레시피를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(AppLocale.korea)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                for (final recipeId in _selectedRecipes) {
                  await context.read<RecipeCubit>().deleteRecipe(recipeId);
                }
                _cancelSelection();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 중 오류가 발생했습니다: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppStrings.getDelete(AppLocale.korea),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _scanReceipt() {
    context.push('/scan-receipt');
  }
}
