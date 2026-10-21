import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/data/dtos/school_dto.dart';

class SchoolRemoteDataSource {
  SchoolRemoteDataSource({required this.dio, required this.environment});

  final Dio dio;
  final Environment environment;

  Future<School> resolveSchool({
    required String placeId,
    required String sessionToken,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      environment.schoolResolveEndpoint,
      data: {'placeId': placeId, 'sessionToken': sessionToken},
    );
    final payload = response.data;
    if (payload == null) {
      throw const FormatException('Empty school payload.');
    }
    return schoolFromJson(Map<String, Object?>.from(payload));
  }
}
