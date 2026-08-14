import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/pkce/pkce_generator.dart';
import 'package:vanep_mobile/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/user_profile_dto.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/authorization_request.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/profile_patch_request.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

import '../auth_data_mocks.dart';

DioException _dioError() => DioException(
  requestOptions: RequestOptions(path: '/oauth2/token'),
  message: 'boom',
);

DioException _invalidGrantError() => DioException(
  requestOptions: RequestOptions(path: '/oauth2/token'),
  response: Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: '/oauth2/token'),
    statusCode: 400,
    data: const {'error': 'invalid_grant'},
  ),
);

void main() {
  late MockOAuthRemoteDataSource remote;
  late MockUserProfileRemoteDataSource profileRemote;
  late MockAuthLocalDataSource local;
  late MockWebSessionCleaner webSession;
  late AuthRepositoryImpl repository;

  final fixedNow = DateTime.utc(2026, 7, 11, 12);

  setUpAll(registerAuthDataFallbacks);

  setUp(() {
    remote = MockOAuthRemoteDataSource();
    profileRemote = MockUserProfileRemoteDataSource();
    local = MockAuthLocalDataSource();
    webSession = MockWebSessionCleaner();
    repository = AuthRepositoryImpl(
      remote: remote,
      profileRemote: profileRemote,
      local: local,
      pkce: PkceGenerator(),
      environment: testEnvironment,
      webSession: webSession,
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
      expect(
        uri.queryParameters['redirect_uri'],
        'com.vanep.vanepmobile://oauth2redirect',
      );
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

    test(
      'exchanges, fetches profile, persists and returns the session',
      () async {
        when(
          () => remote.exchangeCode(
            code: any(named: 'code'),
            codeVerifier: any(named: 'codeVerifier'),
            redirectUri: any(named: 'redirectUri'),
          ),
        ).thenAnswer((_) async => testTokenResponseDto);
        when(
          () => remote.fetchProfile(any()),
        ).thenAnswer((_) async => testUserProfileDto);
        when(
          () => local.saveSession(any()),
        ).thenAnswer((_) => Future<void>.value());

        final result = await repository.exchangeCode(
          code: 'the-code',
          request: request,
        );

        final session = result.valueOrNull!;
        expect(session.accessToken, 'access-1');
        expect(session.refreshToken, 'refresh-1');
        expect(session.profile.token, 'user-token-1');
        expect(session.expiresAt, fixedNow.add(const Duration(seconds: 900)));
        verify(() => local.saveSession(any())).called(1);
      },
    );

    test('maps a Dio error to NetworkAuthFailure', () async {
      when(
        () => remote.exchangeCode(
          code: any(named: 'code'),
          codeVerifier: any(named: 'codeVerifier'),
          redirectUri: any(named: 'redirectUri'),
        ),
      ).thenThrow(_dioError());

      final result = await repository.exchangeCode(code: 'x', request: request);

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
      when(
        () => local.saveSession(any()),
      ).thenAnswer((_) => Future<void>.value());

      final result = await repository.currentSession();

      expect(result.valueOrNull!.accessToken, 'access-2');
      verify(() => remote.refresh('refresh-1')).called(1);
      verify(() => local.saveSession(any())).called(1);
    });

    test('signs the user out when the refresh token is rejected', () async {
      final expired = testAuthSessionDto(
        expiresAt: fixedNow.subtract(const Duration(minutes: 1)),
      );
      when(local.readSession).thenReturn(expired);
      when(() => remote.refresh(any())).thenThrow(_invalidGrantError());
      when(local.clearSession).thenAnswer((_) => Future<void>.value());

      final result = await repository.currentSession();

      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
      verify(local.clearSession).called(1);
    });

    test('keeps the session when the refresh fails transiently', () async {
      final expired = testAuthSessionDto(
        expiresAt: fixedNow.subtract(const Duration(minutes: 1)),
      );
      when(local.readSession).thenReturn(expired);
      when(() => remote.refresh(any())).thenThrow(_dioError());

      final result = await repository.currentSession();

      expect(result.isOk, isTrue);
      expect(result.valueOrNull, expired);
      verifyNever(local.clearSession);
    });
  });

  group('signOut', () {
    test(
      'revokes both tokens, clears the local session and web cookies',
      () async {
        when(local.readSession).thenReturn(testAuthSessionDto());
        when(
          () => remote.revoke(any(), any()),
        ).thenAnswer((_) => Future<void>.value());
        when(local.clearSession).thenAnswer((_) => Future<void>.value());
        when(webSession.clear).thenAnswer((_) => Future<void>.value());

        final result = await repository.signOut();

        expect(result.isOk, isTrue);
        verify(() => remote.revoke('refresh-1', 'refresh_token')).called(1);
        verify(() => remote.revoke('access-1', 'access_token')).called(1);
        verify(local.clearSession).called(1);
        verify(webSession.clear).called(1);
      },
    );

    test('clears web cookies even when there is no stored session', () async {
      when(local.readSession).thenReturn(null);
      when(local.clearSession).thenAnswer((_) => Future<void>.value());
      when(webSession.clear).thenAnswer((_) => Future<void>.value());

      final result = await repository.signOut();

      expect(result.isOk, isTrue);
      verifyNever(() => remote.revoke(any(), any()));
      verify(webSession.clear).called(1);
    });
  });

  group('refreshUserProfile', () {
    test('fetches me, persists profile and returns it', () async {
      when(local.readSession).thenReturn(testAuthSessionDto());
      const updated = UserProfileDto(
        token: 'user-token-1',
        name: 'Ana Atualizada',
        email: 'ana@vanep.com.br',
        type: UserType.driver,
        pendingEmail: 'novo@vanep.com.br',
      );
      when(profileRemote.fetchMe).thenAnswer((_) async => updated);
      when(
        () => local.saveSession(any()),
      ).thenAnswer((_) => Future<void>.value());

      final result = await repository.refreshUserProfile();

      expect(result.valueOrNull, updated);
      verify(() => local.saveSession(any())).called(1);
    });

    test('returns unexpected when there is no session', () async {
      when(local.readSession).thenReturn(null);

      final result = await repository.refreshUserProfile();

      expect(result.errorOrNull, isA<UnexpectedProfileEditFailure>());
      verifyNever(profileRemote.fetchMe);
    });
  });

  group('patchUserProfile', () {
    test('patches with touched fields only and persists body profile', () async {
      when(local.readSession).thenReturn(testAuthSessionDto());
      const updated = UserProfileDto(
        token: 'user-token-1',
        name: 'Maria Silva',
        email: 'ana@vanep.com.br',
        type: UserType.driver,
      );
      when(
        () => profileRemote.patchMe(any()),
      ).thenAnswer((_) async => updated);
      when(
        () => local.saveSession(any()),
      ).thenAnswer((_) => Future<void>.value());

      final builder = ProfilePatchRequestBuilder()..setName('Maria Silva');
      final result = await repository.patchUserProfile(builder.build());

      expect(result.valueOrNull, updated);
      final body =
          verify(() => profileRemote.patchMe(captureAny())).captured.single
              as Map<String, Object?>;
      expect(body, {'name': 'Maria Silva'});
      verifyNever(profileRemote.fetchMe);
    });

    test('maps structured 409 cooldown from dio', () async {
      when(local.readSession).thenReturn(testAuthSessionDto());
      when(() => profileRemote.patchMe(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/user/me'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/api/user/me'),
            statusCode: 409,
            data: {
              'message': 'cooldown',
              'code': 'cooldown',
              'field': 'name',
              'retryAfter': '2026-09-01T12:00:00.000Z',
            },
          ),
        ),
      );

      final result = await repository.patchUserProfile(
        (ProfilePatchRequestBuilder()..setName('X')).build(),
      );

      final failure = result.errorOrNull! as StructuredProfileEditFailure;
      expect(failure.code, ProfileErrorCode.cooldown);
      expect(failure.field, 'name');
      expect(failure.retryAfter, DateTime.parse('2026-09-01T12:00:00.000Z'));
    });
  });

  group('requestEmailChange', () {
    test('posts email change then fetches me once', () async {
      when(local.readSession).thenReturn(testAuthSessionDto());
      when(
        () => profileRemote.requestEmailChange(any()),
      ).thenAnswer((_) => Future<void>.value());
      const updated = UserProfileDto(
        token: 'user-token-1',
        email: 'ana@vanep.com.br',
        pendingEmail: 'novo@vanep.com.br',
        type: UserType.driver,
      );
      when(profileRemote.fetchMe).thenAnswer((_) async => updated);
      when(
        () => local.saveSession(any()),
      ).thenAnswer((_) => Future<void>.value());

      final result = await repository.requestEmailChange('novo@vanep.com.br');

      expect(result.valueOrNull?.pendingEmail, 'novo@vanep.com.br');
      verify(
        () => profileRemote.requestEmailChange('novo@vanep.com.br'),
      ).called(1);
      verify(profileRemote.fetchMe).called(1);
    });

    test('maps email_duplicate 409', () async {
      when(local.readSession).thenReturn(testAuthSessionDto());
      when(() => profileRemote.requestEmailChange(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/user/me/email-change'),
          response: Response<Map<String, dynamic>>(
            requestOptions: RequestOptions(path: '/api/user/me/email-change'),
            statusCode: 409,
            data: {
              'message': 'taken',
              'code': 'email_duplicate',
              'field': 'email',
            },
          ),
        ),
      );

      final result = await repository.requestEmailChange('taken@vanep.com.br');

      final failure = result.errorOrNull! as StructuredProfileEditFailure;
      expect(failure.code, ProfileErrorCode.emailDuplicate);
      expect(failure.field, 'email');
      verifyNever(profileRemote.fetchMe);
    });
  });
}
