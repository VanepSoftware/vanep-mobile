import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_accepted_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';

import '../../../core/ui/localized_harness.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';

const nbsp = ' ';

void main() {
  final accepted = TestProposal(
    token: testVersion2.token,
    version: 2,
    status: ProposalStatus.accepted,
    installmentAmountCents: 30000,
    startsOn: DateTime(2027, 2, 15),
    acceptedAt: DateTime(2026, 10, 25, 13, 40),
    items: testVersion2.items,
  );

  Future<void> pumpAccepted(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      localizedHarness(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ProposalAcceptedPage(
                  request: testProposalForSiblings,
                  proposal: accepted,
                ),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('says the contract was generated and sums up the terms', (
    tester,
  ) async {
    await pumpAccepted(tester);

    expect(find.text('Proposta aceita'), findsOneWidget);
    expect(
      find.text(
        'Contrato de Ana e Pedro com Carlos Souza gerado para assinatura.',
      ),
      findsOneWidget,
    );
    expect(find.text('Resumo'), findsOneWidget);
    expect(find.text('R\$${nbsp}300/mês · 12x'), findsOneWidget);
    expect(find.text('15 fev a 17 dez 2027'), findsOneWidget);
    expect(find.text('Seg a sex · ida e volta'), findsOneWidget);
  });

  testWidgets('lists the next steps with the acceptance date only', (
    tester,
  ) async {
    await pumpAccepted(tester);

    expect(find.text('Próximas etapas'), findsOneWidget);
    expect(find.text('Aceite da proposta'), findsOneWidget);
    expect(find.text('25/10 13:40'), findsOneWidget);
    expect(find.text('Sua assinatura'), findsOneWidget);
    expect(find.text('Assinatura do motorista'), findsOneWidget);
    expect(find.text('Início das viagens'), findsOneWidget);
    expect(find.text('15 fev 2027'), findsOneWidget);
    expect(
      find.text(
        'Ao assinar o contrato, as outras negociações de Ana e Pedro são encerradas.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('signing opens coming soon and signing later closes', (
    tester,
  ) async {
    await pumpAccepted(tester);

    await tester.tap(find.text('Revisar e assinar contrato'));
    await tester.pumpAndSettle();
    expect(find.byType(VanepComingSoonPage), findsOneWidget);

    Navigator.of(tester.element(find.byType(VanepComingSoonPage))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assinar depois'));
    await tester.pumpAndSettle();

    expect(find.byType(ProposalAcceptedPage), findsNothing);
  });
}
