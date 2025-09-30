import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../logging/talker_config.dart';
import '../security/rate_limiter.dart';
import '../security/audit_logger.dart';
import 'result.dart';
import 'api_config.dart';
import '../error/failure.dart';

/// Centralized API client for all network operations
///
/// Usage:
/// ```dart
/// final apiClient = ApiClient();
/// final result = await apiClient.get('/sales');
/// ```
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// Initialize API client
  Future<void> initialize() async {
    try {
      await _setupInterceptors();
      await _configureBaseOptions();

      TalkerConfig.logInfo('API client initialized');
    } catch (e, stackTrace) {
      TalkerConfig.logError('Failed to initialize API client', e, stackTrace);
      rethrow;
    }
  }

  /// Setup interceptors
  Future<void> _setupInterceptors() async {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication header
          final token = await _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add common headers
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          options.headers['X-Client-Version'] = await _getClientVersion();
          options.headers['X-Platform'] = defaultTargetPlatform.name;

          // Rate limiting check
          final canProceed = await RateLimiter.instance.checkLimit('api_call');
          if (!canProceed) {
            handler.reject(
              DioException(
                requestOptions: options,
                message: 'Rate limit exceeded',
                type: DioExceptionType.unknown,
              ),
            );
            return;
          }

          // Log request
          TalkerConfig.logNetwork('${options.method} ${options.path}');

          // Audit log
          await AuditLogger.instance.logDataAccess(
            '${options.method}:${options.path}',
            operation: options.method,
            metadata: {
              'url': options.uri.toString(),
              'headers': options.headers,
            },
          );

          handler.next(options);
        },
        onResponse: (response, handler) async {
          // Log response
          TalkerConfig.logNetwork(
            '${response.requestOptions.method} ${response.requestOptions.path} - ${response.statusCode}',
          );

          // Audit log
          await AuditLogger.instance.logDataAccess(
            '${response.requestOptions.method}:${response.requestOptions.path}',
            operation: 'RESPONSE',
            metadata: {
              'status_code': response.statusCode,
              'response_size': response.data?.toString().length ?? 0,
            },
          );

          handler.next(response);
        },
        onError: (error, handler) async {
          // Log error
          TalkerConfig.logError(
            'API Error: ${error.requestOptions.method} ${error.requestOptions.path}',
            error,
            error.stackTrace,
          );

          // Audit log
          await AuditLogger.instance.logSecurityEvent(
            'API_ERROR',
            metadata: {
              'method': error.requestOptions.method,
              'path': error.requestOptions.path,
              'status_code': error.response?.statusCode,
              'error_message': error.message,
            },
          );

          handler.next(error);
        },
      ),
    );

    // Retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: (message) => TalkerConfig.logInfo(message),
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );

    // Timeout interceptor
    _dio.interceptors.add(TimeoutInterceptor());
  }

  /// Configure base options
  Future<void> _configureBaseOptions() async {
    final config = ApiConfig.instance;

    _dio.options = BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: Duration(milliseconds: config.connectionTimeoutMs),
      receiveTimeout: Duration(milliseconds: config.receiveTimeoutMs),
      sendTimeout: Duration(milliseconds: config.sendTimeoutMs),
      validateStatus: (status) => status != null && status < 500,
    );
  }

  /// Get authentication token
  Future<String?> _getAuthToken() async {
    // This would integrate with your auth service
    // For now, return null
    return null;
  }

  /// Get client version
  Future<String> _getClientVersion() async {
    return '1.0.0'; // This would come from package_info_plus
  }

  /// GET request
  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Result.ok(response.data as T);
    } on DioException catch (e) {
      return Result.err(_handleDioError(e));
    } catch (e) {
      return Result.err(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  /// POST request
  Future<Result<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Result.ok(response.data as T);
    } on DioException catch (e) {
      return Result.err(_handleDioError(e));
    } catch (e) {
      return Result.err(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  /// PUT request
  Future<Result<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Result.ok(response.data as T);
    } on DioException catch (e) {
      return Result.err(_handleDioError(e));
    } catch (e) {
      return Result.err(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  /// DELETE request
  Future<Result<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Result.ok(response.data as T);
    } on DioException catch (e) {
      return Result.err(_handleDioError(e));
    } catch (e) {
      return Result.err(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  /// PATCH request
  Future<Result<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return Result.ok(response.data as T);
    } on DioException catch (e) {
      return Result.err(_handleDioError(e));
    } catch (e) {
      return Result.err(Failure('Unexpected error: ${e.toString()}'));
    }
  }

  /// Handle Dio errors
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Failure(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return Failure('Request timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Failure('Response timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return Failure('Bad request. Please check your input.');
          case 401:
            return Failure('Unauthorized. Please login again.');
          case 403:
            return Failure('Forbidden. You do not have permission.');
          case 404:
            return Failure('Resource not found.');
          case 422:
            return Failure('Validation error. Please check your input.');
          case 429:
            return Failure('Too many requests. Please try again later.');
          case 500:
            return Failure('Server error. Please try again later.');
          default:
            return Failure('HTTP error: $statusCode');
        }
      case DioExceptionType.cancel:
        return Failure('Request cancelled.');
      case DioExceptionType.connectionError:
        return Failure(
          'Connection error. Please check your internet connection.',
        );
      case DioExceptionType.badCertificate:
        return Failure('Certificate error. Please contact support.');
      case DioExceptionType.unknown:
        return Failure('Unknown error: ${error.message}');
    }
  }

  /// Upload file
  Future<Result<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return Result.ok(response.data as T);
    } on DioException catch (e) {
      return Result.err(_handleDioError(e));
    } catch (e) {
      return Result.err(Failure('Upload error: ${e.toString()}'));
    }
  }

  /// Download file
  Future<Result<String>> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return Result.ok(savePath);
    } on DioException catch (e) {
      return Result.err(_handleDioError(e));
    } catch (e) {
      return Result.err(Failure('Download error: ${e.toString()}'));
    }
  }

  /// Get Dio instance for advanced usage
  Dio get dio => _dio;

  /// Check if initialized
  bool get isInitialized => true;
}

/// Retry interceptor for handling network failures
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String message)? logPrint;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
    this.logPrint,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < retries) {
        logPrint?.call('Retrying request (${retryCount + 1}/$retries)');

        await Future.delayed(retryDelays[retryCount]);

        err.requestOptions.extra['retryCount'] = retryCount + 1;

        try {
          final response = await dio.fetch(err.requestOptions);
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

/// Timeout interceptor
class TimeoutInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Set default timeouts if not set
    options.connectTimeout ??= const Duration(seconds: 30);
    options.receiveTimeout ??= const Duration(seconds: 30);
    options.sendTimeout ??= const Duration(seconds: 30);

    handler.next(options);
  }
}
