import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/entities/driver_occupancy.dart';
import 'package:vanep_mobile/modules/driver_van_central/domain/value_objects/operation_shift.dart';

import '../driver_van_central_fixtures.dart';

void main() {
  group('ShiftOccupancySeats', () {
    test('counts the seats left in a van', () {
      const afternoon = TestShiftOccupancy(OperationShift.afternoon, 12);

      expect(afternoon.vacanciesIn(16), 4);
      expect(afternoon.isFullIn(16), isFalse);
      expect(afternoon.fillRatioIn(16), 0.75);
    });

    test('a shift at capacity is full and has no seats left', () {
      const morning = TestShiftOccupancy(OperationShift.morning, 16);

      expect(morning.vacanciesIn(16), 0);
      expect(morning.isFullIn(16), isTrue);
      expect(morning.fillRatioIn(16), 1);
    });

    test('more passengers than seats never go below zero or past full', () {
      const morning = TestShiftOccupancy(OperationShift.morning, 20);

      expect(morning.vacanciesIn(16), 0);
      expect(morning.isFullIn(16), isTrue);
      expect(morning.fillRatioIn(16), 1);
    });

    test('a van without seats is full and empty at the same time', () {
      const night = TestShiftOccupancy(OperationShift.night, 0);

      expect(night.vacanciesIn(0), 0);
      expect(night.isFullIn(0), isTrue);
      expect(night.fillRatioIn(0), 0);
    });
  });

  group('DriverOccupancyShifts', () {
    test('finds the passengers of a shift, or none when it is missing', () {
      expect(testOccupancy.passengersIn(OperationShift.morning), 16);
      expect(testOccupancy.passengersIn(OperationShift.afternoon), 12);
      expect(
        const TestDriverOccupancy(
          shifts: [],
          students: 0,
          studentsWithFamily: 0,
        ).passengersIn(OperationShift.night),
        0,
      );
    });

    test('shows morning and afternoon always, and night only when used', () {
      expect(testOccupancy.visibleShifts.map((shift) => shift.shift), [
        OperationShift.morning,
        OperationShift.afternoon,
      ]);
      expect(testNightOccupancy.visibleShifts.map((shift) => shift.shift), [
        OperationShift.morning,
        OperationShift.afternoon,
        OperationShift.night,
      ]);
    });

    test('lists the shifts that still have seats in a van', () {
      expect(testOccupancy.shiftsWithVacanciesIn(16), [
        OperationShift.afternoon,
      ]);
      expect(testOccupancy.shiftsWithVacanciesIn(12), isEmpty);
      expect(testOccupancy.shiftsWithVacanciesIn(30), [
        OperationShift.morning,
        OperationShift.afternoon,
      ]);
    });
  });
}
