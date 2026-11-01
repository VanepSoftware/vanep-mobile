import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/entities/proposal.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';

class LegTimes {
  const LegTimes(this.byDay);

  final Map<Weekday, ClockTime> byDay;

  bool get isEmpty => byDay.isEmpty;

  ClockTime? get shared {
    final times = byDay.values.toSet();
    return times.length == 1 ? times.single : null;
  }
}

LegTimes timesOfLeg(Iterable<ScheduleSlot> slots, RouteLeg leg) {
  final timesByDay = {
    for (final slot in slots)
      if (slot.leg == leg) slot.weekday: slot.pickupTime,
  };
  return LegTimes({
    for (final weekday in Weekday.values) weekday: ?timesByDay[weekday],
  });
}
