import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_state.dart';

import '../auth_fixtures.dart';
import 'auth_presentation_mocks.dart';

void main() {
  late MockSignInWithPassword signInWithPassword;
  late List<AuthSession> startedSessions;

  final session = FakeAuthSession();
  const filled = LoginState(email: 'ana@vanep.com.br', password: 'secret1');

  setUp(() {
    signInWithPassword = MockSignInWithPassword();
    startedSessions = [];
  });

  LoginCubit buildCubit() => LoginCubit(
    signInWithPassword: signInWithPassword,
    startSession: startedSessions.add,
  );

  void stubSignIn(Result<AuthFailure, AuthSession> result) {
    when(
      () => signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => result);
  }

  blocTest<LoginCubit, LoginState>(
    'typing updates the draft and clears the last failure',
    build: buildCubit,
    seed: () => const LoginState(failure: InvalidCredentialsAuthFailure()),
    act: (cubit) => cubit
      ..updateEmail('ana@vanep.com.br')
      ..updatePassword('secret1'),
    expect: () => [const LoginState(email: 'ana@vanep.com.br'), filled],
  );

  test('canSubmit needs an e-mail and a password', () {
    expect(const LoginState().canSubmit, isFalse);
    expect(const LoginState(email: 'a@b.c').canSubmit, isFalse);
    expect(filled.canSubmit, isTrue);
    expect(filled.copyWith(status: LoginStatus.submitting).canSubmit, isFalse);
  });

  blocTest<LoginCubit, LoginState>(
    'submitPassword hands the session to the app on success',
    setUp: () => stubSignIn(Ok(session)),
    build: buildCubit,
    seed: () => filled,
    act: (cubit) => cubit.submitPassword(),
    expect: () => [filled.copyWith(status: LoginStatus.submitting), filled],
    verify: (_) {
      expect(startedSessions, [session]);
      verify(
        () =>
            signInWithPassword(email: 'ana@vanep.com.br', password: 'secret1'),
      ).called(1);
    },
  );

  blocTest<LoginCubit, LoginState>(
    'submitPassword keeps the draft and exposes the failure',
    setUp: () => stubSignIn(const Err(AccountLockedAuthFailure())),
    build: buildCubit,
    seed: () => filled,
    act: (cubit) => cubit.submitPassword(),
    expect: () => [
      filled.copyWith(status: LoginStatus.submitting),
      filled.copyWith(failure: const AccountLockedAuthFailure()),
    ],
    verify: (_) => expect(startedSessions, isEmpty),
  );

  blocTest<LoginCubit, LoginState>(
    'submitPassword does nothing while the form is incomplete',
    build: buildCubit,
    act: (cubit) => cubit.submitPassword(),
    expect: () => <LoginState>[],
    verify: (_) => verifyNever(
      () => signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ),
  );

  blocTest<LoginCubit, LoginState>(
    'clearFailure removes the failure once shown',
    build: buildCubit,
    seed: () => filled.copyWith(failure: const NetworkAuthFailure()),
    act: (cubit) => cubit.clearFailure(),
    expect: () => [filled],
  );
}
