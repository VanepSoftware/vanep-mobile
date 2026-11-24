import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';

class FileUploader {
  const FileUploader({required this.dio});

  final Dio dio;

  Future<void> upload(
    String endpoint, {
    required String path,
    required String fileName,
    ProgressCallback? onSendProgress,
  }) async {
    await dio.post<void>(
      endpoint,
      data: await multipartForm(path: path, fileName: fileName),
      onSendProgress: onSendProgress,
    );
  }

  Future<Map<String, Object?>> createWithFile(
    String endpoint, {
    required String path,
    required String fileName,
    Map<String, String> fields = const {},
    ProgressCallback? onSendProgress,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      endpoint,
      data: await multipartForm(path: path, fileName: fileName, fields: fields),
      onSendProgress: onSendProgress,
    );
    return response.data ?? const {};
  }

  Future<FormData> multipartForm({
    required String path,
    required String fileName,
    Map<String, String> fields = const {},
  }) async {
    return FormData.fromMap({
      ...fields,
      'file': await MultipartFile.fromFile(path, filename: fileName),
    });
  }
}

PhotoFailure photoFailureFrom(DioException error) {
  final problem = ApiProblem.fromDioException(error);
  if (problem.isNetworkFailure) return PhotoFailure.network;
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.mediaFileTooLarge,
    ApiErrorCodes.requestPayloadTooLarge,
  ])) {
    return PhotoFailure.tooLarge;
  }
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.mediaMimeNotAllowed,
    ApiErrorCodes.mediaFileUnreadable,
    ApiErrorCodes.mediaFileRequired,
  ])) {
    return PhotoFailure.unsupportedType;
  }
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.authForbidden,
    ApiErrorCodes.authUnauthenticated,
  ])) {
    return PhotoFailure.permissionDenied;
  }
  return switch (problem.status) {
    413 => PhotoFailure.tooLarge,
    400 => PhotoFailure.unsupportedType,
    403 => PhotoFailure.permissionDenied,
    _ => PhotoFailure.unexpected,
  };
}
