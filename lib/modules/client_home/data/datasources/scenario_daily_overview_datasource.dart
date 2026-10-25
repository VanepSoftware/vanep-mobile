import 'package:vanep_mobile/modules/client_home/data/datasources/client_home_scenario.dart';
import 'package:vanep_mobile/modules/client_home/data/datasources/daily_overview_datasource.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/day_event.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';

DateTime dayAt(DateTime day, int hour, [int minute = 0]) =>
    DateTime(day.year, day.month, day.day, hour, minute);

DateTime nextWeekdayAfter(DateTime day) {
  var candidate = DateTime(day.year, day.month, day.day + 1);
  while (candidate.weekday > DateTime.friday) {
    candidate = DateTime(candidate.year, candidate.month, candidate.day + 1);
  }
  return candidate;
}

List<DateTime> nextWeekdays(DateTime day, int count) {
  final weekdays = <DateTime>[];
  var cursor = day;
  while (weekdays.length < count) {
    cursor = nextWeekdayAfter(cursor);
    weekdays.add(cursor);
  }
  return weekdays;
}

// TODO(VAN-41): mocked data for development only. Every overview below is
// fake and must be replaced by the remote data source as each endpoint lands
// (see tasks 6.1–6.4); delete this class, ClientHomeScenario and
// CLIENT_HOME_SCENARIO once all of them are wired.
class ScenarioDailyOverviewDataSource implements DailyOverviewDataSource {
  const ScenarioDailyOverviewDataSource({
    required this.scenario,
    this.clock = DateTime.now,
  });

  final ClientHomeScenario scenario;

  final DateTime Function() clock;

  @override
  Future<DailyOverview> findDailyOverview() async {
    final now = clock();
    return switch (scenario) {
      ClientHomeScenario.firstAccess => const DailyOverview(),
      ClientHomeScenario.negotiating => negotiatingOverview(now),
      ClientHomeScenario.everythingAtOnce => everythingAtOnceOverview(now),
      ClientHomeScenario.beforeRoute => beforeRouteOverview(now),
      ClientHomeScenario.vanArriving => vanArrivingOverview(now),
      ClientHomeScenario.arrivedAtSchool => arrivedAtSchoolOverview(now),
      ClientHomeScenario.noRouteToday => noRouteTodayOverview(now),
    };
  }

  // TODO(VAN-41): mocked negotiation and proposals; replace with the
  // proposals endpoint (api-java #30).
  DailyOverview negotiatingOverview(DateTime now) {
    return DailyOverview(
      today: const NegotiatingSection(
        childNames: ['Ana', 'Pedro'],
        openNegotiations: 3,
      ),
      needsYou: [
        NewProposalItem(
          driverName: 'Carlos Souza',
          childNames: const ['Ana', 'Pedro'],
          roundTrip: true,
          monthlyFeeCents: 65000,
          expiresAt: now.add(const Duration(days: 6)),
        ),
        const ExpiredRequestItem(driverName: 'Rita Alves'),
      ],
    );
  }

  // TODO(VAN-41): mocked route, live trip, payment, proposal and contract;
  // replace with the daily route, payments (#17), proposals (#30) and
  // contract (#31/#32) endpoints.
  DailyOverview everythingAtOnceOverview(DateTime now) {
    return DailyOverview(
      today: VanDaySection(
        vans: [
          carlosMorningVan(
            now,
            riders: const [VanRider(name: 'Ana')],
            live: liveTrip(now),
          ),
        ],
        childrenWithoutRoute: const [
          ChildWithoutRoute(name: 'Pedro', reason: NoRouteReason.noVanYet),
        ],
      ),
      needsYou: [
        PaymentItem(
          amountCents: 35000,
          dueAt: now.add(const Duration(days: 1)),
          childName: 'Ana',
        ),
        NewProposalItem(
          driverName: 'Rita Alves',
          childNames: const ['Pedro'],
          roundTrip: true,
          monthlyFeeCents: 32000,
          expiresAt: now.add(const Duration(days: 7)),
        ),
        ContractToSignItem(
          childName: 'Pedro',
          driverName: 'João Pedro Lima',
          monthlyFeeCents: 30000,
          signBy: now.add(const Duration(days: 2)),
        ),
      ],
    );
  }

  // TODO(VAN-41): mocked vans, absence, stop change and payment; replace with
  // the daily route and payments (#17) endpoints.
  DailyOverview beforeRouteOverview(DateTime now) {
    return DailyOverview(
      today: VanDaySection(
        vans: [
          carlosMorningVan(
            now,
            absentRider: 'Ana',
            stopChange: const StopChange(
              childName: 'Pedro',
              leg: TripLeg.returning,
              placeLabel: 'casa da avó',
            ),
          ),
          ritaAfternoonVan(now),
        ],
        childrenWithoutRoute: const [
          ChildWithoutRoute(
            name: 'Bia',
            reason: NoRouteReason.goesWithGuardian,
          ),
          ChildWithoutRoute(name: 'Davi', reason: NoRouteReason.noVanYet),
        ],
      ),
      needsYou: [
        PaymentItem(
          amountCents: 65000,
          dueAt: dayAt(now, 0),
          awaitingConfirmationFrom: 'Carlos',
        ),
      ],
    );
  }

  // TODO(VAN-41): mocked live trip and child day; replace with the daily route
  // and live trip endpoints.
  DailyOverview vanArrivingOverview(DateTime now) {
    return DailyOverview(
      today: VanDaySection(
        vans: [
          carlosMorningVan(
            now,
            absentRider: 'Ana',
            live: liveTrip(now, approaching: true),
          ),
        ],
        childDay: ChildDayPlan(
          childName: 'Pedro',
          milestones: [
            DayMilestone(
              kind: DayMilestoneKind.homeBoarding,
              at: dayAt(now, 6, 46),
              estimated: true,
              current: true,
            ),
            DayMilestone(
              kind: DayMilestoneKind.schoolArrival,
              at: dayAt(now, 7, 15),
            ),
            DayMilestone(
              kind: DayMilestoneKind.schoolDeparture,
              at: dayAt(now, 12, 30),
            ),
            DayMilestone(
              kind: DayMilestoneKind.homeArrival,
              at: dayAt(now, 13, 5),
              estimated: true,
              placeLabel: 'casa da avó',
            ),
          ],
        ),
      ),
    );
  }

  // TODO(VAN-41): mocked arrival and day events; replace with the daily route
  // and live trip endpoints.
  DailyOverview arrivedAtSchoolOverview(DateTime now) {
    return DailyOverview(
      today: ArrivedSection(
        childName: 'Pedro',
        schoolName: 'Colégio Horizonte',
        confirmedAt: dayAt(now, 7, 18),
        schoolDepartureAt: dayAt(now, 12, 30),
        returnPlaceLabel: 'casa da avó',
        events: [
          DayEvent(
            kind: DayEventKind.droppedAtSchool,
            at: dayAt(now, 7, 18),
            actorName: 'Marcos',
          ),
          DayEvent(
            kind: DayEventKind.boardedAtHome,
            at: dayAt(now, 6, 47),
            actorName: 'Marcos',
          ),
          DayEvent(
            kind: DayEventKind.routeStarted,
            at: dayAt(now, 6, 21),
            actorName: 'Carlos',
          ),
          DayEvent(
            kind: DayEventKind.absence,
            at: dayAt(now, 6, 2),
            childName: 'Ana',
          ),
        ],
      ),
    );
  }

  // TODO(VAN-41): mocked week plan, rating, renewal and inspection items;
  // replace with the daily route endpoint and the driver/contract endpoints
  // that will serve these items.
  DailyOverview noRouteTodayOverview(DateTime now) {
    final weekdays = nextWeekdays(now, 5);
    return DailyOverview(
      today: NoRouteTodaySection(
        nextRouteAt: dayAt(weekdays.first, 6, 40),
        week: [
          for (final (index, day) in weekdays.indexed)
            WeekDayPlan(date: day, going: true, returning: index != 2),
        ],
      ),
      needsYou: [
        const RateDriverItem(driverName: 'Carlos Souza'),
        const RenewalItem(driverName: 'Carlos', year: 2027),
        VehicleInspectionExpiredItem(
          driverName: 'Carlos',
          regularizeBy: now.add(const Duration(days: 14)),
        ),
      ],
    );
  }

  // TODO(VAN-41): mocked live trip shared by everythingAtOnce and
  // vanArriving; replace with the live trip endpoint.
  LiveTrip liveTrip(DateTime now, {bool approaching = false}) {
    return LiveTrip(
      leg: TripLeg.going,
      stage: TripStage.boarding,
      etaMinutes: 6,
      etaAt: now.add(const Duration(minutes: 6)),
      updatedAt: now.subtract(const Duration(seconds: 3)),
      approaching: approaching,
      crewNames: const ['Carlos', 'Marcos'],
    );
  }

  // TODO(VAN-41): mocked van shared by everythingAtOnce, beforeRoute and
  // vanArriving; replace with the daily route endpoint.
  VanDay carlosMorningVan(
    DateTime now, {
    String? absentRider,
    List<VanRider>? riders,
    LiveTrip? live,
    StopChange? stopChange,
  }) {
    return VanDay(
      driverName: 'Carlos',
      vehicleModel: 'Sprinter',
      plate: 'SDF4E21',
      shift: SchoolShift.morning,
      departureAt: dayAt(now, 6, 20),
      riders:
          riders ??
          [
            const VanRider(name: 'Pedro'),
            VanRider(name: 'Ana', absentToday: absentRider == 'Ana'),
          ],
      schedule: VanSchedule(
        boardingStartAt: dayAt(now, 6, 40),
        boardingEndAt: dayAt(now, 6, 50),
        schoolArrivalAt: dayAt(now, 7, 15),
        schoolDepartureAt: dayAt(now, 12, 30),
      ),
      live: live,
      stopChange: stopChange,
    );
  }

  // TODO(VAN-41): mocked van used by beforeRoute; replace with the daily route
  // endpoint.
  VanDay ritaAfternoonVan(DateTime now) {
    return VanDay(
      driverName: 'Rita',
      vehicleModel: 'Ducato',
      plate: 'JKL1A23',
      shift: SchoolShift.afternoon,
      departureAt: dayAt(now, 11, 20),
      riders: const [VanRider(name: 'Lucas')],
      schedule: VanSchedule(
        boardingStartAt: dayAt(now, 11, 40),
        boardingEndAt: dayAt(now, 11, 50),
        schoolArrivalAt: dayAt(now, 12, 30),
        schoolDepartureAt: dayAt(now, 18),
      ),
    );
  }
}
