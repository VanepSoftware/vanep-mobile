String? trimmedOrNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

bool isLongerThan(String value, int maxLength) {
  return (trimmedOrNull(value)?.length ?? 0) > maxLength;
}
