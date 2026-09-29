import '../../../../core/media/photo_failure.dart';
import '../../../../core/media/picked_photo.dart';
import '../../../../core/result/result.dart';
import '../repositories/driver_van_repository.dart';
import '../value_objects/van_photo_target.dart';

class ChangeVanPhoto {
  const ChangeVanPhoto(this.repository);

  final DriverVanRepository repository;

  Future<Result<PhotoFailure, void>> call(
    VanPhotoTarget target,
    PickedPhoto photo,
  ) {
    return repository.uploadVanPhoto(target.vanToken, target.side, photo);
  }
}
