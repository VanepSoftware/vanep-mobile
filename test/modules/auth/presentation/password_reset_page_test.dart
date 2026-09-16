import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/account_field.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/password_reset_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/password_reset_page.dart';

import 'auth_presentation_mocks.dart';
import 'auth_test_harness.dart';

void main() {
  late MockPasswordResetCubit cubit;

  const emailStep = PasswordResetState(email: 'ana@vanep.com.br');
  const codeStep = PasswordResetState(
    email: 'ana@vanep.com.br',
    step: PasswordResetStep.code,
  );

  setUp(() {
    cubit = MockPasswordResetCubit();
    when(() => cubit.clearFeedback()).thenReturn(null);
  });

  void givenState(
    PasswordResetState state, {
    Stream<PasswordResetState>? changes,
  }) {
    when(() => cubit.state).thenReturn(state);
    whenListen(
      cubit,
      changes ?? const Stream<PasswordResetState>.empty(),
      initialState: state,
    );
  }

  Widget page() => BlocProvider<PasswordResetCubit>.value(
    value: cubit,
    child: const PasswordResetPage(),
  );

  testWidgets('the e-mail step asks for the code', (tester) async {
    givenState(emailStep);
    when(() => cubit.requestCode()).thenAnswer((_) async {});

    await tester.pumpWidget(authTestApp(page()));
    await tester.tap(find.widgetWithText(FilledButton, 'Enviar código'));

    expect(find.text('ana@vanep.com.br'), findsOneWidget);
    verify(() => cubit.requestCode()).called(1);
  });

  testWidgets('the code step asks for the code and the new password', (
    tester,
  ) async {
    givenState(
      codeStep.copyWith(
        issues: const {AccountField.password: AccountFieldIssue.tooShort},
      ),
    );
    when(() => cubit.updateCode(any())).thenReturn(null);
    when(() => cubit.resetPassword()).thenAnswer((_) async {});

    await tester.pumpWidget(authTestApp(page()));
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Redefinir senha'));

    expect(find.text('Nova senha'), findsOneWidget);
    expect(
      find.text('A senha deve ter ao menos 8 caracteres.'),
      findsOneWidget,
    );
    verify(() => cubit.updateCode('123456')).called(1);
    verify(() => cubit.resetPassword()).called(1);
  });

  testWidgets('a completed reset returns to login with a notice', (
    tester,
  ) async {
    givenState(
      codeStep,
      changes: Stream.value(
        codeStep.copyWith(status: PasswordResetStatus.completed),
      ),
    );

    await tester.pumpWidget(
      authTestApp(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => page())),
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
      find.text('Senha redefinida! Entre com a nova senha.'),
      findsOneWidget,
    );
  });
}
