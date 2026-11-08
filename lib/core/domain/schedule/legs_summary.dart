import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';
import 'package:vanep_mobile/core/domain/schedule/schedule_slot.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';

enum LegsSummary { roundTrip, outboundOnly, homeboundOnly, mixed }

LegsSummary? summarizeSlots(Iterable<ScheduleSlot> slots) {
  final legsByDay = <Weekday, Set<RouteLeg>>{};
  for (final slot in slots) {
    legsByDay.putIfAbsent(slot.weekday, () => {}).add(slot.leg);
  }
  return combineDaySummaries([
    for (final legs in legsByDay.values)
      summarizeLegsOfDay(
        needsOutbound: legs.contains(RouteLeg.outbound),
        needsReturn: legs.contains(RouteLeg.homebound),
      ),
  ]);
}

LegsSummary? summarizeLegsOfDay({
  required bool needsOutbound,
  required bool needsReturn,
}) {
  return switch ((needsOutbound, needsReturn)) {
    (true, true) => LegsSummary.roundTrip,
    (true, false) => LegsSummary.outboundOnly,
    (false, true) => LegsSummary.homeboundOnly,
    (false, false) => null,
  };
}

LegsSummary? combineDaySummaries(Iterable<LegsSummary?> daySummaries) {
  final summaries = {for (final summary in daySummaries) ?summary};
  if (summaries.isEmpty) return null;
  return summaries.length == 1 ? summaries.single : LegsSummary.mixed;
}
