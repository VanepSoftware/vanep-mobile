import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/pkce/pkce_generator.dart';
import 'package:vanep_mobile/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/authorization_request.dart';

import '../auth_data_mocks.dart';

DioException _dioError() => DioException(
      requestOptions: RequestOptions(path: '/oauth2/token'),
      message: 'boom',
    );

void main() {
  late MockOAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late AuthRepositoryImpl repository;

  final fixedNow = DateTime.utc(2026, 7, 11, 12);

  setUpAll(registerAuthDataFallbacks);

  setUp(() {
    remote = MockOAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remote: remote,
      local: local,
      pkce: PkceGenerator(),
      environment: testEnvironment,
      clock: () => fixedNow,
    );
  });

  group('buildAuthorizationRequest', () {
    test('builds a PKCE authorize URL with the configured client/redirect', () {
      final request = repository.buildAuthorizationRequest();
      final uri = Uri.parse(request.authorizationUrl);

      expect(uri.path, '/oauth2/authorize');
      expect(uri.queryParameters['response_type'], 'code');
      expect(uri.queryParameters['client_id'], 'vanep-mobile');
      expect(uri.queryParameters['redirect_uri'],
          'com.vanep.vanepmobile://oauth2redirect');
      expect(uri.queryParameters['scope'], 'read write');
      expect(uri.queryParameters['code_challenge_method'], 'S256');
      expect(uri.queryParameters['code_challenge'], isNotEmpty);
      expect(uri.queryParameters['state'], request.state);
      expect(request.codeVerifier, isNotEmpty);
    });
  });

  group('exchangeCode', () {
    const request = AuthorizationRequest(
      authorizationUrl: 'http://10.0.2.2:8080/oauth2/authorize',
      redirectUri: 'com.vanep.vanepmobile://oauth2redirect',
      state: 'state-1',
      codeVerifier: 'verifier-1',
    );

    test('exchanges, fetches profile, persists and returns the session',
        () async {
      when(() => remote.exchangeCode(
            code: any(named: 'code'),
            codeVerifier: any(named: 'codeVerifier'),
            redirectUri: any(named: 'redirectUri'),
          )).thenAnswer((_) async => testTokenResponseDto);
      when(() => remote.fetchProfile(any()))
          .thenAnswer((_) async => testUserProfileDto);
      when(() => local.saveSession(any()))
          .thenAnswer((_) => Future<void>.value());

      final result =
          await repository.exchangeCode(code: 'the-code', request: request);

      final session = result.valueOrNull!;
      expect(session.accessToken, 'access-1');
      expect(session.refreshToken, 'refresh-1');
      expect(session.profile.token, 'user-token-1');
      expect(session.expiresAt, fixedNow.add(const Duration(seconds: 900)));
      verify(() => local.saveSession(any())).called(1);
    });

    test('maps a Dio error to NetworkAuthFailure', () async {
      when(() => remote.exchangeCode(
            code: any(named: 'code'),
            codeVerifier: any(named: 'codeVerifier'),
            redirectUri: any(named: 'redirectUri'),
          )).thenThrow(_dioError());

      final result =
          await repository.exchangeCode(code: 'x', request: request);

      expect(result.errorOrNull, isA<NetworkAuthFailure>());
    });
  });

  group('currentSession', () {
    test('returns null when nothing is stored', () async {
      when(local.readSession).thenReturn(null);

      final result = await repository.currentSession();

      expect(result.valueOrNull, isNull);
    });

    test('returns the stored session when still valid', () async {
      final valid = testAuthSessionDto(
        expiresAt: fixedNow.add(const Duration(minutes: 10)),
      );
      when(local.readSession).thenReturn(valid);

      final result = await repository.currentSession();

      expect(result.valueOrNull, valid);
      verifyNever(() => remote.refresh(any()));
    });

    test('refreshes and persists when the access token expired', () async {
      final expired = testAuthSessionDto(
        expiresAt: fixedNow.subtract(const Duration(minutes: 1)),
      );
      when(local.readSession).thenReturn(expired);
      when(() => remote.refresh(any())).thenAnswer(
        (_) async => testTokenResponseDto.copyWith(accessToken: 'access-2'),
      );
      when(() => local.saveSession(any()))
          .thenAnswer((_) => Future<void>.value());

      final result = await repository.currentSession();

      expect(result.valueOrNull!.accessToken, 'access-2');
      verify(() => remote.refresh('refresh-1')).called(1);
      verify(() => local.saveSession(any())).called(1);
    });

    test('signs the user out when the refresh fails', () async {
      final expired = testAuthSessionDto(
        expiresAt: fixedNow.subtract(const Duration(minutes: 1)),
      );
      when(local.readSession).thenReturn(expired);
      when(() => remote.refresh(any())).thenThrow(_dioError());
      when(local.clearSession).thenAnswer((_) => Future<void>.value());

      final result = await repository.currentSession();

      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
      verify(local.clearSession).called(1);
    });
  });

  group('signOut', () {
    test('revokes both tokens and clears the local session', () async {
      when(local.readSession).thenReturn(testAuthSessionDto());
      when(() => remote.revoke(any(), any()))
          .thenAnswer((_) => Future<void>.value());
      when(local.clearSession).thenAnswer((_) => Future<void>.value());

      final result = await repository.signOut();

      expect(result.isOk, isTrue);
      verify(() => remote.revoke('refresh-1', 'refresh_token')).called(1);
      verify(() => remote.revoke('access-1', 'access_token')).called(1);
      verify(local.clearSession).called(1);
    });
  });
}
