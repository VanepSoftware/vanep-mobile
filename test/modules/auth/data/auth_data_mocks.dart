import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/auth_local_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/oauth_remote_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/auth_session_dto.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/token_response_dto.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/user_profile_dto.dart';

class MockOAuthRemoteDataSource extends Mock implements OAuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockBox extends Mock implements Box<String> {}

class MockDio extends Mock implements Dio {}

/// Test [Environment] built from its public constructor (no dotenv needed).
const testEnvironment = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
  oauthRedirectUri: 'com.vanep.vanepmobile://oauth2redirect',
  oauthScopes: 'read write',
);

const testUserProfileDto = UserProfileDto(
  token: 'user-token-1',
  name: 'Ana Motorista',
  email: 'ana@vanep.com.br',
  type: 'DRIVER',
);

const testTokenResponseDto = TokenResponseDto(
  accessToken: 'access-1',
  tokenType: 'Bearer',
  expiresInSeconds: 900,
  refreshToken: 'refresh-1',
  scope: 'read write',
);

AuthSessionDto testAuthSessionDto({DateTime? expiresAt}) => AuthSessionDto(
      accessToken: 'access-1',
      refreshToken: 'refresh-1',
      expiresAt: expiresAt ?? DateTime.utc(2999),
      profile: testUserProfileDto,
    );

void registerAuthDataFallbacks() {
  registerFallbackValue(testAuthSessionDto());
  registerFallbackValue(RequestOptions());
}
