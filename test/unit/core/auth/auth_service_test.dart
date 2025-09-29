import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:deneme1/core/auth/auth_service.dart';
import 'package:deneme1/core/network/result.dart';

void main() {
  group('AuthService', () {
    late MockFlutterSecureStorage mockStorage;
    late MockDio mockDio;
    late AuthService authService;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      mockDio = MockDio();
      authService = AuthService(storage: mockStorage, dio: mockDio);
    });

    group('login', () {
      test('should return success when login is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(
          () => mockDio.post('/auth/login', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'access_token': 'access_token_123',
              'refresh_token': 'refresh_token_123',
              'expires_at': '2024-12-31T23:59:59Z',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
        );

        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await authService.login(email, password);

        // Assert
        expect(result, isA<Success<AuthTokens>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.accessToken, equals('access_token_123'));
        expect(result.dataOrNull?.refreshToken, equals('refresh_token_123'));
      });

      test('should return error when login fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';

        when(
          () => mockDio.post('/auth/login', data: any(named: 'data')),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            response: Response(
              statusCode: 401,
              requestOptions: RequestOptions(path: '/auth/login'),
            ),
          ),
        );

        // Act
        final result = await authService.login(email, password);

        // Assert
        expect(result, isA<Error<AuthTokens>>());
        expect(result.isFailure, isTrue);
        expect(result.messageOrEmpty, contains('Invalid credentials'));
      });
    });

    group('refreshToken', () {
      test('should return success when refresh is successful', () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'refresh_token'),
        ).thenAnswer((_) async => 'refresh_token_123');

        when(
          () => mockDio.post('/auth/refresh', data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'access_token': 'new_access_token_123',
              'refresh_token': 'new_refresh_token_123',
              'expires_at': '2024-12-31T23:59:59Z',
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/auth/refresh'),
          ),
        );

        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async {});

        // Act
        final result = await authService.refreshToken();

        // Assert
        expect(result, isA<Success<AuthTokens>>());
        expect(result.isSuccess, isTrue);
        expect(result.dataOrNull?.accessToken, equals('new_access_token_123'));
      });

      test('should return error when no refresh token available', () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'refresh_token'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await authService.refreshToken();

        // Assert
        expect(result, isA<Error<AuthTokens>>());
        expect(result.isFailure, isTrue);
        expect(result.messageOrEmpty, contains('No refresh token available'));
      });
    });

    group('logout', () {
      test('should clear all stored data', () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'access_token'),
        ).thenAnswer((_) async => 'access_token_123');

        when(
          () => mockDio.post('/auth/logout', options: any(named: 'options')),
        ).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(path: '/auth/logout'),
          ),
        );

        when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

        // Act
        await authService.logout();

        // Assert
        verify(() => mockStorage.deleteAll()).called(1);
      });
    });

    group('isAuthenticated', () {
      test('should return true when access token exists', () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'access_token'),
        ).thenAnswer((_) async => 'access_token_123');

        // Act
        final result = await authService.isAuthenticated();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when no access token', () async {
        // Arrange
        when(
          () => mockStorage.read(key: 'access_token'),
        ).thenAnswer((_) async => null);

        // Act
        final result = await authService.isAuthenticated();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockDio extends Mock implements Dio {}
