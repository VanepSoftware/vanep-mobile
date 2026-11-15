import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_comparison_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';

import '../../../core/ui/localized_harness.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';

const nbsp = ' ';

void main() {
  Future<void> pumpComparison(
    WidgetTester tester, {
    required Proposal previous,
    required Proposal current,
  }) async {
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      localizedHarness(
        ProposalComparisonPage(previous: previous, current: current),
      ),
    );
  }

  testWidgets('what changed is one table with the versions as columns', (
    tester,
  ) async {
    await pumpComparison(tester, previous: testVersion1, current: testVersion2);

    expect(find.text('O que mudou'), findsNothing);
    expect(find.textContaining('no total'), findsNothing);
    final table = find.byType(ComparisonTable);
    Finder inTable(String text) =>
        find.descendant(of: table, matching: find.text(text));
    expect(inTable('VERSÃO 1'), findsOneWidget);
    expect(inTable('VERSÃO 2'), findsOneWidget);
    expect(inTable('Valor'), findsOneWidget);
    expect(inTable('R\$${nbsp}340/mês · 12x'), findsOneWidget);
    expect(inTable('R\$${nbsp}300/mês · 12x'), findsOneWidget);
    expect(inTable('Período do contrato'), findsOneWidget);
    expect(inTable('1 fev a 17 dez 2027'), findsOneWidget);
    expect(inTable('15 fev a 17 dez 2027'), findsOneWidget);
    expect(find.text('Antes'), findsNothing);
    expect(find.text('Agora'), findsNothing);
  });

  testWidgets('each changed row points from the old value to the new', (
    tester,
  ) async {
    await pumpComparison(tester, previous: testVersion1, current: testVersion2);

    final rows = find.byType(ComparisonRow);
    expect(
      find.descendant(of: rows, matching: find.byIcon(Icons.arrow_forward)),
      findsNWidgets(tester.widgetList(rows).length),
    );
    expect(
      find.descendant(
        of: find.byType(ComparisonVersionHeader),
        matching: find.byIcon(Icons.arrow_forward),
      ),
      findsNothing,
    );
    final before = tester.getRect(find.text('R\$${nbsp}340/mês · 12x'));
    final arrow = tester.getRect(
      find.descendant(
        of: find.widgetWithText(ComparisonRow, 'Valor'),
        matching: find.byIcon(Icons.arrow_forward),
      ),
    );
    final after = tester.getRect(find.text('R\$${nbsp}300/mês · 12x'));
    expect(before.right, lessThanOrEqualTo(arrow.left));
    expect(arrow.right, lessThanOrEqualTo(after.left));
  });

  testWidgets('a schedule change shows one leg per line', (tester) async {
    final later = TestProposal(
      token: 'proposal-later',
      version: 2,
      installmentAmountCents: testVersion1.installmentAmountCents,
      totalAmountCents: testVersion1.totalAmountCents,
      items: [
        TestProposalItem(
          slots: [
            for (final weekday in weekdaysMondayToFriday) ...[
              TestScheduleSlot(weekday: weekday, leg: RouteLeg.outbound),
              TestScheduleSlot(
                weekday: weekday,
                leg: RouteLeg.homebound,
                pickupTime: const ClockTime(hour: 18, minute: 30),
              ),
            ],
          ],
        ),
      ],
    );
    final earlier = TestProposal(
      token: 'proposal-earlier',
      installmentAmountCents: testVersion1.installmentAmountCents,
      totalAmountCents: testVersion1.totalAmountCents,
      items: [TestProposalItem()],
    );

    await pumpComparison(tester, previous: earlier, current: later);

    final table = find.byType(ComparisonTable);
    Finder inTable(String text) =>
        find.descendant(of: table, matching: find.text(text));
    expect(inTable('Horários'), findsOneWidget);
    expect(inTable('Volta · Seg a sex'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ScheduleComparisonRow),
        matching: find.byIcon(Icons.arrow_forward),
      ),
      findsOneWidget,
    );
    expect(inTable('18:00'), findsOneWidget);
    expect(inTable('18:30'), findsOneWidget);
    expect(
      find.descendant(of: table, matching: find.textContaining('Ida')),
      findsNothing,
    );
    expect(inTable('Valor'), findsNothing);
  });

  testWidgets('a change of one sibling says whose it is', (tester) async {
    List<TestScheduleSlot> fridayAt(ClockTime homebound) => [
      TestScheduleSlot(
        weekday: Weekday.friday,
        leg: RouteLeg.homebound,
        pickupTime: homebound,
      ),
    ];
    Proposal versionWith(ClockTime anaHomebound, {int version = 1}) {
      return TestProposal(
        token: 'proposal-siblings-$version',
        version: version,
        installmentAmountCents: testVersion1.installmentAmountCents,
        totalAmountCents: testVersion1.totalAmountCents,
        items: [
          TestProposalItem(
            dependentToken: 'dep-ana',
            dependentFirstName: 'Ana',
            slots: fridayAt(anaHomebound),
          ),
          TestProposalItem(
            dependentToken: 'dep-pedro',
            dependentFirstName: 'Pedro',
            slots: fridayAt(const ClockTime(hour: 18, minute: 0)),
          ),
        ],
      );
    }

    await pumpComparison(
      tester,
      previous: versionWith(const ClockTime(hour: 18, minute: 0)),
      current: versionWith(const ClockTime(hour: 17, minute: 30), version: 2),
    );

    expect(
      find.descendant(
        of: find.byType(ComparisonTable),
        matching: find.text('Ana · Volta · Sex'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('versions without changes say so', (tester) async {
    await pumpComparison(tester, previous: testVersion2, current: testVersion2);

    expect(find.text('Nada mudou entre as duas versões.'), findsOneWidget);
    expect(find.byType(ComparisonTable), findsNothing);
  });
}
