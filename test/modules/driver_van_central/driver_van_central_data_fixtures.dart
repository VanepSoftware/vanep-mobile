import 'package:vanep_mobile/modules/driver_van_central/data/dtos/driver_attendance_dto.dart';
import 'package:vanep_mobile/modules/driver_van_central/data/dtos/driver_occupancy_dto.dart';
import 'package:vanep_mobile/core/domain/schedule/operation_shift.dart';

const occupancyJson = {
  'shifts': [
    {'shift': 'MORNING', 'passengers': 16},
    {'shift': 'AFTERNOON', 'passengers': 12},
    {'shift': 'NIGHT', 'passengers': 0},
  ],
  'students': 28,
  'studentsWithFamily': 24,
};

const driverMeJson = {
  'token': 'driver-1',
  'photo': null,
  'rating': 4.8,
  'approvalStatus': 'APPROVED',
  'available': true,
  'active': true,
  'basePrice': 320.5,
  'user': {'token': 'user-1', 'name': 'Carlos Motorista'},
};

const activeAssistantJson = {
  'token': 'assistant-1',
  'name': 'Marcos Lima',
  'email': 'marcos@vanep.test',
  'photo': null,
  'status': 'ACTIVE',
  'activatedAt': '2026-10-01T12:00:00Z',
};

const pendingAssistantJson = {
  'token': 'assistant-2',
  'name': 'Rita Souza',
  'email': 'rita@vanep.test',
  'photo': null,
  'status': 'PENDING',
  'activatedAt': null,
};

const occupancyDto = DriverOccupancyDto(
  shifts: [
    ShiftOccupancyDto(shift: OperationShift.morning, passengers: 16),
    ShiftOccupancyDto(shift: OperationShift.afternoon, passengers: 12),
  ],
  students: 28,
  studentsWithFamily: 24,
);

const attendanceDto = DriverAttendanceDto(
  acceptingStudents: true,
  basePriceCents: 32000,
);
