import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/dependents/data/dtos/school_day_dto.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';

void main() {
  test('a school day is read from weekday and schoolShift', () {
    final dto = SchoolDayDto.fromJson(const {
      'weekday': 'MONDAY',
      'schoolShift': 'FULLTIME',
    });

    expect(dto.weekday, Weekday.monday);
    expect(dto.schoolShift, SchoolShift.fullTime);
  });

  test('a school day is written as weekday and schoolShift', () {
    const dto = SchoolDayDto(
      weekday: Weekday.friday,
      schoolShift: SchoolShift.night,
    );

    expect(dto.toJson(), {'weekday': 'FRIDAY', 'schoolShift': 'NIGHT'});
  });

  test('the week is read from the list the back returns', () {
    final week = schoolWeekFromJson(const [
      {'weekday': 'WEDNESDAY', 'schoolShift': 'AFTERNOON'},
      {'weekday': 'MONDAY', 'schoolShift': 'MORNING'},
    ]);

    expect(
      week,
      SchoolWeek.fromDays(const [
        SchoolDay(weekday: Weekday.monday, shift: SchoolShift.morning),
        SchoolDay(weekday: Weekday.wednesday, shift: SchoolShift.afternoon),
      ]),
    );
  });

  test('an unknown day or shift is left out of the week', () {
    final week = schoolWeekFromJson(const [
      {'weekday': 'FUNDAY', 'schoolShift': 'MORNING'},
      {'weekday': 'TUESDAY', 'schoolShift': 'EVENING'},
      {'weekday': 'THURSDAY', 'schoolShift': 'NIGHT'},
    ]);

    expect(week.days, const [
      SchoolDay(weekday: Weekday.thursday, shift: SchoolShift.night),
    ]);
  });

  test('no payload is an empty week', () {
    expect(schoolWeekFromJson(null), const SchoolWeek.empty());
  });

  test('the PUT body lists the days starting on Monday', () {
    final week = const SchoolWeek.empty()
        .turnOn(Weekday.friday)
        .changeShift(Weekday.friday, SchoolShift.fullTime)
        .turnOn(Weekday.monday);

    expect(schoolWeekToJson(week), {
      'days': [
        {'weekday': 'MONDAY', 'schoolShift': 'FULLTIME'},
        {'weekday': 'FRIDAY', 'schoolShift': 'FULLTIME'},
      ],
    });
  });

  test('an empty week is sent as an empty list', () {
    expect(schoolWeekToJson(const SchoolWeek.empty()), {'days': <Object?>[]});
  });
}
