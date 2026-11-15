import 'package:vanep_mobile/modules/driver_service_areas/domain/entities/service_area.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_attendance.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/van_assistant.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/value_objects/operation_shift.dart';
import 'package:vanep_mobile/modules/driver_vans/data/dtos/driver_van_dto.dart';

class TestShiftOccupancy implements ShiftOccupancy {
  const TestShiftOccupancy(this.shift, this.passengers);

  @override
  final OperationShift shift;

  @override
  final int passengers;
}

class TestDriverOccupancy implements DriverOccupancy {
  const TestDriverOccupancy({
    required this.shifts,
    required this.students,
    required this.studentsWithFamily,
  });

  @override
  final List<ShiftOccupancy> shifts;

  @override
  final int students;

  @override
  final int studentsWithFamily;
}

class TestDriverAttendance implements DriverAttendance {
  const TestDriverAttendance({
    required this.acceptingStudents,
    this.basePriceCents,
  });

  @override
  final bool acceptingStudents;

  @override
  final int? basePriceCents;
}

class TestVanAssistant implements VanAssistant {
  const TestVanAssistant({
    required this.token,
    required this.name,
    required this.status,
  });

  @override
  final String token;

  @override
  final String name;

  @override
  final VanAssistantStatus status;
}

const testOccupancy = TestDriverOccupancy(
  shifts: [
    TestShiftOccupancy(OperationShift.morning, 16),
    TestShiftOccupancy(OperationShift.afternoon, 12),
    TestShiftOccupancy(OperationShift.night, 0),
  ],
  students: 28,
  studentsWithFamily: 24,
);

const testNightOccupancy = TestDriverOccupancy(
  shifts: [
    TestShiftOccupancy(OperationShift.morning, 3),
    TestShiftOccupancy(OperationShift.afternoon, 0),
    TestShiftOccupancy(OperationShift.night, 5),
  ],
  students: 8,
  studentsWithFamily: 8,
);

const testAttendance = TestDriverAttendance(
  acceptingStudents: true,
  basePriceCents: 32000,
);

const testAssistants = [
  TestVanAssistant(
    token: 'assistant-1',
    name: 'Marcos Lima',
    status: VanAssistantStatus.active,
  ),
  TestVanAssistant(
    token: 'assistant-2',
    name: 'Rita Souza',
    status: VanAssistantStatus.pending,
  ),
];

const firstVan = DriverVanDto(
  token: 'van-1',
  plate: 'SDF4E21',
  brand: 'Mercedes-Benz',
  model: 'Sprinter 415',
  manufactureYear: 2021,
  color: 'Branca',
  capacity: 16,
);

const secondVan = DriverVanDto(
  token: 'van-2',
  plate: 'RTA3B45',
  brand: 'Renault',
  model: 'Master',
  manufactureYear: 2019,
  color: 'Prata',
  capacity: 12,
  active: false,
);

const testServiceAreas = [
  ServiceArea(
    token: 'area-1',
    name: 'Taguatinga',
    cityName: 'Brasília',
    stateUf: 'DF',
    coversWholeCity: false,
  ),
  ServiceArea(
    token: 'area-2',
    name: 'Águas Claras',
    cityName: 'Brasília',
    stateUf: 'DF',
    coversWholeCity: false,
  ),
];
