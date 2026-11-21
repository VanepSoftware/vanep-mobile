import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vanep_mobile/core/media/device_document_capture.dart';
import 'package:vanep_mobile/core/media/device_document_readers.dart';
import 'package:vanep_mobile/core/media/document_capture.dart';
import 'package:vanep_mobile/core/media/document_file_store.dart';
import 'package:vanep_mobile/core/network/api_image_loader.dart';
import 'package:vanep_mobile/core/network/dio_client.dart';
import 'package:vanep_mobile/core/network/file_uploader.dart';
import 'package:vanep_mobile/core/media/image_picker_photo_picker.dart';
import 'package:vanep_mobile/core/media/photo_picker.dart';

void registerMediaDependencies(GetIt getIt) {
  final authenticatedDio = getIt<Dio>(instanceName: authenticatedDioName);

  getIt
    ..registerSingleton<ApiImageLoader>(ApiImageLoader(dio: authenticatedDio))
    ..registerSingleton<FileUploader>(FileUploader(dio: authenticatedDio))
    ..registerLazySingleton<PhotoPicker>(ImagePickerPhotoPicker.new)
    ..registerLazySingleton<DocumentFileStore>(DocumentFileStore.new)
    ..registerLazySingleton<DocumentCapture>(
      () => DeviceDocumentCapture(
        scanner: ScannerDocumentReader(store: getIt<DocumentFileStore>()),
        gallery: GalleryDocumentReader(
          store: getIt<DocumentFileStore>(),
          photoPicker: getIt<PhotoPicker>(),
        ),
        pdfFile: PdfFileDocumentReader(store: getIt<DocumentFileStore>()),
      ),
    );
}
