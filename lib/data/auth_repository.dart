import 'dart:convert';

import 'package:careerhub_mobile/data/api_result.dart';
import 'package:careerhub_mobile/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';


const _accessTokenKey = 'access_token';
const _refreshTokenKey = 'refresh_token';

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:5059',
      ),
    ),
  );

  return AuthRepository(
    dio: dio,
    storage: const FlutterSecureStorage(),
  );
}

class AuthRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  const AuthRepository({
    required this.dio,
    required this.storage,
  });

 Future<String?> readAccessToken() async {
  return storage.read(key: _accessTokenKey);
}

bool isTokenExpired(String token) {
  try {
    final payload = _decodeJwtPayload(token);

    final exp = payload['exp'];

    if (exp == null) {
      return false;
    }

    final expiry = DateTime.fromMillisecondsSinceEpoch(
      (exp as int) * 1000,
    );

    return expiry.isBefore(DateTime.now());
  } catch (_) {
    return true;
  }
}

User decodeUser(String token) {
  final payload = _decodeJwtPayload(token);

  final email = payload['email'] as String? ?? '';

  return User(
    id: payload['sub'] as String? ?? '',
    email: email,
    displayName: payload['name'] as String? ?? email,
  );
}

Future<ApiResult<User>> login(
  String email,
  String password,
) async {
  try {
    final response = await dio.post(
      '/api/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;

    final accessToken = data['accessToken'] as String;
    final refreshToken = data['refreshToken'] as String;

    await storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );

    await storage.write(
      key: _refreshTokenKey,
      value: refreshToken,
    );

    return Success(
      decodeUser(accessToken),
    );
  } on DioException catch (e) {
    if (e.response?.statusCode == 400 ||
        e.response?.statusCode == 401) {
      return const Failure(
        'Invalid email or password.',
      );
    }

    return Failure(
      e.message ?? 'A network error occurred.',
      statusCode: e.response?.statusCode,
    );
  } catch (_) {
    return const Failure(
      'Something went wrong. Please try again.',
    );
  }
}

Future<User?> tryRefresh() async {
  final refreshToken = await storage.read(
    key: _refreshTokenKey,
  );

  if (refreshToken == null) {
    return null;
  }

  try {
    final response = await dio.post(
      '/api/auth/refresh',
      data: {
        'refreshToken': refreshToken,
      },
    );

    final data = response.data as Map<String, dynamic>;

    final accessToken = data['accessToken'] as String;

    await storage.write(
      key: _accessTokenKey,
      value: accessToken,
    );

    final newRefreshToken = data['refreshToken'] as String?;

    if (newRefreshToken != null) {
      await storage.write(
        key: _refreshTokenKey,
        value: newRefreshToken,
      );
    }

    return decodeUser(accessToken);
  } catch (_) {
    await storage.deleteAll();
    return null;
  }
}

Future<void> logout() async {
  await storage.deleteAll();
}

static Map<String, dynamic> _decodeJwtPayload(String token) {
  final segments = token.split('.');

  if (segments.length != 3) {
    throw const FormatException('Invalid JWT');
  }

  final payload = segments[1];

  final normalized = payload.padRight(
    payload.length + ((4 - payload.length % 4) % 4),
    '=',
  );

  final decoded = utf8.decode(
    base64Url.decode(normalized),
  );

  return Map<String, dynamic>.from(
    jsonDecode(decoded),
  );
}

}