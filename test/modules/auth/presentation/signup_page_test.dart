import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/signup_form.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/signup_state.dart';
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
}
