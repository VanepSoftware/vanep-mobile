import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/photo_source.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';

abstract class PhotoPicker {
  Future<Result<PhotoFailure, PickedPhoto?>> pick(PhotoSource source);
}
