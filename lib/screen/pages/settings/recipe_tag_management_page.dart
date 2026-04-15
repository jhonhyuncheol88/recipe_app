import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../controller/tag/tag_cubit.dart';
import '../../../controller/tag/tag_state.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../../model/tag.dart';
import '../../../theme/app_text_styles.dart';
import '../../../util/app_strings.dart';

/// 레시피 메뉴 태그 관리 페이지
/// - 태그 추가 / 수정 / 삭제
/// - 드래그로 순서 변경 (SharedPreferences에 저장)
class RecipeTagManagementPage extends StatefulWidget {
  const RecipeTagManagementPage({super.key});

  @override
  State<RecipeTagManagementPage> createState() =>
      _RecipeTagManagementPageState();
}

class _RecipeTagManagementPageState extends State<RecipeTagManagementPage> {
  static const _orderKey = 'recipe_tag_order';

  List<Tag> _orderedTags = [];
  bool _loaded = false;

  // 선택 가능한 색상 팔레트
  static const List<Color> _palette = [
    Color(0xFFE53935), Color(0xFFE91E63), Color(0xFF9C27B0),
    Color(0xFF673AB7), Color(0xFF3F51B5), Color(0xFF2196F3),
    Color(0xFF03A9F4), Color(0xFF00BCD4), Color(0xFF009688),
    Color(0xFF4CAF50), Color(0xFF8BC34A), Color(0xFFCDDC39),
    Color(0xFFFFEB3B), Color(0xFFFFC107), Color(0xFFFF9800),
    Color(0xFFFF5722), Color(0xFF795548), Color(0xFF607D8B),
  ];

  @override
  void initState() {
    super.initState();
    context.read<TagCubit>().loadTagsByType(TagType.recipe);
  }

  /// SharedPreferences에서 저장된 순서 불러와 태그 정렬
  Future<List<Tag>> _applySavedOrder(List<Tag> tags) async {
    final prefs = await SharedPreferences.getInstance();
    final orderStr = prefs.getString(_orderKey);
    if (orderStr == null || orderStr.isEmpty) return tags;

    final ids = orderStr.split(',');
    final ordered = <Tag>[];
    for (final id in ids) {
      final found = tags.where((t) => t.id == id).toList();
      if (found.isNotEmpty) ordered.add(found.first);
    }
    // 순서에 없는 새 태그는 뒤에 추가
    for (final tag in tags) {
      if (!ordered.any((t) => t.id == tag.id)) ordered.add(tag);
    }
    return ordered;
  }

  Future<void> _saveOrder(List<Tag> tags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_orderKey, tags.map((t) => t.id).join(','));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final tag = _orderedTags.removeAt(oldIndex);
      _orderedTags.insert(newIndex, tag);
    });
    _saveOrder(_orderedTags);
  }

  Color _hexToColor(String hex) {
    try {
      return Color(
        int.parse(hex.replaceFirst('#', ''), radix: 16) | 0xFF000000,
      );
    } catch (_) {
      return Colors.grey;
    }
  }

  String _colorToHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  /// 추가 / 수정 다이얼로그
  Future<void> _showEditDialog({Tag? existing}) async {
    final locale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    final nameController =
        TextEditingController(text: existing?.name ?? '');
    Color selectedColor = existing != null
        ? _hexToColor(existing.color)
        : _palette.first;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            backgroundColor: colorScheme.surface,
            title: Text(
              existing == null
                  ? AppStrings.getAddTag(locale)
                  : AppStrings.getEditTag(locale),
              style: AppTextStyles.headline4
                  .copyWith(color: colorScheme.onSurface),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 태그명 입력
                TextField(
                  controller: nameController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: AppStrings.getTagName(locale),
                    labelStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 색상 팔레트
                Text(
                  AppStrings.getTagColor(locale),
                  style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _palette.map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setLocal(() => selectedColor = color),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.onSurface
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppStrings.getCancel(locale)),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppStrings.getSave(locale)),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || nameController.text.trim().isEmpty) return;
    if (!mounted) return;

    final name = nameController.text.trim();
    final hexColor = _colorToHex(selectedColor);

    if (existing == null) {
      // 추가
      final newTag = Tag(
        id: const Uuid().v4(),
        name: name,
        color: hexColor,
        type: TagType.recipe,
        createdAt: DateTime.now(),
      );
      await context.read<TagCubit>().addTag(newTag);
    } else {
      // 수정
      await context.read<TagCubit>().updateTag(
            existing.copyWith(name: name, color: hexColor),
          );
    }
    if (!mounted) return;
    context.read<TagCubit>().loadTagsByType(TagType.recipe);
  }

  Future<void> _confirmDelete(Tag tag) async {
    final locale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppStrings.getDeleteTag(locale),
          style:
              AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        content: Text(
          AppStrings.getDeleteTagConfirm(locale, tag.name),
          style: AppTextStyles.bodyMedium
              .copyWith(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.getCancel(locale)),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.getDelete(locale)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<TagCubit>().deleteTag(tag.id);
    setState(() {
      _orderedTags.removeWhere((t) => t.id == tag.id);
    });
    await _saveOrder(_orderedTags);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppStrings.getRecipeTagManagement(locale),
          style:
              AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: BlocConsumer<TagCubit, TagState>(
        listener: (context, state) async {
          if (state is TagsLoaded &&
              (state.filterType == TagType.recipe || !_loaded)) {
            final ordered = await _applySavedOrder(state.tags);
            if (mounted) {
              setState(() {
                _orderedTags = ordered;
                _loaded = true;
              });
            }
          }
        },
        builder: (context, state) {
          if (!_loaded && state is TagLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_orderedTags.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.label_off_outlined,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getNoTags(locale),
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 안내 문구
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.drag_indicator,
                        size: 18,
                        color: colorScheme.primary.withValues(alpha: 0.7)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.getTagReorderHint(locale),
                        style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.primary.withValues(alpha: 0.8)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _orderedTags.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final tag = _orderedTags[index];
                    return ListTile(
                      key: ValueKey(tag.id),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      leading: Icon(Icons.drag_indicator,
                          color: colorScheme.onSurface.withValues(alpha: 0.3)),
                      title: Text(
                        tag.name,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: colorScheme.onSurface),
                      ),
                      subtitle: tag.usageCount > 0
                          ? Text(
                              AppStrings.getTagUsageCount(locale, tag.usageCount),
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5)),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 수정
                          IconButton(
                            icon: Icon(Icons.edit_outlined,
                                size: 20,
                                color: colorScheme.primary
                                    .withValues(alpha: 0.7)),
                            onPressed: () =>
                                _showEditDialog(existing: tag),
                          ),
                          // 삭제
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                size: 20,
                                color: colorScheme.error
                                    .withValues(alpha: 0.7)),
                            onPressed: () => _confirmDelete(tag),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'recipe_tag_add',
        onPressed: () => _showEditDialog(),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        icon: const Icon(Icons.add),
        label: Text(AppStrings.getAddTag(locale)),
      ),
    );
  }
}
