import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/recipe/recipe_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../model/ai_recipe.dart';
import '../../../router/router_helper.dart';
import 'ai_recipe_detail_page.dart';

/// AI 레시피 관리 페이지
class AiRecipePage extends StatefulWidget {
  const AiRecipePage({super.key});

  @override
  State<AiRecipePage> createState() => _AiRecipePageState();
}

class _AiRecipePageState extends State<AiRecipePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 AI 레시피 목록 가져오기
    context.read<RecipeCubit>().loadAiRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              AppStrings.getAiRecipeManagement(currentLocale),
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [],
          ),
          body: Column(
            children: [
              _buildSearchAndFilter(currentLocale),
              Expanded(
                child: BlocBuilder<RecipeCubit, RecipeState>(
                  builder: (context, state) {
                    print('AiRecipePage: 현재 상태 - ${state.runtimeType}');

                    if (state is RecipeLoading) {
                      print('AiRecipePage: 로딩 상태 표시');
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AiRecipesEmpty) {
                      print('AiRecipePage: 빈 상태 표시');
                      return _buildEmptyState(currentLocale);
                    }

                    if (state is AiRecipesLoaded) {
                      return _buildAiRecipeList(state.aiRecipes, currentLocale);
                    }

                    if (state is AiRecipesSearchResult) {
                      return _buildAiRecipeList(state.aiRecipes, currentLocale);
                    }

                    if (state is RecipeError) {
                      return _buildErrorState(state.message, currentLocale);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilter(AppLocale locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 검색바
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppStrings.getSearchAiRecipesHint(locale),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<RecipeCubit>().loadAiRecipes();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.accent),
              ),
            ),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                context.read<RecipeCubit>().searchAiRecipes(query);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocale locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.getNoSavedAiRecipes(locale),
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.getNoSavedAiRecipesDescription(locale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRecipeList(List<AiRecipe> aiRecipes, AppLocale locale) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: aiRecipes.length,
      itemBuilder: (context, index) {
        final aiRecipe = aiRecipes[index];
        return _buildAiRecipeCard(aiRecipe, locale);
      },
    );
  }

  Widget _buildAiRecipeCard(AiRecipe aiRecipe, AppLocale locale) {
    return GestureDetector(
      onTap: () {
        // AI 레시피 상세 페이지로 이동
        context.push('/ai/recipe/detail', extra: {'aiRecipeId': aiRecipe.id});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aiRecipe.recipeName,
                          style: AppTextStyles.headline4.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (aiRecipe.cuisineType != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            aiRecipe.cuisineType!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleMenuAction(value, aiRecipe, locale),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'convert',
                        child: Row(
                          children: [
                            Icon(Icons.transform, color: AppColors.accent),
                            const SizedBox(width: 8),
                            Text(AppStrings.getConvertToRecipe(locale)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(AppStrings.getDelete(locale)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // 내용
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aiRecipe.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // 정보 행
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.people,
                        '${aiRecipe.servings}${AppStrings.getPeople(locale)}',
                        AppColors.info,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.timer,
                        '${aiRecipe.totalTimeMinutes}${AppStrings.getMinutes(locale)}',
                        AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.trending_up,
                        aiRecipe.difficulty,
                        AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 태그
                  if (aiRecipe.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: aiRecipe.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.accent.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accent,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // 하단 정보
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(aiRecipe.generatedAt, locale),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (aiRecipe.isConvertedToRecipe)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            AppStrings.getConverted(locale),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontSize: 12,
                            ),
                          ),
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

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, AppLocale locale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<RecipeCubit>().loadAiRecipes();
              },
              child: Text(AppStrings.getRetry(locale)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, AiRecipe aiRecipe, AppLocale locale) {
    switch (action) {
      case 'convert':
        _showConvertDialog(aiRecipe, locale);
        break;
      case 'delete':
        _showDeleteDialog(aiRecipe, locale);
        break;
    }
  }

  void _showConvertDialog(AiRecipe aiRecipe, AppLocale locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getConvertToRecipe(locale)),
        content: Text(AppStrings.getConvertToRecipeDescription(locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(locale)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RecipeCubit>().convertAiRecipeToRecipe(aiRecipe.id);
            },
            child: Text(AppStrings.getConvertToRecipe(locale)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.buttonText,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AiRecipe aiRecipe, AppLocale locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getDeleteAiRecipe(locale)),
        content: Text(AppStrings.getDeleteAiRecipeConfirm(locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.getCancel(locale)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<RecipeCubit>().deleteAiRecipe(aiRecipe.id);
            },
            child: Text(AppStrings.getDelete(locale)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.buttonText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, AppLocale locale) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return AppStrings.getToday(locale);
    } else if (difference.inDays == 1) {
      return AppStrings.getYesterday(locale);
    } else if (difference.inDays < 7) {
      return AppStrings.getDaysAgo(locale, difference.inDays);
    } else {
      return AppStrings.getMonthDay(locale, date.month, date.day);
    }
  }
}
