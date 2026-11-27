import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';

ProfileEditFailure mapProfileEditDioException(DioException error) {
  final problem = ApiProblem.fromDioException(error);
  if (problem.isNetworkFailure) {
    return NetworkProfileEditFailure(error.message);
  }

  final retryAfter = problem.readDateTimeExtra('retryAfter');
  final rootCode = ProfileErrorCode.fromApi(problem.code);
  if (rootCode != null) {
    return StructuredProfileEditFailure(
      code: rootCode,
      field: problem.field,
      retryAfter: retryAfter,
    );
  }
  if (problem.code == ApiErrorCodes.validationFailed) {
    for (final fieldError in problem.errors) {
      final mappedCode = ProfileErrorCode.fromApi(fieldError.code);
      if (mappedCode != null) {
        return StructuredProfileEditFailure(
          code: mappedCode,
          field: fieldError.field ?? problem.field,
          retryAfter: retryAfter,
        );
      }
    }
  }

  return UnexpectedProfileEditFailure(problem.detail ?? error.message);
}
