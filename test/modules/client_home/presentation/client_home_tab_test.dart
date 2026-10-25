import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/modules/client_home/domain/failures/client_home_failure.dart';
import 'package:vanep_mobile/modules/client_home/domain/usecases/prioritize_needs_you_items.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_cubit.dart';
import 'package:vanep_mobile/modules/client_home/presentation/cubit/client_home_state.dart';
import 'package:vanep_mobile/modules/client_home/presentation/pages/client_home_tab.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/client_home_skeleton.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/home_shortcuts_grid.dart';
import 'package:vanep_mobile/modules/client_home/presentation/widgets/live_van_card.dart';

import '../../../core/ui/localized_harness.dart';
import '../client_home_fixtures.dart';
import '../client_home_mocks.dart';

class HomeCallbacks {
  int menu = 0;
  int notifications = 0;
  int findVan = 0;
  int addAddress = 0;
  int addDependent = 0;
}

Widget clientHomeHarness(ClientHomeCubit cubit, HomeCallbacks callbacks) {
  return localizedHarness(
    Scaffold(
      body: BlocProvider<ClientHomeCubit>.value(
        value: cubit,
        child: ClientHomeTab(
          displayName: 'Maria Silva',
          onMenuTapped: () => callbacks.menu++,
          onNotificationsTapped: () => callbacks.notifications++,
          onFindVanTapped: () => callbacks.findVan++,
          onAddAddressTapped: () => callbacks.addAddress++,
          onAddDependentTapped: () => callbacks.addDependent++,
        ),
      ),
    ),
  );
}

NeedsYouSummary prioritized(List<NeedsYouItem> items) =>
    const PrioritizeNeedsYouItems()(items);

void main() {
  late MockClientHomeCubit cubit;
  late HomeCallbacks callbacks;

  setUp(() {
    cubit = MockClientHomeCubit();
    callbacks = HomeCallbacks();
    when(cubit.loadHome).thenAnswer((_) async {});
  });

  Future<void> pumpHome(WidgetTester tester, ClientHomeState state) async {
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      cubit,
      const Stream<ClientHomeState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(clientHomeHarness(cubit, callbacks));
  }

  Future<void> pumpReady(WidgetTester tester, ClientHome home) {
    return pumpHome(
      tester,
      ClientHomeState(status: ClientHomeStatus.ready, home: home),
    );
  }

  double topOf(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  testWidgets('shows the skeleton while the first load runs', (tester) async {
    await pumpHome(
      tester,
      const ClientHomeState(status: ClientHomeStatus.loading),
    );

    expect(find.byType(ClientHomeSkeleton), findsOneWidget);
    expect(find.text('Olá, Maria!'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    await pumpHome(
      tester,
      const ClientHomeState(
        status: ClientHomeStatus.loadFailed,
        failure: ClientHomeFailure.network,
      ),
    );

    expect(find.byType(VanepErrorView), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));

    verify(cubit.loadHome).called(1);
  });

  testWidgets('the top bar menu and bell call their callbacks', (tester) async {
    await pumpReady(tester, testClientHome());

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.tap(find.byTooltip('Notificações'));

    expect(callbacks.menu, 1);
    expect(callbacks.notifications, 1);
  });

  group('first access', () {
    testWidgets('shows progress and asks for the address first', (
      tester,
    ) async {
      await pumpReady(
        tester,
        testClientHome(
          today: const FirstStepsSection(
            hasAddress: false,
            hasDependents: false,
          ),
        ),
      );

      expect(find.text('Olá, Maria!'), findsOneWidget);
      expect(
        find.text('Vamos deixar tudo pronto para a primeira viagem.'),
        findsOneWidget,
      );
      expect(find.text('PRIMEIROS PASSOS · 1 DE 3'), findsOneWidget);
      expect(find.text('Como funciona na Vanep'), findsOneWidget);

      await tester.tap(find.text('Adicionar meu endereço'));
      expect(callbacks.addAddress, 1);
    });

    testWidgets('with the address done it asks for a dependent', (
      tester,
    ) async {
      await pumpReady(
        tester,
        testClientHome(
          today: const FirstStepsSection(
            hasAddress: true,
            hasDependents: false,
          ),
        ),
      );

      expect(find.text('PRIMEIROS PASSOS · 2 DE 3'), findsOneWidget);
      await tester.tap(find.text('Cadastrar dependente'));
      expect(callbacks.addDependent, 1);
    });
  });

  testWidgets('without a van the existing card finds a van', (tester) async {
    await pumpReady(tester, testClientHome());

    expect(find.text('Nenhuma van vinculada'), findsOneWidget);
    await tester.tap(find.text('Procurar van'));

    expect(callbacks.findVan, 1);
  });

  testWidgets('negotiating shows the count and the featured proposal', (
    tester,
  ) async {
    await pumpReady(
      tester,
      testClientHome(
        today: testNegotiatingSection,
        needsYou: prioritized([testCarlosProposal, testExpiredRequest]),
      ),
    );

    expect(find.text('Ana e Pedro ainda sem van'), findsOneWidget);
    expect(find.text('3 negociações em andamento'), findsOneWidget);
    expect(find.text('Proposta nova'), findsOneWidget);
    expect(find.text('Expira em 2 dias'), findsOneWidget);
    expect(find.text('Pedido para Rita expirou'), findsOneWidget);

    await tester.tap(find.text('Buscar vans'));
    expect(callbacks.findVan, 1);
  });

  testWidgets('blocks keep the order Today, Needs you, Shortcuts', (
    tester,
  ) async {
    await pumpReady(
      tester,
      testClientHome(
        today: testBeforeRouteSection,
        needsYou: prioritized([testOctoberFeeAwaitingConfirmation]),
        headline: HomeHeadline.goodMorning,
        enabledShortcuts: HomeShortcut.values.toSet(),
      ),
    );

    expect(topOf(tester, 'Hoje'), lessThan(topOf(tester, 'Precisa de você')));
    expect(
      topOf(tester, 'Precisa de você'),
      lessThan(topOf(tester, 'Atalhos')),
    );
    expect(find.text('Bom dia, Maria!'), findsOneWidget);
    expect(find.text('Quarta, 4 de novembro'), findsOneWidget);
  });

  testWidgets('without pending items the Needs you block is hidden', (
    tester,
  ) async {
    await pumpReady(tester, testClientHome(today: testBeforeRouteSection));

    expect(find.text('Precisa de você'), findsNothing);
  });

  testWidgets('before route groups by van with the absent child', (
    tester,
  ) async {
    await pumpReady(
      tester,
      testClientHome(
        today: testBeforeRouteSection,
        enabledShortcuts: HomeShortcut.values.toSet(),
      ),
    );

    expect(find.text('Van de Carlos · manhã'), findsOneWidget);
    expect(find.text('Sprinter SDF4E21 · sai às 6h20'), findsOneWidget);
    expect(find.text('Ana não vai hoje'), findsOneWidget);
    expect(find.text('Desfazer'), findsOneWidget);
    expect(find.text('Na volta, Pedro desce na casa da avó'), findsOneWidget);
    expect(find.text('Van de Rita · tarde'), findsOneWidget);
    expect(find.text('Lucas · embarque 11h40'), findsOneWidget);
    expect(find.text('Bia e Davi sem rota hoje'), findsOneWidget);
    expect(find.text('Bia vai com você · Davi ainda sem van'), findsOneWidget);
  });

  testWidgets('a live van shows the ETA and the trip stages', (tester) async {
    await pumpReady(
      tester,
      testClientHome(
        today: testLiveSection(),
        enabledShortcuts: HomeShortcut.values.toSet(),
      ),
    );

    expect(find.byType(LiveVanCard), findsOneWidget);
    expect(find.text('AO VIVO · IDA'), findsOneWidget);
    expect(find.text('6 min'), findsOneWidget);
    expect(find.text('até a sua parada · ~6h46'), findsOneWidget);
    expect(find.text('Escola'), findsOneWidget);
    expect(find.text('Falar com Carlos'), findsOneWidget);
  });

  testWidgets('an approaching van shows the map, crew and child day', (
    tester,
  ) async {
    await pumpReady(
      tester,
      testClientHome(
        today: testLiveSection(approaching: true),
        headline: HomeHeadline.vanArriving,
        enabledShortcuts: HomeShortcut.values.toSet(),
      ),
    );

    expect(find.text('A van está chegando'), findsOneWidget);
    expect(find.text('Mapa ilustrativo'), findsOneWidget);
    expect(
      find.text('Pedro embarca nesta parada · Ana não vai hoje'),
      findsOneWidget,
    );
    expect(find.text('Carlos e Marcos na van'), findsOneWidget);
    expect(find.text('O dia de Pedro'), findsOneWidget);
    expect(find.text('Hoje: casa da avó'), findsOneWidget);
  });

  testWidgets('after arrival it confirms and lists the day newest first', (
    tester,
  ) async {
    await pumpReady(
      tester,
      testClientHome(
        today: testArrivedSection,
        headline: HomeHeadline.allGood,
        enabledShortcuts: HomeShortcut.values.toSet(),
      ),
    );

    expect(find.text('Tudo certo por aqui'), findsOneWidget);
    expect(find.text('CONFIRMADO ÀS 7H18'), findsOneWidget);
    expect(find.text('Pedro chegou à escola'), findsOneWidget);
    expect(
      topOf(tester, 'Desceu na escola'),
      lessThan(topOf(tester, 'Rota iniciada')),
    );
    expect(find.text('por Marcos'), findsNWidgets(2));
    expect(find.text('Ana não vai hoje'), findsOneWidget);
  });

  testWidgets('no route today shows the next route and the week', (
    tester,
  ) async {
    await pumpReady(
      tester,
      testClientHome(
        today: testNoRouteTodaySection,
        headline: HomeHeadline.goodWeekend,
        date: testSaturdayMorning,
        enabledShortcuts: HomeShortcut.values.toSet(),
        needsYou: prioritized([
          testRenewal,
          testInspectionExpired,
          testRateCarlos,
        ]),
      ),
    );

    expect(find.text('Bom fim de semana!'), findsOneWidget);
    expect(find.text('Sem rota hoje'), findsOneWidget);
    expect(find.text('Próxima: Segunda, 6h40'), findsOneWidget);
    expect(find.text('seg'), findsOneWidget);
    expect(find.text('Quarta: a volta é com você'), findsOneWidget);
    expect(find.text('Renovação para 2027'), findsOneWidget);
    expect(find.text('Vistoria da van venceu'), findsOneWidget);
    expect(find.text('Como está a van de Carlos?'), findsOneWidget);
  });

  group('needs you', () {
    testWidgets('the contract to sign is featured before other items', (
      tester,
    ) async {
      await pumpReady(
        tester,
        testClientHome(
          today: testLiveSection(),
          enabledShortcuts: HomeShortcut.values.toSet(),
          needsYou: prioritized([
            testAnaMonthlyFee,
            testRitaProposal,
            testContractToSign,
          ]),
        ),
      );

      expect(find.text('Contrato de Pedro pronto'), findsOneWidget);
      expect(find.text('Revisar e assinar'), findsOneWidget);
      expect(find.text('Nova proposta para Pedro'), findsOneWidget);
      expect(find.text('Mensalidade de Ana'), findsOneWidget);
      expect(find.text('Vence amanhã'), findsOneWidget);
      expect(
        topOf(tester, 'Contrato de Pedro pronto'),
        lessThan(topOf(tester, 'Mensalidade de Ana')),
      );
      expect(find.text('Ver tudo'), findsNothing);
    });

    testWidgets('more than three items shows See all', (tester) async {
      await pumpReady(
        tester,
        testClientHome(
          today: testNoRouteTodaySection,
          enabledShortcuts: HomeShortcut.values.toSet(),
          needsYou: prioritized([
            testRenewal,
            testInspectionExpired,
            testRateCarlos,
            testAnaMonthlyFee,
          ]),
        ),
      );

      expect(find.text('Ver tudo'), findsOneWidget);
      expect(find.text('Como está a van de Carlos?'), findsNothing);
    });
  });

  group('shortcuts', () {
    testWidgets('the six shortcuts are always visible', (tester) async {
      await pumpReady(tester, testClientHome());

      expect(find.byType(HomeShortcutTile), findsNWidgets(6));
    });

    testWidgets('a disabled shortcut does nothing', (tester) async {
      await pumpReady(tester, testClientHome());

      await tester.tap(find.text('Avisar falta'));
      await tester.pumpAndSettle();

      expect(find.byType(VanepComingSoonPage), findsNothing);
    });

    testWidgets('an enabled shortcut without screen opens coming soon', (
      tester,
    ) async {
      await pumpReady(tester, testClientHome());

      await tester.tap(find.text('Propostas'));
      await tester.pumpAndSettle();

      expect(find.byType(VanepComingSoonPage), findsOneWidget);
    });
  });
}
