import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/city_unmatched_problem.dart';
import 'package:vanep_mobile/core/network/problem_detail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area_draft.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/failures/service_area_failure.dart';
import 'package:vanep_mobile/modules/driver_service_areas/domain/repositories/driver_service_area_repository.dart';
import 'package:vanep_mobile/modules/driver_service_areas/data/datasources/driver_service_area_remote_datasource.dart';

const districtRequiredMarker = 'bairro';
const tooManyAreasMarker = 'máximo';

ServiceAreaFailure serviceAreaFailureFrom(DioException exception) {
  final status = exception.response?.statusCode;
  if (status == null) return ServiceAreaFailure.network;
  if (status == 429) return ServiceAreaFailure.rateLimited;
  if (status != 400) return ServiceAreaFailure.unexpected;
  if (isIbgeCityUnmatchedProblem(exception.response?.data)) {
    return ServiceAreaFailure.cityUnmatched;
  }
  final detail = readProblemDetail(exception.response?.data).toLowerCase();
  if (detail.contains(tooManyAreasMarker)) return ServiceAreaFailure.tooManyAreas;
  if (detail.contains(districtRequiredMarker)) {
    return ServiceAreaFailure.districtRequired;
  }
  return ServiceAreaFailure.placeNotResolved;
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
