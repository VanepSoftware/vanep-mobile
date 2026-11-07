import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/client_proposals/domain/value_objects/client_proposals.dart';
import 'package:vanep_mobile/modules/contract_readiness/domain/entities/contract_readiness.dart';
import 'package:vanep_mobile/modules/dependents/domain/entities/dependent.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/drivers/data/dtos/driver_profile_dto.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../dependents/dependents_fixtures.dart';
import '../negotiations/negotiations_fixtures.dart';

final testProposalsNow = DateTime(2026, 10, 25, 10);

const testPedro = TestDependent(
  token: 'child-pedro',
  name: 'Pedro Souza',
  birthDate: '2015-03-22',
);

const testAna = TestDependent(
  token: 'child-ana',
  name: 'Ana Souza',
  birthDate: '2018-06-01',
);

const testLucas = TestDependent(
  token: 'child-lucas',
  name: 'Lucas Souza',
  birthDate: '2020-01-10',
);

TestClientRequestItem testItemFor(
  Dependent child, {
  String schoolName = 'Colégio Delta',
  SchoolShift shift = SchoolShift.afternoon,
  List<RequestedDay>? days,
}) {
  return TestClientRequestItem(
    dependentToken: child.token,
    dependentName: child.name,
    dependentBirthDate: child.birthDate,
    schoolName: schoolName,
    days:
        days ??
        [
          for (final weekday in weekdaysMondayToFriday)
            TestRequestedDay(weekday: weekday, schoolShift: shift),
        ],
  );
}

final testProposalForSiblings = TestClientServiceRequest(
  token: 'request-carlos',
  status: ServiceRequestStatus.answered,
  items: [testItemFor(testAna), testItemFor(testPedro)],
  currentProposal: TestProposalSummary(
    token: 'proposal-carlos-v2',
    version: 2,
    installments: 12,
    installmentAmountCents: 30000,
    validUntil: testProposalsNow.add(const Duration(days: 6)),
    startsOn: DateTime(2027, 2, 15),
  ),
);

final testAdjustmentForPedro = TestClientServiceRequest(
  token: 'request-rita',
  conversationToken: 'conversation-rita',
  driverToken: 'driver-rita',
  driverName: 'Rita Alves',
  driverRating: null,
  status: ServiceRequestStatus.answered,
  items: [testItemFor(testPedro)],
  currentProposal: TestProposalSummary(
    token: 'proposal-rita-v1',
    validUntil: testProposalsNow.add(const Duration(days: 3)),
    hasPendingAdjustment: true,
  ),
);

final testRequestForLucas = TestClientServiceRequest(
  token: 'request-joao',
  conversationToken: 'conversation-joao',
  driverToken: 'driver-joao',
  driverName: 'João Lima',
  items: [testItemFor(testLucas, shift: SchoolShift.morning)],
  createdAt: testProposalsNow.subtract(const Duration(days: 1)),
  expiresAt: testProposalsNow.add(const Duration(hours: 52)),
);

final testRequestForRemovedChild = TestClientServiceRequest(
  token: 'request-removed',
  driverName: 'Marta Dias',
  items: [
    TestClientRequestItem(
      dependentToken: 'child-removed',
      dependentName: 'Bia',
    ),
  ],
);

final testClosedForPedro = TestClientServiceRequest(
  token: 'request-closed-pedro',
  status: ServiceRequestStatus.withdrawn,
  items: [testItemFor(testPedro)],
);

final testClosedForAna = TestClientServiceRequest(
  token: 'request-closed-ana',
  status: ServiceRequestStatus.converted,
  driverName: 'Paula Reis',
  items: [testItemFor(testAna)],
);

final testOpenRequests = <ClientServiceRequest>[
  testProposalForSiblings,
  testAdjustmentForPedro,
  testRequestForLucas,
  testRequestForRemovedChild,
];

ClientProposals testClientProposals({
  List<Dependent> children = const [testPedro, testAna, testLucas],
  List<ClientServiceRequest>? open,
  List<ClientServiceRequest>? closed,
  int? closedCount,
  int closedPage = 0,
  bool hasMoreClosed = false,
}) {
  final closedRequests = closed ?? [testClosedForPedro, testClosedForAna];
  return ClientProposals(
    loadedAt: testProposalsNow,
    children: children,
    feed: ProposalsFeed(
      open: open ?? testOpenRequests,
      closed: closedRequests,
      closedCount: closedCount ?? closedRequests.length,
    ),
    closedPage: closedPage,
    hasMoreClosed: hasMoreClosed,
  );
}

final testVersion1 = TestProposal(
  token: 'proposal-carlos-v1',
  serviceRequestToken: testProposalForSiblings.token,
  status: ProposalStatus.superseded,
  installmentAmountCents: 34000,
  totalAmountCents: 408000,
  items: [
    TestProposalItem(
      dependentToken: testAna.token,
      dependentName: testAna.name,
      dependentFirstName: 'Ana',
    ),
    TestProposalItem(
      dependentToken: testPedro.token,
      dependentName: testPedro.name,
      dependentFirstName: 'Pedro',
    ),
  ],
  adjustments: [
    TestProposalAdjustment(createdAt: DateTime.utc(2026, 10, 3, 10)),
  ],
  createdAt: DateTime.utc(2026, 10, 2, 9),
);

final testVersion2 = TestProposal(
  token: 'proposal-carlos-v2',
  serviceRequestToken: testProposalForSiblings.token,
  version: 2,
  installmentAmountCents: 30000,
  totalAmountCents: 360000,
  validUntil: testProposalsNow.add(const Duration(days: 6)),
  startsOn: DateTime(2027, 2, 15),
  items: testVersion1.items,
  message: 'Consigo buscar 10 minutos antes.',
  createdAt: DateTime.utc(2026, 10, 4, 9),
);

const testQuoteDriver = DriverProfileDto(
  token: 'driver-carlos',
  name: 'Carlos Souza',
  rating: 4.8,
  available: true,
  vehicles: [
    DriverProfileVehicleDto(
      token: 'van-master',
      brand: 'Renault',
      model: 'Master',
      manufactureYear: 2019,
      color: 'Branca',
      capacity: 15,
    ),
  ],
);

const testBia = TestDependent(
  token: 'dep-bia',
  name: 'Bia Souza',
  birthDate: '2017-05-02',
  address: TestDependentAddress(),
  school: TestDependentSchool(),
);

const testDavi = TestDependent(
  token: 'dep-davi',
  name: 'Davi Souza',
  birthDate: '2019-08-10',
  address: TestDependentAddress(),
);

final testBiaWeek = SchoolWeek.fromDays([
  for (final weekday in weekdaysMondayToFriday)
    SchoolDay(weekday: weekday, shift: SchoolShift.afternoon),
]);

const testDaviMissingSchool = ContractReadiness(
  ready: false,
  gaps: [
    ReadinessGap(
      subject: ContractReadinessSubject.dependent,
      field: ContractReadinessField.school,
      dependentToken: 'dep-davi',
    ),
  ],
);

const testClientWithoutPhone = ContractReadiness(
  ready: false,
  gaps: [
    ReadinessGap(
      subject: ContractReadinessSubject.client,
      field: ContractReadinessField.phone,
    ),
  ],
);
