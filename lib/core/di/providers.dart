import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/token_store.dart';
import '../network/auth_interceptor.dart';
import '../network/api_client.dart';

final secureStorageProvider = Provider((_) => const FlutterSecureStorage());

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => TokenStore(ref.read(secureStorageProvider)),
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE',
        defaultValue: 'https://api.example.com',
      ),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  dio.interceptors.add(AuthInterceptor(ref.read(tokenStoreProvider), dio));
  dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.read(dioProvider);
  return ApiClient(dio);
});
