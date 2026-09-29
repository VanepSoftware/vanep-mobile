import '../../../../core/result/result.dart';
import '../entities/driver_van.dart';
import '../failures/driver_van_failure.dart';
import '../repositories/driver_van_repository.dart';

class ListMyVans {
  const ListMyVans(this.repository);

  final DriverVanRepository repository;

  Future<Result<DriverVanFailure, List<DriverVan>>> call() {
    return repository.listMyVans();
  }
}
