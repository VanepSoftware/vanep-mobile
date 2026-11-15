import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/ui/vanep_current_dot.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_proposal_detail.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_proposal_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_service_request_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_composer_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/request_decline_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/pages/driver_proposal_page.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/pages/driver_service_request_page.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/driver_negotiation_actions.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../../core/ui/localized_harness.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

const nbsp = '\u00a0';

void main() {
  late List<String> calls;
  RequestDeclineOutcome? declineOutcome;
  ProposalComposerOutcome? composeOutcome;

  final requestWithNotes = TestDriverServiceRequest(
    token: 'request-new',
    notes: 'A Alice sai mais cedo às sextas.',
    createdAt: DateTime(2026, 10, 1, 8),
    items: newRequestForSiblings.items,
  );

  DriverNegotiationActions actions() => DriverNegotiationActions(
    onChat: (DriverServiceRequest request) async =>
        calls.add('chat ${request.conversationToken}'),
    onDecline: (DriverServiceRequest request) async {
      calls.add('decline ${request.token}');
      return declineOutcome;
    },
    onComposeProposal: (request, previousVersion) async {
      calls.add('compose ${previousVersion?.version}');
      return composeOutcome;
    },
  );

  setUp(() {
    calls = [];
    declineOutcome = null;
    composeOutcome = null;
  });

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget pushedFrom(Widget page) {
    return Builder(
      builder: (context) => TextButton(
        onPressed: () =>
            Navigator.of(context)
                .push(MaterialPageRoute<bool>(builder: (_) => page)),
        child: const Text('abrir'),
      ),
    );
  }

  group('DriverServiceRequestPage', () {
    late MockDriverServiceRequestCubit cubit;

    setUp(() {
      cubit = MockDriverServiceRequestCubit();
      when(() => cubit.load()).thenAnswer((_) async {});
    });

    Future<void> pumpRequest(
      WidgetTester tester,
      DriverServiceRequest request,
    ) async {
      useTallScreen(tester);
      whenListen(
        cubit,
        const Stream<DriverServiceRequestState>.empty(),
        initialState: DriverServiceRequestState(
          status: DriverServiceRequestStatus.ready,
          request: request,
        ),
      );
      await tester.pumpWidget(
        localizedHarness(
          pushedFrom(
            BlocProvider<DriverServiceRequestCubit>.value(
              value: cubit,
              child: DriverServiceRequestPage(
                actions: actions(),
                clock: () => DateTime(2026, 10, 2, 9),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the students by first name and age', (tester) async {
      await pumpRequest(tester, requestWithNotes);

      expect(find.text('Maria'), findsOneWidget);
      expect(find.text('Chegou ontem'), findsOneWidget);
      expect(find.text('Theo'), findsWidgets);
      expect(find.text('9 anos · Colégio Delta, tarde'), findsOneWidget);
      expect(find.text('7 anos · Colégio Delta, tarde'), findsOneWidget);
    });

    testWidgets('the route shows only the neighborhood', (tester) async {
      await pumpRequest(tester, requestWithNotes);

      expect(find.text('Trajeto'), findsOneWidget);
      expect(find.text('Taguatinga'), findsWidgets);
      expect(find.text('Endereço completo após o aceite.'), findsOneWidget);
    });

    testWidgets('shows the days, the desired start and the message', (
      tester,
    ) async {
      await pumpRequest(tester, requestWithNotes);

      expect(find.text('Dias e trechos'), findsOneWidget);
      expect(find.text('Início desejado'), findsOneWidget);
      expect(find.text('Mensagem da família'), findsOneWidget);
      expect(find.text('A Alice sai mais cedo às sextas.'), findsOneWidget);
    });

    testWidgets('a request outbound only on wednesday shows its grid', (
      tester,
    ) async {
      await pumpRequest(
        tester,
        TestDriverServiceRequest(
          items: [TestDriverRequestItem(days: wednesdayOutboundOnly)],
        ),
      );

      bool isMarked(String label) => tester
          .widget<WeekLegCellButton>(
            find.byWidgetPredicate(
              (widget) => widget is WeekLegCellButton && widget.label == label,
            ),
          )
          .cell
          .isSelected;

      expect(isMarked('Quarta, Ida'), isTrue);
      expect(isMarked('Quarta, Volta'), isFalse);
    });

    testWidgets('chat opens the conversation of the request', (tester) async {
      await pumpRequest(tester, requestWithNotes);

      await tester.tap(find.text('Conversar'));

      expect(calls, ['chat conversation-1']);
    });

    testWidgets('an open request offers decline and build proposal', (
      tester,
    ) async {
      await pumpRequest(tester, requestWithNotes);

      expect(find.text('Recusar'), findsOneWidget);
      expect(find.text('Montar proposta'), findsOneWidget);
    });

    testWidgets('a declined request goes back to the list', (tester) async {
      declineOutcome = RequestDeclineOutcome.declined;
      await pumpRequest(tester, requestWithNotes);

      await tester.tap(find.text('Recusar'));
      await tester.pumpAndSettle();

      expect(calls, ['decline request-new']);
      expect(find.text('abrir'), findsOneWidget);
    });

    testWidgets('an outdated decline reloads the request', (tester) async {
      declineOutcome = RequestDeclineOutcome.outdated;
      await pumpRequest(tester, requestWithNotes);

      await tester.tap(find.text('Recusar'));
      await tester.pumpAndSettle();

      verify(() => cubit.load()).called(1);
    });

    testWidgets('a sent proposal goes back to the list', (tester) async {
      composeOutcome = ProposalComposerOutcome.sent;
      await pumpRequest(tester, requestWithNotes);

      await tester.tap(find.text('Montar proposta'));
      await tester.pumpAndSettle();

      expect(calls, ['compose null']);
      expect(find.text('abrir'), findsOneWidget);
    });

    testWidgets('an answered request has no footer', (tester) async {
      await pumpRequest(
        tester,
        TestDriverServiceRequest(status: ServiceRequestStatus.answered),
      );

      expect(find.text('Montar proposta'), findsNothing);
    });
  });

  group('DriverProposalPage', () {
    late MockDriverProposalCubit cubit;

    setUp(() {
      cubit = MockDriverProposalCubit();
      when(() => cubit.load()).thenAnswer((_) async {});
    });

    Future<void> pumpProposal(
      WidgetTester tester,
      DriverProposalDetail detail,
    ) async {
      useTallScreen(tester);
      whenListen(
        cubit,
        const Stream<DriverProposalState>.empty(),
        initialState: DriverProposalState(
          status: DriverProposalStatus.ready,
          detail: detail,
        ),
      );
      await tester.pumpWidget(
        localizedHarness(
          pushedFrom(
            BlocProvider<DriverProposalCubit>.value(
              value: cubit,
              child: DriverProposalPage(
                actions: actions(),
                clock: () => DateTime(2026, 10, 4, 9),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    final adjustment = DriverProposalDetail(
      request: adjustmentRequest,
      proposal: versionWithAdjustment,
      versions: [versionWithAdjustment],
    );

    DriverProposalDetail adjustmentOf(TestProposalAdjustment request) {
      final proposal = TestProposal(
        serviceRequestToken: 'request-adjust',
        adjustments: [request],
      );
      return DriverProposalDetail(
        request: adjustmentRequest,
        proposal: proposal,
        versions: [proposal],
      );
    }

    testWidgets('the adjustment card names the subject, the time and note', (
      tester,
    ) async {
      await pumpProposal(
        tester,
        adjustmentOf(
          TestProposalAdjustment(
            createdAt: DateTime(2026, 10, 4, 8, 40),
            note: 'Consegue um pouco menos?',
          ),
        ),
      );

      expect(find.text('Ajuste solicitado'), findsOneWidget);
      expect(find.text('AJUSTE SOLICITADO · VALOR'), findsOneWidget);
      expect(find.text('hoje, 8h40'), findsOneWidget);
      expect(find.text('Consegue um pouco menos?'), findsOneWidget);
      expect(find.text('Pedido de ajuste'), findsNothing);
      expect(find.text('Assunto'), findsNothing);
      expect(find.textContaining('Enviado em'), findsNothing);
    });

    testWidgets('a suggested price is compared with the open version', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpProposal(tester, adjustment);

      expect(find.text('Versão 1'), findsWidgets);
      expect(find.text('R\$\u00a0340'), findsOneWidget);
      expect(find.text('Sugerido'), findsOneWidget);
      expect(find.text('R\$ 290'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('De R\\\$\u00a0340 para R\\\$ 290')),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('a schedule suggestion is shown without a comparison', (
      tester,
    ) async {
      await pumpProposal(
        tester,
        adjustmentOf(
          TestProposalAdjustment(
            createdAt: DateTime(2026, 10, 3, 18, 5),
            field: ProposalAdjustmentField.schedule,
            suggestedValue: 'Ida às 6h50',
          ),
        ),
      );

      expect(find.text('AJUSTE SOLICITADO · DIAS E HORÁRIOS'), findsOneWidget);
      expect(find.text('ontem, 18h05'), findsOneWidget);
      expect(find.text('Sugerido'), findsOneWidget);
      expect(find.text('Ida às 6h50'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('without a suggested value only the subject and note show', (
      tester,
    ) async {
      await pumpProposal(
        tester,
        adjustmentOf(
          TestProposalAdjustment(
            createdAt: DateTime(2026, 9, 30, 7),
            field: ProposalAdjustmentField.installments,
            suggestedValue: null,
            note: 'Dá para fazer em mais vezes?',
          ),
        ),
      );

      expect(find.text('AJUSTE SOLICITADO · PARCELAS'), findsOneWidget);
      expect(find.text('30/09, 7h00'), findsOneWidget);
      expect(find.text('Dá para fazer em mais vezes?'), findsOneWidget);
      expect(find.text('Sugerido'), findsNothing);
      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('the version card shows the monthly price and the total', (
      tester,
    ) async {
      await pumpProposal(tester, adjustment);

      expect(
        find.text('R\$${nbsp}340/mês · 12x', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('R\$${nbsp}4.080'), findsOneWidget);
      expect(find.textContaining('no total'), findsNothing);
    });

    testWidgets('the version is marked with the blue dot, never the word', (
      tester,
    ) async {
      await pumpProposal(tester, adjustment);

      expect(find.text('Versão 1'), findsWidgets);
      expect(find.byType(VanepCurrentDot), findsWidgets);
      expect(find.textContaining('Atual'), findsNothing);
      expect(
        find.text('Uma nova versão substitui a anterior.'),
        findsOneWidget,
      );
      expect(find.text('Histórico'), findsOneWidget);
    });

    testWidgets('there is no keep current and no earnings', (tester) async {
      await pumpProposal(tester, adjustment);

      expect(find.textContaining('Manter'), findsNothing);
      expect(find.textContaining('receberia'), findsNothing);
    });

    testWidgets('new version opens the composer with the open version', (
      tester,
    ) async {
      await pumpProposal(tester, adjustment);

      await tester.tap(find.text('Nova versão'));
      await tester.pumpAndSettle();

      expect(calls, ['compose 1']);
    });

    testWidgets('decline declines the request', (tester) async {
      await pumpProposal(tester, adjustment);

      await tester.tap(find.text('Recusar'));
      await tester.pumpAndSettle();

      expect(calls, ['decline request-adjust']);
    });

    testWidgets('see full proposal opens it read only', (tester) async {
      await pumpProposal(tester, adjustment);

      await tester.tap(find.text('Ver proposta completa'));
      await tester.pumpAndSettle();

      expect(find.text('Proposta'), findsOneWidget);
      expect(find.text('Condições'), findsOneWidget);
      expect(find.text('Nova versão'), findsNothing);
    });

    testWidgets('a proposal waiting for the family has no actions', (
      tester,
    ) async {
      await pumpProposal(
        tester,
        DriverProposalDetail(
          request: awaitingRequest,
          proposal: TestProposal(message: 'Saio às 6h30.'),
          versions: [TestProposal()],
        ),
      );

      expect(find.text('Proposta'), findsOneWidget);
      expect(find.text('Horários'), findsOneWidget);
      expect(find.text('Saio às 6h30.'), findsOneWidget);
      expect(find.text('Recusar'), findsNothing);
      expect(find.text('Nova versão'), findsNothing);
      expect(find.text('Aceitar'), findsNothing);
    });

    testWidgets('the read only proposal names students by first name', (
      tester,
    ) async {
      await pumpProposal(
        tester,
        DriverProposalDetail(
          request: awaitingRequest,
          proposal: TestProposal(),
        ),
      );

      expect(find.text('Theo'), findsOneWidget);
      expect(find.textContaining('Souza'), findsNothing);
    });

    testWidgets('chat opens the conversation of the request', (tester) async {
      await pumpProposal(tester, adjustment);

      await tester.tap(find.byTooltip('Conversar'));

      expect(calls, ['chat conversation-1']);
    });
  });
}
