import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/domain/gender.dart';
import 'package:vanep_mobile/core/ui/vanep_gender_select.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/email_code_verification_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/email_code_verification_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/start_session.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/email_code_verification_page.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/signup_page.dart';

import '../account_fixtures.dart';
import 'auth_presentation_mocks.dart';
import 'auth_test_harness.dart';

void main() {
  late MockSignupCubit cubit;

  setUp(() {
    cubit = MockSignupCubit();
    when(() => cubit.clearFailure()).thenReturn(null);
  });

  void givenState(SignupState state, {Stream<SignupState>? changes}) {
    when(() => cubit.state).thenReturn(state);
    whenListen(
      cubit,
      changes ?? const Stream<SignupState>.empty(),
      initialState: state,
    );
  }

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget signupPage() =>
      BlocProvider<SignupCubit>.value(value: cubit, child: const SignupPage());

  testWidgets('the first step asks only for the access details', (
    tester,
  ) async {
    givenState(const SignupState(form: SignupForm(type: UserType.client)));

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Etapa 1 de 3'), findsOneWidget);
    expect(find.text('Dados de acesso'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('CPF'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Continuar'), findsOneWidget);
  });

  testWidgets('the password checklist and confirmation follow the typing', (
    tester,
  ) async {
    givenState(
      const SignupState(
        form: SignupForm(
          type: UserType.client,
          password: 'secret1',
          passwordConfirmation: 'secret2',
        ),
        issues: {
          AccountField.password: AccountFieldIssue.missingUppercase,
          AccountField.passwordConfirmation: AccountFieldIssue.mismatch,
        },
      ),
    );
    useTallScreen(tester);

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Confirmar senha'), findsOneWidget);
    expect(find.text('Mínimo de 6 caracteres'), findsOneWidget);
    expect(find.text('Uma letra maiúscula'), findsOneWidget);
    expect(find.text('Um caractere especial (ex.: ! @ # \$)'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(
      find.text('A senha não atende a todos os requisitos.'),
      findsOneWidget,
    );
    expect(find.text('As senhas não coincidem.'), findsOneWidget);
  });

  testWidgets('Continuar asks the cubit for the next step', (tester) async {
    givenState(const SignupState(form: SignupForm(type: UserType.client)));
    when(() => cubit.nextStep()).thenReturn(null);

    await tester.pumpWidget(authTestApp(signupPage()));
    await tester.tap(find.widgetWithText(FilledButton, 'Continuar'));

    verify(() => cubit.nextStep()).called(1);
  });

  testWidgets('back on a later step returns to the previous step', (
    tester,
  ) async {
    givenState(
      const SignupState(form: SignupForm(type: UserType.client), stepIndex: 1),
    );
    when(() => cubit.previousStep()).thenReturn(null);

    await tester.pumpWidget(authTestApp(signupPage()));
    final dismissed = await tester.binding.handlePopRoute();
    await tester.pump();

    expect(dismissed, isTrue);
    verify(() => cubit.previousStep()).called(1);
    expect(find.byType(SignupPage), findsOneWidget);
  });

  testWidgets('driver form asks for the driver fields', (tester) async {
    givenState(
      const SignupState(form: SignupForm(type: UserType.driver), stepIndex: 2),
    );

    useTallScreen(tester);

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Cadastro de motorista'), findsOneWidget);
    expect(find.text('Etapa 3 de 4'), findsOneWidget);
    expect(find.text('Valor base (R\$)'), findsOneWidget);
    expect(find.text('CNPJ (próprio ou da empresa)'), findsOneWidget);
  });

  testWidgets('client form has no driver fields', (tester) async {
    givenState(
      const SignupState(form: SignupForm(type: UserType.client), stepIndex: 1),
    );

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Cadastro de cliente'), findsOneWidget);
    expect(find.text('Etapa 2 de 3'), findsOneWidget);
    expect(find.text('Valor base (R\$)'), findsNothing);
  });

  testWidgets('typing the name reaches the cubit', (tester) async {
    givenState(const SignupState(form: SignupForm(type: UserType.client)));
    when(() => cubit.updateName(any())).thenReturn(null);

    await tester.pumpWidget(authTestApp(signupPage()));
    await tester.enterText(find.byType(TextField).first, 'Ana');

    verify(() => cubit.updateName('Ana')).called(1);
  });

  testWidgets('the last step shows the summary and the terms', (tester) async {
    givenState(SignupState(form: validClientSignupForm, stepIndex: 2));
    when(() => cubit.updateAcceptTerms(any())).thenReturn(null);
    useTallScreen(tester);

    await tester.pumpWidget(authTestApp(signupPage()));
    await tester.tap(find.byType(Checkbox));

    expect(find.text('Revise e confirme'), findsOneWidget);
    expect(find.text('Ana Cliente'), findsOneWidget);
    expect(find.text('Sou cliente (responsável)'), findsOneWidget);
    verify(() => cubit.updateAcceptTerms(false)).called(1);
  });

  testWidgets('field issues are shown under their fields', (tester) async {
    const issues = {
      AccountField.email: AccountFieldIssue.duplicate,
      AccountField.document: AccountFieldIssue.invalid,
    };
    givenState(
      const SignupState(
        form: SignupForm(type: UserType.client),
        issues: issues,
      ),
    );

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Já existe uma conta com este e-mail.'), findsOneWidget);
    expect(
      find.text('CPF inválido. Verifique os números informados.'),
      findsNothing,
    );
  });

  testWidgets('tapping Criar conta on the last step submits', (tester) async {
    givenState(SignupState(form: validClientSignupForm, stepIndex: 2));
    when(() => cubit.submit()).thenAnswer((_) async {});

    await tester.pumpWidget(authTestApp(signupPage()));
    await tester.tap(find.widgetWithText(FilledButton, 'Criar conta'));

    verify(() => cubit.submit()).called(1);
  });

  testWidgets('a failure without fields is shown as feedback', (tester) async {
    final state = SignupState(form: validClientSignupForm);
    givenState(
      state,
      changes: Stream.value(
        state.copyWith(failure: const NetworkAccountFailure()),
      ),
    );

    await tester.pumpWidget(authTestApp(signupPage()));
    await tester.pump();

    expect(
      find.text('Sem conexão com o servidor. Tente novamente.'),
      findsOneWidget,
    );
    verify(() => cubit.clearFailure()).called(1);
  });

  testWidgets('a created account continues to code verification', (
    tester,
  ) async {
    final verificationCubit = MockEmailCodeVerificationCubit();
    whenListen(
      verificationCubit,
      const Stream<EmailCodeVerificationState>.empty(),
      initialState: const EmailCodeVerificationState(
        email: 'ana@vanep.com.br',
        password: 'secret1',
      ),
    );
    when(() => verificationCubit.startResendCooldown()).thenReturn(null);
    final requests = <EmailCodeVerificationRequest>[];
    getIt.registerFactoryParam<
      EmailCodeVerificationCubit,
      EmailCodeVerificationRequest,
      StartSession
    >((request, _) {
      requests.add(request);
      return verificationCubit;
    });
    addTearDown(getIt.reset);
    final authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );
    final state = SignupState(form: validClientSignupForm);
    givenState(
      state,
      changes: Stream.value(state.copyWith(status: SignupStatus.completed)),
    );

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: authTestApp(signupPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(EmailCodeVerificationPage), findsOneWidget);
    expect(requests, [
      const EmailCodeVerificationRequest(
        email: 'ana@vanep.com.br',
        password: 'Secret@1',
        codeAlreadySent: true,
      ),
    ]);
    verify(() => verificationCubit.startResendCooldown()).called(1);
  });

  testWidgets('Google sign-up starts with the personal details', (
    tester,
  ) async {
    givenState(
      const SignupState(
        form: SignupForm(type: UserType.assistant),
        googleTicket: googleTicket,
      ),
    );

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Etapa 1 de 2'), findsOneWidget);
    expect(find.text('Senha'), findsNothing);
    expect(find.text('CPF'), findsOneWidget);
  });

  testWidgets('Google sign-up summarizes the Google account at the end', (
    tester,
  ) async {
    givenState(
      const SignupState(
        form: SignupForm(type: UserType.assistant),
        googleTicket: googleTicket,
        stepIndex: 1,
      ),
    );

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Novo Usuário'), findsOneWidget);
    expect(find.text('novo@gmail.com'), findsOneWidget);
    expect(find.text('Cadastro de assistente'), findsOneWidget);
  });

  testWidgets('an expired Google ticket returns to login', (tester) async {
    final state = SignupState(
      form: validClientSignupForm,
      googleTicket: googleTicket,
    );
    givenState(
      state,
      changes: Stream.value(
        state.copyWith(failure: const InvalidSignupTicketAccountFailure()),
      ),
    );

    await tester.pumpWidget(
      authTestApp(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => signupPage())),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('abrir'), findsOneWidget);
    expect(
      find.text(
        'Seu cadastro com o Google expirou. Entre com o Google novamente.',
      ),
      findsOneWidget,
    );
  });

  group('gender', () {
    void personalStep() {
      givenState(
        const SignupState(
          form: SignupForm(type: UserType.client),
          stepIndex: 1,
        ),
      );
      when(() => cubit.updateGender(any())).thenReturn(null);
    }

    testWidgets('is a select with the four options, not chips', (tester) async {
      personalStep();
      useTallScreen(tester);

      await tester.pumpWidget(authTestApp(signupPage()));

      expect(find.byType(VanepGenderSelect), findsOneWidget);
      expect(find.text('Sexo'), findsOneWidget);
      expect(find.text('Prefiro não informar'), findsOneWidget);

      await tester.tap(find.byType(DropdownButton<Gender?>));
      await tester.pumpAndSettle();

      for (final label in ['Masculino', 'Feminino', 'Outro']) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });

    testWidgets('choosing a gender reaches the cubit', (tester) async {
      personalStep();
      useTallScreen(tester);

      await tester.pumpWidget(authTestApp(signupPage()));
      await tester.tap(find.byType(DropdownButton<Gender?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Feminino').last);
      await tester.pumpAndSettle();

      verify(() => cubit.updateGender(Gender.female)).called(1);
    });

    testWidgets('choosing Prefiro não informar clears it', (tester) async {
      givenState(
        const SignupState(
          form: SignupForm(type: UserType.client, gender: Gender.female),
          stepIndex: 1,
        ),
      );
      when(() => cubit.updateGender(any())).thenReturn(null);
      useTallScreen(tester);

      await tester.pumpWidget(authTestApp(signupPage()));
      await tester.tap(find.byType(DropdownButton<Gender?>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prefiro não informar').last);
      await tester.pumpAndSettle();

      verify(() => cubit.updateGender(null)).called(1);
    });
  });

  group('birth date field', () {
    testWidgets('shows the chosen date as dd/MM/yyyy without the time', (
      tester,
    ) async {
      givenState(
        SignupState(
          form: SignupForm(
            type: UserType.client,
            birthDate: DateTime(1994, 3, 7),
          ),
          stepIndex: 1,
        ),
      );
      useTallScreen(tester);

      await tester.pumpWidget(authTestApp(signupPage()));

      expect(find.text('07/03/1994'), findsOneWidget);
      expect(find.textContaining('T00:00'), findsNothing);
    });
  });
}
