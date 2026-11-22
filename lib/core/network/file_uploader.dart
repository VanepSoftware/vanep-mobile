import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/media/photo_failure.dart';

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
  return switch (error.response?.statusCode) {
    null => PhotoFailure.network,
    413 => PhotoFailure.tooLarge,
    400 => PhotoFailure.unsupportedType,
    _ => PhotoFailure.unexpected,
  };
}
