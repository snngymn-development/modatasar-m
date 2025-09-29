import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../network/result.dart';
import '../error/failure.dart';

/// Authentication service with Bearer token flow
///
/// Usage:
/// ```dart
/// final authService = ref.read(authServiceProvider);
/// await authService.login(email, password);
/// ```
class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;
  final Dio _dio;
  final Completer<void> _refreshCompleter = Completer<void>();

  AuthService({required FlutterSecureStorage storage, required Dio dio})
    : _storage = storage,
      _dio = dio;

  /// Login with email and password
  Future<Result<AuthTokens>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final tokens = AuthTokens.fromJson(response.data);
      await _storeTokens(tokens);

      return Result.ok(tokens);
    } on DioException catch (e) {
      return Result.err(_handleAuthError(e));
    } catch (e, stack) {
      return Result.err(
        Failure(
          'Login failed: ${e.toString()}',
          stack: stack,
          originalError: e,
        ),
      );
    }
  }

  /// Refresh access token using refresh token
  Future<Result<AuthTokens>> refreshToken() async {
    // Prevent multiple simultaneous refresh attempts
    if (_refreshCompleter.isCompleted) {
      return Result.err(Failure('Refresh already in progress'));
    }

    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        return Result.err(Failure('No refresh token available'));
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final tokens = AuthTokens.fromJson(response.data);
      await _storeTokens(tokens);

      _refreshCompleter.complete();
      return Result.ok(tokens);
    } on DioException catch (e) {
      _refreshCompleter.completeError(e);
      return Result.err(_handleAuthError(e));
    } catch (e, stack) {
      _refreshCompleter.completeError(e);
      return Result.err(
        Failure(
          'Token refresh failed: ${e.toString()}',
          stack: stack,
          originalError: e,
        ),
      );
    }
  }

  /// Logout and clear all stored data
  Future<void> logout() async {
    try {
      // Call logout endpoint if needed
      final accessToken = await _storage.read(key: _accessTokenKey);
      if (accessToken != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
      }
    } catch (e) {
      // Ignore logout API errors
    } finally {
      // Always clear local storage
      await _storage.deleteAll();
    }
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Store tokens securely
  Future<void> _storeTokens(AuthTokens tokens) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
    ]);
  }

  /// Handle authentication errors
  Failure _handleAuthError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return Failure('Invalid credentials', code: '401');
      case 403:
        return Failure('Access denied', code: '403');
      case 429:
        return Failure('Too many requests', code: '429');
      default:
        return Failure(
          e.message ?? 'Authentication failed',
          code: e.response?.statusCode.toString(),
          originalError: e,
        );
    }
  }
}

/// Authentication tokens model
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
