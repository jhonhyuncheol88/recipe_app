import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

/// 앱에서 사용하는 공통 ListTile 위젯
class AppListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool selected;
  final Color? tileColor;
  final Color? selectedTileColor;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.tileColor,
    this.selectedTileColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withOpacity(0.5),
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: enabled
                    ? colorScheme.onSurface.withOpacity(0.6)
                    : colorScheme.onSurface.withOpacity(0.4),
              ),
            )
          : null,
      leading: leading,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      selected: selected,
      tileColor: tileColor ?? Colors.transparent,
      selectedTileColor:
          selectedTileColor ?? colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

/// 재료 ListTile 위젯
class IngredientListTile extends StatelessWidget {
  final String name;
  final double price;
  final double amount;
  final String unit;
  final DateTime? expiryDate;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const IngredientListTile({
    super.key,
    required this.name,
    required this.price,
    required this.amount,
    required this.unit,
    this.expiryDate,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: name,
      subtitle: _buildSubtitle(),
      leading: _buildLeading(context),
      trailing: _buildTrailing(context),
      onTap: onTap,
    );
  }

  String _buildSubtitle() {
    String subtitle = '₩${price.toStringAsFixed(0)} • ${amount.toInt()} $unit';

    if (expiryDate != null) {
      final now = DateTime.now();
      final daysUntilExpiry = expiryDate!.difference(now).inDays;

      String statusText;
      if (daysUntilExpiry < 0) {
        statusText = '만료됨';
      } else if (daysUntilExpiry <= 3) {
        statusText = '위험';
      } else if (daysUntilExpiry <= 7) {
        statusText = '경고';
      } else {
        statusText = '정상';
      }

      subtitle += ' • $statusText';
    }

    return subtitle;
  }

  Widget _buildLeading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.inventory_2,
        color: colorScheme.primary,
        size: 20,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 20),
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 20),
            color: colorScheme.error,
          ),
        Icon(Icons.chevron_right,
            color: colorScheme.onSurface.withOpacity(0.3)),
      ],
    );
  }
}

/// 레시피 ListTile 위젯
class RecipeListTile extends StatelessWidget {
  final String name;
  final String description;
  final double totalCost;
  final String outputUnit;
  final double outputAmount;
  final String? imagePath;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RecipeListTile({
    super.key,
    required this.name,
    required this.description,
    required this.totalCost,
    required this.outputUnit,
    required this.outputAmount,
    this.imagePath,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      title: name,
      subtitle: _buildSubtitle(),
      leading: _buildLeading(context),
      trailing: _buildTrailing(context),
      onTap: onTap,
    );
  }

  String _buildSubtitle() {
    String subtitle =
        '₩${totalCost.toStringAsFixed(0)} • ${outputAmount.toStringAsFixed(1)} $outputUnit';

    if (description.isNotEmpty) {
      subtitle = '$description\n$subtitle';
    }

    return subtitle;
  }

  Widget _buildLeading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant,
                color: colorScheme.primary,
                size: 20,
              ),
            );
          },
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.restaurant,
        color: colorScheme.primary,
        size: 20,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 20),
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 20),
            color: colorScheme.error,
          ),
        Icon(Icons.chevron_right,
            color: colorScheme.onSurface.withOpacity(0.3)),
      ],
    );
  }
}

/// 설정 ListTile 위젯
class SettingsListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppListTile(
      title: title,
      subtitle: subtitle,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      trailing: trailing ??
          (showChevron
              ? Icon(Icons.chevron_right,
                  color: colorScheme.onSurface.withOpacity(0.3))
              : null),
      onTap: onTap,
    );
  }
}
