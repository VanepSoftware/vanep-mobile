import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_current_dot.dart';
import 'package:vanep_mobile/core/ui/vanep_expiry_chip.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_detail_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_comparison_page.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_detail_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/negotiation_blocks.dart';
import 'package:vanep_mobile/modules/negotiations/presentation/widgets/proposal_sections.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';

import '../../../core/ui/localized_harness.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

const nbsp = ' ';

void main() {
  late MockProposalDetailCubit cubit;
  late List<String> calls;
  late ProposalDeclineOutcome? declineOutcome;

  setUp(() {
    cubit = MockProposalDetailCubit();
    calls = [];
    declineOutcome = null;
    when(cubit.load).thenAnswer((_) async {});
    when(cubit.accept).thenAnswer((_) async {});
    when(cubit.cancelRequest).thenAnswer((_) async {});
    when(() => cubit.showVersion(any())).thenAnswer((_) async {});
  });

  ProposalDetailState proposalState(
    Proposal proposal, {
    List<Proposal>? versions,
  }) {
    return ProposalDetailState(
      status: ProposalDetailStatus.ready,
      proposalToken: proposal.token,
      request: testProposalForSiblings,
      proposal: proposal,
      versions: versions ?? [testVersion1, testVersion2],
    );
  }

  Future<void> pumpDetail(
    WidgetTester tester,
    ProposalDetailState state, {
    Stream<ProposalDetailState> changes = const Stream.empty(),
  }) async {
    tester.view.physicalSize = const Size(430, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(cubit, changes, initialState: state);
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<ProposalDetailCubit>.value(
          value: cubit,
          child: ProposalDetailPage(
            clock: () => testProposalsNow,
            actions: ProposalDetailActions(
              onChat: (request) => calls.add('chat'),
              onAskAdjustment: (request, proposal) async {
                calls.add('adjust ${proposal.version}');
                return true;
              },
              onDecline: (request, proposal) async {
                calls.add('decline ${proposal.version}');
                return declineOutcome;
              },
              onAccepted: (request, proposal) => calls.add('accepted'),
            ),
          ),
        ),
      ),
    );
  }

  group('an open proposal', () {
    testWidgets('shows the header, the driver and the price', (tester) async {
      await pumpDetail(tester, proposalState(testVersion2));

      expect(find.text('Proposta'), findsOneWidget);
      expect(find.text('Para Ana e Pedro'), findsOneWidget);
      expect(find.text('Carlos Souza'), findsOneWidget);
      expect(find.text('4,8'), findsOneWidget);
      expect(find.text('Master 2019 · 15 lugares'), findsOneWidget);
      expect(find.text('VERSÃO 2'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(VanepChip),
          matching: find.text('Expira em 31/10'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('R\$${nbsp}300/mês · 12x', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('R\$${nbsp}3.600 no total'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsNothing);
    });

    testWidgets('shows each student with the school', (tester) async {
      await pumpDetail(tester, proposalState(testVersion2));

      expect(find.text('Alunos'), findsOneWidget);
      expect(find.text('Ana Souza'), findsOneWidget);
      expect(find.text('8 anos · Colégio Delta, tarde'), findsOneWidget);
      expect(find.text('Pedro Souza'), findsOneWidget);
      expect(find.text('11 anos · Colégio Delta, tarde'), findsOneWidget);
      expect(find.textContaining('O motorista vê'), findsNothing);
    });

    testWidgets('shows the days, the times and the terms', (tester) async {
      await pumpDetail(tester, proposalState(testVersion2));

      expect(find.text('Dias e trechos'), findsOneWidget);
      expect(find.byType(VanepWeekLegsGrid<RouteLeg>), findsWidgets);
      final schedule = find.byType(DetailScheduleSection);
      Finder inSchedule(String text) =>
          find.descendant(of: schedule, matching: find.text(text));
      expect(find.byType(ScheduleLegTile), findsNWidgets(2));
      expect(inSchedule('Ida'), findsOneWidget);
      expect(inSchedule('Embarque em casa'), findsOneWidget);
      expect(inSchedule('12:05'), findsOneWidget);
      expect(inSchedule('Volta'), findsOneWidget);
      expect(inSchedule('Saída da escola'), findsOneWidget);
      expect(inSchedule('18:00'), findsOneWidget);
      expect(find.text('15 fev a 17 dez 2027'), findsOneWidget);
      expect(find.text('Dia 10'), findsOneWidget);
      expect(find.text('IPCA na renovação'), findsOneWidget);
      expect(find.text('Aviso de 30 dias + 10%'), findsOneWidget);
      expect(find.text('Taxa de reserva'), findsNothing);
      expect(find.text('Chegada à escola'), findsNothing);
      expect(find.text('Espera no ponto'), findsNothing);
      expect(find.text('Consigo buscar 10 minutos antes.'), findsOneWidget);
      expect(
        find.text(
          'Em caso de aceite, o contrato é gerado para revisão e assinatura.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('times that change between the days show per day', (
      tester,
    ) async {
      final slots = [
        ...roundTripSlotsOn([Weekday.monday, Weekday.tuesday]),
        const TestScheduleSlot(
          weekday: Weekday.wednesday,
          leg: RouteLeg.outbound,
        ),
        const TestScheduleSlot(
          weekday: Weekday.wednesday,
          leg: RouteLeg.homebound,
          pickupTime: ClockTime(hour: 12, minute: 30),
        ),
      ];
      final proposal = TestProposal(
        token: testVersion2.token,
        version: 2,
        items: [TestProposalItem(dependentToken: testAna.token, slots: slots)],
      );

      await pumpDetail(tester, proposalState(proposal, versions: [proposal]));

      final homebound = find.byWidgetPredicate(
        (widget) =>
            widget is ScheduleLegTile && widget.leg == RouteLeg.homebound,
      );
      Finder inHomebound(String text) =>
          find.descendant(of: homebound, matching: find.text(text));
      expect(find.text('12:05'), findsOneWidget);
      expect(inHomebound('Seg'), findsOneWidget);
      expect(inHomebound('Ter'), findsOneWidget);
      expect(inHomebound('Qua'), findsOneWidget);
      expect(inHomebound('18:00'), findsNWidgets(2));
      expect(inHomebound('12:30'), findsOneWidget);
    });

    testWidgets('a reservation fee shows only its amount', (tester) async {
      final proposal = TestProposal(
        token: testVersion2.token,
        version: 2,
        enrollmentFeeCents: 15000,
      );

      await pumpDetail(tester, proposalState(proposal, versions: [proposal]));

      expect(find.text('Taxa de reserva'), findsOneWidget);
      expect(find.text('R\$${nbsp}150'), findsOneWidget);
    });

    testWidgets('a second version shows the difference and the comparison', (
      tester,
    ) async {
      await pumpDetail(tester, proposalState(testVersion2));

      final value = find.byType(ProposalValueCard);
      expect(
        find.descendant(of: value, matching: find.text('R\$${nbsp}480')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: value, matching: find.byIcon(Icons.arrow_downward)),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('R\\\$${nbsp}480 a menos no total')),
        findsOneWidget,
      );
      expect(find.textContaining('versão 1'), findsNothing);
      final compare = find.widgetWithText(ProposalLinkButton, 'Comparar');
      expect(
        find.descendant(
          of: compare,
          matching: find.byIcon(Icons.compare_arrows),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: compare,
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsNothing,
      );

      await tester.tap(find.text('Comparar'));
      await tester.pumpAndSettle();

      expect(find.byType(ProposalComparisonPage), findsOneWidget);
      expect(find.text('R\$${nbsp}340/mês · 12x'), findsOneWidget);
    });

    testWidgets('the value card has the same space above and below', (
      tester,
    ) async {
      await pumpDetail(tester, proposalState(testVersion2));

      final card = tester.getRect(find.byType(ProposalValueCard));
      final chip = tester.getRect(find.byType(VanepChip));
      final compare = tester.getRect(find.text('Comparar'));
      final total = tester.getRect(find.text('R\$${nbsp}3.600 no total'));
      final divider = tester.getRect(
        find.descendant(
          of: find.byType(ProposalValueCard),
          matching: find.byType(Divider),
        ),
      );

      final topGap = chip.top - card.top;
      final bottomGap = card.bottom - compare.bottom;
      expect((bottomGap - topGap).abs(), lessThanOrEqualTo(1));
      final aboveDivider = divider.top - total.bottom;
      final belowDivider = compare.top - divider.bottom;
      expect((aboveDivider - belowDivider).abs(), lessThanOrEqualTo(2));
    });

    testWidgets('a higher total shows the increase without green', (
      tester,
    ) async {
      final pricier = TestProposal(
        token: 'proposal-carlos-v2-pricier',
        serviceRequestToken: testProposalForSiblings.token,
        version: 2,
        installmentAmountCents: 36000,
        totalAmountCents: 432000,
      );
      await pumpDetail(
        tester,
        proposalState(pricier, versions: [testVersion1, pricier]),
      );

      expect(
        find.bySemanticsLabel(RegExp('R\\\$${nbsp}240 a mais no total')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('more installments with the same total is not a discount', (
      tester,
    ) async {
      final previous = TestProposal(
        token: testVersion1.token,
        serviceRequestToken: testProposalForSiblings.token,
        installments: 10,
        installmentAmountCents: 40800,
        totalAmountCents: 408000,
      );
      final current = TestProposal(
        token: 'proposal-carlos-v2-installments',
        serviceRequestToken: testProposalForSiblings.token,
        version: 2,
        installments: 12,
        installmentAmountCents: 34000,
        totalAmountCents: 408000,
      );
      await pumpDetail(
        tester,
        proposalState(current, versions: [previous, current]),
      );

      final summary = find.byType(PriceChangeSummary);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
      expect(find.byIcon(Icons.arrow_upward), findsNothing);
      expect(
        find.descendant(of: summary, matching: find.text('10x')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: summary, matching: find.text('12x')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summary,
          matching: find.byIcon(Icons.arrow_forward),
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('De 10 para 12 parcelas')),
        findsOneWidget,
      );
    });

    testWidgets('a new total and new installments show both', (tester) async {
      final previous = TestProposal(
        token: testVersion1.token,
        serviceRequestToken: testProposalForSiblings.token,
        installments: 10,
        installmentAmountCents: 40800,
        totalAmountCents: 408000,
      );
      final current = TestProposal(
        token: 'proposal-carlos-v2-both',
        serviceRequestToken: testProposalForSiblings.token,
        version: 2,
        installments: 12,
        installmentAmountCents: 29000,
        totalAmountCents: 348000,
      );
      await pumpDetail(
        tester,
        proposalState(current, versions: [previous, current]),
      );

      final summary = find.byType(PriceChangeSummary);
      expect(
        find.descendant(of: summary, matching: find.text('R\$${nbsp}600')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summary,
          matching: find.byIcon(Icons.arrow_downward),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: summary, matching: find.text('10x')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: summary, matching: find.text('12x')),
        findsOneWidget,
      );
    });

    testWidgets('a proposal that expires within two days shows it in amber', (
      tester,
    ) async {
      final expiring = TestProposal(
        token: 'proposal-expiring',
        serviceRequestToken: testProposalForSiblings.token,
        version: 2,
        installmentAmountCents: 30000,
        validUntil: testProposalsNow.add(const Duration(days: 1)),
      );
      await pumpDetail(
        tester,
        proposalState(expiring, versions: [testVersion1, expiring]),
      );

      expect(
        tester.widget<VanepExpiryChip>(find.byType(VanepExpiryChip)).isUrgent,
        isTrue,
      );
    });

    testWidgets('a proposal with days left keeps the expiry gray', (
      tester,
    ) async {
      await pumpDetail(tester, proposalState(testVersion2));

      expect(
        tester.widget<VanepExpiryChip>(find.byType(VanepExpiryChip)).isUrgent,
        isFalse,
      );
    });

    testWidgets('a first version has no comparison', (tester) async {
      await pumpDetail(
        tester,
        proposalState(testVersion2, versions: [testVersion2]),
      );

      expect(find.text('Comparar'), findsNothing);
      expect(find.byIcon(Icons.arrow_downward), findsNothing);
    });

    testWidgets('the history lists the events with the open version', (
      tester,
    ) async {
      await pumpDetail(tester, proposalState(testVersion2));

      expect(find.text('Histórico'), findsOneWidget);
      expect(find.text('Pedido de orçamento'), findsOneWidget);
      expect(find.text('Versão 1'), findsOneWidget);
      expect(find.text('Ajuste pedido · R\$ 290'), findsOneWidget);
      expect(find.text('Versão 2'), findsOneWidget);
      expect(find.text('Atual'), findsNothing);
      final dots = tester.widgetList<VanepCurrentDot>(
        find.byType(VanepCurrentDot),
      );
      expect(
        [for (final dot in dots) dot.isCurrent],
        [false, false, false, true],
      );
      final entries = tester.widgetList<NegotiationHistoryEntry>(
        find.byType(NegotiationHistoryEntry),
      );
      expect(
        [for (final entry in entries) entry.showsConnector],
        [true, true, true, false],
      );
    });

    testWidgets('the footer asks for a change and accepts after confirming', (
      tester,
    ) async {
      await pumpDetail(tester, proposalState(testVersion2));

      final footer = find.byType(DetailFooter);
      Finder inFooter(String text) =>
          find.descendant(of: footer, matching: find.text(text));
      expect(inFooter('Pedir ajuste'), findsOneWidget);
      expect(inFooter('Aceitar'), findsOneWidget);
      expect(inFooter('Recusar proposta'), findsNothing);

      await tester.tap(find.text('Recusar proposta'));
      await tester.pump();
      await tester.tap(find.text('Pedir ajuste'));
      await tester.pump();
      await tester.tap(find.text('Aceitar'));
      await tester.pumpAndSettle();

      expect(find.text('Aceitar proposta?'), findsOneWidget);
      expect(
        find.text(
          'O contrato de Ana e Pedro com Carlos Souza é gerado para revisão e '
          'assinatura.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Aceitar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Conversar'));

      expect(calls, ['decline 2', 'adjust 2', 'chat']);
      verify(cubit.accept).called(1);
      verify(cubit.load).called(1);
    });

    testWidgets('going back from the confirmation does not accept', (
      tester,
    ) async {
      await pumpDetail(tester, proposalState(testVersion2));

      await tester.tap(find.text('Aceitar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      expect(find.text('Aceitar proposta?'), findsNothing);
      verifyNever(cubit.accept);
    });

    testWidgets('a decline that finds the negotiation changed reloads it', (
      tester,
    ) async {
      declineOutcome = ProposalDeclineOutcome.outdated;
      await pumpDetail(tester, proposalState(testVersion2));

      await tester.tap(find.text('Recusar proposta'));
      await tester.pumpAndSettle();

      verify(cubit.load).called(1);
      expect(find.byType(ProposalDetailPage), findsOneWidget);
    });

    testWidgets('an accepted proposal opens the accepted screen', (
      tester,
    ) async {
      final changes = StreamController<ProposalDetailState>();
      addTearDown(changes.close);
      await pumpDetail(
        tester,
        proposalState(testVersion2),
        changes: changes.stream,
      );

      final accepted = TestProposal(
        token: testVersion2.token,
        version: 2,
        status: ProposalStatus.accepted,
      );
      changes.add(
        proposalState(testVersion2)
            .copyWith(proposal: accepted, acceptedProposal: accepted),
      );
      await tester.pump();

      expect(calls, ['accepted']);
    });
  });

  testWidgets('a replaced version is read-only with a link to the current', (
    tester,
  ) async {
    await pumpDetail(tester, proposalState(testVersion1));

    expect(find.text('Aceitar'), findsNothing);
    expect(find.text('Recusar proposta'), findsNothing);
    expect(
      find.text('Esta versão foi substituída por uma mais nova.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ver a versão atual'));

    verify(() => cubit.showVersion(testVersion2.token)).called(1);
  });

  testWidgets('a closed proposal is read-only with the outcome', (
    tester,
  ) async {
    final declined = TestProposal(
      token: testVersion2.token,
      version: 2,
      status: ProposalStatus.declined,
    );

    await pumpDetail(tester, proposalState(declined, versions: [declined]));

    expect(find.text('Aceitar'), findsNothing);
    expect(find.text('Situação: Recusada'), findsOneWidget);
  });

  group('a request without a proposal', () {
    final requestState = ProposalDetailState(
      status: ProposalDetailStatus.ready,
      request: TestClientServiceRequest(
        token: testRequestForLucas.token,
        driverName: 'João Lima',
        notes: 'Lucas sai às 11h30.',
        items: testRequestForLucas.items,
        expiresAt: DateTime(2026, 10, 27, 14),
      ),
    );

    testWidgets('shows what was asked and offers to cancel it', (tester) async {
      await pumpDetail(tester, requestState);

      expect(find.text('Pedido'), findsOneWidget);
      expect(find.text('João Lima'), findsOneWidget);
      expect(find.text('Lucas Souza'), findsOneWidget);
      expect(find.text('Dias e trechos'), findsOneWidget);
      expect(find.text('Início desejado'), findsOneWidget);
      expect(find.text('1 fev 2027'), findsOneWidget);
      expect(find.text('Lucas sai às 11h30.'), findsOneWidget);
      expect(find.text('Prazo de resposta'), findsOneWidget);
      expect(find.text('27/10 14:00'), findsOneWidget);
      expect(find.text('Pedido de orçamento'), findsOneWidget);
      expect(find.text('Aceitar'), findsNothing);

      await tester.tap(find.text('Cancelar pedido'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar pedido').last);
      await tester.pumpAndSettle();

      verify(cubit.cancelRequest).called(1);
    });
  });

  testWidgets('a negotiation that no longer exists says so and leaves', (
    tester,
  ) async {
    final changes = StreamController<ProposalDetailState>();
    addTearDown(changes.close);
    await tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<ProposalDetailCubit>.value(
                    value: cubit,
                    child: ProposalDetailPage(
                      actions: ProposalDetailActions(
                        onChat: (_) {},
                        onAskAdjustment: (_, _) async => false,
                        onDecline: (_, _) async => null,
                        onAccepted: (_, _) {},
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    whenListen(
      cubit,
      changes.stream,
      initialState: proposalState(testVersion2),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    changes.add(
      const ProposalDetailState(status: ProposalDetailStatus.notFound),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProposalDetailPage), findsNothing);
    expect(
      find.text('Esta negociação não está mais disponível.'),
      findsOneWidget,
    );
  });

  testWidgets('a declined proposal leaves the detail', (tester) async {
    tester.view.physicalSize = const Size(430, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      cubit,
      const Stream<ProposalDetailState>.empty(),
      initialState: proposalState(testVersion2),
    );
    await tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider<ProposalDetailCubit>.value(
                    value: cubit,
                    child: ProposalDetailPage(
                      actions: ProposalDetailActions(
                        onChat: (_) {},
                        onAskAdjustment: (_, _) async => false,
                        onDecline: (_, _) async =>
                            ProposalDeclineOutcome.declined,
                        onAccepted: (_, _) {},
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recusar proposta'));
    await tester.pumpAndSettle();

    expect(find.byType(ProposalDetailPage), findsNothing);
    verifyNever(cubit.load);
  });
}
