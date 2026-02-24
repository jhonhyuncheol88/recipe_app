import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/index.dart';
import '../../data/ingredient_repository.dart';
import '../../data/sauce_repository.dart';
import '../../service/sauce_expiry_service.dart';
import '../../service/notification_service.dart';
import '../../util/app_strings.dart';
import '../../util/app_locale.dart';

abstract class ExpiryNotificationState {}

class ExpiryNotificationInitial extends ExpiryNotificationState {}

class ExpiryNotificationsLoaded extends ExpiryNotificationState {
  final List<ExpiryNotification> notifications;
  ExpiryNotificationsLoaded(this.notifications);
}

class ExpiryNotificationCubit extends Cubit<ExpiryNotificationState> {
  final IngredientRepository ingredientRepository;
  final SauceRepository sauceRepository;
  final SauceExpiryService sauceExpiryService;
  final NotificationService _notificationService;
  final Uuid _uuid = const Uuid();
  static final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  // SharedPreferences keys
  static const String _kNotifEnabled = 'notif_enabled';
  static const String _kNotifWarning = 'notif_warning';
  static const String _kNotifDanger = 'notif_danger';
  static const String _kNotifExpired = 'notif_expired';
  static const String _kNotifTime = 'notif_time'; // 알람 시간 설정 추가

  bool notificationsEnabled = true;
  bool warningEnabled = true;
  bool dangerEnabled = true;
  bool expiredEnabled = true;
  TimeOfDay notificationTime = const TimeOfDay(
    hour: 9,
    minute: 0,
  ); // 기본값: 오전 9시

  // 시간 기준 임계값 (로컬 시간 기준)
  static const int dangerThresholdHours = 24; // 24시간 이내 → 위험
  static const int warningThresholdHours = 72; // 72시간 이내 → 경고

  ExpiryNotificationCubit({
    required this.ingredientRepository,
    required this.sauceRepository,
    required this.sauceExpiryService,
    required NotificationService notificationService,
  }) : _notificationService = notificationService,
       super(ExpiryNotificationInitial()) {
    _loadPrefsAndApply();
  }

  void setNotificationsEnabled(bool enabled) {
    notificationsEnabled = enabled;
    _logger.i('[ExpiryNotif] Notifications toggle -> $enabled');
    _savePrefs();
    if (!enabled) {
      _logger.i('[ExpiryNotif] Cancelling all scheduled notifications');
      _notificationService.cancelAll();
      emit(ExpiryNotificationsLoaded(const []));
    } else {
      _logger.i('[ExpiryNotif] Reloading and scheduling notifications');
      loadExpiryNotifications();
    }
  }

  void setWarningEnabled(bool enabled) {
    warningEnabled = enabled;
    _savePrefs();
    if (notificationsEnabled) {
      loadExpiryNotifications();
    } else {
      emit(ExpiryNotificationsLoaded(const []));
    }
  }

  void setDangerEnabled(bool enabled) {
    dangerEnabled = enabled;
    _savePrefs();
    if (notificationsEnabled) {
      loadExpiryNotifications();
    } else {
      emit(ExpiryNotificationsLoaded(const []));
    }
  }

  void setExpiredEnabled(bool enabled) {
    expiredEnabled = enabled;
    _savePrefs();
    if (notificationsEnabled) {
      loadExpiryNotifications();
    } else {
      emit(ExpiryNotificationsLoaded(const []));
    }
  }

  /// 알람 시간 설정
  void setNotificationTime(TimeOfDay time) {
    notificationTime = time;
    _savePrefs();
    if (notificationsEnabled) {
      loadExpiryNotifications();
    }
  }

  /// 현재 설정된 알람 시간 반환
  TimeOfDay getNotificationTime() {
    return notificationTime;
  }

  /// 재료와 소스의 만료 임계값에 따라 노티피케이션 목록 산출 (메모리 상)
  Future<void> loadExpiryNotifications() async {
    _logger.i('[ExpiryNotif] loadExpiryNotifications() start');
    final List<ExpiryNotification> list = [];

    if (!notificationsEnabled) {
      _logger.i('[ExpiryNotif] Skipped: notifications disabled');
      emit(ExpiryNotificationsLoaded(const []));
      return;
    }

    // 재료 알림 (시간 단위로 평가)
    final now = DateTime.now();
    final ingredients = await ingredientRepository.getAllIngredients();
    _logger.i('[ExpiryNotif] Fetched ingredients: ${ingredients.length}');
    for (final ing in ingredients) {
      if (ing.expiryDate == null) continue;
      final remaining = ing.expiryDate!.difference(now);
      NotificationType? type;
      if (remaining.isNegative) {
        type = NotificationType.expired;
      } else if (remaining.inHours <= dangerThresholdHours) {
        type = NotificationType.danger;
      } else if (remaining.inHours <= warningThresholdHours) {
        type = NotificationType.warning;
      }
      if (type != null && _isTypeEnabled(type)) {
        list.add(
          ExpiryNotification(
            id: _uuid.v4(),
            ingredientId: ing.id,
            ingredientName: ing.name,
            expiryDate: ing.expiryDate!,
            type: type,
            createdAt: now,
          ),
        );
      }
    }

    // 소스 알림 (소스 자체는 만료일 없음 → 구성 재료로 계산, 시간 단위 평가)
    final sauces = await sauceRepository.getAllSauces();
    _logger.i('[ExpiryNotif] Fetched sauces: ${sauces.length}');
    for (final sauce in sauces) {
      final expiry = await sauceExpiryService.getSauceExpiryDate(sauce.id);
      if (expiry == null) continue;
      final remaining = expiry.difference(now);
      NotificationType? type;
      if (remaining.isNegative) {
        type = NotificationType.expired;
      } else if (remaining.inHours <= dangerThresholdHours) {
        type = NotificationType.danger;
      } else if (remaining.inHours <= warningThresholdHours) {
        type = NotificationType.warning;
      }
      if (type != null && _isTypeEnabled(type)) {
        list.add(
          ExpiryNotification(
            id: _uuid.v4(),
            ingredientId: sauce.id,
            ingredientName: '[소스] ${sauce.name}',
            expiryDate: expiry,
            type: type,
            createdAt: now,
          ),
        );
      }
    }

    emit(ExpiryNotificationsLoaded(list));
    _logger.i('[ExpiryNotif] Computed notifications: ${list.length}');

    try {
      _logger.i('[ExpiryNotif] Clearing previous schedule...');
      await _notificationService.cancelAll();

      final prefs = await SharedPreferences.getInstance();
      final locale = _getLocaleFromPrefs(prefs);

      final grouped = <String, List<({String name, DateTime expiryAt})>>{};
      final now = DateTime.now();

      for (final n in list) {
        if (warningEnabled) {
          final at = DateTime(
            n.expiryDate.year,
            n.expiryDate.month,
            n.expiryDate.day - 3,
            notificationTime.hour,
            notificationTime.minute,
          );
          if (at.isAfter(now)) {
            final key = '${at.millisecondsSinceEpoch}';
            grouped.putIfAbsent(key, () => []).add((name: n.ingredientName, expiryAt: n.expiryDate));
          }
        }
        if (dangerEnabled) {
          final at = DateTime(
            n.expiryDate.year,
            n.expiryDate.month,
            n.expiryDate.day - 1,
            notificationTime.hour,
            notificationTime.minute,
          );
          if (at.isAfter(now)) {
            final key = '${at.millisecondsSinceEpoch}';
            grouped.putIfAbsent(key, () => []).add((name: n.ingredientName, expiryAt: n.expiryDate));
          }
        }
        if (expiredEnabled) {
          final at = DateTime(
            n.expiryDate.year,
            n.expiryDate.month,
            n.expiryDate.day,
            notificationTime.hour,
            notificationTime.minute,
          );
          if (at.isAfter(now)) {
            final key = '${at.millisecondsSinceEpoch}';
            grouped.putIfAbsent(key, () => []).add((name: n.ingredientName, expiryAt: n.expiryDate));
          }
        }
      }

      final title = AppStrings.getExpiryNotificationTitle(locale);
      final sectionToday = AppStrings.getExpirySectionToday(locale);
      final section1Day = AppStrings.getExpirySectionIn1Day(locale);
      final section3Days = AppStrings.getExpirySectionIn3Days(locale);

      for (final entry in grouped.entries) {
        final atMs = int.parse(entry.key);
        final at = DateTime.fromMillisecondsSinceEpoch(atMs);
        final notifDate = DateTime(at.year, at.month, at.day);

        final items = entry.value;
        final byDiff = <int, List<String>>{};
        for (final item in items) {
          final expDate = DateTime(item.expiryAt.year, item.expiryAt.month, item.expiryAt.day);
          final diff = expDate.difference(notifDate).inDays;
          if (diff == 0 || diff == 1 || diff == 3) {
            byDiff.putIfAbsent(diff, () => []).add(item.name);
          }
        }

        final sections = <String>[];
        if (byDiff.containsKey(0)) {
          sections.add(sectionToday);
          sections.addAll(byDiff[0]!);
        }
        if (byDiff.containsKey(1)) {
          sections.add(section1Day);
          sections.addAll(byDiff[1]!);
        }
        if (byDiff.containsKey(3)) {
          sections.add(section3Days);
          sections.addAll(byDiff[3]!);
        }
        final body = sections.join('\n');

        await _notificationService.scheduleConsolidated(
          at: at,
          title: title,
          body: body,
        );
      }

      _logger.i('[ExpiryNotif] Scheduling done: ${grouped.length} consolidated notifications');
      final pending = await _notificationService.getPending();
      _logger.i('[ExpiryNotif] Pending notifications: ${pending.length}');
      for (final p in pending) {
        _logger.d('[ExpiryNotif]   - id:${p.id} ${p.title}');
      }
    } catch (e) {
      _logger.e('[ExpiryNotif] Scheduling failed: $e');
    }
  }

  AppLocale _getLocaleFromPrefs(SharedPreferences prefs) {
    final saved = prefs.getString('app_locale_code');
    if (saved != null) {
      final found = AppLocale.fromLocaleCode(saved);
      if (found != null) return found;
    }
    return AppLocale.defaultLocale;
  }

  bool _isTypeEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.warning:
        return warningEnabled;
      case NotificationType.danger:
        return dangerEnabled;
      case NotificationType.expired:
        return expiredEnabled;
    }
  }

  Future<void> _loadPrefsAndApply() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      notificationsEnabled = prefs.getBool(_kNotifEnabled) ?? true;
      warningEnabled = prefs.getBool(_kNotifWarning) ?? true;
      dangerEnabled = prefs.getBool(_kNotifDanger) ?? true;
      expiredEnabled = prefs.getBool(_kNotifExpired) ?? true;

      // 알람 시간 로드
      final hour = prefs.getInt(_kNotifTime + '_hour') ?? 9;
      final minute = prefs.getInt(_kNotifTime + '_minute') ?? 0;
      notificationTime = TimeOfDay(hour: hour, minute: minute);

      _logger.i(
        '[ExpiryNotif] Prefs loaded -> enabled:$notificationsEnabled warning:$warningEnabled danger:$dangerEnabled expired:$expiredEnabled time:${notificationTime.hour}:${notificationTime.minute}',
      );
      // Emit empty list to trigger UI rebuild with restored toggles.
      // Actual scheduling will be triggered after NotificationService.initialize()
      // from main.dart.
      emit(ExpiryNotificationsLoaded(const []));
    } catch (e) {
      _logger.e('[ExpiryNotif] Prefs load failed: $e');
    }
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotifEnabled, notificationsEnabled);
      await prefs.setBool(_kNotifWarning, warningEnabled);
      await prefs.setBool(_kNotifDanger, dangerEnabled);
      await prefs.setBool(_kNotifExpired, expiredEnabled);

      // 알람 시간 저장
      await prefs.setInt(_kNotifTime + '_hour', notificationTime.hour);
      await prefs.setInt(_kNotifTime + '_minute', notificationTime.minute);

      _logger.i(
        '[ExpiryNotif] Prefs saved -> enabled:$notificationsEnabled warning:$warningEnabled danger:$dangerEnabled expired:$expiredEnabled time:${notificationTime.hour}:${notificationTime.minute}',
      );
    } catch (e) {
      _logger.e('[ExpiryNotif] Prefs save failed: $e');
    }
  }
}
