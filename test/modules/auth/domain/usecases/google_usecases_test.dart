import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/complete_google_signup.dart';
import 'package:vanep_mobile/modules/auth/domain/usecases/sign_in_with_google.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';

import '../../account_fixtures.dart';
import '../../auth_fixtures.dart';
import '../../auth_mocks.dart';

void main() {
  setUpAll(registerAuthFallbacks);

  test('SignInWithGoogle delegates to the auth repository', () async {
    final repository = MockAuthRepository();
    final session = FakeAuthSession();
    when(
      repository.signInWithGoogle,
    ).thenAnswer((_) async => Ok<AuthFailure, AuthSession>(session));

    final result = await SignInWithGoogle(repository)();

    expect(result.valueOrNull, session);
  });

  group('CompleteGoogleSignup', () {
    late MockAccountRepository repository;

    setUp(() => repository = MockAccountRepository());

    test('does not require name, e-mail or password', () async {
      when(
        () => repository.completeGoogleSignup(
          ticket: any(named: 'ticket'),
          form: any(named: 'form'),
        ),
      ).thenAnswer((_) async => const Ok<AccountFailure, void>(null));
      final form = validClientSignupForm.copyWith(
        name: '',
        email: '',
        password: '',
      );

      final result = await CompleteGoogleSignup(repository)(
        ticket: 'ticket-1',
        form: form,
      );

      expect(result.isOk, isTrue);
      verify(
        () => repository.completeGoogleSignup(ticket: 'ticket-1', form: form),
      ).called(1);
    });

    test('still validates the profile fields locally', () async {
      final form = validClientSignupForm.copyWith(document: '123');

      final result = await CompleteGoogleSignup(repository)(
        ticket: 'ticket-1',
        form: form,
      );

      expect(
        result.errorOrNull,
        const AccountValidationFailure({
          AccountField.document: AccountFieldIssue.invalid,
        }),
      );
    });
  });
}
