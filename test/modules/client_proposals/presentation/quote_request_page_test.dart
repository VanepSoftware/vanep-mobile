import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/ui/vanep_week_legs_grid.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/quote_request_setup.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_state.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/pages/quote_request_page.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_profile_dto.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

import '../../../core/ui/localized_harness.dart';
import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockQuoteRequestCubit cubit;
  late List<String> calls;

  final today = DateTime(2026, 10, 25);
  final students = [
    QuoteStudent(dependent: testBia, week: testBiaWeek),
    const QuoteStudent(
      dependent: testDavi,
      week: SchoolWeek.empty(),
      gaps: {ContractReadinessField.school},
    ),
  ];
  final emptyDraft = ServiceRequestDraft(
    driverToken: testQuoteDriver.token,
    desiredStartDate: today,
  );

  QuoteRequestState readyState({
    ServiceRequestDraft? draft,
    DriverProfileDto driver = testQuoteDriver,
    Set<ContractReadinessField> clientGaps = const {},
    int openCount = 1,
    ClientServiceRequest? existingNegotiation,
    NegotiationFailure? failure,
  }) {
    return QuoteRequestState(
      status: QuoteRequestStatus.ready,
      setup: QuoteRequestSetup(
        driver: driver,
        students: QuoteStudents(students: students, clientGaps: clientGaps),
        openRequests: [
          for (var index = 0; index < openCount; index++)
            TestClientServiceRequest(token: 'open-$index'),
        ],
      ),
      draft: draft ?? emptyDraft,
      today: today,
      existingNegotiation: existingNegotiation,
      failure: failure,
    );
  }

  final biaSelected = emptyDraft.withStudent(
    testBia.token,
    weekdaysMondayToFriday,
  );

  setUp(() {
    cubit = MockQuoteRequestCubit();
    calls = [];
    when(cubit.send).thenAnswer((_) async {});
    when(cubit.refreshReadiness).thenAnswer((_) async {});
  });

  Future<void> pumpQuote(
    WidgetTester tester,
    QuoteRequestState state, {
    Stream<QuoteRequestState> changes = const Stream.empty(),
  }) async {
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    whenListen(cubit, changes, initialState: state);
    await tester.pumpWidget(
      localizedHarness(
        BlocProvider<QuoteRequestCubit>.value(
          value: cubit,
          child: QuoteRequestPage(
            actions: QuoteRequestActions(
              onCompleteStudent: (dependent, gaps) async =>
                  calls.add('complete ${dependent.token}'),
              onCompleteClientField: (field) async =>
                  calls.add('client ${field.name}'),
              onSent: (request) => calls.add('sent ${request.token}'),
              onOpenNegotiation: (request) =>
                  calls.add('open ${request.token}'),
            ),
          ),
        ),
      ),
    );
  }

  group('the header', () {
    testWidgets('shows the driver, the rating and the first van', (
      tester,
    ) async {
      await pumpQuote(tester, readyState());

      expect(find.text('Pedir orçamento'), findsOneWidget);
      expect(find.text('Carlos Souza'), findsOneWidget);
      expect(find.text('4,8'), findsOneWidget);
      expect(find.text('Master 2019 · 15 lugares'), findsOneWidget);
    });

    testWidgets('a driver without a rating shows only the van', (tester) async {
      await pumpQuote(
        tester,
        readyState(
          driver: const DriverProfileDto(
            token: 'driver-new',
            name: 'Rita Alves',
            available: true,
            vehicles: [
              DriverProfileVehicleDto(
                token: 'van-ducato',
                brand: 'Fiat',
                model: 'Ducato',
                manufactureYear: 2022,
                color: 'Prata',
                capacity: 16,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Rita Alves'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.text('Ducato 2022 · 16 lugares'), findsOneWidget);
    });
  });

  group('the students', () {
    testWidgets('a ready student can be checked', (tester) async {
      await pumpQuote(tester, readyState());

      expect(find.text('Bia Souza'), findsOneWidget);
      await tester.tap(find.text('Bia Souza'));

      verify(() => cubit.toggleStudent(testBia.token)).called(1);
    });

    testWidgets('an incomplete student is disabled with a link to complete', (
      tester,
    ) async {
      await pumpQuote(tester, readyState());

      expect(find.text('Cadastro incompleto'), findsOneWidget);
      await tester.tap(find.text('Davi Souza'));
      verifyNever(() => cubit.toggleStudent(testDavi.token));

      await tester.tap(find.text('Completar'));
      await tester.pump();

      expect(calls, ['complete ${testDavi.token}']);
      verify(cubit.refreshReadiness).called(1);
    });

    testWidgets('each checked student gets a grid of days and legs', (
      tester,
    ) async {
      await pumpQuote(tester, readyState(draft: biaSelected));

      expect(find.byType(VanepWeekLegsGrid<RouteLeg>), findsOneWidget);
      expect(find.text('Sáb'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Quarta, Volta'));

      verify(
        () => cubit.toggleLeg(
          testBia.token,
          Weekday.wednesday,
          RouteLeg.homebound,
        ),
      ).called(1);
    });

    testWidgets('the route shows the pickup in one line and the school', (
      tester,
    ) async {
      await pumpQuote(tester, readyState(draft: biaSelected));

      expect(find.text('Trajeto'), findsOneWidget);
      expect(find.text('Colégio Delta'), findsOneWidget);
      expect(find.textContaining('O motorista vê'), findsNothing);
      final pickup = tester.widget<Text>(find.text('QNL 5 Conjunto A, 12'));
      expect(pickup.maxLines, 1);
    });
  });

  testWidgets('the start date cannot be in the past', (tester) async {
    await pumpQuote(tester, readyState(draft: biaSelected));

    expect(find.text('Início desejado'), findsOneWidget);
    await tester.tap(find.text('25/10/2026'));
    await tester.pumpAndSettle();

    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(picker.firstDate, today);
  });

  testWidgets('the message is optional and up to 1000 characters', (
    tester,
  ) async {
    await pumpQuote(tester, readyState(draft: biaSelected));

    final field = tester.widget<TextField>(find.byType(TextField).last);
    expect(field.maxLength, 1000);

    await tester.enterText(find.byType(TextField).last, 'Bia sai às 12h.');
    verify(() => cubit.changeNotes('Bia sai às 12h.')).called(1);
  });

  group('the footer', () {
    testWidgets('shows the reply time without the open count and sends', (
      tester,
    ) async {
      await pumpQuote(tester, readyState(draft: biaSelected, openCount: 4));

      expect(find.text('Resposta em até 72 h'), findsOneWidget);
      expect(find.textContaining('pedidos abertos'), findsNothing);
      await tester.tap(find.text('Enviar pedido'));

      verify(cubit.send).called(1);
    });

    testWidgets('at the limit says so and does not send', (tester) async {
      await pumpQuote(tester, readyState(draft: biaSelected, openCount: 5));

      expect(
        find.text('Você atingiu o limite de 5 pedidos abertos.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Enviar pedido'));

      verifyNever(cubit.send);
    });

    testWidgets('a gap of the client tells what is missing', (tester) async {
      await pumpQuote(
        tester,
        readyState(
          draft: biaSelected,
          clientGaps: {
            ContractReadinessField.phone,
            ContractReadinessField.address,
            ContractReadinessField.document,
          },
        ),
      );

      expect(
        find.text('Para pedir orçamento, complete seu cadastro:'),
        findsOneWidget,
      );
      expect(find.text('CPF'), findsOneWidget);

      await tester.tap(find.text('Telefone'));
      await tester.tap(find.text('Endereço'));
      await tester.tap(find.text('CPF'));
      await tester.pump();
      await tester.tap(find.text('Enviar pedido'));

      expect(calls, ['client phone', 'client address']);
      verifyNever(cubit.send);
    });
  });

  testWidgets('a sent request leaves for the proposals', (tester) async {
    final changes = StreamController<QuoteRequestState>();
    addTearDown(changes.close);
    await pumpQuote(
      tester,
      readyState(draft: biaSelected),
      changes: changes.stream,
    );

    changes.add(
      readyState(
        draft: biaSelected,
      ).copyWith(sentRequest: TestClientServiceRequest(token: 'request-new')),
    );
    await tester.pump();

    expect(calls, ['sent request-new']);
  });

  testWidgets('an open request with the driver offers to open it', (
    tester,
  ) async {
    final existing = TestClientServiceRequest(token: 'request-open');
    await pumpQuote(
      tester,
      readyState(
        draft: biaSelected,
        existingNegotiation: existing,
        failure: const NegotiationConflictFailure(
          detail: 'Você já tem um pedido aberto com este motorista.',
        ),
      ),
    );

    expect(
      find.text('Você já tem um pedido aberto com este motorista.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ver negociação'));

    expect(calls, ['open request-open']);
  });
}
