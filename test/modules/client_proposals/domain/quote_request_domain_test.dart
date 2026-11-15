import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/quote_request_setup.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_profile_dto.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_draft.dart';

import '../../negotiations/negotiations_fixtures.dart';
import '../client_proposals_fixtures.dart';

void main() {
  final today = DateTime(2026, 10, 25);
  final bia = QuoteStudent(dependent: testBia, week: testBiaWeek);
  const davi = QuoteStudent(
    dependent: testDavi,
    week: SchoolWeek.empty(),
    gaps: {ContractReadinessField.school},
  );
  final biaSelected = ServiceRequestDraft(
    driverToken: testQuoteDriver.token,
    desiredStartDate: today,
  ).withStudent(testBia.token, weekdaysMondayToFriday);

  QuoteRequestSetup setupWith({
    DriverProfileDto driver = testQuoteDriver,
    Set<ContractReadinessField> clientGaps = const {},
    int openCount = 1,
  }) {
    return QuoteRequestSetup(
      driver: driver,
      students: QuoteStudents(students: [bia, davi], clientGaps: clientGaps),
      openRequests: [
        for (var index = 0; index < openCount; index++)
          TestClientServiceRequest(token: 'open-$index'),
      ],
    );
  }

  test('a student is ready with no gaps and a week of school', () {
    expect(bia.isReady, isTrue);
    expect(davi.isReady, isFalse);
    expect(
      QuoteStudent(dependent: testDavi, week: const SchoolWeek.empty()).isReady,
      isFalse,
    );
  });

  test('only the gaps of the client hold the whole request', () {
    expect(clientGapsOf(testClientWithoutPhone), {
      ContractReadinessField.phone,
    });
    expect(clientGapsOf(testDaviMissingSchool), isEmpty);
  });

  test('a valid draft can be sent', () {
    expect(setupWith().allowsSending(biaSelected, today: today), isTrue);
  });

  test('a gap of the client, the limit or an unavailable driver block it', () {
    expect(
      setupWith(clientGaps: {ContractReadinessField.phone})
          .allowsSending(biaSelected, today: today),
      isFalse,
    );
    expect(setupWith(openCount: 5).hasReachedOpenRequestsLimit, isTrue);
    expect(
      setupWith(openCount: 5).allowsSending(biaSelected, today: today),
      isFalse,
    );
    expect(
      setupWith(
        driver: const DriverProfileDto(
          token: 'driver-carlos',
          name: 'Carlos Souza',
          available: false,
        ),
      ).allowsSending(biaSelected, today: today),
      isFalse,
    );
  });

  test('a draft without students cannot be sent', () {
    expect(
      setupWith().allowsSending(
        ServiceRequestDraft(
          driverToken: testQuoteDriver.token,
          desiredStartDate: today,
        ),
        today: today,
      ),
      isFalse,
    );
  });

  test('a student that is no longer ready leaves the draft', () {
    final students = QuoteStudents(
      students: [
        QuoteStudent(
          dependent: testBia,
          week: testBiaWeek,
          gaps: const {ContractReadinessField.school},
        ),
      ],
    );

    expect(students.keepReadyStudents(biaSelected).items, isEmpty);
  });

  test('finds the open request with the driver', () {
    final withCarlos = TestClientServiceRequest(
      token: 'request-carlos',
      driverToken: testQuoteDriver.token,
    );

    expect(
      findOpenRequestWithDriver([
        TestClientServiceRequest(
          token: 'request-other',
          driverToken: 'driver-paula',
        ),
        withCarlos,
      ], testQuoteDriver.token),
      withCarlos,
    );
    expect(findOpenRequestWithDriver(const [], testQuoteDriver.token), isNull);
  });
}
