import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../widget/index.dart';
import '../../widget/recipe_quick_view_dialog.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/recipe/recipe_state.dart';
import '../../../model/recipe.dart';
import '../../../model/tag.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../router/router_helper.dart';

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

  // 필터 옵션: 기본 태그(`tag.dart`) 기반으로 구성
  List<String> get _filterOptions => [
    '전체',
    ...DefaultTags.recipeTagsFor(
      context.read<LocaleCubit>().state,
    ).map((t) => t.name),
  ];

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
    double totalWeightG = 0.0;

    // 모든 재료의 투입량을 g 단위(기본 단위)로 환산해서 합산
    for (final ingredient in recipe.ingredients) {
      switch (ingredient.unitId) {
        case 'g':
          totalWeightG += ingredient.amount;
          break;
        case 'kg':
          totalWeightG += ingredient.amount * 1000;
          break;
        case 'ml':
          totalWeightG += ingredient.amount; // ml ≈ g 가정
          break;
        case 'L':
          totalWeightG += ingredient.amount * 1000;
          break;
        case '개':
        case '조각':
          totalWeightG += ingredient.amount * 50; // 개당 50g 가정
          break;
        default:
          totalWeightG += ingredient.amount;
      }
    }

    return {
      'ingredientCount': ingredientCount,
      'totalWeight': totalWeightG,
      'weightUnit': 'g',
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          AppStrings.getRecipeManagement(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: _cancelSelection,
              child: Text(
                AppStrings.getCancelSelection(currentLocale),
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
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          final availableHeight =
              MediaQuery.of(context).size.height - keyboardHeight;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight - 200, // AppBar와 기타 요소들의 높이 고려
              ),
              child: Column(
                children: [
                  if (_isSelectionMode) _buildSelectionHeader(),
                  _buildSearchSection(),
                  _buildFilterSection(),
                  _buildRecipeList(recipeState),
                ],
              ),
            ),
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
        label: AppStrings.getSearchRecipe(context.watch<LocaleCubit>().state),
        hint: AppStrings.getSearchRecipeHint(
          context.watch<LocaleCubit>().state,
        ),
        controller: _searchController,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        onChanged: (value) {
          context.read<RecipeCubit>().searchRecipes(value);
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    final currentLocale = context.watch<LocaleCubit>().state;
    final Map<String, String> localized = {
      '전체': AppStrings.getAll(currentLocale),
    };
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
                label: Text(localized[filter] ?? filter),
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
    final currentLocale = context.watch<LocaleCubit>().state;
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primaryLight,
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.accent, size: 20),
          const SizedBox(width: 8),
          Text(
            AppStrings.getSelectedCount(currentLocale, _selectedRecipes.length),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _deleteSelectedRecipes,
            child: Text(
              AppStrings.getDeleteSelected(context.watch<LocaleCubit>().state),
              style: AppTextStyles.buttonSmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList(RecipeState state) {
    final currentLocale = context.watch<LocaleCubit>().state;

    if (state is RecipeLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is RecipeEmpty) {
      return const SizedBox(height: 200, child: RecipeEmptyState());
    }

    if (state is RecipeError) {
      return SizedBox(
        height: 200,
        child: Center(
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
                text: AppStrings.getRetry(context.watch<LocaleCubit>().state),
                type: AppButtonType.primary,
                onPressed: () {
                  context.read<RecipeCubit>().loadRecipes();
                },
              ),
            ],
          ),
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
    } else if (state is RecipeAdded) {
      recipes = state.recipes;
    } else if (state is RecipeUpdated) {
      recipes = state.recipes;
    } else if (state is RecipeDeleted) {
      recipes = state.recipes;
    } else if (state is RecipesSortedByCost) {
      recipes = state.recipes;
    } else if (state is RecentRecipesLoaded) {
      recipes = state.recipes;
    } else if (state is RecipesByIngredientLoaded) {
      recipes = state.recipes;
    } else if (state is RecipeCostRecalculated) {
      recipes = state.recipes;
    }

    if (recipes.isEmpty) {
      return const SizedBox(height: 200, child: RecipeEmptyState());
    }

    return Container(
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight: MediaQuery.of(context).size.height * 0.6, // 화면 높이의 60%로 제한
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
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
              recipe: recipe, // 실제 Recipe 객체 전달
              locale: currentLocale, // 로컬화 지원
              onTap: () => _editRecipe(recipe),
              onEdit: () => _editRecipe(recipe),
              onDelete: () => _deleteRecipe(recipe),
              onLongPress: () => _toggleRecipeSelection(recipe.id),
              onAiAnalysis: () => _startAiAnalysis(recipe), // AI 분석 콜백 추가
              onViewQuick: () => _viewRecipeQuick(recipe), // 레시피 바로보기 콜백 추가
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final currentLocale = context.watch<LocaleCubit>().state;
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
        AppStrings.getAddRecipeButton(currentLocale),
        style: AppTextStyles.buttonMedium,
      ),
    );
  }

  void _applyFilter(String filter) {
    if (filter == '전체') {
      context.read<RecipeCubit>().loadRecipes();
    } else {
      // 기본 태그 목록에서 이름으로 id 찾기 후 Cubit에 위임
      final tag = DefaultTags.recipeTagsFor(context.read<LocaleCubit>().state)
          .firstWhere(
            (t) => t.name == filter,
            orElse: () => Tag(
              id: '',
              name: '',
              color: '#000000',
              type: TagType.recipe,
              createdAt: DateTime.now(),
            ),
          );
      if (tag.id.isNotEmpty) {
        context.read<RecipeCubit>().filterRecipesByTag(tag.id);
      }
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
    final currentLocale = context.read<LocaleCubit>().state;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getDeleteRecipe(currentLocale)),
        content: Text(
          '${recipe.name} ${AppStrings.getDeleteRecipeConfirm(currentLocale)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(currentLocale)),
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
                      content: Text(
                        '${AppStrings.getDelete(currentLocale)} 중 오류가 발생했습니다: $e',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppStrings.getDelete(currentLocale),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedRecipes() {
    final currentLocale = context.read<LocaleCubit>().state;
    if (_selectedRecipes.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getDeleteSelectedRecipes(currentLocale)),
        content: Text(
          AppStrings.getDeleteSelectedRecipesConfirm(
            currentLocale,
            _selectedRecipes.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(currentLocale)),
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
                      content: Text(
                        AppStrings.getDeleteError(currentLocale, e.toString()),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppStrings.getDelete(currentLocale),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // 삭제 예정 함수 제거 (미사용)

  /// AI 분석 시작
  void _startAiAnalysis(Recipe recipe) {
    print('_startAiAnalysis 호출됨 - Recipe: ${recipe.name}');
    print('_startAiAnalysis 호출됨 - Recipe ID: ${recipe.id}');

    // AI 판매 분석 페이지로 이동 (RouterHelper 사용)
    RouterHelper.goToAiSalesAnalysis(context, recipe);
  }

  /// 레시피 바로보기
  void _viewRecipeQuick(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => RecipeQuickViewDialog(
        recipe: recipe,
        locale: context.read<LocaleCubit>().state,
      ),
    );
  }
}
