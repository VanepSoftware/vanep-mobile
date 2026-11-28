import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/driver_to_rate.dart';

abstract class DriverRatingRepository {
  Future<Result<ClientHomeFailure, List<DriverToRate>>> findDriversToRate();

  Future<Result<ClientHomeFailure, void>> rate(String driverToken, int stars);
}
