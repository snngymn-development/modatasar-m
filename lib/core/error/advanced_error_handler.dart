import 'dart:async';
import 'dart:convert';
import '../logging/talker_config.dart';
import 'failure.dart';
import '../network/result.dart';

/// Advanced error handling service with comprehensive error management
///
/// Usage:
/// ```dart
/// final errorHandler = AdvancedErrorHandler();
/// await errorHandler.handleError(error, context);
/// ```
class AdvancedErrorHandler {
  static final AdvancedErrorHandler _instance =
      AdvancedErrorHandler._internal();
  factory AdvancedErrorHandler() => _instance;
  AdvancedErrorHandler._internal();

  final Map<String, int> _errorCounts = {};
  final Map<String, DateTime> _lastErrorTimes = {};
  final List<ErrorContext> _errorHistory = [];

  /// Handle error with advanced context and recovery
  Future<Result<T>> handleError<T>(
    dynamic error,
    ErrorContext context, {
    bool retryable = true,
    int maxRetries = 3,
    Duration? retryDelay,
  }) async {
    try {
      // Log error with context
      await _logError(error, context);

      // Check if error is retryable
      if (retryable && _shouldRetry(error, context)) {
        return await _retryOperation<T>(error, context, maxRetries, retryDelay);
      }

      // Create appropriate failure
      final failure = _createFailure(error, context);

      // Store error for analytics
      await _storeErrorForAnalytics(error, context);

      return Error(failure);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Error in error handler', e, stackTrace);
      return Error(Failure('Error handling failed: $e'));
    }
  }

  /// Handle network errors specifically
  Future<Result<T>> handleNetworkError<T>(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    final errorContext = ErrorContext(
      operation: operation,
      context: context ?? {},
      timestamp: DateTime.now(),
      errorType: ErrorType.network,
    );

    return handleError<T>(error, errorContext);
  }

  /// Handle database errors specifically
  Future<Result<T>> handleDatabaseError<T>(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    final errorContext = ErrorContext(
      operation: operation,
      context: context ?? {},
      timestamp: DateTime.now(),
      errorType: ErrorType.database,
    );

    return handleError<T>(error, errorContext);
  }

  /// Handle validation errors specifically
  Future<Result<T>> handleValidationError<T>(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    final errorContext = ErrorContext(
      operation: operation,
      context: context ?? {},
      timestamp: DateTime.now(),
      errorType: ErrorType.validation,
    );

    return handleError<T>(error, errorContext);
  }

  /// Handle authentication errors specifically
  Future<Result<T>> handleAuthError<T>(
    dynamic error,
    String operation, {
    Map<String, dynamic>? context,
  }) async {
    final errorContext = ErrorContext(
      operation: operation,
      context: context ?? {},
      timestamp: DateTime.now(),
      errorType: ErrorType.authentication,
    );

    return handleError<T>(error, errorContext);
  }

  /// Get error statistics
  Map<String, dynamic> getErrorStatistics() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));

    final recentErrors = _errorHistory
        .where((error) => error.timestamp.isAfter(last24Hours))
        .length;

    final errorTypes = <String, int>{};
    for (final error in _errorHistory) {
      final type = error.errorType.toString().split('.').last;
      errorTypes[type] = (errorTypes[type] ?? 0) + 1;
    }

    return {
      'total_errors': _errorHistory.length,
      'recent_errors_24h': recentErrors,
      'error_types': errorTypes,
      'most_common_operation': _getMostCommonOperation(),
      'last_error_time': _errorHistory.isNotEmpty
          ? _errorHistory.last.timestamp.toIso8601String()
          : null,
    };
  }

  /// Clear error history
  void clearErrorHistory() {
    _errorHistory.clear();
    _errorCounts.clear();
    _lastErrorTimes.clear();
    TalkerConfig.logInfo('Error history cleared');
  }

  /// Log error with comprehensive context
  Future<void> _logError(dynamic error, ErrorContext context) async {
    TalkerConfig.logError(
      'Error in ${context.operation}: $error',
      error,
      StackTrace.current,
    );

    // Store in error history
    _errorHistory.add(context);

    // Update error counts
    _errorCounts[context.operation] =
        (_errorCounts[context.operation] ?? 0) + 1;
    _lastErrorTimes[context.operation] = context.timestamp;

    // Keep only last 1000 errors
    if (_errorHistory.length > 1000) {
      _errorHistory.removeAt(0);
    }
  }

  /// Check if error should be retried
  bool _shouldRetry(dynamic error, ErrorContext context) {
    // Don't retry if too many recent errors
    final recentCount = _errorCounts[context.operation] ?? 0;
    if (recentCount > 5) return false;

    // Don't retry certain error types
    if (error.toString().contains('unauthorized') ||
        error.toString().contains('forbidden') ||
        error.toString().contains('not found')) {
      return false;
    }

    return true;
  }

  /// Retry operation with exponential backoff
  Future<Result<T>> _retryOperation<T>(
    dynamic error,
    ErrorContext context,
    int maxRetries,
    Duration? retryDelay,
  ) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final delay = retryDelay ?? Duration(seconds: attempt * 2);
      await Future.delayed(delay);

      TalkerConfig.logInfo(
        'Retrying ${context.operation} (attempt $attempt/$maxRetries)',
      );

      // In a real implementation, you would retry the actual operation
      // For now, we'll simulate a retry
      try {
        // Simulate retry logic
        await Future.delayed(const Duration(milliseconds: 100));

        // If this was a real retry, you would call the original operation again
        // For now, we'll return the error after max retries
        if (attempt == maxRetries) {
          final failure = _createFailure(error, context);
          return Error(failure);
        }
      } catch (e) {
        if (attempt == maxRetries) {
          final failure = _createFailure(e, context);
          return Error(failure);
        }
      }
    }

    final failure = _createFailure(error, context);
    return Error(failure);
  }

  /// Create appropriate failure based on error type
  Failure _createFailure(dynamic error, ErrorContext context) {
    final errorMessage = error.toString();

    if (errorMessage.contains('network') || errorMessage.contains('timeout')) {
      return Failure(
        'Network error in ${context.operation}',
        code: 'NETWORK_ERROR',
      );
    } else if (errorMessage.contains('unauthorized') ||
        errorMessage.contains('forbidden')) {
      return Failure(
        'Authentication error in ${context.operation}',
        code: 'AUTH_ERROR',
      );
    } else if (errorMessage.contains('validation') ||
        errorMessage.contains('invalid')) {
      return Failure(
        'Validation error in ${context.operation}',
        code: 'VALIDATION_ERROR',
      );
    } else if (errorMessage.contains('database') ||
        errorMessage.contains('sql')) {
      return Failure(
        'Database error in ${context.operation}',
        code: 'DATABASE_ERROR',
      );
    } else {
      return Failure(
        'Unknown error in ${context.operation}: $errorMessage',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Store error for analytics
  Future<void> _storeErrorForAnalytics(
    dynamic error,
    ErrorContext context,
  ) async {
    try {
      // In a real implementation, you would send this to your analytics service
      final analyticsData = {
        'error_type': context.errorType.toString(),
        'operation': context.operation,
        'error_message': error.toString(),
        'timestamp': context.timestamp.toIso8601String(),
        'context': context.context,
      };

      TalkerConfig.logInfo(
        'Error analytics data: ${jsonEncode(analyticsData)}',
      );
    } catch (e) {
      TalkerConfig.logError('Failed to store error analytics', e);
    }
  }

  /// Get most common operation that causes errors
  String _getMostCommonOperation() {
    if (_errorCounts.isEmpty) return 'none';

    var maxCount = 0;
    var mostCommon = '';

    _errorCounts.forEach((operation, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = operation;
      }
    });

    return mostCommon;
  }
}

/// Error context for comprehensive error tracking
class ErrorContext {
  final String operation;
  final Map<String, dynamic> context;
  final DateTime timestamp;
  final ErrorType errorType;

  const ErrorContext({
    required this.operation,
    required this.context,
    required this.timestamp,
    required this.errorType,
  });
}

/// Error types for categorization
enum ErrorType {
  network,
  database,
  validation,
  authentication,
  business,
  system,
  unknown,
}
