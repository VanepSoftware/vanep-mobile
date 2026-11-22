import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/design_system/vanep_theme.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_cubit.dart';
import 'package:vanep_mobile/modules/assistant/presentation/cubit/assistant_home_state.dart';
import 'package:vanep_mobile/modules/assistant/presentation/pages/assistant_route_stops_page.dart';

import '../../fixtures/assistant_fixtures.dart';
import '../../fixtures/assistant_route_fixtures.dart';
import '../../mocks/assistant_mocks.dart';

Widget localizedApp(Widget home) {
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
    home: home,
  );
}

void useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

final now = DateTime(2026, 10, 14, 7);

void main() {
  group('route and stops (VAN-71)', () {
    late MockAssistantHomeCubit cubit;

    setUp(() {
      cubit = MockAssistantHomeCubit();
      final state = AssistantHomeState(
        status: AssistantHomeLoadStatus.ready,
        overview: testHomeOverviewTwoVans,
        selectedVanToken: testAssistantVanPrimary.token,
        route: testRouteOnPickup(),
      );
      when(() => cubit.state).thenReturn(state);
      whenListen(
        cubit,
        const Stream<AssistantHomeState>.empty(),
        initialState: state,
      );
    });

    Widget stopsPage() => localizedApp(
      BlocProvider<AssistantHomeCubit>.value(
        value: cubit,
        child: const AssistantRouteStopsPage(),
      ),
    );

    testWidgets('lists the outbound stops with their progress', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(stopsPage());

      expect(find.text('Theo · Laura não estava no ponto'), findsOneWidget);
      expect(find.text('Agora'), findsOneWidget);
      expect(find.text('Desembarque · 5 alunos'), findsOneWidget);
      expect(
        find.text('Ordem das paradas definida pelo motorista.'),
        findsOneWidget,
      );
    });

    testWidgets('a van with no trip today says so', (tester) async {
      final noTrip = AssistantHomeState(
        status: AssistantHomeLoadStatus.ready,
        overview: testHomeOverviewTwoVans,
        selectedVanToken: testAssistantVanSecondary.token,
      );
      when(() => cubit.state).thenReturn(noTrip);
      whenListen(
        cubit,
        const Stream<AssistantHomeState>.empty(),
        initialState: noTrip,
      );
      await tester.pumpWidget(stopsPage());

      expect(find.text('Sem rota hoje'), findsOneWidget);
    });

    testWidgets('"Volta" shows the return stops', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(stopsPage());

      await tester.tap(find.text('Volta'));
      await tester.pump();

      expect(find.text('Desembarque · Helena e Davi'), findsOneWidget);
      expect(find.text('Theo · Laura não estava no ponto'), findsNothing);
    });
  });
}
