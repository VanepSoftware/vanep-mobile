import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/failures/client_proposals_failure.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/usecases/load_quote_request.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/failures/contract_readiness_failure.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/drivers/domain/failures/driver_failure.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
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
  late LoadQuoteStudents loadQuoteStudents;
  late LoadQuoteRequest loadQuoteRequest;

  final openRequest = TestClientServiceRequest(token: 'request-open');

  setUp(() {
    findDriverProfile = MockFindDriverProfile();
    findMyDependents = MockFindMyDependents();
    findReadiness = MockFindContractReadiness();
    findSchoolDays = MockFindSchoolDays();
    listServiceRequests = MockListClientServiceRequests();
    loadQuoteStudents = LoadQuoteStudents(
      findMyDependents: findMyDependents,
      findReadiness: findReadiness,
      findSchoolDays: findSchoolDays,
    );
    loadQuoteRequest = LoadQuoteRequest(
      findDriverProfile: findDriverProfile,
      loadQuoteStudents: loadQuoteStudents,
      listServiceRequests: listServiceRequests,
    );
    when(() => findDriverProfile(testQuoteDriver.token))
        .thenAnswer((_) async => const Ok(testQuoteDriver));
    when(findMyDependents.call)
        .thenAnswer((_) async => const Ok([testBia, testDavi]));
    when(() => findReadiness([testBia.token, testDavi.token]))
        .thenAnswer((_) async => const Ok(testDaviMissingSchool));
    when(() => findSchoolDays(testBia.token))
        .thenAnswer((_) async => Ok(testBiaWeek));
    when(() => findSchoolDays(testDavi.token))
        .thenAnswer((_) async => const Ok(SchoolWeek.empty()));
    when(
      () => listServiceRequests(statuses: openServiceRequestStatuses),
    ).thenAnswer(
      (_) async => Ok(
        NegotiationPage(items: [openRequest], isLast: true, totalElements: 1),
      ),
    );
  });

  test(
    'each student comes with the week and the gaps of the readiness',
    () async {
      final students = (await loadQuoteStudents()).valueOrNull!;

      expect(students.students.map((student) => student.dependent), [
        testBia,
        testDavi,
      ]);
      expect(students.students.first.week, testBiaWeek);
      expect(students.students.last.gaps, {ContractReadinessField.school});
      expect(students.clientGaps, isEmpty);
    },
  );

  test('reads the driver, the students and the open requests', () async {
    final setup = (await loadQuoteRequest(testQuoteDriver.token)).valueOrNull!;

    expect(setup.driver, testQuoteDriver);
    expect(setup.students.students, hasLength(2));
    expect(setup.openRequests, [openRequest]);
  });

  test('a driver without connection fails as network', () async {
    when(() => findDriverProfile(testQuoteDriver.token))
        .thenAnswer((_) async => const Err(NetworkDriverFailure()));

    expect(
      (await loadQuoteRequest(testQuoteDriver.token)).errorOrNull,
      ClientProposalsFailure.network,
    );
  });

  test('a readiness that fails fails the students', () async {
    when(() => findReadiness([testBia.token, testDavi.token]))
        .thenAnswer((_) async => const Err(ContractReadinessFailure.network));

    expect(
      (await loadQuoteStudents()).errorOrNull,
      ClientProposalsFailure.network,
    );
  });
}
