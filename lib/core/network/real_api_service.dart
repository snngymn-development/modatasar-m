import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../logging/talker_config.dart';
import '../error/failure.dart';
import 'result.dart';
import 'graphql_client.dart';
import 'grpc_client.dart';
import '../realtime/websocket_service.dart';

/// Real API service integrating multiple protocols
///
/// Usage:
/// ```dart
/// final apiService = RealApiService();
/// final result = await apiService.getSales();
/// ```
class RealApiService {
  static final RealApiService _instance = RealApiService._internal();
  factory RealApiService() => _instance;
  RealApiService._internal();

  late GraphQLClient _graphqlClient;
  late GrpcClient _grpcClient;
  late WebSocketService _wsService;
  late Dio _dio;

  bool _isInitialized = false;

  /// Initialize real API service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize all clients
      _graphqlClient = GraphQLClient();
      await _graphqlClient.initialize();

      _grpcClient = GrpcClient();
      await _grpcClient.initialize();

      _wsService = WebSocketService.instance;
      await _wsService.connect();

      // Initialize REST client
      _dio = Dio(
        BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: 'https://api.example.com',
          ),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // Add interceptors
      _dio.interceptors.add(
        LogInterceptor(requestBody: kDebugMode, responseBody: kDebugMode),
      );

      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Add authentication
            final token = await _getAuthToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
          onError: (error, handler) async {
            TalkerConfig.logError('REST API error', error);
            handler.next(error);
          },
        ),
      );

      _isInitialized = true;
      TalkerConfig.logInfo('Real API service initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError(
        'Failed to initialize real API service',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Get sales data using GraphQL
  Future<Result<List<Map<String, dynamic>>>> getSales({
    int? limit,
    int? offset,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final result = await _graphqlClient.query(
        GraphQLQueries.getSales,
        variables: {'limit': limit ?? 50, 'offset': offset ?? 0},
      );

      if (result.isSuccess) {
        final data = result.data['data']?['sales'] as List<dynamic>? ?? [];
        final sales = data.cast<Map<String, dynamic>>();
        return Success(sales);
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get sales', e, stackTrace);
      return Error(Failure('Failed to get sales: $e'));
    }
  }

  /// Get sales data using REST API
  Future<Result<List<Map<String, dynamic>>>> getSalesRest({
    int? limit,
    int? offset,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.get(
        '/sales',
        queryParameters: {'limit': limit ?? 50, 'offset': offset ?? 0},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        final sales = data.cast<Map<String, dynamic>>();
        return Success(sales);
      } else {
        return Error(
          Failure('HTTP ${response.statusCode}: ${response.statusMessage}'),
        );
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get sales via REST', e, stackTrace);
      return Error(Failure('Failed to get sales via REST: $e'));
    }
  }

  /// Get sales data using gRPC
  Future<Result<List<Map<String, dynamic>>>> getSalesGrpc({
    int? limit,
    int? offset,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final result = await _grpcClient.call<List<Map<String, dynamic>>>(
        GrpcServices.salesService,
        GrpcMethods.getSales,
        {'limit': limit ?? 50, 'offset': offset ?? 0},
      );

      if (result.isSuccess) {
        return Success(result.data);
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get sales via gRPC', e, stackTrace);
      return Error(Failure('Failed to get sales via gRPC: $e'));
    }
  }

  /// Create sale using GraphQL
  Future<Result<Map<String, dynamic>>> createSale(
    Map<String, dynamic> saleData,
  ) async {
    try {
      if (!_isInitialized) await initialize();

      final result = await _graphqlClient.mutate(
        GraphQLMutations.createSale,
        variables: {'input': saleData},
      );

      if (result.isSuccess) {
        final data =
            result.data['data']?['createSale'] as Map<String, dynamic>? ?? {};
        return Success(data);
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to create sale', e, stackTrace);
      return Error(Failure('Failed to create sale: $e'));
    }
  }

  /// Create sale using REST API
  Future<Result<Map<String, dynamic>>> createSaleRest(
    Map<String, dynamic> saleData,
  ) async {
    try {
      if (!_isInitialized) await initialize();

      final response = await _dio.post('/sales', data: saleData);

      if (response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        return Success(data);
      } else {
        return Error(
          Failure('HTTP ${response.statusCode}: ${response.statusMessage}'),
        );
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to create sale via REST', e, stackTrace);
      return Error(Failure('Failed to create sale via REST: $e'));
    }
  }

  /// Subscribe to real-time sales updates
  Stream<Result<Map<String, dynamic>>> subscribeToSales() {
    try {
      if (!_isInitialized) {
        throw Exception('Real API service not initialized');
      }

      return _graphqlClient.subscribe(GraphQLQueries.salesSubscription).map((
        result,
      ) {
        if (result.isSuccess) {
          final data =
              result.data['data']?['salesUpdated'] as Map<String, dynamic>? ??
              {};
          return Success(data);
        } else {
          return Error(result.error);
        }
      });
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to subscribe to sales', e, stackTrace);
      return Stream.value(Error(Failure('Failed to subscribe to sales: $e')));
    }
  }

  /// Get customers data
  Future<Result<List<Map<String, dynamic>>>> getCustomers({
    int? limit,
    int? offset,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final result = await _graphqlClient.query(
        GraphQLQueries.getCustomers,
        variables: {'limit': limit ?? 50, 'offset': offset ?? 0},
      );

      if (result.isSuccess) {
        final data = result.data['data']?['customers'] as List<dynamic>? ?? [];
        final customers = data.cast<Map<String, dynamic>>();
        return Success(customers);
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get customers', e, stackTrace);
      return Error(Failure('Failed to get customers: $e'));
    }
  }

  /// Get inventory data
  Future<Result<List<Map<String, dynamic>>>> getInventory({
    int? limit,
    int? offset,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final result = await _graphqlClient.query(
        GraphQLQueries.getInventory,
        variables: {'limit': limit ?? 50, 'offset': offset ?? 0},
      );

      if (result.isSuccess) {
        final data = result.data['data']?['inventory'] as List<dynamic>? ?? [];
        final inventory = data.cast<Map<String, dynamic>>();
        return Success(inventory);
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to get inventory', e, stackTrace);
      return Error(Failure('Failed to get inventory: $e'));
    }
  }

  /// Process payment using gRPC
  Future<Result<Map<String, dynamic>>> processPayment(
    Map<String, dynamic> paymentData,
  ) async {
    try {
      if (!_isInitialized) await initialize();

      final result = await _grpcClient.call<Map<String, dynamic>>(
        GrpcServices.paymentService,
        GrpcMethods.processPayment,
        paymentData,
      );

      if (result.isSuccess) {
        return Success(result.data);
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to process payment', e, stackTrace);
      return Error(Failure('Failed to process payment: $e'));
    }
  }

  /// Generate report using gRPC
  Future<Result<Map<String, dynamic>>> generateReport(
    Map<String, dynamic> reportData,
  ) async {
    try {
      if (!_isInitialized) await initialize();

      final result = await _grpcClient.call<Map<String, dynamic>>(
        GrpcServices.reportService,
        GrpcMethods.generateReport,
        reportData,
      );

      if (result.isSuccess) {
        return Success(result.data);
      } else {
        return Error(result.error);
      }
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to generate report', e, stackTrace);
      return Error(Failure('Failed to generate report: $e'));
    }
  }

  /// Get connection status
  Map<String, bool> getConnectionStatus() {
    return {
      'graphql': _isInitialized,
      'grpc': _isInitialized,
      'websocket': _wsService.isConnected,
      'rest': _isInitialized,
    };
  }

  /// Close all connections
  Future<void> close() async {
    try {
      await _grpcClient.close();
      await _wsService.disconnect();
      _isInitialized = false;
      TalkerConfig.logInfo('Real API service closed');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to close real API service', e, stackTrace);
    }
  }

  Future<String?> _getAuthToken() async {
    // TODO: Get from secure storage
    return 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
  }
}
