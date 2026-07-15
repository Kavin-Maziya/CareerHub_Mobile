
// Sealed result type for the repository boundary. No @freezed, no
// Every subclass must live in this same file, the compiler has
// a complete, closed picture of every possible ApiResult<T> shape,
// enabling exhaustiveness checking on any switch over this type.

sealed class ApiResult<T> {
  const ApiResult();
}

final class Success<T> extends ApiResult<T> {
  final T data;

  const Success(this.data);
}

final class Failure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});
}