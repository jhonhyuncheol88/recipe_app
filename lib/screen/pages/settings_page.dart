import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../theme/app_text_styles.dart';
import '../../theme/app_colors.dart';
import '../../util/app_strings.dart';
import '../../util/app_locale.dart';
import '../../util/number_format_style.dart';
import '../widget/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/index.dart';
import '../../controller/setting/theme_cubit.dart';

import '../../data/index.dart';
import '../../router/router_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

/// 설정 페이지
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final currentLocale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/');
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            AppStrings.getSettings(currentLocale),
            style: AppTextStyles.headline4.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(
              AppStrings.getNotificationSettings(currentLocale),
            ),
            const SizedBox(height: 8),
            _buildNotificationSettings(currentLocale),
            const SizedBox(height: 32),
            _buildSectionTitle(AppStrings.getDisplaySettings(currentLocale)),
            const SizedBox(height: 8),
            _buildDisplaySettings(currentLocale),
            const SizedBox(height: 32),
            _buildSectionTitle(AppStrings.getAppSettings(currentLocale)),
            const SizedBox(height: 8),
            _buildAppSettings(currentLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: AppTextStyles.headline4.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNotificationSettings(AppLocale locale) {
    final notifCubit = context.watch<ExpiryNotificationCubit>();
    final colorScheme = Theme.of(context).colorScheme;
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
            activeColor: colorScheme.primary,
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
              activeColor: Colors.orange,
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
              activeColor: colorScheme.error,
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
              activeColor: colorScheme.error,
            ),
            onTap: null,
          ),
          SettingsListTile(
            title: AppStrings.getAlarmTimeSetting(locale),
            subtitle:
                '${notifCubit.getNotificationTime().hour.toString().padLeft(2, '0')}:${notifCubit.getNotificationTime().minute.toString().padLeft(2, '0')}',
            icon: Icons.access_time,
            onTap: _showTimePickerDialog,
          ),
        ],
      ],
    );
  }

  Widget _buildDisplaySettings(AppLocale locale) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.state.brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SettingsListTile(
          title: AppStrings.getThemeColor(locale),
          subtitle: themeCubit.state.themeType.displayName,
          icon: Icons.palette,
          onTap: _showThemeDialog,
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.1)),
            ),
          ),
        ),
        SettingsListTile(
          title: AppStrings.getDarkMode(locale),
          subtitle:
              isDark ? AppStrings.getOn(locale) : AppStrings.getOff(locale),
          icon: isDark ? Icons.dark_mode : Icons.light_mode,
          trailing: Switch(
            value: isDark,
            onChanged: (value) {
              context.read<ThemeCubit>().toggleBrightness();
            },
            activeColor: colorScheme.primary,
          ),
          onTap: () {
            context.read<ThemeCubit>().toggleBrightness();
          },
        ),
      ],
    );
  }

  void _showThemeDialog() {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        final currentTheme = context.read<ThemeCubit>().state.themeType;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(AppStrings.getThemeColorSelection(currentLocale),
              style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeType.values.map((type) {
              final typeColorScheme =
                  AppColors.getColorScheme(type, Theme.of(context).brightness);
              return RadioListTile<ThemeType>(
                title: Text(type.displayName,
                    style: TextStyle(color: colorScheme.onSurface)),
                value: type,
                groupValue: currentTheme,
                activeColor: typeColorScheme.primary,
                secondary: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: typeColorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeCubit>().changeTheme(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getClose(currentLocale)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppSettings(AppLocale locale) {
    return Column(
      children: [
        SettingsListTile(
          title: AppStrings.getOnboarding(locale),
          subtitle: AppStrings.getOnboardingDescription(locale),
          icon: Icons.auto_awesome,
          onTap: () {
            RouterHelper.goToOnboarding(context, force: true);
          },
        ),
        SettingsListTile(
          title: AppStrings.getLanguageSettings(locale),
          subtitle: context.watch<LocaleCubit>().state.displayName,
          icon: Icons.language,
          onTap: _showLanguageDialog,
        ),
        SettingsListTile(
          title: AppStrings.getNumberFormatSettings(locale),
          subtitle: _getNumberFormatStyleDisplayName(
            context.watch<NumberFormatCubit>().state,
            locale,
          ),
          icon: Icons.numbers,
          onTap: _showNumberFormatDialog,
        ),
        SettingsListTile(
          title: AppStrings.getSendFeedback(locale),
          subtitle: AppStrings.getSendFeedbackDescription(locale),
          icon: Icons.mail_outline,
          onTap: _sendFeedbackEmail,
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

  void _showLanguageDialog() {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppStrings.getLanguageSelection(context.read<LocaleCubit>().state),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final loc in [
              AppLocale.korea,
              AppLocale.usa,
              AppLocale.china,
              AppLocale.japan,
              AppLocale.vietnam,
            ])
              _buildLanguageOption(loc.displayName, loc),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.getCancel(currentLocale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String title, AppLocale value) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
      trailing: context.watch<LocaleCubit>().state == value
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: () {
        context.read<LocaleCubit>().setLocale(value);
        Navigator.pop(context);
      },
    );
  }

  void _showNumberFormatDialog() {
    final currentLocale = context.read<LocaleCubit>().state;
    final currentFormat = context.read<NumberFormatCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppStrings.getNumberFormatSettings(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNumberFormatOption(
              AppStrings.getNumberFormatThousandsComma(currentLocale),
              NumberFormatStyle.thousandsComma,
              currentFormat,
            ),
            _buildNumberFormatOption(
              AppStrings.getNumberFormatDollarStyle(currentLocale),
              NumberFormatStyle.dollarStyle,
              currentFormat,
            ),
            _buildNumberFormatOption(
              AppStrings.getNumberFormatEuropeanStyle(currentLocale),
              NumberFormatStyle.europeanStyle,
              currentFormat,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.getCancel(currentLocale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberFormatOption(
    String title,
    NumberFormatStyle value,
    NumberFormatStyle currentValue,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
      trailing: currentValue == value
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: () {
        context.read<NumberFormatCubit>().setFormatStyle(value);
        Navigator.pop(context);
      },
    );
  }

  String _getNumberFormatStyleDisplayName(
    NumberFormatStyle style,
    AppLocale locale,
  ) {
    switch (style) {
      case NumberFormatStyle.thousandsComma:
        return AppStrings.getNumberFormatThousandsComma(locale);
      case NumberFormatStyle.dollarStyle:
        return AppStrings.getNumberFormatDollarStyle(locale);
      case NumberFormatStyle.europeanStyle:
        return AppStrings.getNumberFormatEuropeanStyle(locale);
    }
  }

  void _exportData() {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.save_alt, color: colorScheme.onSurface),
                title: Text(AppStrings.getSaveToDevice(currentLocale),
                    style: TextStyle(color: colorScheme.onSurface)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final dbPath = p.join(
                      await getDatabasesPath(),
                      'recipe_app.db',
                    );

                    Directory targetDir;
                    String platformInfo;

                    if (Platform.isAndroid) {
                      targetDir = Directory('/storage/emulated/0/Download');
                      if (!await targetDir.exists()) {
                        targetDir = await getApplicationDocumentsDirectory();
                        platformInfo = AppStrings.getDocumentsFolder(
                          currentLocale,
                        );
                      } else {
                        platformInfo = AppStrings.getDownloadFolder(
                          currentLocale,
                        );
                      }
                    } else {
                      targetDir = await getApplicationDocumentsDirectory();
                      platformInfo = AppStrings.getDocumentsFolder(
                        currentLocale,
                      );
                    }

                    final timestamp =
                        DateTime.now().toIso8601String().replaceAll(':', '-');
                    final outPath = p.join(
                      targetDir.path,
                      'recipe_app_export_$timestamp.db',
                    );
                    await File(dbPath).copy(outPath);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppStrings.getExportCompleteMessage(
                            currentLocale,
                            platformInfo,
                          ),
                        ),
                        backgroundColor: colorScheme.primary,
                        action: SnackBarAction(
                          label: AppStrings.getShare(currentLocale),
                          textColor: colorScheme.onPrimary,
                          onPressed: () async {
                            await Share.shareXFiles([
                              XFile(outPath),
                            ], text: AppStrings.getDatabaseFile(currentLocale));
                          },
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppStrings.getExportFailedMessage(
                            currentLocale,
                            e.toString(),
                          ),
                        ),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.ios_share, color: colorScheme.onSurface),
                title: Text(AppStrings.getShare(currentLocale),
                    style: TextStyle(color: colorScheme.onSurface)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final dbPath = p.join(
                      await getDatabasesPath(),
                      'recipe_app.db',
                    );
                    final tmpDir = await getTemporaryDirectory();
                    final timestamp =
                        DateTime.now().toIso8601String().replaceAll(':', '-');
                    final tmpPath = p.join(
                      tmpDir.path,
                      'recipe_app_export_$timestamp.db',
                    );
                    await File(dbPath).copy(tmpPath);
                    await Share.shareXFiles([
                      XFile(tmpPath),
                    ], text: AppStrings.getDatabaseFile(currentLocale));
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppStrings.getShareFailedMessage(
                            currentLocale,
                            e.toString(),
                          ),
                        ),
                        backgroundColor: colorScheme.error,
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
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final pickedPath = result.files.single.path!;
      final fileExtension = p.extension(pickedPath).toLowerCase();

      if (fileExtension != '.db') {
        if (!mounted) return;
        final currentLocale = context.read<LocaleCubit>().state;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getDatabaseFileOnly(currentLocale)),
            backgroundColor: colorScheme.error,
          ),
        );
        return;
      }

      await DatabaseHelper().close();
      final dbPath = p.join(await getDatabasesPath(), 'recipe_app.db');

      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      await File(pickedPath).copy(dbPath);

      await DatabaseHelper().database;

      if (!mounted) return;
      await Future.wait([
        context.read<IngredientCubit>().loadIngredients(),
        context.read<RecipeCubit>().loadRecipes(),
        context.read<SauceCubit>().loadSauces(),
        context.read<TagCubit>().loadAllTags(),
      ]);

      if (!mounted) return;
      final currentLocale = context.read<LocaleCubit>().state;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getImportComplete(currentLocale)),
          backgroundColor: colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final currentLocale = context.read<LocaleCubit>().state;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.getImportFailedMessage(currentLocale, e.toString()),
          ),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  void _resetData() {
    final currentLocale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          AppStrings.getDataReset(currentLocale),
          style: AppTextStyles.headline4.copyWith(color: colorScheme.onSurface),
        ),
        content: Text(
          AppStrings.getDataResetWarning(currentLocale),
          style:
              AppTextStyles.bodyMedium.copyWith(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.getCancel(currentLocale),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await DatabaseHelper().close();
                final dbPath = p.join(
                  await getDatabasesPath(),
                  'recipe_app.db',
                );
                await deleteDatabase(dbPath);

                await DatabaseHelper().database;

                if (!mounted) return;
                await Future.wait([
                  context.read<IngredientCubit>().loadIngredients(),
                  context.read<RecipeCubit>().loadRecipes(),
                  context.read<SauceCubit>().loadSauces(),
                  context.read<TagCubit>().loadAllTags(),
                ]);

                if (!mounted) return;
                Navigator.pop(context);
                final currentLocale = context.read<LocaleCubit>().state;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppStrings.getDataResetSuccess(currentLocale),
                    ),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                final currentLocale = context.read<LocaleCubit>().state;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppStrings.getResetFailedMessage(
                        currentLocale,
                        e.toString(),
                      ),
                    ),
                    backgroundColor: colorScheme.error,
                  ),
                );
              }
            },
            child: Text(
              AppStrings.getReset(currentLocale),
              style: AppTextStyles.buttonMedium.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog() async {
    final notifCubit = context.read<ExpiryNotificationCubit>();
    final initialTime = notifCubit.getNotificationTime();
    final colorScheme = Theme.of(context).colorScheme;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      notifCubit.setNotificationTime(pickedTime);
    }
  }

  void _sendFeedbackEmail() async {
    final Email email = Email(
      body: 'Feedback for Recipe App:\n\n',
      subject: '[Recipe App] Feedback',
      recipients: ['support@example.com'],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open email app: $error'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
