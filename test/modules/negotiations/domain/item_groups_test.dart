import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/core/domain/schedule/clock_time.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/item_groups.dart';
import 'package:vanep_mobile/core/domain/schedule/route_leg.dart';

import '../negotiations_fixtures.dart';

void main() {
  test('students with the same slots share one schedule', () {
    final ana = TestProposalItem(dependentToken: 'dep-ana');
    final pedro = TestProposalItem(dependentToken: 'dep-pedro');
    final lucas = TestProposalItem(
      dependentToken: 'dep-lucas',
      slots: [
        const TestScheduleSlot(
          weekday: Weekday.monday,
          leg: RouteLeg.outbound,
          pickupTime: ClockTime(hour: 6, minute: 40),
        ),
      ],
    );

    expect(groupItemsBySchedule([ana, lucas, pedro]), [
      [ana, pedro],
      [lucas],
    ]);
  });

  test('the order of the slots does not split a schedule', () {
    final slots = roundTripSlotsOn(weekdaysMondayToFriday);
    final ana = TestProposalItem(dependentToken: 'dep-ana', slots: slots);
    final pedro = TestProposalItem(
      dependentToken: 'dep-pedro',
      slots: slots.reversed.toList(),
    );

    expect(groupItemsBySchedule([ana, pedro]), [
      [ana, pedro],
    ]);
  });

  test('students asked on the same days and legs share one group', () {
    final ana = TestClientRequestItem(dependentToken: 'dep-ana');
    final pedro = TestClientRequestItem(dependentToken: 'dep-pedro');
    final lucas = TestClientRequestItem(
      dependentToken: 'dep-lucas',
      days: [
        const TestRequestedDay(weekday: Weekday.monday, needsReturn: false),
      ],
    );

    expect(groupItemsByDays([ana, lucas, pedro]), [
      [ana, pedro],
      [lucas],
    ]);
  });
}
