import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/problem_detail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/datasources/driver_student_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/family_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/repositories/driver_student_repository.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';

class DriverStudentRepositoryImpl implements DriverStudentRepository {
  const DriverStudentRepositoryImpl({required this.remote});

  final DriverStudentRemoteDataSource remote;

  @override
  Future<Result<DriverStudentFailure, List<DriverStudent>>> listStudents({
    String? vehicleToken,
  }) {
    return guardDriverStudentCall(
      () => remote.listStudents(vehicleToken: vehicleToken),
    );
  }

  @override
  Future<Result<DriverStudentFailure, FamilyInvite>> inviteFamily(
    String studentToken,
  ) {
    return guardDriverStudentCall(() => remote.inviteFamily(studentToken));
  }

  @override
  Future<Result<DriverStudentFailure, FamilyInvite>> findParentsGroupInvite() {
    return guardDriverStudentCall(remote.findParentsGroupInvite);
  }

  @override
  Future<Result<DriverStudentFailure, void>> mergeFamily(String studentToken) {
    return guardDriverStudentCall(() => remote.mergeFamily(studentToken));
  }

  @override
  Future<Result<DriverStudentFailure, void>> dismissFamilyMatch(
    String studentToken,
  ) {
    return guardDriverStudentCall(
      () => remote.dismissFamilyMatch(studentToken),
    );
  }

  @override
  Future<Result<DriverStudentFailure, String>> createUnlinkedPassenger(
    UnlinkedPassengerDraft draft,
  ) {
    return guardDriverStudentCall(() => remote.createUnlinkedPassenger(draft));
  }
}

DriverStudentFailure driverStudentFailureFrom(DioException exception) {
  final response = exception.response;
  if (response == null) return const DriverStudentNetworkFailure();
  final detail = readProblemDetail(response.data);
  return switch (response.statusCode) {
    404 => const DriverStudentNotFoundFailure(),
    400 ||
    409 ||
    422 when detail.isNotEmpty => DriverStudentRejectedFailure(detail: detail),
    _ => const DriverStudentUnexpectedFailure(),
  };
}

Future<Result<DriverStudentFailure, T>> guardDriverStudentCall<T>(
  Future<T> Function() call,
) async {
  try {
    return Ok(await call());
  } on DioException catch (exception) {
    return Err(driverStudentFailureFrom(exception));
  } on FormatException {
    return const Err(DriverStudentUnexpectedFailure());
  }
}
