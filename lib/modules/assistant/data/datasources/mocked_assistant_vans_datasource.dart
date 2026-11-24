import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

abstract class AssistantVansDataSource {
  Future<AssistantVansOverview> findVansOverview();
}

// TODO(VAN-68): mocked vans and former links from the prototype. The real
// vans come from GET /api/assistants/me/vans; departure time, student count,
// route of the day and former links need new endpoints. The pending invite
// already comes from the API (AssistantVansRepositoryImpl). Delete this class
// and its registration in assistant_container.dart when they are wired.
class MockedAssistantVansDataSource implements AssistantVansDataSource {
  const MockedAssistantVansDataSource();

  @override
  Future<AssistantVansOverview> findVansOverview() async {
    return AssistantVansOverview(
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
