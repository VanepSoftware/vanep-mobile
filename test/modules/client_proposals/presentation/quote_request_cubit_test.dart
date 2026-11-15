import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_quote_request.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_cubit.dart';
import 'package:vanep_mobile/modules/client_proposals/presentation/cubit/quote_request_state.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/failures/negotiation_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';
import '../client_proposals_mocks.dart';

void main() {
  late MockFindDriverProfile findDriverProfile;
  late MockFindMyDependents findMyDependents;
  late MockFindContractReadiness findReadiness;
  late MockFindSchoolDays findSchoolDays;
  late MockListClientServiceRequests listServiceRequests;
  late MockSendServiceRequest sendServiceRequest;

  final today = DateTime(2026, 10, 25);
  final openWithCarlos = TestClientServiceRequest(
    token: 'request-open-carlos',
    driverToken: testQuoteDriver.token,
  );

  void answerOpen(List<ClientServiceRequest> requests) {
    when(() => listServiceRequests(statuses: openServiceRequestStatuses))
        .thenAnswer(
          (_) async => Ok(
            NegotiationPage(
              items: requests,
              isLast: true,
              totalElements: requests.length,
            ),
          ),
        );
  }

  void answerReadiness(ContractReadiness readiness) {
    when(() => findReadiness([testBia.token, testDavi.token]))
        .thenAnswer((_) async => Ok(readiness));
  }

  setUpAll(
    () => registerFallbackValue(const ServiceRequestDraft(driverToken: '')),
  );

  setUp(() {
    findDriverProfile = MockFindDriverProfile();
    findMyDependents = MockFindMyDependents();
    findReadiness = MockFindContractReadiness();
    findSchoolDays = MockFindSchoolDays();
    listServiceRequests = MockListClientServiceRequests();
    sendServiceRequest = MockSendServiceRequest();
    when(() => findDriverProfile(testQuoteDriver.token))
        .thenAnswer((_) async => const Ok(testQuoteDriver));
    when(findMyDependents.call)
        .thenAnswer((_) async => const Ok([testBia, testDavi]));
    answerReadiness(testDaviMissingSchool);
    when(() => findSchoolDays(testBia.token))
        .thenAnswer((_) async => Ok(testBiaWeek));
    when(() => findSchoolDays(testDavi.token))
        .thenAnswer((_) async => const Ok(SchoolWeek.empty()));
    answerOpen([TestClientServiceRequest()]);
  });

  QuoteRequestCubit buildCubit() {
    final loadQuoteStudents = LoadQuoteStudents(
      findMyDependents: findMyDependents,
      findReadiness: findReadiness,
      findSchoolDays: findSchoolDays,
    );
    return QuoteRequestCubit(
      driverToken: testQuoteDriver.token,
      loadQuoteRequest: LoadQuoteRequest(
        findDriverProfile: findDriverProfile,
        loadQuoteStudents: loadQuoteStudents,
        listServiceRequests: listServiceRequests,
      ),
      loadQuoteStudents: loadQuoteStudents,
      listServiceRequests: listServiceRequests,
      sendServiceRequest: sendServiceRequest,
      clock: () => today,
    );
  }

  Future<QuoteRequestCubit> loadedCubit() async {
    final cubit = buildCubit();
    await cubit.load();
    return cubit;
  }

  group('loading', () {
    test(
      'reads the driver, the students, their weeks and the open ones',
      () async {
        final cubit = await loadedCubit();
        final state = cubit.state;

        expect(state.status, QuoteRequestStatus.ready);
        expect(state.driver, testQuoteDriver);
        expect(state.students.map((student) => student.dependent), [
          testBia,
          testDavi,
        ]);
        expect(state.students.first.week, testBiaWeek);
        expect(state.openCount, 1);
        expect(state.draft!.desiredStartDate, today);
        verify(() => findReadiness([testBia.token, testDavi.token])).called(1);
      },
    );

    test('a student with a gap is disabled', () async {
      final cubit = await loadedCubit();

      expect(cubit.state.students.first.isReady, isTrue);
      expect(cubit.state.students.last.isReady, isFalse);
      expect(cubit.state.students.last.gaps, {ContractReadinessField.school});

      cubit.toggleStudent(testDavi.token);

      expect(cubit.state.draft!.items, isEmpty);
    });

    blocTest<QuoteRequestCubit, QuoteRequestState>(
      'any failure while loading offers to try again',
      setUp: () =>
          when(() => findDriverProfile(testQuoteDriver.token))
              .thenAnswer((_) async => const Err(NetworkDriverFailure())),
      build: buildCubit,
      act: (cubit) => cubit.load(),
      expect: () => [
        const QuoteRequestState(status: QuoteRequestStatus.loading),
        const QuoteRequestState(status: QuoteRequestStatus.loadFailed),
      ],
    );
  });

  group('the draft', () {
    test('a student starts with every leg on the days of school', () async {
      final cubit = await loadedCubit();

      cubit.toggleStudent(testBia.token);

      expect(
        cubit.state.draft!.items.single,
        RequestDraftItem.withEveryLegOn(testBia.token, weekdaysMondayToFriday),
      );
      expect(cubit.state.canSend, isTrue);
    });

    test('turns a leg off and unselects a student', () async {
      final cubit = await loadedCubit();

      cubit
        ..toggleStudent(testBia.token)
        ..toggleLeg(testBia.token, Weekday.wednesday, RouteLeg.homebound);

      expect(
        cubit.state.draft!.items.single.hasLeg(
          Weekday.wednesday,
          RouteLeg.homebound,
        ),
        isFalse,
      );

      cubit.toggleStudent(testBia.token);
      expect(cubit.state.draft!.items, isEmpty);
      expect(cubit.state.canSend, isFalse);
    });

    test('keeps the start date and the message', () async {
      final cubit = await loadedCubit();

      cubit
        ..changeStartDate(DateTime(2027, 2, 1))
        ..changeNotes('Bia sai às 12h.');

      expect(cubit.state.draft!.desiredStartDate, DateTime(2027, 2, 1));
      expect(cubit.state.draft!.notes, 'Bia sai às 12h.');
    });
  });

  group('what keeps the request from being sent', () {
    test('a gap of the client disables sending', () async {
      answerReadiness(testClientWithoutPhone);
      final cubit = await loadedCubit();

      cubit.toggleStudent(testBia.token);

      expect(cubit.state.clientGaps, {ContractReadinessField.phone});
      expect(cubit.state.canSend, isFalse);
    });

    test('five open negotiations reach the limit', () async {
      answerOpen([
        for (var index = 0; index < 5; index++)
          TestClientServiceRequest(token: 'open-$index'),
      ]);
      final cubit = await loadedCubit();

      cubit.toggleStudent(testBia.token);

      expect(cubit.state.hasReachedLimit, isTrue);
      expect(cubit.state.canSend, isFalse);
    });

    test('completing a student checks the readiness again', () async {
      final cubit = await loadedCubit();
      cubit.toggleStudent(testBia.token);
      answerReadiness(const ContractReadiness(ready: true, gaps: []));
      when(() => findSchoolDays(testDavi.token))
          .thenAnswer((_) async => Ok(testBiaWeek));

      await cubit.refreshReadiness();

      expect(cubit.state.students.last.isReady, isTrue);
      expect(cubit.state.draft!.isSelected(testBia.token), isTrue);
      verify(() => findReadiness([testBia.token, testDavi.token])).called(2);
    });
  });

  group('sending', () {
    test('sends the draft and keeps the request sent', () async {
      final cubit = await loadedCubit();
      cubit.toggleStudent(testBia.token);
      final sent = TestClientServiceRequest(token: 'request-new');
      when(() => sendServiceRequest(cubit.state.draft!))
          .thenAnswer((_) async => Ok(sent));

      await cubit.send();

      expect(cubit.state.sentRequest, sent);
      expect(cubit.state.isSending, isFalse);
    });

    test('an open request with this driver offers the existing one', () async {
      final cubit = await loadedCubit();
      cubit.toggleStudent(testBia.token);
      when(() => sendServiceRequest(any())).thenAnswer(
        (_) async => const Err(
          NegotiationConflictFailure(detail: 'Você já tem um pedido aberto.'),
        ),
      );
      answerOpen([openWithCarlos]);

      await cubit.send();

      expect(
        cubit.state.failure,
        const NegotiationConflictFailure(
          detail: 'Você já tem um pedido aberto.',
        ),
      );
      expect(cubit.state.existingNegotiation, openWithCarlos);
      expect(cubit.state.draft!.isSelected(testBia.token), isTrue);
    });

    test('a rule of the back keeps the draft and tells why', () async {
      final cubit = await loadedCubit();
      cubit.toggleStudent(testBia.token);
      final draft = cubit.state.draft!;
      when(() => sendServiceRequest(any())).thenAnswer(
        (_) async => const Err(
          NegotiationRejectedFailure(detail: 'Sem aula no sábado.'),
        ),
      );

      await cubit.send();

      expect(
        cubit.state.failure,
        const NegotiationRejectedFailure(detail: 'Sem aula no sábado.'),
      );
      expect(cubit.state.draft, draft);
      expect(cubit.state.existingNegotiation, isNull);
    });
  });
}
