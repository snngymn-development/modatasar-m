import 'dart:async';
import '../logging/talker_config.dart';

/// Rate limiter service to prevent abuse
///
/// Usage:
/// ```dart
/// final limiter = RateLimiter();
/// await limiter.initialize();
/// final canProceed = await limiter.checkLimit('api_call');
/// ```
class RateLimiter {
  static RateLimiter? _instance;
  static RateLimiter get instance => _instance ??= RateLimiter._();

  RateLimiter._();

  final Map<String, List<DateTime>> _requestHistory = {};
  final Map<String, RateLimitConfig> _configs = {};
  Timer? _cleanupTimer;

  /// Initialize rate limiter
  Future<void> initialize() async {
    try {
      // Setup default rate limits
      _setupDefaultLimits();

      // Start cleanup timer to remove old entries
      _startCleanupTimer();

      TalkerConfig.logInfo('Rate limiter initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to initialize rate limiter', e, stackTrace);
      rethrow;
    }
  }

  /// Setup default rate limits
  void _setupDefaultLimits() {
    _configs['api_call'] = RateLimitConfig(
      maxRequests: 100,
      windowDuration: const Duration(minutes: 1),
    );
    _configs['login_attempt'] = RateLimitConfig(
      maxRequests: 5,
      windowDuration: const Duration(minutes: 15),
    );
    _configs['password_reset'] = RateLimitConfig(
      maxRequests: 3,
      windowDuration: const Duration(hours: 1),
    );
    _configs['general'] = RateLimitConfig(
      maxRequests: 1000,
      windowDuration: const Duration(hours: 1),
    );
  }

  /// Start cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupOldEntries();
    });
  }

  /// Check if request is within rate limit
  Future<bool> checkLimit(String key, {String? identifier}) async {
    try {
      final config = _configs[key] ?? _configs['general']!;
      final requestKey = identifier != null ? '$key:$identifier' : key;

      final now = DateTime.now();
      final windowStart = now.subtract(config.windowDuration);

      // Get recent requests for this key
      final requests = _requestHistory[requestKey] ?? [];

      // Remove old requests outside the window
      requests.removeWhere((time) => time.isBefore(windowStart));

      // Check if we're within the limit
      if (requests.length >= config.maxRequests) {
        TalkerConfig.logWarning('Rate limit exceeded for $key');
        return false;
      }

      // Add current request
      requests.add(now);
      _requestHistory[requestKey] = requests;

      TalkerConfig.logDebug(
        'Rate limit check passed for $key (${requests.length}/${config.maxRequests})',
      );
      return true;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Rate limit check failed for $key', e, stackTrace);
      // In case of error, allow the request to proceed
      return true;
    }
  }

  /// Get remaining requests for a key
  int getRemainingRequests(String key, {String? identifier}) {
    try {
      final config = _configs[key] ?? _configs['general']!;
      final requestKey = identifier != null ? '$key:$identifier' : key;

      final now = DateTime.now();
      final windowStart = now.subtract(config.windowDuration);

      final requests = _requestHistory[requestKey] ?? [];
      requests.removeWhere((time) => time.isBefore(windowStart));

      return config.maxRequests - requests.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get time until rate limit resets
  Duration? getTimeUntilReset(String key, {String? identifier}) {
    try {
      final config = _configs[key] ?? _configs['general']!;
      final requestKey = identifier != null ? '$key:$identifier' : key;

      final requests = _requestHistory[requestKey] ?? [];
      if (requests.isEmpty) return null;

      final oldestRequest = requests.first;
      final resetTime = oldestRequest.add(config.windowDuration);
      final now = DateTime.now();

      if (resetTime.isAfter(now)) {
        return resetTime.difference(now);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Add custom rate limit configuration
  void addRateLimit(String key, RateLimitConfig config) {
    _configs[key] = config;
    TalkerConfig.logInfo(
      'Added rate limit config for $key: ${config.maxRequests} requests per ${config.windowDuration.inMinutes} minutes',
    );
  }

  /// Remove rate limit configuration
  void removeRateLimit(String key) {
    _configs.remove(key);
    _requestHistory.remove(key);
    TalkerConfig.logInfo('Removed rate limit config for $key');
  }

  /// Cleanup old entries
  void _cleanupOldEntries() {
    try {
      final now = DateTime.now();
      final maxAge = const Duration(hours: 24);
      final cutoffTime = now.subtract(maxAge);

      for (final key in _requestHistory.keys.toList()) {
        final requests = _requestHistory[key]!;
        requests.removeWhere((time) => time.isBefore(cutoffTime));

        if (requests.isEmpty) {
          _requestHistory.remove(key);
        }
      }

      TalkerConfig.logDebug('Cleaned up old rate limit entries');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to cleanup rate limit entries',
        e,
        stackTrace,
      );
    }
  }

  /// Get rate limit statistics
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{};

    for (final key in _requestHistory.keys) {
      final requests = _requestHistory[key]!;
      final config = _configs[key] ?? _configs['general']!;

      stats[key] = {
        'current_requests': requests.length,
        'max_requests': config.maxRequests,
        'window_duration_minutes': config.windowDuration.inMinutes,
        'remaining_requests': config.maxRequests - requests.length,
      };
    }

    return stats;
  }

  /// Clear all rate limit data
  void clearAll() {
    _requestHistory.clear();
    TalkerConfig.logInfo('Cleared all rate limit data');
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _requestHistory.clear();
    _configs.clear();
  }
}

/// Rate limit configuration
class RateLimitConfig {
  final int maxRequests;
  final Duration windowDuration;

  const RateLimitConfig({
    required this.maxRequests,
    required this.windowDuration,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RateLimitConfig &&
        other.maxRequests == maxRequests &&
        other.windowDuration == windowDuration;
  }

  @override
  int get hashCode => maxRequests.hashCode ^ windowDuration.hashCode;

  @override
  String toString() {
    return 'RateLimitConfig(maxRequests: $maxRequests, windowDuration: $windowDuration)';
  }
}
