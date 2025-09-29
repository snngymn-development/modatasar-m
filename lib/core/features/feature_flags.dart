import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../di/providers.dart';

/// Feature flags service with local defaults and remote override
///
/// Usage:
/// ```dart
/// final isEnabled = ref.read(featureFlagsProvider).isEnabled('new_ui');
/// ```
class FeatureFlagsService {
  final Dio _dio;
  Map<String, dynamic> _flags = {};
  bool _initialized = false;

  FeatureFlagsService({required Dio dio}) : _dio = dio;

  /// Initialize feature flags
  Future<void> initialize() async {
    if (_initialized) return;

    // Load local defaults first
    await _loadLocalDefaults();

    // Try to fetch remote overrides
    await _loadRemoteOverrides();

    _initialized = true;
  }

  /// Check if a feature is enabled
  bool isEnabled(String flagName) {
    return _flags[flagName] as bool? ?? false;
  }

  /// Get feature flag value
  T getValue<T>(String flagName, T defaultValue) {
    final value = _flags[flagName];
    if (value is T) return value;
    return defaultValue;
  }

  /// Get all feature flags
  Map<String, dynamic> getAllFlags() {
    return Map.unmodifiable(_flags);
  }

  /// Load local defaults from assets
  Future<void> _loadLocalDefaults() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/config/feature_flags.json',
      );
      final defaults = json.decode(jsonString) as Map<String, dynamic>;
      _flags = Map.from(defaults);
    } catch (e) {
      // Fallback to hardcoded defaults
      _flags = _getDefaultFlags();
    }
  }

  /// Load remote overrides
  Future<void> _loadRemoteOverrides() async {
    try {
      final response = await _dio.get('/api/feature-flags');
      final remoteFlags = response.data as Map<String, dynamic>;

      // Merge remote flags with local defaults
      _flags = {..._flags, ...remoteFlags};
    } catch (e) {
      // Ignore remote loading errors, use local defaults
    }
  }

  /// Get default feature flags
  Map<String, dynamic> _getDefaultFlags() {
    return {
      'new_ui': false,
      'dark_mode': true,
      'analytics_enabled': true,
      'crash_reporting': true,
      'offline_mode': false,
      'beta_features': false,
    };
  }
}

/// Feature flags provider
final featureFlagsProvider = FutureProvider<FeatureFlagsService>((ref) async {
  final dio = ref.read(dioProvider);
  final service = FeatureFlagsService(dio: dio);
  await service.initialize();
  return service;
});

/// Individual feature flag providers
final newUiEnabledProvider = Provider<bool>((ref) {
  final flags = ref.watch(featureFlagsProvider);
  return flags.when(
    data: (service) => service.isEnabled('new_ui'),
    loading: () => false,
    error: (_, __) => false,
  );
});

final darkModeEnabledProvider = Provider<bool>((ref) {
  final flags = ref.watch(featureFlagsProvider);
  return flags.when(
    data: (service) => service.isEnabled('dark_mode'),
    loading: () => true,
    error: (_, __) => true,
  );
});

final analyticsEnabledProvider = Provider<bool>((ref) {
  final flags = ref.watch(featureFlagsProvider);
  return flags.when(
    data: (service) => service.isEnabled('analytics_enabled'),
    loading: () => true,
    error: (_, __) => true,
  );
});
