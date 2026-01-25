import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// 인앱 리뷰 서비스
/// 리뷰 요청을 관리하고 적절한 시점에 리뷰를 요청합니다.
class InAppReviewService {
  static final InAppReviewService _instance = InAppReviewService._internal();
  factory InAppReviewService() => _instance;
  InAppReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  // SharedPreferences 키
  static const String _lastReviewRequestKey = 'last_review_request_time';
  static const String _reviewRequestCountKey = 'review_request_count';
  static const String _userReviewedKey = 'user_reviewed';
  static const String _userDeclinedKey = 'user_declined';

  // 리뷰 요청 간격 (3일로 설정 - 더 자주 나타나도록)
  static const Duration _reviewCooldown = Duration(days: 3);
  
  // 최대 리뷰 요청 횟수 (너무 자주 요청하지 않도록)
  static const int _maxReviewRequests = 10;

  /// 리뷰 요청 가능 여부 확인
  Future<bool> canRequestReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 사용자가 이미 리뷰를 작성했거나 거부한 경우
      final userReviewed = prefs.getBool(_userReviewedKey) ?? false;
      final userDeclined = prefs.getBool(_userDeclinedKey) ?? false;
      
      if (userReviewed) {
        _logger.d('ℹ️ 사용자가 이미 리뷰를 작성했습니다.');
        return false;
      }
      
      if (userDeclined) {
        // 거부한 경우에도 7일 후 다시 요청 가능하도록
        final lastDeclinedTime = prefs.getInt('${_userDeclinedKey}_time') ?? 0;
        final daysSinceDeclined = 
            (DateTime.now().millisecondsSinceEpoch - lastDeclinedTime) ~/ 
            (1000 * 60 * 60 * 24);
        
        if (daysSinceDeclined < 7) {
          _logger.d('ℹ️ 사용자가 리뷰를 거부했습니다. 7일 후 다시 요청 가능.');
          return false;
        }
      }

      // 리뷰 요청 횟수 확인
      final requestCount = prefs.getInt(_reviewRequestCountKey) ?? 0;
      if (requestCount >= _maxReviewRequests) {
        _logger.d('ℹ️ 최대 리뷰 요청 횟수에 도달했습니다.');
        return false;
      }

      // 마지막 리뷰 요청 시간 확인
      final lastRequestTime = prefs.getInt(_lastReviewRequestKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeSinceLastRequest = currentTime - lastRequestTime;
      
      if (timeSinceLastRequest < _reviewCooldown.inMilliseconds) {
        final daysRemaining = 
            (_reviewCooldown.inMilliseconds - timeSinceLastRequest) ~/ 
            (1000 * 60 * 60 * 24);
        _logger.d('ℹ️ 리뷰 요청 쿨다운 중. ${daysRemaining + 1}일 후 다시 요청 가능.');
        return false;
      }

      return true;
    } catch (e) {
      _logger.e('❌ 리뷰 요청 가능 여부 확인 중 오류: $e');
      return false;
    }
  }

  /// 인앱 리뷰 요청
  /// 
  /// [forceRequest]: true인 경우 쿨다운을 무시하고 강제로 요청합니다.
  Future<bool> requestReview({bool forceRequest = false}) async {
    try {
      if (!forceRequest && !await canRequestReview()) {
        return false;
      }

      _logger.i('⭐ 인앱 리뷰 요청 시작');

      // InAppReview가 사용 가능한지 확인
      if (await _inAppReview.isAvailable()) {
        // 리뷰 요청 시간 기록
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
          _lastReviewRequestKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        
        // 요청 횟수 증가
        final currentCount = prefs.getInt(_reviewRequestCountKey) ?? 0;
        await prefs.setInt(_reviewRequestCountKey, currentCount + 1);

        // 리뷰 요청
        await _inAppReview.requestReview();
        
        _logger.i('✅ 인앱 리뷰 요청 완료');
        
        // 리뷰 작성 여부는 사용자가 직접 확인할 수 없으므로
        // 요청 후 일정 시간이 지나면 다시 요청 가능하도록 설정
        return true;
      } else {
        _logger.w('⚠️ 인앱 리뷰를 사용할 수 없습니다.');
        
        // 사용할 수 없는 경우 스토어로 이동
        await _inAppReview.openStoreListing();
        return false;
      }
    } catch (e) {
      _logger.e('❌ 인앱 리뷰 요청 중 오류: $e');
      return false;
    }
  }

  /// 사용자가 리뷰를 작성했다고 표시
  /// (실제로는 확인할 수 없지만, 사용자가 직접 알려준 경우 사용)
  Future<void> markAsReviewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_userReviewedKey, true);
      _logger.i('✅ 사용자 리뷰 작성 완료로 표시');
    } catch (e) {
      _logger.e('❌ 리뷰 작성 표시 중 오류: $e');
    }
  }

  /// 사용자가 리뷰를 거부했다고 표시
  Future<void> markAsDeclined() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_userDeclinedKey, true);
      await prefs.setInt(
        '${_userDeclinedKey}_time',
        DateTime.now().millisecondsSinceEpoch,
      );
      _logger.i('ℹ️ 사용자 리뷰 거부로 표시');
    } catch (e) {
      _logger.e('❌ 리뷰 거부 표시 중 오류: $e');
    }
  }

  /// 리뷰 상태 초기화 (테스트용)
  Future<void> resetReviewState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastReviewRequestKey);
      await prefs.remove(_reviewRequestCountKey);
      await prefs.remove(_userReviewedKey);
      await prefs.remove(_userDeclinedKey);
      await prefs.remove('${_userDeclinedKey}_time');
      _logger.i('🔄 리뷰 상태 초기화 완료');
    } catch (e) {
      _logger.e('❌ 리뷰 상태 초기화 중 오류: $e');
    }
  }

  /// 스토어 페이지로 이동
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
      _logger.i('📱 스토어 페이지로 이동');
    } catch (e) {
      _logger.e('❌ 스토어 페이지 이동 중 오류: $e');
    }
  }
}
