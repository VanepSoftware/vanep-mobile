import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/core/domain/weekday.dart';
import 'package:vanep_mobile/modules/negotiations/domain/value_objects/request_schools.dart';

import '../negotiations_fixtures.dart';

TestDriverRequestItem itemAt(
  String token,
  String? school, {
  List<SchoolShift?> shifts = const [SchoolShift.afternoon],
  List<Weekday> weekdays = const [Weekday.monday],
}) {
  return TestDriverRequestItem(
    dependentToken: token,
    schoolName: school,
    days: [
      for (final (index, weekday) in weekdays.indexed)
        TestRequestedDay(
          weekday: weekday,
          schoolShift: shifts[index % shifts.length],
        ),
    ],
  );
}

void main() {
  test('siblings at the same school share one group and its shift', () {
    final groups = groupItemsBySchool([
      itemAt('ana', 'Colégio Delta'),
      itemAt('pedro', 'Colégio Delta'),
    ]);

    expect(groups, hasLength(1));
    expect(groups.single.schoolName, 'Colégio Delta');
    expect(groups.single.items.map((item) => item.dependentToken), [
      'ana',
      'pedro',
    ]);
    expect(groups.single.shift, SchoolShift.afternoon);
    expect(groups.single.hasVaryingShift, isFalse);
  });

  test('different schools are separate groups in the order of the items', () {
    final groups = groupItemsBySchool([
      itemAt('ana', 'Colégio Delta'),
      itemAt('pedro', 'Escola Alfa', shifts: const [SchoolShift.morning]),
      itemAt('lucas', 'Colégio Delta'),
    ]);

    expect(groups.map((group) => group.schoolName), [
      'Colégio Delta',
      'Escola Alfa',
    ]);
    expect(groups.first.items, hasLength(2));
    expect(groups.last.shift, SchoolShift.morning);
  });

  test('a shift that changes between the days varies', () {
    final group = groupItemsBySchool([
      itemAt(
        'ana',
        'Colégio Delta',
        shifts: const [SchoolShift.morning, SchoolShift.afternoon],
        weekdays: const [Weekday.monday, Weekday.tuesday],
      ),
    ]).single;

    expect(group.shift, isNull);
    expect(group.hasVaryingShift, isTrue);
  });

  test('days without a known shift neither set nor vary it', () {
    final group = groupItemsBySchool([
      itemAt('ana', null, shifts: const [null]),
    ]).single;

    expect(group.schoolName, isNull);
    expect(group.shift, isNull);
    expect(group.hasVaryingShift, isFalse);
  });

  test('the requested weekdays are the days with a leg, in week order', () {
    final items = [
      TestDriverRequestItem(
        days: const [
          TestRequestedDay(weekday: Weekday.friday),
          TestRequestedDay(
            weekday: Weekday.tuesday,
            needsOutbound: false,
            needsReturn: false,
          ),
        ],
      ),
      TestDriverRequestItem(
        days: const [TestRequestedDay(weekday: Weekday.monday)],
      ),
    ];

    expect(requestedWeekdays(items), [Weekday.monday, Weekday.friday]);
  });
}
