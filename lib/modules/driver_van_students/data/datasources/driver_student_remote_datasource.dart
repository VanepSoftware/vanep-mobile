import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/data/json_readers.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/dtos/driver_student_dto.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/dtos/unlinked_passenger_request_body.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';

class DriverStudentRemoteDataSource {
  const DriverStudentRemoteDataSource({
    required this.dio,
    required this.environment,
  });

  final Dio dio;
  final Environment environment;

  Future<List<DriverStudentDto>> listStudents({String? vehicleToken}) async {
    final response = await dio.get<List<dynamic>>(
      environment.driverStudentsEndpoint,
      queryParameters: {'vehicleToken': ?vehicleToken},
    );
    return [
      for (final json in (response.data ?? const []).whereType<Map>())
        DriverStudentDto.fromJson(Map<String, Object?>.from(json)),
    ];
  }

  Future<FamilyInviteDto> inviteFamily(String studentToken) async {
    final response = await dio.post<Map<String, dynamic>>(
      environment.unlinkedPassengerInviteEndpoint(studentToken),
    );
    return FamilyInviteDto.fromJson(readBody(response.data));
  }

  Future<FamilyInviteDto> findParentsGroupInvite() async {
    final response = await dio.get<Map<String, dynamic>>(
      environment.driverInviteLinkEndpoint,
    );
    return FamilyInviteDto.fromJson(readBody(response.data));
  }

  Future<void> mergeFamily(String studentToken) async {
    await dio.post<Map<String, dynamic>>(
      environment.unlinkedPassengerMergeEndpoint(studentToken),
    );
  }

  Future<void> dismissFamilyMatch(String studentToken) async {
    await dio.post<Map<String, dynamic>>(
      environment.unlinkedPassengerDismissMatchEndpoint(studentToken),
    );
  }

  Future<String> createUnlinkedPassenger(UnlinkedPassengerDraft draft) async {
    final response = await dio.post<Map<String, dynamic>>(
      environment.driverUnlinkedPassengersEndpoint,
      data: unlinkedPassengerDraftToJson(draft),
    );
    return readToken(readBody(response.data)['token']);
  }
}

Map<String, Object?> readBody(Map<String, dynamic>? data) {
  if (data == null) throw const FormatException('Empty response body.');
  return Map<String, Object?>.from(data);
}
