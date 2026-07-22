import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _accessTokenKey = 'access_token';
const String _refreshTokenKey = 'refresh_token';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Dio retryDio;
  final void Function() onUnauthenticated;

  bool _isRefreshing = false;
  final List<Completer<String>> _queue = [];

  AuthInterceptor({
    required this.storage,
    required this.retryDio,
    required this.onUnauthenticated,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storage.read(key: _accessTokenKey);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Case 1 - Not a 401
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Case 2 - 401 while refreshing
    if (err.requestOptions.path.contains('/api/auth/refresh')) {
      _drainQueue(err);

      await storage.deleteAll();

      onUnauthenticated();

      handler.next(err);
      return;
    }

    // Case 3 - Refresh already running
    if (_isRefreshing) {
      final completer = Completer<String>();
      _queue.add(completer);

      try {
        final token = await completer.future;

        err.requestOptions.headers['Authorization'] = 'Bearer $token';

        final response = await retryDio.fetch(err.requestOptions);

        handler.resolve(response);
      } catch (_) {
        handler.next(err);
      }

      return;
    }

    // Case 4 - Start refresh
    _isRefreshing = true;

    try {
      final refreshToken = await storage.read(key: _refreshTokenKey);

      if (refreshToken == null) {
        _drainQueue(err);

        await storage.deleteAll();

        onUnauthenticated();

        handler.next(err);
        return;
      }

      final response = await retryDio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final accessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String?;

      await storage.write(key: _accessTokenKey, value: accessToken);

      if (newRefreshToken != null) {
        await storage.write(key: _refreshTokenKey, value: newRefreshToken);
      }

      for (final completer in _queue) {
        completer.complete(accessToken);
      }
      _queue.clear();

      err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';

      final retryResponse = await retryDio.fetch(err.requestOptions);

      handler.resolve(retryResponse);
    } catch (e) {
      _drainQueue(err);

      await storage.deleteAll();

      onUnauthenticated();

      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _drainQueue(DioException err) {
    for (final completer in _queue) {
      completer.completeError(err);
    }

    _queue.clear();
  }
}
