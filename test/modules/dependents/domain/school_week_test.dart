import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/school_week.dart';
import 'package:vanep_mobile/modules/dependents/domain/value_objects/weekday.dart';

void main() {
  group('Weekday', () {
    test('starts on Monday', () {
      expect(Weekday.values.first, Weekday.monday);
      expect(Weekday.values.last, Weekday.sunday);
    });

    test('maps API names both ways', () {
      for (final day in Weekday.values) {
        expect(Weekday.fromApi(Weekday.toApi(day)), day);
      }
      expect(Weekday.toApi(Weekday.thursday), 'THURSDAY');
      expect(Weekday.fromApi('friday'), Weekday.friday);
      expect(Weekday.fromApi('FUNDAY'), isNull);
      expect(Weekday.fromApi(null), isNull);
    });
  });

  group('SchoolWeek.turnOn', () {
    test('uses MORNING when no day is on', () {
      final week = const SchoolWeek.empty().turnOn(Weekday.wednesday);

      expect(week.shiftOf(Weekday.wednesday), SchoolShift.morning);
    });

    test('copies the nearest earlier day that is on', () {
      final week = const SchoolWeek.empty()
          .turnOn(Weekday.monday)
          .changeShift(Weekday.monday, SchoolShift.afternoon)
          .turnOn(Weekday.wednesday)
          .changeShift(Weekday.wednesday, SchoolShift.fullTime)
          .turnOn(Weekday.thursday);

      expect(week.shiftOf(Weekday.thursday), SchoolShift.fullTime);
    });

    test('falls back to the nearest later day when none is earlier', () {
      final week = const SchoolWeek.empty()
          .turnOn(Weekday.friday)
          .changeShift(Weekday.friday, SchoolShift.night)
          .turnOn(Weekday.thursday)
          .changeShift(Weekday.thursday, SchoolShift.afternoon)
          .turnOn(Weekday.tuesday);

      expect(week.shiftOf(Weekday.tuesday), SchoolShift.afternoon);
    });

    test('keeps the shift of a day that is already on', () {
      final week = const SchoolWeek.empty()
          .turnOn(Weekday.monday)
          .changeShift(Weekday.monday, SchoolShift.night)
          .turnOn(Weekday.monday);

      expect(week.shiftOf(Weekday.monday), SchoolShift.night);
    });
  });

  group('SchoolWeek edits', () {
    test('turnOff drops the day and its shift', () {
      final week = const SchoolWeek.empty()
          .turnOn(Weekday.monday)
          .turnOff(Weekday.monday);

      expect(week.isOn(Weekday.monday), isFalse);
      expect(week.shiftOf(Weekday.monday), isNull);
      expect(week.isEmpty, isTrue);
    });

    test('changeShift changes only that day', () {
      final week = const SchoolWeek.empty()
          .turnOn(Weekday.monday)
          .turnOn(Weekday.tuesday)
          .changeShift(Weekday.tuesday, SchoolShift.fullTime);

      expect(week.shiftOf(Weekday.monday), SchoolShift.morning);
      expect(week.shiftOf(Weekday.tuesday), SchoolShift.fullTime);
    });

    test('changeShift ignores a day that is off', () {
      final week = const SchoolWeek.empty().changeShift(
        Weekday.saturday,
        SchoolShift.morning,
      );

      expect(week.isEmpty, isTrue);
    });

    test('counts the days that are on', () {
      final week = const SchoolWeek.empty()
          .turnOn(Weekday.monday)
          .turnOn(Weekday.friday);

      expect(week.dayCount, 2);
    });
  });

  group('SchoolWeek.days', () {
    test('lists the days that are on, Monday first', () {
      final week = SchoolWeek.fromDays(const [
        SchoolDay(weekday: Weekday.friday, shift: SchoolShift.morning),
        SchoolDay(weekday: Weekday.monday, shift: SchoolShift.fullTime),
      ]);

      expect(week.days, const [
        SchoolDay(weekday: Weekday.monday, shift: SchoolShift.fullTime),
        SchoolDay(weekday: Weekday.friday, shift: SchoolShift.morning),
      ]);
    });
  });

  group('SchoolWeek equality', () {
    test('two weeks with the same days are equal', () {
      final first = const SchoolWeek.empty()
          .turnOn(Weekday.monday)
          .turnOn(Weekday.tuesday);
      final second = const SchoolWeek.empty()
          .turnOn(Weekday.tuesday)
          .changeShift(Weekday.tuesday, SchoolShift.morning)
          .turnOn(Weekday.monday);

      expect(first, second);
    });

    test('a different shift makes them different', () {
      final first = const SchoolWeek.empty().turnOn(Weekday.monday);
      final second = first.changeShift(Weekday.monday, SchoolShift.night);

      expect(first, isNot(second));
    });
  });
}
