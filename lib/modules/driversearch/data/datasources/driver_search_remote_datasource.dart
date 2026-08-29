import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../../domain/entities/driver_search_page.dart';
import '../../domain/entities/driver_search_result.dart';

List<String> readServiceAreaNames(Object? raw) {
  if (raw is! List) return const [];
  return raw.whereType<String>().where((name) => name.isNotEmpty).toList();
}

DriverSearchResult driverSearchResultFromJson(Map<String, Object?> json) {
  return DriverSearchResult(
    token: json['token'] as String? ?? '',
    name: json['name'] as String? ?? '',
    photoUrl: json['photo'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
    basePrice: (json['basePrice'] as num?)?.toDouble(),
    experienceYears: (json['experienceYears'] as num?)?.toInt(),
    available: json['available'] as bool? ?? false,
    serviceAreas: readServiceAreaNames(json['serviceAreas']),
  );
}

DriverSearchPage readSearchPage(Map<String, dynamic>? body) {
  final content = body?['content'];
  if (content is! List) {
    return const DriverSearchPage(drivers: [], isLast: true);
  }
  return DriverSearchPage(
    drivers: content
        .whereType<Map<String, dynamic>>()
        .map((entry) => driverSearchResultFromJson(Map<String, Object?>.from(entry)))
        .toList(),
    isLast: body?['last'] as bool? ?? true,
  );
}

class DriverSearchRemoteDataSource {
  DriverSearchRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  String get endpoint => '${environment.driversEndpoint}/search';

  Future<DriverSearchPage> searchByPlace(
    String placeId,
    String? sessionToken, {
    int page = 0,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: {
        'placeId': placeId,
        'page': page,
        if (sessionToken != null && sessionToken.isNotEmpty)
          'sessionToken': sessionToken,
      },
    );
    return readSearchPage(response.data);
  }
}
