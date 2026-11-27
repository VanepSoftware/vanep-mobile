import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/datasources/driver_student_remote_datasource.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/driver_student.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/entities/family_invite.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/failures/driver_student_failure.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/repositories/driver_student_repository.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';

const _notFoundCodes = {
  ApiErrorCodes.unlinkedPassengerNotFound,
  ApiErrorCodes.unlinkedPassengerSchoolNotFound,
  ApiErrorCodes.driverStudentVehicleNotFound,
  ApiErrorCodes.familyInviteNotFound,
  ApiErrorCodes.familyInviteDependentNotFound,
  ApiErrorCodes.schoolNotFound,
  ApiErrorCodes.vehicleNotFound,
  ApiErrorCodes.userDriverProfileNotFound,
  ApiErrorCodes.requestRouteNotFound,
};

const _rejectedCodes = {
  ApiErrorCodes.unlinkedPassengerVehicleNotOwned,
  ApiErrorCodes.unlinkedPassengerFieldNull,
  ApiErrorCodes.unlinkedPassengerNameRequired,
  ApiErrorCodes.familyInviteAlreadyLinked,
  ApiErrorCodes.familyInviteLinkBlocked,
  ApiErrorCodes.familyInviteConcurrentRequest,
  ApiErrorCodes.familyMatchNotPending,
  ApiErrorCodes.familyMatchAlreadyPending,
  ApiErrorCodes.familyMatchDependentAlreadyLinked,
  ApiErrorCodes.validationFailed,
  ApiErrorCodes.requestBodyUnreadable,
  ApiErrorCodes.requestParameterInvalid,
};

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
  final problem = ApiProblem.fromDioException(exception);
  if (problem.isNetworkFailure) return const DriverStudentNetworkFailure();
  if (problem.matchesAnyCode(_notFoundCodes)) {
    return const DriverStudentNotFoundFailure();
  }
  final detail = problem.detailText;
  if (problem.matchesAnyCode(_rejectedCodes) && detail.isNotEmpty) {
    return DriverStudentRejectedFailure(detail: detail);
  }
  return switch (problem.status) {
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
