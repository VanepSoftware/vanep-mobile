import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations_pt.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/presentation/mappers/account_failure_l10n.dart';

void main() {
  final l10n = AppLocalizationsPt();

  test('field issue messages depend on the field when it matters', () {
    expect(
      accountFieldIssueMessage(
        l10n,
        AccountField.password,
        AccountFieldIssue.tooShort,
      ),
      'A senha deve ter ao menos 6 caracteres.',
    );
    expect(
      accountFieldIssueMessage(
        l10n,
        AccountField.document,
        AccountFieldIssue.duplicate,
      ),
      'Já existe uma conta com este CPF.',
    );
    expect(
      accountFieldIssueMessage(
        l10n,
        AccountField.experienceYears,
        AccountFieldIssue.invalid,
      ),
      'Informe um número válido.',
    );
    expect(
      accountFieldIssueMessage(
        l10n,
        AccountField.name,
        AccountFieldIssue.rejected,
      ),
      'Confira este campo.',
    );
  });

  test('every failure has a message', () {
    const failures = <AccountFailure>[
      AccountValidationFailure({}),
      InvalidCodeAccountFailure(),
      InvalidSignupTicketAccountFailure(),
      TooManyRequestsAccountFailure(),
      NetworkAccountFailure(),
      UnexpectedAccountFailure(),
    ];

    for (final failure in failures) {
      expect(accountFailureMessage(l10n, failure), isNotEmpty);
    }
  });
}
