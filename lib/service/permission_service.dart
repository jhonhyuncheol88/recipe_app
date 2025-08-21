import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // 갤러리 접근 권한 요청
  static Future<bool> requestGalleryPermission() async {
    // Android 13+ 에서는 photos 권한 사용
    if (await Permission.photos.isGranted) {
      return true;
    }
    
    // 권한이 거부된 경우 요청
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // 갤러리 권한 상태 확인
  static Future<bool> isGalleryPermissionGranted() async {
    return await Permission.photos.isGranted;
  }

  // 권한이 거부된 경우 앱 설정으로 이동
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // 권한 상태에 따른 메시지 반환
  static String getPermissionMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '권한이 허용되었습니다.';
      case PermissionStatus.denied:
        return '갤러리 접근 권한이 필요합니다.';
      case PermissionStatus.permanentlyDenied:
        return '권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.';
      case PermissionStatus.restricted:
        return '권한이 제한되었습니다.';
      case PermissionStatus.limited:
        return '권한이 제한적으로 허용되었습니다.';
      default:
        return '알 수 없는 권한 상태입니다.';
    }
  }
}
