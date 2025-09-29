/// Application constants
///
/// Usage:
/// ```dart
/// final apiUrl = AppConstants.apiBaseUrl;
/// final timeout = AppConstants.requestTimeout;
/// ```
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'https://api.example.com',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String featureFlagsKey = 'feature_flags';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration syncInterval = Duration(minutes: 5);

  // UI
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // Error Messages
  static const String networkErrorMessage = 'Network error occurred';
  static const String unknownErrorMessage = 'An unknown error occurred';
  static const String timeoutErrorMessage = 'Request timed out';
  static const String serverErrorMessage = 'Server error occurred';
}
