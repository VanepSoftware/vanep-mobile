import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/repositories/driver_van_repository.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_target.dart';

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
