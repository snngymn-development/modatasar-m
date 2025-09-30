import 'dart:async';
import 'package:dio/dio.dart';
import '../logging/talker_config.dart';
import '../network/result.dart';
import '../error/failure.dart';
import '../config/api_config.dart';

/// Backend Service for Real API Integration
///
/// Usage:
/// ```dart
/// final backendService = BackendService();
/// final result = await backendService.getSales();
/// final result = await backendService.createSale(saleData);
/// ```
class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  late Dio _dio;
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiry = const Duration(minutes: 5);

  /// Initialize backend service
  Future<void> initialize() async {
    try {
      _dio = Dio();

      // Configure base options
      _dio.options = BaseOptions(
        baseUrl: ApiConfig.instance.baseUrl,
        connectTimeout: ApiConfig.instance.connectionTimeout,
        receiveTimeout: ApiConfig.instance.receiveTimeout,
        sendTimeout: ApiConfig.instance.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      // Add interceptors
      _dio.interceptors.add(_createAuthInterceptor());
      _dio.interceptors.add(_createLoggingInterceptor());
      _dio.interceptors.add(_createCacheInterceptor());
      _dio.interceptors.add(_createRetryInterceptor());

      TalkerConfig.logInfo('Backend Service initialized');
    } catch (e) {
      TalkerConfig.logError('Failed to initialize Backend Service', e);
    }
  }

  /// Get sales data
  Future<Result<List<Map<String, dynamic>>>> getSales({
    Map<String, dynamic>? filters,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (filters != null) ...filters,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      };

      final response = await _dio.get(
        '/api/sales',
        queryParameters: queryParams,
      );

      final List<dynamic> salesData = response.data['data'] ?? [];
      final sales = salesData.cast<Map<String, dynamic>>();

      TalkerConfig.logInfo('Fetched ${sales.length} sales from backend');
      return Success(sales);
    } catch (e) {
      TalkerConfig.logError('Failed to fetch sales', e);
      return Error(_handleError(e));
    }
  }

  /// Create new sale
  Future<Result<Map<String, dynamic>>> createSale(
    Map<String, dynamic> saleData,
  ) async {
    try {
      final response = await _dio.post('/api/sales', data: saleData);

      final sale = response.data['data'] as Map<String, dynamic>;

      // Invalidate cache
      _invalidateCache('/api/sales');

      TalkerConfig.logInfo('Created sale: ${sale['id']}');
      return Success(sale);
    } catch (e) {
      TalkerConfig.logError('Failed to create sale', e);
      return Error(_handleError(e));
    }
  }

  /// Update sale
  Future<Result<Map<String, dynamic>>> updateSale(
    String saleId,
    Map<String, dynamic> saleData,
  ) async {
    try {
      final response = await _dio.put('/api/sales/$saleId', data: saleData);

      final sale = response.data['data'] as Map<String, dynamic>;

      // Invalidate cache
      _invalidateCache('/api/sales');

      TalkerConfig.logInfo('Updated sale: $saleId');
      return Success(sale);
    } catch (e) {
      TalkerConfig.logError('Failed to update sale', e);
      return Error(_handleError(e));
    }
  }

  /// Delete sale
  Future<Result<void>> deleteSale(String saleId) async {
    try {
      await _dio.delete('/api/sales/$saleId');

      // Invalidate cache
      _invalidateCache('/api/sales');

      TalkerConfig.logInfo('Deleted sale: $saleId');
      return Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to delete sale', e);
      return Error(_handleError(e));
    }
  }

  /// Get inventory items
  Future<Result<List<Map<String, dynamic>>>> getInventoryItems({
    Map<String, dynamic>? filters,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (filters != null) ...filters,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      };

      final response = await _dio.get(
        '/api/inventory',
        queryParameters: queryParams,
      );

      final List<dynamic> itemsData = response.data['data'] ?? [];
      final items = itemsData.cast<Map<String, dynamic>>();

      TalkerConfig.logInfo(
        'Fetched ${items.length} inventory items from backend',
      );
      return Success(items);
    } catch (e) {
      TalkerConfig.logError('Failed to fetch inventory items', e);
      return Error(_handleError(e));
    }
  }

  /// Update inventory item
  Future<Result<Map<String, dynamic>>> updateInventoryItem(
    String itemId,
    Map<String, dynamic> itemData,
  ) async {
    try {
      final response = await _dio.put('/api/inventory/$itemId', data: itemData);

      final item = response.data['data'] as Map<String, dynamic>;

      // Invalidate cache
      _invalidateCache('/api/inventory');

      TalkerConfig.logInfo('Updated inventory item: $itemId');
      return Success(item);
    } catch (e) {
      TalkerConfig.logError('Failed to update inventory item', e);
      return Error(_handleError(e));
    }
  }

  /// Get customers
  Future<Result<List<Map<String, dynamic>>>> getCustomers({
    Map<String, dynamic>? filters,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (filters != null) ...filters,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      };

      final response = await _dio.get(
        '/api/customers',
        queryParameters: queryParams,
      );

      final List<dynamic> customersData = response.data['data'] ?? [];
      final customers = customersData.cast<Map<String, dynamic>>();

      TalkerConfig.logInfo(
        'Fetched ${customers.length} customers from backend',
      );
      return Success(customers);
    } catch (e) {
      TalkerConfig.logError('Failed to fetch customers', e);
      return Error(_handleError(e));
    }
  }

  /// Create customer
  Future<Result<Map<String, dynamic>>> createCustomer(
    Map<String, dynamic> customerData,
  ) async {
    try {
      final response = await _dio.post('/api/customers', data: customerData);

      final customer = response.data['data'] as Map<String, dynamic>;

      // Invalidate cache
      _invalidateCache('/api/customers');

      TalkerConfig.logInfo('Created customer: ${customer['id']}');
      return Success(customer);
    } catch (e) {
      TalkerConfig.logError('Failed to create customer', e);
      return Error(_handleError(e));
    }
  }

  /// Update customer
  Future<Result<Map<String, dynamic>>> updateCustomer(
    String customerId,
    Map<String, dynamic> customerData,
  ) async {
    try {
      final response = await _dio.put(
        '/api/customers/$customerId',
        data: customerData,
      );

      final customer = response.data['data'] as Map<String, dynamic>;

      // Invalidate cache
      _invalidateCache('/api/customers');

      TalkerConfig.logInfo('Updated customer: $customerId');
      return Success(customer);
    } catch (e) {
      TalkerConfig.logError('Failed to update customer', e);
      return Error(_handleError(e));
    }
  }

  /// Delete customer
  Future<Result<void>> deleteCustomer(String customerId) async {
    try {
      await _dio.delete('/api/customers/$customerId');

      // Invalidate cache
      _invalidateCache('/api/customers');

      TalkerConfig.logInfo('Deleted customer: $customerId');
      return Success(null);
    } catch (e) {
      TalkerConfig.logError('Failed to delete customer', e);
      return Error(_handleError(e));
    }
  }

  /// Get reports data
  Future<Result<Map<String, dynamic>>> getReports({
    String? reportType,
    Map<String, dynamic>? filters,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (reportType != null) 'type': reportType,
        if (filters != null) ...filters,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _dio.get(
        '/api/reports',
        queryParameters: queryParams,
      );

      final reportData = response.data['data'] as Map<String, dynamic>;

      TalkerConfig.logInfo('Fetched report: $reportType');
      return Success(reportData);
    } catch (e) {
      TalkerConfig.logError('Failed to fetch reports', e);
      return Error(_handleError(e));
    }
  }

  /// Sync offline data
  Future<Result<Map<String, dynamic>>> syncOfflineData(
    List<Map<String, dynamic>> offlineData,
  ) async {
    try {
      final response = await _dio.post(
        '/api/sync',
        data: {
          'offline_data': offlineData,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final syncResult = response.data['data'] as Map<String, dynamic>;

      TalkerConfig.logInfo('Synced ${offlineData.length} offline records');
      return Success(syncResult);
    } catch (e) {
      TalkerConfig.logError('Failed to sync offline data', e);
      return Error(_handleError(e));
    }
  }

  /// Health check
  Future<Result<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _dio.get('/api/health');
      final healthData = response.data as Map<String, dynamic>;

      TalkerConfig.logInfo('Backend health check successful');
      return Success(healthData);
    } catch (e) {
      TalkerConfig.logError('Backend health check failed', e);
      return Error(_handleError(e));
    }
  }

  // Private methods
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add authentication token
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshed = await _refreshAuthToken();
          if (refreshed) {
            // Retry the request
            final newToken = await _getAuthToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          }
        }
        handler.next(error);
      },
    );
  }

  Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        TalkerConfig.logInfo(
          '🌐 API Request: ${options.method} ${options.path}',
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        TalkerConfig.logInfo(
          '🌐 API Response: ${response.statusCode} ${response.requestOptions.path}',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        TalkerConfig.logError('🌐 API Error: ${error.message}', error);
        handler.next(error);
      },
    );
  }

  Interceptor _createCacheInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.method == 'GET') {
          final cacheKey =
              '${options.method}_${options.path}_${options.queryParameters}';
          if (_cache.containsKey(cacheKey)) {
            final timestamp = _cacheTimestamps[cacheKey];
            if (timestamp != null &&
                DateTime.now().difference(timestamp) < _cacheExpiry) {
              // Return cached response
              final cachedData = _cache[cacheKey];
              final response = Response(
                requestOptions: options,
                data: cachedData,
                statusCode: 200,
              );
              handler.resolve(response);
              return;
            }
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.requestOptions.method == 'GET') {
          final cacheKey =
              '${response.requestOptions.method}_${response.requestOptions.path}_${response.requestOptions.queryParameters}';
          _cache[cacheKey] = response.data;
          _cacheTimestamps[cacheKey] = DateTime.now();
        }
        handler.next(response);
      },
    );
  }

  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          final retryCount = error.requestOptions.extra['retryCount'] ?? 0;
          if (retryCount < 3) {
            await Future.delayed(Duration(seconds: retryCount + 1));
            error.requestOptions.extra['retryCount'] = retryCount + 1;

            try {
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // Continue to next retry or fail
            }
          }
        }
        handler.next(error);
      },
    );
  }

  Future<String?> _getAuthToken() async {
    // Get token from secure storage
    // Note: In a real implementation, this would get token from secure storage
    // For now, we'll return a mock token
    return 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<bool> _refreshAuthToken() async {
    // Implement token refresh logic
    // Note: In a real implementation, this would refresh the auth token
    // For now, we'll simulate successful refresh
    TalkerConfig.logInfo('Refreshing auth token');
    return true;
  }

  void _invalidateCache(String path) {
    _cache.removeWhere((key, value) => key.contains(path));
    _cacheTimestamps.removeWhere((key, value) => key.contains(path));
  }

  Failure _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return Failure(
            'Connection timeout. Please check your internet connection.',
          );
        case DioExceptionType.receiveTimeout:
          return Failure('Server response timeout. Please try again.');
        case DioExceptionType.sendTimeout:
          return Failure('Request timeout. Please try again.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'Server error';
          return Failure('Server error ($statusCode): $message');
        case DioExceptionType.cancel:
          return Failure('Request cancelled');
        case DioExceptionType.connectionError:
          return Failure(
            'Connection error. Please check your internet connection.',
          );
        case DioExceptionType.badCertificate:
          return Failure('SSL certificate error');
        case DioExceptionType.unknown:
          return Failure('Unknown error: ${error.message}');
      }
    }
    return Failure('Unexpected error: $error');
  }
}
