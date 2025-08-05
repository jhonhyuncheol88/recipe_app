import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
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
    return ListTile(
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: enabled ? AppColors.textPrimary : AppColors.textLight,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: enabled ? AppColors.textSecondary : AppColors.textLight,
              ),
            )
          : null,
      leading: leading,
      trailing: trailing,
      onTap: enabled ? onTap : null,
      onLongPress: enabled ? onLongPress : null,
      selected: selected,
      tileColor: tileColor ?? AppColors.surface,
      selectedTileColor: selectedTileColor ?? AppColors.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      leading: _buildLeading(),
      trailing: _buildTrailing(),
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

  Widget _buildLeading() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.inventory_2,
        color: AppColors.buttonText,
        size: 20,
      ),
    );
  }

  Widget _buildTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.textSecondary,
          ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 20),
            color: AppColors.error,
          ),
        const Icon(Icons.chevron_right, color: AppColors.textLight),
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
      leading: _buildLeading(),
      trailing: _buildTrailing(),
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

  Widget _buildLeading() {
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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.buttonText,
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
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.restaurant,
        color: AppColors.buttonText,
        size: 20,
      ),
    );
  }

  Widget _buildTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.textSecondary,
          ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 20),
            color: AppColors.error,
          ),
        const Icon(Icons.chevron_right, color: AppColors.textLight),
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
    return AppListTile(
      title: title,
      subtitle: subtitle,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.buttonText, size: 20),
      ),
      trailing:
          trailing ??
          (showChevron
              ? const Icon(Icons.chevron_right, color: AppColors.textLight)
              : null),
      onTap: onTap,
    );
  }
}
