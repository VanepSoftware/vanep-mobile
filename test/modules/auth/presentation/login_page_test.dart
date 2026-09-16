import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/account_type_page.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/login_page.dart';

import 'auth_presentation_mocks.dart';

Widget loginHarness(LoginCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: BlocProvider<LoginCubit>.value(
      value: cubit,
      child: const LoginPage(),
    ),
  );
}

void main() {
  late MockLoginCubit cubit;

  const filled = LoginState(email: 'ana@vanep.com.br', password: 'secret1');

  setUp(() {
    cubit = MockLoginCubit();
    when(() => cubit.clearFailure()).thenReturn(null);
  });

  void givenState(LoginState state, {Stream<LoginState>? changes}) {
    when(() => cubit.state).thenReturn(state);
    whenListen(
      cubit,
      changes ?? const Stream<LoginState>.empty(),
      initialState: state,
    );
  }

  testWidgets('typing forwards e-mail and password to the cubit', (
    tester,
  ) async {
    givenState(const LoginState());
    when(() => cubit.updateEmail(any())).thenReturn(null);
    when(() => cubit.updatePassword(any())).thenReturn(null);

    await tester.pumpWidget(loginHarness(cubit));
    await tester.enterText(find.byType(TextField).at(0), 'ana@vanep.com.br');
    await tester.enterText(find.byType(TextField).at(1), 'secret1');

    verify(() => cubit.updateEmail('ana@vanep.com.br')).called(1);
    verify(() => cubit.updatePassword('secret1')).called(1);
  });

  testWidgets('the sign-in button is disabled until the form is filled', (
    tester,
  ) async {
    givenState(const LoginState());

    await tester.pumpWidget(loginHarness(cubit));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('tapping Entrar submits the password', (tester) async {
    givenState(filled);
    when(() => cubit.submitPassword()).thenAnswer((_) async {});

    await tester.pumpWidget(loginHarness(cubit));
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    verify(() => cubit.submitPassword()).called(1);
  });

  final messages = <AuthFailure, String>{
    const InvalidCredentialsAuthFailure(): 'E-mail ou senha incorretos.',
    const AccountLockedAuthFailure():
        'Muitas tentativas sem sucesso. Tente de novo em alguns minutos.',
    const TooManyRequestsAuthFailure():
        'Muitas requisições. Aguarde um instante e tente de novo.',
    const NetworkAuthFailure(): 'Não foi possível entrar. Tente novamente.',
  };

  for (final entry in messages.entries) {
    testWidgets('shows the message for ${entry.key.runtimeType}', (
      tester,
    ) async {
      givenState(
        filled,
        changes: Stream.value(filled.copyWith(failure: entry.key)),
      );

      await tester.pumpWidget(loginHarness(cubit));
      await tester.pump();

      expect(find.text(entry.value), findsOneWidget);
      verify(() => cubit.clearFailure()).called(1);
    });
  }

  testWidgets('Criar conta opens the account type choice', (tester) async {
    givenState(const LoginState());

    await tester.pumpWidget(loginHarness(cubit));
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();

    expect(find.byType(AccountTypePage), findsOneWidget);
  });
}
