import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/data/datasources/google_id_token_source.dart';
import 'package:vanep_mobile/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/auth_session_dto.dart';
import 'package:vanep_mobile/modules/auth/data/dtos/user_profile_dto.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
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
  late MockGoogleIdTokenSource googleIdTokens;
  late AuthRepositoryImpl repository;

  final fixedNow = DateTime.utc(2026, 7, 11, 12);

  setUpAll(registerAuthDataFallbacks);

  setUp(() {
    remote = MockOAuthRemoteDataSource();
    profileRemote = MockUserProfileRemoteDataSource();
    local = MockAuthLocalDataSource();
    googleIdTokens = MockGoogleIdTokenSource();
    repository = AuthRepositoryImpl(
      remote: remote,
      profileRemote: profileRemote,
      local: local,
      googleIdTokens: googleIdTokens,
      clock: () => fixedNow,
    );
  });

  group('signInWithPassword', () {
    void stubPasswordGrant() {
      when(
        () => remote.requestPasswordGrant(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => testTokenResponseDto);
    }

    test(
      'requests the grant, fetches the profile and saves the session',
      () async {
        stubPasswordGrant();
        when(
          () => remote.fetchProfile(any()),
        ).thenAnswer((_) async => testUserProfileDto);
        when(
          () => local.saveSession(any()),
        ).thenAnswer((_) => Future<void>.value());

        final result = await repository.signInWithPassword(
          email: 'ana@vanep.com.br',
          password: 'secret1',
        );

        final session = result.valueOrNull!;
        expect(session.refreshToken, 'refresh-1');
        expect(session.expiresAt, fixedNow.add(const Duration(seconds: 900)));
        verify(() => remote.fetchProfile('access-1')).called(1);
        verify(() => local.saveSession(any())).called(1);
      },
    );

    test('maps an OAuth error body to a typed failure', () async {
      when(
        () => remote.requestPasswordGrant(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(_invalidGrantError());

      final result = await repository.signInWithPassword(
        email: 'ana@vanep.com.br',
        password: 'wrong',
      );

      expect(result.errorOrNull, const InvalidCredentialsAuthFailure());
      verifyNever(() => local.saveSession(any()));
    });

    test('a failing profile fetch is a network failure', () async {
      stubPasswordGrant();
      when(() => remote.fetchProfile(any())).thenThrow(_dioError());

      final result = await repository.signInWithPassword(
        email: 'ana@vanep.com.br',
        password: 'secret1',
      );

      expect(result.errorOrNull, const NetworkAuthFailure('boom'));
      verifyNever(() => local.saveSession(any()));
    });
  });

  group('signInWithGoogle', () {
    test('sends the Google ID token and starts the session', () async {
      when(
        googleIdTokens.requestIdToken,
      ).thenAnswer((_) async => 'google-id-token');
      when(
        () => remote.requestGoogleGrant(any()),
      ).thenAnswer((_) async => testTokenResponseDto);
      when(
        () => remote.fetchProfile(any()),
      ).thenAnswer((_) async => testUserProfileDto);
      when(
        () => local.saveSession(any()),
      ).thenAnswer((_) => Future<void>.value());

      final result = await repository.signInWithGoogle();

      expect(result.valueOrNull?.accessToken, 'access-1');
      verify(() => remote.requestGoogleGrant('google-id-token')).called(1);
    });

    test('a dismissed chooser is a cancelled failure', () async {
      when(googleIdTokens.requestIdToken).thenAnswer((_) async => null);

      final result = await repository.signInWithGoogle();

      expect(result.errorOrNull, const CancelledAuthFailure());
      verifyNever(() => remote.requestGoogleGrant(any()));
    });

    test('an SDK error is a Google sign-in failure', () async {
      when(
        googleIdTokens.requestIdToken,
      ).thenThrow(const GoogleIdTokenException('clientConfigurationError'));

      final result = await repository.signInWithGoogle();

      expect(
        result.errorOrNull,
        const GoogleSignInAuthFailure('clientConfigurationError'),
      );
    });

    test('a new Google user gets the registration ticket', () async {
      when(
        googleIdTokens.requestIdToken,
      ).thenAnswer((_) async => 'google-id-token');
      final options = RequestOptions(path: '/oauth2/token');
      when(() => remote.requestGoogleGrant(any())).thenThrow(
        DioException(
          requestOptions: options,
          response: Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 400,
            data: const {
              'error': 'registration_required',
              'signup_ticket': 'ticket-1',
              'email': 'novo@gmail.com',
              'name': 'Novo',
            },
          ),
        ),
      );

      final result = await repository.signInWithGoogle();

      expect(result.errorOrNull, isA<RegistrationRequiredAuthFailure>());
      verifyNever(() => local.saveSession(any()));
    });
  });

  group('currentSession', () {
    test('returns null when nothing is stored', () async {
      when(local.readSession).thenAnswer((_) async => null);

      final result = await repository.currentSession();

      expect(result.valueOrNull, isNull);
    });

    test('returns the stored session when still valid', () async {
      final valid = testAuthSessionDto(
        expiresAt: fixedNow.add(const Duration(minutes: 10)),
      );
      when(local.readSession).thenAnswer((_) async => valid);

      final result = await repository.currentSession();

      expect(result.valueOrNull, valid);
      verifyNever(() => remote.refresh(any()));
    });

    test('refreshes and persists when the access token expired', () async {
      final expired = testAuthSessionDto(
        expiresAt: fixedNow.subtract(const Duration(minutes: 1)),
      );
      when(local.readSession).thenAnswer((_) async => expired);
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
      when(local.readSession).thenAnswer((_) async => expired);
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
      when(local.readSession).thenAnswer((_) async => expired);
      when(() => remote.refresh(any())).thenThrow(_dioError());

      final result = await repository.currentSession();

      expect(result.isOk, isTrue);
      expect(result.valueOrNull, expired);
      verifyNever(local.clearSession);
    });
  });

  group('refreshSession', () {
    test('renews even when the stored expiry still looks valid', () async {
      final unexpired = testAuthSessionDto(
        expiresAt: fixedNow.add(const Duration(minutes: 10)),
      );
      when(local.readSession).thenAnswer((_) async => unexpired);
      when(() => remote.refresh(any())).thenAnswer(
        (_) async => testTokenResponseDto.copyWith(accessToken: 'access-2'),
      );
      when(
        () => local.saveSession(any()),
      ).thenAnswer((_) => Future<void>.value());

      final result = await repository.refreshSession();

      expect(result.valueOrNull!.accessToken, 'access-2');
      verify(() => remote.refresh('refresh-1')).called(1);
    });

    test('spends the refresh token once for concurrent callers', () async {
      final expired = testAuthSessionDto(
        expiresAt: fixedNow.subtract(const Duration(minutes: 1)),
      );
      when(local.readSession).thenAnswer((_) async => expired);
      when(() => remote.refresh(any())).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return testTokenResponseDto.copyWith(
          accessToken: 'access-2',
          refreshToken: 'refresh-2',
        );
      });
      when(
        () => local.saveSession(any()),
      ).thenAnswer((_) => Future<void>.value());

      final results = await Future.wait([
        repository.refreshSession(),
        repository.refreshSession(),
        repository.refreshSession(),
      ]);

      verify(() => remote.refresh('refresh-1')).called(1);
      for (final result in results) {
        expect(result.valueOrNull!.accessToken, 'access-2');
      }
    });

    test('starts a new exchange after the previous one settled', () async {
      final expired = testAuthSessionDto(
        expiresAt: fixedNow.subtract(const Duration(minutes: 1)),
      );
      when(local.readSession).thenAnswer((_) async => expired);
      when(() => remote.refresh(any())).thenAnswer(
        (_) async => testTokenResponseDto.copyWith(accessToken: 'access-2'),
      );
      when(
        () => local.saveSession(any()),
      ).thenAnswer((_) => Future<void>.value());

      await repository.refreshSession();
      await repository.refreshSession();

      verify(() => remote.refresh('refresh-1')).called(2);
    });
  });

  group('signOut', () {
    test(
      'revokes both tokens, clears the local session and signs out of Google',
      () async {
        when(local.readSession).thenAnswer((_) async => testAuthSessionDto());
        when(
          () => remote.revoke(any(), any()),
        ).thenAnswer((_) => Future<void>.value());
        when(local.clearSession).thenAnswer((_) => Future<void>.value());
        when(googleIdTokens.signOut).thenAnswer((_) => Future<void>.value());

        final result = await repository.signOut();

        expect(result.isOk, isTrue);
        verify(() => remote.revoke('refresh-1', 'refresh_token')).called(1);
        verify(() => remote.revoke('access-1', 'access_token')).called(1);
        verify(local.clearSession).called(1);
        verify(googleIdTokens.signOut).called(1);
      },
    );

    test('signs out of Google even when there is no stored session', () async {
      when(local.readSession).thenAnswer((_) async => null);
      when(local.clearSession).thenAnswer((_) => Future<void>.value());
      when(googleIdTokens.signOut).thenAnswer((_) => Future<void>.value());

      final result = await repository.signOut();

      expect(result.isOk, isTrue);
      verifyNever(() => remote.revoke(any(), any()));
      verify(googleIdTokens.signOut).called(1);
    });
  });

  group('refreshUserProfile', () {
    test('fetches me, persists profile and returns it', () async {
      when(local.readSession).thenAnswer((_) async => testAuthSessionDto());
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
      when(local.readSession).thenAnswer((_) async => null);

      final result = await repository.refreshUserProfile();

      expect(result.errorOrNull, isA<UnexpectedProfileEditFailure>());
      verifyNever(profileRemote.fetchMe);
    });

    test('keeps tokens refreshed while the profile was loading', () async {
      final before = testAuthSessionDto();
      final rotated = testAuthSessionDto().copyWith(
        accessToken: 'access-2',
        refreshToken: 'refresh-2',
      );
      var readCount = 0;
      when(local.readSession).thenAnswer((_) async {
        readCount += 1;
        return readCount == 1 ? before : rotated;
      });
      when(profileRemote.fetchMe).thenAnswer((_) async => testUserProfileDto);
      final saved = <AuthSessionDto>[];
      when(() => local.saveSession(any())).thenAnswer((invocation) async {
        saved.add(invocation.positionalArguments.first as AuthSessionDto);
      });

      await repository.refreshUserProfile();

      expect(saved.single.accessToken, 'access-2');
      expect(saved.single.refreshToken, 'refresh-2');
    });
  });

  group('patchUserProfile', () {
    test(
      'patches with touched fields only and persists body profile',
      () async {
        when(local.readSession).thenAnswer((_) async => testAuthSessionDto());
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
      },
    );

    test('maps structured 409 cooldown from dio', () async {
      when(local.readSession).thenAnswer((_) async => testAuthSessionDto());
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
      when(local.readSession).thenAnswer((_) async => testAuthSessionDto());
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
      when(local.readSession).thenAnswer((_) async => testAuthSessionDto());
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
