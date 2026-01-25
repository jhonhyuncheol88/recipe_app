import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../theme/app_text_styles.dart';
import '../../../service/permission_service.dart';
import '../../../util/app_strings.dart';
import '../../../util/app_locale.dart';
import '../../../controller/setting/locale_cubit.dart';
import '../../widget/app_button.dart';

class PermissionRequestPage extends StatefulWidget {
  const PermissionRequestPage({super.key});

  @override
  State<PermissionRequestPage> createState() => _PermissionRequestPageState();
}

class _PermissionRequestPageState extends State<PermissionRequestPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final List<PermissionInfo> _permissions;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _permissions = [
      PermissionInfo(
        icon: Icons.notifications_active,
        titleGetter: AppStrings.getNotificationPermissionTitle,
        descriptionGetter: AppStrings.getNotificationPermissionDescription,
        benefits: [
          AppStrings.getExpiryNotificationBenefit,
          AppStrings.getImportantUpdatesBenefit,
          AppStrings.getPersonalizedNotificationBenefit,
        ],
        permissionType: PermissionType.notification,
      ),
      PermissionInfo(
        icon: Icons.photo_library,
        titleGetter: AppStrings.getGalleryPermissionTitle,
        descriptionGetter: AppStrings.getGalleryPermissionDescription,
        benefits: [
          AppStrings.getReceiptOcrBenefit,
          AppStrings.getIngredientPhotosBenefit,
          AppStrings.getQuickRegistrationBenefit,
        ],
        permissionType: PermissionType.gallery,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(locale),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _permissions.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPermissionPage(_permissions[index], locale);
                },
              ),
            ),
            _buildBottomButtons(locale),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.getPermissionSetup(locale),
                style: AppTextStyles.headline4.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${_currentPage + 1} / ${_permissions.length}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _permissions.length,
              backgroundColor: colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPage(PermissionInfo info, AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              info.icon,
              size: 60,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            info.titleGetter(locale),
            style: AppTextStyles.headline2.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            info.descriptionGetter(locale),
            style: AppTextStyles.bodyLarge.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.getPermissionBenefitTitle(locale),
                      style: AppTextStyles.cardTitle.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...info.benefits.map((benefitGetter) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            benefitGetter(locale),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.getChangeLaterInfo(locale),
                    style: AppTextStyles.caption.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(AppLocale locale) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            onPressed: _handleAllowPermission,
            text: AppStrings.getAllowPermission(locale),
            icon: Icons.check,
            type: AppButtonType.primary,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _handleSkip,
            child: Text(
              AppStrings.getSkipForNow(locale),
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAllowPermission() async {
    final currentPermission = _permissions[_currentPage];
    bool granted = false;

    try {
      switch (currentPermission.permissionType) {
        case PermissionType.notification:
          if (Platform.isIOS) {
            granted = await _requestIOSNotificationPermission();
          } else {
            granted = await PermissionService.requestNotificationPermission();
          }
          break;
        case PermissionType.gallery:
          granted = await PermissionService.requestGalleryPermission();
          break;
      }

      if (granted) {
        _goToNextPage();
      } else {
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      _goToNextPage();
    }
  }

  Future<bool> _requestIOSNotificationPermission() async {
    try {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      final iosImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        await Future.delayed(const Duration(milliseconds: 500));

        final status = await ph.Permission.notification.status;
        final result = status.isGranted || status.isProvisional;
        return result;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _handleSkip() {
    _goToNextPage();
  }

  void _goToNextPage() {
    if (_currentPage < _permissions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completePermissionSetup();
    }
  }

  Future<void> _completePermissionSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permission_requested', true);

    if (mounted) {
      context.go('/');
    }
  }

  void _showPermissionDeniedDialog() {
    final locale = context.read<LocaleCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(AppStrings.getPermissionDeniedTitle(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        content: Text(AppStrings.getPermissionDeniedMessage(locale),
            style: TextStyle(color: colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            child: Text(AppStrings.getOpenSettings(locale)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _goToNextPage();
            },
            child: Text(AppStrings.getOnboardingNext(locale)),
          ),
        ],
      ),
    );
  }
}

enum PermissionType {
  notification,
  gallery,
}

class PermissionInfo {
  final IconData icon;
  final String Function(AppLocale) titleGetter;
  final String Function(AppLocale) descriptionGetter;
  final List<String Function(AppLocale)> benefits;
  final PermissionType permissionType;

  PermissionInfo({
    required this.icon,
    required this.titleGetter,
    required this.descriptionGetter,
    required this.benefits,
    required this.permissionType,
  });
}
