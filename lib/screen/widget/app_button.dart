import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// 앱에서 사용하는 공통 버튼 위젯
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize(), color: _getTextColor()),
          SizedBox(width: _getSpacing()),
          Text(text, style: _getTextStyle()),
        ],
      );
    }

    return Text(text, style: _getTextStyle());
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getTextColor(),
      elevation: _getElevation(),
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
      ),
      padding: _getPadding(),
      minimumSize: _getMinimumSize(),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case AppButtonType.primary:
        return AppColors.buttonPrimary;
      case AppButtonType.secondary:
        return AppColors.buttonSecondary;
      case AppButtonType.success:
        return AppColors.success;
      case AppButtonType.warning:
        return AppColors.warning;
      case AppButtonType.error:
        return AppColors.error;
    }
  }

  Color _getTextColor() {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
      case AppButtonType.success:
      case AppButtonType.warning:
      case AppButtonType.error:
        return AppColors.buttonText;
    }
  }

  double _getElevation() {
    switch (size) {
      case AppButtonSize.small:
        return 1;
      case AppButtonSize.medium:
        return 2;
      case AppButtonSize.large:
        return 3;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return 8;
      case AppButtonSize.medium:
        return 12;
      case AppButtonSize.large:
        return 16;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  Size _getMinimumSize() {
    switch (size) {
      case AppButtonSize.small:
        return const Size(80, 36);
      case AppButtonSize.medium:
        return const Size(120, 48);
      case AppButtonSize.large:
        return const Size(160, 56);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.buttonSmall;
      case AppButtonSize.medium:
        return AppTextStyles.buttonMedium;
      case AppButtonSize.large:
        return AppTextStyles.buttonLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  double _getSpacing() {
    switch (size) {
      case AppButtonSize.small:
        return 4;
      case AppButtonSize.medium:
        return 8;
      case AppButtonSize.large:
        return 12;
    }
  }
}

/// 버튼 타입 열거형
enum AppButtonType { primary, secondary, success, warning, error }

/// 버튼 크기 열거형
enum AppButtonSize { small, medium, large }
