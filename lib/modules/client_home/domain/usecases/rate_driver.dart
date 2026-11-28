import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/repositories/driver_rating_repository.dart';

class RateDriver {
  const RateDriver({required this.repository});

  final DriverRatingRepository repository;

  Future<Result<ClientHomeFailure, void>> call(String driverToken, int stars) {
    return repository.rate(driverToken, stars);
  }
}
