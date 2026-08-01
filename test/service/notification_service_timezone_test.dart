import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/service/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('NotificationService 현지시간(timezone) 스케줄', () {
    tearDown(() {
      // 테스트 간 tz.local 오염 방지
      NotificationService.configureLocalTimezone('UTC');
    });

    test('toTzLocal: Asia/Seoul wall-clock 9:00이 그대로 유지된다', () {
      NotificationService.configureLocalTimezone('Asia/Seoul');

      final wall = DateTime(2026, 8, 5, 9, 0);
      final scheduled = NotificationService.toTzLocal(wall);

      expect(scheduled.location.name, 'Asia/Seoul');
      expect(scheduled.year, 2026);
      expect(scheduled.month, 8);
      expect(scheduled.day, 5);
      expect(scheduled.hour, 9);
      expect(scheduled.minute, 0);
      // UTC 절대시각: KST = UTC+9 → 00:00 UTC
      expect(scheduled.toUtc().hour, 0);
    });

    test('toTzLocal: America/New_York wall-clock 9:00이 VM 로컬과 무관하게 유지된다', () {
      NotificationService.configureLocalTimezone('America/New_York');

      // DateTime(...)는 VM 로컬 성분이지만, toTzLocal은 year/month/day/hour/minute만 사용
      final wall = DateTime(2026, 8, 5, 9, 30);
      final scheduled = NotificationService.toTzLocal(wall);

      expect(scheduled.location.name, 'America/New_York');
      expect(scheduled.hour, 9);
      expect(scheduled.minute, 30);
      expect(scheduled.day, 5);
    });

    test('toTzLocal: 성분(년월일시분)을 tz.local wall-clock으로 보존한다', () {
      NotificationService.configureLocalTimezone('Pacific/Honolulu');

      final wall = DateTime(2026, 12, 1, 14, 15);
      final wallClock = NotificationService.toTzLocal(wall);

      expect(wallClock.location.name, 'Pacific/Honolulu');
      expect(wallClock.year, 2026);
      expect(wallClock.month, 12);
      expect(wallClock.day, 1);
      expect(wallClock.hour, 14);
      expect(wallClock.minute, 15);
    });

    test('nextDailyOccurrence: 아직 안 지난 시각이면 오늘', () {
      NotificationService.configureLocalTimezone('Asia/Seoul');
      final now = tz.TZDateTime(tz.local, 2026, 7, 30, 8, 0);

      final next = NotificationService.nextDailyOccurrence(
        const TimeOfDay(hour: 9, minute: 0),
        now: now,
      );

      expect(next.year, 2026);
      expect(next.month, 7);
      expect(next.day, 30);
      expect(next.hour, 9);
      expect(next.minute, 0);
      expect(next.location.name, 'Asia/Seoul');
    });

    test('nextDailyOccurrence: 이미 지난 시각이면 내일', () {
      NotificationService.configureLocalTimezone('Europe/Berlin');
      final now = tz.TZDateTime(tz.local, 2026, 7, 30, 10, 0);

      final next = NotificationService.nextDailyOccurrence(
        const TimeOfDay(hour: 9, minute: 0),
        now: now,
      );

      expect(next.day, 31);
      expect(next.hour, 9);
      expect(next.location.name, 'Europe/Berlin');
    });

    test('nextDailyOccurrence: 자정 넘김(월말)도 현지 달력 기준', () {
      NotificationService.configureLocalTimezone('Asia/Seoul');
      final now = tz.TZDateTime(tz.local, 2026, 1, 31, 22, 0);

      final next = NotificationService.nextDailyOccurrence(
        const TimeOfDay(hour: 9, minute: 0),
        now: now,
      );

      expect(next.year, 2026);
      expect(next.month, 2);
      expect(next.day, 1);
      expect(next.hour, 9);
    });

    test('configureLocalTimezone: 여러 타임존 전환 후에도 wall-clock 일치', () {
      for (final zone in ['Asia/Seoul', 'America/Los_Angeles', 'UTC', 'Asia/Ho_Chi_Minh']) {
        NotificationService.configureLocalTimezone(zone);
        final scheduled = NotificationService.toTzLocal(
          DateTime(2026, 8, 10, 9, 0),
        );
        expect(scheduled.location.name, zone, reason: zone);
        expect(scheduled.hour, 9, reason: zone);
        expect(scheduled.minute, 0, reason: zone);
      }
    });
  });
}
