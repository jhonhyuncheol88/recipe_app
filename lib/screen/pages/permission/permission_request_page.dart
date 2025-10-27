import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../theme/app_colors.dart';
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
    // initState에서는 context를 사용할 수 없으므로 build에서 초기화
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 진행 바
            _buildProgressBar(locale),

            // 권한 설명 페이지
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

            // 하단 버튼
            _buildBottomButtons(locale),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(AppLocale locale) {
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
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_currentPage + 1} / ${_permissions.length}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _permissions.length,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionPage(PermissionInfo info, AppLocale locale) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              info.icon,
              size: 60,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 32),

          // 제목
          Text(
            info.titleGetter(locale),
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // 설명
          Text(
            info.descriptionGetter(locale),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // 혜택 목록
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.getPermissionBenefitTitle(locale),
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.textPrimary,
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
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            benefitGetter(locale),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 안내 문구
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.getChangeLaterInfo(locale),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
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
                color: AppColors.textLight,
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
      print('🎯 권한 요청 시작: ${currentPermission.permissionType}');

      switch (currentPermission.permissionType) {
        case PermissionType.notification:
          if (Platform.isIOS) {
            // iOS에서는 NotificationService를 통해 iOS 네이티브 방식으로 요청
            print('🔔 iOS 네이티브 알림 권한 요청 시작');
            granted = await _requestIOSNotificationPermission();
          } else {
            // Android에서는 permission_handler 사용
            granted = await PermissionService.requestNotificationPermission();
          }
          break;
        case PermissionType.gallery:
          // iOS에서는 image_picker가 자동으로 네이티브 권한 팝업 표시
          // Android에서는 permission_handler 사용
          print('📸 갤러리 권한 요청 시작');
          granted = await PermissionService.requestGalleryPermission();
          break;
      }

      print('🎯 권한 요청 결과: $granted');

      if (granted) {
        // 권한 허용됨
        print('✅ 권한 허용됨 - 다음 페이지로 이동');
        _goToNextPage();
      } else {
        // 권한 거부됨 - 다음 페이지로 이동할지 물어봄
        print('❌ 권한 거부됨 - 거부 다이얼로그 표시');
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      // 에러 발생 시 다음 페이지로
      print('⚠️ 권한 요청 중 에러 발생: $e');
      _goToNextPage();
    }
  }

  /// iOS 네이티브 방식으로 알림 권한 요청
  Future<bool> _requestIOSNotificationPermission() async {
    try {
      print('🔔 iOS 네이티브 알림 권한 요청 시작');

      // flutter_local_notifications의 iOS 플랫폼 특정 구현을 통해 권한 요청
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      final iosImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      print('🔔 iOS 플랫폼 구현 얻기 완료');

      // iOS 권한 직접 요청
      if (iosImplementation != null) {
        print('🔔 iOS 권한 다이얼로그 표시');
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('✅ iOS 권한 요청 완료');

        // 잠시 대기
        await Future.delayed(const Duration(milliseconds: 500));

        // 권한 상태 확인
        final status = await ph.Permission.notification.status;
        print('🔔 iOS 알림 권한 상태: $status');

        // provisional도 허용으로 처리
        final result = status.isGranted || status.isProvisional;
        print(result ? '✅ iOS 알림 권한 허용됨' : '❌ iOS 알림 권한 거부됨');
        return result;
      } else {
        print('❌ iOS 플랫폼 구현을 찾을 수 없음');
        return false;
      }
    } catch (e) {
      print('❌ iOS 알림 권한 요청 실패: $e');
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
    // 권한 요청 완료 상태 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permission_requested', true);

    // 홈으로 이동
    if (mounted) {
      context.go('/');
    }
  }

  void _showPermissionDeniedDialog() {
    final locale = context.read<LocaleCubit>().state;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getPermissionDeniedTitle(locale)),
        content: Text(AppStrings.getPermissionDeniedMessage(locale)),
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
