import 'package:vanep_mobile/modules/assistant/data/dtos/assistant_van_dto.dart';
import 'package:vanep_mobile/modules/assistant/domain/value_objects/assistant_vans_overview.dart';

/// Reads one item of GET /api/assistants/me/vans: a shift the assistant works
/// with the linked driver, on the driver's main vehicle.
AssistantVanSummary assistantVanSummaryFromJson(Map<String, Object?> json) {
  return AssistantVanSummary(
    van: AssistantVanDto.fromJson(json),
    departureMinutes: minutesOfDay(json['departureTime']),
    studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
    hasRouteToday: json['hasRouteToday'] == true,
  );
}

/// Turns an ISO local time such as "06:20" or "06:20:00" into minutes after
/// midnight, or null when it is missing or malformed.
int? minutesOfDay(Object? value) {
  if (value is! String) return null;
  final parts = value.split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return hour * 60 + minute;
}
