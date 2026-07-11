import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
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

  final session = FakeAuthSession();

  setUpAll(registerAuthFallbacks);

  setUp(() {
    getCurrentSession = MockGetCurrentSession();
    buildAuthorizationRequest = MockBuildAuthorizationRequest();
    exchangeAuthorizationCode = MockExchangeAuthorizationCode();
    signOut = MockSignOut();
  });

  AuthCubit buildCubit() => AuthCubit(
        getCurrentSession: getCurrentSession,
        buildAuthorizationRequest: buildAuthorizationRequest,
        exchangeAuthorizationCode: exchangeAuthorizationCode,
        signOut: signOut,
      );

  group('checkSession', () {
    blocTest<AuthCubit, AuthState>(
      'emits authenticated when a session is restored',
      setUp: () => when(getCurrentSession.call).thenAnswer(
        (_) async => Ok<AuthFailure, AuthSession?>(session),
      ),
      build: buildCubit,
      act: (cubit) => cubit.checkSession(),
      expect: () => [const AuthUnknown(), AuthAuthenticated(session)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits unauthenticated when there is no session',
      setUp: () => when(getCurrentSession.call).thenAnswer(
        (_) async => const Ok<AuthFailure, AuthSession?>(null),
      ),
      build: buildCubit,
      act: (cubit) => cubit.checkSession(),
      expect: () => [const AuthUnknown(), const AuthUnauthenticated()],
    );
  });

  blocTest<AuthCubit, AuthState>(
    'startLogin emits AuthAuthenticating with the built request',
    setUp: () => when(buildAuthorizationRequest.call)
        .thenReturn(fakeAuthorizationRequest),
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
      setUp: () => when(
        () => exchangeAuthorizationCode(
          code: any(named: 'code'),
          request: any(named: 'request'),
        ),
      ).thenAnswer(
        (_) async => const Err<AuthFailure, AuthSession>(NetworkAuthFailure()),
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
    setUp: () => when(signOut.call).thenAnswer(
      (_) async => const Ok<AuthFailure, void>(null),
    ),
    build: buildCubit,
    act: (cubit) => cubit.signOut(),
    expect: () => [const AuthUnauthenticated()],
  );
}
