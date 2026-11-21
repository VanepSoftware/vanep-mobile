import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/core/ui/vanep_swipe_to_confirm.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/failures/assistant_failure.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_home_tab.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../fixtures/assistant_route_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

Widget homeHarness(MockAssistantHomeCubit cubit, {String? email}) {
  return MaterialApp(
    theme: VanepTheme.light(),
    locale: const Locale('pt'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<AssistantHomeCubit>.value(
      value: cubit,
      child: AssistantHomeTab(displayName: 'Marcos Ribeiro', email: email),
    ),
  );
}

AssistantHomeState readyState({
  required AssistantHomeOverview overview,
  String? selectedVanToken,
  AssistantRouteSnapshot? route,
}) {
  return AssistantHomeState(
    status: AssistantHomeLoadStatus.ready,
    overview: overview,
    selectedVanToken: selectedVanToken,
    route: route,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, NoShowReason>{});
    registerFallbackValue(<String, String>{});
    registerFallbackValue(<String>{});
  });

  late MockAssistantHomeCubit cubit;
  final carlosToken = testAssistantVanPrimary.token;

  void seed(AssistantHomeState state) {
    when(() => cubit.state).thenReturn(state);
    whenListen(
      cubit,
      const Stream<AssistantHomeState>.empty(),
      initialState: state,
    );
  }

  setUp(() {
    cubit = MockAssistantHomeCubit();
    when(() => cubit.selectVan(any())).thenAnswer((_) async {});
    when(
      () => cubit.confirmCurrentStop(
        selectedPassengerTokens: any(named: 'selectedPassengerTokens'),
        reasons: any(named: 'reasons'),
        notes: any(named: 'notes'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => cubit.confirmCurrentStop(
        selectedPassengerTokens: any(named: 'selectedPassengerTokens'),
      ),
    ).thenAnswer((_) async {});
    when(() => cubit.confirmPresenceInVan()).thenAnswer((_) async {});
    when(() => cubit.load(selectedVanToken: any(named: 'selectedVanToken')))
        .thenAnswer((_) async {});
    when(() => cubit.undoLastConfirmation()).thenAnswer((_) async {});
  });

  testWidgets('greets the assistant by first name', (tester) async {
    seed(readyState(overview: const AssistantHomeOverview()));
    await tester.pumpWidget(homeHarness(cubit));

    expect(find.text('Olá, Marcos!'), findsOneWidget);
  });

  testWidgets('no van: shows the e-mail and how it works', (tester) async {
    seed(readyState(overview: const AssistantHomeOverview()));
    await tester.pumpWidget(homeHarness(cubit, email: 'marcos@email.com'));

    expect(find.text('Ainda sem van'), findsOneWidget);
    expect(find.text('marcos@email.com'), findsOneWidget);
    expect(find.text('Como funciona'), findsOneWidget);
  });

  testWidgets('invite: shows the inviting driver', (tester) async {
    seed(
      readyState(
        overview: AssistantHomeOverview(pendingInvite: testAssistantInvite),
      ),
    );
    await tester.pumpWidget(homeHarness(cubit));

    expect(find.text('Você recebeu um convite.'), findsOneWidget);
    expect(find.textContaining(testAssistantInvite.driverName), findsWidgets);
  });

  testWidgets('before the route: "Estou na van" tells the cubit', (
    tester,
  ) async {
    seed(
      readyState(
        overview: testHomeOverviewTwoVans,
        selectedVanToken: carlosToken,
        route: testRouteNotStarted(),
      ),
    );
    await tester.pumpWidget(homeHarness(cubit));

    expect(find.text('Não iniciada'), findsOneWidget);
    await tester.tap(find.text('Estou na van'));

    verify(() => cubit.confirmPresenceInVan()).called(1);
  });

  testWidgets('with two vans, a chip switches the van', (tester) async {
    seed(
      readyState(
        overview: testHomeOverviewTwoVans,
        selectedVanToken: carlosToken,
        route: testRouteNotStarted(),
      ),
    );
    await tester.pumpWidget(homeHarness(cubit));

    await tester.tap(find.textContaining('Maria'));

    verify(() => cubit.selectVan(testAssistantVanSecondary.token)).called(1);
  });

  testWidgets('on route: a swipe confirms only who stayed ticked', (
    tester,
  ) async {
    seed(
      readyState(
        overview: testHomeOverviewTwoVans,
        selectedVanToken: carlosToken,
        route: testRouteOnPickup(),
      ),
    );
    await tester.pumpWidget(homeHarness(cubit));

    expect(find.text('Embarque em casa'), findsOneWidget);
    expect(find.text('Parada 3 de 6'), findsOneWidget);
    expect(find.text('Deslize para confirmar (2)'), findsOneWidget);

    await tester.tap(find.text('Gabriel'));
    await tester.pump();
    expect(find.text('Deslize para confirmar (1)'), findsOneWidget);

    await tester.ensureVisible(find.byKey(vanepSwipeToConfirmKnobKey));
    await tester.drag(
      find.byKey(vanepSwipeToConfirmKnobKey),
      const Offset(1000, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Por que não embarcou?'), findsOneWidget);
    await tester.tap(find.text('Passou mal'));
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    verify(
      () => cubit.confirmCurrentStop(
        selectedPassengerTokens: {'passenger-beatriz'},
        reasons: {'passenger-gabriel': NoShowReason.sick},
        notes: const {},
      ),
    ).called(1);
  });

  testWidgets('"Outro motivo" asks for a description', (tester) async {
    seed(
      readyState(
        overview: testHomeOverviewTwoVans,
        selectedVanToken: carlosToken,
        route: testRouteOnPickup(),
      ),
    );
    await tester.pumpWidget(homeHarness(cubit));
    await tester.tap(find.text('Gabriel'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(vanepSwipeToConfirmKnobKey));
    await tester.drag(
      find.byKey(vanepSwipeToConfirmKnobKey),
      const Offset(1000, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Outro motivo'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'foi ao médico');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    verify(
      () => cubit.confirmCurrentStop(
        selectedPassengerTokens: {'passenger-beatriz'},
        reasons: {'passenger-gabriel': NoShowReason.other},
        notes: {'passenger-gabriel': 'foi ao médico'},
      ),
    ).called(1);
  });

  testWidgets('a swipe with everyone ticked asks for no reason', (
    tester,
  ) async {
    seed(
      readyState(
        overview: testHomeOverviewTwoVans,
        selectedVanToken: carlosToken,
        route: testRouteOnPickup(),
      ),
    );
    await tester.pumpWidget(homeHarness(cubit));
    await tester.ensureVisible(find.byKey(vanepSwipeToConfirmKnobKey));
    await tester.drag(
      find.byKey(vanepSwipeToConfirmKnobKey),
      const Offset(1000, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('Por que não embarcou?'), findsNothing);
    verify(
      () => cubit.confirmCurrentStop(
        selectedPassengerTokens: {'passenger-beatriz', 'passenger-gabriel'},
      ),
    ).called(1);
  });

  testWidgets('at school: names who goes on to the next school', (
    tester,
  ) async {
    seed(
      readyState(
        overview: testHomeOverviewTwoVans,
        selectedVanToken: carlosToken,
        route: testRouteAtSchool(),
      ),
    );
    await tester.pumpWidget(homeHarness(cubit));

    expect(find.text('Chegada na escola'), findsOneWidget);
    expect(find.text('2 alunos descem aqui'), findsOneWidget);
    expect(find.text('Miguel segue até Escola Classe 10'), findsOneWidget);
  });

  testWidgets('paused: offers the other active van', (tester) async {
    seed(
      readyState(
        overview: testHomeOverviewCarlosPaused,
        selectedVanToken: carlosToken,
      ),
    );
    await tester.pumpWidget(homeHarness(cubit));

    expect(find.text('João pausou seu acesso'), findsOneWidget);
    await tester.tap(find.text('Ver a rota desta van'));

    verify(() => cubit.selectVan(testAssistantVanSecondary.token)).called(1);
  });

  testWidgets('a failed load can be retried', (tester) async {
    seed(
      const AssistantHomeState(
        status: AssistantHomeLoadStatus.loadFailed,
        failure: AssistantFailure.network,
      ),
    );
    await tester.pumpWidget(homeHarness(cubit));

    await tester.tap(find.text('Tentar de novo'));

    verify(() => cubit.load()).called(1);
  });

  testWidgets('a confirmed stop offers undo', (tester) async {
    final ready = readyState(
      overview: testHomeOverviewTwoVans,
      selectedVanToken: carlosToken,
      route: testRouteAtSchool(),
    );
    final confirmed = ready.copyWith(
      lastConfirmation: testStopConfirmationAtPickup,
    );
    when(() => cubit.state).thenReturn(confirmed);
    whenListen(
      cubit,
      Stream<AssistantHomeState>.fromIterable([confirmed]),
      initialState: ready,
    );
    await tester.pumpWidget(homeHarness(cubit));
    await tester.pumpAndSettle();

    expect(find.text('1 aluno confirmado'), findsOneWidget);
    await tester.tap(find.text('Desfazer'));

    verify(() => cubit.undoLastConfirmation()).called(1);
  });
}
