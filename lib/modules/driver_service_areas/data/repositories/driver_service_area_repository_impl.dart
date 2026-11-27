import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area_draft.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/failures/service_area_failure.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/repositories/driver_service_area_repository.dart';
import 'package:vanep_mobile/modules/driver_service_areas/data/datasources/driver_service_area_remote_datasource.dart';

const _placeNotResolvedCodes = {
  ApiErrorCodes.driverServiceAreaAreaTokenUnknown,
  ApiErrorCodes.driverServiceAreaAreasRequired,
  ApiErrorCodes.driverServiceAreaItemInvalid,
  ApiErrorCodes.driverServiceAreaPlaceIdTooLong,
  ApiErrorCodes.driverServiceAreaAreaTokenTooLong,
  ApiErrorCodes.driverServiceAreaSessionTokenTooLong,
  ApiErrorCodes.locationPlaceNotResolvable,
  ApiErrorCodes.locationPlaceNotFound,
  ApiErrorCodes.locationCountryUnsupported,
  ApiErrorCodes.locationStateUnsupported,
  ApiErrorCodes.locationComponentUnknownType,
  ApiErrorCodes.validationFailed,
  ApiErrorCodes.requestBodyUnreadable,
  ApiErrorCodes.requestParameterInvalid,
};

ServiceAreaFailure serviceAreaFailureFrom(DioException exception) {
  final problem = ApiProblem.fromDioException(exception);
  if (problem.isNetworkFailure) return ServiceAreaFailure.network;
  if (problem.matchesCode(ApiErrorCodes.locationCityUnmatched)) {
    return ServiceAreaFailure.cityUnmatched;
  }
  if (problem.matchesCode(ApiErrorCodes.driverServiceAreaAreasTooMany)) {
    return ServiceAreaFailure.tooManyAreas;
  }
  if (problem.matchesCode(ApiErrorCodes.driverServiceAreaDistrictRequired)) {
    return ServiceAreaFailure.districtRequired;
  }
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.locationPlaceRateLimited,
    ApiErrorCodes.requestRateLimited,
  ])) {
    return ServiceAreaFailure.rateLimited;
  }
  if (problem.matchesAnyCode(_placeNotResolvedCodes)) {
    return ServiceAreaFailure.placeNotResolved;
  }

  return switch (problem.status) {
    429 => ServiceAreaFailure.rateLimited,
    400 => ServiceAreaFailure.placeNotResolved,
    _ => ServiceAreaFailure.unexpected,
  };
}

class DriverServiceAreaRepositoryImpl implements DriverServiceAreaRepository {
  const DriverServiceAreaRepositoryImpl({required this.remote});

  final DriverServiceAreaRemoteDataSource remote;

  @override
  Future<Result<ServiceAreaFailure, List<ServiceArea>>> findMyAreas() async {
    try {
      return Ok(await remote.fetchMyAreas());
    } on DioException catch (exception) {
      return Err(serviceAreaFailureFrom(exception));
    }
  }

  @override
  Future<Result<ServiceAreaFailure, List<ServiceArea>>> replaceMyAreas(
    List<ServiceAreaDraft> drafts,
  ) async {
    try {
      return Ok(await remote.replaceMyAreas(drafts));
    } on DioException catch (exception) {
      return Err(serviceAreaFailureFrom(exception));
    }
  }
}
