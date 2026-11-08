import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/schools/data/datasources/school_remote_datasource.dart';
import 'package:vanep_mobile/modules/schools/domain/repositories/school_repository.dart';

class MockDio extends Mock implements Dio {}

class MockSchoolRemoteDataSource extends Mock
    implements SchoolRemoteDataSource {}

class MockSchoolRepository extends Mock implements SchoolRepository {}

const testSchoolsEnvironment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
);

const deltaSchoolJson = <String, Object?>{
  'token': 'school-delta',
  'name': 'Colégio Delta',
  'googlePlaceId': 'place-delta',
  'cityName': 'Brasília',
  'cityToken': 'city-brasilia',
  'address': null,
  'active': true,
  'createdAt': '2026-10-01T12:00:00Z',
};

DioException schoolDioFailure(int? status, {Object? body}) {
  final requestOptions = RequestOptions(path: '/api/schools/resolve');
  return DioException(
    requestOptions: requestOptions,
    response: status == null
        ? null
        : Response<Object?>(
            requestOptions: requestOptions,
            statusCode: status,
            data: body,
          ),
  );
}
