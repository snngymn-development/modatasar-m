import 'package:flutter/foundation.dart';

/// API configuration and environment management
///
/// Usage:
/// ```dart
/// final apiConfig = ApiConfig.instance;
/// final baseUrl = apiConfig.baseUrl;
/// ```
class ApiConfig {
  static ApiConfig? _instance;
  static ApiConfig get instance => _instance ??= ApiConfig._();

  ApiConfig._();

  /// Base URL for API calls
  String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE');
    if (envUrl.isNotEmpty) return envUrl;

    if (kDebugMode) {
      return 'https://api-dev.modaapi.com';
    } else if (kProfileMode) {
      return 'https://api-staging.modaapi.com';
    } else {
      return 'https://api.modaapi.com';
    }
  }

  /// API version
  String get apiVersion => 'v1';

  /// Full API base URL with version
  String get fullBaseUrl => '$baseUrl/api/$apiVersion';

  /// Request timeout duration
  Duration get requestTimeout => const Duration(seconds: 30);

  /// Connection timeout duration
  Duration get connectionTimeout => const Duration(seconds: 15);

  /// Receive timeout duration
  Duration get receiveTimeout => const Duration(seconds: 30);

  /// Send timeout duration
  Duration get sendTimeout => const Duration(seconds: 30);

  /// Retry attempts for failed requests
  int get maxRetries => 3;

  /// Retry delay between attempts
  Duration get retryDelay => const Duration(seconds: 2);

  /// Enable request/response logging
  bool get enableLogging => kDebugMode;

  /// Enable performance monitoring
  bool get enablePerformanceMonitoring => true;

  /// Rate limiting configuration
  Map<String, dynamic> get rateLimits => {
    'api_call': {'maxRequests': 1000, 'windowMinutes': 60},
    'login_attempt': {'maxRequests': 5, 'windowMinutes': 15},
    'password_reset': {'maxRequests': 3, 'windowMinutes': 60},
  };

  /// Retry configuration
  Map<String, dynamic> get retryConfig => {
    'maxRetries': 3,
    'retryDelays': [1000, 2000, 3000], // milliseconds
    'retryableStatusCodes': [500, 502, 503, 504],
  };

  /// Security configuration
  Map<String, dynamic> get securityConfig => {
    'enableCertificatePinning': !kDebugMode,
    'enableRateLimiting': true,
    'enableAuditLogging': true,
    'maxRequestSize': 10 * 1024 * 1024, // 10MB
  };

  /// WebSocket configuration
  Map<String, dynamic> get websocketConfig => {
    'url': kDebugMode
        ? 'wss://api-dev.modaapi.com/ws'
        : 'wss://api.modaapi.com/ws',
    'reconnectInterval': 5000, // milliseconds
    'maxReconnectAttempts': 5,
    'pingInterval': 30000, // milliseconds
  };

  /// File upload configuration
  Map<String, dynamic> get uploadConfig => {
    'maxFileSize': 50 * 1024 * 1024, // 50MB
    'allowedTypes': ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'],
    'chunkSize': 1024 * 1024, // 1MB
  };

  /// Cache configuration
  Map<String, dynamic> get cacheConfig => {
    'enableCaching': true,
    'defaultTtl': 300, // 5 minutes
    'maxCacheSize': 100 * 1024 * 1024, // 100MB
  };

  /// API endpoints
  static const String salesEndpoint = '/sales';
  static const String inventoryEndpoint = '/inventory';
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String productsEndpoint = '/products';
  static const String customersEndpoint = '/customers';
  static const String paymentsEndpoint = '/payments';
  static const String ordersEndpoint = '/orders';
  static const String reportsEndpoint = '/reports';
  static const String cartEndpoint = '/cart';
  static const String websocketEndpoint = '/ws';
}
