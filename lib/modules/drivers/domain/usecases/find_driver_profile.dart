import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/domain/repositories/driver_repository.dart';

class FindDriverProfile {
  const FindDriverProfile(this.repository);

  final DriverRepository repository;

  Future<Result<DriverFailure, DriverProfile>> call(String driverToken) {
    return repository.findProfile(driverToken);
  }
}
