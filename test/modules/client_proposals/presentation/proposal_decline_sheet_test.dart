import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/proposal_decline_reason.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_decline_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/widgets/proposal_decline_sheet.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';

import '../../../core/ui/localized_harness.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

const nbsp = ' ';

void main() {
  late MockProposalDeclineCubit cubit;

  setUp(() {
    cubit = MockProposalDeclineCubit();
    when(() => cubit.send(reasonLabel: any(named: 'reasonLabel')))
        .thenAnswer((_) async {});
  });

  Future<void> pumpSheet(
    WidgetTester tester,
    ProposalDeclineState state,
  ) async {
    tester.view.physicalSize = const Size(430, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      cubit,
      const Stream<ProposalDeclineState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: BlocProvider<ProposalDeclineCubit>.value(
            value: cubit,
            child: ProposalDeclineSheet(
              request: testProposalForSiblings,
              proposal: testVersion2,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the driver, the value, the children and the reasons', (
    tester,
  ) async {
    await pumpSheet(tester, const ProposalDeclineState());

    expect(find.text('Recusar proposta'), findsNWidgets(2));
    expect(find.text('Carlos Souza'), findsOneWidget);
    expect(
      find.text('R\$${nbsp}300/mês · 12x · Para Ana e Pedro'),
      findsOneWidget,
    );
    for (final reason in [
      'Valor acima do esperado',
      'Horários não atendem',
      'Escolhi outra van',
      'Não preciso mais do transporte',
      'Outro motivo',
    ]) {
      expect(find.text(reason), findsOneWidget);
    }
    expect(
      find.text('A negociação com Carlos Souza é encerrada.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Escolhi outra van'));

    verify(() => cubit.selectReason(ProposalDeclineReason.choseAnotherVan))
        .called(1);
  });

  testWidgets('declining waits for a reason', (tester) async {
    await pumpSheet(tester, const ProposalDeclineState());

    await tester.tap(find.text('Recusar proposta').last);

    verifyNever(() => cubit.send(reasonLabel: any(named: 'reasonLabel')));
  });

  testWidgets('the message fits with any reason in 500 characters', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      const ProposalDeclineState(reason: ProposalDeclineReason.choseAnotherVan),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLength, 500 - 'Não preciso mais do transporte'.length - 2);

    await tester.enterText(find.byType(TextField), 'Obrigada, Carlos.');
    verify(() => cubit.changeMessage('Obrigada, Carlos.')).called(1);
  });

  testWidgets('declines with the label of the reason after confirming', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      const ProposalDeclineState(reason: ProposalDeclineReason.choseAnotherVan),
    );

    await tester.tap(find.text('Recusar proposta').last);
    await tester.pumpAndSettle();

    expect(find.text('Recusar proposta?'), findsOneWidget);
    expect(
      find.text(
        'Isso encerra a negociação com Carlos Souza e não pode ser desfeito.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Recusar'));
    await tester.pumpAndSettle();

    verify(() => cubit.send(reasonLabel: 'Escolhi outra van')).called(1);
  });

  testWidgets('going back from the confirmation does not decline', (
    tester,
  ) async {
    await pumpSheet(
      tester,
      const ProposalDeclineState(reason: ProposalDeclineReason.choseAnotherVan),
    );

    await tester.tap(find.text('Recusar proposta').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();

    verifyNever(() => cubit.send(reasonLabel: any(named: 'reasonLabel')));
  });

  Future<List<ProposalDeclineOutcome?>> openSheet(
    WidgetTester tester,
    Stream<ProposalDeclineState> changes,
  ) async {
    final outcomes = <ProposalDeclineOutcome?>[];
    whenListen(cubit, changes, initialState: const ProposalDeclineState());
    await tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => outcomes.add(
                await showModalBottomSheet<ProposalDeclineOutcome>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => BlocProvider<ProposalDeclineCubit>.value(
                    value: cubit,
                    child: ProposalDeclineSheet(
                      request: testProposalForSiblings,
                      proposal: testVersion2,
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
    return outcomes;
  }

  testWidgets('a declined proposal closes the sheet as declined', (
    tester,
  ) async {
    final changes = StreamController<ProposalDeclineState>();
    addTearDown(changes.close);
    final outcomes = await openSheet(tester, changes.stream);

    changes.add(ProposalDeclineState(declinedProposal: testVersion2));
    await tester.pumpAndSettle();

    expect(outcomes, [ProposalDeclineOutcome.declined]);
  });

  testWidgets('a negotiation changed on the other side closes it as outdated', (
    tester,
  ) async {
    final changes = StreamController<ProposalDeclineState>();
    addTearDown(changes.close);
    final outcomes = await openSheet(tester, changes.stream);

    changes.add(
      const ProposalDeclineState(
        failure: NegotiationConflictFailure(detail: 'Chegou a versão 3.'),
      ),
    );
    await tester.pumpAndSettle();

    expect(outcomes, [ProposalDeclineOutcome.outdated]);
    expect(find.text('Chegou a versão 3.'), findsOneWidget);
  });

  testWidgets('a network failure keeps the sheet open', (tester) async {
    final changes = StreamController<ProposalDeclineState>();
    addTearDown(changes.close);
    final outcomes = await openSheet(tester, changes.stream);

    changes.add(
      const ProposalDeclineState(failure: NegotiationNetworkFailure()),
    );
    await tester.pumpAndSettle();

    expect(outcomes, isEmpty);
    expect(find.byType(ProposalDeclineSheet), findsOneWidget);
  });
}
