import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  /// exactAllowWhileIdle 실패 시 inexactAllowWhileIdle로 폴백 (exact_alarms_not_permitted 대응)
  static bool _useExactAlarms = true;
  static final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  /// 테스트에서 기기 타임존 조회를 대체하기 위한 시임.
  @visibleForTesting
  static Future<String> Function() timezoneNameProvider =
      FlutterTimezone.getLocalTimezone;

  /// initialize()에서 확정된 기기 타임존 이름 (초기화 실패 시 null 유지 →
  /// resume 시 refreshTimezoneIfChanged()가 재시도해 복구).
  String? _currentTimezoneName;
  bool _tzInitialized = false;

  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'expiry_notifications';
  static const String _channelName = '유통기한 알림';
  static const String _channelDescription = '재료/소스 유통기한 알림 채널';

  /// Wall-clock 성분을 [tz.local] 기준 TZDateTime으로 변환.
  ///
  /// `TZDateTime.from(DateTime, location)`은 millisecondsSinceEpoch(절대 시각)을
  /// 쓰므로 Dart VM 로컬과 `tz.local`이 다르면 현지 시각이 어긋난다.
  /// 유통기한 알림은 "현지 오전 9시" 같은 wall-clock이 기준이므로 성분 그대로 쓴다.
  @visibleForTesting
  static tz.TZDateTime toTzLocal(DateTime wallClock) {
    return tz.TZDateTime(
      tz.local,
      wallClock.year,
      wallClock.month,
      wallClock.day,
      wallClock.hour,
      wallClock.minute,
      wallClock.second,
      wallClock.millisecond,
      wallClock.microsecond,
    );
  }

  /// 매일 반복 알림의 다음 발생 시각 (tz.local wall-clock).
  @visibleForTesting
  static tz.TZDateTime nextDailyOccurrence(
    TimeOfDay timeOfDay, {
    tz.TZDateTime? now,
  }) {
    final n = now ?? tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      n.year,
      n.month,
      n.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    if (next.isBefore(n)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  /// 테스트/수동용: IANA 타임존으로 tz.local 설정.
  @visibleForTesting
  static void configureLocalTimezone(String locationName) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(locationName));
  }

  /// 테스트용: initialize() 없이 타임존 초기화 완료 상태로 표시.
  @visibleForTesting
  void debugMarkTimezoneInitialized(String? name) {
    _tzInitialized = true;
    _currentTimezoneName = name;
  }

  /// 앱 resume 시 기기 타임존 변경 감지. 바뀌었으면 tz.local을 갱신하고 true를
  /// 반환한다 — 호출자는 true일 때 알람을 재스케줄해야 한다.
  /// initialize() 전이거나 조회 실패 시에는 아무것도 하지 않는다.
  Future<bool> refreshTimezoneIfChanged() async {
    if (!_tzInitialized) return false;
    try {
      final tzName = await timezoneNameProvider();
      if (tzName == _currentTimezoneName) return false;
      tz.setLocalLocation(tz.getLocation(tzName));
      _currentTimezoneName = tzName;
      _logger.i('[ExpiryNotif] Timezone changed -> $tzName');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 알림 초기화. 탭 콜백을 전달하면 알림 탭 시 호출됩니다.
  /// iOS에서 권한을 요청하려면 requestIOSPermission을 true로 설정하세요.
  Future<void> initialize({
    Future<void> Function(String? payload)? onTap,
    bool requestIOSPermission = true, // iOS에서 권한 요청 여부
  }) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: requestIOSPermission,
      requestBadgePermission: requestIOSPermission,
      requestSoundPermission: requestIOSPermission,
    );
    final InitializationSettings settings = InitializationSettings(
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

    // Timezone 초기화 - flutter_timezone으로 기기 IANA 타임존 획득
    tz.initializeTimeZones();
    try {
      final tzName = await timezoneNameProvider();
      final deviceLocation = tz.getLocation(tzName);
      tz.setLocalLocation(deviceLocation);
      _currentTimezoneName = tzName;
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    _tzInitialized = true;
    // Android 채널 사전 생성 및 알림 권한 요청
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  NotificationDetails _details({String? body}) {
    final android = body != null && body.isNotEmpty
        ? AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
            styleInformation: BigTextStyleInformation(body),
          )
        : const AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.max,
            enableVibration: true,
            playSound: true,
          );
    const ios = DarwinNotificationDetails();
    return NotificationDetails(android: android, iOS: ios);
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
    // 더 안전한 ID 생성 - 32비트 범위 내로 보장
    final hash = input.hashCode.abs();
    return hash % 1000000; // 0~999,999 범위
  }

  /// 즉시 알림 표시
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(id, title, body, _details(body: body), payload: payload);
  }

  AndroidScheduleMode get _scheduleMode =>
      _useExactAlarms
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: _scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted' && _useExactAlarms) {
        _useExactAlarms = false;
        await _zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          details: details,
          payload: payload,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      } else {
        rethrow;
      }
    }
  }

  /// 지정 시각에 1회 알림
  Future<void> scheduleOneTime({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) async {
    await _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: toTzLocal(when),
      details: _details(body: body),
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
    await _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: nextDailyOccurrence(timeOfDay),
      details: _details(body: body),
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 일자·시각 기준 통합 알람 1개 스케줄 (여러 재료를 하나의 알림으로)
  Future<void> scheduleConsolidated({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    final id = _stableIdFromString(at.toIso8601String());
    _logger.d(
      '[ExpiryNotif] scheduleConsolidated: $title at ${at.toIso8601String()}',
    );
    await _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: toTzLocal(at),
      details: _details(body: body),
      payload: title,
    );
  }
}
