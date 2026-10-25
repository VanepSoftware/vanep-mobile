import 'package:vanep_mobile/modules/client_home/domain/value_objects/client_home.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/day_event.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/needs_you_item.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/today_section.dart';
import 'package:vanep_mobile/modules/client_home/domain/value_objects/van_day.dart';

final testWednesdayMorning = DateTime(2026, 11, 4, 6, 40);

final testSaturdayMorning = DateTime(2026, 10, 17, 9);

DateTime atWednesday(int hour, [int minute = 0]) =>
    DateTime(2026, 11, 4, hour, minute);

final testContractToSign = ContractToSignItem(
  childName: 'Pedro',
  driverName: 'João Pedro Lima',
  monthlyFeeCents: 30000,
  signBy: DateTime(2026, 11, 6, 23, 59),
);

final testRitaProposal = NewProposalItem(
  driverName: 'Rita Alves',
  childNames: const ['Pedro'],
  roundTrip: true,
  monthlyFeeCents: 32000,
  expiresAt: DateTime(2026, 11, 10),
);

final testCarlosProposal = NewProposalItem(
  driverName: 'Carlos Souza',
  childNames: const ['Ana', 'Pedro'],
  roundTrip: true,
  monthlyFeeCents: 65000,
  expiresAt: DateTime(2026, 11, 6),
);

const testExpiredRequest = ExpiredRequestItem(driverName: 'Rita Alves');

final testAnaMonthlyFee = PaymentItem(
  amountCents: 35000,
  dueAt: DateTime(2026, 11, 5),
  childName: 'Ana',
);

final testOctoberFeeAwaitingConfirmation = PaymentItem(
  amountCents: 65000,
  dueAt: DateTime(2026, 10, 10),
  awaitingConfirmationFrom: 'Carlos',
);

const testRenewal = RenewalItem(driverName: 'Carlos', year: 2027);

final testInspectionExpired = VehicleInspectionExpiredItem(
  driverName: 'Carlos',
  regularizeBy: DateTime(2026, 10, 31),
);

const testRateCarlos = RateDriverItem(driverName: 'Carlos Souza');

final testCarlosMorningVan = VanDay(
  driverName: 'Carlos',
  vehicleModel: 'Sprinter',
  plate: 'SDF4E21',
  shift: SchoolShift.morning,
  departureAt: atWednesday(6, 20),
  riders: const [
    VanRider(name: 'Pedro'),
    VanRider(name: 'Ana', absentToday: true),
  ],
  schedule: VanSchedule(
    boardingStartAt: atWednesday(6, 40),
    boardingEndAt: atWednesday(6, 50),
    schoolArrivalAt: atWednesday(7, 15),
    schoolDepartureAt: atWednesday(12, 30),
  ),
  stopChange: const StopChange(
    childName: 'Pedro',
    leg: TripLeg.returning,
    placeLabel: 'casa da avó',
  ),
);

final testRitaAfternoonVan = VanDay(
  driverName: 'Rita',
  vehicleModel: 'Ducato',
  plate: 'JKL1234',
  shift: SchoolShift.afternoon,
  departureAt: atWednesday(11, 20),
  riders: const [VanRider(name: 'Lucas')],
  schedule: VanSchedule(
    boardingStartAt: atWednesday(11, 40),
    boardingEndAt: atWednesday(11, 50),
    schoolArrivalAt: atWednesday(12, 30),
    schoolDepartureAt: atWednesday(18),
  ),
);

LiveTrip testLiveTrip({bool approaching = false}) => LiveTrip(
  leg: TripLeg.going,
  stage: TripStage.boarding,
  etaMinutes: 6,
  etaAt: atWednesday(6, 46),
  updatedAt: atWednesday(6, 40),
  approaching: approaching,
  crewNames: const ['Carlos', 'Marcos'],
);

VanDay testLiveVan({bool approaching = false}) => VanDay(
  driverName: testCarlosMorningVan.driverName,
  vehicleModel: testCarlosMorningVan.vehicleModel,
  plate: testCarlosMorningVan.plate,
  shift: testCarlosMorningVan.shift,
  departureAt: testCarlosMorningVan.departureAt,
  riders: testCarlosMorningVan.riders,
  schedule: testCarlosMorningVan.schedule,
  live: testLiveTrip(approaching: approaching),
);

final testBeforeRouteSection = VanDaySection(
  vans: [testCarlosMorningVan, testRitaAfternoonVan],
  childrenWithoutRoute: const [
    ChildWithoutRoute(name: 'Bia', reason: NoRouteReason.goesWithGuardian),
    ChildWithoutRoute(name: 'Davi', reason: NoRouteReason.noVanYet),
  ],
);

final testPedroDay = ChildDayPlan(
  childName: 'Pedro',
  milestones: [
    DayMilestone(
      kind: DayMilestoneKind.homeBoarding,
      at: atWednesday(6, 46),
      estimated: true,
      current: true,
    ),
    DayMilestone(kind: DayMilestoneKind.schoolArrival, at: atWednesday(7, 15)),
    DayMilestone(
      kind: DayMilestoneKind.schoolDeparture,
      at: atWednesday(12, 30),
    ),
    DayMilestone(
      kind: DayMilestoneKind.homeArrival,
      at: atWednesday(13, 5),
      estimated: true,
      placeLabel: 'casa da avó',
    ),
  ],
);

VanDaySection testLiveSection({bool approaching = false}) => VanDaySection(
  vans: [testLiveVan(approaching: approaching)],
  childDay: approaching ? testPedroDay : null,
);

final testArrivedSection = ArrivedSection(
  childName: 'Pedro',
  schoolName: 'Colégio Horizonte',
  confirmedAt: atWednesday(7, 18),
  schoolDepartureAt: atWednesday(12, 30),
  returnPlaceLabel: 'casa da avó',
  events: [
    DayEvent(
      kind: DayEventKind.droppedAtSchool,
      at: atWednesday(7, 18),
      actorName: 'Marcos',
    ),
    DayEvent(
      kind: DayEventKind.boardedAtHome,
      at: atWednesday(6, 47),
      actorName: 'Marcos',
    ),
    DayEvent(
      kind: DayEventKind.routeStarted,
      at: atWednesday(6, 21),
      actorName: 'Carlos',
    ),
    DayEvent(
      kind: DayEventKind.absence,
      at: atWednesday(6, 2),
      childName: 'Ana',
    ),
  ],
);

final testNoRouteTodaySection = NoRouteTodaySection(
  nextRouteAt: DateTime(2026, 10, 19, 6, 40),
  week: [
    WeekDayPlan(date: DateTime(2026, 10, 19), going: true, returning: true),
    WeekDayPlan(date: DateTime(2026, 10, 20), going: true, returning: true),
    WeekDayPlan(date: DateTime(2026, 10, 21), going: true, returning: false),
    WeekDayPlan(date: DateTime(2026, 10, 22), going: true, returning: true),
    WeekDayPlan(date: DateTime(2026, 10, 23), going: true, returning: true),
  ],
);

const testNegotiatingSection = NegotiatingSection(
  childNames: ['Ana', 'Pedro'],
  openNegotiations: 3,
);

ClientHome testClientHome({
  TodaySection today = const NoLinkedVanSection(),
  NeedsYouSummary needsYou = const NeedsYouSummary(),
  HomeHeadline headline = HomeHeadline.hello,
  Set<HomeShortcut> enabledShortcuts = const {HomeShortcut.proposals},
  DateTime? date,
}) {
  return ClientHome(
    date: date ?? testWednesdayMorning,
    headline: headline,
    today: today,
    needsYou: needsYou,
    enabledShortcuts: enabledShortcuts,
  );
}
