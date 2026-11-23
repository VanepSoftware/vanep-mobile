import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/formatters/money_formatter.dart';
import 'package:vanep_mobile/core/ui/vanep_error_view.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_terms.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_compose_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/pages/proposal_compose_page.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_compose_parts.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/widgets/proposal_schedule_grid.dart';

import '../../../core/ui/localized_harness.dart';
import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

void main() {
  late MockProposalComposeCubit cubit;

  setUpAll(() {
    registerFallbackValue(testProposalComposeDraft());
  });

  setUp(() {
    cubit = MockProposalComposeCubit();
    when(cubit.loadDraft).thenAnswer((_) async {});
    when(cubit.sendProposal).thenAnswer((_) async {});
  });

  Widget pageHarness() {
    return localizedHarness(
      Scaffold(
        body: BlocProvider<ProposalComposeCubit>.value(
          value: cubit,
          child: const ProposalComposePage(),
        ),
      ),
    );
  }

  Future<void> pumpPage(WidgetTester tester, ProposalComposeState state) async {
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      cubit,
      const Stream<ProposalComposeState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(pageHarness());
  }

  ProposalComposeState readyDraft(ProposalComposeDraft draft) {
    return ProposalComposeState(
      status: ProposalComposeStatus.ready,
      draft: draft,
    );
  }

  AppLocalizations l10nOf(WidgetTester tester) {
    return AppLocalizations.of(tester.element(find.byType(ListView)))!;
  }

  VoidCallback? sendAction(WidgetTester tester) {
    return tester
        .widget<VanepPrimaryButton>(find.byType(VanepPrimaryButton))
        .onPressed;
  }

  testWidgets('shows every section of the proposal', (tester) async {
    await pumpPage(tester, readyDraft(testProposalComposeDraft()));
    final l10n = l10nOf(tester);

    expect(find.text('Nova proposta'), findsOneWidget);
    expect(find.text('Família Andrade · Theo e Alice'), findsOneWidget);
    expect(find.text('Sprinter · SDF4E21'), findsOneWidget);
    expect(find.text('Tarde: 4 vagas · 16 lugares'), findsOneWidget);
    expect(find.text('Theo'), findsOneWidget);
    expect(find.text('Ida e volta'), findsNWidgets(2));
    expect(find.text('320'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text(formatMoney(l10n, 744000)), findsNWidgets(2));
    expect(find.text('12x de ${formatMoney(l10n, 62000)}'), findsNWidgets(2));
    expect(find.text(formatMoney(l10n, 6000)), findsOneWidget);
    expect(find.text('12x de ${formatMoney(l10n, 500)}'), findsOneWidget);
    expect(find.text(formatMoney(l10n, 738000)), findsOneWidget);
    expect(find.text('12x · todo dia 10'), findsOneWidget);
    expect(find.text('1º fev a 17 dez 2027'), findsOneWidget);
    expect(find.text('seg'), findsOneWidget);
    expect(find.byType(ProposalGridCell), findsNWidgets(10));
    expect(find.text('Conforme o pedido'), findsOneWidget);
    expect(find.text('12h05–12h15'), findsOneWidget);
    expect(find.text('12h50'), findsOneWidget);
    expect(find.text('18h00'), findsOneWidget);
    expect(find.text('até 5 min'), findsOneWidget);
    expect(find.text('1 parcela, abatida da 1ª'), findsOneWidget);
    expect(find.text('IPCA, na renovação'), findsOneWidget);
    expect(find.text('Aviso de 30 dias + 10% do saldo'), findsOneWidget);
    expect(find.byType(ProposalValidityNote), findsOneWidget);
    expect(sendAction(tester), isNotNull);
  });

  testWidgets('editing a price reports the new cents', (tester) async {
    await pumpPage(tester, readyDraft(testProposalComposeDraft()));

    await tester.enterText(find.byType(EditableText).first, '400');

    verify(() => cubit.changeStudentPrice('theo', 40000)).called(1);
  });

  testWidgets('a grid cell toggles its day and leg', (tester) async {
    await pumpPage(tester, readyDraft(testProposalComposeDraft()));

    await tester.tap(find.byType(ProposalGridCell).last);

    verify(() => cubit.toggleSlot(testFridayReturn)).called(1);
  });

  testWidgets('a changed grid says it differs from the request', (
    tester,
  ) async {
    await pumpPage(
      tester,
      readyDraft(testProposalComposeDraft().withSlotToggled(testFridayReturn)),
    );

    expect(find.text('Diferente do pedido'), findsOneWidget);
  });

  testWidgets('a van without seats warns and pauses sending', (tester) async {
    await pumpPage(
      tester,
      readyDraft(testProposalComposeDraft(selectedVanToken: 'master')),
    );

    expect(
      find.text('Esta van não tem vaga para todos os alunos neste turno.'),
      findsOneWidget,
    );
    expect(sendAction(tester), isNull);
  });

  testWidgets('the van sheet picks another van', (tester) async {
    await pumpPage(tester, readyDraft(testProposalComposeDraft()));

    await tester.tap(find.text('Sprinter · SDF4E21'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Master · RTA2B19'));
    await tester.pumpAndSettle();

    verify(() => cubit.selectVan('master')).called(1);
  });

  testWidgets('the payment sheet saves the installments', (tester) async {
    await pumpPage(tester, readyDraft(testProposalComposeDraft()));

    await tester.tap(find.text('12x · todo dia 10'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10x'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(
      () => cubit.changePayment(testPayment.copyWith(installments: 10)),
    ).called(1);
  });

  testWidgets('the times sheet saves the wait at the stop', (tester) async {
    await pumpPage(tester, readyDraft(testProposalComposeDraft()));

    await tester.tap(find.text('Editar').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('até 10 min'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(
      () => cubit.changeTimes(testRouteTimes.copyWith(stopWaitMinutes: 10)),
    ).called(1);
  });

  testWidgets('the conditions sheet saves the readjustment', (tester) async {
    await pumpPage(tester, readyDraft(testProposalComposeDraft()));

    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sem reajuste'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(
      () => cubit.changeConditions(
        testConditions.copyWith(readjustment: ProposalReadjustment.none),
      ),
    ).called(1);
  });

  testWidgets('typing a message reports it', (tester) async {
    await pumpPage(tester, readyDraft(testProposalComposeDraft()));

    await tester.enterText(
      find.byType(EditableText).last,
      'Tenho vaga para os dois.',
    );

    verify(() => cubit.changeMessage('Tenho vaga para os dois.')).called(1);
  });

  testWidgets('an overdue invoice keeps the form and pauses sending', (
    tester,
  ) async {
    await pumpPage(
      tester,
      readyDraft(
        testProposalComposeDraft(block: ProposalComposeBlock.overdueInvoice),
      ),
    );

    expect(find.text('Envio pausado'), findsOneWidget);
    expect(find.text('Theo'), findsOneWidget);
    expect(sendAction(tester), isNull);
  });

  testWidgets('not accepting students hides the form', (tester) async {
    await pumpPage(
      tester,
      readyDraft(
        testProposalComposeDraft(
          block: ProposalComposeBlock.notAcceptingStudents,
        ),
      ),
    );

    expect(find.text('Novos alunos pausados'), findsOneWidget);
    expect(find.text('Theo'), findsNothing);
    expect(find.text('Enviar proposta'), findsNothing);
    expect(find.byType(VanepPrimaryButton), findsNothing);
  });

  testWidgets('a failed load offers retry', (tester) async {
    await pumpPage(
      tester,
      const ProposalComposeState(status: ProposalComposeStatus.loadFailed),
    );

    expect(find.byType(VanepErrorView), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    verify(cubit.loadDraft).called(1);
  });

  testWidgets('a sent proposal tells the driver', (tester) async {
    final ready = readyDraft(testProposalComposeDraft());
    final updates = StreamController<ProposalComposeState>();
    addTearDown(updates.close);
    whenListen(cubit, updates.stream, initialState: ready);
    await tester.pumpWidget(pageHarness());

    updates.add(ready.sent());
    await tester.pump();

    expect(find.text('Proposta enviada.'), findsOneWidget);
  });
}
