import 'dart:async';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/api_config.dart';
import '../logging/talker_config.dart';
import 'result.dart';
import '../error/failure.dart';

/// Enhanced network client with retry logic, connectivity handling, and performance monitoring
///
/// Usage:
/// ```dart
/// final client = EnhancedNetworkClient();
/// final result = await client.get('/sales');
/// ```
class EnhancedNetworkClient {
  late final Dio _dio;
  final Connectivity _connectivity = Connectivity();
  final ApiConfig _config = ApiConfig.instance;

  EnhancedNetworkClient() {
    _dio = _createDio();
    _setupInterceptors();
  }

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _config.fullBaseUrl,
        connectTimeout: _config.connectionTimeout,
        receiveTimeout: _config.receiveTimeout,
        sendTimeout: _config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'ModaApp/1.0.0',
        },
      ),
    );

    return dio;
  }

  void _setupInterceptors() {
    // Retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: (message) => TalkerConfig.logNetwork(message),
        retries: _config.maxRetries,
        retryDelays: List.generate(
          _config.maxRetries,
          (index) =>
              Duration(seconds: (index + 1) * _config.retryDelay.inSeconds),
        ),
      ),
    );

    // Connectivity interceptor
    _dio.interceptors.add(ConnectivityInterceptor(_connectivity));

    // Performance monitoring interceptor
    if (_config.enablePerformanceMonitoring) {
      _dio.interceptors.add(PerformanceInterceptor());
    }

    // Logging interceptor
    if (_config.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) => TalkerConfig.logNetwork(object.toString()),
        ),
      );
    }
  }

  /// GET request with enhanced error handling
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      stopwatch.stop();

      TalkerConfig.logPerformance('GET $path', stopwatch.elapsed);
      return Success(response.data as T);
    } on DioException catch (e) {
      return _handleDioException(e, 'GET', path);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Unexpected error in GET $path', e, stackTrace);
      return Error(Failure('Unexpected error: $e', stack: stackTrace));
    }
  }

  /// POST request with enhanced error handling
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      stopwatch.stop();

      TalkerConfig.logPerformance('POST $path', stopwatch.elapsed);
      return Success(response.data as T);
    } on DioException catch (e) {
      return _handleDioException(e, 'POST', path);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Unexpected error in POST $path', e, stackTrace);
      return Error(Failure('Unexpected error: $e', stack: stackTrace));
    }
  }

  /// PUT request with enhanced error handling
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      stopwatch.stop();

      TalkerConfig.logPerformance('PUT $path', stopwatch.elapsed);
      return Success(response.data as T);
    } on DioException catch (e) {
      return _handleDioException(e, 'PUT', path);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Unexpected error in PUT $path', e, stackTrace);
      return Error(Failure('Unexpected error: $e', stack: stackTrace));
    }
  }

  /// DELETE request with enhanced error handling
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      stopwatch.stop();

      TalkerConfig.logPerformance('DELETE $path', stopwatch.elapsed);
      return Success(response.data as T);
    } on DioException catch (e) {
      return _handleDioException(e, 'DELETE', path);
    } catch (e, stackTrace) {
      TalkerConfig.logError('Unexpected error in DELETE $path', e, stackTrace);
      return Error(Failure('Unexpected error: $e', stack: stackTrace));
    }
  }

  Result<T> _handleDioException<T>(DioException e, String method, String path) {
    final failure = switch (e.type) {
      DioExceptionType.connectionTimeout => Failure(
        'Connection timeout for $method $path',
        code: 'CONNECTION_TIMEOUT',
        originalError: e,
      ),
      DioExceptionType.sendTimeout => Failure(
        'Send timeout for $method $path',
        code: 'SEND_TIMEOUT',
        originalError: e,
      ),
      DioExceptionType.receiveTimeout => Failure(
        'Receive timeout for $method $path',
        code: 'RECEIVE_TIMEOUT',
        originalError: e,
      ),
      DioExceptionType.badResponse => Failure(
        'Bad response for $method $path: ${e.response?.statusCode}',
        code: 'BAD_RESPONSE',
        originalError: e,
      ),
      DioExceptionType.cancel => Failure(
        'Request cancelled for $method $path',
        code: 'CANCELLED',
        originalError: e,
      ),
      DioExceptionType.connectionError => Failure(
        'Connection error for $method $path: ${e.message}',
        code: 'CONNECTION_ERROR',
        originalError: e,
      ),
      DioExceptionType.badCertificate => Failure(
        'Bad certificate for $method $path',
        code: 'BAD_CERTIFICATE',
        originalError: e,
      ),
      DioExceptionType.unknown => Failure(
        'Unknown error for $method $path: ${e.message}',
        code: 'UNKNOWN',
        originalError: e,
      ),
    };

    TalkerConfig.logError('Network error in $method $path', e, e.stackTrace);
    return Error(failure);
  }

  /// Get raw Dio instance for advanced usage
  Dio get dio => _dio;

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}

/// Retry interceptor for handling failed requests
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String message)? logPrint;

  RetryInterceptor({
    required this.dio,
    required this.retries,
    required this.retryDelays,
    this.logPrint,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < retries) {
        logPrint?.call(
          'Retrying request (${retryCount + 1}/$retries): ${err.requestOptions.path}',
        );

        await Future.delayed(retryDelays[retryCount]);

        final newOptions = err.requestOptions.copyWith(
          extra: {...err.requestOptions.extra, 'retryCount': retryCount + 1},
        );

        try {
          final response = await dio.fetch(newOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to next retry or fail
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// Connectivity interceptor for handling network availability
class ConnectivityInterceptor extends Interceptor {
  final Connectivity connectivity;

  ConnectivityInterceptor(this.connectivity);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connectivityResult = await connectivity.checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
      );
      return;
    }

    handler.next(options);
  }
}

/// Performance monitoring interceptor
class PerformanceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      TalkerConfig.logPerformance(
        '${response.requestOptions.method} ${response.requestOptions.path}',
        Duration(milliseconds: duration),
      );
    }
    handler.next(response);
  }
}
