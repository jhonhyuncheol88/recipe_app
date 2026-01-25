import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/recipe/recipe_cubit.dart';
import '../../../controller/recipe/recipe_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../model/ai_recipe.dart';

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
    context.read<RecipeCubit>().loadAiRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<LocaleCubit, AppLocale>(
      builder: (context, currentLocale) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(
              AppStrings.getAiRecipeManagement(currentLocale),
              style: AppTextStyles.headline3.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            backgroundColor: colorScheme.surface,
            elevation: 0,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
          ),
          body: Column(
            children: [
              _buildSearchAndFilter(currentLocale),
              Expanded(
                child: BlocBuilder<RecipeCubit, RecipeState>(
                  builder: (context, state) {
                    if (state is RecipeLoading) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.primary));
                    }

                    if (state is AiRecipesEmpty) {
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppStrings.getSearchAiRecipesHint(locale),
              prefixIcon: Icon(Icons.search,
                  color: colorScheme.onSurface.withValues(alpha: 0.4)),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear,
                    color: colorScheme.onSurface.withValues(alpha: 0.4)),
                onPressed: () {
                  _searchController.clear();
                  context.read<RecipeCubit>().loadAiRecipes();
                },
              ),
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
                borderSide: BorderSide(color: colorScheme.primary),
              ),
            ),
            style: TextStyle(color: colorScheme.onSurface),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 80,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.getNoSavedAiRecipes(locale),
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.getNoSavedAiRecipesDescription(locale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
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
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        context.push('/ai/recipe/detail', extra: {'aiRecipeId': aiRecipe.id});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
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
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (aiRecipe.cuisineType != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            aiRecipe.cuisineType!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: colorScheme.surface,
                    onSelected: (value) =>
                        _handleMenuAction(value, aiRecipe, locale),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'convert',
                        child: Row(
                          children: [
                            Icon(Icons.transform, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(AppStrings.getConvertToRecipe(locale),
                                style: TextStyle(color: colorScheme.onSurface)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: colorScheme.error),
                            const SizedBox(width: 8),
                            Text(AppStrings.getDelete(locale),
                                style: TextStyle(color: colorScheme.error)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aiRecipe.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.people,
                        '${aiRecipe.servings}${AppStrings.getPeople(locale)}',
                        colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.timer,
                        '${aiRecipe.totalTimeMinutes}${AppStrings.getMinutes(locale)}',
                        colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.trending_up,
                        aiRecipe.difficulty,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(aiRecipe.generatedAt, locale),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
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
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            AppStrings.getConverted(locale),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: colorScheme.error),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTextStyles.headline4.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<RecipeCubit>().loadAiRecipes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(AppStrings.getRetry(locale)),
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
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getConvertToRecipe(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(AppStrings.getConvertToRecipeDescription(locale),
            style: TextStyle(color: colorScheme.onSurface)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(AppStrings.getConvertToRecipe(locale)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AiRecipe aiRecipe, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getDeleteAiRecipe(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(AppStrings.getDeleteAiRecipeConfirm(locale),
            style: TextStyle(color: colorScheme.onSurface)),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text(AppStrings.getDelete(locale)),
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
