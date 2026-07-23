import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';
import 'package:vanep_mobile/shell/client_shell.dart';

import '../modules/auth/auth_fixtures.dart';
import '../modules/auth/presentation/auth_presentation_mocks.dart';
import '../modules/drivers/drivers_fixtures.dart';
import '../modules/drivers/presentation/drivers_presentation_mocks.dart';

Widget _harness(DriversCubit driversCubit, AuthCubit authCubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<DriversCubit>.value(value: driversCubit),
      ],
      child: const ClientShell(profile: FakeUserProfile()),
    ),
  );
}

void main() {
  late MockDriversCubit driversCubit;
  late MockAuthCubit authCubit;

  setUp(() {
    driversCubit = MockDriversCubit();
    authCubit = MockAuthCubit();
    whenListen(
      driversCubit,
      const Stream<DriversState>.empty(),
      initialState: const DriversState(
        status: DriversStatus.loaded,
        drivers: testRecentDrivers,
      ),
    );
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );
  });

  testWidgets('starts on the home tab with the greeting', (tester) async {
    await tester.pumpWidget(_harness(driversCubit, authCubit));

    expect(find.text('Olá, Ana!'), findsOneWidget);
  });

  testWidgets('switches to the Vans tab showing the coming soon view', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(driversCubit, authCubit));

    await tester.tap(find.text('Vans'));
    await tester.pumpAndSettle();

    expect(find.text('Em breve'), findsOneWidget);
  });

  testWidgets('shows the profile tab with profile content', (tester) async {
    await tester.pumpWidget(_harness(driversCubit, authCubit));

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Motorista'), findsOneWidget);
    expect(find.text('Dados pessoais'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sair'), 200);
    expect(find.text('Sair'), findsOneWidget);
  });
}
