import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_invite.dart';
import 'package:vanep_mobile/modules/assistant/domain/usecases/assistant_route_progress.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_home_status.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_route_snapshot.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_van_link.dart';

const afternoonStartHour = 12;
const nightStartHour = 18;

String currentShiftAt(DateTime now) {
  if (now.hour < afternoonStartHour) return 'MORNING';
  if (now.hour < nightStartHour) return 'AFTERNOON';
  return 'NIGHT';
}

AssistantVanLink? selectAssistantVanLink(
  List<AssistantVanLink> links,
  String? selectedVanToken, {
  DateTime? now,
}) {
  final selected = links
      .where((link) => link.van.token == selectedVanToken)
      .firstOrNull;
  if (selected != null) return selected;
  final active = links.where((link) => link.isActive).toList();
  final shift = now == null ? null : currentShiftAt(now);
  final ofCurrentShift = active
      .where((link) => link.van.shift == shift || link.van.shift == 'FULLTIME')
      .firstOrNull;
  return ofCurrentShift ?? active.firstOrNull ?? links.firstOrNull;
}

AssistantHomeStatus deriveAssistantHomeStatus({
  required List<AssistantVanLink> links,
  AssistantInvite? pendingInvite,
  String? selectedVanToken,
  AssistantRouteSnapshot? route,
}) {
  final hasActiveLink = links.any((link) => link.isActive);
  if (!hasActiveLink && pendingInvite != null) {
    return AssistantHomeInviteReceived(pendingInvite);
  }

  final link = selectAssistantVanLink(links, selectedVanToken);
  if (link == null) return const AssistantHomeNoVan();

  if (!link.isActive) {
    if (link.status == AssistantLinkStatus.pending) {
      return const AssistantHomeNoVan();
    }
    return AssistantHomeAccessPaused(
      link: link,
      otherActiveLinks: links.where((other) => other.isActive).toList(),
    );
  }

  final stop = route?.currentStop;
  if (route == null || stop == null) {
    return AssistantHomeBeforeRoute(link: link, route: route);
  }
  if (stop.kind.isBoarding) {
    return AssistantHomeOnRouteBoarding(link: link, route: route, stop: stop);
  }
  return AssistantHomeOnRouteDropOff(link: link, route: route, stop: stop);
}
