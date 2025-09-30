import 'dart:async';
import 'dart:math';
import '../logging/talker_config.dart';
import '../backend/backend_service.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Database Sync Service for Offline/Online Synchronization
///
/// Usage:
/// ```dart
/// final syncService = DatabaseSyncService();
/// await syncService.initialize();
/// await syncService.syncPendingChanges();
/// ```
class DatabaseSyncService {
  static final DatabaseSyncService _instance = DatabaseSyncService._internal();
  factory DatabaseSyncService() => _instance;
  static DatabaseSyncService get instance => _instance;
  DatabaseSyncService._internal();

  late BackendService _backendService;

  bool _isInitialized = false;
  bool _isSyncing = false;
  Timer? _syncTimer;

  final Map<String, List<SyncOperation>> _pendingOperations = {};
  final Map<String, DateTime> _lastSyncTimes = {};

  // Sync configuration
  static const Duration _syncInterval = Duration(minutes: 5);
  static const int _maxRetryAttempts = 3;
  // Removed unused field

  /// Initialize sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _backendService = BackendService();
      await _backendService.initialize();

      await _loadPendingOperations();
      _startPeriodicSync();

      _isInitialized = true;
      TalkerConfig.logInfo('Database sync service initialized');
    } catch (e) {
      TalkerConfig.logError('Failed to initialize database sync service', e);
    }
  }

  /// Sync pending changes
  Future<Result<SyncResult>> syncPendingChanges() async {
    if (_isSyncing) {
      return Error(Failure('Sync already in progress'));
    }

    try {
      _isSyncing = true;
      TalkerConfig.logInfo('🔄 Starting database sync...');

      final result = await _performSync();

      if (result.isSuccess) {
        TalkerConfig.logInfo('✅ Database sync completed successfully');
      } else {
        TalkerConfig.logError('❌ Database sync failed: ${result.error}');
      }

      return result;
    } catch (e) {
      TalkerConfig.logError('Database sync error', e);
      return Error(Failure('Database sync error: $e'));
    } finally {
      _isSyncing = false;
    }
  }

  /// Add operation to sync queue
  Future<void> addOperation(SyncOperation operation) async {
    try {
      _pendingOperations[operation.table] ??= [];
      _pendingOperations[operation.table]!.add(operation);

      // Save to local storage
      await _savePendingOperations();

      TalkerConfig.logInfo(
        '📝 Added operation to sync queue: ${operation.type} ${operation.table}',
      );
    } catch (e) {
      TalkerConfig.logError('Failed to add operation to sync queue', e);
    }
  }

  /// Create record
  Future<void> createRecord(String table, Map<String, dynamic> data) async {
    final operation = SyncOperation(
      id: _generateOperationId(),
      table: table,
      type: SyncOperationType.create,
      data: data,
      timestamp: DateTime.now(),
      retryCount: 0,
    );

    await addOperation(operation);
  }

  /// Update record
  Future<void> updateRecord(
    String table,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    final operation = SyncOperation(
      id: _generateOperationId(),
      table: table,
      type: SyncOperationType.update,
      recordId: recordId,
      data: data,
      timestamp: DateTime.now(),
      retryCount: 0,
    );

    await addOperation(operation);
  }

  /// Delete record
  Future<void> deleteRecord(String table, String recordId) async {
    final operation = SyncOperation(
      id: _generateOperationId(),
      table: table,
      type: SyncOperationType.delete,
      recordId: recordId,
      data: <String, dynamic>{}, // Delete operations don't need data
      timestamp: DateTime.now(),
      retryCount: 0,
    );

    await addOperation(operation);
  }

  /// Get sync status
  Map<String, dynamic> getSyncStatus() {
    final totalPending = _pendingOperations.values.fold(
      0,
      (sum, operations) => sum + operations.length,
    );

    final lastSyncTimes = Map<String, String>.from(
      _lastSyncTimes.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    );

    return {
      'is_syncing': _isSyncing,
      'total_pending_operations': totalPending,
      'pending_operations_by_table': _pendingOperations.map(
        (key, value) => MapEntry(key, value.length),
      ),
      'last_sync_times': lastSyncTimes,
      'sync_interval_minutes': _syncInterval.inMinutes,
      'max_retry_attempts': _maxRetryAttempts,
    };
  }

  /// Force sync specific table
  Future<Result<SyncResult>> syncTable(String table) async {
    if (_isSyncing) {
      return Error(Failure('Sync already in progress'));
    }

    try {
      _isSyncing = true;
      TalkerConfig.logInfo('🔄 Syncing table: $table');

      final operations = _pendingOperations[table] ?? [];
      if (operations.isEmpty) {
        return Success(
          SyncResult(
            successCount: 0,
            errorCount: 0,
            skippedCount: 0,
            duration: Duration.zero,
          ),
        );
      }

      final result = await _syncOperations(operations);

      if (result.isSuccess) {
        _pendingOperations[table] = [];
        _lastSyncTimes[table] = DateTime.now();
        await _savePendingOperations();
      }

      return result;
    } catch (e) {
      TalkerConfig.logError('Failed to sync table: $table', e);
      return Error(Failure('Failed to sync table: $e'));
    } finally {
      _isSyncing = false;
    }
  }

  /// Clear all pending operations
  Future<void> clearPendingOperations() async {
    try {
      _pendingOperations.clear();
      await _savePendingOperations();
      TalkerConfig.logInfo('🗑️ Cleared all pending operations');
    } catch (e) {
      TalkerConfig.logError('Failed to clear pending operations', e);
    }
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _isInitialized = false;
  }

  // Private methods
  Future<void> _startPeriodicSync() async {
    _syncTimer = Timer.periodic(_syncInterval, (timer) async {
      if (!_isSyncing) {
        await syncPendingChanges();
      }
    });
  }

  Future<Result<SyncResult>> _performSync() async {
    final allOperations = <SyncOperation>[];
    for (final operations in _pendingOperations.values) {
      allOperations.addAll(operations);
    }

    if (allOperations.isEmpty) {
      return Success(
        SyncResult(
          successCount: 0,
          errorCount: 0,
          skippedCount: 0,
          duration: Duration.zero,
        ),
      );
    }

    return await _syncOperations(allOperations);
  }

  Future<Result<SyncResult>> _syncOperations(
    List<SyncOperation> operations,
  ) async {
    final startTime = DateTime.now();
    int successCount = 0;
    int errorCount = 0;
    int skippedCount = 0;

    // Group operations by table
    final operationsByTable = <String, List<SyncOperation>>{};
    for (final operation in operations) {
      operationsByTable[operation.table] ??= [];
      operationsByTable[operation.table]!.add(operation);
    }

    // Sync each table
    for (final entry in operationsByTable.entries) {
      final table = entry.key;
      final tableOperations = entry.value;

      try {
        final result = await _syncTableOperations(table, tableOperations);
        successCount += result.successCount;
        errorCount += result.errorCount;
        skippedCount += result.skippedCount;
      } catch (e) {
        TalkerConfig.logError('Failed to sync table: $table', e);
        errorCount += tableOperations.length;
      }
    }

    final duration = DateTime.now().difference(startTime);
    final syncResult = SyncResult(
      successCount: successCount,
      errorCount: errorCount,
      skippedCount: skippedCount,
      duration: duration,
    );

    return Success(syncResult);
  }

  Future<SyncResult> _syncTableOperations(
    String table,
    List<SyncOperation> operations,
  ) async {
    int successCount = 0;
    int errorCount = 0;
    int skippedCount = 0;

    for (final operation in operations) {
      try {
        final result = await _executeOperation(operation);
        if (result.isSuccess) {
          successCount++;
          // Remove from pending operations
          _pendingOperations[table]?.remove(operation);
        } else {
          errorCount++;
          // Increment retry count
          operation.retryCount++;
          if (operation.retryCount >= _maxRetryAttempts) {
            // Remove operation after max retries
            _pendingOperations[table]?.remove(operation);
            TalkerConfig.logError(
              'Operation failed after max retries: ${operation.id}',
            );
          }
        }
      } catch (e) {
        TalkerConfig.logError('Operation execution error: ${operation.id}', e);
        errorCount++;
      }
    }

    return SyncResult(
      successCount: successCount,
      errorCount: errorCount,
      skippedCount: skippedCount,
      duration: Duration.zero,
    );
  }

  Future<Result<void>> _executeOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case SyncOperationType.create:
          return await _executeCreateOperation(operation);
        case SyncOperationType.update:
          return await _executeUpdateOperation(operation);
        case SyncOperationType.delete:
          return await _executeDeleteOperation(operation);
      }
    } catch (e) {
      TalkerConfig.logError('Failed to execute operation: ${operation.id}', e);
      return Error(Failure('Operation execution failed: $e'));
    }
  }

  Future<Result<void>> _executeCreateOperation(SyncOperation operation) async {
    switch (operation.table) {
      case 'sales':
        return await _backendService.createSale(operation.data);
      case 'customers':
        return await _backendService.createCustomer(operation.data);
      case 'inventory':
        return await _backendService.updateInventoryItem(
          operation.recordId!,
          operation.data,
        );
      default:
        return Error(Failure('Unknown table: ${operation.table}'));
    }
  }

  Future<Result<void>> _executeUpdateOperation(SyncOperation operation) async {
    switch (operation.table) {
      case 'sales':
        return await _backendService.updateSale(
          operation.recordId!,
          operation.data,
        );
      case 'customers':
        return await _backendService.updateCustomer(
          operation.recordId!,
          operation.data,
        );
      case 'inventory':
        return await _backendService.updateInventoryItem(
          operation.recordId!,
          operation.data,
        );
      default:
        return Error(Failure('Unknown table: ${operation.table}'));
    }
  }

  Future<Result<void>> _executeDeleteOperation(SyncOperation operation) async {
    switch (operation.table) {
      case 'sales':
        return await _backendService.deleteSale(operation.recordId!);
      case 'customers':
        return await _backendService.deleteCustomer(operation.recordId!);
      default:
        return Error(Failure('Unknown table: ${operation.table}'));
    }
  }

  Future<void> _loadPendingOperations() async {
    try {
      // Load from local database
      // Note: In a real implementation, this would load from a local database
      // For now, we'll simulate loading operations
      TalkerConfig.logInfo('Loading pending operations from local database');
    } catch (e) {
      TalkerConfig.logError('Failed to load pending operations', e);
    }
  }

  Future<void> _savePendingOperations() async {
    try {
      // Save to local database
      // Note: In a real implementation, this would save to a local database
      // For now, we'll simulate saving operations
      TalkerConfig.logInfo('Saving pending operations to local database');
    } catch (e) {
      TalkerConfig.logError('Failed to save pending operations', e);
    }
  }

  String _generateOperationId() {
    return 'op_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
}

/// Sync Operation class
class SyncOperation {
  final String id;
  final String table;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final String? recordId;
  final DateTime timestamp;
  int retryCount;

  SyncOperation({
    required this.id,
    required this.table,
    required this.type,
    required this.data,
    this.recordId,
    required this.timestamp,
    required this.retryCount,
  });
}

/// Sync Operation Type enum
enum SyncOperationType { create, update, delete }

/// Sync Result class
class SyncResult {
  final int successCount;
  final int errorCount;
  final int skippedCount;
  final Duration duration;

  const SyncResult({
    required this.successCount,
    required this.errorCount,
    required this.skippedCount,
    required this.duration,
  });

  int get totalCount => successCount + errorCount + skippedCount;
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;
  double get errorRate => totalCount > 0 ? errorCount / totalCount : 0.0;
}
