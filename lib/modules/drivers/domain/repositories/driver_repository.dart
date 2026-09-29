import '../../../../core/result/result.dart';
import '../entities/driver.dart';
import '../entities/driver_profile.dart';
import '../failures/driver_failure.dart';

abstract class DriverRepository {
  Future<Result<DriverFailure, List<Driver>>> fetchRecentDrivers({int limit});

  Future<Result<DriverFailure, DriverProfile>> findProfile(String driverToken);
}
