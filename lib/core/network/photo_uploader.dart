import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';

class PhotoUploader {
  const PhotoUploader({required this.dio});

  final Dio dio;

  Future<void> upload(String endpoint, PickedPhoto photo) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        photo.path,
        filename: photo.fileName,
      ),
    });
    await dio.post<void>(endpoint, data: form);
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
