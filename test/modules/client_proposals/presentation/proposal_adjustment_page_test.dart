import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/proposal_adjustment_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/proposal_adjustment_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_adjustment_field.dart';

import '../../../core/ui/localized_harness.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

const nbsp = ' ';

void main() {
  late MockProposalAdjustmentCubit cubit;

  setUp(() {
    cubit = MockProposalAdjustmentCubit();
    when(cubit.send).thenAnswer((_) async {});
  });

  Future<void> pumpAdjustment(
    WidgetTester tester,
    ProposalAdjustmentState state, {
    Stream<ProposalAdjustmentState> changes = const Stream.empty(),
  }) async {
    tester.view.physicalSize = const Size(430, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(cubit, changes, initialState: state);
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<ProposalAdjustmentCubit>.value(
          value: cubit,
          child: ProposalAdjustmentPage(
            request: testProposalForSiblings,
            proposal: testVersion2,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the driver, the children and the open version', (
    tester,
  ) async {
    await pumpAdjustment(tester, const ProposalAdjustmentState());

    expect(find.text('Pedir ajuste'), findsOneWidget);
    expect(find.text('Carlos Souza'), findsOneWidget);
    expect(find.text('Para Ana e Pedro'), findsOneWidget);
    expect(find.text('Versão 2 · R\$${nbsp}300/mês · 12x'), findsOneWidget);
    expect(find.text('A versão 2 segue válida até 31/10.'), findsOneWidget);
  });

  testWidgets('the five subjects are a single choice', (tester) async {
    await pumpAdjustment(tester, const ProposalAdjustmentState());

    for (final subject in [
      'Valor',
      'Parcelas',
      'Dias e horários',
      'Período do contrato',
      'Outro',
    ]) {
      expect(find.text(subject), findsOneWidget);
    }

    await tester.tap(find.text('Dias e horários'));

    verify(() => cubit.selectField(ProposalAdjustmentField.schedule)).called(1);
  });

  testWidgets('the price asks for the amount of each installment', (
    tester,
  ) async {
    await pumpAdjustment(
      tester,
      const ProposalAdjustmentState(
        draft: ProposalAdjustmentDraft(field: ProposalAdjustmentField.price),
      ),
    );

    expect(find.text('Mensalidade'), findsOneWidget);
    expect(find.text('Valor sugerido'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '29000');

    verify(() => cubit.changeSuggestedValue('R\$${nbsp}290')).called(1);
  });

  testWidgets('the other subjects take a free suggested value', (tester) async {
    await pumpAdjustment(
      tester,
      const ProposalAdjustmentState(
        draft: ProposalAdjustmentDraft(field: ProposalAdjustmentField.period),
      ),
    );

    expect(find.text('Valor sugerido'), findsOneWidget);
    expect(find.text('Mensalidade'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'Começar em março');
    await tester.enterText(find.byType(TextField).last, 'Obrigada.');

    verify(() => cubit.changeSuggestedValue('Começar em março')).called(1);
    verify(() => cubit.changeNote('Obrigada.')).called(1);
  });

  testWidgets('the limits of the texts are 100 and 500', (tester) async {
    await pumpAdjustment(
      tester,
      const ProposalAdjustmentState(
        draft: ProposalAdjustmentDraft(field: ProposalAdjustmentField.other),
      ),
    );

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.map((field) => field.maxLength), [100, 500]);
  });

  testWidgets('sending waits for a value or a message', (tester) async {
    await pumpAdjustment(
      tester,
      const ProposalAdjustmentState(
        draft: ProposalAdjustmentDraft(field: ProposalAdjustmentField.other),
      ),
    );

    await tester.tap(find.text('Enviar pedido de ajuste'));
    verifyNever(cubit.send);
  });

  testWidgets('a complete adjustment is sent', (tester) async {
    await pumpAdjustment(
      tester,
      const ProposalAdjustmentState(
        draft: ProposalAdjustmentDraft(
          field: ProposalAdjustmentField.schedule,
          note: 'Pode buscar 10 min antes?',
        ),
      ),
    );

    await tester.tap(find.text('Enviar pedido de ajuste'));
    verify(cubit.send).called(1);
  });

  testWidgets('a failure of the back shows its message', (tester) async {
    final changes = StreamController<ProposalAdjustmentState>();
    addTearDown(changes.close);
    await pumpAdjustment(
      tester,
      const ProposalAdjustmentState(),
      changes: changes.stream,
    );

    changes.add(
      const ProposalAdjustmentState(
        failure: NegotiationRejectedFailure(detail: 'Ajuste vazio.'),
      ),
    );
    await tester.pump();

    expect(find.text('Ajuste vazio.'), findsOneWidget);
  });
}
