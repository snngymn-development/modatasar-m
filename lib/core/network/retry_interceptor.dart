import 'dart:math';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor({this.maxRetries = 3, this.baseDelayMs = 300});
  final int maxRetries;
  final int baseDelayMs;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final retries = (requestOptions.extra['retries'] as int?) ?? 0;

    final shouldRetry = _isRetriable(err) && retries < maxRetries;
    if (!shouldRetry) return handler.next(err);

    final delay = _backoffDelay(retries);
    await Future<void>.delayed(Duration(milliseconds: delay));

    requestOptions.extra['retries'] = retries + 1;

    try {
      // Create a new Dio instance with the same base options
      final dio = Dio(
        BaseOptions(
          baseUrl: requestOptions.baseUrl,
          connectTimeout: requestOptions.connectTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
          sendTimeout: requestOptions.sendTimeout,
          headers: requestOptions.headers,
        ),
      );

      // Retry the request
      final resp = await dio.fetch(requestOptions);
      return handler.resolve(resp);
    } catch (e) {
      return handler.next(err);
    }
  }

  bool _isRetriable(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return true;
    }

    final status = e.response?.statusCode ?? 0;
    return status == 429 || (status >= 500 && status < 600);
  }

  int _backoffDelay(int retries) {
    final rnd = Random().nextInt(100);
    return (baseDelayMs * pow(2, retries)).toInt() + rnd; // jitter
  }
}
