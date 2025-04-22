import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;

  static const String _gamesCompletedKey = 'games_completed_count';
  static const String _lastReviewRequestKey = 'last_review_request_date';
  static const String _hasRatedKey = 'has_rated_app';

  static const int _initialReviewThreshold = 3;
  static const int _subsequentReviewThreshold = 5;

  static const int _minDaysBetweenRequests = 7;

  static Future<void> incrementCompletedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final int currentCount = prefs.getInt(_gamesCompletedKey) ?? 0;
    final int newCount = currentCount + 1;
    await prefs.setInt(_gamesCompletedKey, newCount);

    await _checkAndRequestReview();
  }

  static Future<void> _checkAndRequestReview() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_hasRatedKey) ?? false) {
      return;
    }

    final int gamesCompleted = prefs.getInt(_gamesCompletedKey) ?? 0;
    final int? lastRequestTimestamp = prefs.getInt(_lastReviewRequestKey);
    final DateTime now = DateTime.now();
    final DateTime lastRequest =
        lastRequestTimestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(lastRequestTimestamp)
            : DateTime(2000);

    final int daysSinceLastRequest = now.difference(lastRequest).inDays;
    final bool enoughTimePassed = daysSinceLastRequest >= _minDaysBetweenRequests;
    bool shouldShowReview = false;

    if (enoughTimePassed) {
      if (gamesCompleted == _initialReviewThreshold) {
        shouldShowReview = true;
      } else if (gamesCompleted > _initialReviewThreshold &&
          (gamesCompleted - _initialReviewThreshold) % _subsequentReviewThreshold == 0) {
        shouldShowReview = true;
      }
    }

    if (shouldShowReview) {
      await prefs.setInt(_lastReviewRequestKey, now.millisecondsSinceEpoch);
      await requestReview();
    }
  }

  static Future<void> requestReview() async {
    final bool isAvailable = await _inAppReview.isAvailable();

    if (isAvailable) {
      try {
        await _inAppReview.requestReview();
      } catch (e) {
        print('ReviewService: Error requesting review: $e');
      }
    }
  }

  static Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
  }

  static Future<void> resetReviewStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gamesCompletedKey);
    await prefs.remove(_lastReviewRequestKey);
    await prefs.remove(_hasRatedKey);
  }

  // Testing functions
  static Future<Map<String, dynamic>> getReviewStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int gamesCompleted = prefs.getInt(_gamesCompletedKey) ?? 0;
    final int? lastRequestTimestamp = prefs.getInt(_lastReviewRequestKey);
    final bool hasRated = prefs.getBool(_hasRatedKey) ?? false;

    final DateTime? lastRequest =
        lastRequestTimestamp != null ? DateTime.fromMillisecondsSinceEpoch(lastRequestTimestamp) : null;

    return {
      'gamesCompleted': gamesCompleted,
      'lastRequestDate': lastRequest?.toString() ?? 'Never',
      'hasRated': hasRated,
      'nextReviewAt': _getNextReviewThreshold(gamesCompleted),
    };
  }

  static int _getNextReviewThreshold(int currentGames) {
    if (currentGames < _initialReviewThreshold) {
      return _initialReviewThreshold;
    } else {
      final int baseCount = (currentGames - _initialReviewThreshold) ~/ _subsequentReviewThreshold;
      return _initialReviewThreshold + (baseCount + 1) * _subsequentReviewThreshold;
    }
  }

  static Future<void> forceReviewRequest() async {
    await requestReview();
  }

  static Future<void> setGameCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gamesCompletedKey, count);
  }
}
