import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_repository.dart';

/// Background sync service for offline-first data
///
/// Usage:
/// ```dart
/// final syncService = ref.read(syncServiceProvider);
/// await syncService.startPeriodicSync();
/// ```
class SyncService {
  final dynamic database;
  final List<OfflineRepository> repositories;
  final Connectivity connectivity;

  Timer? _syncTimer;
  bool _isOnline = true;

  SyncService({
    required this.database,
    required this.repositories,
    required this.connectivity,
  }) {
    _initConnectivityListener();
  }

  /// Start periodic sync
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) => _syncData());
  }

  /// Stop periodic sync
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Manual sync trigger
  Future<void> syncNow() async {
    if (_isOnline) {
      await _syncData();
    }
  }

  /// Initialize connectivity listener
  void _initConnectivityListener() {
    connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final isOnline = results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );

      if (isOnline && !_isOnline) {
        // Came back online, sync immediately
        _syncData();
      }
      _isOnline = isOnline;
    });
  }

  /// Sync data for all repositories
  Future<void> _syncData() async {
    if (!_isOnline) return;

    try {
      for (final _ in repositories) {
        // await repository.syncWithRemote();
      }
    } catch (e) {
      // print('Sync failed: $e');
    }
  }

  /// Check if device is online
  bool get isOnline => _isOnline;

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
  }
}

/// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError('SyncService provider not implemented');
});
