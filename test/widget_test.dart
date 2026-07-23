import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/app.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';

import 'modules/auth/auth_fixtures.dart';
import 'modules/auth/presentation/auth_presentation_mocks.dart';
import 'modules/drivers/drivers_fixtures.dart';
import 'modules/drivers/presentation/drivers_presentation_mocks.dart';
import 'modules/profile/profile_mocks.dart';

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
    home: BlocProvider<AuthCubit>.value(value: cubit, child: const AuthGate()),
  );
}

void main() {
  late MockAuthCubit cubit;

  setUp(() => cubit = MockAuthCubit());

  testWidgets('shows the splash while the session is unknown', (tester) async {
    when(() => cubit.state).thenReturn(const AuthUnknown());
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthUnknown(),
    );

    await tester.pumpWidget(_harness(cubit));

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('shows the welcome screen with the Continue button when '
      'unauthenticated', (tester) async {
    when(() => cubit.state).thenReturn(const AuthUnauthenticated());
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );

    await tester.pumpWidget(_harness(cubit));

    expect(find.text('Continuar'), findsOneWidget);
  });

  testWidgets('shows the client home shell when authenticated', (
    tester,
  ) async {
    final driversCubit = MockDriversCubit();
    final profileSummaryCubit = MockProfileSummaryCubit();
    whenListen(
      driversCubit,
      const Stream<DriversState>.empty(),
      initialState: const DriversState(
        status: DriversStatus.loaded,
        drivers: testRecentDrivers,
      ),
    );
    whenListen(
      profileSummaryCubit,
      const Stream<ProfileSummaryState>.empty(),
      initialState: const ProfileSummaryState(),
    );
    when(() => driversCubit.loadRecentDrivers()).thenAnswer((_) async {});
    getIt
      ..registerFactory<DriversCubit>(() => driversCubit)
      ..registerFactory<ProfileSummaryCubit>(() => profileSummaryCubit);
    addTearDown(getIt.reset);

    final state = AuthAuthenticated(FakeAuthSession());
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<AuthState>.empty(), initialState: state);

    await tester.pumpWidget(_harness(cubit));

    expect(find.text('Olá, Ana!'), findsOneWidget);
    expect(find.text('Sugestões perto de você'), findsOneWidget);
  });
}
