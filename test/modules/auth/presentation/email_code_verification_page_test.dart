import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/account_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/email_code_verification_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/email_code_verification_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/email_code_verification_page.dart';

import 'auth_presentation_mocks.dart';
import 'auth_test_harness.dart';

void main() {
  late MockEmailCodeVerificationCubit cubit;

  const initial = EmailCodeVerificationState(
    email: 'ana@vanep.com.br',
    password: 'secret1',
  );

  setUp(() {
    cubit = MockEmailCodeVerificationCubit();
    when(() => cubit.clearFeedback()).thenReturn(null);
  });

  void givenState(
    EmailCodeVerificationState state, {
    Stream<EmailCodeVerificationState>? changes,
  }) {
    when(() => cubit.state).thenReturn(state);
    whenListen(
      cubit,
      changes ?? const Stream<EmailCodeVerificationState>.empty(),
      initialState: state,
    );
  }

  Widget page() => BlocProvider<EmailCodeVerificationCubit>.value(
    value: cubit,
    child: const EmailCodeVerificationPage(),
  );

  testWidgets('shows where the code went and forwards typing', (tester) async {
    givenState(initial);
    when(() => cubit.updateCode(any())).thenReturn(null);

    await tester.pumpWidget(authTestApp(page()));
    await tester.enterText(find.byType(TextField), '123456');

    expect(
      find.text('Enviamos um código de 6 dígitos para ana@vanep.com.br.'),
      findsOneWidget,
    );
    verify(() => cubit.updateCode('123456')).called(1);
  });

  testWidgets('does not claim a code was sent when none was', (tester) async {
    givenState(
      const EmailCodeVerificationState(
        email: 'ana@vanep.com.br',
        password: 'secret1',
        codeAlreadySent: false,
      ),
    );

    await tester.pumpWidget(authTestApp(page()));

    expect(
      find.text(
        'Digite o código de 6 dígitos que foi enviado para ana@vanep.com.br. '
        'Se ele expirou ou não chegou, peça um novo abaixo.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Enviamos um código'), findsNothing);
  });

  testWidgets('Confirmar verifies once six digits are typed', (tester) async {
    givenState(initial.copyWith(code: '123456'));
    when(() => cubit.verify()).thenAnswer((_) async {});

    await tester.pumpWidget(authTestApp(page()));
    await tester.tap(find.widgetWithText(FilledButton, 'Confirmar'));

    verify(() => cubit.verify()).called(1);
  });

  testWidgets('resend shows the countdown while cooling down', (tester) async {
    givenState(initial.copyWith(resendSecondsLeft: 42));

    await tester.pumpWidget(authTestApp(page()));

    final resend = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Reenviar código em 42s'),
    );
    expect(resend.onPressed, isNull);
  });

  testWidgets('resend is available after the cooldown', (tester) async {
    givenState(initial);
    when(() => cubit.resend()).thenAnswer((_) async {});

    await tester.pumpWidget(authTestApp(page()));
    await tester.tap(find.text('Reenviar código'));

    verify(() => cubit.resend()).called(1);
  });

  testWidgets('an invalid code is reported', (tester) async {
    givenState(
      initial,
      changes: Stream.value(
        initial.copyWith(
          feedback: const AccountFailureCodeFeedback(
            InvalidCodeAccountFailure(),
          ),
        ),
      ),
    );

    await tester.pumpWidget(authTestApp(page()));
    await tester.pump();

    expect(find.text('Código inválido ou expirado.'), findsOneWidget);
    verify(() => cubit.clearFeedback()).called(1);
  });

  testWidgets('a verified e-mail without session returns to login', (
    tester,
  ) async {
    givenState(
      initial,
      changes: Stream.value(
        initial.copyWith(status: EmailCodeVerificationStatus.verified),
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
      find.text('E-mail confirmado! Entre para continuar.'),
      findsOneWidget,
    );
  });
}
