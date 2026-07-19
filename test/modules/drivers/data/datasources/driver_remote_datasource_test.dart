import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/drivers/data/datasources/driver_remote_datasource.dart';

import '../drivers_data_mocks.dart';
import '../../drivers_fixtures.dart';

Response<Map<String, dynamic>> _ok(Map<String, dynamic> body) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(),
      statusCode: 200,
      data: body,
    );

void main() {
  late MockDio dio;
  late DriverRemoteDataSource remote;

  setUp(() {
    dio = MockDio();
    remote = DriverRemoteDataSource(dio: dio, environment: testEnvironment);
  });

  test('fetchRecentDrivers requests sorted page and parses content', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => _ok(driversPageJson([carlosJson])));

    final drivers = await remote.fetchRecentDrivers(limit: 3);

    expect(drivers, hasLength(1));
    expect(drivers.first.name, 'Carlos Souza');

    final query =
        verify(
              () => dio.get<Map<String, dynamic>>(
                testEnvironment.driversEndpoint,
                queryParameters: captureAny(named: 'queryParameters'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(query['size'], 3);
    expect(query['sort'], 'createdAt,desc');
  });

  test('fetchRecentDrivers returns empty list when content is absent', () async {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer((_) async => _ok({'totalElements': 0}));

    final drivers = await remote.fetchRecentDrivers(limit: 3);

    expect(drivers, isEmpty);
  });
}
