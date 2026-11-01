import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/leg_times.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/route_leg.dart';

import '../negotiations_fixtures.dart';

void main() {
  test('the same time every day is shared', () {
    final times = timesOfLeg(
      roundTripSlotsOn(weekdaysMondayToFriday),
      RouteLeg.outbound,
    );

    expect(times.shared, const ClockTime(hour: 12, minute: 5));
    expect(times.byDay.keys, weekdaysMondayToFriday);
  });

  test('a time that changes on one day is shown per day', () {
    final times = timesOfLeg([
      ...roundTripSlotsOn([Weekday.monday, Weekday.tuesday]),
      const TestScheduleSlot(
        weekday: Weekday.wednesday,
        leg: RouteLeg.homebound,
        pickupTime: ClockTime(hour: 12, minute: 30),
      ),
    ], RouteLeg.homebound);

    expect(times.shared, isNull);
    expect(
      times.byDay[Weekday.wednesday],
      const ClockTime(hour: 12, minute: 30),
    );
    expect(times.byDay.keys, [
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
    ]);
  });

  test('a leg without slots has no time', () {
    final times = timesOfLeg([
      const TestScheduleSlot(weekday: Weekday.monday, leg: RouteLeg.outbound),
    ], RouteLeg.homebound);

    expect(times.isEmpty, isTrue);
    expect(times.shared, isNull);
  });
}
