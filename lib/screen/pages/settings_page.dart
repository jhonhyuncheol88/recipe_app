import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../theme/tokens/tokens.dart';
import '../../util/app_strings.dart';
import '../../util/app_locale.dart';
import '../../util/number_format_style.dart';
import '../widget/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../controller/index.dart';
import '../../controller/setting/theme_cubit.dart';

import '../../service/backup_service.dart';
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
    final tokens = AppColorTokens.of(context);
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
        backgroundColor: tokens.bgBase,
        appBar: AppBar(
          title: Text(
            AppStrings.getSettings(currentLocale),
            style: AppTypography.heading2.copyWith(
              color: tokens.fgDefault,
            ),
          ),
          backgroundColor: tokens.bgBase,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            const _PremiumHeroBanner(),
            const _UserProfileCard(),
            const SizedBox(height: AppSpacing.s24),

            _SettingsSection(
              title: AppStrings.getNotificationSettings(currentLocale),
              children: _buildNotificationItems(currentLocale),
            ),
            const SizedBox(height: AppSpacing.s20),

            _SettingsSection(
              title: AppStrings.getDisplaySettings(currentLocale),
              children: _buildDisplayItems(currentLocale),
            ),
            const SizedBox(height: AppSpacing.s20),

            _SettingsSection(
              title: AppStrings.getDataManagement(currentLocale),
              children: _buildDataItems(currentLocale),
            ),
            const SizedBox(height: AppSpacing.s20),

            _SettingsSection(
              title: AppStrings.getOtherSettings(currentLocale),
              children: _buildOtherItems(currentLocale),
            ),
            const SizedBox(height: AppSpacing.s32),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── section item builders ─────────────────────────

  List<Widget> _buildNotificationItems(AppLocale locale) {
    final notifCubit = context.watch<ExpiryNotificationCubit>();
    final tokens = AppColorTokens.of(context);
    return [
      SettingsListTile(
        title: AppStrings.getEnableNotifications(locale),
        subtitle: AppStrings.getEnableNotificationsDescription(locale),
        icon: Icons.notifications,
        trailing: Switch(
          value: notifCubit.notificationsEnabled,
          onChanged: (value) {
            context
                .read<ExpiryNotificationCubit>()
                .setNotificationsEnabled(value);
          },
        ),
        onTap: null,
        showChevron: false,
      ),
      if (notifCubit.notificationsEnabled) ...[
        SettingsListTile(
          title: AppStrings.getExpiryWarningNotification(locale),
          subtitle: AppStrings.getExpiryWarningDescription(locale),
          icon: Icons.warning,
          iconColor: tokens.warning,
          iconBackgroundColor: tokens.warningSoft,
          trailing: Switch(
            value: notifCubit.warningEnabled,
            onChanged: (value) {
              context.read<ExpiryNotificationCubit>().setWarningEnabled(value);
            },
          ),
          onTap: null,
          showChevron: false,
        ),
        SettingsListTile(
          title: AppStrings.getExpiryDangerNotification(locale),
          subtitle: AppStrings.getExpiryDangerDescription(locale),
          icon: Icons.error,
          iconColor: tokens.negative,
          iconBackgroundColor: tokens.negativeSoft,
          trailing: Switch(
            value: notifCubit.dangerEnabled,
            onChanged: (value) {
              context.read<ExpiryNotificationCubit>().setDangerEnabled(value);
            },
          ),
          onTap: null,
          showChevron: false,
        ),
        SettingsListTile(
          title: AppStrings.getExpiryExpiredNotification(locale),
          subtitle: AppStrings.getExpiryExpiredDescription(locale),
          icon: Icons.block,
          iconColor: tokens.negative,
          iconBackgroundColor: tokens.negativeSoft,
          trailing: Switch(
            value: notifCubit.expiredEnabled,
            onChanged: (value) {
              context.read<ExpiryNotificationCubit>().setExpiredEnabled(value);
            },
          ),
          onTap: null,
          showChevron: false,
        ),
        SettingsListTile(
          title: AppStrings.getAlarmTimeSetting(locale),
          subtitle:
              '${notifCubit.getNotificationTime().hour.toString().padLeft(2, '0')}:${notifCubit.getNotificationTime().minute.toString().padLeft(2, '0')}',
          icon: Icons.access_time,
          onTap: _showTimePickerDialog,
        ),
      ],
    ];
  }

  List<Widget> _buildDisplayItems(AppLocale locale) {
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.state.brightness == Brightness.dark;

    return [
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
        ),
        onTap: () {
          context.read<ThemeCubit>().toggleBrightness();
        },
        showChevron: false,
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
    ];
  }

  List<Widget> _buildDataItems(AppLocale locale) {
    final tokens = AppColorTokens.of(context);
    return [
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
        iconColor: tokens.negative,
        iconBackgroundColor: tokens.negativeSoft,
        onTap: _resetData,
      ),
    ];
  }

  List<Widget> _buildOtherItems(AppLocale locale) {
    return [
      SettingsListTile(
        title: AppStrings.getOnboarding(locale),
        subtitle: AppStrings.getOnboardingDescription(locale),
        icon: Icons.auto_awesome,
        onTap: () {
          RouterHelper.goToOnboarding(context, force: true);
        },
      ),
      SettingsListTile(
        title: AppStrings.getSendFeedback(locale),
        subtitle: AppStrings.getSendFeedbackDescription(locale),
        icon: Icons.mail_outline,
        onTap: _sendFeedbackEmail,
      ),
    ];
  }

  // ───────────────────────── dialogs / actions ─────────────────────────

  void _showLanguageDialog() {
    final currentLocale = context.read<LocaleCubit>().state;
    final tokens = AppColorTokens.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.bgBase,
        title: Text(
          AppStrings.getLanguageSelection(context.read<LocaleCubit>().state),
          style: AppTypography.heading2.copyWith(color: tokens.fgDefault),
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
    final tokens = AppColorTokens.of(context);
    return ListTile(
      title: Text(title, style: TextStyle(color: tokens.fgDefault)),
      trailing: context.watch<LocaleCubit>().state == value
          ? Icon(Icons.check, color: tokens.primary)
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
    final tokens = AppColorTokens.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.bgBase,
        title: Text(
          AppStrings.getNumberFormatSettings(currentLocale),
          style: AppTypography.heading2.copyWith(color: tokens.fgDefault),
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
    final tokens = AppColorTokens.of(context);
    return ListTile(
      title: Text(title, style: TextStyle(color: tokens.fgDefault)),
      trailing: currentValue == value
          ? Icon(Icons.check, color: tokens.primary)
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
    final tokens = AppColorTokens.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: tokens.bgBase,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.save_alt, color: tokens.fgDefault),
                title: Text(AppStrings.getSaveToDevice(currentLocale),
                    style: TextStyle(color: tokens.fgDefault)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
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

                    final outPath = await BackupService().exportTo(targetDir);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppStrings.getExportCompleteMessage(
                            currentLocale,
                            platformInfo,
                          ),
                        ),
                        backgroundColor: tokens.primary,
                        action: SnackBarAction(
                          label: AppStrings.getShare(currentLocale),
                          textColor: tokens.fgOnPrimary,
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
                        backgroundColor: tokens.negative,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.ios_share, color: tokens.fgDefault),
                title: Text(AppStrings.getShare(currentLocale),
                    style: TextStyle(color: tokens.fgDefault)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final tmpPath = await BackupService().exportToTemp();
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
                        backgroundColor: tokens.negative,
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
    final tokens = AppColorTokens.of(context);
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
            backgroundColor: tokens.negative,
          ),
        );
        return;
      }

      // BackupService 가 SQLite 헤더/user_version 검증 + 기존 DB 백업 → 실패 시
      // 자동 롤백까지 처리.
      await BackupService().importFrom(pickedPath);

      if (!mounted) return;
      await _reloadAllState();

      if (!mounted) return;
      final currentLocale = context.read<LocaleCubit>().state;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getImportComplete(currentLocale)),
          backgroundColor: tokens.primary,
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
          backgroundColor: tokens.negative,
        ),
      );
    }
  }

  /// import / reset 후 모든 cubit 과 알림 스케줄을 새 DB 기준으로 다시 로드.
  Future<void> _reloadAllState() async {
    await Future.wait([
      context.read<IngredientCubit>().loadIngredients(),
      context.read<RecipeCubit>().loadRecipes(),
      context.read<SauceCubit>().loadSauces(),
      context.read<TagCubit>().loadAllTags(),
    ]);
    // 유통기한 알림: DB 변경 시 기존 스케줄이 stale 이므로 재계산.
    try {
      final notifCubit = context.read<ExpiryNotificationCubit>();
      if (notifCubit.notificationsEnabled) {
        await notifCubit.loadExpiryNotifications();
      }
    } catch (_) {
      // 알림 cubit 미존재/재로딩 실패는 critical 아님.
    }
  }

  void _resetData() {
    final currentLocale = context.read<LocaleCubit>().state;
    final tokens = AppColorTokens.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tokens.bgBase,
        title: Text(
          AppStrings.getDataReset(currentLocale),
          style: AppTypography.heading2.copyWith(color: tokens.fgDefault),
        ),
        content: Text(
          AppStrings.getDataResetWarning(currentLocale),
          style:
              AppTypography.body2.copyWith(color: tokens.fgDefault),
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
                await BackupService().resetDatabase();

                if (!mounted) return;
                await _reloadAllState();

                if (!mounted) return;
                Navigator.pop(context);
                final currentLocale = context.read<LocaleCubit>().state;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppStrings.getDataResetSuccess(currentLocale),
                    ),
                    backgroundColor: tokens.primary,
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
                    backgroundColor: tokens.negative,
                  ),
                );
              }
            },
            child: Text(
              AppStrings.getReset(currentLocale),
              style: AppTypography.label1.copyWith(
                color: tokens.negative,
                fontWeight: FontWeight.w700,
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

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
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
      final tokens = AppColorTokens.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open email app: $error'),
          backgroundColor: tokens.negative,
        ),
      );
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Top widgets — premium hero / user profile
// ════════════════════════════════════════════════════════════════════════════

/// 프리미엄 가입 유도 히어로 배너.
/// `PremiumActive` 상태에서는 자기 자신을 숨김(SizedBox.shrink).
class _PremiumHeroBanner extends StatelessWidget {
  const _PremiumHeroBanner();

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumCubit>().state;
    if (premium.isPremium) return const SizedBox.shrink();

    final locale = context.watch<LocaleCubit>().state;
    final tokens = AppColorTokens.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.brR16,
        child: InkWell(
          borderRadius: AppRadius.brR16,
          onTap: () => RouterHelper.goToPremium(context),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: AppRadius.brR16,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [tokens.primary, tokens.accentAi],
              ),
              boxShadow: [
                BoxShadow(
                  color: tokens.primary.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s20,
                vertical: AppSpacing.s20,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: AppRadius.brR12,
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.getPremiumMenuTitle(locale),
                          style: AppTypography.heading2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          AppStrings.getPremiumMenuSubtitle(locale),
                          style: AppTypography.body2.copyWith(
                            color: Colors.white.withOpacity(0.92),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 유저 프로필 카드 — 항상 노출. 탭하면 계정 정보 페이지(프리미엄 관리 포함).
class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final premium = context.watch<PremiumCubit>().state;
    final locale = context.watch<LocaleCubit>().state;
    final tokens = AppColorTokens.of(context);

    final isAuthed = auth is Authenticated;
    final user = isAuthed ? auth.user : null;

    return Material(
      color: tokens.bgElev1,
      borderRadius: AppRadius.brR16,
      child: InkWell(
        borderRadius: AppRadius.brR16,
        onTap: () => RouterHelper.goToAccountInfo(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.brR16,
            border: Border.all(color: tokens.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s16,
          ),
          child: Row(
            children: [
              _buildAvatar(user, tokens),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isAuthed
                                ? (user?.displayName ??
                                    AppStrings.getUser(locale))
                                : AppStrings.getNotSignedIn(locale),
                            style: AppTypography.headline2.copyWith(
                              color: tokens.fgStrong,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (premium.isPremium) ...[
                          const SizedBox(width: AppSpacing.s8),
                          _PremiumBadge(tokens: tokens, locale: locale),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      isAuthed
                          ? (user?.email ?? '')
                          : AppStrings.getSignInRequiredForFeature(locale),
                      style: AppTypography.body2.copyWith(
                        color: tokens.fgTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: tokens.fgTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(User? user, AppColorTokens tokens) {
    if (user == null) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: tokens.bgMuted,
        child: Icon(Icons.person_outline, color: tokens.fgTertiary, size: 24),
      );
    }
    final initial = (user.displayName?.isNotEmpty ?? false)
        ? user.displayName!.characters.first.toUpperCase()
        : (user.email?.isNotEmpty ?? false)
            ? user.email!.characters.first.toUpperCase()
            : '?';
    return CircleAvatar(
      radius: 24,
      backgroundColor: tokens.primarySoft,
      backgroundImage:
          user.photoURL != null ? NetworkImage(user.photoURL!) : null,
      child: user.photoURL == null
          ? Text(
              initial,
              style: AppTypography.title3.copyWith(
                color: tokens.primary,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  final AppColorTokens tokens;
  final AppLocale locale;
  const _PremiumBadge({required this.tokens, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: tokens.positiveSoft,
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, color: tokens.positive, size: 12),
          const SizedBox(width: AppSpacing.s4),
          Text(
            'Premium',
            style: AppTypography.caption2.copyWith(
              color: tokens.positive,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Section card grouping
// ════════════════════════════════════════════════════════════════════════════

/// 섹션 타이틀 + 카드(라운드 컨테이너) 그루핑.
/// 카드 내부 항목 사이에는 얇은 디바이더로 구획.
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppColorTokens.of(context);

    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i != children.length - 1) {
        separated.add(
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s64),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: tokens.borderSubtle,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.s4,
            bottom: AppSpacing.s8,
          ),
          child: Text(
            title,
            style: AppTypography.label1.copyWith(
              color: tokens.fgSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: tokens.bgElev1,
            borderRadius: AppRadius.brR16,
            border: Border.all(color: tokens.borderSubtle),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
          child: Column(children: separated),
        ),
      ],
    );
  }
}
