import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_cubit.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/cubit/driver_negotiations_state.dart';
import 'package:vanep_mobile/modules/driver_proposals/presentation/pages/driver_proposals_tab.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

import '../../../core/ui/localized_harness.dart';
import '../driver_proposals_fixtures.dart';
import '../driver_proposals_mocks.dart';

const nbsp = '\u00a0';

void main() {
  late MockDriverNegotiationsCubit cubit;
  late List<String> opened;

  setUp(() {
    cubit = MockDriverNegotiationsCubit();
    opened = [];
    when(() => cubit.load()).thenAnswer((_) async {});
    when(() => cubit.loadMore()).thenAnswer((_) async {});
  });

  Future<void> pumpTab(
    WidgetTester tester,
    DriverNegotiationsState state,
  ) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(
      cubit,
      const Stream<DriverNegotiationsState>.empty(),
      initialState: state,
    );
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<DriverNegotiationsCubit>.value(
          value: cubit,
          child: DriverProposalsTab(
            actions: DriverProposalsTabActions(
              onOpenRequest: (DriverServiceRequest request) async =>
                  opened.add('request ${request.token}'),
              onOpenProposal: (DriverServiceRequest request) async =>
                  opened.add('proposal ${request.token}'),
            ),
          ),
        ),
      ),
    );
  }

  DriverNegotiationsState readyWith(List<DriverServiceRequest> requests) {
    return DriverNegotiationsState(
      status: DriverNegotiationsStatus.ready,
      negotiations: driverNegotiationsOf(requests),
    );
  }

  testWidgets('shows the negotiations count and the two groups', (
    tester,
  ) async {
    await pumpTab(
      tester,
      readyWith([newRequestForSiblings, adjustmentRequest, awaitingRequest]),
    );

    expect(find.text('Negociações'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.text('Aguardando resposta'), findsOneWidget);
  });

  testWidgets('a request for two siblings names the parent and both', (
    tester,
  ) async {
    await pumpTab(tester, readyWith([newRequestForSiblings]));

    expect(find.text('Maria · Theo e Alice'), findsOneWidget);
    expect(find.text('Pedido novo'), findsOneWidget);
    expect(find.text('Expira em 2 dias'), findsOneWidget);
    expect(find.text('Colégio Delta, tarde'), findsOneWidget);
    expect(find.text('Embarque em Taguatinga'), findsOneWidget);
  });

  testWidgets('a requested adjustment shows no suggested value', (
    tester,
  ) async {
    await pumpTab(tester, readyWith([adjustmentRequest]));

    expect(find.text('Ajuste solicitado'), findsOneWidget);
    expect(find.textContaining('R\$'), findsNothing);
  });

  testWidgets('an awaiting proposal shows its installments and validity', (
    tester,
  ) async {
    await pumpTab(tester, readyWith([awaitingRequest]));

    expect(find.text('R\$${nbsp}340/mês · 12x'), findsOneWidget);
    expect(find.text('Expira em 5 dias'), findsOneWidget);
  });

  testWidgets('a new request opens the request, the others the proposal', (
    tester,
  ) async {
    await pumpTab(tester, readyWith([newRequestForSiblings, awaitingRequest]));

    await tester.tap(find.text('Maria · Theo e Alice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paula · Theo'));
    await tester.pumpAndSettle();

    expect(opened, ['request request-new', 'proposal request-awaiting']);
    verify(() => cubit.load()).called(2);
  });

  testWidgets('without negotiations it explains where requests appear', (
    tester,
  ) async {
    await pumpTab(tester, readyWith(const []));

    expect(find.text('Nenhuma negociação aberta'), findsOneWidget);
  });

  testWidgets('contracts are coming soon', (tester) async {
    await pumpTab(
      tester,
      const DriverNegotiationsState(
        status: DriverNegotiationsStatus.ready,
        segment: DriverProposalsSegment.contracts,
      ),
    );

    expect(find.text('Em breve'), findsOneWidget);
  });

  testWidgets('tapping contracts selects that segment', (tester) async {
    when(() => cubit.selectSegment(DriverProposalsSegment.contracts))
        .thenReturn(null);
    await pumpTab(tester, readyWith(const []));

    await tester.tap(find.text('Contratos'));

    verify(() => cubit.selectSegment(DriverProposalsSegment.contracts))
        .called(1);
  });

  testWidgets('a failed load offers to try again', (tester) async {
    await pumpTab(
      tester,
      const DriverNegotiationsState(
        status: DriverNegotiationsStatus.loadFailed,
      ),
    );

    await tester.tap(find.text('Tentar novamente'));

    expect(
      find.text('Não foi possível carregar as negociações.'),
      findsOneWidget,
    );
    verify(() => cubit.load()).called(1);
  });
}
