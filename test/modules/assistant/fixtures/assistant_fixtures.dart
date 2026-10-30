import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_students_overview.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

final testAssistantInvite = AssistantInvite(
  token: 'invite-tok-12345678901234567890',
  driverName: 'João Motorista',
  driverPhoto: 'https://example.com/driver.png',
  driverRating: 4.9,
  vehicleDescription: 'Mercedes Sprinter 2024 (ABC-1234)',
  expiresAt: DateTime.utc(2026, 9, 20, 12, 0),
  status: 'PENDING',
);

const testAssistantVanPrimary = AssistantVan(
  token: 'van-token-primary',
  driverToken: 'driver-token-1',
  driverName: 'João Motorista',
  plate: 'ABC-1234',
  model: 'Mercedes Sprinter 2024',
  shift: 'MORNING',
);

const testAssistantVanSecondary = AssistantVan(
  token: 'van-token-secondary',
  driverToken: 'driver-token-2',
  driverName: 'Maria Motorista',
  plate: 'XYZ-9876',
  model: 'Renault Master 2023',
  shift: 'AFTERNOON',
);

AssistantInvite buildAssistantPendingInvite({required Duration expiresIn}) {
  return AssistantInvite(
    token: 'invite-tok-vans-12345678901234567890',
    driverName: 'João Pedro Lima',
    vehicleDescription: 'Master 2019 · tarde',
    expiresAt: DateTime.now().add(expiresIn),
    status: 'PENDING',
  );
}

const testAssistantVanSummaryWithRoute = AssistantVanSummary(
  van: AssistantVan(
    token: 'van-token-carlos',
    driverToken: 'driver-token-carlos',
    driverName: 'Carlos Mendes',
    plate: 'SDF4E21',
    model: 'Sprinter',
    shift: 'MORNING',
  ),
  departureMinutes: 380,
  studentCount: 16,
  hasRouteToday: true,
);

const testAssistantVanSummaryWithoutRoute = AssistantVanSummary(
  van: AssistantVan(
    token: 'van-token-rita',
    driverToken: 'driver-token-rita',
    driverName: 'Rita Souza',
    plate: 'PBX7C19',
    model: 'Ducato',
    shift: 'AFTERNOON',
  ),
  departureMinutes: 700,
  studentCount: 1,
  hasRouteToday: false,
);

final testAssistantVansOverview = AssistantVansOverview(
  pendingInvite: buildAssistantPendingInvite(
    expiresIn: const Duration(days: 3, hours: 1),
  ),
  activeVans: const [
    testAssistantVanSummaryWithRoute,
    testAssistantVanSummaryWithoutRoute,
  ],
  formerVanCount: 1,
);

const testAssistantStudentAna = AssistantStudentSummary(
  token: 'student-ana',
  name: 'Ana Oliveira',
  stopNumber: 3,
  placeName: 'Col. Horizonte',
  isAbsentToday: true,
);

const testAssistantStudentLais = AssistantStudentSummary(
  token: 'student-lais',
  name: 'Laís Teixeira',
  stopNumber: 7,
  placeName: 'Escola Classe 10',
);

const testAssistantStudentBeatriz = AssistantStudentSummary(
  token: 'student-beatriz',
  name: 'Beatriz Santos',
  stopNumber: 5,
  placeName: 'Jd. das Flores',
);

const testAssistantStudentsOverview = AssistantStudentsOverview(
  rosters: [
    AssistantStudentsRoster(
      van: testAssistantVanPrimary,
      students: [
        testAssistantStudentLais,
        testAssistantStudentAna,
        testAssistantStudentBeatriz,
      ],
    ),
    AssistantStudentsRoster(
      van: testAssistantVanSecondary,
      students: [testAssistantStudentBeatriz],
    ),
  ],
);
