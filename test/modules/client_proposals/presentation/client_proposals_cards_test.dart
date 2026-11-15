import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/awaiting_request_card.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/closed_proposal_card.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/pending_proposal_card.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../../core/ui/localized_host.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';

const nbsp = ' ';

void main() {
  late List<String> taps;

  setUp(() => taps = []);

  Future<void> pumpPending(
    WidgetTester tester,
    ClientServiceRequest request, {
    bool canChat = true,
  }) {
    return tester.pumpWidget(
      localizedHost(
        PendingProposalCard(
          request: request,
          now: testProposalsNow,
          onSeeProposal: () => taps.add('proposal'),
          onChat: canChat ? () => taps.add('chat') : null,
        ),
      ),
    );
  }

  group('a pending proposal', () {
    testWidgets('shows the driver, the children, the days and the price', (
      tester,
    ) async {
      await pumpPending(tester, testProposalForSiblings);

      expect(find.text('Carlos Souza'), findsOneWidget);
      expect(find.text('4,8'), findsOneWidget);
      expect(
        find.text('Para Ana e Pedro · Colégio Delta, tarde'),
        findsOneWidget,
      );
      expect(find.text('Seg a sex · a partir de 15 fev'), findsOneWidget);
      expect(
        find.text('R\$${nbsp}300/mês · 12x', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Expira em 6 dias'), findsOneWidget);
      expect(find.textContaining('antes'), findsNothing);
      expect(find.textContaining('Master'), findsNothing);
    });

    testWidgets('children at different schools show one line each', (
      tester,
    ) async {
      await pumpPending(
        tester,
        TestClientServiceRequest(
          status: ServiceRequestStatus.answered,
          currentProposal: TestProposalSummary(),
          items: [
            testItemFor(testAna),
            testItemFor(
              testPedro,
              schoolName: 'Escola Alfa',
              shift: SchoolShift.morning,
            ),
          ],
        ),
      );

      expect(find.text('Para Ana · Colégio Delta, tarde'), findsOneWidget);
      expect(find.text('Para Pedro · Escola Alfa, manhã'), findsOneWidget);
    });

    testWidgets('a shift that changes between the days varies', (tester) async {
      await pumpPending(
        tester,
        TestClientServiceRequest(
          status: ServiceRequestStatus.answered,
          currentProposal: TestProposalSummary(),
          items: [
            testItemFor(
              testAna,
              days: const [
                TestRequestedDay(
                  weekday: Weekday.monday,
                  schoolShift: SchoolShift.morning,
                ),
                TestRequestedDay(weekday: Weekday.wednesday),
              ],
            ),
          ],
        ),
      );

      expect(
        find.text('Para Ana · Colégio Delta, turno varia'),
        findsOneWidget,
      );
      expect(find.textContaining('Seg, Qua · a partir de'), findsOneWidget);
    });

    testWidgets('a driver without a rating shows only the name', (
      tester,
    ) async {
      await pumpPending(
        tester,
        TestClientServiceRequest(
          status: ServiceRequestStatus.answered,
          driverRating: null,
          currentProposal: TestProposalSummary(),
        ),
      );

      expect(find.text('Carlos Souza'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.textContaining('Nov'), findsNothing);
    });

    testWidgets('opens the proposal and the chat', (tester) async {
      await pumpPending(tester, testProposalForSiblings);

      await tester.tap(find.text('Conversar'));
      await tester.tap(find.text('Ver proposta'));

      expect(taps, ['chat', 'proposal']);
    });

    testWidgets('without a conversation there is no chat button', (
      tester,
    ) async {
      await pumpPending(tester, testProposalForSiblings, canChat: false);

      expect(find.text('Conversar'), findsNothing);
      expect(find.text('Ver proposta'), findsOneWidget);
    });
  });

  group('a negotiation waiting for the driver', () {
    Future<void> pumpAwaiting(
      WidgetTester tester,
      ClientServiceRequest request,
    ) {
      return tester.pumpWidget(
        localizedHost(
          AwaitingRequestCard(
            request: request,
            now: testProposalsNow,
            onCancel: () => taps.add('cancel'),
            onSeeRequest: () => taps.add('request'),
            onSeeProposal: () => taps.add('proposal'),
          ),
        ),
      );
    }

    testWidgets('a sent request shows when it was sent and the time left', (
      tester,
    ) async {
      await pumpAwaiting(tester, testRequestForLucas);

      expect(find.text('João Lima'), findsOneWidget);
      expect(find.text('Para Lucas · enviado ontem'), findsOneWidget);
      expect(find.text('Faltam 52h'), findsOneWidget);

      await tester.tap(find.text('Cancelar pedido'));
      await tester.tap(find.text('Ver pedido'));

      expect(taps, ['cancel', 'request']);
    });

    testWidgets('an adjustment asked shows the validity of the version', (
      tester,
    ) async {
      await pumpAwaiting(tester, testAdjustmentForPedro);

      expect(find.text('Rita Alves'), findsOneWidget);
      expect(find.text('Ajuste solicitado'), findsOneWidget);
      expect(find.text('Expira em 3 dias'), findsOneWidget);
      expect(find.text('Cancelar pedido'), findsNothing);

      await tester.tap(find.text('Ver proposta'));

      expect(taps, ['proposal']);
    });
  });

  testWidgets('a closed negotiation shows the outcome without a price', (
    tester,
  ) async {
    final outcomes = {
      ServiceRequestStatus.converted: 'Aceita',
      ServiceRequestStatus.declined: 'Recusada pelo motorista',
      ServiceRequestStatus.withdrawn: 'Encerrada por você',
      ServiceRequestStatus.expired: 'Expirada',
    };

    for (final MapEntry(key: status, value: outcome) in outcomes.entries) {
      await tester.pumpWidget(
        localizedHost(
          ClosedProposalCard(
            request: TestClientServiceRequest(
              status: status,
              items: [testItemFor(testAna), testItemFor(testPedro)],
              currentProposal: status == ServiceRequestStatus.converted
                  ? TestProposalSummary()
                  : null,
            ),
          ),
        ),
      );

      expect(find.text('Carlos Souza'), findsOneWidget);
      expect(find.text('Para Ana e Pedro'), findsOneWidget);
      expect(find.text(outcome), findsOneWidget);
      expect(find.textContaining('R\$'), findsNothing);
    }
  });
}
