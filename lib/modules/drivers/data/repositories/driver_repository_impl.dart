import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver.dart';
import 'package:vanep_mobile/modules/drivers/domain/entities/driver_profile.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/drivers/domain/repositories/driver_repository.dart';
import 'package:vanep_mobile/modules/drivers/data/datasources/driver_remote_datasource.dart';

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
      return Err(driverProfileFailureFrom(error));
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
  final problem = ApiProblem.fromDioException(error);
  if (problem.isNetworkFailure) return NetworkDriverFailure(error.message);
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.driverNotFound,
    ApiErrorCodes.userDriverProfileNotFound,
    ApiErrorCodes.requestRouteNotFound,
  ])) {
    return const NotFoundDriverFailure();
  }
  if (problem.status == 404) return const NotFoundDriverFailure();
  return UnexpectedDriverFailure(problem.detail ?? error.message);
}
