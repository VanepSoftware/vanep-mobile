import '../../../../core/result/result.dart';
import '../entities/driver.dart';
import '../failures/driver_failure.dart';
import '../repositories/driver_repository.dart';

class ListRecentDrivers {
  const ListRecentDrivers(this._repository, {this.defaultLimit = 3});

  final DriverRepository _repository;
  final int defaultLimit;

  Future<Result<DriverFailure, List<Driver>>> call({int? limit}) {
    return _repository.fetchRecentDrivers(limit: limit ?? defaultLimit);
  }
}
