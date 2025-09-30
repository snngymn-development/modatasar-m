import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../logging/talker_config.dart';

/// Advanced caching service with intelligent cache management
///
/// Usage:
/// ```dart
/// final cacheService = AdvancedCacheService();
/// await cacheService.set('key', data, ttl: Duration(hours: 1));
/// final data = await cacheService.get('key');
/// ```
class AdvancedCacheService {
  static final AdvancedCacheService _instance =
      AdvancedCacheService._internal();
  factory AdvancedCacheService() => _instance;
  AdvancedCacheService._internal();

  final Map<String, CacheEntry> _memoryCache = {};
  final Map<String, DateTime> _accessTimes = {};
  final Map<String, int> _accessCounts = {};

  Directory? _cacheDirectory;
  Timer? _cleanupTimer;
  final int _maxMemoryCacheSize = 100;

  /// Initialize cache service
  Future<void> initialize() async {
    try {
      // Get cache directory
      _cacheDirectory = await getTemporaryDirectory();
      await _cacheDirectory!.create(recursive: true);

      // Start cleanup timer
      _startCleanupTimer();

      // Load existing cache metadata
      await _loadCacheMetadata();

      TalkerConfig.logInfo('Advanced cache service initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize cache service',
        e,
        stackTrace,
      );
    }
  }

  /// Set cache entry with TTL and priority
  Future<void> set(
    String key,
    dynamic value, {
    Duration? ttl,
    CachePriority priority = CachePriority.normal,
    bool persistToDisk = false,
  }) async {
    try {
      final now = DateTime.now();
      final expiry = ttl != null ? now.add(ttl) : null;

      final entry = CacheEntry(
        key: key,
        value: value,
        createdAt: now,
        expiresAt: expiry,
        priority: priority,
        accessCount: 0,
        lastAccessed: now,
      );

      // Store in memory cache
      _memoryCache[key] = entry;
      _accessTimes[key] = now;
      _accessCounts[key] = 0;

      // Persist to disk if requested
      if (persistToDisk) {
        await _persistToDisk(key, entry);
      }

      // Cleanup if cache is full
      await _cleanupIfNeeded();

      TalkerConfig.logInfo('Cache entry set: $key');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to set cache entry: $key', e, stackTrace);
    }
  }

  /// Get cache entry
  Future<T?> get<T>(String key) async {
    try {
      // Check memory cache first
      final memoryEntry = _memoryCache[key];
      if (memoryEntry != null) {
        if (_isExpired(memoryEntry)) {
          await remove(key);
          return null;
        }

        // Update access statistics
        _updateAccessStats(key);
        return memoryEntry.value as T?;
      }

      // Check disk cache
      final diskEntry = await _loadFromDisk(key);
      if (diskEntry != null) {
        if (_isExpired(diskEntry)) {
          await remove(key);
          return null;
        }

        // Move to memory cache
        _memoryCache[key] = diskEntry;
        _updateAccessStats(key);
        return diskEntry.value as T?;
      }

      return null;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get cache entry: $key', e, stackTrace);
      return null;
    }
  }

  /// Get or set cache entry
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
    CachePriority priority = CachePriority.normal,
    bool persistToDisk = false,
  }) async {
    try {
      final cached = await get<T>(key);
      if (cached != null) {
        return cached;
      }

      final value = await fetcher();
      await set(
        key,
        value,
        ttl: ttl,
        priority: priority,
        persistToDisk: persistToDisk,
      );
      return value;
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to get or set cache entry: $key',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Remove cache entry
  Future<void> remove(String key) async {
    try {
      // Remove from memory cache
      _memoryCache.remove(key);
      _accessTimes.remove(key);
      _accessCounts.remove(key);

      // Remove from disk cache
      await _removeFromDisk(key);

      TalkerConfig.logInfo('Cache entry removed: $key');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to remove cache entry: $key',
        e,
        stackTrace,
      );
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    try {
      _memoryCache.clear();
      _accessTimes.clear();
      _accessCounts.clear();

      if (_cacheDirectory != null) {
        final files = _cacheDirectory!.listSync();
        for (final file in files) {
          if (file is File) {
            await file.delete();
          }
        }
      }

      TalkerConfig.logInfo('All cache cleared');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to clear cache', e, stackTrace);
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    final totalEntries = _memoryCache.length;
    final expiredEntries = _memoryCache.values
        .where((entry) => _isExpired(entry))
        .length;
    final diskEntries = _getDiskCacheCount();

    final memoryUsage = _calculateMemoryUsage();
    final diskUsage = _calculateDiskUsage();

    return {
      'total_entries': totalEntries,
      'memory_entries': totalEntries,
      'disk_entries': diskEntries,
      'expired_entries': expiredEntries,
      'memory_usage_mb': memoryUsage,
      'disk_usage_mb': diskUsage,
      'hit_rate': _calculateHitRate(),
      'most_accessed': _getMostAccessedKeys(5),
      'oldest_entry': _getOldestEntry()?.createdAt.toIso8601String(),
      'newest_entry': _getNewestEntry()?.createdAt.toIso8601String(),
    };
  }

  /// Check if cache entry is expired
  bool _isExpired(CacheEntry entry) {
    if (entry.expiresAt == null) return false;
    return DateTime.now().isAfter(entry.expiresAt!);
  }

  /// Update access statistics
  void _updateAccessStats(String key) {
    _accessTimes[key] = DateTime.now();
    _accessCounts[key] = (_accessCounts[key] ?? 0) + 1;

    // Update entry access count
    final entry = _memoryCache[key];
    if (entry != null) {
      _memoryCache[key] = CacheEntry(
        key: entry.key,
        value: entry.value,
        createdAt: entry.createdAt,
        expiresAt: entry.expiresAt,
        priority: entry.priority,
        accessCount: entry.accessCount + 1,
        lastAccessed: DateTime.now(),
      );
    }
  }

  /// Start cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _performCleanup(),
    );
  }

  /// Perform cache cleanup
  Future<void> _performCleanup() async {
    try {
      // Remove expired entries
      final expiredKeys = _memoryCache.entries
          .where((entry) => _isExpired(entry.value))
          .map((entry) => entry.key)
          .toList();

      for (final key in expiredKeys) {
        await remove(key);
      }

      // Cleanup old disk cache files
      await _cleanupOldDiskFiles();

      // Cleanup memory cache if too large
      await _cleanupMemoryCache();

      if (expiredKeys.isNotEmpty) {
        TalkerConfig.logInfo(
          'Cache cleanup completed: ${expiredKeys.length} entries removed',
        );
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to perform cache cleanup', e, stackTrace);
    }
  }

  /// Cleanup memory cache if too large
  Future<void> _cleanupMemoryCache() async {
    if (_memoryCache.length <= _maxMemoryCacheSize) return;

    // Sort by priority and access count
    final sortedEntries = _memoryCache.entries.toList()
      ..sort((a, b) {
        // First sort by priority
        final priorityComparison = a.value.priority.index.compareTo(
          b.value.priority.index,
        );
        if (priorityComparison != 0) return priorityComparison;

        // Then sort by access count (least accessed first)
        return a.value.accessCount.compareTo(b.value.accessCount);
      });

    // Remove least important entries
    final toRemove = sortedEntries.take(
      _memoryCache.length - _maxMemoryCacheSize,
    );
    for (final entry in toRemove) {
      await remove(entry.key);
    }
  }

  /// Cleanup if cache is full
  Future<void> _cleanupIfNeeded() async {
    if (_memoryCache.length > _maxMemoryCacheSize) {
      await _cleanupMemoryCache();
    }
  }

  /// Persist entry to disk
  Future<void> _persistToDisk(String key, CacheEntry entry) async {
    try {
      if (_cacheDirectory == null) return;

      final file = File('${_cacheDirectory!.path}/$key.json');
      final data = {
        'key': entry.key,
        'value': entry.value,
        'createdAt': entry.createdAt.toIso8601String(),
        'expiresAt': entry.expiresAt?.toIso8601String(),
        'priority': entry.priority.index,
        'accessCount': entry.accessCount,
        'lastAccessed': entry.lastAccessed.toIso8601String(),
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to persist cache entry to disk: $key',
        e,
        stackTrace,
      );
    }
  }

  /// Load entry from disk
  Future<CacheEntry?> _loadFromDisk(String key) async {
    try {
      if (_cacheDirectory == null) return null;

      final file = File('${_cacheDirectory!.path}/$key.json');
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      return CacheEntry(
        key: data['key'] as String,
        value: data['value'],
        createdAt: DateTime.parse(data['createdAt'] as String),
        expiresAt: data['expiresAt'] != null
            ? DateTime.parse(data['expiresAt'] as String)
            : null,
        priority: CachePriority.values[data['priority'] as int],
        accessCount: data['accessCount'] as int,
        lastAccessed: DateTime.parse(data['lastAccessed'] as String),
      );
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to load cache entry from disk: $key',
        e,
        stackTrace,
      );
      return null;
    }
  }

  /// Remove entry from disk
  Future<void> _removeFromDisk(String key) async {
    try {
      if (_cacheDirectory == null) return;

      final file = File('${_cacheDirectory!.path}/$key.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to remove cache entry from disk: $key',
        e,
        stackTrace,
      );
    }
  }

  /// Load cache metadata
  Future<void> _loadCacheMetadata() async {
    // Implementation for loading cache metadata
  }

  /// Cleanup old disk files
  Future<void> _cleanupOldDiskFiles() async {
    if (_cacheDirectory == null) return;

    try {
      final files = _cacheDirectory!.listSync();
      final now = DateTime.now();
      final maxAge = const Duration(days: 7);

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final stat = await file.stat();
          if (now.difference(stat.modified) > maxAge) {
            await file.delete();
          }
        }
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to cleanup old disk files', e, stackTrace);
    }
  }

  /// Calculate memory usage
  double _calculateMemoryUsage() {
    // Simplified memory usage calculation
    return _memoryCache.length * 0.1; // Assume 0.1MB per entry
  }

  /// Calculate disk usage
  double _calculateDiskUsage() {
    // Simplified disk usage calculation
    return _getDiskCacheCount() * 0.05; // Assume 0.05MB per entry
  }

  /// Get disk cache count
  int _getDiskCacheCount() {
    if (_cacheDirectory == null) return 0;
    try {
      return _cacheDirectory!
          .listSync()
          .where((file) => file is File && file.path.endsWith('.json'))
          .length;
    } catch (e) {
      return 0;
    }
  }

  /// Calculate hit rate
  double _calculateHitRate() {
    final totalAccesses = _accessCounts.values.fold(
      0,
      (sum, count) => sum + count,
    );
    if (totalAccesses == 0) return 0.0;

    final hits = _accessCounts.values.where((count) => count > 0).length;
    return hits / totalAccesses;
  }

  /// Get most accessed keys
  List<String> _getMostAccessedKeys(int count) {
    final sortedKeys = _accessCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedKeys.take(count).map((entry) => entry.key).toList();
  }

  /// Get oldest entry
  CacheEntry? _getOldestEntry() {
    if (_memoryCache.isEmpty) return null;

    return _memoryCache.values.reduce(
      (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
    );
  }

  /// Get newest entry
  CacheEntry? _getNewestEntry() {
    if (_memoryCache.isEmpty) return null;

    return _memoryCache.values.reduce(
      (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
    );
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
    _accessTimes.clear();
    _accessCounts.clear();
    TalkerConfig.logInfo('Cache service disposed');
  }
}

/// Cache entry data class
class CacheEntry {
  final String key;
  final dynamic value;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final CachePriority priority;
  final int accessCount;
  final DateTime lastAccessed;

  const CacheEntry({
    required this.key,
    required this.value,
    required this.createdAt,
    this.expiresAt,
    required this.priority,
    required this.accessCount,
    required this.lastAccessed,
  });
}

/// Cache priority levels
enum CachePriority { low, normal, high, critical }
