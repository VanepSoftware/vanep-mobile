import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';

void main() {
  test('fromApi maps RFC 9457 ProblemDetail profile codes', () {
    expect(
      ProfileErrorCode.fromApi('user.profile.name.cooldown'),
      ProfileErrorCode.cooldown,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.phone.cooldown'),
      ProfileErrorCode.cooldown,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.email.cooldown'),
      ProfileErrorCode.cooldown,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.email.resend.cooldown'),
      ProfileErrorCode.cooldown,
    );
    expect(
      ProfileErrorCode.fromApi('auth.signup.email.duplicate'),
      ProfileErrorCode.emailDuplicate,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.field.null'),
      ProfileErrorCode.fieldNull,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.phone.blank'),
      ProfileErrorCode.phoneBlank,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.email.same'),
      ProfileErrorCode.emailSame,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.email.invalid'),
      ProfileErrorCode.emailInvalid,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.email.required'),
      ProfileErrorCode.emailRequired,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.name.too_long'),
      ProfileErrorCode.nameTooLong,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.phone.too_long'),
      ProfileErrorCode.phoneTooLong,
    );
    expect(
      ProfileErrorCode.fromApi('user.profile.email.too_long'),
      ProfileErrorCode.emailTooLong,
    );
  });

  test('fromApi rejects removed legacy snake_case and unknown codes', () {
    expect(ProfileErrorCode.fromApi('cooldown'), isNull);
    expect(ProfileErrorCode.fromApi('email_duplicate'), isNull);
    expect(ProfileErrorCode.fromApi('phone_blank'), isNull);
    expect(ProfileErrorCode.fromApi('UNKNOWN'), isNull);
    expect(ProfileErrorCode.fromApi(null), isNull);
  });
}
