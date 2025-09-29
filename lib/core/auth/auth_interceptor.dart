import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deneme1/core/network/result.dart';
import 'package:deneme1/core/error/failure.dart';
import 'auth_service.dart';

/// Dio interceptor for handling authentication
///
/// Usage:
/// ```dart
/// dio.interceptors.add(AuthInterceptor(authServiceProvider));
/// ```
class AuthInterceptor extends Interceptor {
  final Ref _ref;
  bool _isRefreshing = false;

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _addAuthHeader(options);
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Handle token refresh
      final result = await _handleTokenRefresh();
      if (result is Success<AuthTokens>) {
        // Retry the original request
        final retryResult = await _retryRequest(err.requestOptions);
        if (retryResult is Success<Response>) {
          handler.resolve(retryResult.data);
          return;
        }
      }
    }
    handler.next(err);
  }

  /// Add authorization header to request
  void _addAuthHeader(RequestOptions options) {
    final authService = _ref.read(authServiceProvider);
    authService.getAccessToken().then((token) {
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    });
  }

  /// Handle token refresh with mutex
  Future<Result<AuthTokens>> _handleTokenRefresh() async {
    if (_isRefreshing) {
      // Wait for ongoing refresh
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return Success(
        AuthTokens(
          accessToken: '',
          refreshToken: '',
          expiresAt: DateTime.now(),
        ),
      );
    }

    _isRefreshing = true;
    try {
      final authService = _ref.read(authServiceProvider);
      final result = await authService.refreshToken();
      return result;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Retry the original request with new token
  Future<Result<Response>> _retryRequest(RequestOptions options) async {
    try {
      final dio = Dio();
      _addAuthHeader(options);
      final response = await dio.fetch(options);
      return Success(response);
    } catch (e) {
      return Error(
        Failure('Request retry failed: ${e.toString()}', originalError: e),
      );
    }
  }
}

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError('AuthService provider not implemented');
});
