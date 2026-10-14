int readPagingInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}
