import 'package:dio/dio.dart';

import '../../domain/failures/profile_edit_failure.dart';
import '../dtos/profile_error_dto.dart';

ProfileEditFailure mapProfileEditDioException(DioException error) {
  final status = error.response?.statusCode;
  if (status == 400 || status == 409) {
    final data = error.response?.data;
    if (data is Map) {
      final dto = ProfileErrorDto.fromJson(Map<String, Object?>.from(data));
      final code = ProfileErrorCode.fromApi(dto.code);
      if (code != null) {
        return StructuredProfileEditFailure(
          code: code,
          field: dto.field,
          retryAfter: dto.retryAfter,
          serverMessage: dto.message,
        );
      }
    }
  }
  return NetworkProfileEditFailure(error.message);
}
