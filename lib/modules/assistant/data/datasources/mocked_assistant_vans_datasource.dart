import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

abstract class AssistantVansDataSource {
  Future<AssistantVansOverview> findVansOverview();
}

// TODO(VAN-68): mocked vans, pending invite and former links from the
// prototype. The real vans come from GET /api/assistants/me/vans; departure
// time, student count, route of the day, invite preview and former links need
// new endpoints. Delete this class and its registration in
// assistant_container.dart when they are wired.
class MockedAssistantVansDataSource implements AssistantVansDataSource {
  const MockedAssistantVansDataSource({this.clock = DateTime.now});

  final DateTime Function() clock;

  @override
  Future<AssistantVansOverview> findVansOverview() async {
    return AssistantVansOverview(
      pendingInvite: AssistantInvite(
        token: 'mock-invite-joao-pedro',
        driverName: 'João Pedro Lima',
        vehicleDescription: 'Master 2019 · tarde',
        expiresAt: clock().add(const Duration(days: 3, hours: 1)),
        status: 'PENDING',
      ),
      activeVans: const [
        AssistantVanSummary(
          van: AssistantVan(
            token: 'mock-van-carlos',
            driverToken: 'mock-driver-carlos',
            driverName: 'Carlos Mendes',
            plate: 'SDF4E21',
            model: 'Sprinter',
            shift: 'MORNING',
          ),
          departureMinutes: 380,
          studentCount: 16,
          hasRouteToday: true,
        ),
        AssistantVanSummary(
          van: AssistantVan(
            token: 'mock-van-rita',
            driverToken: 'mock-driver-rita',
            driverName: 'Rita Souza',
            plate: 'PBX7C19',
            model: 'Ducato',
            shift: 'AFTERNOON',
          ),
          departureMinutes: 700,
          studentCount: 9,
          hasRouteToday: false,
        ),
      ],
      formerVanCount: 1,
    );
  }
}
