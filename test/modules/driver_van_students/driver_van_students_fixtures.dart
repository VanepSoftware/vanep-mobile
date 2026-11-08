import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_city.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/brazilian_state.dart';
import 'package:vanep_mobile/modules/ibge_locations/domain/entities/ibge_locations_page.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/dtos/driver_occupancy_dto.dart';
import 'package:vanep_mobile/core/data/schedule_slot_dto.dart';
import 'package:vanep_mobile/core/domain/postal_address_draft.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/driver_van_students/data/dtos/driver_student_dto.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/family_status.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/student_source.dart';
import 'package:vanep_mobile/modules/driver_van_students/domain/value_objects/unlinked_passenger_draft.dart';
import 'package:vanep_mobile/modules/schools/domain/entities/school.dart';

const morningPickup = ClockTime(hour: 6, minute: 40);

const noonPickup = ClockTime(hour: 12, minute: 10);

const mondayMorningOutbound = ScheduleSlotDto(
  weekday: Weekday.monday,
  leg: RouteLeg.outbound,
  shift: OperationShift.morning,
  pickupTime: morningPickup,
);

const mondayAfternoonReturn = ScheduleSlotDto(
  weekday: Weekday.monday,
  leg: RouteLeg.homebound,
  shift: OperationShift.afternoon,
  pickupTime: noonPickup,
);

const rafaelMatch = FamilyMatchDto(
  token: 'match-1',
  dependentToken: 'dep-rafael',
  dependentName: 'Rafael Costa',
  dependentAge: 9,
  clientName: 'Maria Costa',
);

DriverStudentDto studentFixture({
  String token = 'student-1',
  String name = 'Laura Mendes',
  StudentSource source = StudentSource.unlinkedPassenger,
  FamilyStatus familyStatus = FamilyStatus.notInvited,
  SchoolShift? schoolShift = SchoolShift.morning,
  List<ScheduleSlotDto> slots = const [
    mondayMorningOutbound,
    mondayAfternoonReturn,
  ],
  DateTime? invitedAt,
  FamilyMatchDto? familyMatch,
  String? dependentToken,
}) {
  return DriverStudentDto(
    token: token,
    source: source,
    name: name,
    schoolName: 'Col. Horizonte',
    schoolShift: schoolShift,
    slots: slots,
    familyStatus: familyStatus,
    invitedAt: invitedAt,
    familyMatch: familyMatch,
    dependentToken: dependentToken,
  );
}

final contractedBruno = studentFixture(
  token: 'item-bruno',
  name: 'Bruno Costa',
  source: StudentSource.contractItem,
  familyStatus: FamilyStatus.withFamily,
  schoolShift: null,
  dependentToken: 'dep-bruno',
);

final uninvitedLaura = studentFixture();

final invitedSofia = studentFixture(
  token: 'student-sofia',
  name: 'Sofia Lima',
  familyStatus: FamilyStatus.invited,
  invitedAt: DateTime.utc(2026, 11, 6, 15),
);

final joinedRafael = studentFixture(
  token: 'student-rafael',
  name: 'Rafael',
  familyStatus: FamilyStatus.familyJoined,
  invitedAt: DateTime.utc(2026, 11, 1),
  familyMatch: rafaelMatch,
);

final afternoonMiguel = studentFixture(
  token: 'student-miguel',
  name: 'Miguel Rocha',
  schoolShift: SchoolShift.afternoon,
  slots: const [mondayAfternoonReturn],
);

final vanStudents = [
  contractedBruno,
  uninvitedLaura,
  invitedSofia,
  joinedRafael,
  afternoonMiguel,
];

const colegioHorizonte = School(token: 'school-1', name: 'Col. Horizonte');

final resolvedAddress = PostalAddressDraft.fromParts(
  zipCode: '01001000',
  cityToken: 'city-sp',
  cityName: 'São Paulo',
  uf: 'SP',
  street: 'Rua das Flores',
  number: '100',
);

UnlinkedPassengerDraft completeDraft() {
  return UnlinkedPassengerDraft(
    name: ' Laura Mendes ',
    school: colegioHorizonte,
    schoolShift: SchoolShift.morning,
    address: resolvedAddress,
    legTimes: const {
      (Weekday.monday, RouteLeg.outbound): morningPickup,
      (Weekday.monday, RouteLeg.homebound): noonPickup,
    },
    vehicleToken: 'van-1',
  );
}

const studentJson = {
  'token': 'student-rafael',
  'source': 'UNLINKED_PASSENGER',
  'name': 'Rafael',
  'schoolToken': 'school-1',
  'schoolName': 'Col. Horizonte',
  'schoolShift': 'MORNING',
  'slots': [
    {
      'weekday': 'MONDAY',
      'leg': 'OUTBOUND',
      'shift': 'MORNING',
      'pickupTime': '06:40:00',
    },
  ],
  'vehicleToken': 'van-1',
  'dependentToken': null,
  'familyStatus': 'FAMILY_JOINED',
  'invitedAt': '2026-11-01T12:00:00Z',
  'familyMatch': {
    'token': 'match-1',
    'dependentToken': 'dep-rafael',
    'dependentName': 'Rafael Costa',
    'dependentAge': 9,
    'clientName': 'Maria Costa',
  },
};

const contractStudentJson = {
  'token': 'item-bruno',
  'source': 'CONTRACT_ITEM',
  'name': 'Bruno Costa',
  'schoolToken': 'school-1',
  'schoolName': 'Col. Horizonte',
  'schoolShift': null,
  'slots': [],
  'vehicleToken': null,
  'dependentToken': 'dep-bruno',
  'familyStatus': 'WITH_FAMILY',
  'invitedAt': null,
  'familyMatch': null,
};

const inviteJson = {
  'code': 'ABCD2345EFGH',
  'inviteUrl': 'https://vanep.com.br/convite/ABCD2345EFGH',
  'sentAt': '2026-11-08T18:00:00Z',
};

final familyInvite = FamilyInviteDto(
  code: 'ABCD2345EFGH',
  inviteUrl: 'https://vanep.com.br/convite/ABCD2345EFGH',
  sentAt: DateTime.utc(2026, 11, 8, 18),
);

const studentsOccupancy = DriverOccupancyDto(
  shifts: [],
  students: 28,
  studentsWithFamily: 24,
);

const schoolSearchSuggestion = PlaceSuggestion(
  placeId: 'place-1',
  primaryText: 'Col. Horizonte',
  secondaryText: 'São Paulo',
);
const addressState = BrazilianState(
  token: 'state-sp',
  name: 'São Paulo',
  uf: 'SP',
  active: true,
);
const addressCity = BrazilianCity(
  token: 'city-sp',
  name: 'São Paulo',
  stateToken: 'state-sp',
  stateUf: 'SP',
  active: true,
);

const addressStatesPage = IbgeLocationsPage(
  items: [addressState],
  totalElements: 1,
  totalPages: 1,
  number: 0,
  size: 30,
);
const addressCitiesPage = IbgeLocationsPage(
  items: [addressCity],
  totalElements: 1,
  totalPages: 1,
  number: 0,
  size: 50,
);
const emptyCitiesPage = IbgeLocationsPage<BrazilianCity>(
  items: [],
  totalElements: 0,
  totalPages: 0,
  number: 0,
  size: 50,
);
