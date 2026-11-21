import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_trip_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';

import 'assistant_fixtures.dart';

const testRouteSchoolHorizonte = 'Colégio Horizonte';
const testRouteSchoolClasse10 = 'Escola Classe 10';

AssistantRoutePassenger testRoutePassenger(
  String name, {
  ChecklistStatus status = ChecklistStatus.pending,
  String school = testRouteSchoolHorizonte,
  NoShowReason? noShowReason,
}) {
  return AssistantRoutePassenger(
    token: 'passenger-${name.toLowerCase()}',
    name: name,
    schoolName: school,
    checklistStatus: status,
    noShowReason: noShowReason,
  );
}

AssistantRouteStop testRouteStop(
  int sequence,
  RouteStopKind kind,
  List<AssistantRoutePassenger> passengers, {
  RouteStopStatus status = RouteStopStatus.pending,
  String? label,
}) {
  return AssistantRouteStop(
    token: 'stop-$sequence',
    kind: kind,
    sequence: sequence,
    status: status,
    label: label ?? 'QNL $sequence',
    passengers: passengers,
  );
}

final testRouteAbsenceAna = AssistantAbsence(
  passengerToken: 'passenger-ana',
  passengerName: 'Ana',
  date: DateTime(2026, 10, 14),
  kind: AbsenceKind.notGoing,
  source: AbsenceSource.client,
  notifiedAt: DateTime(2026, 10, 14, 6, 2),
);

List<AssistantRouteStop> testReturnLegStops() => [
  testRouteStop(7, RouteStopKind.pickupSchool, [
    testRoutePassenger('Helena'),
    testRoutePassenger('Davi'),
  ], label: testRouteSchoolHorizonte),
  testRouteStop(8, RouteStopKind.dropOffHome, [
    testRoutePassenger('Helena'),
    testRoutePassenger('Davi'),
  ]),
];

AssistantRouteSnapshot testRouteOnPickup() => AssistantRouteSnapshot(
  tripToken: 'trip-carlos-morning',
  tripStatus: AssistantTripStatus.inProgress,
  stops: [
    testRouteStop(1, RouteStopKind.pickupHome, [
      testRoutePassenger('Helena', status: ChecklistStatus.done),
      testRoutePassenger('Davi', status: ChecklistStatus.done),
    ], status: RouteStopStatus.done),
    testRouteStop(2, RouteStopKind.pickupHome, [
      testRoutePassenger('Theo', status: ChecklistStatus.done),
      testRoutePassenger(
        'Laura',
        status: ChecklistStatus.skipped,
        noShowReason: NoShowReason.notAtStop,
      ),
    ], status: RouteStopStatus.done),
    testRouteStop(3, RouteStopKind.pickupHome, [
      testRoutePassenger('Beatriz'),
      testRoutePassenger('Gabriel'),
    ], status: RouteStopStatus.arrived),
    testRouteStop(4, RouteStopKind.pickupHome, [
      testRoutePassenger('Miguel', school: testRouteSchoolClasse10),
      testRoutePassenger('Ana', status: ChecklistStatus.absent),
    ]),
    testRouteStop(5, RouteStopKind.dropOffSchool, [
      testRoutePassenger('Helena'),
      testRoutePassenger('Davi'),
      testRoutePassenger('Theo'),
      testRoutePassenger('Beatriz'),
      testRoutePassenger('Gabriel'),
    ], label: testRouteSchoolHorizonte),
    testRouteStop(6, RouteStopKind.dropOffSchool, [
      testRoutePassenger('Miguel', school: testRouteSchoolClasse10),
    ], label: testRouteSchoolClasse10),
    ...testReturnLegStops(),
  ],
  todayAbsences: [testRouteAbsenceAna],
);

AssistantRouteSnapshot testRouteAtSchool() => AssistantRouteSnapshot(
  tripToken: 'trip-carlos-morning',
  tripStatus: AssistantTripStatus.inProgress,
  stops: [
    testRouteStop(1, RouteStopKind.pickupHome, [
      testRoutePassenger('Helena', status: ChecklistStatus.done),
      testRoutePassenger('Davi', status: ChecklistStatus.done),
    ], status: RouteStopStatus.done),
    testRouteStop(4, RouteStopKind.pickupHome, [
      testRoutePassenger(
        'Miguel',
        status: ChecklistStatus.done,
        school: testRouteSchoolClasse10,
      ),
    ], status: RouteStopStatus.done),
    testRouteStop(
      5,
      RouteStopKind.dropOffSchool,
      [testRoutePassenger('Helena'), testRoutePassenger('Davi')],
      label: testRouteSchoolHorizonte,
      status: RouteStopStatus.arrived,
    ),
    testRouteStop(6, RouteStopKind.dropOffSchool, [
      testRoutePassenger('Miguel', school: testRouteSchoolClasse10),
    ], label: testRouteSchoolClasse10),
    ...testReturnLegStops(),
  ],
);

AssistantRouteSnapshot testRouteAfterFirstSchool() => AssistantRouteSnapshot(
  tripToken: 'trip-carlos-morning',
  tripStatus: AssistantTripStatus.inProgress,
  stops: [
    testRouteStop(1, RouteStopKind.pickupHome, [
      testRoutePassenger('Helena', status: ChecklistStatus.done),
    ], status: RouteStopStatus.done),
    testRouteStop(
      5,
      RouteStopKind.dropOffSchool,
      [testRoutePassenger('Helena', status: ChecklistStatus.done)],
      label: testRouteSchoolHorizonte,
      status: RouteStopStatus.done,
    ),
  ],
);

AssistantRouteSnapshot testRouteNotStarted() => AssistantRouteSnapshot(
  tripToken: 'trip-carlos-morning',
  tripStatus: AssistantTripStatus.scheduled,
  stops: [
    testRouteStop(1, RouteStopKind.pickupHome, [testRoutePassenger('Helena')]),
    testRouteStop(2, RouteStopKind.pickupHome, [testRoutePassenger('Theo')]),
    testRouteStop(3, RouteStopKind.pickupHome, [testRoutePassenger('Pedro')]),
    testRouteStop(4, RouteStopKind.pickupHome, [testRoutePassenger('Sofia')]),
    testRouteStop(5, RouteStopKind.dropOffSchool, [
      testRoutePassenger('Helena'),
      testRoutePassenger('Theo'),
      testRoutePassenger('Pedro'),
      testRoutePassenger('Sofia'),
    ], label: testRouteSchoolHorizonte),
  ],
);

final testStopConfirmationAtPickup = StopConfirmation(
  vanToken: testAssistantVanPrimary.token,
  stopToken: 'stop-3',
  confirmedPassengerTokens: ['passenger-beatriz'],
  skippedPassengers: {'passenger-gabriel': NoShowReason.notAtStop},
);

final testLinkCarlosActive = AssistantVanLink(
  van: testAssistantVanPrimary,
  status: AssistantLinkStatus.active,
);

final testLinkRitaActive = AssistantVanLink(
  van: testAssistantVanSecondary,
  status: AssistantLinkStatus.active,
);

final testLinkCarlosPaused = AssistantVanLink(
  van: testAssistantVanPrimary,
  status: AssistantLinkStatus.inactive,
  statusChangedAt: DateTime(2026, 10, 12),
);

final testHomeOverviewTwoVans = AssistantHomeOverview(
  links: [testLinkCarlosActive, testLinkRitaActive],
);

final testHomeOverviewCarlosPaused = AssistantHomeOverview(
  links: [testLinkCarlosPaused, testLinkRitaActive],
);
