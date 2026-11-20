import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/driver_search/data/datasources/driver_search_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late Environment environment;
  late DriverSearchRemoteDataSource dataSource;

  setUp(() {
    dio = MockDio();
    environment = const Environment(
      authBaseUrl: 'https://api.vanep.com.br',
      oauthClientId: 'vanep-mobile',
    );
    dataSource = DriverSearchRemoteDataSource(
      dio: dio,
      environment: environment,
    );
  });

  test('searchByPlace calls endpoint with query parameters', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ''),
        data: {
          'content': [
            {
              'token': 'driver-1',
              'name': 'Carlos',
              'available': true,
              'serviceAreas': ['Asa Sul'],
            },
          ],
          'last': true,
        },
      ),
    );

    final page = await dataSource.searchByPlace('place-1', 'session-1', page: 0);

    expect(page.drivers.length, 1);
    expect(page.drivers.first.name, 'Carlos');
    expect(page.isLast, isTrue);
    verify(
      () => dio.get<Map<String, dynamic>>(
        'https://api.vanep.com.br/api/drivers/search',
        queryParameters: {
          'placeId': 'place-1',
          'page': 0,
          'sessionToken': 'session-1',
        },
      ),
    ).called(1);
  });

  test('fetchRecommended calls recommended endpoint with page and size', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: ''),
        data: {
          'content': [
            {
              'token': 'driver-rec-1',
              'name': 'Marcos',
              'available': true,
              'serviceAreas': ['Taguatinga'],
            },
          ],
          'last': false,
        },
      ),
    );

    final page = await dataSource.fetchRecommended(page: 1, size: 10);

    expect(page.drivers.length, 1);
    expect(page.drivers.first.name, 'Marcos');
    expect(page.isLast, isFalse);
    verify(
      () => dio.get<Map<String, dynamic>>(
        'https://api.vanep.com.br/api/drivers/recommended',
        queryParameters: {
          'page': 1,
          'size': 10,
        },
      ),
    ).called(1);
  });
}
