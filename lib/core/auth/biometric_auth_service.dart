import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logging/talker_config.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Biometric authentication service
///
/// Usage:
/// ```dart
/// final auth = BiometricAuthService();
/// await auth.initialize();
/// final result = await auth.authenticate();
/// ```
class BiometricAuthService {
  static BiometricAuthService? _instance;
  static BiometricAuthService get instance =>
      _instance ??= BiometricAuthService._();

  BiometricAuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricDataKey = 'biometric_data';

  bool _isInitialized = false;
  bool _isBiometricEnabled = false;
  List<BiometricType> _availableBiometrics = [];

  /// Initialize biometric authentication
  Future<void> initialize() async {
    try {
      // Check if biometric authentication is available
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        TalkerConfig.logInfo('Biometric authentication not available');
        return;
      }

      // Get available biometric types
      _availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (_availableBiometrics.isEmpty) {
        TalkerConfig.logInfo('No biometric types available');
        return;
      }

      // Check if biometric is enabled
      _isBiometricEnabled = await _isBiometricEnabledInStorage();

      _isInitialized = true;
      TalkerConfig.logInfo(
        'Biometric authentication initialized. Available types: $_availableBiometrics',
      );
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize biometric authentication',
        e,
        stackTrace,
      );
    }
  }

  /// Check if biometric authentication is available
  bool get isAvailable => _isInitialized && _availableBiometrics.isNotEmpty;

  /// Check if biometric authentication is enabled
  bool get isEnabled => _isBiometricEnabled;

  /// Get available biometric types
  List<BiometricType> get availableBiometrics =>
      List.from(_availableBiometrics);

  /// Enable biometric authentication
  Future<Result<void>> enableBiometric() async {
    try {
      if (!isAvailable) {
        return Error(Failure('Biometric authentication not available'));
      }

      // First authenticate to enable
      final authResult = await authenticate(
        reason: 'Enable biometric authentication for secure access',
      );

      if (authResult.isFailure) {
        return Error(
          Failure('Authentication failed: ${authResult.error.message}'),
        );
      }

      // Save biometric enabled state
      await _storage.write(key: _biometricEnabledKey, value: 'true');
      _isBiometricEnabled = true;

      TalkerConfig.logInfo('Biometric authentication enabled');
      return const Success(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to enable biometric authentication',
        e,
        stackTrace,
      );
      return Error(
        Failure(
          'Failed to enable biometric authentication: $e',
          stack: stackTrace,
        ),
      );
    }
  }

  /// Disable biometric authentication
  Future<Result<void>> disableBiometric() async {
    try {
      await _storage.delete(key: _biometricEnabledKey);
      await _storage.delete(key: _biometricDataKey);
      _isBiometricEnabled = false;

      TalkerConfig.logInfo('Biometric authentication disabled');
      return const Success(null);
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to disable biometric authentication',
        e,
        stackTrace,
      );
      return Error(
        Failure(
          'Failed to disable biometric authentication: $e',
          stack: stackTrace,
        ),
      );
    }
  }

  /// Authenticate using biometric
  Future<Result<void>> authenticate({
    String reason = 'Authenticate to access secure features',
    bool stickyAuth = true,
  }) async {
    try {
      if (!isAvailable) {
        return Error(Failure('Biometric authentication not available'));
      }

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (result) {
        TalkerConfig.logInfo('Biometric authentication successful');
        return const Success(null);
      } else {
        TalkerConfig.logInfo('Biometric authentication failed or cancelled');
        return Error(Failure('Biometric authentication failed'));
      }
    } on PlatformException catch (e, stackTrace) {
      TalkerConfig.logError(
        'Biometric authentication platform error',
        e,
        stackTrace,
      );
      return Error(
        Failure(
          'Biometric authentication error: ${e.message}',
          stack: stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      TalkerConfig.logError('Biometric authentication error', e, stackTrace);
      return Error(
        Failure('Biometric authentication error: $e', stack: stackTrace),
      );
    }
  }

  /// Authenticate with specific biometric type
  Future<Result<void>> authenticateWithBiometric(
    BiometricType biometricType, {
    String reason = 'Authenticate to access secure features',
  }) async {
    try {
      if (!_availableBiometrics.contains(biometricType)) {
        return Error(Failure('Biometric type $biometricType not available'));
      }

      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (result) {
        TalkerConfig.logInfo(
          'Biometric authentication with $biometricType successful',
        );
        return const Success(null);
      } else {
        TalkerConfig.logInfo(
          'Biometric authentication with $biometricType failed',
        );
        return Error(Failure('Biometric authentication failed'));
      }
    } on PlatformException catch (e, stackTrace) {
      TalkerConfig.logError(
        'Biometric authentication error with $biometricType',
        e,
        stackTrace,
      );
      return Error(
        Failure(
          'Biometric authentication error: ${e.message}',
          stack: stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Biometric authentication error with $biometricType',
        e,
        stackTrace,
      );
      return Error(
        Failure('Biometric authentication error: $e', stack: stackTrace),
      );
    }
  }

  /// Check if biometric is enabled in storage
  Future<bool> _isBiometricEnabledInStorage() async {
    try {
      final enabled = await _storage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Get biometric authentication status
  BiometricAuthStatus getStatus() {
    return BiometricAuthStatus(
      isAvailable: isAvailable,
      isEnabled: isEnabled,
      availableBiometrics: availableBiometrics,
      isInitialized: _isInitialized,
    );
  }

  /// Get biometric type display name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Get biometric strength
  BiometricStrength getBiometricStrength() {
    if (_availableBiometrics.contains(BiometricType.strong)) {
      return BiometricStrength.strong;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint) ||
        _availableBiometrics.contains(BiometricType.face)) {
      return BiometricStrength.medium;
    } else if (_availableBiometrics.contains(BiometricType.weak)) {
      return BiometricStrength.weak;
    } else {
      return BiometricStrength.none;
    }
  }
}

/// Biometric authentication status
class BiometricAuthStatus {
  final bool isAvailable;
  final bool isEnabled;
  final List<BiometricType> availableBiometrics;
  final bool isInitialized;

  BiometricAuthStatus({
    required this.isAvailable,
    required this.isEnabled,
    required this.availableBiometrics,
    required this.isInitialized,
  });

  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'isEnabled': isEnabled,
      'availableBiometrics': availableBiometrics
          .map((e) => e.toString())
          .toList(),
      'isInitialized': isInitialized,
    };
  }
}

/// Biometric strength levels
enum BiometricStrength { none, weak, medium, strong }
