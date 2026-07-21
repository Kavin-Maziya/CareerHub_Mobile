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
  return null;
}

bool isTokenExpired(String token) {
  return false;
}

User decodeUser(String token) {
  throw UnimplementedError();
}

Future<ApiResult<User>> login(
  String email,
  String password,
) async {
  throw UnimplementedError();
}

Future<User?> tryRefresh() async {
  return null;
}

Future<void> logout() async {}

static Map<String, dynamic> _decodeJwtPayload(String token) {
  throw UnimplementedError();
}

}