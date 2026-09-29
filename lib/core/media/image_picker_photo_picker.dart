import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../result/result.dart';
import 'photo_failure.dart';
import 'photo_picker.dart';
import 'photo_source.dart';
import 'picked_photo.dart';

const double maxPickedPhotoDimension = 1600;

const int pickedPhotoQuality = 85;

class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker({ImagePicker? picker})
    : picker = picker ?? ImagePicker();

  final ImagePicker picker;

  @override
  Future<Result<PhotoFailure, PickedPhoto?>> pick(PhotoSource source) async {
    try {
      final file = await picker.pickImage(
        source: imageSourceFor(source),
        maxWidth: maxPickedPhotoDimension,
        maxHeight: maxPickedPhotoDimension,
        imageQuality: pickedPhotoQuality,
      );
      if (file == null) return const Ok(null);
      return Ok(PickedPhoto(path: file.path, fileName: file.name));
    } on PlatformException catch (error) {
      return Err(photoFailureFromPlatform(error));
    }
  }
}

ImageSource imageSourceFor(PhotoSource source) {
  return switch (source) {
    PhotoSource.gallery => ImageSource.gallery,
    PhotoSource.camera => ImageSource.camera,
  };
}

PhotoFailure photoFailureFromPlatform(PlatformException error) {
  return error.code.contains('access_denied')
      ? PhotoFailure.permissionDenied
      : PhotoFailure.unexpected;
}
