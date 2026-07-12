import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/auth_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/welcome_page.dart';

import 'auth_presentation_mocks.dart';

Widget _harness(AuthCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: const WelcomePage(),
    ),
  );
}

void main() {
  late MockAuthCubit cubit;

  setUp(() {
    cubit = MockAuthCubit();
    when(() => cubit.state).thenReturn(const AuthUnauthenticated());
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );
  });

  testWidgets('tapping Continuar starts login', (tester) async {
    when(() => cubit.startLogin()).thenReturn(null);

    await tester.pumpWidget(_harness(cubit));
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    verify(() => cubit.startLogin()).called(1);
  });

  testWidgets('shows an error snackbar on a failure state', (tester) async {
    whenListen(
      cubit,
      Stream<AuthState>.fromIterable(const [
        AuthFailureState(NetworkAuthFailure()),
        AuthUnauthenticated(),
      ]),
      initialState: const AuthUnauthenticated(),
    );

    await tester.pumpWidget(_harness(cubit));
    await tester.pump();

    expect(
      find.text('Não foi possível entrar. Tente novamente.'),
      findsOneWidget,
    );
  });

  testWidgets('shows an info snackbar when login is cancelled', (tester) async {
    whenListen(
      cubit,
      Stream<AuthState>.fromIterable(const [
        AuthFailureState(CancelledAuthFailure()),
        AuthUnauthenticated(),
      ]),
      initialState: const AuthUnauthenticated(),
    );

    await tester.pumpWidget(_harness(cubit));
    await tester.pump();

    expect(find.text('O login foi cancelado.'), findsOneWidget);
  });
}
