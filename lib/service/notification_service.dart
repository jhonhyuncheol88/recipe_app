import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'expiry_notifications';
  static const String _channelName = '유통기한 알림';
  static const String _channelDescription = '재료/소스 유통기한 알림 채널';

  /// 알림 초기화. 탭 콜백을 전달하면 알림 탭 시 호출됩니다.
  Future<void> initialize({
    Future<void> Function(String? payload)? onTap,
  }) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (resp) async {
        if (onTap != null) {
          await onTap(resp.payload);
        }
      },
    );

    // Timezone 초기화
    tz.initializeTimeZones();
    final localTz = DateTime.now().timeZoneName;
    tz.setLocalLocation(tz.getLocation('Asia/Seoul')); // 한국 시간대 기본값

    // Android 채널 사전 생성
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(channel);
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancelById(int id) async {
    await _plugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getPending() {
    return _plugin.pendingNotificationRequests();
  }

  int _stableIdFromString(String input) {
    // 간단한 해시 → 양수 보장
    final hash = input.hashCode & 0x7fffffff;
    return hash;
  }

  /// 즉시 알림 표시
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(id, title, body, _details(), payload: payload);
  }

  /// 지정 시각에 1회 알림
  Future<void> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    final tzTime = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      payload: payload,
    );
  }

  /// 매일 반복 알림 (예: 오전 9시)
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay timeOfDay,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      next,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> scheduleForItem({
    required String itemId,
    required String itemName,
    required DateTime expiryAt,
    bool warningEnabled = true,
    bool dangerEnabled = true,
    bool expiredEnabled = true,
  }) async {
    final now = DateTime.now();
    final baseId = _stableIdFromString(itemId) * 10;

    // 경고: 만료 72시간 전
    if (warningEnabled) {
      final at = expiryAt.subtract(const Duration(hours: 72));
      if (at.isAfter(now)) {
        await _plugin.zonedSchedule(
          baseId + 1,
          '[만료 경고] $itemName',
          '3일 이내에 만료됩니다.',
          tz.TZDateTime.from(at, tz.local),
          _details(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

          payload: 'warning:$itemId',
        );
      }
    }

    // 위험: 만료 24시간 전
    if (dangerEnabled) {
      final at = expiryAt.subtract(const Duration(hours: 24));
      if (at.isAfter(now)) {
        await _plugin.zonedSchedule(
          baseId + 2,
          '[만료 임박] $itemName',
          '1일 이내에 만료됩니다.',
          tz.TZDateTime.from(at, tz.local),
          _details(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

          payload: 'danger:$itemId',
        );
      }
    }

    // 만료 시점
    if (expiredEnabled) {
      final at = expiryAt;
      if (at.isAfter(now)) {
        await _plugin.zonedSchedule(
          baseId + 3,
          '[만료] $itemName',
          '유통기한이 지났습니다.',
          tz.TZDateTime.from(at, tz.local),
          _details(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

          payload: 'expired:$itemId',
        );
      }
    }
  }
}
