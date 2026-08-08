import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/controller/ingredient/ingredient_cubit.dart';
import 'package:recipe_app/controller/notification/expiry_notification_cubit.dart';
import 'package:recipe_app/data/ingredient_repository.dart';
import 'package:recipe_app/data/sauce_repository.dart';
import 'package:recipe_app/data/tag_repository.dart';
import 'package:recipe_app/model/index.dart';
import 'package:recipe_app/service/notification_service.dart';
import 'package:recipe_app/service/sauce_expiry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 스케줄 호출만 기록하는 테스트용 서비스.
class _RecordingNotificationService extends NotificationService {
  final List<DateTime> scheduledAts = [];
  int cancelAllCount = 0;

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    scheduledAts.clear();
  }

  @override
  Future<void> scheduleConsolidated({
    required DateTime at,
    required String title,
    required String body,
  }) async {
    final tzAt = NotificationService.toTzLocal(at);
    scheduledAts.add(
      DateTime(tzAt.year, tzAt.month, tzAt.day, tzAt.hour, tzAt.minute),
    );
  }

  @override
  Future<List<PendingNotificationRequest>> getPending() async => [];
}

/// 수정(updateIngredient)을 지원하는 인메모리 재료 저장소.
class _FakeIngredientRepo extends IngredientRepository {
  _FakeIngredientRepo(this._items);
  List<Ingredient> _items;

  void setItems(List<Ingredient> items) => _items = items;

  @override
  Future<List<Ingredient>> getAllIngredients() async => _items;

  @override
  Future<void> updateIngredient(Ingredient ingredient) async {
    _items = [
      for (final i in _items)
        if (i.id == ingredient.id) ingredient else i,
    ];
  }
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

class _FakeTagRepo extends TagRepository {}

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
  late ExpiryNotificationCubit expiryCubit;
  late IngredientCubit ingredientCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    NotificationService.configureLocalTimezone('Asia/Seoul');
    notif = _RecordingNotificationService();
    ingredientRepo = _FakeIngredientRepo([]);
    expiryCubit = ExpiryNotificationCubit(
      ingredientRepository: ingredientRepo,
      sauceRepository: _FakeSauceRepo(),
      sauceExpiryService: _FakeSauceExpiry(),
      notificationService: notif,
    );
    ingredientCubit = IngredientCubit(
      ingredientRepository: ingredientRepo,
      tagRepository: _FakeTagRepo(),
      expiryNotificationCubit: expiryCubit,
    );
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    await ingredientCubit.close();
    await expiryCubit.close();
    NotificationService.configureLocalTimezone('UTC');
  });

  test('유통기한을 더 임박한 날짜로 수정하면 재스케줄된다 (배선 확인)', () async {
    final base = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    // 초기: 2일 후 만료 (≤72h → 스케줄됨)
    ingredientRepo.setItems([
      _ing(id: 'a', name: '요구르트', expiry: base.add(const Duration(days: 2))),
    ]);
    await expiryCubit.loadExpiryNotifications();
    expect(notif.scheduledAts, isNotEmpty);

    // 수정: 유통기한을 1일 후로 변경 → updateIngredient 경로가 재스케줄해야 함
    final edited = _ing(
      id: 'a',
      name: '요구르트',
      expiry: base.add(const Duration(days: 1)),
    );
    await ingredientCubit.updateIngredient(edited);

    expect(
      notif.cancelAllCount,
      greaterThan(1),
      reason: '수정 시 cancelAll 후 재스케줄이 일어나야 한다',
    );
    // 수정된 만료(1일 후) 당일 알림이 반영돼야 한다
    expect(
      _scheduledOnDay(notif, base.add(const Duration(days: 1))),
      isTrue,
      reason: '수정된 유통기한(1일 후)이 스케줄에 반영되지 않았다',
    );
  });

  test('유통기한을 더 먼 날짜(10일 후)로 수정해도 3일 전 사전 알림이 스케줄된다', () async {
    final base = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    // 초기: 2일 후 만료 → 임박 알림 스케줄됨
    ingredientRepo.setItems([
      _ing(id: 'a', name: '생크림', expiry: base.add(const Duration(days: 2))),
    ]);
    await expiryCubit.loadExpiryNotifications();
    expect(notif.scheduledAts, isNotEmpty);

    // 수정: "아직 여유 있으니 3일 전에 알려줘" 기대하며 10일 후로 변경
    final edited = _ing(
      id: 'a',
      name: '생크림',
      expiry: base.add(const Duration(days: 10)),
    );
    await ingredientCubit.updateIngredient(edited);

    // 3일 전(=7일 후) 사전 알림이 스케줄돼야 한다.
    // (수정 전에는 cancelAll 로 기존 알림만 지워지고 10일 후 재료는 ≤72h 아니라 제외돼
    //  아무것도 안 잡혔다 → 이 테스트가 회귀 방지 역할을 한다.)
    expect(
      _scheduledOnDay(notif, base.add(const Duration(days: 7))),
      isTrue,
      reason: '유통기한을 10일 후로 수정했는데 3일 전 알림이 스케줄되지 않았다',
    );
  });
}
