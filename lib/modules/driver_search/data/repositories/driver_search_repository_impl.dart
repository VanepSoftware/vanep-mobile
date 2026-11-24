import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_search/domain/entities/driver_search_page.dart';
import 'package:vanep_mobile/modules/driver_search/domain/failures/driver_search_failure.dart';
import 'package:vanep_mobile/modules/driver_search/domain/repositories/driver_search_repository.dart';
import 'package:vanep_mobile/modules/driver_search/data/datasources/driver_search_remote_datasource.dart';

const _placeNotResolvedCodes = {
  ApiErrorCodes.locationPlaceNotResolvable,
  ApiErrorCodes.locationPlaceNotFound,
  ApiErrorCodes.locationCountryUnsupported,
  ApiErrorCodes.locationStateUnsupported,
  ApiErrorCodes.locationComponentUnknownType,
  ApiErrorCodes.validationFailed,
  ApiErrorCodes.requestParameterInvalid,
};

DriverSearchFailure driverSearchFailureFrom(DioException exception) {
  final problem = ApiProblem.fromDioException(exception);
  if (problem.isNetworkFailure) return DriverSearchFailure.network;
  if (problem.matchesCode(ApiErrorCodes.locationCityUnmatched)) {
    return DriverSearchFailure.cityUnmatched;
  }
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.locationPlaceRateLimited,
    ApiErrorCodes.requestRateLimited,
  ])) {
    return DriverSearchFailure.rateLimited;
  }
  if (problem.matchesAnyCode(_placeNotResolvedCodes)) {
    return DriverSearchFailure.placeNotResolved;
  }
  return switch (problem.status) {
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

  @override
  Future<Result<DriverSearchFailure, DriverSearchPage>> fetchRecommended({
    int page = 0,
  }) async {
    try {
      return Ok(await remote.fetchRecommended(page: page));
    } on DioException catch (exception) {
      return Err(driverSearchFailureFrom(exception));
    }
  }
}
