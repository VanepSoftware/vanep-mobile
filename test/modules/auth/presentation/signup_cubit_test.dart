import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_state.dart';

import '../account_fixtures.dart';
import '../auth_mocks.dart';
import 'auth_presentation_mocks.dart';

void main() {
  late MockSignUp signUp;

  final filled = SignupState(form: validClientSignupForm);

  setUpAll(registerAuthFallbacks);

  setUp(() => signUp = MockSignUp());

  SignupCubit buildCubit() =>
      SignupCubit(signUp: signUp, type: UserType.client);

  void stubSignUp(Result<AccountFailure, void> result) {
    when(() => signUp(any())).thenAnswer((_) async => result);
  }

  test('starts with an empty form of the chosen type', () {
    expect(
      buildCubit().state,
      const SignupState(form: SignupForm(type: UserType.client)),
    );
  });

  blocTest<SignupCubit, SignupState>(
    'editing a field updates the form and clears only that issue',
    build: buildCubit,
    seed: () => const SignupState(
      form: SignupForm(type: UserType.client),
      issues: {
        AccountField.name: AccountFieldIssue.required,
        AccountField.document: AccountFieldIssue.invalid,
      },
    ),
    act: (cubit) => cubit.updateName('Ana'),
    expect: () => [
      const SignupState(
        form: SignupForm(type: UserType.client, name: 'Ana'),
        issues: {AccountField.document: AccountFieldIssue.invalid},
      ),
    ],
  );

  blocTest<SignupCubit, SignupState>(
    'every field has its own update',
    build: buildCubit,
    act: (cubit) => cubit
      ..updateEmail('ana@vanep.com.br')
      ..updatePassword('secret1')
      ..updateDocument(validCpf)
      ..updatePhone('(11) 99999-0000')
      ..updateBirthDate(DateTime(1990, 5, 15))
      ..updateGender(Gender.female)
      ..updateAcceptTerms(true)
      ..updateBasePrice('100')
      ..updateCnpj('11222333000181')
      ..updateExperienceYears('3'),
    verify: (cubit) => expect(
      cubit.state.form,
      SignupForm(
        type: UserType.client,
        email: 'ana@vanep.com.br',
        password: 'secret1',
        document: validCpf,
        phone: '(11) 99999-0000',
        birthDate: DateTime(1990, 5, 15),
        gender: Gender.female,
        acceptTerms: true,
        basePrice: '100',
        cnpj: '11222333000181',
        experienceYears: '3',
      ),
    ),
  );

  blocTest<SignupCubit, SignupState>(
    'submit completes when the account is created',
    setUp: () => stubSignUp(const Ok(null)),
    build: buildCubit,
    seed: () => filled,
    act: (cubit) => cubit.submit(),
    expect: () => [
      filled.copyWith(status: SignupStatus.submitting),
      filled.copyWith(status: SignupStatus.completed),
    ],
    verify: (_) => verify(() => signUp(validClientSignupForm)).called(1),
  );

  blocTest<SignupCubit, SignupState>(
    'field issues from validation or duplicates go to the fields',
    setUp: () => stubSignUp(
      const Err(
        AccountValidationFailure({
          AccountField.email: AccountFieldIssue.duplicate,
        }),
      ),
    ),
    build: buildCubit,
    seed: () => filled,
    act: (cubit) => cubit.submit(),
    expect: () => [
      filled.copyWith(status: SignupStatus.submitting),
      filled.copyWith(
        issues: const {AccountField.email: AccountFieldIssue.duplicate},
      ),
    ],
  );

  blocTest<SignupCubit, SignupState>(
    'failures without fields become feedback',
    setUp: () => stubSignUp(const Err(NetworkAccountFailure())),
    build: buildCubit,
    seed: () => filled,
    act: (cubit) => cubit.submit(),
    expect: () => [
      filled.copyWith(status: SignupStatus.submitting),
      filled.copyWith(failure: const NetworkAccountFailure()),
    ],
  );

  blocTest<SignupCubit, SignupState>(
    'a validation failure without known fields becomes feedback',
    setUp: () => stubSignUp(const Err(AccountValidationFailure({}))),
    build: buildCubit,
    seed: () => filled,
    act: (cubit) => cubit.submit(),
    expect: () => [
      filled.copyWith(status: SignupStatus.submitting),
      filled.copyWith(failure: const AccountValidationFailure({})),
    ],
  );

  blocTest<SignupCubit, SignupState>(
    'submit is ignored while a request is running',
    build: buildCubit,
    seed: () => filled.copyWith(status: SignupStatus.submitting),
    act: (cubit) => cubit.submit(),
    expect: () => <SignupState>[],
  );

  blocTest<SignupCubit, SignupState>(
    'clearFailure removes the shown failure',
    build: buildCubit,
    seed: () => filled.copyWith(failure: const NetworkAccountFailure()),
    act: (cubit) => cubit.clearFailure(),
    expect: () => [filled],
  );
}
