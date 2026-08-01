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

/// 스케줄 호출만 기록하는 테스트용 서비스.
class _RecordingNotificationService extends NotificationService {
  final List<DateTime> scheduledAts = [];
  final List<({DateTime at, String title, String body})> calls = [];
  int cancelAllCount = 0;

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    scheduledAts.clear();
    calls.clear();
  }

  @override
  Future<void> scheduleConsolidated({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    // 실제 서비스와 동일하게 tz.local wall-clock으로 변환해 검증 가능
    final tzAt = NotificationService.toTzLocal(at);
    scheduledAts.add(DateTime(
      tzAt.year,
      tzAt.month,
      tzAt.day,
      tzAt.hour,
      tzAt.minute,
    ));
    calls.add((at: at, title: title, body: body));
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

Ingredient _ing({
  required String id,
  required String name,
  required DateTime expiry,
}) {
  return Ingredient(
    id: id,
    name: name,
    purchasePrice: 1000,
    purchaseAmount: 1,
    purchaseUnitId: 'u1',
    expiryDate: expiry,
    createdAt: DateTime(2026, 1, 1),
    tagIds: const [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingNotificationService notif;
  late _FakeIngredientRepo ingredientRepo;
  late ExpiryNotificationCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    NotificationService.configureLocalTimezone('Asia/Seoul');
    notif = _RecordingNotificationService();
    ingredientRepo = _FakeIngredientRepo([]);
    cubit = ExpiryNotificationCubit(
      ingredientRepository: ingredientRepo,
      sauceRepository: _FakeSauceRepo(),
      sauceExpiryService: _FakeSauceExpiry(),
      notificationService: notif,
    );
    // prefs 로드 완료 대기
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    await cubit.close();
    NotificationService.configureLocalTimezone('UTC');
  });

  test('기본 알람 시각(09:00)으로 3일전·1일전·당일 스케줄', () async {
    // 유통기한: 오늘+10일 → warning/danger/expired 모두 미래 스케줄 가능
    // 목록에 들어가려면 remaining.inHours <= 72 (warning) 이어야 함
    // → 만료가 48시간 후인 재료 사용 (danger 구간, 당일·1일전만 미래일 수 있음)
    final now = DateTime.now();
    final expiry = DateTime(now.year, now.month, now.day).add(
      const Duration(days: 2, hours: 12),
    ); // ~2.5일 후 → warning(≤72h)

    ingredientRepo.setItems([
      _ing(id: 'a', name: '양파', expiry: expiry),
    ]);

    await cubit.loadExpiryNotifications();

    expect(notif.cancelAllCount, greaterThan(0));
    expect(notif.scheduledAts, isNotEmpty);

    // 모든 스케줄이 기본 09:00
    for (final at in notif.scheduledAts) {
      expect(at.hour, 9, reason: 'scheduled at $at');
      expect(at.minute, 0, reason: 'scheduled at $at');
    }

    // 당일 = expiry 날짜 09:00, 1일전, 3일전이 포함될 수 있음
    final expiryDate = DateTime(expiry.year, expiry.month, expiry.day);
    final hours = notif.scheduledAts.map((e) => e.hour).toSet();
    expect(hours, {9});

    final days = notif.scheduledAts
        .map((e) => DateTime(e.year, e.month, e.day))
        .toSet();
    expect(days.contains(expiryDate), isTrue); // 당일
    expect(
      days.contains(expiryDate.subtract(const Duration(days: 1))),
      isTrue,
    ); // 1일전
  });

  test('setNotificationTime(14:30) 후 재스케줄되면 현지 14:30으로 갱신', () async {
    final now = DateTime.now();
    final expiry = DateTime(now.year, now.month, now.day).add(
      const Duration(days: 2, hours: 12),
    );
    ingredientRepo.setItems([
      _ing(id: 'a', name: '당근', expiry: expiry),
    ]);

    await cubit.loadExpiryNotifications();
    expect(notif.scheduledAts.every((e) => e.hour == 9), isTrue);

    cubit.setNotificationTime(const TimeOfDay(hour: 14, minute: 30));
    // setNotificationTime → loadExpiryNotifications (async)
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await cubit.loadExpiryNotifications();

    expect(notif.scheduledAts, isNotEmpty);
    for (final at in notif.scheduledAts) {
      expect(at.hour, 14, reason: 'after time change: $at');
      expect(at.minute, 30, reason: 'after time change: $at');
    }
  });

  test('알림 OFF → cancelAll, ON → 다시 스케줄', () async {
    final now = DateTime.now();
    final expiry = DateTime(now.year, now.month, now.day).add(
      const Duration(days: 1, hours: 6),
    );
    ingredientRepo.setItems([
      _ing(id: 'a', name: '마늘', expiry: expiry),
    ]);

    await cubit.loadExpiryNotifications();
    expect(notif.scheduledAts, isNotEmpty);

    cubit.setNotificationsEnabled(false);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(notif.scheduledAts, isEmpty);

    cubit.setNotificationsEnabled(true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await cubit.loadExpiryNotifications();
    expect(notif.scheduledAts, isNotEmpty);
  });

  test('스케줄 DateTime → toTzLocal 변환 시 Asia/Seoul wall-clock 유지', () async {
    NotificationService.configureLocalTimezone('Asia/Seoul');
    final now = DateTime.now();
    final expiry = DateTime(now.year, now.month, now.day).add(
      const Duration(days: 2, hours: 12),
    );
    ingredientRepo.setItems([
      _ing(id: 'a', name: '파', expiry: expiry),
    ]);
    cubit.setNotificationTime(const TimeOfDay(hour: 9, minute: 0));
    await cubit.loadExpiryNotifications();

    for (final call in notif.calls) {
      final tzAt = NotificationService.toTzLocal(call.at);
      expect(tzAt.location.name, 'Asia/Seoul');
      expect(tzAt.hour, call.at.hour);
      expect(tzAt.minute, call.at.minute);
      expect(tzAt.day, call.at.day);
    }
  });

  test('과거 알람 시각은 스케줄에서 제외', () async {
    final now = DateTime.now();
    // 오늘 만료 + 알람 01:00 → 현재가 01:00 이후면 당일/1일전/3일전 중 과거는 제외
    final expiry = DateTime(now.year, now.month, now.day, 23, 59);
    ingredientRepo.setItems([
      _ing(id: 'a', name: '오늘만료', expiry: expiry),
    ]);

    cubit.notificationTime = const TimeOfDay(hour: 1, minute: 0);
    await cubit.loadExpiryNotifications();

    final threshold = DateTime.now().subtract(const Duration(seconds: 2));
    for (final at in notif.scheduledAts) {
      expect(at.isAfter(threshold), isTrue, reason: 'past schedule leaked: $at');
    }
  });
}

