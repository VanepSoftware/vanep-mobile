import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
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

  Widget signupPage() =>
      BlocProvider<SignupCubit>.value(value: cubit, child: const SignupPage());

  testWidgets('driver form asks for the driver fields', (tester) async {
    givenState(const SignupState(form: SignupForm(type: UserType.driver)));

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Cadastro de motorista'), findsOneWidget);
    expect(find.text('Valor base (R\$)'), findsOneWidget);
    expect(find.text('CNPJ (próprio ou da empresa)'), findsOneWidget);
  });

  testWidgets('client form has no driver fields', (tester) async {
    givenState(const SignupState(form: SignupForm(type: UserType.client)));

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Cadastro de cliente'), findsOneWidget);
    expect(find.text('Valor base (R\$)'), findsNothing);
  });

  testWidgets('typing and accepting the terms reach the cubit', (tester) async {
    givenState(const SignupState(form: SignupForm(type: UserType.client)));
    when(() => cubit.updateName(any())).thenReturn(null);
    when(() => cubit.updateAcceptTerms(any())).thenReturn(null);
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(authTestApp(signupPage()));
    await tester.enterText(find.byType(TextField).first, 'Ana');
    await tester.tap(find.byType(Checkbox));

    verify(() => cubit.updateName('Ana')).called(1);
    verify(() => cubit.updateAcceptTerms(true)).called(1);
  });

  testWidgets('field issues are shown under their fields', (tester) async {
    givenState(
      const SignupState(
        form: SignupForm(type: UserType.client),
        issues: {
          AccountField.email: AccountFieldIssue.duplicate,
          AccountField.document: AccountFieldIssue.invalid,
        },
      ),
    );

    await tester.pumpWidget(authTestApp(signupPage()));

    expect(find.text('Já existe uma conta com este e-mail.'), findsOneWidget);
    expect(
      find.text('CPF inválido. Verifique os números informados.'),
      findsOneWidget,
    );
  });

  testWidgets('tapping Criar conta submits', (tester) async {
    givenState(SignupState(form: validClientSignupForm));
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
        password: 'secret1',
        codeAlreadySent: true,
      ),
    ]);
    verify(() => verificationCubit.startResendCooldown()).called(1);
  });

  testWidgets(
    'Google sign-up shows the Google account instead of credentials',
    (tester) async {
      givenState(
        const SignupState(
          form: SignupForm(type: UserType.assistant),
          googleTicket: googleTicket,
        ),
      );

      await tester.pumpWidget(authTestApp(signupPage()));

      expect(find.text('Novo Usuário'), findsOneWidget);
      expect(find.text('novo@gmail.com'), findsOneWidget);
      expect(find.text('Senha'), findsNothing);
      expect(find.text('Cadastro de assistente'), findsOneWidget);
    },
  );

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
}
