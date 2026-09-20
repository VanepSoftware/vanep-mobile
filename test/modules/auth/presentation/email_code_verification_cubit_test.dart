import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/code_resend_cooldown.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/email_code_verification_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/email_code_verification_state.dart';

import '../auth_fixtures.dart';
import 'auth_presentation_mocks.dart';

void main() {
  late MockVerifyEmailCode verifyEmailCode;
  late MockResendEmailVerificationCode resendCode;
  late MockSignInWithPassword signInWithPassword;
  late List<AuthSession> startedSessions;

  final session = FakeAuthSession();
  const initial = EmailCodeVerificationState(
    email: 'ana@vanep.com.br',
    password: 'secret1',
  );
  final typed = initial.copyWith(code: '123456');

  setUp(() {
    verifyEmailCode = MockVerifyEmailCode();
    resendCode = MockResendEmailVerificationCode();
    signInWithPassword = MockSignInWithPassword();
    startedSessions = [];
  });

  EmailCodeVerificationCubit buildCubit() => EmailCodeVerificationCubit(
    verifyEmailCode: verifyEmailCode,
    resendCode: resendCode,
    signInWithPassword: signInWithPassword,
    startSession: startedSessions.add,
    cooldown: CodeResendCooldown(seconds: 30),
    email: 'ana@vanep.com.br',
    password: 'secret1',
    codeAlreadySent: true,
  );

  void stubVerify(Result<AccountFailure, void> result) {
    when(
      () => verifyEmailCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenAnswer((_) async => result);
  }

  void stubSignIn(Result<AuthFailure, AuthSession> result) {
    when(
      () => signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => result);
  }

  blocTest<EmailCodeVerificationCubit, EmailCodeVerificationState>(
    'updateCode keeps at most six digits',
    build: buildCubit,
    act: (cubit) => cubit.updateCode('12a3-45678'),
    expect: () => [initial.copyWith(code: '123456')],
  );

  blocTest<EmailCodeVerificationCubit, EmailCodeVerificationState>(
    'a correct code signs in with the password kept in memory',
    setUp: () {
      stubVerify(const Ok(null));
      stubSignIn(Ok(session));
    },
    build: buildCubit,
    seed: () => typed,
    act: (cubit) => cubit.verify(),
    expect: () => [
      typed.copyWith(status: EmailCodeVerificationStatus.verifying),
      typed.copyWith(status: EmailCodeVerificationStatus.signedIn),
    ],
    verify: (_) {
      expect(startedSessions, [session]);
      verify(
        () =>
            signInWithPassword(email: 'ana@vanep.com.br', password: 'secret1'),
      ).called(1);
    },
  );

  blocTest<EmailCodeVerificationCubit, EmailCodeVerificationState>(
    'a verified e-mail whose sign-in fails sends the user back to login',
    setUp: () {
      stubVerify(const Ok(null));
      stubSignIn(const Err(NetworkAuthFailure()));
    },
    build: buildCubit,
    seed: () => typed,
    act: (cubit) => cubit.verify(),
    expect: () => [
      typed.copyWith(status: EmailCodeVerificationStatus.verifying),
      typed.copyWith(status: EmailCodeVerificationStatus.verified),
    ],
    verify: (_) => expect(startedSessions, isEmpty),
  );

  blocTest<EmailCodeVerificationCubit, EmailCodeVerificationState>(
    'an invalid code becomes feedback and keeps the code editable',
    setUp: () => stubVerify(const Err(InvalidCodeAccountFailure())),
    build: buildCubit,
    seed: () => typed,
    act: (cubit) => cubit.verify(),
    expect: () => [
      typed.copyWith(status: EmailCodeVerificationStatus.verifying),
      typed.copyWith(
        feedback: const AccountFailureCodeFeedback(InvalidCodeAccountFailure()),
      ),
    ],
  );

  blocTest<EmailCodeVerificationCubit, EmailCodeVerificationState>(
    'verify waits for six digits',
    build: buildCubit,
    seed: () => initial.copyWith(code: '123'),
    act: (cubit) => cubit.verify(),
    expect: () => <EmailCodeVerificationState>[],
  );

  blocTest<EmailCodeVerificationCubit, EmailCodeVerificationState>(
    'resend sends a new code and starts the cooldown',
    setUp: () => when(
      () => resendCode(any()),
    ).thenAnswer((_) async => const Ok<AccountFailure, void>(null)),
    build: buildCubit,
    act: (cubit) => cubit.resend(),
    expect: () => [
      initial.copyWith(status: EmailCodeVerificationStatus.resending),
      initial.copyWith(feedback: const CodeResentFeedback()),
      initial.copyWith(
        feedback: const CodeResentFeedback(),
        resendSecondsLeft: 30,
      ),
    ],
    verify: (_) => verify(() => resendCode('ana@vanep.com.br')).called(1),
  );

  blocTest<EmailCodeVerificationCubit, EmailCodeVerificationState>(
    'resend is blocked during the cooldown',
    build: buildCubit,
    seed: () => initial.copyWith(resendSecondsLeft: 12),
    act: (cubit) => cubit.resend(),
    expect: () => <EmailCodeVerificationState>[],
  );

  blocTest<EmailCodeVerificationCubit, EmailCodeVerificationState>(
    'startResendCooldown publishes the remaining seconds',
    build: buildCubit,
    act: (cubit) => cubit.startResendCooldown(),
    expect: () => [initial.copyWith(resendSecondsLeft: 30)],
  );

  blocTest<EmailCodeVerificationCubit, EmailCodeVerificationState>(
    'clearFeedback removes the shown feedback',
    build: buildCubit,
    seed: () => initial.copyWith(feedback: const CodeResentFeedback()),
    act: (cubit) => cubit.clearFeedback(),
    expect: () => [initial],
  );

  group('leaving the screen while a request is in flight', () {
    late Completer<Result<AccountFailure, void>> verifyAnswer;
    late Completer<Result<AuthFailure, AuthSession>> signInAnswer;
    late Completer<Result<AccountFailure, void>> resendAnswer;

    setUp(() {
      verifyAnswer = Completer();
      signInAnswer = Completer();
      resendAnswer = Completer();
      when(
        () => verifyEmailCode(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) => verifyAnswer.future);
      when(
        () => signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => signInAnswer.future);
      when(() => resendCode(any())).thenAnswer((_) => resendAnswer.future);
    });

    EmailCodeVerificationCubit typedCubit() =>
        buildCubit()..updateCode('123456');

    test('a rejected code that arrives after leaving is ignored', () async {
      final cubit = typedCubit();

      final pending = cubit.verify();
      await cubit.close();
      verifyAnswer.complete(const Err(InvalidCodeAccountFailure()));

      await expectLater(pending, completes);
    });

    test(
      'a verified code that arrives after leaving does not sign in',
      () async {
        final cubit = typedCubit();

        final pending = cubit.verify();
        await cubit.close();
        verifyAnswer.complete(const Ok(null));
        await pending;

        verifyNever(
          () => signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
        expect(startedSessions, isEmpty);
      },
    );

    test(
      'a sign-in that ends after leaving still starts the session',
      () async {
        final cubit = typedCubit();

        final pending = cubit.verify();
        verifyAnswer.complete(const Ok(null));
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
        signInAnswer.complete(Ok(session));
        await pending;

        expect(startedSessions, [session]);
      },
    );

    test('a failed sign-in that ends after leaving is ignored', () async {
      final cubit = typedCubit();

      final pending = cubit.verify();
      verifyAnswer.complete(const Ok(null));
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
      signInAnswer.complete(const Err(NetworkAuthFailure()));

      await expectLater(pending, completes);
      expect(startedSessions, isEmpty);
    });

    test('a resend that ends after leaving is ignored', () async {
      final cubit = buildCubit();

      final pending = cubit.resend();
      await cubit.close();
      resendAnswer.complete(const Ok(null));

      await expectLater(pending, completes);
    });
  });
}
