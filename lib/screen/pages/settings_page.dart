import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../util/app_strings.dart';
import '../../util/app_locale.dart';
import '../widget/index.dart';

/// 설정 페이지
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _expiryWarningEnabled = true;
  bool _expiryDangerEnabled = true;
  bool _expiryExpiredEnabled = true;
  String _selectedLanguage = '한국어';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getSettings(AppLocale.korea),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(
            AppStrings.getNotificationSettings(AppLocale.korea),
          ),
          const SizedBox(height: 8),
          _buildNotificationSettings(),

          const SizedBox(height: 32),
          _buildSectionTitle(AppStrings.getAppSettings(AppLocale.korea)),
          const SizedBox(height: 8),
          _buildAppSettings(),

          const SizedBox(height: 32),
          _buildSectionTitle(AppStrings.getInformation(AppLocale.korea)),
          const SizedBox(height: 8),
          _buildAppInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headline4.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        SettingsListTile(
          title: AppStrings.getEnableNotifications(AppLocale.korea),
          subtitle: AppStrings.getEnableNotificationsDescription(
            AppLocale.korea,
          ),
          icon: Icons.notifications,
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            activeColor: AppColors.accent,
          ),
          onTap: null,
        ),
        if (_notificationsEnabled) ...[
          SettingsListTile(
            title: AppStrings.getExpiryWarningNotification(AppLocale.korea),
            subtitle: AppStrings.getExpiryWarningDescription(AppLocale.korea),
            icon: Icons.warning,
            trailing: Switch(
              value: _expiryWarningEnabled,
              onChanged: (value) {
                setState(() {
                  _expiryWarningEnabled = value;
                });
              },
              activeColor: AppColors.warning,
            ),
            onTap: null,
          ),
          SettingsListTile(
            title: AppStrings.getExpiryDangerNotification(AppLocale.korea),
            subtitle: AppStrings.getExpiryDangerDescription(AppLocale.korea),
            icon: Icons.error,
            trailing: Switch(
              value: _expiryDangerEnabled,
              onChanged: (value) {
                setState(() {
                  _expiryDangerEnabled = value;
                });
              },
              activeColor: AppColors.error,
            ),
            onTap: null,
          ),
          SettingsListTile(
            title: AppStrings.getExpiryExpiredNotification(AppLocale.korea),
            subtitle: AppStrings.getExpiryExpiredDescription(AppLocale.korea),
            icon: Icons.block,
            trailing: Switch(
              value: _expiryExpiredEnabled,
              onChanged: (value) {
                setState(() {
                  _expiryExpiredEnabled = value;
                });
              },
              activeColor: AppColors.error,
            ),
            onTap: null,
          ),
        ],
      ],
    );
  }

  Widget _buildAppSettings() {
    return Column(
      children: [
        SettingsListTile(
          title: AppStrings.getLanguageSettings(AppLocale.korea),
          subtitle: _selectedLanguage,
          icon: Icons.language,
          onTap: _showLanguageDialog,
        ),
        SettingsListTile(
          title: AppStrings.getExportData(AppLocale.korea),
          subtitle: AppStrings.getExportDataDescription(AppLocale.korea),
          icon: Icons.backup,
          onTap: _exportData,
        ),
        SettingsListTile(
          title: AppStrings.getImportData(AppLocale.korea),
          subtitle: AppStrings.getImportDataDescription(AppLocale.korea),
          icon: Icons.restore,
          onTap: _importData,
        ),
        SettingsListTile(
          title: AppStrings.getResetData(AppLocale.korea),
          subtitle: AppStrings.getResetDataDescription(AppLocale.korea),
          icon: Icons.delete_forever,
          onTap: _resetData,
        ),
      ],
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        SettingsListTile(
          title: AppStrings.getAppVersion(AppLocale.korea),
          subtitle: '1.0.0',
          icon: Icons.info,
          showChevron: false,
          onTap: null,
        ),
        SettingsListTile(
          title: AppStrings.getDeveloperInfo(AppLocale.korea),
          subtitle: AppStrings.getDeveloperTeam(AppLocale.korea),
          icon: Icons.person,
          onTap: _showDeveloperInfo,
        ),
        SettingsListTile(
          title: AppStrings.getPrivacyPolicy(AppLocale.korea),
          subtitle: AppStrings.getPrivacyPolicyDescription(AppLocale.korea),
          icon: Icons.privacy_tip,
          onTap: _showPrivacyPolicy,
        ),
        SettingsListTile(
          title: AppStrings.getTermsOfService(AppLocale.korea),
          subtitle: AppStrings.getTermsOfServiceDescription(AppLocale.korea),
          icon: Icons.description,
          onTap: _showTermsOfService,
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.getLanguageSelection(AppLocale.korea),
          style: AppTextStyles.headline4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('한국어', '한국어'),
            _buildLanguageOption('English', 'English'),
            _buildLanguageOption('日本語', '日本語'),
            _buildLanguageOption('中文', '中文'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: _selectedLanguage == value
          ? Icon(Icons.check, color: AppColors.accent)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _exportData() {
    // TODO: 데이터 내보내기 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.getFeatureInProgress(AppLocale.korea, '데이터 내보내기'),
        ),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _importData() {
    // TODO: 데이터 가져오기 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.getFeatureInProgress(AppLocale.korea, '데이터 가져오기'),
        ),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _resetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.getDataReset(AppLocale.korea),
          style: AppTextStyles.headline4,
        ),
        content: Text(
          AppStrings.getDataResetWarning(AppLocale.korea),
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: 데이터 초기화 구현
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.getDataResetSuccess(AppLocale.korea),
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              '초기화',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeveloperInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.getDeveloperInfo(AppLocale.korea),
          style: AppTextStyles.headline4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getDeveloperTeam(AppLocale.korea),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.getAppDescription(AppLocale.korea),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.getVersion(AppLocale.korea),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.getConfirm(AppLocale.korea),
              style: AppTextStyles.buttonMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: 개인정보 처리방침 페이지로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.getFeatureInProgress(AppLocale.korea, '개인정보 처리방침'),
        ),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showTermsOfService() {
    // TODO: 이용약관 페이지로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.getFeatureInProgress(AppLocale.korea, '이용약관')),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
