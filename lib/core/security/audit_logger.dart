import 'dart:async';
import 'dart:convert';
import '../logging/talker_config.dart';

/// Audit logger for security and compliance
///
/// Usage:
/// ```dart
/// final auditLogger = AuditLogger();
/// await auditLogger.initialize();
/// await auditLogger.logUserAction('login', userId: 'user123');
/// ```
class AuditLogger {
  static AuditLogger? _instance;
  static AuditLogger get instance => _instance ??= AuditLogger._();

  AuditLogger._();

  final List<AuditEntry> _entries = [];
  Timer? _flushTimer;
  bool _isInitialized = false;

  /// Initialize audit logger
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      // Start periodic flush timer
      _startFlushTimer();

      _isInitialized = true;
      TalkerConfig.logInfo('Audit logger initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to initialize audit logger', e, stackTrace);
      rethrow;
    }
  }

  /// Start periodic flush timer
  void _startFlushTimer() {
    _flushTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _flushEntries();
    });
  }

  /// Log user action
  Future<void> logUserAction(
    String action, {
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
    AuditLevel level = AuditLevel.info,
  }) async {
    try {
      final entry = AuditEntry(
        id: _generateId(),
        timestamp: DateTime.now(),
        level: level,
        category: AuditCategory.userAction,
        action: action,
        userId: userId,
        sessionId: sessionId,
        metadata: metadata ?? {},
        ipAddress: await _getCurrentIPAddress(),
        userAgent: await _getUserAgent(),
      );

      _addEntry(entry);
      TalkerConfig.logInfo('Audit logged: $action');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to log user action: $action',
        e,
        stackTrace,
      );
    }
  }

  /// Log security event
  Future<void> logSecurityEvent(
    String event, {
    String? userId,
    String? sessionId,
    Map<String, dynamic>? metadata,
    AuditLevel level = AuditLevel.warning,
  }) async {
    try {
      final entry = AuditEntry(
        id: _generateId(),
        timestamp: DateTime.now(),
        level: level,
        category: AuditCategory.security,
        action: event,
        userId: userId,
        sessionId: sessionId,
        metadata: metadata ?? {},
        ipAddress: await _getCurrentIPAddress(),
        userAgent: await _getUserAgent(),
      );

      _addEntry(entry);
      TalkerConfig.logWarning('Security event logged: $event');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to log security event: $event',
        e,
        stackTrace,
      );
    }
  }

  /// Log data access
  Future<void> logDataAccess(
    String resource, {
    String? userId,
    String? sessionId,
    String operation = 'READ',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final entry = AuditEntry(
        id: _generateId(),
        timestamp: DateTime.now(),
        level: AuditLevel.info,
        category: AuditCategory.dataAccess,
        action: '$operation:$resource',
        userId: userId,
        sessionId: sessionId,
        metadata: metadata ?? {},
        ipAddress: await _getCurrentIPAddress(),
        userAgent: await _getUserAgent(),
      );

      _addEntry(entry);
      TalkerConfig.logInfo('Data access logged: $operation $resource');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to log data access: $operation $resource',
        e,
        stackTrace,
      );
    }
  }

  /// Log system event
  Future<void> logSystemEvent(
    String event, {
    Map<String, dynamic>? metadata,
    AuditLevel level = AuditLevel.info,
  }) async {
    try {
      final entry = AuditEntry(
        id: _generateId(),
        timestamp: DateTime.now(),
        level: level,
        category: AuditCategory.system,
        action: event,
        metadata: metadata ?? {},
        ipAddress: await _getCurrentIPAddress(),
        userAgent: await _getUserAgent(),
      );

      _addEntry(entry);
      TalkerConfig.logInfo('System event logged: $event');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to log system event: $event',
        e,
        stackTrace,
      );
    }
  }

  /// Add entry to audit log
  void _addEntry(AuditEntry entry) {
    _entries.add(entry);

    // Keep only last 1000 entries in memory
    if (_entries.length > 1000) {
      _entries.removeAt(0);
    }
  }

  /// Generate unique ID
  String _generateId() {
    return 'AUDIT_${DateTime.now().millisecondsSinceEpoch}_${_entries.length}';
  }

  /// Get current IP address
  Future<String?> _getCurrentIPAddress() async {
    try {
      // In a real implementation, you would get the actual IP address
      // For now, return a placeholder
      return '127.0.0.1';
    } catch (e) {
      return null;
    }
  }

  /// Get user agent
  Future<String?> _getUserAgent() async {
    try {
      // In a real implementation, you would get the actual user agent
      // For now, return a placeholder
      return 'Flutter App/1.0.0';
    } catch (e) {
      return null;
    }
  }

  /// Flush entries to storage
  Future<void> _flushEntries() async {
    try {
      if (_entries.isEmpty) return;

      // In a real implementation, you would save to a secure database
      // For now, we'll just log them
      for (final entry in _entries) {
        TalkerConfig.logInfo('AUDIT: ${entry.toJson()}');
      }

      // Clear entries after flushing
      _entries.clear();
      TalkerConfig.logInfo('Audit entries flushed');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to flush audit entries', e, stackTrace);
    }
  }

  /// Get audit entries
  List<AuditEntry> getEntries({
    AuditCategory? category,
    AuditLevel? level,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    var filteredEntries = _entries.where((entry) {
      if (category != null && entry.category != category) return false;
      if (level != null && entry.level != level) return false;
      if (userId != null && entry.userId != userId) return false;
      if (startDate != null && entry.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && entry.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();

    // Sort by timestamp (newest first)
    filteredEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && filteredEntries.length > limit) {
      filteredEntries = filteredEntries.take(limit).toList();
    }

    return filteredEntries;
  }

  /// Get audit statistics
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{
      'total_entries': _entries.length,
      'by_category': {},
      'by_level': {},
      'by_user': {},
    };

    for (final entry in _entries) {
      // Count by category
      stats['by_category'][entry.category.name] =
          (stats['by_category'][entry.category.name] ?? 0) + 1;

      // Count by level
      stats['by_level'][entry.level.name] =
          (stats['by_level'][entry.level.name] ?? 0) + 1;

      // Count by user
      if (entry.userId != null) {
        stats['by_user'][entry.userId!] =
            (stats['by_user'][entry.userId!] ?? 0) + 1;
      }
    }

    return stats;
  }

  /// Export audit log
  String exportAuditLog() {
    final entries = _entries.map((e) => e.toJson()).toList();
    return jsonEncode({
      'exported_at': DateTime.now().toIso8601String(),
      'total_entries': entries.length,
      'entries': entries,
    });
  }

  /// Clear all audit entries
  void clearAll() {
    _entries.clear();
    TalkerConfig.logInfo('All audit entries cleared');
  }

  /// Dispose resources
  void dispose() {
    _flushTimer?.cancel();
    _entries.clear();
  }
}

/// Audit entry data class
class AuditEntry {
  final String id;
  final DateTime timestamp;
  final AuditLevel level;
  final AuditCategory category;
  final String action;
  final String? userId;
  final String? sessionId;
  final Map<String, dynamic> metadata;
  final String? ipAddress;
  final String? userAgent;

  const AuditEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.category,
    required this.action,
    this.userId,
    this.sessionId,
    required this.metadata,
    this.ipAddress,
    this.userAgent,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'category': category.name,
      'action': action,
      'user_id': userId,
      'session_id': sessionId,
      'metadata': metadata,
      'ip_address': ipAddress,
      'user_agent': userAgent,
    };
  }

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: AuditLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => AuditLevel.info,
      ),
      category: AuditCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => AuditCategory.system,
      ),
      action: json['action'] as String,
      userId: json['user_id'] as String?,
      sessionId: json['session_id'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
    );
  }

  @override
  String toString() {
    return 'AuditEntry(id: $id, action: $action, level: ${level.name}, category: ${category.name})';
  }
}

/// Audit levels
enum AuditLevel { debug, info, warning, error, critical }

/// Audit categories
enum AuditCategory {
  userAction,
  security,
  dataAccess,
  system,
  authentication,
  authorization,
}
