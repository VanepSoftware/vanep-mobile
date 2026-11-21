import 'package:vanep_mobile/modules/assistant/data/datasources/assistant_home_scenario.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_absence.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_trip_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/no_show_reason.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/stop_confirmation.dart';

abstract class AssistantRouteDataSource {
  Future<AssistantHomeOverview> findHomeOverview();

  Future<AssistantRouteSnapshot?> findTodayRoute(String vanToken);

  Future<AssistantRouteSnapshot> confirmStop(StopConfirmation confirmation);

  Future<AssistantRouteSnapshot> undoStopConfirmation({
    required String vanToken,
    required String stopToken,
  });

  Future<void> markPresentInVan(String vanToken);
}

const mockedVanCarlosToken = 'mock-van-carlos';
const mockedVanRitaToken = 'mock-van-rita';
const mockedSchoolHorizonte = 'Colégio Horizonte';
const mockedSchoolClasse10 = 'Escola Classe 10';

const mockedVanCarlos = AssistantVan(
  token: mockedVanCarlosToken,
  driverToken: 'mock-driver-carlos',
  driverName: 'Carlos Mendes',
  plate: 'SDF4E21',
  model: 'Sprinter',
  shift: 'MORNING',
);

const mockedVanRita = AssistantVan(
  token: mockedVanRitaToken,
  driverToken: 'mock-driver-rita',
  driverName: 'Rita Souza',
  plate: 'PBX7C19',
  model: 'Ducato',
  shift: 'AFTERNOON',
);

class MockedHomeStop {
  const MockedHomeStop(this.label, this.minutesAfterSix, this.passengers);

  final String label;
  final int minutesAfterSix;
  final List<String> passengers;
}

const mockedHomeStops = [
  MockedHomeStop('QNL 3, casa 8', 28, ['Helena Reis', 'Davi Reis']),
  MockedHomeStop('QNL 4, Conjunto B', 33, ['Laura Mendes', 'Theo Martins']),
  MockedHomeStop('QNL 5, Conjunto F', 40, ['Pedro Oliveira', 'Ana Oliveira']),
  MockedHomeStop('QNL 5, Conjunto H', 44, [
    'Júlia Barros',
    'Enzo Barros',
    'Lívia Barros',
  ]),
  MockedHomeStop('QNL 5, Conjunto J, casa 12', 48, [
    'Beatriz Santos',
    'Gabriel Santos',
  ]),
  MockedHomeStop('QNL 7, casa 3', 52, ['Sofia Lima', 'Lucas Prado']),
  MockedHomeStop('QNL 9, Conjunto A', 57, ['Miguel Teixeira', 'Laís Teixeira']),
  MockedHomeStop('QNL 10, casa 4', 61, ['Rafael Costa']),
];

const mockedClasse10Students = {'Miguel Teixeira', 'Laís Teixeira'};
const mockedAbsentStudents = {'Ana Oliveira', 'Lucas Prado'};
const mockedNoShowStudent = 'Laura Mendes';

String mockedPassengerToken(String name) =>
    'mock-passenger-${name.split(' ').first.toLowerCase()}';

String mockedSchoolOf(String name) => mockedClasse10Students.contains(name)
    ? mockedSchoolClasse10
    : mockedSchoolHorizonte;

// TODO(VAN-67): mocked links, invite and today's route of the prototype
// (frames aux-home-1…6). Real data needs, in vanep-api-java: the N:N
// driver_assistant link with status per van (B1), GET /api/assistants/me/vans
// (B2), the assistant's read of today's route (B3), batch stop confirmation and
// undo over checklist_entry (B4), "Estou na van" (B5) and the pause reason/date
// (B10). Delete this class, AssistantHomeScenario and their registration in
// assistant_container.dart when they are wired.
class MockedAssistantRouteDataSource implements AssistantRouteDataSource {
  MockedAssistantRouteDataSource({
    this.scenario = AssistantHomeScenario.beforeRoute,
    this.clock = DateTime.now,
  });

  final AssistantHomeScenario scenario;
  final DateTime Function() clock;
  final Map<String, AssistantRouteSnapshot> routesByVan = {};
  final Map<String, AssistantRouteSnapshot> routesBeforeLastConfirmation = {};

  DateTime todayAt(int minutesAfterSix) {
    final now = clock();
    return DateTime(now.year, now.month, now.day, 6, minutesAfterSix);
  }

  @override
  Future<AssistantHomeOverview> findHomeOverview() async {
    return switch (scenario) {
      AssistantHomeScenario.noVan => const AssistantHomeOverview(),
      AssistantHomeScenario.inviteReceived => AssistantHomeOverview(
        pendingInvite: AssistantInvite(
          token: 'mock-invite-carlos',
          driverName: mockedVanCarlos.driverName,
          driverRating: 4.9,
          vehicleDescription: 'Sprinter · SDF4E21',
          expiresAt: clock().add(const Duration(days: 2)),
          status: 'PENDING',
        ),
      ),
      AssistantHomeScenario.accessPaused => AssistantHomeOverview(
        links: [
          AssistantVanLink(
            van: mockedVanCarlos,
            status: AssistantLinkStatus.inactive,
            statusChangedAt: clock().subtract(const Duration(days: 2)),
          ),
          const AssistantVanLink(
            van: mockedVanRita,
            status: AssistantLinkStatus.active,
          ),
        ],
      ),
      _ => const AssistantHomeOverview(
        links: [
          AssistantVanLink(
            van: mockedVanCarlos,
            status: AssistantLinkStatus.active,
          ),
          AssistantVanLink(
            van: mockedVanRita,
            status: AssistantLinkStatus.active,
          ),
        ],
      ),
    };
  }

  @override
  Future<AssistantRouteSnapshot?> findTodayRoute(String vanToken) async {
    if (vanToken != mockedVanCarlosToken) return null;
    return routesByVan[vanToken] ??= buildCarlosRoute();
  }

  AssistantRouteSnapshot buildCarlosRoute() {
    final finishedStopCount = switch (scenario) {
      AssistantHomeScenario.onRouteBoarding => 4,
      AssistantHomeScenario.onRouteDropOff => 8,
      _ => 0,
    };
    final isOnRoute = finishedStopCount > 0;
    return AssistantRouteSnapshot(
      tripToken: 'mock-trip-carlos-morning',
      tripStatus: isOnRoute
          ? AssistantTripStatus.inProgress
          : AssistantTripStatus.scheduled,
      shift: mockedVanCarlos.shift,
      startedAt: isOnRoute ? todayAt(21) : null,
      departureAt: todayAt(20),
      stops: [...buildOutboundStops(finishedStopCount), ...buildReturnStops()],
      todayAbsences: [
        AssistantAbsence(
          passengerToken: mockedPassengerToken('Ana Oliveira'),
          passengerName: 'Ana Oliveira',
          date: todayAt(0),
          kind: AbsenceKind.notGoing,
          source: AbsenceSource.client,
          notifiedAt: todayAt(2),
        ),
        AssistantAbsence(
          passengerToken: mockedPassengerToken('Lucas Prado'),
          passengerName: 'Lucas Prado',
          date: todayAt(0),
          kind: AbsenceKind.notGoing,
          source: AbsenceSource.client,
          notifiedAt: todayAt(0).subtract(const Duration(hours: 14)),
        ),
      ],
    );
  }

  List<AssistantRouteStop> buildOutboundStops(int finishedStopCount) {
    final homeStops = [
      for (final (index, stop) in mockedHomeStops.indexed)
        buildHomePickup(index, stop, finishedStopCount: finishedStopCount),
    ];
    final allStudents = mockedHomeStops.expand((stop) => stop.passengers);
    AssistantRouteStop school(int sequence, String name, int minutes) {
      final status = finishedStopCount == sequence - 1
          ? RouteStopStatus.arrived
          : RouteStopStatus.pending;
      return AssistantRouteStop(
        token: 'mock-stop-$sequence',
        kind: RouteStopKind.dropOffSchool,
        sequence: sequence,
        status: status,
        label: name,
        plannedArrivalAt: todayAt(minutes),
        passengers: [
          for (final student in allStudents)
            if (mockedSchoolOf(student) == name)
              mockedPassenger(student, ChecklistStatus.pending),
        ],
      );
    }

    return [
      ...homeStops,
      school(9, mockedSchoolHorizonte, 75),
      school(10, mockedSchoolClasse10, 85),
    ];
  }

  AssistantRouteStop buildHomePickup(
    int index,
    MockedHomeStop stop, {
    required int finishedStopCount,
  }) {
    final isFinished = index < finishedStopCount;
    final isCurrent = scenario.isOnRoute && index == finishedStopCount;
    return AssistantRouteStop(
      token: 'mock-stop-${index + 1}',
      kind: RouteStopKind.pickupHome,
      sequence: index + 1,
      status: isFinished
          ? RouteStopStatus.done
          : (isCurrent ? RouteStopStatus.arrived : RouteStopStatus.pending),
      label: stop.label,
      plannedArrivalAt: todayAt(stop.minutesAfterSix),
      completedAt: isFinished ? todayAt(stop.minutesAfterSix + 1) : null,
      passengers: [
        for (final name in stop.passengers)
          mockedPassenger(
            name,
            !isFinished
                ? ChecklistStatus.pending
                : (name == mockedNoShowStudent
                      ? ChecklistStatus.skipped
                      : ChecklistStatus.done),
            confirmedAt: isFinished ? todayAt(stop.minutesAfterSix + 1) : null,
          ),
      ],
    );
  }

  List<AssistantRouteStop> buildReturnStops() {
    final allStudents = mockedHomeStops.expand((stop) => stop.passengers);
    return [
      AssistantRouteStop(
        token: 'mock-stop-11',
        kind: RouteStopKind.pickupSchool,
        sequence: 11,
        status: RouteStopStatus.pending,
        label: mockedSchoolHorizonte,
        passengers: [
          for (final student in allStudents)
            if (mockedSchoolOf(student) == mockedSchoolHorizonte)
              mockedPassenger(student, ChecklistStatus.pending),
        ],
      ),
      for (final (index, stop) in mockedHomeStops.reversed.indexed)
        AssistantRouteStop(
          token: 'mock-stop-${12 + index}',
          kind: RouteStopKind.dropOffHome,
          sequence: 12 + index,
          status: RouteStopStatus.pending,
          label: stop.label,
          passengers: [
            for (final name in stop.passengers)
              mockedPassenger(name, ChecklistStatus.pending),
          ],
        ),
    ];
  }

  AssistantRoutePassenger mockedPassenger(
    String name,
    ChecklistStatus status, {
    DateTime? confirmedAt,
  }) {
    final isAbsent = mockedAbsentStudents.contains(name);
    return AssistantRoutePassenger(
      token: mockedPassengerToken(name),
      name: name,
      schoolName: mockedSchoolOf(name),
      checklistStatus: isAbsent ? ChecklistStatus.absent : status,
      confirmedAt: isAbsent ? null : confirmedAt,
      noShowReason:
          !isAbsent &&
              name == mockedNoShowStudent &&
              status == ChecklistStatus.skipped
          ? NoShowReason.notAtStop
          : null,
    );
  }

  @override
  Future<AssistantRouteSnapshot> confirmStop(
    StopConfirmation confirmation,
  ) async {
    final route = (await findTodayRoute(confirmation.vanToken))!;
    final now = clock();
    final updated = AssistantRouteSnapshot(
      tripToken: route.tripToken,
      tripStatus: route.tripStatus,
      shift: route.shift,
      startedAt: route.startedAt,
      departureAt: route.departureAt,
      todayAbsences: route.todayAbsences,
      stops: [
        for (final stop in route.stops)
          stop.token == confirmation.stopToken
              ? confirmedStop(stop, confirmation, now)
              : stop,
      ],
    );
    routesBeforeLastConfirmation[confirmation.vanToken] = route;
    return routesByVan[confirmation.vanToken] = updated;
  }

  AssistantRouteStop confirmedStop(
    AssistantRouteStop stop,
    StopConfirmation confirmation,
    DateTime now,
  ) {
    return AssistantRouteStop(
      token: stop.token,
      kind: stop.kind,
      sequence: stop.sequence,
      status: RouteStopStatus.done,
      label: stop.label,
      plannedArrivalAt: stop.plannedArrivalAt,
      completedAt: now,
      passengers: [
        for (final passenger in stop.passengers)
          if (confirmation.confirmedPassengerTokens.contains(passenger.token))
            mockedPassengerWith(passenger, ChecklistStatus.done, now)
          else if (confirmation.skippedPassengers[passenger.token]
              case final reason?)
            mockedPassengerWith(
              passenger,
              ChecklistStatus.skipped,
              now,
              reason: reason,
              notes: confirmation.skipNotes[passenger.token],
            )
          else
            passenger,
      ],
    );
  }

  AssistantRoutePassenger mockedPassengerWith(
    AssistantRoutePassenger passenger,
    ChecklistStatus status,
    DateTime confirmedAt, {
    NoShowReason? reason,
    String? notes,
  }) {
    return AssistantRoutePassenger(
      token: passenger.token,
      name: passenger.name,
      schoolName: passenger.schoolName,
      photoUrl: passenger.photoUrl,
      siblingTokens: passenger.siblingTokens,
      checklistStatus: status,
      confirmedAt: confirmedAt,
      noShowReason: reason,
      skipNotes: notes,
    );
  }

  @override
  Future<AssistantRouteSnapshot> undoStopConfirmation({
    required String vanToken,
    required String stopToken,
  }) async {
    final previous = routesBeforeLastConfirmation.remove(vanToken);
    if (previous == null) return (await findTodayRoute(vanToken))!;
    return routesByVan[vanToken] = previous;
  }

  @override
  Future<void> markPresentInVan(String vanToken) async {}
}

extension AssistantHomeScenarioRoute on AssistantHomeScenario {
  bool get isOnRoute =>
      this == AssistantHomeScenario.onRouteBoarding ||
      this == AssistantHomeScenario.onRouteDropOff;
}
