T? findByApiName<T>(
  List<T> values,
  String Function(T value) apiNameOf,
  Object? raw,
) {
  if (raw is! String) return null;
  final normalized = raw.trim().toUpperCase();
  for (final value in values) {
    if (apiNameOf(value) == normalized) return value;
  }
  return null;
}
