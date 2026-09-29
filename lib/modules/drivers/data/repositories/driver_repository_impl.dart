import 'package:dio/dio.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/driver.dart';
import '../../domain/entities/driver_profile.dart';
import '../../domain/failures/driver_failure.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/driver_remote_datasource.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl({required this.remote});

  final DriverRemoteDataSource remote;

  @override
  Future<Result<DriverFailure, List<Driver>>> fetchRecentDrivers({
    int limit = 3,
  }) async {
    try {
      final drivers = await remote.fetchRecentDrivers(limit: limit);
      return Ok(drivers);
    } on DioException catch (error) {
      return Err(NetworkDriverFailure(error.message));
    } on Object catch (error) {
      return Err(UnexpectedDriverFailure(error.toString()));
    }
  }

  @override
  Future<Result<DriverFailure, DriverProfile>> findProfile(
    String driverToken,
  ) async {
    try {
      return Ok(await remote.fetchProfile(driverToken));
    } on DioException catch (error) {
      return Err(driverProfileFailureFrom(error));
    } on Object catch (error) {
      return Err(UnexpectedDriverFailure(error.toString()));
    }
  }
}

DriverFailure driverProfileFailureFrom(DioException error) {
  return switch (error.response?.statusCode) {
    404 => const NotFoundDriverFailure(),
    null => NetworkDriverFailure(error.message),
    _ => UnexpectedDriverFailure(error.message),
  };
}
