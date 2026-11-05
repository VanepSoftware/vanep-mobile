import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/domain/repositories/driver_repository.dart';

class ListRecentDrivers {
  const ListRecentDrivers(this._repository, {this.defaultLimit = 3});

  final DriverRepository _repository;
  final int defaultLimit;

  Future<Result<DriverFailure, List<Driver>>> call({int? limit}) {
    return _repository.fetchRecentDrivers(limit: limit ?? defaultLimit);
  }
}
