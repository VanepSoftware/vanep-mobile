import 'package:vanep_mobile/core/domain/schedule/legs_summary.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/service_request.dart';

export 'package:vanep_mobile/core/domain/schedule/legs_summary.dart';

LegsSummary? summarizeLegs(Iterable<RequestedDay> days) {
  return combineDaySummaries([
    for (final day in days)
      summarizeLegsOfDay(
        needsOutbound: day.needsOutbound,
        needsReturn: day.needsReturn,
      ),
  ]);
}
