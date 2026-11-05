import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/client_proposals_page.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/child_filter_button.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/child_filter_sheet.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/client_proposals_skeleton.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/pending_proposal_card.dart';

import '../../../core/ui/localized_harness.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockClientProposalsCubit cubit;
  late int searchTaps;

  setUp(() {
    cubit = MockClientProposalsCubit();
    searchTaps = 0;
    when(cubit.loadProposals).thenAnswer((_) async {});
  });

  Future<void> pumpPage(WidgetTester tester, ClientProposalsState state) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      cubit,
      const Stream<ClientProposalsState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<ClientProposalsCubit>.value(
          value: cubit,
          child: ClientProposalsPage(onSearchVansTapped: () => searchTaps++),
        ),
      ),
    );
  }

  Future<void> pumpReady(
    WidgetTester tester,
    ClientProposals proposals, {
    String? selectedChildToken,
    ProposalsTab tab = ProposalsTab.open,
  }) {
    return pumpPage(
      tester,
      ClientProposalsState(
        status: ClientProposalsStatus.ready,
        proposals: proposals,
        selectedChildToken: selectedChildToken,
        tab: tab,
      ),
    );
  }

  testWidgets('shows the skeleton while the first load runs', (tester) async {
    await pumpPage(
      tester,
      const ClientProposalsState(status: ClientProposalsStatus.loading),
    );

    expect(find.byType(ClientProposalsSkeleton), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    await pumpPage(
      tester,
      const ClientProposalsState(
        status: ClientProposalsStatus.loadFailed,
        failure: ClientProposalsFailure.network,
      ),
    );

    expect(find.byType(VanepErrorView), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    verify(cubit.loadProposals).called(1);
  });

  testWidgets('groups open items into pending and awaiting reply', (
    tester,
  ) async {
    await pumpReady(tester, testClientProposals());

    expect(find.text('3 de 5 solicitações abertas'), findsOneWidget);
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.byType(PendingProposalCard), findsNWidgets(2));
    expect(find.text('4,7 · Master 2019'), findsOneWidget);
    expect(find.text('Nova na Vanep · Ducato 2022'), findsOneWidget);
    expect(find.text('Para Pedro · Colégio Delta, tarde'), findsNWidgets(2));
    expect(find.text('Seg a sex · a partir de 1º fev'), findsOneWidget);
    expect(find.text('Seg, qua, sex · a partir de 15 fev'), findsOneWidget);
    expect(find.textContaining('antes R\$'), findsOneWidget);
    expect(find.text('Expira em 6 dias'), findsOneWidget);
    expect(find.text('Aguardando resposta'), findsOneWidget);
    expect(find.text('Marcos Teixeira'), findsOneWidget);
    expect(find.text('Para Pedro · enviado ontem'), findsOneWidget);
    expect(find.text('Faltam 52h'), findsOneWidget);
    expect(find.text('Cancelar pedido'), findsOneWidget);
  });

  testWidgets('the tabs show the counts and switch tab', (tester) async {
    await pumpReady(tester, testClientProposals());

    expect(find.text('Em aberto'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Encerradas'));
    verify(() => cubit.selectTab(ProposalsTab.closed)).called(1);
  });

  testWidgets('the closed tab lists the outcomes', (tester) async {
    await pumpReady(tester, testClientProposals(), tab: ProposalsTab.closed);

    expect(find.text('Carlos Mendes'), findsOneWidget);
    expect(find.text('Recusada'), findsOneWidget);
    expect(find.text('Expirada'), findsOneWidget);
    expect(find.text('Pendentes'), findsNothing);
  });

  testWidgets('a selected child filters both lists and the counts', (
    tester,
  ) async {
    await pumpReady(
      tester,
      testClientProposals(),
      selectedChildToken: testAna.token,
    );

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Nenhuma proposta em aberto'), findsOneWidget);
    expect(find.text('3 de 5 solicitações abertas'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('the filter is hidden with a single child', (tester) async {
    await pumpReady(tester, testClientProposals(children: const [testPedro]));

    expect(find.byType(ChildFilterButton), findsNothing);
  });

  testWidgets('the filter sheet lists each child with open counts', (
    tester,
  ) async {
    await pumpReady(tester, testClientProposals());

    await tester.tap(find.byType(ChildFilterButton));
    await tester.pumpAndSettle();

    final sheet = find.byType(ChildFilterSheet);
    expect(
      find.descendant(of: sheet, matching: find.text('Ver propostas de')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('3 em aberto')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.text('2 para responder · 1 aguardando'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Nenhuma em aberto')),
      findsNWidgets(2),
    );
    expect(
      find.descendant(
        of: sheet,
        matching: find.text('Pedro · 11 anos', findRichText: true),
      ),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: sheet,
        matching: find.text('Lucas · 6 anos', findRichText: true),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => cubit.selectChild(testLucas.token)).called(1);
    expect(find.byType(ChildFilterSheet), findsNothing);
  });

  testWidgets('without open items it offers to find a van', (tester) async {
    await pumpReady(
      tester,
      testClientProposals(feed: const ProposalsFeed()),
    );

    expect(find.text('Nenhuma proposta em aberto'), findsOneWidget);
    await tester.tap(find.text('Procurar van'));
    expect(searchTaps, 1);
  });

  testWidgets('the search action searches for vans', (tester) async {
    await pumpReady(tester, testClientProposals());

    await tester.tap(find.byTooltip('Buscar mais vans'));
    expect(searchTaps, 1);
  });

  testWidgets('actions without a screen yet open coming soon', (tester) async {
    await pumpReady(tester, testClientProposals());

    await tester.tap(find.text('Ver proposta').first);
    await tester.pumpAndSettle();

    expect(find.byType(VanepComingSoonPage), findsOneWidget);
  });
}
