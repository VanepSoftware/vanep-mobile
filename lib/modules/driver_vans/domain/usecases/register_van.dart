import '../../../../core/result/result.dart';
import '../entities/driver_van.dart';
import '../failures/driver_van_failure.dart';
import '../repositories/driver_van_repository.dart';
import '../value_objects/van_registration.dart';

class RegisterVan {
  const RegisterVan(this.repository);

  final DriverVanRepository repository;

  Future<Result<DriverVanFailure, DriverVan>> call(
    VanRegistration registration,
  ) {
    return repository.registerVan(registration);
  }
}
