import 'package:dio/dio.dart';

import 'package:vanep_mobile/core/network/api_error_codes.dart';
import 'package:vanep_mobile/core/network/api_problem.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/cep_lookup.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/ibge_locations_page.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/repositories/ibge_locations_repository.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/datasources/ibge_locations_remote_datasource.dart';

CepFailure cepFailureFrom(DioException exception) {
  final problem = ApiProblem.fromDioException(exception);
  if (problem.isNetworkFailure) return CepFailure.network;
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.cepInvalid,
    ApiErrorCodes.validationFailed,
    ApiErrorCodes.requestParameterInvalid,
  ])) {
    return CepFailure.invalidFormat;
  }
  if (problem.matchesCode(ApiErrorCodes.cepIbgeNotFound)) {
    return CepFailure.cityNotInCatalog;
  }
  if (problem.matchesCode(ApiErrorCodes.cepNotFound)) {
    return CepFailure.notFound;
  }
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.cepRateLimited,
    ApiErrorCodes.requestRateLimited,
  ])) {
    return CepFailure.rateLimited;
  }
  if (problem.matchesCode(ApiErrorCodes.cepLookupFailed)) {
    return CepFailure.unavailable;
  }
  return switch (problem.status) {
    400 => CepFailure.invalidFormat,
    404 => CepFailure.notFound,
    429 => CepFailure.rateLimited,
    503 => CepFailure.unavailable,
    _ => CepFailure.unexpected,
  };
}

IbgeLocationsFailure ibgeLocationsFailureFrom(DioException exception) {
  final problem = ApiProblem.fromDioException(exception);
  if (problem.isNetworkFailure) return IbgeLocationsFailure.network;
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.cityUfRequired,
    ApiErrorCodes.validationFailed,
    ApiErrorCodes.requestParameterInvalid,
  ])) {
    return IbgeLocationsFailure.ufMissing;
  }
  if (problem.matchesAnyCode(const [
    ApiErrorCodes.stateUfNotFound,
    ApiErrorCodes.stateNotFound,
  ])) {
    return IbgeLocationsFailure.ufNotFound;
  }
  return switch (problem.status) {
    400 => IbgeLocationsFailure.ufMissing,
    404 => IbgeLocationsFailure.ufNotFound,
    _ => IbgeLocationsFailure.unexpected,
  };
}

class IbgeLocationsRepositoryImpl implements IbgeLocationsRepository {
  const IbgeLocationsRepositoryImpl({required this.remote});

  final IbgeLocationsRemoteDataSource remote;

  @override
  Future<Result<CepFailure, CepLookup>> lookupCep(String cep) async {
    try {
      return Ok(await remote.lookupCep(cep));
    } on DioException catch (exception) {
      return Err(cepFailureFrom(exception));
    }
  }

  @override
  Future<Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianState>>>
  listStates({required int page, required int size}) async {
    try {
      return Ok(await remote.listStates(page: page, size: size));
    } on DioException catch (exception) {
      return Err(ibgeLocationsFailureFrom(exception));
    }
  }

  @override
  Future<Result<IbgeLocationsFailure, IbgeLocationsPage<BrazilianCity>>>
  listCities({
    required String uf,
    String? search,
    required int page,
    required int size,
  }) async {
    try {
      return Ok(
        await remote.listCities(uf: uf, search: search, page: page, size: size),
      );
    } on DioException catch (exception) {
      return Err(ibgeLocationsFailureFrom(exception));
    }
  }
}
