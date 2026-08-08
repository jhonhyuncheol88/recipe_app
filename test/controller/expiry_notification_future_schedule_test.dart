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

/// notif.scheduledAts 중 [target] 날짜(09:00)가 포함됐는지.
bool _scheduledOnDay(_RecordingNotificationService notif, DateTime target) {
  final want = DateTime(target.year, target.month, target.day);
  return notif.scheduledAts
      .map((e) => DateTime(e.year, e.month, e.day))
      .contains(want);
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
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    await cubit.close();
    NotificationService.configureLocalTimezone('UTC');
  });

  // 오늘 09:00 이 이미 지났을 수 있으므로, "미래에 남는" 사전 알림만 검증한다.
  // 만료가 충분히 멀면 3일전/1일전/당일 09:00 은 모두 미래이므로 반드시 잡혀야 한다.

  test('만료 10일 후 재료 → 3일전·1일전·당일 사전 알림이 모두 스케줄돼야 한다', () async {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final expiry = base.add(const Duration(days: 10));

    ingredientRepo.setItems([
      _ing(id: 'a', name: '우유', expiry: expiry),
    ]);

    await cubit.loadExpiryNotifications();

    final expiryDate = DateTime(expiry.year, expiry.month, expiry.day);
    final threeDaysBefore = expiryDate.subtract(const Duration(days: 3));
    final oneDayBefore = expiryDate.subtract(const Duration(days: 1));

    expect(
      notif.scheduledAts,
      isNotEmpty,
      reason: '만료 10일 전 재료인데 아무 알림도 스케줄되지 않았다 (알람이 안 울리는 원인)',
    );
    expect(
      _scheduledOnDay(notif, threeDaysBefore),
      isTrue,
      reason: '3일 전 사전 알림($threeDaysBefore)이 스케줄돼야 한다',
    );
    expect(
      _scheduledOnDay(notif, oneDayBefore),
      isTrue,
      reason: '1일 전 사전 알림($oneDayBefore)이 스케줄돼야 한다',
    );
    expect(
      _scheduledOnDay(notif, expiryDate),
      isTrue,
      reason: '당일 알림($expiryDate)이 스케줄돼야 한다',
    );
  });

  test('만료 5일 후 재료 → 최소한 3일전 사전 알림은 스케줄돼야 한다', () async {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    final expiry = base.add(const Duration(days: 5));

    ingredientRepo.setItems([
      _ing(id: 'b', name: '두부', expiry: expiry),
    ]);

    await cubit.loadExpiryNotifications();

    final expiryDate = DateTime(expiry.year, expiry.month, expiry.day);
    final threeDaysBefore = expiryDate.subtract(const Duration(days: 3));

    expect(
      _scheduledOnDay(notif, threeDaysBefore),
      isTrue,
      reason: '만료 5일 후 재료의 3일 전 알림($threeDaysBefore)이 누락됨',
    );
  });
}
