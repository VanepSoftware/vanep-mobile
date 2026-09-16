import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/resend_email_verification_code.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/verify_email_code.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';

import '../../auth_mocks.dart';

void main() {
  late MockAccountRepository repository;

  setUp(() => repository = MockAccountRepository());

  test(
    'VerifyEmailCode sends the trimmed e-mail and the code digits',
    () async {
      when(
        () => repository.verifyEmail(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenAnswer((_) async => const Ok<AccountFailure, void>(null));

      final result = await VerifyEmailCode(repository)(
        email: ' ana@vanep.com.br ',
        code: '012 345',
      );

      expect(result.isOk, isTrue);
      verify(
        () => repository.verifyEmail(email: 'ana@vanep.com.br', code: '012345'),
      ).called(1);
    },
  );

  test('VerifyEmailCode rejects a code without 6 digits locally', () async {
    final result = await VerifyEmailCode(repository)(
      email: 'ana@vanep.com.br',
      code: '12345',
    );

    expect(
      result.errorOrNull,
      const AccountValidationFailure({
        AccountField.code: AccountFieldIssue.invalid,
      }),
    );
    verifyNever(
      () => repository.verifyEmail(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    );
  });

  test(
    'ResendEmailVerificationCode delegates with the trimmed e-mail',
    () async {
      when(
        () => repository.resendEmailVerification(any()),
      ).thenAnswer((_) async => const Ok<AccountFailure, void>(null));

      await ResendEmailVerificationCode(repository)(' ana@vanep.com.br ');

      verify(
        () => repository.resendEmailVerification('ana@vanep.com.br'),
      ).called(1);
    },
  );
}
