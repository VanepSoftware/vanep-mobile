import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/profile_error_dto.dart';

ProfileEditFailure mapProfileEditDioException(DioException error) {
  final problem = ApiProblem.fromDioException(error);
  if (problem.isNetworkFailure) {
    return NetworkProfileEditFailure(error.message);
  }

  final data = error.response?.data;
  if (data is Map) {
    final dto = ProfileErrorDto.fromJson(Map<String, Object?>.from(data));
    final rootCode = ProfileErrorCode.fromApi(dto.code);
    if (rootCode != null) {
      return StructuredProfileEditFailure(
        code: rootCode,
        field: dto.field,
        retryAfter: dto.retryAfter,
      );
    }
    if (dto.code == ApiErrorCodes.validationFailed) {
      for (final fieldError in dto.errors) {
        final mappedCode = ProfileErrorCode.fromApi(fieldError.code);
        if (mappedCode != null) {
          return StructuredProfileEditFailure(
            code: mappedCode,
            field: fieldError.field ?? dto.field,
            retryAfter: dto.retryAfter,
          );
        }
      }
    }
  }

  return UnexpectedProfileEditFailure(problem.detail ?? error.message);
}
