import 'package:vanep_mobile/core/media/photo_failure.dart';
import 'package:vanep_mobile/core/media/picked_photo.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_photo_side.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/value_objects/van_registration.dart';

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
