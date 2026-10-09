import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/failures/service_area_failure.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/repositories/driver_service_area_repository.dart';

class FindMyServiceAreas {
  const FindMyServiceAreas(this.repository);

  final DriverServiceAreaRepository repository;

  Future<Result<ServiceAreaFailure, List<ServiceArea>>> call() {
    return repository.findMyAreas();
  }
}
