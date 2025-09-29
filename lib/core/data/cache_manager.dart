import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cache manager for offline-first data
///
/// Usage:
/// ```dart
/// final cache = ref.read(cacheManagerProvider);
/// await cache.set('key', data);
/// final data = await cache.get('key');
/// ```
class CacheManager {
  final SharedPreferences _prefs;
  final Duration _defaultTtl;

  CacheManager({
    required SharedPreferences prefs,
    Duration defaultTtl = const Duration(hours: 24),
  }) : _prefs = prefs,
       _defaultTtl = defaultTtl;

  /// Set data with TTL
  Future<void> set(String key, dynamic data, {Duration? ttl}) async {
    final ttlToUse = ttl ?? _defaultTtl;
    final expiryTime = DateTime.now().add(ttlToUse);

    final cacheData = {'data': data, 'expiry': expiryTime.toIso8601String()};

    await _prefs.setString(key, json.encode(cacheData));
  }

  /// Get data if not expired
  Future<T?> get<T>(String key) async {
    final cached = _prefs.getString(key);
    if (cached == null) return null;

    try {
      final cacheData = json.decode(cached) as Map<String, dynamic>;
      final expiry = DateTime.parse(cacheData['expiry'] as String);

      if (DateTime.now().isAfter(expiry)) {
        await _prefs.remove(key);
        return null;
      }

      return cacheData['data'] as T?;
    } catch (e) {
      // Invalid cache data, remove it
      await _prefs.remove(key);
      return null;
    }
  }

  /// Check if key exists and is not expired
  Future<bool> exists(String key) async {
    final cached = _prefs.getString(key);
    if (cached == null) return false;

    try {
      final cacheData = json.decode(cached) as Map<String, dynamic>;
      final expiry = DateTime.parse(cacheData['expiry'] as String);

      if (DateTime.now().isAfter(expiry)) {
        await _prefs.remove(key);
        return false;
      }

      return true;
    } catch (e) {
      await _prefs.remove(key);
      return false;
    }
  }

  /// Remove specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Clear all cache
  Future<void> clear() async {
    await _prefs.clear();
  }

  /// Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  /// Get cache size (approximate)
  int getCacheSize() {
    return _prefs.getKeys().length;
  }

  /// Clean expired entries
  Future<void> cleanExpired() async {
    final keys = _prefs.getKeys();

    for (final key in keys) {
      final cached = _prefs.getString(key);
      if (cached == null) continue;

      try {
        final cacheData = json.decode(cached) as Map<String, dynamic>;
        final expiry = DateTime.parse(cacheData['expiry'] as String);

        if (DateTime.now().isAfter(expiry)) {
          await _prefs.remove(key);
        }
      } catch (e) {
        // Invalid cache data, remove it
        await _prefs.remove(key);
      }
    }
  }
}

/// Cache manager provider
final cacheManagerProvider = FutureProvider<CacheManager>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return CacheManager(prefs: prefs);
});

/// Cache key constants
class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String salesData = 'sales_data';
  static const String settings = 'settings';
  static const String lastSyncTime = 'last_sync_time';
}
