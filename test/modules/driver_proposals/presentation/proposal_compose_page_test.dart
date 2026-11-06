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
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_compose_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/pages/proposal_compose_page.dart';

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
    when(() => cubit.changeStudentPrice(any(), any())).thenAnswer((_) {});
  });

  Future<void> pumpPage(
    WidgetTester tester,
    ProposalComposeState state,
  ) async {
    tester.view.physicalSize = const Size(430, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      cubit,
      const Stream<ProposalComposeState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: BlocProvider<ProposalComposeCubit>.value(
            value: cubit,
            child: const ProposalComposePage(),
          ),
        ),
      ),
    );
  }

  ProposalComposeState readyDraft(ProposalComposeDraft draft) {
    return ProposalComposeState(
      status: ProposalComposeStatus.ready,
      draft: draft,
    );
  }

  testWidgets('shows the family, prices, schedule and money summary', (
    tester,
  ) async {
    final draft = testProposalComposeDraft();
    await pumpPage(tester, readyDraft(draft));
    final l10n = AppLocalizations.of(
      tester.element(find.text('Montar proposta')),
    )!;

    expect(find.text('Família Silva'), findsOneWidget);
    expect(
      find.text('Um contrato para esta família, um item por aluno.'),
      findsOneWidget,
    );
    expect(find.text('Pedro Silva'), findsOneWidget);
    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('Colégio Delta'), findsOneWidget);
    expect(find.text('350'), findsOneWidget);
    expect(find.text('280'), findsOneWidget);
    expect(find.text('Segunda'), findsOneWidget);
    expect(find.text('Terça'), findsOneWidget);
    expect(find.text('6h40'), findsWidgets);
    expect(find.text('12h10'), findsWidgets);
    expect(find.text('Ida'), findsNWidgets(2));
    expect(find.text('Volta'), findsOneWidget);
    expect(find.text('Todo dia 10'), findsOneWidget);
    expect(find.text(draft.conditions.notes), findsOneWidget);
    expect(find.text(formatMoney(l10n, 63000)), findsOneWidget);
    expect(find.text(formatMoney(l10n, 500)), findsOneWidget);
    expect(find.text(formatMoney(l10n, 62500)), findsOneWidget);
    expect(
      tester.widget<VanepPrimaryButton>(find.byType(VanepPrimaryButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('editing a price reports the new cents', (tester) async {
    await pumpPage(tester, readyDraft(testProposalComposeDraft()));

    await tester.enterText(find.byType(EditableText).first, '400');

    verify(() => cubit.changeStudentPrice('pedro', 40000)).called(1);
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
    expect(find.text('Pedro Silva'), findsOneWidget);
    expect(
      tester.widget<VanepPrimaryButton>(find.byType(VanepPrimaryButton)).onPressed,
      isNull,
    );
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
    expect(find.text('Pedro Silva'), findsNothing);
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
    await tester.pumpWidget(
      localizedHarness(
        Scaffold(
          body: BlocProvider<ProposalComposeCubit>.value(
            value: cubit,
            child: const ProposalComposePage(),
          ),
        ),
      ),
    );

    updates.add(ready.sent());
    await tester.pump();

    expect(find.text('Proposta enviada.'), findsOneWidget);
  });
}
