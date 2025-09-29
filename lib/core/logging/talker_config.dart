import 'package:talker_flutter/talker_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/logging_providers.dart';

class TalkerConfig {
  static Talker? _instance;

  static Talker get instance {
    _instance ??= TalkerFlutter.init(
      settings: TalkerSettings(
        useConsoleLogs: true,
        enabled: true,
        useHistory: true,
        maxHistoryItems: 100,
      ),
    );
    return _instance!;
  }

  // Provider-based instance (for dependency injection)
  static Talker getProviderInstance(WidgetRef ref) {
    return ref.read(talkerProvider);
  }

  // Helper methods for different log levels
  static void logInfo(String message) {
    instance.info(message);
  }

  static void logError(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    instance.error(message, error, stackTrace);
  }

  static void logWarning(String message) {
    instance.warning(message);
  }

  static void logDebug(String message) {
    instance.debug(message);
  }

  static void logVerbose(String message) {
    instance.verbose(message);
  }

  // Network logging
  static void logNetwork(String message) {
    instance.info('🌐 NETWORK: $message');
  }

  // User action logging
  static void logUserAction(String action) {
    instance.info('👤 USER: $action');
  }

  // Business logic logging
  static void logBusiness(String message) {
    instance.info('💼 BUSINESS: $message');
  }
}
