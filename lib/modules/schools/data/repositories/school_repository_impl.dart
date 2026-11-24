import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';
import 'package:vanep_mobile/modules/schools/domain/failures/school_failure.dart';
import 'package:vanep_mobile/modules/schools/domain/repositories/school_repository.dart';
import 'package:vanep_mobile/modules/schools/data/datasources/school_remote_datasource.dart';

const _rejectedCodes = {
  ApiErrorCodes.schoolPlaceNotASchool,
  ApiErrorCodes.schoolNameBlank,
  ApiErrorCodes.schoolAlreadyActive,
  ApiErrorCodes.schoolNotFound,
  ApiErrorCodes.locationPlaceRateLimited,
  ApiErrorCodes.locationPlaceNotResolvable,
  ApiErrorCodes.locationPlaceNotFound,
  ApiErrorCodes.locationCountryUnsupported,
  ApiErrorCodes.locationStateUnsupported,
  ApiErrorCodes.requestRateLimited,
  ApiErrorCodes.validationFailed,
  ApiErrorCodes.requestBodyUnreadable,
  ApiErrorCodes.requestParameterInvalid,
};

SchoolFailure schoolFailureFrom(DioException exception) {
  final problem = ApiProblem.fromDioException(exception);
  if (problem.isNetworkFailure) return const SchoolNetworkFailure();
  final detail = problem.detailText;
  if (problem.matchesAnyCode(_rejectedCodes) && detail.isNotEmpty) {
    return SchoolRejectedFailure(detail: detail);
  }
  final status = problem.status!;
  if (status >= 400 && status < 500 && detail.isNotEmpty) {
    return SchoolRejectedFailure(detail: detail);
  }
  return const SchoolUnexpectedFailure();
}

class SchoolRepositoryImpl implements SchoolRepository {
  const SchoolRepositoryImpl({required this.remote});

  final SchoolRemoteDataSource remote;

  @override
  Future<Result<SchoolFailure, School>> resolveSchool({
    required String placeId,
    required String sessionToken,
  }) async {
    try {
      return Ok(
        await remote.resolveSchool(
          placeId: placeId,
          sessionToken: sessionToken,
        ),
      );
    } on DioException catch (exception) {
      return Err(schoolFailureFrom(exception));
    } on FormatException {
      return const Err(SchoolUnexpectedFailure());
    }
  }
}
