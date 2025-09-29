import 'package:dio/dio.dart';
import '../database/database.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Offline-first repository pattern
///
/// Usage:
/// ```dart
/// final repository = OfflineRepository(database: database, dio: dio);
/// final result = await repository.getData();
/// ```
abstract class OfflineRepository<T, K> {
  final AppDatabase database;
  final Dio dio;

  OfflineRepository({required this.database, required this.dio});

  /// Get data with offline-first strategy
  Future<Result<List<T>>> getData() async {
    try {
      // 1. Return local data immediately (stale-while-revalidate)
      final localData = await getLocalData();

      // 2. Try to refresh from remote in background
      _refreshFromRemote();

      return Result.ok(localData);
    } catch (e, stack) {
      return Result.err(
        Failure(
          'Failed to get data: ${e.toString()}',
          stack: stack,
          originalError: e,
        ),
      );
    }
  }

  /// Get data with force refresh
  Future<Result<List<T>>> getDataForceRefresh() async {
    try {
      // 1. Try to get fresh data from remote
      final remoteData = await fetchFromRemote();

      // 2. Update local storage
      await updateLocalData(remoteData);

      return Result.ok(remoteData);
    } catch (e, stack) {
      // Fallback to local data if remote fails
      try {
        final localData = await getLocalData();
        return Result.ok(localData);
      } catch (localError) {
        return Result.err(
          Failure(
            'Failed to get data: ${e.toString()}',
            stack: stack,
            originalError: e,
          ),
        );
      }
    }
  }

  /// Create new item
  Future<Result<T>> createItem(T item) async {
    try {
      // 1. Save to local storage immediately
      await saveToLocal(item);

      // 2. Try to sync to remote in background
      _syncToRemote(item);

      return Result.ok(item);
    } catch (e, stack) {
      return Result.err(
        Failure(
          'Failed to create item: ${e.toString()}',
          stack: stack,
          originalError: e,
        ),
      );
    }
  }

  /// Update item
  Future<Result<T>> updateItem(K id, T item) async {
    try {
      // 1. Update local storage immediately
      await updateLocal(id, item);

      // 2. Try to sync to remote in background
      _syncToRemote(item);

      return Result.ok(item);
    } catch (e, stack) {
      return Result.err(
        Failure(
          'Failed to update item: ${e.toString()}',
          stack: stack,
          originalError: e,
        ),
      );
    }
  }

  /// Delete item
  Future<Result<void>> deleteItem(K id) async {
    try {
      // 1. Delete from local storage immediately
      await deleteLocal(id);

      // 2. Try to sync deletion to remote in background
      _syncDeletionToRemote(id);

      return Result.ok(null);
    } catch (e, stack) {
      return Result.err(
        Failure(
          'Failed to delete item: ${e.toString()}',
          stack: stack,
          originalError: e,
        ),
      );
    }
  }

  /// Sync all pending changes
  Future<Result<void>> syncPendingChanges() async {
    try {
      final pendingItems = await getUnsyncedItems();

      for (final item in pendingItems) {
        await syncItemToRemote(item);
      }

      return Result.ok(null);
    } catch (e, stack) {
      return Result.err(
        Failure(
          'Failed to sync changes: ${e.toString()}',
          stack: stack,
          originalError: e,
        ),
      );
    }
  }

  // Abstract methods to be implemented by concrete repositories
  Future<List<T>> getLocalData();
  Future<List<T>> fetchFromRemote();
  Future<void> updateLocalData(List<T> data);
  Future<void> saveToLocal(T item);
  Future<void> updateLocal(K id, T item);
  Future<void> deleteLocal(K id);
  Future<List<T>> getUnsyncedItems();
  Future<void> syncItemToRemote(T item);
  Future<void> syncDeletionToRemote(K id);

  // Background sync methods
  void _refreshFromRemote() {
    fetchFromRemote()
        .then((data) {
          updateLocalData(data);
        })
        .catchError((e) {
          // Log error but don't throw
          // print('Background refresh failed: $e');
        });
  }

  void _syncToRemote(T item) {
    syncItemToRemote(item).catchError((e) {
      // Log error but don't throw
      // print('Background sync failed: $e');
    });
  }

  void _syncDeletionToRemote(K id) {
    syncDeletionToRemote(id).catchError((e) {
      // Log error but don't throw
      // print('Background deletion sync failed: $e');
    });
  }
}
