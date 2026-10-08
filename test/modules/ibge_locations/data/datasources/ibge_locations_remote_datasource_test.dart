import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/datasources/ibge_locations_remote_datasource.dart';

import '../../ibge_locations_data_mocks.dart';
import '../../ibge_locations_fixture.dart';

Response<Map<String, dynamic>> okCatalog(Map<String, Object?> body) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(),
      statusCode: 200,
      data: Map<String, dynamic>.from(body),
    );

void main() {
  late MockDio dio;
  late IbgeLocationsRemoteDataSource remote;

  setUpAll(registerIbgeLocationsDataFallbacks);

  setUp(() {
    dio = MockDio();
    remote = IbgeLocationsRemoteDataSource(
      dio: dio,
      environment: testIbgeEnvironment,
    );
  });

  test('lookupCep gets /api/cep/{digits}', () async {
    when(
      () => dio.get<Map<String, dynamic>>(any()),
    ).thenAnswer((_) async => okCatalog(fakeCepLookupJson()));

    final lookup = await remote.lookupCep('72120120');

    expect(lookup, fakeCepLookup());
    verify(
      () => dio.get<Map<String, dynamic>>(
        testIbgeEnvironment.cepLookupEndpoint('72120120'),
      ),
    ).called(1);
  });

  test('listStates gets /api/states with page and size', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => okCatalog(
        fakeIbgeLocationsPageJson(
          content: [fakeBrazilianStateJson()],
          size: 30,
        ),
      ),
    );

    final page = await remote.listStates(page: 0, size: 30);

    expect(page.items, [fakeDfState]);
    verify(
      () => dio.get<Map<String, dynamic>>(
        testIbgeEnvironment.statesEndpoint,
        queryParameters: {'page': 0, 'size': 30},
      ),
    ).called(1);
  });

  test('listCities always sends uf on /api/cities', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => okCatalog(
        fakeIbgeLocationsPageJson(content: [fakeBrazilianCityJson()]),
      ),
    );

    final page = await remote.listCities(uf: 'DF', page: 0, size: 20);

    expect(page.items, [fakeBrazilianCity()]);
    verify(
      () => dio.get<Map<String, dynamic>>(
        testIbgeEnvironment.citiesEndpoint,
        queryParameters: {'uf': 'DF', 'page': 0, 'size': 20},
      ),
    ).called(1);
  });
}
