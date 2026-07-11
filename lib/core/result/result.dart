/// Explicit result type for error handling — errors are values, not control flow
/// (constitution R04). A [Result] is either [Ok] (success with [T]) or
/// [Err] (failure with [E]).
sealed class Result<E, T> {
  const Result();

  /// True when this is an [Ok].
  bool get isOk => this is Ok<E, T>;

  /// True when this is an [Err].
  bool get isErr => this is Err<E, T>;

  /// Returns the success value or `null` when this is an [Err].
  T? get valueOrNull => switch (this) {
        Ok<E, T>(:final value) => value,
        Err<E, T>() => null,
      };

  /// Returns the error or `null` when this is an [Ok].
  E? get errorOrNull => switch (this) {
        Ok<E, T>() => null,
        Err<E, T>(:final error) => error,
      };

  /// Folds both branches into a single value of type [R].
  R fold<R>(R Function(E error) onErr, R Function(T value) onOk) =>
      switch (this) {
        Ok<E, T>(:final value) => onOk(value),
        Err<E, T>(:final error) => onErr(error),
      };
}

/// Successful [Result] carrying a [value].
final class Ok<E, T> extends Result<E, T> {
  const Ok(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      other is Ok<E, T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Failed [Result] carrying an [error].
final class Err<E, T> extends Result<E, T> {
  const Err(this.error);

  final E error;

  @override
  bool operator ==(Object other) =>
      other is Err<E, T> && other.error == error;

  @override
  int get hashCode => error.hashCode;
}
