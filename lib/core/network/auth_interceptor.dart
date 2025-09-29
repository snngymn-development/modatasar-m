import 'dart:async';
import 'package:dio/dio.dart';
import '../auth/token_store.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._store, this._dio);
  final TokenStore _store;
  final Dio _dio;

  String? _access;
  String? _refresh;
  bool _isRefreshing = false;
  final _queue = <Completer<Response>>[];

  Future<void> _loadTokens() async {
    _access ??= (await _store.read()).$1;
    _refresh ??= (await _store.read()).$2;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await _loadTokens();
    if ((_access ?? '').isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_access';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && (_refresh ?? '').isNotEmpty) {
      final c = Completer<Response>();
      _queue.add(c);
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          // TODO: refresh endpoint/body'yi API'na göre güncelle
          final res = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': _refresh},
          );
          final na = res.data['accessToken'] as String?;
          final nr = res.data['refreshToken'] as String? ?? _refresh;
          if (na != null) {
            _access = na;
            _refresh = nr;
            await _store.save(access: na, refresh: nr!);
            for (final q in _queue) {
              try {
                final ro = err.requestOptions;
                ro.headers['Authorization'] = 'Bearer $_access';
                q.complete(await _dio.fetch(ro));
              } catch (e) {
                q.completeError(e);
              }
            }
          } else {
            for (final q in _queue) {
              q.completeError(err);
            }
          }
        } catch (e) {
          for (final q in _queue) {
            q.completeError(e);
          }
        } finally {
          _queue.clear();
          _isRefreshing = false;
        }
      }
      try {
        handler.resolve(await c.future);
      } catch (_) {
        handler.next(err);
      }
      return;
    }
    handler.next(err);
  }
}
