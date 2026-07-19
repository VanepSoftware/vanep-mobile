import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/drivers/data/datasources/driver_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

class MockDriverRemoteDataSource extends Mock
    implements DriverRemoteDataSource {}

const testEnvironment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
  oauthRedirectUri: 'com.vanep.vanepmobile://oauth2redirect',
  oauthScopes: 'read write',
);
