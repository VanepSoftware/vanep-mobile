import 'package:vanep_mobile/modules/client_home/domain/repositories/driver_rating_repository.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';

class FindDriversToRate {
  const FindDriversToRate({required this.repository});

  final DriverRatingRepository repository;

  /// The rating items of the home. A failure leaves them out instead of
  /// breaking the whole screen.
  Future<List<RateDriverItem>> call() async {
    final result = await repository.findDriversToRate();
    return [
      for (final driver in result.valueOrNull ?? const [])
        RateDriverItem(driverToken: driver.token, driverName: driver.name),
    ];
  }
}
