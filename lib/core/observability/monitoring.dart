import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Application monitoring and observability
///
/// Usage:
/// ```dart
/// Monitoring.logEvent('user_action', {'action': 'button_click'});
/// Monitoring.logError('api_error', error, stackTrace);
/// ```
class Monitoring {
  static late final Talker _talker;

  /// Initialize monitoring system
  static void init() {
    _talker = TalkerFlutter.init();
  }

  /// Log business events (non-PII)
  static void logEvent(String eventName, Map<String, dynamic>? parameters) {
    if (kDebugMode) {
      _talker.info('Event: $eventName', parameters);
    }
    // TODO: Send to analytics service in production
  }

  /// Log user actions (anonymized)
  static void logUserAction(String action, {Map<String, dynamic>? context}) {
    final sanitizedContext = _sanitizeContext(context);
    logEvent('user_action', {'action': action, 'context': sanitizedContext});
  }

  /// Log API calls
  static void logApiCall(
    String endpoint,
    String method,
    int statusCode,
    Duration duration,
  ) {
    logEvent('api_call', {
      'endpoint': endpoint,
      'method': method,
      'status_code': statusCode,
      'duration_ms': duration.inMilliseconds,
    });
  }

  /// Log errors with context
  static void logError(
    String errorType,
    Object error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
  }) {
    final sanitizedContext = _sanitizeContext(context);

    if (kDebugMode) {
      _talker.error('Error: $errorType', error, stackTrace);
    } else {
      // TODO: Send to crash reporting service
      _reportToCrashService(errorType, error, stackTrace, sanitizedContext);
    }
  }

  /// Log performance metrics
  static void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? metadata,
  }) {
    logEvent('performance', {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      'metadata': _sanitizeContext(metadata),
    });
  }

  /// Log network events
  static void logNetwork(String operation, {Map<String, dynamic>? details}) {
    logEvent('network', {
      'operation': operation,
      'details': _sanitizeContext(details),
    });
  }

  /// Sanitize context to remove PII
  static Map<String, dynamic>? _sanitizeContext(Map<String, dynamic>? context) {
    if (context == null) return null;

    final sanitized = <String, dynamic>{};
    for (final entry in context.entries) {
      final key = entry.key.toLowerCase();
      if (_isPII(key)) {
        sanitized[entry.key] = '[REDACTED]';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  /// Check if key contains PII
  static bool _isPII(String key) {
    final piiKeys = [
      'email',
      'phone',
      'password',
      'token',
      'id',
      'name',
      'address',
      'ssn',
      'credit',
      'card',
      'personal',
      'private',
    ];
    return piiKeys.any((pii) => key.contains(pii));
  }

  /// Report to crash service (production)
  static void _reportToCrashService(
    String errorType,
    Object error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ) {
    // Integrate with Sentry
    // Note: In a real implementation, this would integrate with Sentry
    // For now, we'll log to debug console
    // Sentry.captureException(
    //   error,
    //   stackTrace: stackTrace,
    //   extra: context,
    // );
    debugPrint('Production Error [$errorType]: $error');
  }
}
