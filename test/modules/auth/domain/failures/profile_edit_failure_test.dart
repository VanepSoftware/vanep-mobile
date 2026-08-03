import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';

void main() {
  test('fromApi maps snake_case codes', () {
    expect(ProfileErrorCode.fromApi('cooldown'), ProfileErrorCode.cooldown);
    expect(
      ProfileErrorCode.fromApi('email_duplicate'),
      ProfileErrorCode.emailDuplicate,
    );
    expect(ProfileErrorCode.fromApi('field_null'), ProfileErrorCode.fieldNull);
    expect(ProfileErrorCode.fromApi('phone_blank'), ProfileErrorCode.phoneBlank);
    expect(ProfileErrorCode.fromApi('email_same'), ProfileErrorCode.emailSame);
    expect(
      ProfileErrorCode.fromApi('email_invalid'),
      ProfileErrorCode.emailInvalid,
    );
    expect(
      ProfileErrorCode.fromApi('email_required'),
      ProfileErrorCode.emailRequired,
    );
  });

  test('fromApi returns null for unknown codes', () {
    expect(ProfileErrorCode.fromApi('UNKNOWN'), isNull);
    expect(ProfileErrorCode.fromApi(null), isNull);
  });
}
