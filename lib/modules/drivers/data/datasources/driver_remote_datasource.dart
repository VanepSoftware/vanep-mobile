import 'package:dio/dio.dart';

import '../../../../core/environment/environment.dart';
import '../dtos/driver_dto.dart';

class DriverRemoteDataSource {
  DriverRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  Future<List<DriverDto>> fetchRecentDrivers({required int limit}) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.driversEndpoint,
      queryParameters: {'size': limit, 'sort': 'createdAt,desc'},
    );
    final content = response.data?['content'] as List<dynamic>? ?? const [];
    return content
        .map((item) => DriverDto.fromJson(item as Map<String, Object?>))
        .toList();
  }
}
