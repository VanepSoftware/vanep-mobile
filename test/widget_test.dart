import 'dart:async';

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
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/login_state.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/start_session.dart';
import 'package:vanep_mobile/modules/auth/presentation/pages/login_page.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_state.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/shell/client_shell.dart';
import 'package:vanep_mobile/shell/driver_shell.dart';

import 'modules/auth/auth_fixtures.dart';
import 'modules/auth/presentation/auth_presentation_mocks.dart';
import 'modules/dependents/dependents_mocks.dart';
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

class MockDriverSearchCubit extends MockCubit<DriverSearchState>
    implements DriverSearchCubit {}

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

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

  testWidgets('shows the login screen when unauthenticated', (tester) async {
    final loginCubit = MockLoginCubit();
    whenListen(
      loginCubit,
      const Stream<LoginState>.empty(),
      initialState: const LoginState(),
    );
    getIt.registerFactoryParam<LoginCubit, StartSession, void>(
      (_, _) => loginCubit,
    );
    addTearDown(getIt.reset);
    when(() => cubit.state).thenReturn(const AuthUnauthenticated());
    whenListen(
      cubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthUnauthenticated(),
    );

    await tester.pumpWidget(_harness(cubit));

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('routes a client session to the client shell', (tester) async {
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
    final dependentsCubit = MockDependentsCubit();
    whenListen(
      dependentsCubit,
      const Stream<DependentsState>.empty(),
      initialState: const DependentsState(),
    );
    final searchCubit = MockDriverSearchCubit();
    whenListen(
      searchCubit,
      const Stream<DriverSearchState>.empty(),
      initialState: const DriverSearchState(),
    );
    final autocompleteDatasource = MockPlaceAutocompleteDataSource();
    when(
      () => autocompleteDatasource.findSuggestions(any(), any()),
    ).thenAnswer((_) async => const Ok([]));
    getIt
      ..registerFactory<DriversCubit>(() => driversCubit)
      ..registerFactory<ProfileSummaryCubit>(() => profileSummaryCubit)
      ..registerFactory<DriverSearchCubit>(() => searchCubit)
      ..registerFactory<DependentsCubit>(() => dependentsCubit)
      ..registerFactory<PlaceAutocompleteController>(
        () => PlaceAutocompleteController(datasource: autocompleteDatasource),
      );
    addTearDown(getIt.reset);

    final state = AuthAuthenticated(
      FakeAuthSession(profile: const FakeUserProfile(type: UserType.client)),
    );
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<AuthState>.empty(), initialState: state);

    await tester.pumpWidget(_harness(cubit));

    expect(find.byType(ClientShell), findsOneWidget);
    expect(find.byType(DriverShell), findsNothing);
    expect(find.text('Nenhuma van vinculada'), findsOneWidget);
  });

  testWidgets('routes a driver session to the driver shell', (tester) async {
    final profileSummaryCubit = MockProfileSummaryCubit();
    whenListen(
      profileSummaryCubit,
      const Stream<ProfileSummaryState>.empty(),
      initialState: const ProfileSummaryState(),
    );
    final autocompleteDatasource = MockPlaceAutocompleteDataSource();
    when(
      () => autocompleteDatasource.findSuggestions(any(), any()),
    ).thenAnswer((_) async => const Ok([]));
    getIt
      ..registerFactory<DriverHomeCubit>(DriverHomeCubit.new)
      ..registerFactory<ProfileSummaryCubit>(() => profileSummaryCubit)
      ..registerFactory<PlaceAutocompleteController>(
        () => PlaceAutocompleteController(datasource: autocompleteDatasource),
      );
    addTearDown(getIt.reset);

    final state = AuthAuthenticated(
      FakeAuthSession(profile: const FakeUserProfile(type: UserType.driver)),
    );
    when(() => cubit.state).thenReturn(state);
    whenListen(cubit, const Stream<AuthState>.empty(), initialState: state);

    await tester.pumpWidget(_harness(cubit));

    expect(find.byType(DriverShell), findsOneWidget);
    expect(find.byType(ClientShell), findsNothing);
  });

  testWidgets('starting a session closes the pages pushed over the login', (
    tester,
  ) async {
    final loginCubit = MockLoginCubit();
    whenListen(
      loginCubit,
      const Stream<LoginState>.empty(),
      initialState: const LoginState(),
    );
    final profileSummaryCubit = MockProfileSummaryCubit();
    whenListen(
      profileSummaryCubit,
      const Stream<ProfileSummaryState>.empty(),
      initialState: const ProfileSummaryState(),
    );
    getIt
      ..registerFactoryParam<LoginCubit, StartSession, void>(
        (_, _) => loginCubit,
      )
      ..registerFactory<DriverHomeCubit>(DriverHomeCubit.new)
      ..registerFactory<ProfileSummaryCubit>(() => profileSummaryCubit);
    addTearDown(getIt.reset);
    final authenticated = AuthAuthenticated(
      FakeAuthSession(profile: const FakeUserProfile(type: UserType.driver)),
    );
    final states = StreamController<AuthState>();
    addTearDown(states.close);
    when(() => cubit.state).thenReturn(const AuthUnauthenticated());
    whenListen(cubit, states.stream, initialState: const AuthUnauthenticated());

    await tester.pumpWidget(_harness(cubit));
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('código')),
          ),
        );
    await tester.pumpAndSettle();
    expect(find.text('código'), findsOneWidget);

    when(() => cubit.state).thenReturn(authenticated);
    states.add(authenticated);
    await tester.pumpAndSettle();

    expect(find.text('código'), findsNothing);
    expect(find.byType(DriverShell), findsOneWidget);
  });
}
