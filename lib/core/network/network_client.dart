import 'package:dio/dio.dart';
import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/error/failure.dart';

/// Network client for API calls
///
/// Usage:
/// ```dart
/// final client = NetworkClient(dio);
/// final result = await client.get('/api/endpoint');
/// ```
class NetworkClient {
  final Dio _dio;

  NetworkClient(this._dio);

  Future<Result<Response>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(response);
    } catch (e) {
      return Error(Failure('GET request failed: $e'));
    }
  }

  Future<Result<Response>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(response);
    } catch (e) {
      return Error(Failure('POST request failed: $e'));
    }
  }

  Future<Result<Response>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(response);
    } catch (e) {
      return Error(Failure('PUT request failed: $e'));
    }
  }

  Future<Result<Response>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(response);
    } catch (e) {
      return Error(Failure('PATCH request failed: $e'));
    }
  }

  Future<Result<Response>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Success(response);
    } catch (e) {
      return Error(Failure('DELETE request failed: $e'));
    }
  }
}
