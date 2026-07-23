import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/oauth_remote_datasource.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

import '../auth_data_mocks.dart';

Response<Map<String, dynamic>> _ok(Map<String, dynamic> body) =>
    Response<Map<String, dynamic>>(
      requestOptions: RequestOptions(),
      statusCode: 200,
      data: body,
    );

void main() {
  late MockDio dio;
  late OAuthRemoteDataSource remote;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Options());
  });

  setUp(() {
    dio = MockDio();
    remote = OAuthRemoteDataSource(dio: dio, environment: testEnvironment);
  });

  test('exchangeCode posts the authorization_code grant with PKCE', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _ok({
        'access_token': 'access-1',
        'token_type': 'Bearer',
        'expires_in': 900,
        'refresh_token': 'refresh-1',
      }),
    );

    final token = await remote.exchangeCode(
      code: 'the-code',
      codeVerifier: 'verifier-1',
      redirectUri: 'com.vanep.vanepmobile://oauth2redirect',
    );

    expect(token.accessToken, 'access-1');
    expect(token.expiresInSeconds, 900);
    final captured =
        verify(
              () => dio.post<Map<String, dynamic>>(
                testEnvironment.tokenEndpoint,
                data: captureAny(named: 'data'),
                options: any(named: 'options'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(captured['grant_type'], 'authorization_code');
    expect(captured['code'], 'the-code');
    expect(captured['code_verifier'], 'verifier-1');
    expect(captured['client_id'], 'vanep-mobile');
  });

  test('refresh posts the refresh_token grant', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => _ok({
        'access_token': 'access-2',
        'token_type': 'Bearer',
        'expires_in': 900,
      }),
    );

    await remote.refresh('refresh-1');

    final captured =
        verify(
              () => dio.post<Map<String, dynamic>>(
                testEnvironment.tokenEndpoint,
                data: captureAny(named: 'data'),
                options: any(named: 'options'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(captured['grant_type'], 'refresh_token');
    expect(captured['refresh_token'], 'refresh-1');
  });

  test('fetchProfile calls /api/user/me and parses typed profile', () async {
    when(
      () =>
          dio.get<Map<String, dynamic>>(any(), options: any(named: 'options')),
    ).thenAnswer(
      (_) async => _ok({
        'token': 'user-token-1',
        'name': 'Ana',
        'email': 'ana@vanep.com.br',
        'phone': '11999999999',
        'document': '12345678901',
        'birthDate': '1990-05-15',
        'gender': 'FEMALE',
        'type': 'DRIVER',
      }),
    );

    final profile = await remote.fetchProfile('access-1');

    expect(profile.token, 'user-token-1');
    expect(profile.phone, '11999999999');
    expect(profile.document, '12345678901');
    expect(profile.birthDate, '1990-05-15');
    expect(profile.gender, Gender.female);
    expect(profile.type, UserType.driver);
    expect(
      testEnvironment.userProfileEndpoint,
      'http://10.0.2.2:8080/api/user/me',
    );
    final options =
        verify(
              () => dio.get<Map<String, dynamic>>(
                testEnvironment.userProfileEndpoint,
                options: captureAny(named: 'options'),
              ),
            ).captured.single
            as Options;
    expect(options.headers!['Authorization'], 'Bearer access-1');
  });

  test('revoke posts the token with its hint', () async {
    when(
      () => dio.post<void>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async =>
          Response<void>(requestOptions: RequestOptions(), statusCode: 200),
    );

    await remote.revoke('refresh-1', 'refresh_token');

    final captured =
        verify(
              () => dio.post<void>(
                testEnvironment.revocationEndpoint,
                data: captureAny(named: 'data'),
                options: any(named: 'options'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(captured['token'], 'refresh-1');
    expect(captured['token_type_hint'], 'refresh_token');
  });
}
