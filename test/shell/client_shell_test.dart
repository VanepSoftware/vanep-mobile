import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driversearch/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driversearch/presentation/cubit/driver_search_state.dart';
import 'package:vanep_mobile/modules/driversearch/presentation/pages/driver_search_page.dart';
import 'package:vanep_mobile/shell/client_shell.dart';

import '../modules/auth/auth_fixtures.dart';
import '../modules/auth/presentation/auth_presentation_mocks.dart';
import '../modules/drivers/drivers_fixtures.dart';
import '../modules/drivers/presentation/drivers_presentation_mocks.dart';
import '../modules/profile/profile_mocks.dart';

class MockDriverSearchCubit extends MockCubit<DriverSearchState>
    implements DriverSearchCubit {}

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

PlaceAutocompleteController buildAutocomplete() {
  final datasource = MockPlaceAutocompleteDataSource();
  when(() => datasource.findSuggestions(any(), any()))
      .thenAnswer((_) async => const Ok([]));
  return PlaceAutocompleteController(datasource: datasource);
}

Widget _harness(
  DriversCubit driversCubit,
  AuthCubit authCubit,
  ProfileSummaryCubit profileSummaryCubit,
  DriverSearchCubit searchCubit,
  PlaceAutocompleteController autocomplete,
) {
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
        BlocProvider<ProfileSummaryCubit>.value(value: profileSummaryCubit),
        BlocProvider<DriverSearchCubit>.value(value: searchCubit),
      ],
      child: ClientShell(
        profile: const FakeUserProfile(),
        placeAutocomplete: autocomplete,
      ),
    ),
  );
}

void main() {
  late MockDriversCubit driversCubit;
  late MockAuthCubit authCubit;
  late MockProfileSummaryCubit profileSummaryCubit;

  setUpAll(() {
    registerFallbackValue(UserType.client);
  });

  late MockDriverSearchCubit searchCubit;
  late PlaceAutocompleteController autocomplete;

  setUp(() {
    searchCubit = MockDriverSearchCubit();
    whenListen(
      searchCubit,
      const Stream<DriverSearchState>.empty(),
      initialState: const DriverSearchState(),
    );
    autocomplete = buildAutocomplete();
    driversCubit = MockDriversCubit();
    authCubit = MockAuthCubit();
    profileSummaryCubit = MockProfileSummaryCubit();
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
    whenListen(
      profileSummaryCubit,
      const Stream<ProfileSummaryState>.empty(),
      initialState: const ProfileSummaryState(),
    );
    when(authCubit.refreshSessionProfile).thenAnswer((_) async {});
    when(
      () => profileSummaryCubit.refresh(any()),
    ).thenAnswer((_) async {});
  });

  testWidgets('starts on the home tab with the greeting', (tester) async {
    await tester.pumpWidget(
      _harness(driversCubit, authCubit, profileSummaryCubit, searchCubit, autocomplete),
    );

    expect(find.text('Olá, Ana!'), findsOneWidget);
    verifyNever(() => profileSummaryCubit.refresh(any()));
    verifyNever(authCubit.refreshSessionProfile);
  });

  testWidgets('switches to the Vans tab showing the driver search', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(driversCubit, authCubit, profileSummaryCubit, searchCubit, autocomplete),
    );

    await tester.tap(find.bySemanticsLabel('Vans'));
    await tester.pumpAndSettle();

    expect(find.byType(DriverSearchPage), findsOneWidget);
    expect(find.text('Em breve'), findsNothing);
  });

  testWidgets('refreshes session profile and summary when opening profile tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(driversCubit, authCubit, profileSummaryCubit, searchCubit, autocomplete),
    );

    await tester.tap(find.bySemanticsLabel('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Motorista'), findsOneWidget);
    expect(find.text('Dados pessoais'), findsOneWidget);
    verify(authCubit.refreshSessionProfile).called(1);
    verify(() => profileSummaryCubit.refresh(UserType.driver)).called(1);
    await tester.scrollUntilVisible(find.text('Sair'), 200);
    expect(find.text('Sair'), findsOneWidget);
  });

  testWidgets('pull-to-refresh on profile tab refreshes session and summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(driversCubit, authCubit, profileSummaryCubit, searchCubit, autocomplete),
    );

    await tester.tap(find.bySemanticsLabel('Perfil'));
    await tester.pumpAndSettle();
    clearInteractions(authCubit);
    clearInteractions(profileSummaryCubit);
    when(authCubit.refreshSessionProfile).thenAnswer((_) async {});
    when(
      () => profileSummaryCubit.refresh(any()),
    ).thenAnswer((_) async {});

    await tester.fling(find.text('Perfil').first, const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    verify(authCubit.refreshSessionProfile).called(1);
    verify(() => profileSummaryCubit.refresh(UserType.driver)).called(1);
  });
}
