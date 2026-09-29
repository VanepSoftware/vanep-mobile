import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/ibge_locations/data/datasources/ibge_locations_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

class MockIbgeLocationsRemoteDataSource extends Mock
    implements IbgeLocationsRemoteDataSource {}

const testIbgeEnvironment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
);

void registerIbgeLocationsDataFallbacks() {
  registerFallbackValue(RequestOptions());
  registerFallbackValue(Options());
}
