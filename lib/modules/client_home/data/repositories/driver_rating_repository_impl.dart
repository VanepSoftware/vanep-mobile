import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/driver_rating_remote_datasource.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/repositories/driver_rating_repository.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/driver_to_rate.dart';

class DriverRatingRepositoryImpl implements DriverRatingRepository {
  const DriverRatingRepositoryImpl({required this.remote});

  final DriverRatingRemoteDataSource remote;

  @override
  Future<Result<ClientHomeFailure, List<DriverToRate>>> findDriversToRate() {
    return _guard(() async {
      final drivers = await remote.fetchMyDrivers();
      final allowed = await Future.wait([
        for (final driver in drivers) canRateOrFalse(driver.token),
      ]);
      return [
        for (final (index, driver) in drivers.indexed)
          if (allowed[index]) driver,
      ];
    });
  }

  /// A status that cannot be read hides only that driver, not the whole list.
  Future<bool> canRateOrFalse(String driverToken) async {
    try {
      return await remote.canRate(driverToken);
    } on DioException {
      return false;
    }
  }

  @override
  Future<Result<ClientHomeFailure, void>> rate(String driverToken, int stars) {
    return _guard(() => remote.rate(driverToken, stars));
  }

  Future<Result<ClientHomeFailure, T>> _guard<T>(
    Future<T> Function() call,
  ) async {
    try {
      return Ok(await call());
    } on DioException catch (error) {
      return Err(
        error.response == null
            ? ClientHomeFailure.network
            : ClientHomeFailure.unexpected,
      );
    }
  }
}
