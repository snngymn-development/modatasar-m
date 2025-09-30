import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../logging/talker_config.dart';

/// Advanced security service with comprehensive security features
///
/// Usage:
/// ```dart
/// final securityService = AdvancedSecurityService();
/// await securityService.initialize();
/// final encrypted = await securityService.encrypt(data);
/// ```
class AdvancedSecurityService {
  static final AdvancedSecurityService _instance =
      AdvancedSecurityService._internal();
  factory AdvancedSecurityService() => _instance;
  AdvancedSecurityService._internal();

  String? _encryptionKey;
  final List<SecurityEvent> _securityEvents = [];
  final Map<String, int> _failedAttempts = {};
  Timer? _securityMonitorTimer;

  /// Initialize security service
  Future<void> initialize() async {
    try {
      await _generateEncryptionKey();
      await _startSecurityMonitoring();
      await _loadSecurityConfiguration();

      TalkerConfig.logInfo('Advanced security service initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize security service',
        e,
        stackTrace,
      );
    }
  }

  /// Encrypt sensitive data
  Future<String> encrypt(String data) async {
    try {
      if (_encryptionKey == null) {
        throw Exception('Security service not initialized');
      }

      // Simple encryption using base64 and key
      final bytes = utf8.encode(data);
      final keyBytes = utf8.encode(_encryptionKey!);

      final encrypted = <int>[];
      for (int i = 0; i < bytes.length; i++) {
        encrypted.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      final encryptedString = base64Encode(encrypted);

      _logSecurityEvent(SecurityEventType.encryption, 'Data encrypted');
      return encryptedString;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to encrypt data', e, stackTrace);
      rethrow;
    }
  }

  /// Decrypt sensitive data
  Future<String> decrypt(String encryptedData) async {
    try {
      if (_encryptionKey == null) {
        throw Exception('Security service not initialized');
      }

      final encrypted = base64Decode(encryptedData);
      final keyBytes = utf8.encode(_encryptionKey!);

      final decrypted = <int>[];
      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }

      final decryptedString = utf8.decode(decrypted);

      _logSecurityEvent(SecurityEventType.decryption, 'Data decrypted');
      return decryptedString;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to decrypt data', e, stackTrace);
      rethrow;
    }
  }

  /// Hash password with salt
  Future<String> hashPassword(String password, {String? salt}) async {
    try {
      final saltToUse = salt ?? _generateSalt();
      final saltedPassword = password + saltToUse;
      final bytes = utf8.encode(saltedPassword);
      final digest = sha256.convert(bytes);

      _logSecurityEvent(SecurityEventType.passwordHash, 'Password hashed');
      return '$saltToUse:${digest.toString()}';
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to hash password', e, stackTrace);
      rethrow;
    }
  }

  /// Verify password
  Future<bool> verifyPassword(String password, String hashedPassword) async {
    try {
      final parts = hashedPassword.split(':');
      if (parts.length != 2) return false;

      final salt = parts[0];
      final hash = parts[1];

      final hashedInput = await hashPassword(password, salt: salt);
      final inputParts = hashedInput.split(':');
      final inputHash = inputParts[1];

      final isValid = hash == inputHash;

      _logSecurityEvent(
        isValid
            ? SecurityEventType.passwordVerificationSuccess
            : SecurityEventType.passwordVerificationFailure,
        'Password verification ${isValid ? 'successful' : 'failed'}',
      );

      return isValid;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to verify password', e, stackTrace);
      return false;
    }
  }

  /// Generate secure token
  Future<String> generateSecureToken({int length = 32}) async {
    try {
      final random = Random.secure();
      final bytes = List<int>.generate(length, (i) => random.nextInt(256));
      final token = base64Encode(bytes);

      _logSecurityEvent(
        SecurityEventType.tokenGeneration,
        'Secure token generated',
      );
      return token;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to generate secure token', e, stackTrace);
      rethrow;
    }
  }

  /// Validate input for security threats
  Future<SecurityValidationResult> validateInput(String input) async {
    try {
      final threats = <SecurityThreat>[];

      // Check for SQL injection
      if (_containsSqlInjection(input)) {
        threats.add(SecurityThreat.sqlInjection);
      }

      // Check for XSS
      if (_containsXss(input)) {
        threats.add(SecurityThreat.xss);
      }

      // Check for script injection
      if (_containsScriptInjection(input)) {
        threats.add(SecurityThreat.scriptInjection);
      }

      // Check for path traversal
      if (_containsPathTraversal(input)) {
        threats.add(SecurityThreat.pathTraversal);
      }

      final result = SecurityValidationResult(
        isValid: threats.isEmpty,
        threats: threats,
        sanitizedInput: threats.isEmpty ? input : _sanitizeInput(input),
      );

      if (!result.isValid) {
        _logSecurityEvent(
          SecurityEventType.inputValidationFailure,
          'Input validation failed: ${threats.map((t) => t.toString()).join(', ')}',
        );
      }

      return result;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to validate input', e, stackTrace);
      return SecurityValidationResult(
        isValid: false,
        threats: [SecurityThreat.unknown],
        sanitizedInput: '',
      );
    }
  }

  /// Check for suspicious activity
  Future<bool> checkSuspiciousActivity(String userId, String action) async {
    try {
      final now = DateTime.now();
      final window = const Duration(minutes: 5);

      // Get recent attempts
      final recentAttempts = _failedAttempts.entries
          .where(
            (entry) =>
                entry.key.startsWith('$userId:') &&
                now.difference(
                      DateTime.fromMillisecondsSinceEpoch(
                        int.parse(entry.key.split(':').last),
                      ),
                    ) <
                    window,
          )
          .length;

      // Check if too many attempts
      if (recentAttempts > 10) {
        _logSecurityEvent(
          SecurityEventType.suspiciousActivity,
          'Suspicious activity detected for user $userId',
        );
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to check suspicious activity',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Record failed attempt
  void recordFailedAttempt(String userId, String action) {
    try {
      final key = '$userId:$action:${DateTime.now().millisecondsSinceEpoch}';
      _failedAttempts[key] = 1;

      _logSecurityEvent(
        SecurityEventType.failedAttempt,
        'Failed attempt recorded for user $userId',
      );
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to record failed attempt', e, stackTrace);
    }
  }

  /// Get security events
  List<SecurityEvent> getSecurityEvents() => List.unmodifiable(_securityEvents);

  /// Get security report
  Map<String, dynamic> getSecurityReport() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));

    final recentEvents = _securityEvents
        .where((event) => event.timestamp.isAfter(last24Hours))
        .toList();

    final eventTypes = <String, int>{};
    for (final event in recentEvents) {
      final type = event.type.toString().split('.').last;
      eventTypes[type] = (eventTypes[type] ?? 0) + 1;
    }

    return {
      'total_events': _securityEvents.length,
      'recent_events_24h': recentEvents.length,
      'event_types': eventTypes,
      'failed_attempts': _failedAttempts.length,
      'last_event_time': _securityEvents.isNotEmpty
          ? _securityEvents.last.timestamp.toIso8601String()
          : null,
    };
  }

  /// Generate encryption key
  Future<void> _generateEncryptionKey() async {
    try {
      // In a real implementation, you would generate a proper encryption key
      // and store it securely (e.g., in secure storage)
      _encryptionKey =
          'default_encryption_key_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to generate encryption key', e, stackTrace);
      rethrow;
    }
  }

  /// Start security monitoring
  Future<void> _startSecurityMonitoring() async {
    _securityMonitorTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _performSecurityCheck(),
    );
  }

  /// Perform security check
  Future<void> _performSecurityCheck() async {
    try {
      // Clean up old failed attempts
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(hours: 1));

      _failedAttempts.removeWhere((key, value) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(
          int.parse(key.split(':').last),
        );
        return timestamp.isBefore(cutoff);
      });

      // Check for security events
      await _checkSecurityEvents();
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to perform security check', e, stackTrace);
    }
  }

  /// Load security configuration
  Future<void> _loadSecurityConfiguration() async {
    // Load security configuration from secure storage
  }

  /// Check security events
  Future<void> _checkSecurityEvents() async {
    // Check for suspicious patterns in security events
    final recentEvents = _securityEvents
        .where(
          (event) =>
              DateTime.now().difference(event.timestamp) <
              const Duration(minutes: 5),
        )
        .toList();

    if (recentEvents.length > 50) {
      _logSecurityEvent(
        SecurityEventType.securityAlert,
        'High volume of security events detected',
      );
    }
  }

  /// Log security event
  void _logSecurityEvent(SecurityEventType type, String description) {
    final event = SecurityEvent(
      type: type,
      description: description,
      timestamp: DateTime.now(),
    );

    _securityEvents.add(event);

    // Keep only last 1000 events
    if (_securityEvents.length > 1000) {
      _securityEvents.removeAt(0);
    }

    TalkerConfig.logInfo('Security event: $type - $description');
  }

  /// Generate salt
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Check for SQL injection
  bool _containsSqlInjection(String input) {
    final sqlPatterns = [
      r"('|(\\')|(;)|(\\;)|(--)|(\\--)|(/\*)|(\\/\*)|(\*/)|(\\\*/))",
      r"(union|select|insert|update|delete|drop|create|alter|exec|execute)",
      r"(or|and)\s+\d+\s*=\s*\d+",
    ];

    for (final pattern in sqlPatterns) {
      try {
        if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
          return true;
        }
      } catch (e) {
        // Skip invalid regex patterns
        continue;
      }
    }

    return false;
  }

  /// Check for XSS
  bool _containsXss(String input) {
    final xssPatterns = [
      r"<script[^>]*>.*?</script>",
      r"javascript:",
      r"on\w+\s*=",
      r"<iframe[^>]*>",
      r"<object[^>]*>",
      r"<embed[^>]*>",
    ];

    for (final pattern in xssPatterns) {
      try {
        if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
          return true;
        }
      } catch (e) {
        // Skip invalid regex patterns
        continue;
      }
    }

    return false;
  }

  /// Check for script injection
  bool _containsScriptInjection(String input) {
    final scriptPatterns = [
      r"<script",
      r"javascript:",
      r"vbscript:",
      r"onload\s*=",
      r"onerror\s*=",
    ];

    for (final pattern in scriptPatterns) {
      try {
        if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
          return true;
        }
      } catch (e) {
        // Skip invalid regex patterns
        continue;
      }
    }

    return false;
  }

  /// Check for path traversal
  bool _containsPathTraversal(String input) {
    final pathPatterns = [r"\.\./", r"\.\.\\", r"\.\.%2f", r"\.\.%5c"];

    for (final pattern in pathPatterns) {
      try {
        if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
          return true;
        }
      } catch (e) {
        // Skip invalid regex patterns
        continue;
      }
    }

    return false;
  }

  /// Sanitize input
  String _sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll('<', '') // Remove <
        .replaceAll('>', '') // Remove >
        .replaceAll('"', '') // Remove "
        .replaceAll("'", '') // Remove '
        .replaceAll('javascript:', '') // Remove javascript:
        .replaceAll('vbscript:', '') // Remove vbscript:
        .trim();
  }

  /// Dispose resources
  void dispose() {
    _securityMonitorTimer?.cancel();
    _securityEvents.clear();
    _failedAttempts.clear();
    TalkerConfig.logInfo('Security service disposed');
  }
}

/// Security event data class
class SecurityEvent {
  final SecurityEventType type;
  final String description;
  final DateTime timestamp;

  const SecurityEvent({
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

/// Security event types
enum SecurityEventType {
  encryption,
  decryption,
  passwordHash,
  passwordVerificationSuccess,
  passwordVerificationFailure,
  inputValidationFailure,
  suspiciousActivity,
  failedAttempt,
  securityAlert,
  tokenGeneration,
}

/// Security threat types
enum SecurityThreat {
  sqlInjection,
  xss,
  scriptInjection,
  pathTraversal,
  unknown,
}

/// Security validation result
class SecurityValidationResult {
  final bool isValid;
  final List<SecurityThreat> threats;
  final String sanitizedInput;

  const SecurityValidationResult({
    required this.isValid,
    required this.threats,
    required this.sanitizedInput,
  });
}
