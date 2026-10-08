import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area_draft.dart';
import 'package:vanep_mobile/modules/driver_service_areas/data/dtos/service_area_dto.dart';

class DriverServiceAreaRemoteDataSource {
  DriverServiceAreaRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  String get endpoint => '${environment.driversMeEndpoint}/service-areas';

  Future<List<ServiceArea>> fetchMyAreas() async {
    final response = await dio.get<List<dynamic>>(endpoint);
    return readServiceAreas(response.data);
  }

  Future<List<ServiceArea>> replaceMyAreas(List<ServiceAreaDraft> drafts) async {
    final response = await dio.put<List<dynamic>>(
      endpoint,
      data: {
        'areas': drafts.map(serviceAreaDraftToJson).toList(),
      },
    );
    return readServiceAreas(response.data);
  }
}

List<ServiceArea> readServiceAreas(List<dynamic>? payload) {
  if (payload == null) return const [];
  return payload
      .whereType<Map<String, dynamic>>()
      .map((entry) => serviceAreaFromJson(Map<String, Object?>.from(entry)))
      .toList();
}
