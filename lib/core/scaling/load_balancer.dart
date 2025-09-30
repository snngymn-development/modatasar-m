import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../logging/talker_config.dart';
import '../config/environment_config.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Load Balancer for Horizontal Scaling
///
/// Usage:
/// ```dart
/// final loadBalancer = LoadBalancer();
/// await loadBalancer.initialize();
/// final result = await loadBalancer.executeRequest('/api/sales');
/// ```
class LoadBalancer {
  static final LoadBalancer _instance = LoadBalancer._internal();
  factory LoadBalancer() => _instance;
  static LoadBalancer get instance => _instance;
  LoadBalancer._internal();

  late List<ServerNode> _servers;
  late LoadBalancingStrategy _strategy;
  late HealthChecker _healthChecker;

  bool _isInitialized = false;
  int _currentServerIndex = 0;
  final Map<String, int> _serverRequestCounts = {};
  final Map<String, double> _serverResponseTimes = {};
  final Map<String, DateTime> _serverLastRequestTimes = {};

  /// Initialize load balancer
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final config = EnvironmentConfig.instance;

      // Initialize servers based on environment
      _servers = _initializeServers(config);

      // Set load balancing strategy
      _strategy = _getLoadBalancingStrategy(config);

      // Initialize health checker
      _healthChecker = HealthChecker(_servers);
      await _healthChecker.initialize();

      _isInitialized = true;
      TalkerConfig.logInfo(
        'Load balancer initialized with ${_servers.length} servers',
      );
    } catch (e) {
      TalkerConfig.logError('Failed to initialize load balancer', e);
    }
  }

  /// Execute request through load balancer
  Future<Result<T>> executeRequest<T>(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    if (!_isInitialized) {
      return Error(Failure('Load balancer not initialized'));
    }

    try {
      final server = _selectServer();
      if (server == null) {
        return Error(Failure('No healthy servers available'));
      }

      final startTime = DateTime.now();
      final result = await _executeRequestOnServer<T>(
        server,
        endpoint,
        method: method,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        timeout: timeout,
      );

      final duration = DateTime.now().difference(startTime);
      _updateServerMetrics(server, duration);

      return result;
    } catch (e) {
      TalkerConfig.logError('Load balancer request failed', e);
      return Error(Failure('Load balancer request failed: $e'));
    }
  }

  /// Get load balancer status
  Map<String, dynamic> getStatus() {
    final healthyServers = _servers.where((s) => s.isHealthy).length;
    final totalServers = _servers.length;

    return {
      'is_initialized': _isInitialized,
      'strategy': _strategy.name,
      'total_servers': totalServers,
      'healthy_servers': healthyServers,
      'unhealthy_servers': totalServers - healthyServers,
      'servers': _servers
          .map(
            (s) => {
              'id': s.id,
              'url': s.url,
              'is_healthy': s.isHealthy,
              'request_count': _serverRequestCounts[s.id] ?? 0,
              'avg_response_time': _serverResponseTimes[s.id] ?? 0.0,
              'last_request': _serverLastRequestTimes[s.id]?.toIso8601String(),
              'weight': s.weight,
              'priority': s.priority,
            },
          )
          .toList(),
    };
  }

  /// Add server to load balancer
  Future<void> addServer(ServerNode server) async {
    try {
      _servers.add(server);
      await _healthChecker.addServer(server);
      TalkerConfig.logInfo('Added server to load balancer: ${server.id}');
    } catch (e) {
      TalkerConfig.logError('Failed to add server: ${server.id}', e);
    }
  }

  /// Remove server from load balancer
  Future<void> removeServer(String serverId) async {
    try {
      _servers.removeWhere((s) => s.id == serverId);
      await _healthChecker.removeServer(serverId);
      _serverRequestCounts.remove(serverId);
      _serverResponseTimes.remove(serverId);
      _serverLastRequestTimes.remove(serverId);
      TalkerConfig.logInfo('Removed server from load balancer: $serverId');
    } catch (e) {
      TalkerConfig.logError('Failed to remove server: $serverId', e);
    }
  }

  /// Update server weight
  void updateServerWeight(String serverId, int weight) {
    final server = _servers.firstWhere(
      (s) => s.id == serverId,
      orElse: () => throw Exception('Server not found: $serverId'),
    );
    server.weight = weight;
    TalkerConfig.logInfo('Updated server weight: $serverId = $weight');
  }

  /// Dispose resources
  void dispose() {
    _healthChecker.dispose();
    _isInitialized = false;
  }

  // Private methods
  List<ServerNode> _initializeServers(EnvironmentConfig config) {
    final servers = <ServerNode>[];

    // Add primary server
    servers.add(
      ServerNode(
        id: 'primary',
        url: config.apiUrl,
        weight: 100,
        priority: 1,
        isHealthy: true,
      ),
    );

    // Add secondary servers based on environment
    if (config.isProduction) {
      servers.addAll([
        ServerNode(
          id: 'secondary-1',
          url: config.apiUrl.replaceFirst('api.', 'api-1.'),
          weight: 80,
          priority: 2,
          isHealthy: true,
        ),
        ServerNode(
          id: 'secondary-2',
          url: config.apiUrl.replaceFirst('api.', 'api-2.'),
          weight: 80,
          priority: 2,
          isHealthy: true,
        ),
        ServerNode(
          id: 'secondary-3',
          url: config.apiUrl.replaceFirst('api.', 'api-3.'),
          weight: 60,
          priority: 3,
          isHealthy: true,
        ),
      ]);
    } else if (config.isStaging) {
      servers.add(
        ServerNode(
          id: 'secondary-1',
          url: config.apiUrl.replaceFirst('staging-api.', 'staging-api-1.'),
          weight: 80,
          priority: 2,
          isHealthy: true,
        ),
      );
    }

    return servers;
  }

  LoadBalancingStrategy _getLoadBalancingStrategy(EnvironmentConfig config) {
    if (config.isProduction) {
      return LoadBalancingStrategy.weightedRoundRobin;
    } else if (config.isStaging) {
      return LoadBalancingStrategy.leastConnections;
    } else {
      return LoadBalancingStrategy.roundRobin;
    }
  }

  ServerNode? _selectServer() {
    final healthyServers = _servers.where((s) => s.isHealthy).toList();
    if (healthyServers.isEmpty) return null;

    switch (_strategy) {
      case LoadBalancingStrategy.roundRobin:
        return _selectRoundRobin(healthyServers);
      case LoadBalancingStrategy.weightedRoundRobin:
        return _selectWeightedRoundRobin(healthyServers);
      case LoadBalancingStrategy.leastConnections:
        return _selectLeastConnections(healthyServers);
      case LoadBalancingStrategy.leastResponseTime:
        return _selectLeastResponseTime(healthyServers);
      case LoadBalancingStrategy.random:
        return _selectRandom(healthyServers);
    }
  }

  ServerNode _selectRoundRobin(List<ServerNode> servers) {
    final server = servers[_currentServerIndex % servers.length];
    _currentServerIndex = (_currentServerIndex + 1) % servers.length;
    return server;
  }

  ServerNode _selectWeightedRoundRobin(List<ServerNode> servers) {
    final totalWeight = servers.fold(0, (sum, s) => sum + s.weight);
    var random = Random().nextInt(totalWeight);

    for (final server in servers) {
      random -= server.weight;
      if (random <= 0) {
        return server;
      }
    }

    return servers.first;
  }

  ServerNode _selectLeastConnections(List<ServerNode> servers) {
    return servers.reduce((a, b) {
      final aCount = _serverRequestCounts[a.id] ?? 0;
      final bCount = _serverRequestCounts[b.id] ?? 0;
      return aCount < bCount ? a : b;
    });
  }

  ServerNode _selectLeastResponseTime(List<ServerNode> servers) {
    return servers.reduce((a, b) {
      final aTime = _serverResponseTimes[a.id] ?? double.infinity;
      final bTime = _serverResponseTimes[b.id] ?? double.infinity;
      return aTime < bTime ? a : b;
    });
  }

  ServerNode _selectRandom(List<ServerNode> servers) {
    return servers[Random().nextInt(servers.length)];
  }

  Future<Result<T>> _executeRequestOnServer<T>(
    ServerNode server,
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final dio = Dio();
      dio.options.baseUrl = server.url;
      dio.options.connectTimeout = timeout ?? const Duration(seconds: 30);
      dio.options.receiveTimeout = timeout ?? const Duration(seconds: 30);

      Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get(endpoint, queryParameters: queryParameters);
          break;
        case 'POST':
          response = await dio.post(
            endpoint,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case 'PUT':
          response = await dio.put(
            endpoint,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case 'DELETE':
          response = await dio.delete(
            endpoint,
            queryParameters: queryParameters,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return Success(response.data as T);
    } catch (e) {
      TalkerConfig.logError('Request failed on server ${server.id}', e);
      return Error(Failure('Request failed: $e'));
    }
  }

  void _updateServerMetrics(ServerNode server, Duration duration) {
    _serverRequestCounts[server.id] =
        (_serverRequestCounts[server.id] ?? 0) + 1;
    _serverLastRequestTimes[server.id] = DateTime.now();

    final currentAvg = _serverResponseTimes[server.id] ?? 0.0;
    final requestCount = _serverRequestCounts[server.id] ?? 1;
    final newAvg =
        (currentAvg * (requestCount - 1) + duration.inMilliseconds) /
        requestCount;
    _serverResponseTimes[server.id] = newAvg;
  }
}

/// Server Node class
class ServerNode {
  final String id;
  final String url;
  int weight;
  int priority;
  bool isHealthy;
  DateTime? lastHealthCheck;
  String? lastError;

  ServerNode({
    required this.id,
    required this.url,
    required this.weight,
    required this.priority,
    required this.isHealthy,
    this.lastHealthCheck,
    this.lastError,
  });
}

/// Load Balancing Strategy enum
enum LoadBalancingStrategy {
  roundRobin,
  weightedRoundRobin,
  leastConnections,
  leastResponseTime,
  random,
}

/// Health Checker class
class HealthChecker {
  final List<ServerNode> _servers;
  Timer? _healthCheckTimer;
  final Duration _checkInterval = const Duration(seconds: 30);

  HealthChecker(this._servers);

  Future<void> initialize() async {
    await _performHealthCheck();
    _startPeriodicHealthCheck();
  }

  Future<void> addServer(ServerNode server) async {
    await _checkServerHealth(server);
  }

  Future<void> removeServer(String serverId) async {
    // Server will be removed from the list by the caller
  }

  void _startPeriodicHealthCheck() {
    _healthCheckTimer = Timer.periodic(_checkInterval, (timer) {
      _performHealthCheck();
    });
  }

  Future<void> _performHealthCheck() async {
    for (final server in _servers) {
      await _checkServerHealth(server);
    }
  }

  Future<void> _checkServerHealth(ServerNode server) async {
    try {
      final dio = Dio();
      dio.options.baseUrl = server.url;
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      final response = await dio.get('/health');

      server.isHealthy = response.statusCode == 200;
      server.lastHealthCheck = DateTime.now();
      server.lastError = null;

      TalkerConfig.logInfo(
        'Health check ${server.isHealthy ? 'passed' : 'failed'} for server: ${server.id}',
      );
    } catch (e) {
      server.isHealthy = false;
      server.lastHealthCheck = DateTime.now();
      server.lastError = e.toString();

      TalkerConfig.logError('Health check failed for server: ${server.id}', e);
    }
  }

  void dispose() {
    _healthCheckTimer?.cancel();
  }
}
