import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
// 권한 확인/요청은 Cubit에서만 처리

// 권한 요청/저장은 이 화면에서 처리하지 않습니다

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../util/app_strings.dart';
import '../../util/app_locale.dart';
import '../widget/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/index.dart';
import '../../data/index.dart';

/// 설정 페이지
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 선택 언어는 LocaleCubit 상태를 사용하므로 별도 상태 보관 불필요
  // 알림 토글은 Cubit(SharedPreferences 연동)에서 직접 읽어와 표시합니다

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.getSettings(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(AppStrings.getNotificationSettings(currentLocale)),
          const SizedBox(height: 8),
          _buildNotificationSettings(currentLocale),

          const SizedBox(height: 32),
          _buildSectionTitle(AppStrings.getAppSettings(currentLocale)),
          const SizedBox(height: 8),
          _buildAppSettings(currentLocale),

          const SizedBox(height: 32),
          // _buildSectionTitle(AppStrings.getInformation(currentLocale)),
          // const SizedBox(height: 8),
          // _buildAppInfo(currentLocale),
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

  Widget _buildNotificationSettings(AppLocale locale) {
    final notifCubit = context.watch<ExpiryNotificationCubit>();
    return Column(
      children: [
        SettingsListTile(
          title: AppStrings.getEnableNotifications(locale),
          subtitle: AppStrings.getEnableNotificationsDescription(locale),
          icon: Icons.notifications,
          trailing: Switch(
            value: notifCubit.notificationsEnabled,
            onChanged: (value) {
              context.read<ExpiryNotificationCubit>().setNotificationsEnabled(
                value,
              );
            },
            activeColor: AppColors.accent,
          ),
          onTap: null,
        ),
        if (notifCubit.notificationsEnabled) ...[
          SettingsListTile(
            title: AppStrings.getExpiryWarningNotification(locale),
            subtitle: AppStrings.getExpiryWarningDescription(locale),
            icon: Icons.warning,
            trailing: Switch(
              value: notifCubit.warningEnabled,
              onChanged: (value) {
                context.read<ExpiryNotificationCubit>().setWarningEnabled(
                  value,
                );
              },
              activeColor: AppColors.warning,
            ),
            onTap: null,
          ),
          SettingsListTile(
            title: AppStrings.getExpiryDangerNotification(locale),
            subtitle: AppStrings.getExpiryDangerDescription(locale),
            icon: Icons.error,
            trailing: Switch(
              value: notifCubit.dangerEnabled,
              onChanged: (value) {
                context.read<ExpiryNotificationCubit>().setDangerEnabled(value);
              },
              activeColor: AppColors.error,
            ),
            onTap: null,
          ),
          SettingsListTile(
            title: AppStrings.getExpiryExpiredNotification(locale),
            subtitle: AppStrings.getExpiryExpiredDescription(locale),
            icon: Icons.block,
            trailing: Switch(
              value: notifCubit.expiredEnabled,
              onChanged: (value) {
                context.read<ExpiryNotificationCubit>().setExpiredEnabled(
                  value,
                );
              },
              activeColor: AppColors.error,
            ),
            onTap: null,
          ),
        ],
      ],
    );
  }

  Widget _buildAppSettings(AppLocale locale) {
    return Column(
      children: [
        SettingsListTile(
          title: AppStrings.getLanguageSettings(locale),
          subtitle: context.watch<LocaleCubit>().state.displayName,
          icon: Icons.language,
          onTap: _showLanguageDialog,
        ),
        SettingsListTile(
          title: AppStrings.getExportData(locale),
          subtitle: AppStrings.getExportDataDescription(locale),
          icon: Icons.backup,
          onTap: _exportData,
        ),
        SettingsListTile(
          title: AppStrings.getImportData(locale),
          subtitle: AppStrings.getImportDataDescription(locale),
          icon: Icons.restore,
          onTap: _importData,
        ),
        SettingsListTile(
          title: AppStrings.getResetData(locale),
          subtitle: AppStrings.getResetDataDescription(locale),
          icon: Icons.delete_forever,
          onTap: _resetData,
        ),
      ],
    );
  }

  Widget _buildAppInfo(AppLocale locale) {
    return Column(
      children: [
        SettingsListTile(
          title: AppStrings.getAppVersion(locale),
          subtitle: '1.0.0',
          icon: Icons.info,
          showChevron: false,
          onTap: null,
        ),
        SettingsListTile(
          title: AppStrings.getDeveloperInfo(locale),
          subtitle: AppStrings.getDeveloperTeam(locale),
          icon: Icons.person,
          onTap: _showDeveloperInfo,
        ),
        SettingsListTile(
          title: AppStrings.getPrivacyPolicy(locale),
          subtitle: AppStrings.getPrivacyPolicyDescription(locale),
          icon: Icons.privacy_tip,
          onTap: _showPrivacyPolicy,
        ),
        SettingsListTile(
          title: AppStrings.getTermsOfService(locale),
          subtitle: AppStrings.getTermsOfServiceDescription(locale),
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
          AppStrings.getLanguageSelection(context.read<LocaleCubit>().state),
          style: AppTextStyles.headline4,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final loc in [
              AppLocale.korea,
              AppLocale.japan,
              AppLocale.china,
              AppLocale.usa,
            ])
              _buildLanguageOption(loc.displayName, loc),
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

  Widget _buildLanguageOption(String title, AppLocale value) {
    return ListTile(
      title: Text(title),
      trailing: context.watch<LocaleCubit>().state == value
          ? Icon(Icons.check, color: AppColors.accent)
          : null,
      onTap: () {
        context.read<LocaleCubit>().setLocale(value);
        Navigator.pop(context);
      },
    );
  }

  void _exportData() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: const Text('기기에 저장'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final dbPath = p.join(
                      await getDatabasesPath(),
                      'recipe_app.db',
                    );
                    final documentsDir =
                        await getApplicationDocumentsDirectory();
                    final timestamp = DateTime.now()
                        .toIso8601String()
                        .replaceAll(':', '-');
                    final outPath = p.join(
                      documentsDir.path,
                      'recipe_app_export_$timestamp.db',
                    );
                    await File(dbPath).copy(outPath);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('내보내기 완료: $outPath'),
                        backgroundColor: AppColors.success,
                        action: SnackBarAction(
                          label: '공유',
                          onPressed: () async {
                            await Share.shareXFiles([
                              XFile(outPath),
                            ], text: '레시피 앱 데이터베이스 내보내기');
                          },
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('내보내기 실패: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('공유하기'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final dbPath = p.join(
                      await getDatabasesPath(),
                      'recipe_app.db',
                    );
                    final tmpDir = await getTemporaryDirectory();
                    final timestamp = DateTime.now()
                        .toIso8601String()
                        .replaceAll(':', '-');
                    final tmpPath = p.join(
                      tmpDir.path,
                      'recipe_app_export_$timestamp.db',
                    );
                    await File(dbPath).copy(tmpPath);
                    await Share.shareXFiles([
                      XFile(tmpPath),
                    ], text: '레시피 앱 데이터베이스 내보내기');
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('공유 실패: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );
      if (result == null || result.files.single.path == null) {
        return;
      }
      final pickedPath = result.files.single.path!;

      // DB 닫기
      await DatabaseHelper().close();
      final dbPath = p.join(await getDatabasesPath(), 'recipe_app.db');

      // 기존 DB 삭제 후 교체
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      await File(pickedPath).copy(dbPath);

      // 재오픈하여 마이그레이션이 필요하면 적용
      await DatabaseHelper().database;

      // 화면 데이터 새로고침
      await Future.wait([
        context.read<IngredientCubit>().loadIngredients(),
        context.read<RecipeCubit>().loadRecipes(),
        context.read<SauceCubit>().loadSauces(),
        context.read<TagCubit>().loadAllTags(),
      ]);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('데이터 가져오기 완료'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('가져오기 실패: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
            onPressed: () async {
              try {
                // DB 닫기 및 파일 삭제
                await DatabaseHelper().close();
                final dbPath = p.join(
                  await getDatabasesPath(),
                  'recipe_app.db',
                );
                await deleteDatabase(dbPath);

                // 재오픈하여 새로 생성
                await DatabaseHelper().database;

                // 데이터 리로드
                await Future.wait([
                  context.read<IngredientCubit>().loadIngredients(),
                  context.read<RecipeCubit>().loadRecipes(),
                  context.read<SauceCubit>().loadSauces(),
                  context.read<TagCubit>().loadAllTags(),
                ]);

                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppStrings.getDataResetSuccess(AppLocale.korea),
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('초기화 실패: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
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
