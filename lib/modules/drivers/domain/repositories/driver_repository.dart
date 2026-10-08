import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';

abstract class DriverRepository {
  Future<Result<DriverFailure, List<Driver>>> fetchRecentDrivers({int limit});

  Future<Result<DriverFailure, DriverProfile>> findProfile(String driverToken);
}
