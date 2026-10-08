import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/city_unmatched_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_page.dart';
import 'package:vanep_mobile/modules/driver_search/domain/failures/driver_search_failure.dart';
import 'package:vanep_mobile/modules/driver_search/domain/repositories/driver_search_repository.dart';
import 'package:vanep_mobile/modules/driver_search/data/datasources/driver_search_remote_datasource.dart';

DriverSearchFailure driverSearchFailureFrom(DioException exception) {
  final status = exception.response?.statusCode;
  if (status == 400 && isIbgeCityUnmatchedProblem(exception.response?.data)) {
    return DriverSearchFailure.cityUnmatched;
  }
  return switch (status) {
    null => DriverSearchFailure.network,
    400 => DriverSearchFailure.placeNotResolved,
    429 => DriverSearchFailure.rateLimited,
    _ => DriverSearchFailure.unexpected,
  };
}

class DriverSearchRepositoryImpl implements DriverSearchRepository {
  const DriverSearchRepositoryImpl({required this.remote});

  final DriverSearchRemoteDataSource remote;

  @override
  Future<Result<DriverSearchFailure, DriverSearchPage>> searchByPlace(
    String placeId,
    String? sessionToken, {
    int page = 0,
  }) async {
    try {
      return Ok(await remote.searchByPlace(placeId, sessionToken, page: page));
    } on DioException catch (exception) {
      return Err(driverSearchFailureFrom(exception));
    }
  }
}
