import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_dto.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_profile_dto.dart';

class DriverRemoteDataSource {
  DriverRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  Future<List<DriverDto>> fetchRecentDrivers({required int limit}) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.driversRecommendedEndpoint,
      queryParameters: {'size': limit},
    );
    final content = response.data?['content'] as List<dynamic>? ?? const [];
    return content
        .map((item) => DriverDto.fromJson(item as Map<String, Object?>))
        .toList();
  }

  Future<DriverProfileDto> fetchProfile(String driverToken) async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.driverProfileEndpoint(driverToken),
    );
    return DriverProfileDto.fromJson(response.data ?? const {});
  }
}
