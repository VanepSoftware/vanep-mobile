import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/failures/driver_van_failure.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/repositories/driver_van_repository.dart';

class ListMyVans {
  const ListMyVans(this.repository);

  final DriverVanRepository repository;

  Future<Result<DriverVanFailure, List<DriverVan>>> call() {
    return repository.listMyVans();
  }
}
