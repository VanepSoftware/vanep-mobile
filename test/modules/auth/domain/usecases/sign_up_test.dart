import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_up.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';

import '../../account_fixtures.dart';
import '../../auth_mocks.dart';

void main() {
  late MockAccountRepository repository;

  setUpAll(registerAuthFallbacks);

  setUp(() => repository = MockAccountRepository());

  test('sends a valid form to the repository', () async {
    when(
      () => repository.signUp(any()),
    ).thenAnswer((_) async => const Ok<AccountFailure, void>(null));

    final result = await SignUp(repository)(validClientSignupForm);

    expect(result.isOk, isTrue);
    verify(() => repository.signUp(validClientSignupForm)).called(1);
  });

  test('returns the local issues without calling the API', () async {
    final form = validClientSignupForm.copyWith(acceptTerms: false);

    final result = await SignUp(repository)(form);

    expect(
      result.errorOrNull,
      const AccountValidationFailure({
        AccountField.acceptTerms: AccountFieldIssue.notAccepted,
      }),
    );
    verifyNever(() => repository.signUp(any()));
  });
}
