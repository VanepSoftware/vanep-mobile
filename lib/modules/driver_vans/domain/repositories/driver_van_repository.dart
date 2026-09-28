import '../../../../core/media/photo_failure.dart';
import '../../../../core/media/picked_photo.dart';
import '../../../../core/result/result.dart';
import '../entities/driver_van.dart';
import '../failures/driver_van_failure.dart';
import '../value_objects/van_photo_side.dart';
import '../value_objects/van_registration.dart';

abstract class DriverVanRepository {
  Future<Result<DriverVanFailure, List<DriverVan>>> listMyVans();

  Future<Result<DriverVanFailure, DriverVan>> registerVan(
    VanRegistration registration,
  );

  Future<Result<PhotoFailure, void>> uploadVanPhoto(
    String vanToken,
    VanPhotoSide side,
    PickedPhoto photo,
  );
}
