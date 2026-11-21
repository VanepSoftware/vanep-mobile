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
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, filename: fileName),
    });
    await dio.post<void>(endpoint, data: form, onSendProgress: onSendProgress);
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
