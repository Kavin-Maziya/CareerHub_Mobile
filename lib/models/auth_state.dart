import 'user.dart';

sealed class AuthState {
  const AuthState();
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class Authenticating extends AuthState {
  const Authenticating();
}

final class Authenticated extends AuthState {
  final User user;

  const Authenticated({
    required this.user,
  });
}

final class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}