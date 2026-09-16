import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/code_resend_cooldown.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/email_code_verification_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/password_reset_state.dart';

import 'auth_presentation_mocks.dart';

void main() {
  late MockRequestPasswordReset requestPasswordReset;
  late MockResetPasswordWithCode resetPasswordWithCode;

  const emailStep = PasswordResetState(email: 'ana@vanep.com.br');
  const codeStep = PasswordResetState(
    email: 'ana@vanep.com.br',
    step: PasswordResetStep.code,
    code: '123456',
    newPassword: 'nova-senha',
  );

  setUp(() {
    requestPasswordReset = MockRequestPasswordReset();
    resetPasswordWithCode = MockResetPasswordWithCode();
  });

  PasswordResetCubit buildCubit() => PasswordResetCubit(
    requestPasswordReset: requestPasswordReset,
    resetPasswordWithCode: resetPasswordWithCode,
    cooldown: CodeResendCooldown(seconds: 30),
    initialEmail: 'ana@vanep.com.br',
  );

  void stubRequest(Result<AccountFailure, void> result) {
    when(() => requestPasswordReset(any())).thenAnswer((_) async => result);
  }

  void stubReset(Result<AccountFailure, void> result) {
    when(
      () => resetPasswordWithCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
        newPassword: any(named: 'newPassword'),
      ),
    ).thenAnswer((_) async => result);
  }

  test('starts on the e-mail step with the e-mail typed on login', () {
    expect(buildCubit().state, emailStep);
  });

  blocTest<PasswordResetCubit, PasswordResetState>(
    'requesting a code moves to the code step and starts the cooldown',
    setUp: () => stubRequest(const Ok(null)),
    build: buildCubit,
    act: (cubit) => cubit.requestCode(),
    expect: () => [
      emailStep.copyWith(status: PasswordResetStatus.submitting),
      emailStep.copyWith(step: PasswordResetStep.code),
      emailStep.copyWith(step: PasswordResetStep.code, resendSecondsLeft: 30),
    ],
  );

  blocTest<PasswordResetCubit, PasswordResetState>(
    'an invalid e-mail stays on the e-mail step with the issue',
    setUp: () => stubRequest(
      const Err(
        AccountValidationFailure({
          AccountField.email: AccountFieldIssue.invalid,
        }),
      ),
    ),
    build: buildCubit,
    act: (cubit) => cubit.requestCode(),
    expect: () => [
      emailStep.copyWith(status: PasswordResetStatus.submitting),
      emailStep.copyWith(
        issues: const {AccountField.email: AccountFieldIssue.invalid},
      ),
    ],
  );

  blocTest<PasswordResetCubit, PasswordResetState>(
    'typing clears the issue of the edited field',
    build: buildCubit,
    seed: () => codeStep.copyWith(
      issues: const {
        AccountField.code: AccountFieldIssue.invalid,
        AccountField.password: AccountFieldIssue.tooShort,
      },
    ),
    act: (cubit) => cubit
      ..updateCode('65a4321')
      ..updateNewPassword('outra-senha'),
    expect: () => [
      codeStep.copyWith(
        code: '654321',
        issues: const {AccountField.password: AccountFieldIssue.tooShort},
      ),
      codeStep.copyWith(code: '654321', newPassword: 'outra-senha'),
    ],
  );

  blocTest<PasswordResetCubit, PasswordResetState>(
    'resetting with the right code completes',
    setUp: () => stubReset(const Ok(null)),
    build: buildCubit,
    seed: () => codeStep,
    act: (cubit) => cubit.resetPassword(),
    expect: () => [
      codeStep.copyWith(status: PasswordResetStatus.submitting),
      codeStep.copyWith(status: PasswordResetStatus.completed),
    ],
    verify: (_) => verify(
      () => resetPasswordWithCode(
        email: 'ana@vanep.com.br',
        code: '123456',
        newPassword: 'nova-senha',
      ),
    ).called(1),
  );

  blocTest<PasswordResetCubit, PasswordResetState>(
    'an invalid code becomes feedback',
    setUp: () => stubReset(const Err(InvalidCodeAccountFailure())),
    build: buildCubit,
    seed: () => codeStep,
    act: (cubit) => cubit.resetPassword(),
    expect: () => [
      codeStep.copyWith(status: PasswordResetStatus.submitting),
      codeStep.copyWith(
        feedback: const AccountFailureCodeFeedback(InvalidCodeAccountFailure()),
      ),
    ],
  );

  blocTest<PasswordResetCubit, PasswordResetState>(
    'resend asks for a new code and restarts the cooldown',
    setUp: () => stubRequest(const Ok(null)),
    build: buildCubit,
    seed: () => codeStep,
    act: (cubit) => cubit.resend(),
    expect: () => [
      codeStep.copyWith(status: PasswordResetStatus.submitting),
      codeStep.copyWith(feedback: const CodeResentFeedback()),
      codeStep.copyWith(
        feedback: const CodeResentFeedback(),
        resendSecondsLeft: 30,
      ),
    ],
  );

  blocTest<PasswordResetCubit, PasswordResetState>(
    'resend waits for the cooldown',
    build: buildCubit,
    seed: () => codeStep.copyWith(resendSecondsLeft: 5),
    act: (cubit) => cubit.resend(),
    expect: () => <PasswordResetState>[],
  );

  blocTest<PasswordResetCubit, PasswordResetState>(
    'clearFeedback removes the shown feedback',
    build: buildCubit,
    seed: () => codeStep.copyWith(feedback: const CodeResentFeedback()),
    act: (cubit) => cubit.clearFeedback(),
    expect: () => [codeStep],
  );
}
