import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/controller/notification/expiry_notification_cubit.dart';
import 'package:recipe_app/data/ingredient_repository.dart';
import 'package:recipe_app/data/sauce_repository.dart';
import 'package:recipe_app/model/index.dart';
import 'package:recipe_app/service/notification_service.dart';
import 'package:recipe_app/service/sauce_expiry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// 실제 스케줄 시각을 tz.local wall-clock 으로 변환해 기록.
class _RecordingNotificationService extends NotificationService {
  final List<tz.TZDateTime> scheduled = [];

  @override
  Future<void> cancelAll() async => scheduled.clear();

  @override
  Future<void> scheduleConsolidated({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    // 실제 서비스가 scheduleConsolidated 내부에서 toTzLocal(at) 로 변환하는 것과 동일.
    scheduled.add(NotificationService.toTzLocal(at));
  }

  @override
  Future<List<PendingNotificationRequest>> getPending() async => [];
}

class _FakeIngredientRepo extends IngredientRepository {
  _FakeIngredientRepo(this._items);
  List<Ingredient> _items;
  void setItems(List<Ingredient> items) => _items = items;

  @override
  Future<List<Ingredient>> getAllIngredients() async => _items;
}

class _FakeSauceRepo extends SauceRepository {
  @override
  Future<List<Sauce>> getAllSauces() async => [];
}

class _FakeSauceExpiry extends SauceExpiryService {
  _FakeSauceExpiry()
      : super(
          sauceRepository: _FakeSauceRepo(),
          ingredientRepository: _FakeIngredientRepo([]),
        );

  @override
  Future<DateTime?> getSauceExpiryDate(String sauceId) async => null;
}

Ingredient _ing(DateTime expiry) => Ingredient(
      id: 'a',
      name: '우유',
      purchasePrice: 1000,
      purchaseAmount: 1,
      purchaseUnitId: 'u1',
      expiryDate: expiry,
      createdAt: DateTime(2026, 1, 1),
      tagIds: const [],
    );

Future<_RecordingNotificationService> _scheduleInZone(
  String zone, {
  required TimeOfDay time,
}) async {
  NotificationService.configureLocalTimezone(zone);
  final notif = _RecordingNotificationService();
  final repo = _FakeIngredientRepo([
    // 충분히 먼 만료(10일 후) → 3일전/1일전/당일 모두 미래라 스케줄된다.
    _ing(DateTime.now().add(const Duration(days: 10))),
  ]);
  final cubit = ExpiryNotificationCubit(
    ingredientRepository: repo,
    sauceRepository: _FakeSauceRepo(),
    sauceExpiryService: _FakeSauceExpiry(),
    notificationService: notif,
  );
  await Future<void>.delayed(Duration.zero);
  cubit.notificationTime = time;
  await cubit.loadExpiryNotifications();
  await cubit.close();
  return notif;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => NotificationService.configureLocalTimezone('UTC'));

  const zones = [
    'Asia/Seoul',
    'America/New_York',
    'Europe/Berlin',
    'Asia/Ho_Chi_Minh',
    'America/Los_Angeles',
  ];

  for (final zone in zones) {
    test('$zone: 알람이 현지 09:00 wall-clock 으로 스케줄된다', () async {
      final notif = await _scheduleInZone(
        zone,
        time: const TimeOfDay(hour: 9, minute: 0),
      );

      expect(notif.scheduled, isNotEmpty, reason: '$zone: 스케줄 없음');
      for (final s in notif.scheduled) {
        expect(s.location.name, zone, reason: '$zone 타임존으로 잡혀야 함');
        expect(s.hour, 9, reason: '$zone: 현지 09시여야 함 ($s)');
        expect(s.minute, 0, reason: '$zone: 현지 00분이어야 함 ($s)');
      }
    });
  }

  test('같은 달력일 09:00 이라도 나라마다 절대(UTC) 시각이 다르다 = 진짜 현지시간', () async {
    final seoul = await _scheduleInZone(
      'Asia/Seoul',
      time: const TimeOfDay(hour: 9, minute: 0),
    );
    final ny = await _scheduleInZone(
      'America/New_York',
      time: const TimeOfDay(hour: 9, minute: 0),
    );

    // 서울 09:00(UTC+9) 과 뉴욕 09:00(UTC-4/-5) 은 같은 절대 순간이 아니다.
    final seoulUtcHours =
        seoul.scheduled.map((e) => e.toUtc().hour).toSet();
    final nyUtcHours = ny.scheduled.map((e) => e.toUtc().hour).toSet();

    // 서울 09:00 → 00:00 UTC
    expect(seoulUtcHours, {0}, reason: '서울 09시는 UTC 00시');
    // 뉴욕 09:00(여름 EDT=UTC-4) → 13:00 UTC
    expect(nyUtcHours.every((h) => h != 0), isTrue,
        reason: '뉴욕 09시는 서울과 다른 UTC 시각이어야 함');
  });

  test('설정 시각 14:30 도 각 나라 현지 14:30 으로 적용된다', () async {
    final berlin = await _scheduleInZone(
      'Europe/Berlin',
      time: const TimeOfDay(hour: 14, minute: 30),
    );
    expect(berlin.scheduled, isNotEmpty);
    for (final s in berlin.scheduled) {
      expect(s.location.name, 'Europe/Berlin');
      expect(s.hour, 14);
      expect(s.minute, 30);
    }
  });
}
