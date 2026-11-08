import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/proposal_composer_setup.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_composer_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/proposal_composer_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/pages/proposal_composer_page.dart';
import 'package:vanep_mobile/modules/driver_vans/domain/entities/driver_van.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';

import '../../../core/ui/localized_harness.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

const nbsp = ' ';

final today = DateTime(2026, 10, 2);

final requestWithWednesdayOutbound = TestDriverServiceRequest(
  token: 'request-new',
  items: [TestDriverRequestItem(days: wednesdayOutboundOnly)],
);

ProposalComposerState readyState({
  List<DriverVan> vans = const [masterVan],
  int? totalAmountCents,
  int? installments,
}) {
  final setup = ProposalComposerSetup.from(
    request: requestWithWednesdayOutbound,
    vans: vans,
  );
  return ProposalComposerState(
    today: today,
    status: ProposalComposerStatus.ready,
    setup: setup.withDraft(
      setup.draft
          .withTotalAmount(totalAmountCents)
          .withInstallments(installments),
    ),
  );
}

void main() {
  late MockProposalComposerCubit cubit;
  late int registeredVans;

  setUp(() {
    cubit = MockProposalComposerCubit();
    registeredVans = 0;
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.refreshVans()).thenAnswer((_) async {});
  });

  Future<void> pumpComposer(
    WidgetTester tester,
    ProposalComposerState state, {
    Stream<ProposalComposerState>? changes,
  }) async {
    tester.view.physicalSize = const Size(360, 4200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      cubit,
      changes ?? const Stream<ProposalComposerState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<ProposalComposerCubit>.value(
          value: cubit,
          child: ProposalComposerPage(
            actions: ProposalComposerActions(
              onRegisterVan: () async => registeredVans++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('titles the proposal with the parent and the children', (
    tester,
  ) async {
    await pumpComposer(tester, readyState());

    expect(find.text('Nova proposta'), findsOneWidget);
    expect(find.text('Maria · Theo'), findsOneWidget);
  });

  testWidgets('too many installments asks for the range in short', (
    tester,
  ) async {
    await pumpComposer(tester, readyState(installments: 13));

    expect(find.text('De 1 a 12'), findsOneWidget);
  });

  testWidgets('a total below one cent per installment says so', (tester) async {
    await pumpComposer(
      tester,
      readyState(totalAmountCents: 11, installments: 12),
    );

    expect(find.text('Pelo menos 1 centavo por parcela'), findsOneWidget);
  });

  testWidgets('asks the amounts, the installments and the due day', (
    tester,
  ) async {
    await pumpComposer(tester, readyState());

    expect(find.textContaining('Mensalidade'), findsNothing);
    expect(find.text('Total do contrato'), findsOneWidget);
    expect(find.text('Parcelas'), findsOneWidget);
    expect(find.text('Dia de vencimento'), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Fim'), findsOneWidget);
  });

  testWidgets('a leg the family did not ask for cannot be turned on', (
    tester,
  ) async {
    await pumpComposer(tester, readyState());

    final wednesdayReturn = tester.widget<WeekLegCellButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is WeekLegCellButton && widget.label == 'Quarta, Volta',
      ),
    );

    expect(find.text('Conforme o pedido'), findsOneWidget);
    expect(wednesdayReturn.cell.isEnabled, isFalse);
  });

  testWidgets('toggling a requested leg reaches the cubit', (tester) async {
    when(() => cubit.toggleLeg('dep-theo', RouteLeg.homebound, Weekday.monday))
        .thenReturn(null);
    await pumpComposer(tester, readyState());

    await tester.tap(find.bySemanticsLabel('Segunda, Volta'));

    verify(
      () => cubit.toggleLeg('dep-theo', RouteLeg.homebound, Weekday.monday),
    ).called(1);
  });

  testWidgets('each requested leg asks one time per day', (tester) async {
    await pumpComposer(tester, readyState());

    expect(find.text('Embarque em casa'), findsNothing);
    expect(find.text('Saída da escola'), findsNothing);
    expect(find.bySemanticsLabel('Horário da Ida, Quarta'), findsOneWidget);
    expect(find.bySemanticsLabel('Horário da Volta, Segunda'), findsOneWidget);
    expect(find.bySemanticsLabel('Horário da Volta, Quarta'), findsNothing);
    expect(find.text('—'), findsOneWidget);
    expect(find.textContaining('até'), findsNothing);
  });

  testWidgets('applying to every day copies the first time of each leg', (
    tester,
  ) async {
    const pickup = ClockTime(hour: 12, minute: 5);
    const leaveSchool = ClockTime(hour: 18, minute: 0);
    final state = readyState();
    final setup = state.setup!;
    when(() => cubit.applyTimeToEveryDay('dep-theo', RouteLeg.outbound, pickup))
        .thenReturn(null);
    when(
      () => cubit.applyTimeToEveryDay(
        'dep-theo',
        RouteLeg.homebound,
        leaveSchool,
      ),
    ).thenReturn(null);
    await pumpComposer(
      tester,
      state.copyWith(
        setup: setup.withDraft(
          setup.draft
              .withTime('dep-theo', Weekday.monday, RouteLeg.outbound, pickup)
              .withTime(
                'dep-theo',
                Weekday.monday,
                RouteLeg.homebound,
                leaveSchool,
              ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Aplicar a todos os dias'));
    await tester.tap(find.text('Aplicar a todos os dias'));

    verify(
      () => cubit.applyTimeToEveryDay('dep-theo', RouteLeg.outbound, pickup),
    ).called(1);
    verify(
      () => cubit.applyTimeToEveryDay(
        'dep-theo',
        RouteLeg.homebound,
        leaveSchool,
      ),
    ).called(1);
  });

  testWidgets('a picked time reaches the cubit', (tester) async {
    when(
      () => cubit.changeTime(
        'dep-theo',
        Weekday.monday,
        RouteLeg.outbound,
        const ClockTime(hour: 7, minute: 0),
      ),
    ).thenReturn(null);
    await pumpComposer(tester, readyState());

    await tester.tap(find.bySemanticsLabel('Horário da Ida, Segunda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    verify(
      () => cubit.changeTime(
        'dep-theo',
        Weekday.monday,
        RouteLeg.outbound,
        const ClockTime(hour: 7, minute: 0),
      ),
    ).called(1);
  });

  testWidgets('the conditions offer both options of each menu', (tester) async {
    await pumpComposer(tester, readyState());

    expect(find.text('Taxa de reserva'), findsOneWidget);
    expect(find.text('Sem reajuste'), findsOneWidget);
    expect(find.text('IPCA na renovação'), findsOneWidget);
    expect(find.text('Aviso de 30 dias'), findsOneWidget);
    expect(find.text('Aviso de 30 dias + 10%'), findsOneWidget);
    expect(find.text('Mensagem'), findsOneWidget);
  });

  testWidgets('the validity is its own section, after the conditions', (
    tester,
  ) async {
    await pumpComposer(tester, readyState());

    expect(find.text('Validade da proposta'), findsOneWidget);
    expect(find.text('Dias para a família responder'), findsOneWidget);
    expect(
      find.text(
        'Prazo para a família aceitar. Depois dele, a proposta vence. '
        'Até 7 dias.',
      ),
      findsOneWidget,
    );
    expect(find.text('Validade em dias'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Validade da proposta')).dy,
      greaterThan(tester.getTopLeft(find.text('Aviso de 30 dias + 10%')).dy),
    );
  });

  testWidgets('one van is shown without asking', (tester) async {
    await pumpComposer(tester, readyState());

    expect(find.text('Master 2019 · 15 lugares · JKL1A23'), findsOneWidget);
    expect(find.text('Escolha a van desta proposta.'), findsNothing);
  });

  testWidgets('two vans ask to choose one', (tester) async {
    when(() => cubit.chooseVehicle('van-sprinter')).thenReturn(null);
    await pumpComposer(
      tester,
      readyState(vans: const [masterVan, sprinterVan]),
    );

    await tester.tap(find.text('Sprinter 2021 · 18 lugares · ABC1D23'));

    expect(find.text('Escolha a van desta proposta.'), findsOneWidget);
    verify(() => cubit.chooseVehicle('van-sprinter')).called(1);
  });

  testWidgets('without a van it leads to the van registration', (tester) async {
    await pumpComposer(tester, readyState(vans: const []));

    await tester.tap(find.text('Cadastrar van'));
    await tester.pumpAndSettle();

    expect(registeredVans, 1);
    verify(() => cubit.refreshVans()).called(1);
  });

  testWidgets('the footer previews the installment and has no commission', (
    tester,
  ) async {
    await pumpComposer(
      tester,
      readyState(totalAmountCents: 744000, installments: 12),
    );

    expect(
      find.text('R\$${nbsp}620/mês · 12x', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.text(
        'Proposta válida por 7 dias. Em caso de aceite, o contrato é gerado.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('comissão'), findsNothing);
    expect(find.textContaining('você recebe'), findsNothing);
  });

  testWidgets('an incomplete proposal cannot be sent', (tester) async {
    await pumpComposer(tester, readyState());

    await tester.tap(find.text('Enviar proposta'));

    verifyNever(() => cubit.send());
  });

  testWidgets('a period too long shows its error', (tester) async {
    final state = readyState();
    await pumpComposer(
      tester,
      ProposalComposerState(
        today: today,
        status: ProposalComposerStatus.ready,
        setup: state.setup!.withDraft(
          state.draft!.withEndsOn(DateTime(2028, 3, 1)),
        ),
      ),
    );

    expect(find.text('O período pode ter até 12 meses.'), findsOneWidget);
  });

  testWidgets('a 422 shows the message and keeps the screen', (tester) async {
    final ready = readyState();
    await pumpComposer(
      tester,
      ready,
      changes: Stream.value(
        ready.copyWith(
          failure: const NegotiationRejectedFailure(
            detail: 'Horário inválido.',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Horário inválido.'), findsOneWidget);
    expect(find.text('Nova proposta'), findsOneWidget);
  });
}
