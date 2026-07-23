import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';

void main() {
  group('UserType.fromApi', () {
    test('maps known API values', () {
      expect(UserType.fromApi('CLIENT'), UserType.client);
      expect(UserType.fromApi('DRIVER'), UserType.driver);
      expect(UserType.fromApi('ASSISTANT'), UserType.assistant);
      expect(UserType.fromApi('ADMIN'), UserType.admin);
    });

    test('is case-insensitive for known values', () {
      expect(UserType.fromApi('client'), UserType.client);
      expect(UserType.fromApi('Driver'), UserType.driver);
    });

    test('returns null for null, blank, and unknown values', () {
      expect(UserType.fromApi(null), isNull);
      expect(UserType.fromApi(''), isNull);
      expect(UserType.fromApi('   '), isNull);
      expect(UserType.fromApi('UNKNOWN'), isNull);
      expect(UserType.fromApi(42), isNull);
    });
  });

  group('UserType.toApi', () {
    test('maps enum values to API strings', () {
      expect(UserType.toApi(UserType.client), 'CLIENT');
      expect(UserType.toApi(UserType.driver), 'DRIVER');
      expect(UserType.toApi(UserType.assistant), 'ASSISTANT');
      expect(UserType.toApi(UserType.admin), 'ADMIN');
      expect(UserType.toApi(null), isNull);
    });
  });
}
