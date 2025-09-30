class ApiConfig {
  static ApiConfig? _instance;
  static ApiConfig get instance => _instance ??= ApiConfig._();

  ApiConfig._();

  // Base URLs
  static const String _baseUrl = 'https://api.deneme1.com';
  static const String _apiVersion = 'v1';
  String get fullBaseUrl => '$_baseUrl/api/$_apiVersion';
  String get baseUrl => _baseUrl;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Timeout values in milliseconds for compatibility
  int get connectionTimeoutMs => connectionTimeout.inMilliseconds;
  int get receiveTimeoutMs => receiveTimeout.inMilliseconds;
  int get sendTimeoutMs => sendTimeout.inMilliseconds;

  // Logging
  static const bool enableLogging = true;

  // Rate Limiting
  static const Map<String, dynamic> rateLimits = {
    'api_call': {
      'maxRequests': 100,
      'windowMs': 60000,
    }, // 100 requests per minute
    'login_attempt': {
      'maxRequests': 5,
      'windowMs': 300000,
    }, // 5 attempts per 5 minutes
    'password_reset': {
      'maxRequests': 3,
      'windowMs': 3600000,
    }, // 3 attempts per hour
  };

  // Retry Configuration
  static const Map<String, dynamic> retryConfig = {
    'maxRetries': 3,
    'retryDelay': 1000, // milliseconds
    'retryableStatusCodes': [408, 429, 500, 502, 503, 504],
  };

  // Security Configuration
  static const Map<String, dynamic> securityConfig = {
    'enableCertificatePinning': true,
    'enableRateLimiting': true,
    'enableAuditLogging': true,
    'maxRequestSize': 10485760, // 10MB
  };

  // WebSocket Configuration
  static const Map<String, dynamic> websocketConfig = {
    'url': 'wss://api.deneme1.com/ws',
    'reconnectInterval': 5000, // milliseconds
    'maxReconnectAttempts': 5,
    'pingInterval': 30000, // milliseconds
  };

  // Upload Configuration
  static const Map<String, dynamic> uploadConfig = {
    'maxFileSize': 52428800, // 50MB
    'allowedTypes': ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'],
    'chunkSize': 1048576, // 1MB chunks
  };

  // Cache Configuration
  static const Map<String, dynamic> cacheConfig = {
    'enableCaching': true,
    'defaultTTL': 300, // 5 minutes
    'maxCacheSize': 100, // 100 items
  };

  // Endpoints
  static const String salesEndpoint = '/sales';
  static const String inventoryEndpoint = '/inventory';
  static const String customersEndpoint = '/customers';
  static const String cartEndpoint = '/cart';
  static const String websocketEndpoint = '/ws';
}
