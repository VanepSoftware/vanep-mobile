import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/dtos/driver_attendance_dto.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/dtos/driver_occupancy_dto.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/dtos/van_assistant_dto.dart';

class VanCentralRemoteDataSource {
  const VanCentralRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  Future<DriverOccupancyDto> fetchOccupancy() async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.driverOccupancyEndpoint,
    );
    return DriverOccupancyDto.fromJson(
      Map<String, Object?>.from(response.data ?? const {}),
    );
  }

  Future<DriverAttendanceDto> fetchAttendance() async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.driversMeEndpoint,
    );
    return DriverAttendanceDto.fromJson(
      Map<String, Object?>.from(response.data ?? const {}),
    );
  }

  Future<DriverAttendanceDto> updateAvailability({
    required bool available,
  }) async {
    final response = await dio.put<Map<String, dynamic>>(
      environment.driverAvailabilityEndpoint,
      data: {'available': available},
    );
    return DriverAttendanceDto.fromJson(
      Map<String, Object?>.from(response.data ?? const {}),
    );
  }

  Future<List<VanAssistantDto>> fetchAssistants() async {
    final response = await dio.get<List<dynamic>>(
      environment.assistantsEndpoint,
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (json) => VanAssistantDto.fromJson(Map<String, Object?>.from(json)),
        )
        .toList();
  }
}
