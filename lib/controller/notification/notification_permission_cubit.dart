import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

abstract class NotificationPermissionState {
  const NotificationPermissionState();
}

class NotificationPermissionUnknown extends NotificationPermissionState {
  const NotificationPermissionUnknown();
}

class NotificationPermissionGranted extends NotificationPermissionState {
  const NotificationPermissionGranted();
}

class NotificationPermissionDenied extends NotificationPermissionState {
  const NotificationPermissionDenied();
}

class NotificationPermissionCubit extends Cubit<NotificationPermissionState> {
  NotificationPermissionCubit() : super(const NotificationPermissionUnknown());

  Future<void> refresh() async {
    final s = await Permission.notification.status;
    emit(
      s.isGranted
          ? const NotificationPermissionGranted()
          : const NotificationPermissionDenied(),
    );
  }

  Future<void> request() async {
    try {
      if (Platform.isIOS) {
        final ios = FlutterLocalNotificationsPlugin()
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        await ios?.requestPermissions(alert: true, badge: true, sound: true);
      }
      final res = await Permission.notification.request();
      await Future.delayed(const Duration(milliseconds: 200));
      final finalStatus = await Permission.notification.status;
      emit(
        (res.isGranted || finalStatus.isGranted)
            ? const NotificationPermissionGranted()
            : const NotificationPermissionDenied(),
      );
    } catch (_) {
      emit(const NotificationPermissionDenied());
    }
  }
}
