import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/user_profile.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';

import '../auth_fixtures.dart';
import '../auth_mocks.dart';
import 'auth_presentation_mocks.dart';

void main() {
  late MockGetCurrentSession getCurrentSession;
  late MockBuildAuthorizationRequest buildAuthorizationRequest;
  late MockExchangeAuthorizationCode exchangeAuthorizationCode;
  late MockSignOut signOut;
  late MockRefreshUserProfile refreshUserProfile;

  final session = FakeAuthSession();

  setUpAll(registerAuthFallbacks);

  setUp(() {
    getCurrentSession = MockGetCurrentSession();
    buildAuthorizationRequest = MockBuildAuthorizationRequest();
    exchangeAuthorizationCode = MockExchangeAuthorizationCode();
    signOut = MockSignOut();
    refreshUserProfile = MockRefreshUserProfile();
  });

  AuthCubit buildCubit() => AuthCubit(
    getCurrentSession: getCurrentSession,
    buildAuthorizationRequest: buildAuthorizationRequest,
    exchangeAuthorizationCode: exchangeAuthorizationCode,
    signOut: signOut,
    refreshUserProfile: refreshUserProfile,
  );

  group('checkSession', () {
    blocTest<AuthCubit, AuthState>(
      'emits authenticated when a session is restored',
      setUp: () => when(
        getCurrentSession.call,
      ).thenAnswer((_) async => Ok<AuthFailure, AuthSession?>(session)),
      build: buildCubit,
      act: (cubit) => cubit.checkSession(),
      expect: () => [const AuthUnknown(), AuthAuthenticated(session)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits unauthenticated when there is no session',
      setUp: () => when(
        getCurrentSession.call,
      ).thenAnswer((_) async => const Ok<AuthFailure, AuthSession?>(null)),
      build: buildCubit,
      act: (cubit) => cubit.checkSession(),
      expect: () => [const AuthUnknown(), const AuthUnauthenticated()],
    );
  });

  blocTest<AuthCubit, AuthState>(
    'startLogin emits AuthAuthenticating with the built request',
    setUp: () => when(
      buildAuthorizationRequest.call,
    ).thenReturn(fakeAuthorizationRequest),
    build: buildCubit,
    act: (cubit) => cubit.startLogin(),
    expect: () => [AuthAuthenticating(fakeAuthorizationRequest)],
  );

  group('submitAuthorizationCode', () {
    blocTest<AuthCubit, AuthState>(
      'emits exchanging then authenticated on success',
      setUp: () => when(
        () => exchangeAuthorizationCode(
          code: any(named: 'code'),
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => Ok<AuthFailure, AuthSession>(session)),
      build: buildCubit,
      act: (cubit) =>
          cubit.submitAuthorizationCode('code', fakeAuthorizationRequest),
      expect: () => [const AuthExchanging(), AuthAuthenticated(session)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits failure then unauthenticated on error',
      setUp: () =>
          when(
            () => exchangeAuthorizationCode(
              code: any(named: 'code'),
              request: any(named: 'request'),
            ),
          ).thenAnswer(
            (_) async =>
                const Err<AuthFailure, AuthSession>(NetworkAuthFailure()),
          ),
      build: buildCubit,
      act: (cubit) =>
          cubit.submitAuthorizationCode('code', fakeAuthorizationRequest),
      expect: () => [
        const AuthExchanging(),
        const AuthFailureState(NetworkAuthFailure()),
        const AuthUnauthenticated(),
      ],
    );
  });

  blocTest<AuthCubit, AuthState>(
    'cancelLogin emits a cancelled failure then unauthenticated',
    build: buildCubit,
    act: (cubit) => cubit.cancelLogin(),
    expect: () => [
      const AuthFailureState(CancelledAuthFailure()),
      const AuthUnauthenticated(),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signOut emits unauthenticated',
    setUp: () => when(
      signOut.call,
    ).thenAnswer((_) async => const Ok<AuthFailure, void>(null)),
    build: buildCubit,
    act: (cubit) => cubit.signOut(),
    expect: () => [const AuthUnauthenticated()],
  );

  blocTest<AuthCubit, AuthState>(
    'syncProfile replaces profile on authenticated session',
    build: buildCubit,
    seed: () => AuthAuthenticated(session),
    act: (cubit) => cubit.syncProfile(
      const FakeUserProfile(name: 'Maria Silva', pendingEmail: 'n@vanep.com'),
    ),
    expect: () => [
      isA<AuthAuthenticated>().having(
        (state) => state.session.profile.name,
        'name',
        'Maria Silva',
      ),
    ],
    verify: (cubit) {
      final state = cubit.state as AuthAuthenticated;
      expect(state.session.accessToken, session.accessToken);
      expect(state.session.profile.pendingEmail, 'n@vanep.com');
    },
  );

  blocTest<AuthCubit, AuthState>(
    'syncProfile is a no-op when unauthenticated',
    build: buildCubit,
    seed: () => const AuthUnauthenticated(),
    act: (cubit) => cubit.syncProfile(const FakeUserProfile(name: 'X')),
    expect: () => <AuthState>[],
  );

  group('refreshSessionProfile', () {
    blocTest<AuthCubit, AuthState>(
      'syncs profile when refresh succeeds',
      setUp: () => when(refreshUserProfile.call).thenAnswer(
        (_) async => const Ok<ProfileEditFailure, UserProfile>(
          FakeUserProfile(name: 'Atualizado', pendingEmail: 'n@vanep.com'),
        ),
      ),
      build: buildCubit,
      seed: () => AuthAuthenticated(session),
      act: (cubit) => cubit.refreshSessionProfile(),
      expect: () => [
        isA<AuthAuthenticated>().having(
          (state) => state.session.profile.name,
          'name',
          'Atualizado',
        ),
      ],
      verify: (cubit) {
        final state = cubit.state as AuthAuthenticated;
        expect(state.session.accessToken, session.accessToken);
        expect(state.session.profile.pendingEmail, 'n@vanep.com');
      },
    );

    blocTest<AuthCubit, AuthState>(
      'soft-fails and keeps current session when refresh fails',
      setUp: () => when(refreshUserProfile.call).thenAnswer(
        (_) async => const Err<ProfileEditFailure, UserProfile>(
          NetworkProfileEditFailure('offline'),
        ),
      ),
      build: buildCubit,
      seed: () => AuthAuthenticated(session),
      act: (cubit) => cubit.refreshSessionProfile(),
      expect: () => <AuthState>[],
      verify: (cubit) {
        expect(cubit.state, AuthAuthenticated(session));
        verify(refreshUserProfile.call).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'is a no-op when unauthenticated',
      setUp: () => when(refreshUserProfile.call).thenAnswer(
        (_) async => const Ok<ProfileEditFailure, UserProfile>(
          FakeUserProfile(name: 'X'),
        ),
      ),
      build: buildCubit,
      seed: () => const AuthUnauthenticated(),
      act: (cubit) => cubit.refreshSessionProfile(),
      expect: () => <AuthState>[],
      verify: (_) {
        verifyNever(refreshUserProfile.call);
      },
    );
  });
}
