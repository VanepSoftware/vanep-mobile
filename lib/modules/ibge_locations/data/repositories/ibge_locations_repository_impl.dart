import 'package:dio/dio.dart';

import '../../../../core/network/problem_detail.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/brazilian_city.dart';
import '../../domain/entities/brazilian_state.dart';
import '../../domain/entities/cep_lookup.dart';
import '../../domain/entities/ibge_locations_page.dart';
import '../../domain/failures/cep_failure.dart';
import '../../domain/failures/ibge_locations_failure.dart';
import '../../domain/repositories/ibge_locations_repository.dart';
import '../datasources/ibge_locations_remote_datasource.dart';

const cityNotInCatalogMarkers = ['catálogo', 'catalog'];

bool isCityNotInCatalogDetail(String detail) {
  final normalized = detail.toLowerCase();
  return cityNotInCatalogMarkers.any(normalized.contains);
}

CepFailure cepFailureFrom(DioException exception) {
  final status = exception.response?.statusCode;
  if (status == null) return CepFailure.network;
  if (status == 400) return CepFailure.invalidFormat;
  if (status == 429) return CepFailure.rateLimited;
  if (status == 503) return CepFailure.unavailable;
  if (status == 404) {
    final detail = readProblemDetail(exception.response?.data);
    if (isCityNotInCatalogDetail(detail)) {
      return CepFailure.cityNotInCatalog;
    }
    return CepFailure.notFound;
  }
  return CepFailure.unexpected;
}

IbgeLocationsFailure ibgeLocationsFailureFrom(DioException exception) {
  final status = exception.response?.statusCode;
  if (status == null) return IbgeLocationsFailure.network;
  if (status == 400) return IbgeLocationsFailure.ufMissing;
  if (status == 404) return IbgeLocationsFailure.ufNotFound;
  return IbgeLocationsFailure.unexpected;
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
