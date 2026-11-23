import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_proposals/data/datasources/scenario_proposal_compose_datasource.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_compose_draft.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_compose_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/pages/proposal_compose_page.dart';

import '../modules/driver_proposals/driver_proposals_mocks.dart';
import 'preview_harness.dart';

const fullPageHeight = 2050.0;

void main() {
  Future<void> pumpCompose(
    WidgetTester tester,
    ProposalComposeState state, {
    double height = 844,
  }) async {
    setPreviewViewport(tester, height: height);
    final cubit = MockProposalComposeCubit();
    when(cubit.loadDraft).thenAnswer((_) async {});
    whenListen(
      cubit,
      const Stream<ProposalComposeState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      previewApp(
        BlocProvider<ProposalComposeCubit>.value(
          value: cubit,
          child: const ProposalComposePage(),
        ),
      ),
    );
  }

  ProposalComposeState ready(ProposalComposeDraft draft) {
    return ProposalComposeState(
      status: ProposalComposeStatus.ready,
      draft: draft,
    );
  }

  final sample = sampleProposalComposeDraft().copyWith(
    message: 'Tenho vaga para os dois. Fiz R\$ 300 para a Alice por serem '
        'irmãos.',
  );

  group('Montar proposta', skip: previewSkip, () {
    setUpAll(loadPreviewFonts);

    testWidgets('01 tela aberta', (tester) async {
      await pumpCompose(tester, ready(sample));
      await expectPreview(tester, 'proposal_compose_01_open');
    });

    testWidgets('02 pagina inteira', (tester) async {
      await pumpCompose(tester, ready(sample), height: fullPageHeight);
      await expectPreview(tester, 'proposal_compose_02_full_page');
    });

    testWidgets('03 van sem vagas e dias alterados', (tester) async {
      final draft = sample.withVan('master').withSlotToggled(
        sample.slots.last,
      );
      await pumpCompose(tester, ready(draft), height: fullPageHeight);
      await expectPreview(tester, 'proposal_compose_03_no_seats');
    });

    testWidgets('04 fatura vencida', (tester) async {
      await pumpCompose(
        tester,
        ready(
          sampleProposalComposeDraft(
            block: ProposalComposeBlock.overdueInvoice,
          ),
        ),
      );
      await expectPreview(tester, 'proposal_compose_04_overdue_invoice');
    });

    testWidgets('05 nao aceitando alunos', (tester) async {
      await pumpCompose(
        tester,
        ready(
          sampleProposalComposeDraft(
            block: ProposalComposeBlock.notAcceptingStudents,
          ),
        ),
      );
      await expectPreview(tester, 'proposal_compose_05_not_accepting');
    });

    testWidgets('06 sheet da van', (tester) async {
      await pumpCompose(tester, ready(sample));
      await tester.tap(find.text('Sprinter · SDF4E21'));
      await expectPreview(tester, 'proposal_compose_06_van_sheet');
    });

    testWidgets('07 sheet de parcelas', (tester) async {
      await pumpCompose(tester, ready(sample));
      await tester.tap(find.text('12x · todo dia 10'));
      await expectPreview(tester, 'proposal_compose_07_payment_sheet');
    });

    testWidgets('08 sheet de horarios', (tester) async {
      await pumpCompose(tester, ready(sample), height: fullPageHeight);
      await tester.tap(find.text('Editar').first);
      await expectPreview(tester, 'proposal_compose_08_times_sheet');
    });

    testWidgets('09 sheet de condicoes', (tester) async {
      await pumpCompose(tester, ready(sample), height: fullPageHeight);
      await tester.tap(find.text('Editar').last);
      await expectPreview(tester, 'proposal_compose_09_conditions_sheet');
    });

    testWidgets('10 carregando', (tester) async {
      await pumpCompose(
        tester,
        const ProposalComposeState(status: ProposalComposeStatus.loading),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('../../preview/proposal_compose_10_loading.png'),
      );
    });
  });
}
