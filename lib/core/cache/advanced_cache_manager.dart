import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../logging/talker_config.dart';

/// Advanced cache manager with Hive and memory caching
///
/// Usage:
/// ```dart
/// final cache = AdvancedCacheManager();
/// await cache.initialize();
/// await cache.set('key', data);
/// final data = await cache.get('key');
/// ```
class AdvancedCacheManager {
  static AdvancedCacheManager? _instance;
  static AdvancedCacheManager get instance =>
      _instance ??= AdvancedCacheManager._();

  AdvancedCacheManager._();

  late Box<String> _cacheBox;
  final Map<String, CacheItem> _memoryCache = {};
  final Map<String, Timer> _expirationTimers = {};

  bool _isInitialized = false;
  final Duration _defaultExpiration = const Duration(hours: 1);
  final int _maxMemoryItems = 100;

  /// Initialize cache manager
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _cacheBox = await Hive.openBox<String>('advanced_cache');

      // Clean expired items on startup
      await _cleanExpiredItems();

      _isInitialized = true;
      TalkerConfig.logInfo('Advanced cache manager initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize cache manager',
        e,
        stackTrace,
      );
    }
  }

  /// Set cache item
  Future<void> set<T>(
    String key,
    T value, {
    Duration? expiration,
    CachePriority priority = CachePriority.normal,
    bool persistToDisk = true,
  }) async {
    try {
      if (!_isInitialized) {
        TalkerConfig.logWarning('Cache manager not initialized');
        return;
      }

      final jsonString = jsonEncode(value);
      final item = CacheItem<T>(
        key: key,
        value: value,
        jsonString: jsonString,
        createdAt: DateTime.now(),
        expiration: expiration ?? _defaultExpiration,
        priority: priority,
        persistToDisk: persistToDisk,
      );

      // Store in memory cache
      _memoryCache[key] = item;

      // Set expiration timer
      _setExpirationTimer(key, item.expiration);

      // Store in disk cache if needed
      if (persistToDisk) {
        await _cacheBox.put(key, jsonString);
      }

      // Clean memory cache if needed
      _cleanMemoryCacheIfNeeded();

      TalkerConfig.logInfo('Cached item: $key');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to cache item: $key', e, stackTrace);
    }
  }

  /// Get cache item
  Future<T?> get<T>(String key) async {
    try {
      if (!_isInitialized) {
        TalkerConfig.logWarning('Cache manager not initialized');
        return null;
      }

      // Check memory cache first
      final memoryItem = _memoryCache[key];
      if (memoryItem != null && !_isExpired(memoryItem)) {
        TalkerConfig.logInfo('Cache hit (memory): $key');
        return memoryItem.value as T?;
      }

      // Check disk cache
      final diskItem = _cacheBox.get(key);
      if (diskItem != null) {
        try {
          final item = CacheItem<T>.fromJson(diskItem);
          if (!_isExpired(item)) {
            // Store back in memory cache
            _memoryCache[key] = item;
            _setExpirationTimer(key, item.expiration);

            TalkerConfig.logInfo('Cache hit (disk): $key');
            return item.value;
          } else {
            // Remove expired item
            await _cacheBox.delete(key);
          }
        } catch (e) {
          // Invalid JSON, remove item
          await _cacheBox.delete(key);
        }
      }

      TalkerConfig.logInfo('Cache miss: $key');
      return null;
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get cache item: $key', e, stackTrace);
      return null;
    }
  }

  /// Get cache item with fallback
  Future<T> getOrSet<T>(
    String key,
    Future<T> Function() fallback, {
    Duration? expiration,
    CachePriority priority = CachePriority.normal,
    bool persistToDisk = true,
  }) async {
    final cached = await get<T>(key);
    if (cached != null) {
      return cached;
    }

    final value = await fallback();
    await set(
      key,
      value,
      expiration: expiration,
      priority: priority,
      persistToDisk: persistToDisk,
    );
    return value;
  }

  /// Remove cache item
  Future<void> remove(String key) async {
    try {
      _memoryCache.remove(key);
      _expirationTimers[key]?.cancel();
      _expirationTimers.remove(key);
      await _cacheBox.delete(key);

      TalkerConfig.logInfo('Removed cache item: $key');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to remove cache item: $key', e, stackTrace);
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    try {
      _memoryCache.clear();
      for (final timer in _expirationTimers.values) {
        timer.cancel();
      }
      _expirationTimers.clear();
      await _cacheBox.clear();

      TalkerConfig.logInfo('Cleared all cache');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to clear cache', e, stackTrace);
    }
  }

  /// Check if item exists in cache
  Future<bool> exists(String key) async {
    if (_memoryCache.containsKey(key)) {
      return !_isExpired(_memoryCache[key]!);
    }

    final diskItem = _cacheBox.get(key);
    if (diskItem != null) {
      try {
        final item = CacheItem.fromJson(diskItem);
        return !_isExpired(item);
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  /// Get cache statistics
  CacheStatistics getStatistics() {
    final memoryItems = _memoryCache.length;
    final diskItems = _cacheBox.length;
    final memorySize = _calculateMemorySize();
    final diskSize = _calculateDiskSize();

    return CacheStatistics(
      memoryItems: memoryItems,
      diskItems: diskItems,
      memorySize: memorySize,
      diskSize: diskSize,
      hitRate: _calculateHitRate(),
    );
  }

  /// Check if item is expired
  bool _isExpired(CacheItem item) {
    return DateTime.now().isAfter(item.createdAt.add(item.expiration));
  }

  /// Set expiration timer
  void _setExpirationTimer(String key, Duration expiration) {
    _expirationTimers[key]?.cancel();
    _expirationTimers[key] = Timer(expiration, () {
      _memoryCache.remove(key);
      _expirationTimers.remove(key);
    });
  }

  /// Clean expired items
  Future<void> _cleanExpiredItems() async {
    try {
      final keysToRemove = <String>[];

      // Clean memory cache
      for (final entry in _memoryCache.entries) {
        if (_isExpired(entry.value)) {
          keysToRemove.add(entry.key);
        }
      }

      for (final key in keysToRemove) {
        _memoryCache.remove(key);
        _expirationTimers[key]?.cancel();
        _expirationTimers.remove(key);
      }

      // Clean disk cache
      final diskKeysToRemove = <String>[];
      for (final key in _cacheBox.keys) {
        try {
          final item = CacheItem.fromJson(_cacheBox.get(key)!);
          if (_isExpired(item)) {
            diskKeysToRemove.add(key);
          }
        } catch (e) {
          // Invalid JSON, remove
          diskKeysToRemove.add(key);
        }
      }

      for (final key in diskKeysToRemove) {
        await _cacheBox.delete(key);
      }

      if (keysToRemove.isNotEmpty || diskKeysToRemove.isNotEmpty) {
        TalkerConfig.logInfo(
          'Cleaned ${keysToRemove.length} memory items and ${diskKeysToRemove.length} disk items',
        );
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to clean expired items', e, stackTrace);
    }
  }

  /// Clean memory cache if needed
  void _cleanMemoryCacheIfNeeded() {
    if (_memoryCache.length > _maxMemoryItems) {
      // Remove oldest items first
      final sortedEntries = _memoryCache.entries.toList()
        ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));

      final itemsToRemove = sortedEntries.take(
        _memoryCache.length - _maxMemoryItems,
      );
      for (final entry in itemsToRemove) {
        _memoryCache.remove(entry.key);
        _expirationTimers[entry.key]?.cancel();
        _expirationTimers.remove(entry.key);
      }
    }
  }

  /// Calculate memory cache size
  int _calculateMemorySize() {
    return _memoryCache.values.fold(
      0,
      (sum, item) => sum + item.jsonString.length,
    );
  }

  /// Calculate disk cache size
  int _calculateDiskSize() {
    return _cacheBox.values.fold(0, (sum, item) => sum + item.length);
  }

  /// Calculate cache hit rate
  double _calculateHitRate() {
    // This would be implemented with proper hit/miss tracking
    return 0.0;
  }

  /// Dispose resources
  void dispose() {
    for (final timer in _expirationTimers.values) {
      timer.cancel();
    }
    _expirationTimers.clear();
    _memoryCache.clear();
    _cacheBox.close();
  }
}

/// Cache item data class
class CacheItem<T> {
  final String key;
  final T value;
  final String jsonString;
  final DateTime createdAt;
  final Duration expiration;
  final CachePriority priority;
  final bool persistToDisk;

  CacheItem({
    required this.key,
    required this.value,
    required this.jsonString,
    required this.createdAt,
    required this.expiration,
    required this.priority,
    required this.persistToDisk,
  });

  factory CacheItem.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    return CacheItem<T>(
      key: json['key'] as String,
      value: json['value'] as T,
      jsonString: jsonString,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiration: Duration(seconds: json['expiration'] as int),
      priority: CachePriority.values[json['priority'] as int],
      persistToDisk: json['persistToDisk'] as bool,
    );
  }

  String toJson() {
    return jsonEncode({
      'key': key,
      'value': value,
      'createdAt': createdAt.toIso8601String(),
      'expiration': expiration.inSeconds,
      'priority': priority.index,
      'persistToDisk': persistToDisk,
    });
  }
}

/// Cache priority levels
enum CachePriority { low, normal, high, critical }

/// Cache statistics
class CacheStatistics {
  final int memoryItems;
  final int diskItems;
  final int memorySize;
  final int diskSize;
  final double hitRate;

  CacheStatistics({
    required this.memoryItems,
    required this.diskItems,
    required this.memorySize,
    required this.diskSize,
    required this.hitRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'memoryItems': memoryItems,
      'diskItems': diskItems,
      'memorySize': memorySize,
      'diskSize': diskSize,
      'hitRate': hitRate,
    };
  }
}
