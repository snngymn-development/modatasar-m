import '../error/failure.dart' as core;

sealed class Result<T> {
  const Result();

  // Factory constructors for easy creation
  static Result<T> ok<T>(T data) => Success(data);
  static Result<T> err<T>(core.Failure failure) => Error(failure);
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final core.Failure failure;
  const Error(this.failure);
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T get data => switch (this) {
    Success<T>(data: final data) => data,
    Error<T>() => throw StateError('Cannot access data on Error result'),
  };

  core.Failure get error => switch (this) {
    Success<T>() => throw StateError('Cannot access error on Success result'),
    Error<T>(failure: final failure) => failure,
  };

  T? get dataOrNull => switch (this) {
    Success<T>(data: final data) => data,
    Error<T>() => null,
  };

  String get messageOrEmpty => switch (this) {
    Success<T>() => '',
    Error<T>(failure: final failure) => failure.message,
  };

  T getOrElse(T defaultValue) => switch (this) {
    Success<T>(data: final data) => data,
    Error<T>() => defaultValue,
  };

  Result<R> map<R>(R Function(T) mapper) => switch (this) {
    Success<T>(data: final data) => Success(mapper(data)),
    Error<T>(failure: final failure) => Error(failure),
  };

  Result<R> flatMap<R>(Result<R> Function(T) mapper) => switch (this) {
    Success<T>(data: final data) => mapper(data),
    Error<T>(failure: final failure) => Error(failure),
  };

  // Pattern matching with when method
  R when<R>({
    required R Function(T data) success,
    required R Function(core.Failure failure) error,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Error<T>(failure: final failure) => error(failure),
    };
  }
}
