import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/repositories/ibge_locations_repository_impl.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/cep_failure.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/failures/ibge_locations_failure.dart';

import '../../ibge_locations_data_mocks.dart';
import '../../ibge_locations_fixture.dart';

DioException ibgeHttpFailure({
  required String path,
  int? statusCode,
  Object? data,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    type: statusCode == null ? DioExceptionType.connectionTimeout : type,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: RequestOptions(path: path),
            statusCode: statusCode,
            data: data,
          ),
  );
}

void main() {
  late MockIbgeLocationsRemoteDataSource remote;
  late IbgeLocationsRepositoryImpl repository;

  setUpAll(registerIbgeLocationsDataFallbacks);

  setUp(() {
    remote = MockIbgeLocationsRemoteDataSource();
    repository = IbgeLocationsRepositoryImpl(remote: remote);
  });

  test('CEP 200 returns the mapped lookup', () async {
    when(
      () => remote.lookupCep(any()),
    ).thenAnswer((_) async => fakeCepLookup());

    final result = await repository.lookupCep('72120120');

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, fakeCepLookup());
  });

  test('CEP 400 is invalidFormat', () async {
    when(
      () => remote.lookupCep(any()),
    ).thenThrow(ibgeHttpFailure(path: '/api/cep/abc', statusCode: 400));

    final result = await repository.lookupCep('abc');

    expect(result.errorOrNull, CepFailure.invalidFormat);
  });

  test('CEP 404 with não encontrado is notFound', () async {
    when(() => remote.lookupCep(any())).thenThrow(
      ibgeHttpFailure(
        path: '/api/cep/00000000',
        statusCode: 404,
        data: fakeCepNotFoundProblem(),
      ),
    );

    final result = await repository.lookupCep('00000000');

    expect(result.errorOrNull, CepFailure.notFound);
  });

  test('CEP 404 with não está no catálogo is cityNotInCatalog', () async {
    when(() => remote.lookupCep(any())).thenThrow(
      ibgeHttpFailure(
        path: '/api/cep/70000000',
        statusCode: 404,
        data: fakeCepCityNotInCatalogProblem(),
      ),
    );

    final result = await repository.lookupCep('70000000');

    expect(result.errorOrNull, CepFailure.cityNotInCatalog);
  });

  test(
    'CEP 404 in English with not in the catalog is cityNotInCatalog',
    () async {
      when(() => remote.lookupCep(any())).thenThrow(
        ibgeHttpFailure(
          path: '/api/cep/70000000',
          statusCode: 404,
          data: fakeCepCityNotInCatalogProblemEn(),
        ),
      );

      final result = await repository.lookupCep('70000000');

      expect(result.errorOrNull, CepFailure.cityNotInCatalog);
    },
  );

  test('CEP 404 in English with not found is notFound', () async {
    when(() => remote.lookupCep(any())).thenThrow(
      ibgeHttpFailure(
        path: '/api/cep/00000000',
        statusCode: 404,
        data: fakeCepNotFoundProblemEn(),
      ),
    );

    final result = await repository.lookupCep('00000000');

    expect(result.errorOrNull, CepFailure.notFound);
  });

  test('CEP 404 without a body is notFound', () async {
    when(
      () => remote.lookupCep(any()),
    ).thenThrow(ibgeHttpFailure(path: '/api/cep/00000000', statusCode: 404));

    final result = await repository.lookupCep('00000000');

    expect(result.errorOrNull, CepFailure.notFound);
  });

  test('CEP 429 is rateLimited', () async {
    when(
      () => remote.lookupCep(any()),
    ).thenThrow(ibgeHttpFailure(path: '/api/cep/72120120', statusCode: 429));

    final result = await repository.lookupCep('72120120');

    expect(result.errorOrNull, CepFailure.rateLimited);
  });

  test('CEP 503 is unavailable', () async {
    when(
      () => remote.lookupCep(any()),
    ).thenThrow(ibgeHttpFailure(path: '/api/cep/72120120', statusCode: 503));

    final result = await repository.lookupCep('72120120');

    expect(result.errorOrNull, CepFailure.unavailable);
  });

  test('CEP timeout is network', () async {
    when(() => remote.lookupCep(any())).thenThrow(
      ibgeHttpFailure(
        path: '/api/cep/72120120',
        type: DioExceptionType.connectionTimeout,
      ),
    );

    final result = await repository.lookupCep('72120120');

    expect(result.errorOrNull, CepFailure.network);
  });

  test('states 200 returns the page', () async {
    final page = fakeIbgeLocationsPage(items: [fakeDfState], size: 30);
    when(
      () => remote.listStates(
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => page);

    final result = await repository.listStates(page: 0, size: 30);

    expect(result.valueOrNull, page);
  });

  test('listCities requires uf and returns the page of content', () async {
    final page = fakeIbgeLocationsPage(items: [fakeBrazilianCity()]);
    when(
      () => remote.listCities(
        uf: 'DF',
        search: any(named: 'search'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenAnswer((_) async => page);

    final result = await repository.listCities(uf: 'DF', page: 0, size: 20);

    expect(result.valueOrNull, page);
    verify(
      () => remote.listCities(uf: 'DF', search: null, page: 0, size: 20),
    ).called(1);
  });

  test('cities with an unknown uf 404 is ufNotFound', () async {
    when(
      () => remote.listCities(
        uf: 'XX',
        search: any(named: 'search'),
        page: any(named: 'page'),
        size: any(named: 'size'),
      ),
    ).thenThrow(ibgeHttpFailure(path: '/api/cities', statusCode: 404));

    final result = await repository.listCities(uf: 'XX', page: 0, size: 20);

    expect(result.errorOrNull, IbgeLocationsFailure.ufNotFound);
  });
}
