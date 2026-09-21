import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_bottom_nav.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_cubit.dart';
import 'package:vanep_mobile/modules/dependents/presentation/cubit/dependents_state.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:vanep_mobile/modules/auth/presentation/cubit/auth_state.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_cubit.dart';
import 'package:vanep_mobile/modules/drivers/presentation/cubit/drivers_state.dart';
import 'package:vanep_mobile/modules/profile/presentation/cubit/profile_summary_cubit.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_cubit.dart';
import 'package:vanep_mobile/modules/driver_search/presentation/cubit/driver_search_state.dart';
import 'package:vanep_mobile/shell/client_shell.dart';

import '../modules/auth/auth_fixtures.dart';
import '../modules/auth/presentation/auth_presentation_mocks.dart';
import '../modules/dependents/dependents_mocks.dart';
import '../modules/drivers/drivers_fixtures.dart';
import '../modules/drivers/presentation/drivers_presentation_mocks.dart';
import '../modules/profile/profile_mocks.dart';

class MockDriverSearchCubit extends MockCubit<DriverSearchState>
    implements DriverSearchCubit {}

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

PlaceAutocompleteController buildAutocomplete() {
  final datasource = MockPlaceAutocompleteDataSource();
  when(
    () => datasource.findSuggestions(any(), any()),
  ).thenAnswer((_) async => const Ok([]));
  return PlaceAutocompleteController(datasource: datasource);
}

Widget _harness(
  DriversCubit driversCubit,
  AuthCubit authCubit,
  ProfileSummaryCubit profileSummaryCubit,
  DependentsCubit dependentsCubit,
  Future<void> Function(BuildContext)? openDriverSearch,
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
        BlocProvider<DependentsCubit>.value(value: dependentsCubit),
      ],
      child: ClientShell(
        profile: const FakeUserProfile(),
        openDriverSearch: openDriverSearch ?? (_) async {},
      ),
    ),
  );
}

List<String> bottomNavLabels(WidgetTester tester) {
  final nav = tester.widget<VanepBottomNav>(find.byType(VanepBottomNav));
  return [for (final item in nav.items) item.label];
}

void main() {
  late MockDriversCubit driversCubit;
  late MockAuthCubit authCubit;
  late MockProfileSummaryCubit profileSummaryCubit;
  late MockDependentsCubit dependentsCubit;

  Widget harness({Future<void> Function(BuildContext)? openDriverSearch}) {
    return _harness(
      driversCubit,
      authCubit,
      profileSummaryCubit,
      dependentsCubit,
      openDriverSearch,
    );
  }

  setUpAll(() {
    registerFallbackValue(UserType.client);
  });

  setUp(() {
    driversCubit = MockDriversCubit();
    authCubit = MockAuthCubit();
    profileSummaryCubit = MockProfileSummaryCubit();
    dependentsCubit = MockDependentsCubit();
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
    whenListen(
      dependentsCubit,
      const Stream<DependentsState>.empty(),
      initialState: const DependentsState(status: DependentsStatus.ready),
    );
    when(authCubit.refreshSessionProfile).thenAnswer((_) async {});
    when(() => profileSummaryCubit.refresh(any())).thenAnswer((_) async {});
    when(dependentsCubit.loadDependents).thenAnswer((_) async {});
  });

  testWidgets('starts on the home tab with the greeting', (tester) async {
    await tester.pumpWidget(harness());

    expect(find.text('Olá, Ana!'), findsOneWidget);
    verifyNever(() => profileSummaryCubit.refresh(any()));
    verifyNever(authCubit.refreshSessionProfile);
  });

  testWidgets('bottom bar offers home, vans, contracts and dependents', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    expect(bottomNavLabels(tester), [
      'Início',
      'Vans',
      'Contratos',
      'Dependentes',
    ]);
  });

  testWidgets('home shows the no linked van state without the search', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    expect(find.text('Nenhuma van vinculada'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('find a van on home switches to the Vans tab', (tester) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.text('Procurar van'));
    await tester.pumpAndSettle();

    expect(find.text('Sugestões perto de você'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('switches to the Contratos tab showing the coming soon view', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.bySemanticsLabel('Contratos'));
    await tester.pumpAndSettle();

    expect(find.text('Contratos'), findsWidgets);
    expect(find.text('Em breve'), findsOneWidget);
  });

  testWidgets('tapping the vans search field opens the search page', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      harness(openDriverSearch: (_) async => opened = true),
    );
    await tester.tap(find.bySemanticsLabel('Vans'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
  });

  testWidgets('the menu button opens the account drawer and refreshes it', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Ana Motorista'), findsOneWidget);
    expect(find.text('Dados pessoais'), findsOneWidget);
    verify(authCubit.refreshSessionProfile).called(1);
    verify(() => profileSummaryCubit.refresh(UserType.driver)).called(1);
  });

  testWidgets('closing the drawer does not refresh again', (tester) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(780, 300));
    await tester.pumpAndSettle();

    expect(find.byType(Drawer), findsNothing);
    verify(authCubit.refreshSessionProfile).called(1);
  });

  testWidgets('the bell opens the notifications coming soon page', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    await tester.tap(find.byTooltip('Notificações'));
    await tester.pumpAndSettle();

    expect(find.byType(VanepComingSoonPage), findsOneWidget);
    expect(find.text('Em breve'), findsOneWidget);
  });

  testWidgets('dependents load only when their tab is selected', (
    tester,
  ) async {
    await tester.pumpWidget(harness());

    verifyNever(dependentsCubit.loadDependents);

    await tester.tap(find.bySemanticsLabel('Dependentes'));
    await tester.pumpAndSettle();

    expect(find.text('Gerenciar dependentes'), findsOneWidget);
    verify(dependentsCubit.loadDependents).called(1);

    await tester.tap(find.bySemanticsLabel('Início'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Dependentes'));
    await tester.pumpAndSettle();

    verify(dependentsCubit.loadDependents).called(1);
  });
}
