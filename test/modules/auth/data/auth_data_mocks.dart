import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/account_remote_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/auth_local_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/google_id_token_source.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/oauth_remote_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/user_profile_remote_datasource.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/web_session_cleaner.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/auth_session_dto.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/token_response_dto.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/user_profile_dto.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_patch_request.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

import '../account_fixtures.dart';

class MockOAuthRemoteDataSource extends Mock implements OAuthRemoteDataSource {}

class MockUserProfileRemoteDataSource extends Mock
    implements UserProfileRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAccountRemoteDataSource extends Mock
    implements AccountRemoteDataSource {}

class MockWebSessionCleaner extends Mock implements WebSessionCleaner {}

class MockGoogleIdTokenSource extends Mock implements GoogleIdTokenSource {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockDio extends Mock implements Dio {}

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
  phone: '11999999999',
  document: '12345678901',
  birthDate: '1990-05-15',
  gender: Gender.female,
  type: UserType.driver,
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
  registerFallbackValue(const ProfilePatchRequest());
  registerFallbackValue(<String, Object?>{});
  registerFallbackValue(validClientSignupForm);
}
