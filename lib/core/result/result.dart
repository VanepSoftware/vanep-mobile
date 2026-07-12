sealed class Result<E, T> {
  const Result();

  bool get isOk => this is Ok<E, T>;

  bool get isErr => this is Err<E, T>;

  T? get valueOrNull => switch (this) {
    Ok<E, T>(:final value) => value,
    Err<E, T>() => null,
  };

  E? get errorOrNull => switch (this) {
    Ok<E, T>() => null,
    Err<E, T>(:final error) => error,
  };

  R fold<R>(R Function(E error) onErr, R Function(T value) onOk) =>
      switch (this) {
        Ok<E, T>(:final value) => onOk(value),
        Err<E, T>(:final error) => onErr(error),
      };
}

final class Ok<E, T> extends Result<E, T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) => other is Ok<E, T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class Err<E, T> extends Result<E, T> {
  const Err(this.error);

  final E error;

  @override
  bool operator ==(Object other) => other is Err<E, T> && other.error == error;

  @override
  int get hashCode => error.hashCode;
}
