import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/auth/domain/entities/auth_session.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/google_signup_ticket.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_steps.dart';

import '../account_fixtures.dart';
import '../auth_fixtures.dart';
import '../auth_mocks.dart';
import 'auth_presentation_mocks.dart';

void main() {
  late MockSignUp signUp;
  late MockCompleteGoogleSignup completeGoogleSignup;
  late MockSignInWithGoogle signInWithGoogle;
  late List<AuthSession> startedSessions;

  final filled = SignupState(form: validClientSignupForm);

  setUpAll(registerAuthFallbacks);

  setUp(() {
    signUp = MockSignUp();
    completeGoogleSignup = MockCompleteGoogleSignup();
    signInWithGoogle = MockSignInWithGoogle();
    startedSessions = [];
  });

  SignupCubit buildCubit({GoogleSignupTicket? googleTicket}) => SignupCubit(
    signUp: signUp,
    completeGoogleSignup: completeGoogleSignup,
    signInWithGoogle: signInWithGoogle,
    startSession: startedSessions.add,
    entry: SignupEntry(type: UserType.client, googleTicket: googleTicket),
  );

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
      ..updatePassword('Secret@1')
      ..updatePasswordConfirmation('Secret@1')
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
        password: 'Secret@1',
        passwordConfirmation: 'Secret@1',
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

  group('Google sign-up', () {
    final googleFilled = SignupState(
      form: validClientSignupForm,
      googleTicket: googleTicket,
    );
    final session = FakeAuthSession();

    void stubCompletion(Result<AccountFailure, void> result) {
      when(
        () => completeGoogleSignup(
          ticket: any(named: 'ticket'),
          form: any(named: 'form'),
        ),
      ).thenAnswer((_) async => result);
    }

    blocTest<SignupCubit, SignupState>(
      'completes with the ticket and repeats the Google grant',
      setUp: () {
        stubCompletion(const Ok(null));
        when(
          signInWithGoogle.call,
        ).thenAnswer((_) async => Ok<AuthFailure, AuthSession>(session));
      },
      build: () => buildCubit(googleTicket: googleTicket),
      seed: () => googleFilled,
      act: (cubit) => cubit.submit(),
      expect: () => [
        googleFilled.copyWith(status: SignupStatus.submitting),
        googleFilled.copyWith(status: SignupStatus.signedIn),
      ],
      verify: (_) {
        verify(
          () => completeGoogleSignup(
            ticket: 'ticket-1',
            form: validClientSignupForm,
          ),
        ).called(1);
        verifyNever(() => signUp(any()));
        expect(startedSessions, [session]);
      },
    );

    blocTest<SignupCubit, SignupState>(
      'a completed account whose grant fails goes back to login',
      setUp: () {
        stubCompletion(const Ok(null));
        when(signInWithGoogle.call).thenAnswer(
          (_) async =>
              const Err<AuthFailure, AuthSession>(CancelledAuthFailure()),
        );
      },
      build: () => buildCubit(googleTicket: googleTicket),
      seed: () => googleFilled,
      act: (cubit) => cubit.submit(),
      expect: () => [
        googleFilled.copyWith(status: SignupStatus.submitting),
        googleFilled.copyWith(status: SignupStatus.registeredWithoutSession),
      ],
    );

    blocTest<SignupCubit, SignupState>(
      'an expired ticket becomes feedback',
      setUp: () =>
          stubCompletion(const Err(InvalidSignupTicketAccountFailure())),
      build: () => buildCubit(googleTicket: googleTicket),
      seed: () => googleFilled,
      act: (cubit) => cubit.submit(),
      expect: () => [
        googleFilled.copyWith(status: SignupStatus.submitting),
        googleFilled.copyWith(
          failure: const InvalidSignupTicketAccountFailure(),
        ),
      ],
      verify: (_) => verifyNever(signInWithGoogle.call),
    );
  });

  group('steps', () {
    test('password sign-up has access, personal and confirmation steps', () {
      expect(const SignupState(form: SignupForm(type: UserType.client)).steps, [
        SignupStep.access,
        SignupStep.personal,
        SignupStep.confirmation,
      ]);
    });

    test('drivers get a professional step and Google skips access', () {
      expect(
        const SignupState(
          form: SignupForm(type: UserType.driver),
          googleTicket: googleTicket,
        ).steps,
        [SignupStep.personal, SignupStep.professional, SignupStep.confirmation],
      );
    });

    blocTest<SignupCubit, SignupState>(
      'nextStep shows only the issues of the current step',
      build: buildCubit,
      act: (cubit) => cubit
        ..updateName('Ana')
        ..nextStep(),
      verify: (cubit) {
        expect(cubit.state.stepIndex, 0);
        expect(cubit.state.issues, {
          AccountField.email: AccountFieldIssue.required,
          AccountField.password: AccountFieldIssue.required,
          AccountField.passwordConfirmation: AccountFieldIssue.required,
        });
      },
    );

    blocTest<SignupCubit, SignupState>(
      'nextStep advances when the step is valid',
      build: buildCubit,
      seed: () => SignupState(form: validClientSignupForm),
      act: (cubit) => cubit.nextStep(),
      expect: () => [SignupState(form: validClientSignupForm, stepIndex: 1)],
    );

    blocTest<SignupCubit, SignupState>(
      'nextStep keeps issues that belong to other steps',
      build: buildCubit,
      seed: () => SignupState(
        form: validClientSignupForm,
        issues: const {AccountField.document: AccountFieldIssue.duplicate},
      ),
      act: (cubit) => cubit.nextStep(),
      expect: () => [
        SignupState(
          form: validClientSignupForm,
          stepIndex: 1,
          issues: const {AccountField.document: AccountFieldIssue.duplicate},
        ),
      ],
    );

    blocTest<SignupCubit, SignupState>(
      'previousStep goes back and stops at the first step',
      build: buildCubit,
      seed: () => SignupState(form: validClientSignupForm, stepIndex: 1),
      act: (cubit) => cubit
        ..previousStep()
        ..previousStep(),
      expect: () => [SignupState(form: validClientSignupForm)],
    );

    blocTest<SignupCubit, SignupState>(
      'a rejected field sends the user back to its step',
      setUp: () => stubSignUp(
        const Err(
          AccountValidationFailure({
            AccountField.document: AccountFieldIssue.duplicate,
          }),
        ),
      ),
      build: buildCubit,
      seed: () => SignupState(form: validClientSignupForm, stepIndex: 2),
      act: (cubit) => cubit.submit(),
      expect: () => [
        SignupState(
          form: validClientSignupForm,
          stepIndex: 2,
          status: SignupStatus.submitting,
        ),
        SignupState(
          form: validClientSignupForm,
          stepIndex: 1,
          issues: const {AccountField.document: AccountFieldIssue.duplicate},
        ),
      ],
    );
  });

  group('leaving the screen during Google sign-up', () {
    final session = FakeAuthSession();
    late Completer<Result<AccountFailure, void>> completionAnswer;
    late Completer<Result<AuthFailure, AuthSession>> googleAnswer;

    setUp(() {
      completionAnswer = Completer();
      googleAnswer = Completer();
      when(
        () => completeGoogleSignup(
          ticket: any(named: 'ticket'),
          form: any(named: 'form'),
        ),
      ).thenAnswer((_) => completionAnswer.future);
      when(() => signInWithGoogle()).thenAnswer((_) => googleAnswer.future);
    });

    test('a rejection that arrives after leaving is ignored', () async {
      final cubit = buildCubit(googleTicket: googleTicket);

      final pending = cubit.submit();
      await cubit.close();
      completionAnswer.complete(const Err(InvalidSignupTicketAccountFailure()));

      await expectLater(pending, completes);
    });

    test('a completion that arrives after leaving does not reopen '
        'Google', () async {
      final cubit = buildCubit(googleTicket: googleTicket);

      final pending = cubit.submit();
      await cubit.close();
      completionAnswer.complete(const Ok(null));
      await pending;

      verifyNever(() => signInWithGoogle());
      expect(startedSessions, isEmpty);
    });

    test('a Google sign-in that ends after leaving still starts the '
        'session', () async {
      final cubit = buildCubit(googleTicket: googleTicket);

      final pending = cubit.submit();
      completionAnswer.complete(const Ok(null));
      await Future<void>.delayed(Duration.zero);
      await cubit.close();
      googleAnswer.complete(Ok(session));
      await pending;

      expect(startedSessions, [session]);
    });

    test(
      'a failed Google sign-in that ends after leaving is ignored',
      () async {
        final cubit = buildCubit(googleTicket: googleTicket);

        final pending = cubit.submit();
        completionAnswer.complete(const Ok(null));
        await Future<void>.delayed(Duration.zero);
        await cubit.close();
        googleAnswer.complete(const Err(NetworkAuthFailure()));

        await expectLater(pending, completes);
        expect(startedSessions, isEmpty);
      },
    );
  });

  group('leaving the screen during password sign-up', () {
    late Completer<Result<AccountFailure, void>> answer;

    setUp(() {
      answer = Completer();
      when(() => signUp(any())).thenAnswer((_) => answer.future);
    });

    test('a failure that arrives after leaving is ignored', () async {
      final cubit = buildCubit();

      final pending = cubit.submit();
      await cubit.close();
      answer.complete(const Err(NetworkAccountFailure()));

      await expectLater(pending, completes);
    });

    test('a success that arrives after leaving is ignored', () async {
      final cubit = buildCubit();

      final pending = cubit.submit();
      await cubit.close();
      answer.complete(const Ok(null));

      await expectLater(pending, completes);
    });
  });
}
