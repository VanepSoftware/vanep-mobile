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
}
