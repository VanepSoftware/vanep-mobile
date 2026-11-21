import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/check_signup_duplicates.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';

import '../../account_fixtures.dart';
import '../../auth_mocks.dart';

void main() {
  late MockAccountRepository repository;

  setUp(() {
    repository = MockAccountRepository();
    when(
      () => repository.checkSignupDuplicates(
        email: any(named: 'email'),
        document: any(named: 'document'),
        phone: any(named: 'phone'),
      ),
    ).thenAnswer((_) async => const Ok<AccountFailure, void>(null));
  });

  test('sends only the fields of the step, as digits', () async {
    await CheckSignupDuplicates(repository)(validClientSignupForm, {
      AccountField.document,
      AccountField.phone,
      AccountField.birthDate,
    });

    verify(
      () => repository.checkSignupDuplicates(
        document: '52998224725',
        phone: '11999990000',
      ),
    ).called(1);
  });

  test('skips the API when the step has nothing to check', () async {
    final result = await CheckSignupDuplicates(repository)(
      validClientSignupForm.copyWith(phone: ''),
      {AccountField.phone, AccountField.acceptTerms},
    );

    expect(result.isOk, isTrue);
    verifyNever(
      () => repository.checkSignupDuplicates(
        email: any(named: 'email'),
        document: any(named: 'document'),
        phone: any(named: 'phone'),
      ),
    );
  });
}
