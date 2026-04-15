import 'package:flutter/material.dart';
import '../../model/ai_recipe.dart';
import '../../theme/app_text_styles.dart';
import '../../util/app_strings.dart';
import '../../util/app_locale.dart';

/// AI 레시피 목록 카드 위젯
class AiRecipeCard extends StatelessWidget {
  final AiRecipe aiRecipe;
  final AppLocale locale;
  final VoidCallback onTap;
  final VoidCallback onConvert;
  final VoidCallback onDelete;

  const AiRecipeCard({
    super.key,
    required this.aiRecipe,
    required this.locale,
    required this.onTap,
    required this.onConvert,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme),
            _buildBody(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (aiRecipe.cuisineType != null) ...[
                  const SizedBox(height: 2),
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
            onSelected: (value) {
              if (value == 'convert') onConvert();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'convert',
                child: Row(
                  children: [
                    Icon(Icons.transform, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.getConvertToRecipe(locale),
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        color: colorScheme.error, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.getDelete(locale),
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설명
          Text(
            aiRecipe.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // 정보 chips
          Wrap(
            spacing: 6,
            children: [
              _chip(
                Icons.people_outline,
                '${aiRecipe.servings}${AppStrings.getPeople(locale)}',
                colorScheme.secondary,
                colorScheme,
              ),
              _chip(
                Icons.timer_outlined,
                '${aiRecipe.totalTimeMinutes}${AppStrings.getMinutes(locale)}',
                colorScheme.primary,
                colorScheme,
              ),
              _chip(
                Icons.bar_chart,
                aiRecipe.difficulty,
                Colors.green.shade600,
                colorScheme,
              ),
            ],
          ),
          // 태그
          if (aiRecipe.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: aiRecipe.tags.take(3).map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 10),
          // 날짜 + 변환 뱃지
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(aiRecipe.generatedAt, locale),
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
              const Spacer(),
              if (aiRecipe.isConvertedToRecipe)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    AppStrings.getConverted(locale),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(
      IconData icon, String label, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date, AppLocale locale) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return AppStrings.getToday(locale);
    if (diff.inDays == 1) return AppStrings.getYesterday(locale);
    if (diff.inDays < 7) return AppStrings.getDaysAgo(locale, diff.inDays);
    return AppStrings.getMonthDay(locale, date.month, date.day);
  }
}
