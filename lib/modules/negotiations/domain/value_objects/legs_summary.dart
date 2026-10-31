import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

enum LegsSummary { roundTrip, outboundOnly, homeboundOnly, mixed }

LegsSummary? summarizeLegs(Iterable<RequestedDay> days) {
  final summaries = {for (final day in days) ?summarizeDay(day)};
  if (summaries.isEmpty) return null;
  return summaries.length == 1 ? summaries.single : LegsSummary.mixed;
}

LegsSummary? summarizeDay(RequestedDay day) {
  return switch ((day.needsOutbound, day.needsReturn)) {
    (true, true) => LegsSummary.roundTrip,
    (true, false) => LegsSummary.outboundOnly,
    (false, true) => LegsSummary.homeboundOnly,
    (false, false) => null,
  };
}
