import '../result/result.dart';
import 'photo_failure.dart';
import 'photo_source.dart';
import 'picked_photo.dart';

abstract class PhotoPicker {
  Future<Result<PhotoFailure, PickedPhoto?>> pick(PhotoSource source);
}
