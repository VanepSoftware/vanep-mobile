import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/core/network/photo_uploader.dart';
import 'package:vanep_mobile/core/media/image_picker_photo_picker.dart';
import 'package:vanep_mobile/core/media/photo_picker.dart';

void registerMediaDependencies(GetIt getIt) {
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<ApiImageLoader>(ApiImageLoader(dio: authenticatedDio))
    ..registerSingleton<PhotoUploader>(PhotoUploader(dio: authenticatedDio))
    ..registerLazySingleton<PhotoPicker>(ImagePickerPhotoPicker.new);
}
