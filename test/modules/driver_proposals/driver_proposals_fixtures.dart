import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/driver_proposals/domain/value_objects/driver_negotiations.dart';
import 'package:vanep_mobile/modules/driver_vans/data/dtos/driver_van_dto.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/negotiation_page.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/proposal_status.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/service_request_status.dart';

import '../negotiations/negotiations_fixtures.dart';

final driverNow = DateTime(2026, 10, 2, 9);

const masterVan = DriverVanDto(
  token: 'van-master',
  plate: 'JKL1A23',
  brand: 'Renault',
  model: 'Master',
  manufactureYear: 2019,
  color: 'Branca',
  capacity: 15,
);

const sprinterVan = DriverVanDto(
  token: 'van-sprinter',
  plate: 'ABC1D23',
  brand: 'Mercedes-Benz',
  model: 'Sprinter',
  manufactureYear: 2021,
  color: 'Prata',
  capacity: 18,
);

final newRequestForSiblings = TestDriverServiceRequest(
  token: 'request-new',
  items: [
    TestDriverRequestItem(),
    TestDriverRequestItem(
      dependentToken: 'dep-alice',
      dependentFirstName: 'Alice',
      dependentAge: 7,
    ),
  ],
);

final adjustmentRequest = TestDriverServiceRequest(
  token: 'request-adjust',
  status: ServiceRequestStatus.answered,
  currentProposal: TestProposalSummary(hasPendingAdjustment: true),
  clientFirstName: 'Joana',
);

final awaitingRequest = TestDriverServiceRequest(
  token: 'request-awaiting',
  status: ServiceRequestStatus.answered,
  currentProposal: TestProposalSummary(
    token: 'proposal-awaiting',
    validUntil: DateTime(2026, 10, 7, 12),
  ),
  clientFirstName: 'Paula',
);

NegotiationPage<DriverServiceRequest> driverPage(
  List<DriverServiceRequest> items, {
  bool isLast = true,
  int? totalElements,
}) {
  return NegotiationPage(
    items: items,
    isLast: isLast,
    totalElements: totalElements ?? items.length,
  );
}

DriverNegotiations driverNegotiationsOf(List<DriverServiceRequest> requests) {
  return DriverNegotiations(
    requests: requests,
    loadedAt: driverNow,
    totalCount: requests.length,
  );
}

final versionWithAdjustment = TestProposal(
  serviceRequestToken: 'request-adjust',
  adjustments: [
    TestProposalAdjustment(
      createdAt: DateTime.utc(2026, 10, 3, 10),
      note: 'Consegue um pouco menos?',
    ),
  ],
);

final supersededVersion = TestProposal(status: ProposalStatus.superseded);

final wednesdayOutboundOnly = [
  for (final weekday in [Weekday.monday, Weekday.tuesday])
    TestRequestedDay(weekday: weekday),
  const TestRequestedDay(weekday: Weekday.wednesday, needsReturn: false),
];
