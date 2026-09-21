import '../../domain/entities/ibge_locations_page.dart';

int readPagingInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return 0;
}

IbgeLocationsPage<T> ibgeLocationsPageFromJson<T>(
  Map<String, Object?> json,
  T Function(Map<String, Object?> json) readItem,
) {
  final raw = json['content'];
  final items = raw is List
      ? raw
            .whereType<Map>()
            .map((item) => readItem(Map<String, Object?>.from(item)))
            .toList()
      : <T>[];
  return IbgeLocationsPage<T>(
    items: items,
    totalElements: readPagingInt(json['totalElements']),
    totalPages: readPagingInt(json['totalPages']),
    number: readPagingInt(json['number']),
    size: readPagingInt(json['size']),
  );
}
