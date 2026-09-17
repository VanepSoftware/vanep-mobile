import '../../../../core/result/result.dart';
import '../entities/service_area.dart';
import '../failures/service_area_failure.dart';
import '../repositories/driver_service_area_repository.dart';

class FindMyServiceAreas {
  const FindMyServiceAreas(this.repository);

  final DriverServiceAreaRepository repository;

  Future<Result<ServiceAreaFailure, List<ServiceArea>>> call() {
    return repository.findMyAreas();
  }
}
