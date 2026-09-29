import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../network/api_image_loader.dart';
import '../network/dio_client.dart';
import '../network/photo_uploader.dart';
import 'image_picker_photo_picker.dart';
import 'photo_picker.dart';

void registerMediaDependencies(GetIt getIt) {
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<ApiImageLoader>(ApiImageLoader(dio: authenticatedDio))
    ..registerSingleton<PhotoUploader>(PhotoUploader(dio: authenticatedDio))
    ..registerLazySingleton<PhotoPicker>(ImagePickerPhotoPicker.new);
}
