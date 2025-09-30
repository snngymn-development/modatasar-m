import 'dart:async';
import 'dart:math';
import '../logging/talker_config.dart';
import '../config/environment_config.dart';

/// Production Monitoring Service
///
/// Usage:
/// ```dart
/// final monitor = ProductionMonitor.instance;
/// await monitor.initialize();
/// monitor.trackEvent('user_action', {'action': 'login'});
/// ```
class ProductionMonitor {
  static final ProductionMonitor _instance = ProductionMonitor._internal();
  factory ProductionMonitor() => _instance;
  static ProductionMonitor get instance => _instance;
  ProductionMonitor._internal();

  // Removed unused field
  final Map<String, List<Map<String, dynamic>>> _events = {};
  final Map<String, int> _counters = {};
  final Map<String, double> _gauges = {};
  final Map<String, List<double>> _histograms = {};

  Timer? _metricsTimer;
  Timer? _healthCheckTimer;
  Timer? _alertTimer;

  bool _isInitialized = false;
  bool _isEnabled = false;

  // Performance thresholds
  static const double _maxMemoryUsage = 0.8; // 80%
  static const double _maxCpuUsage = 0.7; // 70%
  static const double _maxResponseTime = 5.0; // 5 seconds
  static const int _maxErrorRate = 5; // 5 errors per minute
  // Removed unused field

  /// Initialize production monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final config = EnvironmentConfig.instance;
      _isEnabled = config.enablePerformanceMonitoring;

      if (!_isEnabled) {
        TalkerConfig.logInfo('Production monitoring disabled');
        return;
      }

      await _setupMonitoring();
      _startMetricsCollection();
      _startHealthChecks();
      _startAlerting();

      _isInitialized = true;
      TalkerConfig.logInfo('Production monitoring initialized');
    } catch (e) {
      TalkerConfig.logError('Failed to initialize production monitoring', e);
    }
  }

  /// Track custom event
  void trackEvent(String eventName, Map<String, dynamic>? properties) {
    if (!_isEnabled) return;

    try {
      final event = {
        'name': eventName,
        'properties': properties ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _getSessionId(),
        'user_id': _getUserId(),
      };

      _events[eventName] ??= [];
      _events[eventName]!.add(event);

      // Keep only last 1000 events per type
      if (_events[eventName]!.length > 1000) {
        _events[eventName]!.removeAt(0);
      }

      TalkerConfig.logInfo('📊 Event tracked: $eventName');
    } catch (e) {
      TalkerConfig.logError('Failed to track event: $eventName', e);
    }
  }

  /// Track performance metric
  void trackMetric(
    String metricName,
    double value, {
    Map<String, String>? tags,
  }) {
    if (!_isEnabled) return;

    try {
      _gauges[metricName] = value;

      _histograms[metricName] ??= [];
      _histograms[metricName]!.add(value);

      // Keep only last 1000 values
      if (_histograms[metricName]!.length > 1000) {
        _histograms[metricName]!.removeAt(0);
      }

      // Check thresholds
      _checkMetricThresholds(metricName, value);

      TalkerConfig.logInfo('📈 Metric tracked: $metricName = $value');
    } catch (e) {
      TalkerConfig.logError('Failed to track metric: $metricName', e);
    }
  }

  /// Increment counter
  void incrementCounter(
    String counterName, {
    int value = 1,
    Map<String, String>? tags,
  }) {
    if (!_isEnabled) return;

    try {
      _counters[counterName] = (_counters[counterName] ?? 0) + value;
      TalkerConfig.logInfo(
        '🔢 Counter incremented: $counterName = ${_counters[counterName]}',
      );
    } catch (e) {
      TalkerConfig.logError('Failed to increment counter: $counterName', e);
    }
  }

  /// Track error
  void trackError(
    String errorType,
    String errorMessage, {
    Map<String, dynamic>? context,
  }) {
    if (!_isEnabled) return;

    try {
      incrementCounter('errors_total', tags: {'type': errorType});

      final error = {
        'type': errorType,
        'message': errorMessage,
        'context': context ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'session_id': _getSessionId(),
        'user_id': _getUserId(),
        'stack_trace': StackTrace.current.toString(),
      };

      _events['errors'] ??= [];
      _events['errors']!.add(error);

      // Check error rate
      _checkErrorRate();

      TalkerConfig.logError('🚨 Error tracked: $errorType - $errorMessage');
    } catch (e) {
      TalkerConfig.logError('Failed to track error: $errorType', e);
    }
  }

  /// Track user action
  void trackUserAction(String action, {Map<String, dynamic>? properties}) {
    trackEvent('user_action', {'action': action, ...?properties});
  }

  /// Track API call
  void trackApiCall(
    String endpoint,
    String method,
    int statusCode,
    Duration duration,
  ) {
    trackEvent('api_call', {
      'endpoint': endpoint,
      'method': method,
      'status_code': statusCode,
      'duration_ms': duration.inMilliseconds,
    });

    trackMetric('api_response_time', duration.inMilliseconds.toDouble());
    incrementCounter(
      'api_calls_total',
      tags: {
        'endpoint': endpoint,
        'method': method,
        'status_code': statusCode.toString(),
      },
    );

    if (statusCode >= 400) {
      incrementCounter(
        'api_errors_total',
        tags: {'endpoint': endpoint, 'status_code': statusCode.toString()},
      );
    }
  }

  /// Track database operation
  void trackDatabaseOperation(
    String operation,
    String table,
    Duration duration,
  ) {
    trackEvent('database_operation', {
      'operation': operation,
      'table': table,
      'duration_ms': duration.inMilliseconds,
    });

    trackMetric('database_operation_time', duration.inMilliseconds.toDouble());
    incrementCounter(
      'database_operations_total',
      tags: {'operation': operation, 'table': table},
    );
  }

  /// Track business metric
  void trackBusinessMetric(
    String metricName,
    double value, {
    Map<String, String>? tags,
  }) {
    trackMetric('business_$metricName', value, tags: tags);
  }

  /// Get current metrics
  Map<String, dynamic> getCurrentMetrics() {
    return {
      'gauges': Map<String, double>.from(_gauges),
      'counters': Map<String, int>.from(_counters),
      'histograms': _histograms.map(
        (key, value) => MapEntry(key, {
          'count': value.length,
          'min': value.isNotEmpty ? value.reduce(min) : 0.0,
          'max': value.isNotEmpty ? value.reduce(max) : 0.0,
          'avg': value.isNotEmpty
              ? value.reduce((a, b) => a + b) / value.length
              : 0.0,
          'p95': _calculatePercentile(value, 0.95),
          'p99': _calculatePercentile(value, 0.99),
        }),
      ),
      'events': _events.map((key, value) => MapEntry(key, value.length)),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get health status
  Map<String, dynamic> getHealthStatus() {
    final metrics = getCurrentMetrics();
    final gauges = metrics['gauges'] as Map<String, double>;
    final counters = metrics['counters'] as Map<String, int>;

    final memoryUsage = gauges['memory_usage'] ?? 0.0;
    final cpuUsage = gauges['cpu_usage'] ?? 0.0;
    final responseTime = gauges['api_response_time'] ?? 0.0;
    final errorCount = counters['errors_total'] ?? 0;

    final isHealthy =
        memoryUsage < _maxMemoryUsage &&
        cpuUsage < _maxCpuUsage &&
        responseTime < _maxResponseTime &&
        errorCount < _maxErrorRate;

    return {
      'status': isHealthy ? 'healthy' : 'unhealthy',
      'checks': {
        'memory_usage': {
          'status': memoryUsage < _maxMemoryUsage ? 'ok' : 'critical',
          'value': memoryUsage,
          'threshold': _maxMemoryUsage,
        },
        'cpu_usage': {
          'status': cpuUsage < _maxCpuUsage ? 'ok' : 'critical',
          'value': cpuUsage,
          'threshold': _maxCpuUsage,
        },
        'response_time': {
          'status': responseTime < _maxResponseTime ? 'ok' : 'critical',
          'value': responseTime,
          'threshold': _maxResponseTime,
        },
        'error_rate': {
          'status': errorCount < _maxErrorRate ? 'ok' : 'critical',
          'value': errorCount,
          'threshold': _maxErrorRate,
        },
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get alerts
  List<Map<String, dynamic>> getAlerts() {
    final alerts = <Map<String, dynamic>>[];
    final health = getHealthStatus();
    final checks = health['checks'] as Map<String, dynamic>;

    for (final entry in checks.entries) {
      final check = entry.value as Map<String, dynamic>;
      if (check['status'] == 'critical') {
        alerts.add({
          'type': 'critical',
          'check': entry.key,
          'message':
              '${entry.key} is ${check['status']}: ${check['value']} > ${check['threshold']}',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    }

    return alerts;
  }

  /// Export metrics for external monitoring
  Map<String, dynamic> exportMetrics() {
    return {
      'metrics': getCurrentMetrics(),
      'health': getHealthStatus(),
      'alerts': getAlerts(),
      'environment': EnvironmentConfig.instance.environment.name,
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose resources
  void dispose() {
    _metricsTimer?.cancel();
    _healthCheckTimer?.cancel();
    _alertTimer?.cancel();
    _isInitialized = false;
  }

  // Private methods
  Future<void> _setupMonitoring() async {
    // Initialize default metrics
    _gauges['memory_usage'] = 0.0;
    _gauges['cpu_usage'] = 0.0;
    _gauges['api_response_time'] = 0.0;
    _gauges['active_users'] = 0.0;

    _counters['errors_total'] = 0;
    _counters['api_calls_total'] = 0;
    _counters['api_errors_total'] = 0;
    _counters['database_operations_total'] = 0;
  }

  void _startMetricsCollection() {
    _metricsTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _collectSystemMetrics();
    });
  }

  void _startHealthChecks() {
    _healthCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _performHealthCheck();
    });
  }

  void _startAlerting() {
    _alertTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAlerts();
    });
  }

  void _collectSystemMetrics() {
    try {
      // Simulate system metrics collection
      _gauges['memory_usage'] = _simulateMemoryUsage();
      _gauges['cpu_usage'] = _simulateCpuUsage();
      _gauges['active_users'] = _simulateActiveUsers();

      // Track collection event
      trackEvent('metrics_collected', {
        'memory_usage': _gauges['memory_usage'],
        'cpu_usage': _gauges['cpu_usage'],
        'active_users': _gauges['active_users'],
      });
    } catch (e) {
      TalkerConfig.logError('Failed to collect system metrics', e);
    }
  }

  void _performHealthCheck() {
    try {
      final health = getHealthStatus();
      trackEvent('health_check', health);

      if (health['status'] == 'unhealthy') {
        trackError(
          'health_check_failed',
          'System health check failed',
          context: health,
        );
      }
    } catch (e) {
      TalkerConfig.logError('Failed to perform health check', e);
    }
  }

  void _checkAlerts() {
    try {
      final alerts = getAlerts();
      for (final alert in alerts) {
        trackEvent('alert_triggered', alert);
        TalkerConfig.logError('🚨 ALERT: ${alert['message']}');
      }
    } catch (e) {
      TalkerConfig.logError('Failed to check alerts', e);
    }
  }

  void _checkMetricThresholds(String metricName, double value) {
    switch (metricName) {
      case 'memory_usage':
        if (value > _maxMemoryUsage) {
          trackError(
            'memory_usage_high',
            'Memory usage exceeded threshold',
            context: {'value': value, 'threshold': _maxMemoryUsage},
          );
        }
        break;
      case 'cpu_usage':
        if (value > _maxCpuUsage) {
          trackError(
            'cpu_usage_high',
            'CPU usage exceeded threshold',
            context: {'value': value, 'threshold': _maxCpuUsage},
          );
        }
        break;
      case 'api_response_time':
        if (value > _maxResponseTime) {
          trackError(
            'response_time_high',
            'API response time exceeded threshold',
            context: {'value': value, 'threshold': _maxResponseTime},
          );
        }
        break;
    }
  }

  void _checkErrorRate() {
    final errorCount = _counters['errors_total'] ?? 0;
    if (errorCount > _maxErrorRate) {
      trackError(
        'error_rate_high',
        'Error rate exceeded threshold',
        context: {'error_count': errorCount, 'threshold': _maxErrorRate},
      );
    }
  }

  double _simulateMemoryUsage() {
    // Simulate memory usage between 0.3 and 0.9
    return 0.3 + (Random().nextDouble() * 0.6);
  }

  double _simulateCpuUsage() {
    // Simulate CPU usage between 0.2 and 0.8
    return 0.2 + (Random().nextDouble() * 0.6);
  }

  double _simulateActiveUsers() {
    // Simulate active users between 10 and 100
    return 10 + (Random().nextDouble() * 90);
  }

  String _getSessionId() {
    // Get actual session ID
    // Note: In a real implementation, this would get the actual session ID
    // For now, we'll generate a unique session ID
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _getUserId() {
    // Get actual user ID
    // Note: In a real implementation, this would get the actual user ID
    // For now, we'll generate a mock user ID
    return 'user_${Random().nextInt(1000)}';
  }

  double _calculatePercentile(List<double> values, double percentile) {
    if (values.isEmpty) return 0.0;

    final sorted = List<double>.from(values)..sort();
    final index = (percentile * (sorted.length - 1)).round();
    return sorted[index];
  }
}
