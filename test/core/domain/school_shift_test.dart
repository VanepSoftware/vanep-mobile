import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/domain/school_shift.dart';

void main() {
  group('SchoolShift.fromApi', () {
    test('maps known API values', () {
      expect(SchoolShift.fromApi('MORNING'), SchoolShift.morning);
      expect(SchoolShift.fromApi('AFTERNOON'), SchoolShift.afternoon);
      expect(SchoolShift.fromApi('NIGHT'), SchoolShift.night);
      expect(SchoolShift.fromApi('FULLTIME'), SchoolShift.fullTime);
    });

    test('is case-insensitive for known values', () {
      expect(SchoolShift.fromApi('morning'), SchoolShift.morning);
      expect(SchoolShift.fromApi('FullTime'), SchoolShift.fullTime);
    });

    test('returns null for null, blank, and unknown values', () {
      expect(SchoolShift.fromApi(null), isNull);
      expect(SchoolShift.fromApi(''), isNull);
      expect(SchoolShift.fromApi('   '), isNull);
      expect(SchoolShift.fromApi('EVENING'), isNull);
      expect(SchoolShift.fromApi(42), isNull);
    });
  });

  group('SchoolShift.toApi', () {
    test('maps every value to its API string', () {
      expect(SchoolShift.toApi(SchoolShift.morning), 'MORNING');
      expect(SchoolShift.toApi(SchoolShift.afternoon), 'AFTERNOON');
      expect(SchoolShift.toApi(SchoolShift.night), 'NIGHT');
      expect(SchoolShift.toApi(SchoolShift.fullTime), 'FULLTIME');
    });

    test('round trips every value', () {
      for (final shift in SchoolShift.values) {
        expect(SchoolShift.fromApi(SchoolShift.toApi(shift)), shift);
      }
    });
  });
}
