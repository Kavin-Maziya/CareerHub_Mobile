import 'package:careerhub_mobile/data/api_result.dart';
import 'package:careerhub_mobile/data/auth_repository.dart';
import 'package:careerhub_mobile/models/auth_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {

    @override
  Future<AuthState> build() async {
    final repository = ref.read(authRepositoryProvider);

    final token = await repository.readAccessToken();

    if (token == null) {
      return const Unauthenticated();
    }

    if (repository.isTokenExpired(token)) {
      final user = await repository.tryRefresh();

      if (user != null) {
        return Authenticated(user: user);
      }

      return const Unauthenticated();
    }

    return Authenticated(
      user: repository.decodeUser(token),
    );
  }

  Future<void> login(
  String email,
  String password,
) async {
  state = const AsyncData(
    Authenticating(),
  );

  final repository = ref.read(
    authRepositoryProvider,
  );

  final result = await repository.login(
    email,
    password,
  );

  switch (result) {
    case Success<User>(:final data):
      state = AsyncData(
        Authenticated(user: data),
      );

    case Failure<User>(:final message):
      state = AsyncData(
        AuthError(message),
      );
  }
}

 Future<void> logout() async {
  final repository = ref.read(
    authRepositoryProvider,
  );

  await repository.logout();

  state = const AsyncData(
    Unauthenticated(),
  );
}

}
