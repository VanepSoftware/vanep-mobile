import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/driver_rating_remote_datasource.dart';
import 'package:vanep_mobile/modules/client_home/data/repositories/driver_rating_repository_impl.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/find_drivers_to_rate.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';

class MockDio extends Mock implements Dio {}

const environment = Environment(
  authBaseUrl: 'https://api.vanep.test',
  oauthClientId: 'vanep-mobile',
);

Response<T> ok<T>(T data) => Response<T>(
  requestOptions: RequestOptions(path: ''),
  data: data,
);

void main() {
  late MockDio dio;
  late DriverRatingRepositoryImpl repository;

  setUp(() {
    dio = MockDio();
    repository = DriverRatingRepositoryImpl(
      remote: DriverRatingRemoteDataSource(dio: dio, environment: environment),
    );
  });

  void linksReturn(List<Map<String, dynamic>> links) {
    when(() => dio.get<List<dynamic>>(any()))
        .thenAnswer((_) async => ok<List<dynamic>>(links));
  }

  void statusReturns(String driverToken, bool canRate) {
    when(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: {'driverToken': driverToken},
      ),
    ).thenAnswer(
      (_) async =>
          ok<Map<String, dynamic>>({'rated': !canRate, 'canRate': canRate}),
    );
  }

  test('offers only the drivers the API lets the client rate', () async {
    linksReturn([
      {'driverToken': 'drv-carlos', 'driverName': 'Carlos Souza'},
      {'driverToken': 'drv-rita', 'driverName': 'Rita Lima'},
      {'driverToken': 'drv-carlos', 'driverName': 'Carlos Souza'},
    ]);
    statusReturns('drv-carlos', true);
    statusReturns('drv-rita', false);

    final items = await FindDriversToRate(repository: repository)();

    expect(items, const [
      RateDriverItem(driverToken: 'drv-carlos', driverName: 'Carlos Souza'),
    ]);
    verify(
      () => dio.get<Map<String, dynamic>>(
        'https://api.vanep.test/api/driver-ratings/status',
        queryParameters: {'driverToken': 'drv-carlos'},
      ),
    ).called(1);
  });

  test('leaves the items out when the request fails', () async {
    when(() => dio.get<List<dynamic>>(any()))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

    expect(await FindDriversToRate(repository: repository)(), isEmpty);
  });

  test('posts the stars as the rating', () async {
    when(() => dio.post<void>(any(), data: any(named: 'data')))
        .thenAnswer((_) async => ok<void>(null));

    final result = await repository.rate('drv-carlos', 5);

    expect(result.isOk, isTrue);
    verify(
      () => dio.post<void>(
        'https://api.vanep.test/api/driver-ratings',
        data: {'driverToken': 'drv-carlos', 'rating': 5},
      ),
    ).called(1);
  });

  test('maps a refused rating to a failure', () async {
    when(() => dio.post<void>(any(), data: any(named: 'data'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response<void>(
          requestOptions: RequestOptions(path: ''),
          statusCode: 409,
        ),
      ),
    );

    final result = await repository.rate('drv-carlos', 5);

    expect(result.errorOrNull, ClientHomeFailure.unexpected);
  });
}
