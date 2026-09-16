import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/request_password_reset.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/reset_password_with_code.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';

import '../../auth_mocks.dart';

void main() {
  late MockAccountRepository repository;

  setUp(() => repository = MockAccountRepository());

  group('RequestPasswordReset', () {
    test('sends a valid trimmed e-mail', () async {
      when(
        () => repository.requestPasswordReset(any()),
      ).thenAnswer((_) async => const Ok<AccountFailure, void>(null));

      final result = await RequestPasswordReset(repository)(
        ' ana@vanep.com.br ',
      );

      expect(result.isOk, isTrue);
      verify(
        () => repository.requestPasswordReset('ana@vanep.com.br'),
      ).called(1);
    });

    test('rejects a blank or malformed e-mail locally', () async {
      expect(
        (await RequestPasswordReset(repository)('')).errorOrNull,
        const AccountValidationFailure({
          AccountField.email: AccountFieldIssue.required,
        }),
      );
      expect(
        (await RequestPasswordReset(repository)('ana@')).errorOrNull,
        const AccountValidationFailure({
          AccountField.email: AccountFieldIssue.invalid,
        }),
      );
      verifyNever(() => repository.requestPasswordReset(any()));
    });
  });

  group('ResetPasswordWithCode', () {
    test('sends the code digits and the new password', () async {
      when(
        () => repository.resetPassword(
          email: any(named: 'email'),
          code: any(named: 'code'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => const Ok<AccountFailure, void>(null));

      final result = await ResetPasswordWithCode(repository)(
        email: 'ana@vanep.com.br',
        code: '123 456',
        newPassword: '12345678',
      );

      expect(result.isOk, isTrue);
      verify(
        () => repository.resetPassword(
          email: 'ana@vanep.com.br',
          code: '123456',
          newPassword: '12345678',
        ),
      ).called(1);
    });

    test(
      'a 7-character password and a short code are rejected locally',
      () async {
        final result = await ResetPasswordWithCode(repository)(
          email: 'ana@vanep.com.br',
          code: '123',
          newPassword: '1234567',
        );

        expect(
          result.errorOrNull,
          const AccountValidationFailure({
            AccountField.code: AccountFieldIssue.invalid,
            AccountField.password: AccountFieldIssue.tooShort,
          }),
        );
      },
    );
  });
}
