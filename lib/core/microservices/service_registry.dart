import 'dart:async';
import 'package:dio/dio.dart';
import '../logging/talker_config.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Service Registry for Microservices Architecture
///
/// Usage:
/// ```dart
/// final registry = ServiceRegistry();
/// await registry.registerService('user-service', 'https://user.api.com');
/// final userService = registry.getService('user-service');
/// ```
class ServiceRegistry {
  static final ServiceRegistry _instance = ServiceRegistry._internal();
  factory ServiceRegistry() => _instance;
  ServiceRegistry._internal();

  final Map<String, Microservice> _services = {};
  final Map<String, Dio> _clients = {};

  /// Register a microservice
  Future<void> registerService(
    String name,
    String baseUrl, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final dio = Dio();
      dio.options.baseUrl = baseUrl;
      dio.options.connectTimeout = timeout ?? const Duration(seconds: 30);
      dio.options.receiveTimeout = timeout ?? const Duration(seconds: 30);

      if (headers != null) {
        dio.options.headers.addAll(headers);
      }

      _clients[name] = dio;
      _services[name] = Microservice(
        name: name,
        baseUrl: baseUrl,
        client: dio,
        isHealthy: true,
        lastHealthCheck: DateTime.now(),
      );

      TalkerConfig.logInfo('Microservice registered: $name at $baseUrl');
    } catch (e) {
      TalkerConfig.logError('Failed to register service: $name', e);
    }
  }

  /// Get a microservice client
  Dio? getService(String name) {
    return _clients[name];
  }

  /// Get service information
  Microservice? getServiceInfo(String name) {
    return _services[name];
  }

  /// Health check for all services
  Future<Map<String, bool>> healthCheckAll() async {
    final results = <String, bool>{};

    for (final service in _services.values) {
      try {
        final response = await service.client.get('/health');
        final isHealthy = response.statusCode == 200;
        results[service.name] = isHealthy;

        _services[service.name] = service.copyWith(
          isHealthy: isHealthy,
          lastHealthCheck: DateTime.now(),
        );
      } catch (e) {
        results[service.name] = false;
        _services[service.name] = service.copyWith(
          isHealthy: false,
          lastHealthCheck: DateTime.now(),
        );
        TalkerConfig.logError('Health check failed for ${service.name}', e);
      }
    }

    return results;
  }

  /// Get all registered services
  List<Microservice> getAllServices() {
    return _services.values.toList();
  }

  /// Remove a service
  void removeService(String name) {
    _clients[name]?.close();
    _clients.remove(name);
    _services.remove(name);
    TalkerConfig.logInfo('Service removed: $name');
  }

  /// Clear all services
  void clearAll() {
    for (final client in _clients.values) {
      client.close();
    }
    _clients.clear();
    _services.clear();
    TalkerConfig.logInfo('All services cleared');
  }
}

/// Microservice model
class Microservice {
  final String name;
  final String baseUrl;
  final Dio client;
  final bool isHealthy;
  final DateTime lastHealthCheck;

  const Microservice({
    required this.name,
    required this.baseUrl,
    required this.client,
    required this.isHealthy,
    required this.lastHealthCheck,
  });

  Microservice copyWith({
    String? name,
    String? baseUrl,
    Dio? client,
    bool? isHealthy,
    DateTime? lastHealthCheck,
  }) {
    return Microservice(
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      client: client ?? this.client,
      isHealthy: isHealthy ?? this.isHealthy,
      lastHealthCheck: lastHealthCheck ?? this.lastHealthCheck,
    );
  }
}

/// Microservice API Client
class MicroserviceClient {
  final String serviceName;
  final Dio _client;

  MicroserviceClient(this.serviceName, this._client);

  /// Generic GET request
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client.get(
        path,
        queryParameters: queryParameters,
      );

      if (fromJson != null) {
        return Success(fromJson(response.data));
      }

      return Success(response.data as T);
    } on DioException catch (e) {
      return Error(Failure(e.message ?? 'Network error', originalError: e));
    } catch (e) {
      return Error(Failure('Request failed: $e'));
    }
  }

  /// Generic POST request
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      if (fromJson != null) {
        return Success(fromJson(response.data));
      }

      return Success(response.data as T);
    } on DioException catch (e) {
      return Error(Failure(e.message ?? 'Network error', originalError: e));
    } catch (e) {
      return Error(Failure('Request failed: $e'));
    }
  }

  /// Generic PUT request
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      if (fromJson != null) {
        return Success(fromJson(response.data));
      }

      return Success(response.data as T);
    } on DioException catch (e) {
      return Error(Failure(e.message ?? 'Network error', originalError: e));
    } catch (e) {
      return Error(Failure('Request failed: $e'));
    }
  }

  /// Generic DELETE request
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _client.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      if (fromJson != null) {
        return Success(fromJson(response.data));
      }

      return Success(response.data as T);
    } on DioException catch (e) {
      return Error(Failure(e.message ?? 'Network error', originalError: e));
    } catch (e) {
      return Error(Failure('Request failed: $e'));
    }
  }
}
