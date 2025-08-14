import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/index.dart';
import '../../data/ingredient_repository.dart';
import '../../data/sauce_repository.dart';
import '../../service/sauce_expiry_service.dart';
import '../../service/notification_service.dart';

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

  // SharedPreferences keys
  static const String _kNotifEnabled = 'notif_enabled';
  static const String _kNotifWarning = 'notif_warning';
  static const String _kNotifDanger = 'notif_danger';
  static const String _kNotifExpired = 'notif_expired';

  bool notificationsEnabled = true;
  bool warningEnabled = true;
  bool dangerEnabled = true;
  bool expiredEnabled = true;

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
    developer.log('Notifications toggle -> $enabled', name: 'ExpiryNotif');
    _savePrefs();
    if (!enabled) {
      // 예약된 모든 알림 취소
      developer.log(
        'Cancelling all scheduled notifications',
        name: 'ExpiryNotif',
      );
      _notificationService.cancelAll();
      emit(ExpiryNotificationsLoaded(const []));
    } else {
      // DB에서 다시 읽어 스케줄 등록
      developer.log(
        'Reloading and scheduling notifications',
        name: 'ExpiryNotif',
      );
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

  /// 재료와 소스의 만료 임계값에 따라 노티피케이션 목록 산출 (메모리 상)
  Future<void> loadExpiryNotifications() async {
    developer.log('loadExpiryNotifications() start', name: 'ExpiryNotif');
    final List<ExpiryNotification> list = [];

    // 알림 전역 OFF 시 빈 목록 반환
    if (!notificationsEnabled) {
      developer.log('Skipped: notifications disabled', name: 'ExpiryNotif');
      emit(ExpiryNotificationsLoaded(const []));
      return;
    }

    // 재료 알림 (시간 단위로 평가)
    final now = DateTime.now();
    final ingredients = await ingredientRepository.getAllIngredients();
    developer.log(
      'Fetched ingredients: ${ingredients.length}',
      name: 'ExpiryNotif',
    );
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
    developer.log('Fetched sauces: ${sauces.length}', name: 'ExpiryNotif');
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
    developer.log(
      'Computed notifications: ${list.length}',
      name: 'ExpiryNotif',
    );

    // 스케줄링: 알림 상태/토글에 맞춰 예약 등록
    try {
      developer.log('Clearing previous schedule...', name: 'ExpiryNotif');
      await _notificationService.cancelAll();
      for (final n in list) {
        developer.log(
          'Schedule -> ${n.ingredientName} at ${n.expiryDate.toIso8601String()} [warning:$warningEnabled danger:$dangerEnabled expired:$expiredEnabled]',
          name: 'ExpiryNotif',
        );
        await _notificationService.scheduleForItem(
          itemId: n.ingredientId,
          itemName: n.ingredientName,
          expiryAt: n.expiryDate,
          warningEnabled: warningEnabled,
          dangerEnabled: dangerEnabled,
          expiredEnabled: expiredEnabled,
        );
      }
      developer.log(
        'Scheduling done: ${list.length} items',
        name: 'ExpiryNotif',
      );
    } catch (e) {
      developer.log('Scheduling failed: $e', name: 'ExpiryNotif');
    }
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
      developer.log(
        'Prefs loaded -> enabled:$notificationsEnabled warning:$warningEnabled danger:$dangerEnabled expired:$expiredEnabled',
        name: 'ExpiryNotif',
      );
      // Emit empty list to trigger UI rebuild with restored toggles.
      // Actual scheduling will be triggered after NotificationService.initialize()
      // from main.dart.
      emit(ExpiryNotificationsLoaded(const []));
    } catch (e) {
      developer.log('Prefs load failed: $e', name: 'ExpiryNotif');
    }
  }

  Future<void> _savePrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotifEnabled, notificationsEnabled);
      await prefs.setBool(_kNotifWarning, warningEnabled);
      await prefs.setBool(_kNotifDanger, dangerEnabled);
      await prefs.setBool(_kNotifExpired, expiredEnabled);
      developer.log(
        'Prefs saved -> enabled:$notificationsEnabled warning:$warningEnabled danger:$dangerEnabled expired:$expiredEnabled',
        name: 'ExpiryNotif',
      );
    } catch (e) {
      developer.log('Prefs save failed: $e', name: 'ExpiryNotif');
    }
  }
}
