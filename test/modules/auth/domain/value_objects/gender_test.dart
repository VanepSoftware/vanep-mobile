import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/gender.dart';

void main() {
  group('Gender.fromApi', () {
    test('maps known API values', () {
      expect(Gender.fromApi('MALE'), Gender.male);
      expect(Gender.fromApi('FEMALE'), Gender.female);
      expect(Gender.fromApi('OTHER'), Gender.other);
    });

    test('is case-insensitive for known values', () {
      expect(Gender.fromApi('male'), Gender.male);
      expect(Gender.fromApi('Female'), Gender.female);
    });

    test('returns null for null, blank, and unknown values', () {
      expect(Gender.fromApi(null), isNull);
      expect(Gender.fromApi(''), isNull);
      expect(Gender.fromApi('   '), isNull);
      expect(Gender.fromApi('UNKNOWN'), isNull);
      expect(Gender.fromApi(42), isNull);
    });
  });

  group('Gender.toApi', () {
    test('maps enum values to API strings', () {
      expect(Gender.toApi(Gender.male), 'MALE');
      expect(Gender.toApi(Gender.female), 'FEMALE');
      expect(Gender.toApi(Gender.other), 'OTHER');
      expect(Gender.toApi(null), isNull);
    });
  });
}
