import 'package:vanep_mobile/modules/assistant/data/datasources/mocked_assistant_route_datasource.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_detail.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/checklist_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_kind.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/route_stop_status.dart';

abstract class AssistantVanDetailDataSource {
  Future<AssistantVanDetail> findVanDetail(String vanToken);

  Future<void> leaveVan(String vanToken);
}

// TODO(VAN-69): mocked van detail of the prototype (frame aux-vans-2-detalhe).
// Real data needs GET /api/assistants/me/vans/{token} (backend B7) and the
// driver phone (B6). Leaving maps to the existing POST
// /api/assistants/me/revoke, which must take the van token once the link is
// N:N (B1). Delete this class and its registration in assistant_container.dart
// when they are wired.
class MockedAssistantVanDetailDataSource
    implements AssistantVanDetailDataSource {
  const MockedAssistantVanDetailDataSource({this.clock = DateTime.now});

  final DateTime Function() clock;

  @override
  Future<AssistantVanDetail> findVanDetail(String vanToken) async {
    final now = clock();
    final today = DateTime(now.year, now.month, now.day);
    final isRita = vanToken == mockedVanRitaToken;
    return AssistantVanDetail(
      van: isRita ? mockedVanRita : mockedVanCarlos,
      linkStatus: AssistantLinkStatus.active,
      studentsCount: isRita ? 9 : 16,
      departureAt: today.add(
        isRita
            ? const Duration(hours: 11, minutes: 40)
            : const Duration(hours: 6, minutes: 20),
      ),
      stops: [
        for (final (index, stop) in mockedHomeStops.indexed)
          AssistantRouteStop(
            token: 'mock-detail-stop-${index + 1}',
            kind: RouteStopKind.pickupHome,
            sequence: index + 1,
            status: RouteStopStatus.pending,
            label: stop.label,
            plannedArrivalAt: today.add(
              Duration(hours: 6, minutes: stop.minutesAfterSix),
            ),
            passengers: [
              for (final name in stop.passengers)
                AssistantRoutePassenger(
                  token: mockedPassengerToken(name),
                  name: name,
                  schoolName: mockedSchoolOf(name),
                  checklistStatus: ChecklistStatus.pending,
                ),
            ],
          ),
      ],
    );
  }

  @override
  Future<void> leaveVan(String vanToken) async {}
}
