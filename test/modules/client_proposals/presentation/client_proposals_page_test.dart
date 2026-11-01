import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/client_proposals_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/client_proposals_page.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/awaiting_request_card.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/child_filter_button.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/child_filter_sheet.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/client_proposals_skeleton.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/closed_proposal_card.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/pending_proposal_card.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../../core/ui/localized_harness.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockClientProposalsCubit cubit;
  late List<String> calls;

  setUp(() {
    cubit = MockClientProposalsCubit();
    calls = [];
    when(cubit.loadProposals).thenAnswer((_) async {});
    when(cubit.loadMoreClosed).thenAnswer((_) async {});
    when(() => cubit.cancelRequest(any())).thenAnswer((_) async {});
    when(() => cubit.selectChild(any())).thenAnswer((_) async {});
  });

  ClientProposalsActions actions() => ClientProposalsActions(
    onSearchVansTapped: () => calls.add('search'),
    onSeeProposal: (request) async => calls.add('proposal ${request.token}'),
    onSeeRequest: (request) async => calls.add('request ${request.token}'),
    onChat: (request) async => calls.add('chat ${request.token}'),
  );

  Future<void> pumpPage(
    WidgetTester tester,
    ClientProposalsState state, {
    Stream<ClientProposalsState> changes = const Stream.empty(),
  }) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(cubit, changes, initialState: state);
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<ClientProposalsCubit>.value(
          value: cubit,
          child: ClientProposalsPage(actions: actions()),
        ),
      ),
    );
  }

  ClientProposalsState readyWith(
    ClientProposals proposals, {
    String? selectedChildToken,
    ProposalsTab tab = ProposalsTab.open,
    NegotiationFailure? actionFailure,
  }) {
    return ClientProposalsState(
      status: ClientProposalsStatus.ready,
      proposals: proposals,
      selectedChildToken: selectedChildToken,
      tab: tab,
      actionFailure: actionFailure,
    );
  }

  testWidgets('shows the skeleton while the first load runs', (tester) async {
    await pumpPage(
      tester,
      const ClientProposalsState(status: ClientProposalsStatus.loading),
    );

    expect(find.byType(ClientProposalsSkeleton), findsOneWidget);
  });

  testWidgets('a failed load offers to try again', (tester) async {
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

  testWidgets('groups the open negotiations by whose turn it is', (
    tester,
  ) async {
    await pumpPage(tester, readyWith(testClientProposals()));

    expect(find.text('4 de 5 solicitações abertas'), findsOneWidget);
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.byType(PendingProposalCard), findsOneWidget);
    expect(find.text('Aguardando resposta'), findsOneWidget);
    expect(find.byType(AwaitingRequestCard), findsNWidgets(3));
  });

  testWidgets('the tabs show the counts and switch tab', (tester) async {
    await pumpPage(tester, readyWith(testClientProposals(closedCount: 25)));

    expect(find.text('4'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);

    await tester.tap(find.text('Encerradas'));
    verify(() => cubit.selectTab(ProposalsTab.closed)).called(1);
  });

  testWidgets('a child filter changes the tabs but not the account counter', (
    tester,
  ) async {
    await pumpPage(
      tester,
      readyWith(testClientProposals(), selectedChildToken: testPedro.token),
    );

    expect(find.text('Pedro Souza'), findsOneWidget);
    expect(find.text('4 de 5 solicitações abertas'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Marta Dias'), findsNothing);
  });

  testWidgets('the filter is hidden with a single child', (tester) async {
    await pumpPage(
      tester,
      readyWith(testClientProposals(children: const [testPedro])),
    );

    expect(find.byType(ChildFilterButton), findsNothing);
  });

  testWidgets('the filter sheet lists each child with the open counts', (
    tester,
  ) async {
    await pumpPage(tester, readyWith(testClientProposals()));

    await tester.tap(find.byType(ChildFilterButton));
    await tester.pumpAndSettle();

    final sheet = find.byType(ChildFilterSheet);
    Finder inSheet(String text) => find.descendant(
      of: sheet,
      matching: find.text(text, findRichText: true),
    );
    expect(inSheet('Ver propostas de'), findsOneWidget);
    expect(inSheet('4 em aberto'), findsOneWidget);
    expect(inSheet('1 para responder · 1 aguardando'), findsOneWidget);
    expect(inSheet('1 para responder'), findsOneWidget);
    expect(inSheet('1 aguardando'), findsOneWidget);
    expect(inSheet('Pedro Souza · 11 anos'), findsOneWidget);

    await tester.tap(inSheet('Lucas Souza · 6 anos'));
    await tester.pumpAndSettle();

    verify(() => cubit.selectChild(testLucas.token)).called(1);
    expect(find.byType(ChildFilterSheet), findsNothing);
  });

  testWidgets(
    'the closed tab lists the outcomes and asks for more at the end',
    (tester) async {
      await pumpPage(
        tester,
        readyWith(
          testClientProposals(hasMoreClosed: true),
          tab: ProposalsTab.closed,
        ),
      );

      expect(find.byType(ClosedProposalCard), findsNWidgets(2));
      expect(find.text('Encerrada por você'), findsOneWidget);
      expect(find.text('Aceita'), findsOneWidget);
      expect(find.text('Pendentes'), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      verify(cubit.loadMoreClosed).called(greaterThan(0));
    },
  );

  testWidgets('opens the proposal, the request and the chat', (tester) async {
    await pumpPage(tester, readyWith(testClientProposals()));

    await tester.tap(find.text('Conversar'));
    await tester.tap(find.text('Ver proposta').first);
    await tester.tap(find.text('Ver pedido').first);

    await tester.pump();

    expect(calls, [
      'chat ${testProposalForSiblings.token}',
      'proposal ${testProposalForSiblings.token}',
      'request ${testRequestForLucas.token}',
    ]);
    verify(cubit.loadProposals).called(2);
  });

  testWidgets('a negotiation without a conversation has no chat button', (
    tester,
  ) async {
    await pumpPage(
      tester,
      readyWith(
        testClientProposals(
          open: [
            TestClientServiceRequest(
              status: ServiceRequestStatus.answered,
              conversationToken: null,
              currentProposal: TestProposalSummary(),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Ver proposta'), findsOneWidget);
    expect(find.text('Conversar'), findsNothing);
  });

  testWidgets('cancelling a request asks to confirm first', (tester) async {
    await pumpPage(
      tester,
      readyWith(testClientProposals(open: [testRequestForLucas])),
    );

    await tester.tap(find.text('Cancelar pedido'));
    await tester.pumpAndSettle();

    expect(find.text('Cancelar pedido?'), findsOneWidget);
    expect(
      find.text('O pedido para João Lima é encerrado e vai para Encerradas.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    verifyNever(() => cubit.cancelRequest(any()));

    await tester.tap(find.text('Cancelar pedido'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar pedido').last);
    await tester.pumpAndSettle();

    verify(() => cubit.cancelRequest(testRequestForLucas.token)).called(1);
  });

  testWidgets('a failed action shows the message of the back', (tester) async {
    final changes = StreamController<ClientProposalsState>();
    addTearDown(changes.close);
    await pumpPage(
      tester,
      readyWith(testClientProposals()),
      changes: changes.stream,
    );

    changes.add(
      readyWith(
        testClientProposals(),
        actionFailure: const NegotiationConflictFailure(
          detail: 'O motorista já respondeu.',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('O motorista já respondeu.'), findsOneWidget);
  });

  testWidgets('without open negotiations it offers to find a van', (
    tester,
  ) async {
    await pumpPage(
      tester,
      readyWith(testClientProposals(open: const <ClientServiceRequest>[])),
    );

    expect(find.text('Nenhuma proposta em aberto'), findsOneWidget);
    await tester.tap(find.text('Procurar van'));
    await tester.tap(find.byTooltip('Buscar mais vans'));

    expect(calls, ['search', 'search']);
  });

  testWidgets(
    'closed ones still loading show the spinner, not the empty state',
    (tester) async {
      await tester.pumpWidget(
        localizedHarness(
          const Scaffold(
            body: ClosedProposalsTab(
              feed: ProposalsFeed(),
              isLoadingMore: true,
            ),
          ),
        ),
      );

      expect(find.text('Nenhuma proposta encerrada'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );
}
