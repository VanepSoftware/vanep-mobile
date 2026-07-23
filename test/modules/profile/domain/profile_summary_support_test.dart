import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/value_objects/user_type.dart';
import 'package:vanep_mobile/modules/profile/domain/profile_summary_support.dart';

void main() {
  test('profileSummaryUserType returns type for client, driver, assistant', () {
    expect(profileSummaryUserType(UserType.client), UserType.client);
    expect(profileSummaryUserType(UserType.driver), UserType.driver);
    expect(profileSummaryUserType(UserType.assistant), UserType.assistant);
  });

  test('profileSummaryUserType is null for admin and null', () {
    expect(profileSummaryUserType(UserType.admin), isNull);
    expect(profileSummaryUserType(null), isNull);
  });

  test('supportsProfileSummary mirrors profileSummaryUserType', () {
    expect(supportsProfileSummary(UserType.client), isTrue);
    expect(supportsProfileSummary(UserType.admin), isFalse);
    expect(supportsProfileSummary(null), isFalse);
  });
}
