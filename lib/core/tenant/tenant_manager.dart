import 'dart:async';
// import 'package:equatable/equatable.dart'; // Not used
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logging/talker_config.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Multi-tenant Manager for Enterprise Applications
///
/// Usage:
/// ```dart
/// final tenantManager = TenantManager();
/// await tenantManager.setCurrentTenant('tenant-123');
/// final currentTenant = tenantManager.getCurrentTenant();
/// ```
class TenantManager {
  static final TenantManager _instance = TenantManager._internal();
  factory TenantManager() => _instance;
  TenantManager._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _currentTenantKey = 'current_tenant_id';
  // static const String _tenantConfigKey = 'tenant_config'; // Not used

  Tenant? _currentTenant;
  final Map<String, Tenant> _tenants = {};

  /// Set current tenant
  Future<Result<void>> setCurrentTenant(String tenantId) async {
    try {
      final tenant = _tenants[tenantId];
      if (tenant == null) {
        return Error(Failure('Tenant not found: $tenantId'));
      }

      _currentTenant = tenant;
      await _storage.write(key: _currentTenantKey, value: tenantId);

      TalkerConfig.logInfo('Current tenant set to: $tenantId');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to set current tenant', e);
      return Error(Failure('Failed to set current tenant: $e'));
    }
  }

  /// Get current tenant
  Tenant? getCurrentTenant() {
    return _currentTenant;
  }

  /// Get current tenant ID
  String? getCurrentTenantId() {
    return _currentTenant?.id;
  }

  /// Register a tenant
  Future<Result<void>> registerTenant(Tenant tenant) async {
    try {
      _tenants[tenant.id] = tenant;
      TalkerConfig.logInfo('Tenant registered: ${tenant.id}');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to register tenant', e);
      return Error(Failure('Failed to register tenant: $e'));
    }
  }

  /// Get tenant by ID
  Tenant? getTenant(String tenantId) {
    return _tenants[tenantId];
  }

  /// Get all tenants
  List<Tenant> getAllTenants() {
    return _tenants.values.toList();
  }

  /// Load current tenant from storage
  Future<Result<void>> loadCurrentTenant() async {
    try {
      final tenantId = await _storage.read(key: _currentTenantKey);
      if (tenantId != null) {
        final tenant = _tenants[tenantId];
        if (tenant != null) {
          _currentTenant = tenant;
          TalkerConfig.logInfo('Current tenant loaded: $tenantId');
          return const Success(null);
        }
      }
      return Error(Failure('No current tenant found'));
    } catch (e) {
      TalkerConfig.logError('Failed to load current tenant', e);
      return Error(Failure('Failed to load current tenant: $e'));
    }
  }

  /// Clear current tenant
  Future<void> clearCurrentTenant() async {
    _currentTenant = null;
    await _storage.delete(key: _currentTenantKey);
    TalkerConfig.logInfo('Current tenant cleared');
  }

  /// Get tenant-specific configuration
  Map<String, dynamic>? getTenantConfig() {
    return _currentTenant?.config;
  }

  /// Update tenant configuration
  Future<Result<void>> updateTenantConfig(Map<String, dynamic> config) async {
    try {
      if (_currentTenant == null) {
        return Error(Failure('No current tenant'));
      }

      _currentTenant = _currentTenant!.copyWith(config: config);
      _tenants[_currentTenant!.id] = _currentTenant!;

      TalkerConfig.logInfo('Tenant config updated for: ${_currentTenant!.id}');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to update tenant config', e);
      return Error(Failure('Failed to update tenant config: $e'));
    }
  }

  /// Check if tenant is active
  bool isTenantActive(String tenantId) {
    final tenant = _tenants[tenantId];
    return tenant?.isActive ?? false;
  }

  /// Get tenant-specific API base URL
  String? getTenantApiBaseUrl() {
    return _currentTenant?.apiBaseUrl;
  }

  /// Get tenant-specific database name
  String? getTenantDatabaseName() {
    return _currentTenant?.databaseName;
  }

  /// Switch tenant
  Future<Result<void>> switchTenant(String tenantId) async {
    try {
      final result = await setCurrentTenant(tenantId);
      if (result.isFailure) {
        return result;
      }

      // Notify listeners about tenant change
      _tenantChangeController.add(tenantId);

      TalkerConfig.logInfo('Switched to tenant: $tenantId');
      return const Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to switch tenant', e);
      return Error(Failure('Failed to switch tenant: $e'));
    }
  }

  // Tenant change stream
  final StreamController<String> _tenantChangeController =
      StreamController.broadcast();
  Stream<String> get tenantChangeStream => _tenantChangeController.stream;

  /// Dispose resources
  void dispose() {
    _tenantChangeController.close();
  }
}

/// Tenant model
class Tenant {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final String? apiBaseUrl;
  final String? databaseName;
  final Map<String, dynamic>? config;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? features;
  final Map<String, String>? branding;

  const Tenant({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    this.apiBaseUrl,
    this.databaseName,
    this.config,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.features,
    this.branding,
  });

  Tenant copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    String? apiBaseUrl,
    String? databaseName,
    Map<String, dynamic>? config,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? features,
    Map<String, String>? branding,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      databaseName: databaseName ?? this.databaseName,
      config: config ?? this.config,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      features: features ?? this.features,
      branding: branding ?? this.branding,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'apiBaseUrl': apiBaseUrl,
      'databaseName': databaseName,
      'config': config,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'features': features,
      'branding': branding,
    };
  }

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String?,
      apiBaseUrl: json['apiBaseUrl'] as String?,
      databaseName: json['databaseName'] as String?,
      config: json['config'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      features: (json['features'] as List<dynamic>?)?.cast<String>(),
      branding: (json['branding'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }
}

/// Tenant-specific configuration
class TenantConfig {
  final String tenantId;
  final Map<String, dynamic> settings;
  final Map<String, String> apiEndpoints;
  final Map<String, dynamic> features;
  final Map<String, String> branding;

  const TenantConfig({
    required this.tenantId,
    required this.settings,
    required this.apiEndpoints,
    required this.features,
    required this.branding,
  });

  String? getApiEndpoint(String key) {
    return apiEndpoints[key];
  }

  T? getSetting<T>(String key) {
    return settings[key] as T?;
  }

  bool isFeatureEnabled(String feature) {
    return features[feature] as bool? ?? false;
  }

  String? getBranding(String key) {
    return branding[key];
  }
}
