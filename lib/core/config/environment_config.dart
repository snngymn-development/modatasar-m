import 'dart:io';

/// Environment Configuration Manager
///
/// Usage:
/// ```dart
/// final config = EnvironmentConfig.instance;
/// final apiUrl = config.apiUrl;
/// final isProduction = config.isProduction;
/// ```
class EnvironmentConfig {
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();
  factory EnvironmentConfig() => _instance;
  static EnvironmentConfig get instance => _instance;
  EnvironmentConfig._internal();

  late Environment _environment;
  late Map<String, dynamic> _config;

  /// Initialize environment configuration
  Future<void> initialize() async {
    _environment = _detectEnvironment();
    _config = _loadConfigForEnvironment(_environment);
  }

  /// Get current environment
  Environment get environment => _environment;

  /// Check if running in production
  bool get isProduction => _environment == Environment.production;

  /// Check if running in development
  bool get isDevelopment => _environment == Environment.development;

  /// Check if running in staging
  bool get isStaging => _environment == Environment.staging;

  /// Check if running in test
  bool get isTest => _environment == Environment.test;

  /// Get API base URL
  String get apiUrl => _config['api_url'] as String;

  /// Get WebSocket URL
  String get websocketUrl => _config['websocket_url'] as String;

  /// Get database URL
  String get databaseUrl => _config['database_url'] as String;

  /// Get Redis URL
  String get redisUrl => _config['redis_url'] as String;

  /// Get Sentry DSN
  String get sentryDsn => _config['sentry_dsn'] as String;

  /// Get Firebase project ID
  String get firebaseProjectId => _config['firebase_project_id'] as String;

  /// Get API key
  String get apiKey => _config['api_key'] as String;

  /// Get secret key
  String get secretKey => _config['secret_key'] as String;

  /// Get encryption key
  String get encryptionKey => _config['encryption_key'] as String;

  /// Get JWT secret
  String get jwtSecret => _config['jwt_secret'] as String;

  /// Get JWT expiration time
  Duration get jwtExpiration =>
      Duration(minutes: _config['jwt_expiration_minutes'] as int);

  /// Get cache TTL
  Duration get cacheTtl =>
      Duration(minutes: _config['cache_ttl_minutes'] as int);

  /// Get max retry attempts
  int get maxRetryAttempts => _config['max_retry_attempts'] as int;

  /// Get retry delay
  Duration get retryDelay =>
      Duration(seconds: _config['retry_delay_seconds'] as int);

  /// Get timeout duration
  Duration get timeoutDuration =>
      Duration(seconds: _config['timeout_seconds'] as int);

  /// Get batch size
  int get batchSize => _config['batch_size'] as int;

  /// Get max file size
  int get maxFileSize => _config['max_file_size'] as int;

  /// Get allowed file types
  List<String> get allowedFileTypes =>
      List<String>.from(_config['allowed_file_types'] as List);

  /// Get rate limit per minute
  int get rateLimitPerMinute => _config['rate_limit_per_minute'] as int;

  /// Get rate limit per hour
  int get rateLimitPerHour => _config['rate_limit_per_hour'] as int;

  /// Get log level
  String get logLevel => _config['log_level'] as String;

  /// Get enable analytics
  bool get enableAnalytics => _config['enable_analytics'] as bool;

  /// Get enable crash reporting
  bool get enableCrashReporting => _config['enable_crash_reporting'] as bool;

  /// Get enable performance monitoring
  bool get enablePerformanceMonitoring =>
      _config['enable_performance_monitoring'] as bool;

  /// Get enable AI features
  bool get enableAIFeatures => _config['enable_ai_features'] as bool;

  /// Get enable offline mode
  bool get enableOfflineMode => _config['enable_offline_mode'] as bool;

  /// Get enable real-time sync
  bool get enableRealTimeSync => _config['enable_realtime_sync'] as bool;

  /// Get enable push notifications
  bool get enablePushNotifications =>
      _config['enable_push_notifications'] as bool;

  /// Get enable biometric auth
  bool get enableBiometricAuth => _config['enable_biometric_auth'] as bool;

  /// Get enable social login
  bool get enableSocialLogin => _config['enable_social_login'] as bool;

  /// Get enable dark mode
  bool get enableDarkMode => _config['enable_dark_mode'] as bool;

  /// Get enable multi-language
  bool get enableMultiLanguage => _config['enable_multi_language'] as bool;

  /// Get default language
  String get defaultLanguage => _config['default_language'] as String;

  /// Get supported languages
  List<String> get supportedLanguages =>
      List<String>.from(_config['supported_languages'] as List);

  /// Get currency
  String get currency => _config['currency'] as String;

  /// Get timezone
  String get timezone => _config['timezone'] as String;

  /// Get date format
  String get dateFormat => _config['date_format'] as String;

  /// Get time format
  String get timeFormat => _config['time_format'] as String;

  /// Get number format
  String get numberFormat => _config['number_format'] as String;

  /// Get decimal places
  int get decimalPlaces => _config['decimal_places'] as int;

  /// Get tax rate
  double get taxRate => _config['tax_rate'] as double;

  /// Get discount rate
  double get discountRate => _config['discount_rate'] as double;

  /// Get minimum order amount
  double get minimumOrderAmount => _config['minimum_order_amount'] as double;

  /// Get maximum order amount
  double get maximumOrderAmount => _config['maximum_order_amount'] as double;

  /// Get inventory low stock threshold
  int get inventoryLowStockThreshold =>
      _config['inventory_low_stock_threshold'] as int;

  /// Get inventory high stock threshold
  int get inventoryHighStockThreshold =>
      _config['inventory_high_stock_threshold'] as int;

  /// Get customer credit limit
  double get customerCreditLimit => _config['customer_credit_limit'] as double;

  /// Get payment methods
  List<String> get paymentMethods =>
      List<String>.from(_config['payment_methods'] as List);

  /// Get default payment method
  String get defaultPaymentMethod =>
      _config['default_payment_method'] as String;

  /// Get receipt template
  String get receiptTemplate => _config['receipt_template'] as String;

  /// Get company name
  String get companyName => _config['company_name'] as String;

  /// Get company address
  String get companyAddress => _config['company_address'] as String;

  /// Get company phone
  String get companyPhone => _config['company_phone'] as String;

  /// Get company email
  String get companyEmail => _config['company_email'] as String;

  /// Get company website
  String get companyWebsite => _config['company_website'] as String;

  /// Get company logo
  String get companyLogo => _config['company_logo'] as String;

  /// Get custom configuration value
  T? getCustomValue<T>(String key) {
    return _config[key] as T?;
  }

  /// Set custom configuration value
  void setCustomValue<T>(String key, T value) {
    _config[key] = value;
  }

  // Private methods
  Environment _detectEnvironment() {
    // Check environment variables
    final env =
        Platform.environment['FLUTTER_ENV'] ??
        Platform.environment['DART_ENV'] ??
        'development';

    switch (env.toLowerCase()) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stage':
        return Environment.staging;
      case 'test':
      case 'testing':
        return Environment.test;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }

  Map<String, dynamic> _loadConfigForEnvironment(Environment env) {
    switch (env) {
      case Environment.production:
        return _productionConfig;
      case Environment.staging:
        return _stagingConfig;
      case Environment.test:
        return _testConfig;
      case Environment.development:
        return _developmentConfig;
    }
  }

  // Configuration maps
  static const Map<String, dynamic> _developmentConfig = {
    'api_url': 'https://dev-api.pos-system.com/api/v1',
    'websocket_url': 'wss://dev-api.pos-system.com/ws',
    'database_url': 'sqlite://dev_pos.db',
    'redis_url': 'redis://localhost:6379',
    'sentry_dsn': '',
    'firebase_project_id': 'dev-pos-system',
    'api_key': 'dev_api_key_12345',
    'secret_key': 'dev_secret_key_67890',
    'encryption_key': 'dev_encryption_key_abcdef',
    'jwt_secret': 'dev_jwt_secret_ghijkl',
    'jwt_expiration_minutes': 60,
    'cache_ttl_minutes': 5,
    'max_retry_attempts': 3,
    'retry_delay_seconds': 2,
    'timeout_seconds': 30,
    'batch_size': 100,
    'max_file_size': 10485760, // 10MB
    'allowed_file_types': ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    'rate_limit_per_minute': 100,
    'rate_limit_per_hour': 1000,
    'log_level': 'debug',
    'enable_analytics': true,
    'enable_crash_reporting': true,
    'enable_performance_monitoring': true,
    'enable_ai_features': true,
    'enable_offline_mode': true,
    'enable_realtime_sync': true,
    'enable_push_notifications': true,
    'enable_biometric_auth': true,
    'enable_social_login': true,
    'enable_dark_mode': true,
    'enable_multi_language': true,
    'default_language': 'tr',
    'supported_languages': ['tr', 'en', 'de', 'fr'],
    'currency': 'TRY',
    'timezone': 'Europe/Istanbul',
    'date_format': 'dd/MM/yyyy',
    'time_format': 'HH:mm',
    'number_format': '#,##0.00',
    'decimal_places': 2,
    'tax_rate': 0.18,
    'discount_rate': 0.10,
    'minimum_order_amount': 0.0,
    'maximum_order_amount': 100000.0,
    'inventory_low_stock_threshold': 10,
    'inventory_high_stock_threshold': 100,
    'customer_credit_limit': 5000.0,
    'payment_methods': ['cash', 'card', 'bank_transfer', 'digital_wallet'],
    'default_payment_method': 'cash',
    'receipt_template': 'default',
    'company_name': 'POS System Dev',
    'company_address': 'Dev Address, Istanbul, Turkey',
    'company_phone': '+90 212 555 0123',
    'company_email': 'dev@pos-system.com',
    'company_website': 'https://dev.pos-system.com',
    'company_logo': 'assets/images/logo_dev.png',
  };

  static const Map<String, dynamic> _stagingConfig = {
    'api_url': 'https://staging-api.pos-system.com/api/v1',
    'websocket_url': 'wss://staging-api.pos-system.com/ws',
    'database_url': 'postgresql://staging:password@staging-db:5432/pos_staging',
    'redis_url': 'redis://staging-redis:6379',
    'sentry_dsn': 'https://staging@sentry.io/123456',
    'firebase_project_id': 'staging-pos-system',
    'api_key': 'staging_api_key_12345',
    'secret_key': 'staging_secret_key_67890',
    'encryption_key': 'staging_encryption_key_abcdef',
    'jwt_secret': 'staging_jwt_secret_ghijkl',
    'jwt_expiration_minutes': 30,
    'cache_ttl_minutes': 10,
    'max_retry_attempts': 3,
    'retry_delay_seconds': 3,
    'timeout_seconds': 20,
    'batch_size': 50,
    'max_file_size': 5242880, // 5MB
    'allowed_file_types': ['jpg', 'jpeg', 'png', 'pdf'],
    'rate_limit_per_minute': 50,
    'rate_limit_per_hour': 500,
    'log_level': 'info',
    'enable_analytics': true,
    'enable_crash_reporting': true,
    'enable_performance_monitoring': true,
    'enable_ai_features': true,
    'enable_offline_mode': true,
    'enable_realtime_sync': true,
    'enable_push_notifications': true,
    'enable_biometric_auth': true,
    'enable_social_login': true,
    'enable_dark_mode': true,
    'enable_multi_language': true,
    'default_language': 'tr',
    'supported_languages': ['tr', 'en'],
    'currency': 'TRY',
    'timezone': 'Europe/Istanbul',
    'date_format': 'dd/MM/yyyy',
    'time_format': 'HH:mm',
    'number_format': '#,##0.00',
    'decimal_places': 2,
    'tax_rate': 0.18,
    'discount_rate': 0.10,
    'minimum_order_amount': 0.0,
    'maximum_order_amount': 50000.0,
    'inventory_low_stock_threshold': 5,
    'inventory_high_stock_threshold': 50,
    'customer_credit_limit': 2500.0,
    'payment_methods': ['cash', 'card', 'bank_transfer'],
    'default_payment_method': 'cash',
    'receipt_template': 'staging',
    'company_name': 'POS System Staging',
    'company_address': 'Staging Address, Istanbul, Turkey',
    'company_phone': '+90 212 555 0124',
    'company_email': 'staging@pos-system.com',
    'company_website': 'https://staging.pos-system.com',
    'company_logo': 'assets/images/logo_staging.png',
  };

  static const Map<String, dynamic> _productionConfig = {
    'api_url': 'https://api.pos-system.com/api/v1',
    'websocket_url': 'wss://api.pos-system.com/ws',
    'database_url': 'postgresql://prod:password@prod-db:5432/pos_production',
    'redis_url': 'redis://prod-redis:6379',
    'sentry_dsn': 'https://production@sentry.io/789012',
    'firebase_project_id': 'prod-pos-system',
    'api_key': 'prod_api_key_12345',
    'secret_key': 'prod_secret_key_67890',
    'encryption_key': 'prod_encryption_key_abcdef',
    'jwt_secret': 'prod_jwt_secret_ghijkl',
    'jwt_expiration_minutes': 15,
    'cache_ttl_minutes': 15,
    'max_retry_attempts': 2,
    'retry_delay_seconds': 5,
    'timeout_seconds': 15,
    'batch_size': 25,
    'max_file_size': 2097152, // 2MB
    'allowed_file_types': ['jpg', 'jpeg', 'png'],
    'rate_limit_per_minute': 30,
    'rate_limit_per_hour': 300,
    'log_level': 'warn',
    'enable_analytics': true,
    'enable_crash_reporting': true,
    'enable_performance_monitoring': true,
    'enable_ai_features': true,
    'enable_offline_mode': true,
    'enable_realtime_sync': true,
    'enable_push_notifications': true,
    'enable_biometric_auth': true,
    'enable_social_login': true,
    'enable_dark_mode': true,
    'enable_multi_language': true,
    'default_language': 'tr',
    'supported_languages': ['tr', 'en'],
    'currency': 'TRY',
    'timezone': 'Europe/Istanbul',
    'date_format': 'dd/MM/yyyy',
    'time_format': 'HH:mm',
    'number_format': '#,##0.00',
    'decimal_places': 2,
    'tax_rate': 0.18,
    'discount_rate': 0.10,
    'minimum_order_amount': 0.0,
    'maximum_order_amount': 25000.0,
    'inventory_low_stock_threshold': 3,
    'inventory_high_stock_threshold': 25,
    'customer_credit_limit': 1000.0,
    'payment_methods': ['cash', 'card'],
    'default_payment_method': 'cash',
    'receipt_template': 'production',
    'company_name': 'POS System',
    'company_address': 'Production Address, Istanbul, Turkey',
    'company_phone': '+90 212 555 0125',
    'company_email': 'info@pos-system.com',
    'company_website': 'https://pos-system.com',
    'company_logo': 'assets/images/logo.png',
  };

  static const Map<String, dynamic> _testConfig = {
    'api_url': 'https://test-api.pos-system.com/api/v1',
    'websocket_url': 'wss://test-api.pos-system.com/ws',
    'database_url': 'sqlite://test_pos.db',
    'redis_url': 'redis://localhost:6379',
    'sentry_dsn': '',
    'firebase_project_id': 'test-pos-system',
    'api_key': 'test_api_key_12345',
    'secret_key': 'test_secret_key_67890',
    'encryption_key': 'test_encryption_key_abcdef',
    'jwt_secret': 'test_jwt_secret_ghijkl',
    'jwt_expiration_minutes': 5,
    'cache_ttl_minutes': 1,
    'max_retry_attempts': 1,
    'retry_delay_seconds': 1,
    'timeout_seconds': 10,
    'batch_size': 10,
    'max_file_size': 1048576, // 1MB
    'allowed_file_types': ['jpg', 'png'],
    'rate_limit_per_minute': 1000,
    'rate_limit_per_hour': 10000,
    'log_level': 'error',
    'enable_analytics': false,
    'enable_crash_reporting': false,
    'enable_performance_monitoring': false,
    'enable_ai_features': false,
    'enable_offline_mode': true,
    'enable_realtime_sync': false,
    'enable_push_notifications': false,
    'enable_biometric_auth': false,
    'enable_social_login': false,
    'enable_dark_mode': false,
    'enable_multi_language': false,
    'default_language': 'en',
    'supported_languages': ['en'],
    'currency': 'USD',
    'timezone': 'UTC',
    'date_format': 'MM/dd/yyyy',
    'time_format': 'HH:mm',
    'number_format': '#,##0.00',
    'decimal_places': 2,
    'tax_rate': 0.0,
    'discount_rate': 0.0,
    'minimum_order_amount': 0.0,
    'maximum_order_amount': 1000.0,
    'inventory_low_stock_threshold': 1,
    'inventory_high_stock_threshold': 10,
    'customer_credit_limit': 100.0,
    'payment_methods': ['cash'],
    'default_payment_method': 'cash',
    'receipt_template': 'test',
    'company_name': 'Test POS System',
    'company_address': 'Test Address',
    'company_phone': '+1 555 0123',
    'company_email': 'test@pos-system.com',
    'company_website': 'https://test.pos-system.com',
    'company_logo': 'assets/images/logo_test.png',
  };
}

/// Environment enum
enum Environment { development, staging, production, test }
