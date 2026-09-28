import '../../../../core/result/result.dart';
import '../entities/driver_profile.dart';
import '../failures/driver_failure.dart';
import '../repositories/driver_repository.dart';

class FindDriverProfile {
  const FindDriverProfile(this.repository);

  final DriverRepository repository;

  Future<Result<DriverFailure, DriverProfile>> call(String driverToken) {
    return repository.findProfile(driverToken);
  }
}
