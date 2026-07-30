import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/service/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NotificationService service;

  setUp(() {
    NotificationService.configureLocalTimezone('Asia/Seoul');
    service = NotificationService();
  });

  tearDown(() {
    NotificationService.timezoneNameProvider = () async =>
        throw UnimplementedError('테스트에서 provider를 설정하세요');
  });

  test('초기화 전에는 아무것도 하지 않고 false', () async {
    NotificationService.timezoneNameProvider =
        () async => 'America/New_York';
    expect(await service.refreshTimezoneIfChanged(), isFalse);
    expect(tz.local.name, 'Asia/Seoul');
  });

  test('타임존이 동일하면 false', () async {
    service.debugMarkTimezoneInitialized('Asia/Seoul');
    NotificationService.timezoneNameProvider = () async => 'Asia/Seoul';
    expect(await service.refreshTimezoneIfChanged(), isFalse);
    expect(tz.local.name, 'Asia/Seoul');
  });

  test('타임존이 바뀌면 tz.local 갱신 후 true', () async {
    service.debugMarkTimezoneInitialized('Asia/Seoul');
    NotificationService.timezoneNameProvider =
        () async => 'America/New_York';
    expect(await service.refreshTimezoneIfChanged(), isTrue);
    expect(tz.local.name, 'America/New_York');

    // 같은 타임존으로 다시 호출하면 이제 false (내부 상태 갱신 확인)
    expect(await service.refreshTimezoneIfChanged(), isFalse);
  });

  test('초기화 실패(UTC 폴백, 이름 null) 후 resume에서 정상 조회되면 복구', () async {
    NotificationService.configureLocalTimezone('UTC');
    service.debugMarkTimezoneInitialized(null);
    NotificationService.timezoneNameProvider = () async => 'Asia/Seoul';
    expect(await service.refreshTimezoneIfChanged(), isTrue);
    expect(tz.local.name, 'Asia/Seoul');
  });

  test('조회 실패 시 기존 타임존 유지하고 false', () async {
    service.debugMarkTimezoneInitialized('Asia/Seoul');
    NotificationService.timezoneNameProvider =
        () async => throw Exception('platform channel 실패');
    expect(await service.refreshTimezoneIfChanged(), isFalse);
    expect(tz.local.name, 'Asia/Seoul');
  });

  test('존재하지 않는 타임존 이름이 오면 기존 타임존 유지하고 false', () async {
    service.debugMarkTimezoneInitialized('Asia/Seoul');
    NotificationService.timezoneNameProvider = () async => 'Not/AZone';
    expect(await service.refreshTimezoneIfChanged(), isFalse);
    expect(tz.local.name, 'Asia/Seoul');
  });
}
