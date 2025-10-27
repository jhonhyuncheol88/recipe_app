import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionService {
  // === 갤러리 권한 ===

  // 갤러리 접근 권한 요청
  static Future<bool> requestGalleryPermission() async {
    print('📸 갤러리 권한 요청 시작');

    // iOS와 Android에서 적절한 권한 사용
    final permission =
        Platform.isIOS ? ph.Permission.photos : ph.Permission.photos;

    // 현재 권한 상태 확인
    final currentStatus = await permission.status;
    print('📸 현재 갤러리 권한 상태: $currentStatus');

    if (currentStatus.isGranted) {
      print('✅ 갤러리 권한 이미 허용됨');
      return true;
    }

    // 권한이 제한적으로 허용된 경우 (iOS 14+)
    if (currentStatus.isLimited) {
      print('✅ 갤러리 권한 제한적으로 허용됨');
      return true;
    }

    // 권한 요청
    print('📸 갤러리 권한 시스템 다이얼로그 표시');
    final status = await permission.request();
    print('📸 갤러리 권한 요청 결과: $status');

    final result = status.isGranted || status.isLimited || status.isProvisional;
    print(result ? '✅ 갤러리 권한 허용됨' : '❌ 갤러리 권한 거부됨');
    return result;
  }

  // 갤러리 권한 상태 확인
  static Future<bool> isGalleryPermissionGranted() async {
    final permission =
        Platform.isIOS ? ph.Permission.photos : ph.Permission.photos;

    // 최신 상태 확인
    final status = await permission.status;
    return status.isGranted || status.isLimited || status.isProvisional;
  }

  // === 카메라 권한 ===

  // 카메라 권한 요청
  static Future<bool> requestCameraPermission() async {
    print('📷 카메라 권한 요청 시작');

    // 현재 권한 상태 확인
    final currentStatus = await ph.Permission.camera.status;
    print('📷 현재 카메라 권한 상태: $currentStatus');

    if (currentStatus.isGranted) {
      print('✅ 카메라 권한 이미 허용됨');
      return true;
    }

    // 권한 요청
    print('📷 카메라 권한 시스템 다이얼로그 표시');
    final status = await ph.Permission.camera.request();
    print('📷 카메라 권한 요청 결과: $status');

    final result = status.isGranted;
    print(result ? '✅ 카메라 권한 허용됨' : '❌ 카메라 권한 거부됨');
    return result;
  }

  // 카메라 권한 상태 확인
  static Future<bool> isCameraPermissionGranted() async {
    return await ph.Permission.camera.isGranted;
  }

  // === 알림 권한 ===

  // 알림 권한 요청
  static Future<bool> requestNotificationPermission() async {
    print('🔔 알림 권한 요청 시작');

    // 현재 권한 상태 확인
    final currentStatus = await ph.Permission.notification.status;
    print('🔔 현재 알림 권한 상태: $currentStatus');

    if (currentStatus.isGranted || currentStatus.isProvisional) {
      print('✅ 알림 권한 이미 허용됨 (granted or provisional)');
      return true;
    }

    // 권한 요청
    print('🔔 알림 권한 시스템 다이얼로그 표시');
    final status = await ph.Permission.notification.request();
    print('🔔 알림 권한 요청 결과: $status');

    // iOS에서는 provisional도 허용으로 처리
    final result = status.isGranted || status.isProvisional;
    print(result ? '✅ 알림 권한 허용됨' : '❌ 알림 권한 거부됨');
    return result;
  }

  // 알림 권한 상태 확인
  static Future<bool> isNotificationPermissionGranted() async {
    final status = await ph.Permission.notification.status;
    return status.isGranted || status.isProvisional;
  }

  // === 공통 메서드 ===

  // 권한이 거부된 경우 앱 설정으로 이동
  static Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  // 권한 상태에 따른 메시지 반환
  static String getPermissionMessage(ph.PermissionStatus status) {
    switch (status) {
      case ph.PermissionStatus.granted:
        return '권한이 허용되었습니다.';
      case ph.PermissionStatus.denied:
        return '갤러리 접근 권한이 필요합니다.';
      case ph.PermissionStatus.permanentlyDenied:
        return '권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.';
      case ph.PermissionStatus.restricted:
        return '권한이 제한되었습니다.';
      case ph.PermissionStatus.limited:
        return '권한이 제한적으로 허용되었습니다.';
      default:
        return '알 수 없는 권한 상태입니다.';
    }
  }
}
