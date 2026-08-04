import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/auth/domain/failures/profile_edit_failure.dart';
import 'package:vanep_mobile/modules/auth/presentation/mappers/profile_edit_failure_l10n.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('maps structured codes to ARB copy', () {
    expect(
      profileErrorCodeMessage(l10n, ProfileErrorCode.emailDuplicate),
      'This email is already in use.',
    );
    expect(
      profileErrorCodeMessage(
        l10n,
        ProfileErrorCode.cooldown,
        formattedRetryAfter: '9/1/2026 10:00 AM',
      ),
      'You can change this again on 9/1/2026 10:00 AM.',
    );
    expect(
      profileErrorCodeMessage(l10n, ProfileErrorCode.nameTooLong),
      'Name must be at most 255 characters.',
    );
    expect(
      profileErrorCodeMessage(l10n, ProfileErrorCode.phoneTooLong),
      'Phone number must be at most 32 characters.',
    );
    expect(
      profileErrorCodeMessage(l10n, ProfileErrorCode.emailTooLong),
      'Email must be at most 255 characters.',
    );
  });

  test('maps network and unexpected failures', () {
    expect(
      profileEditFailureMessage(l10n, const NetworkProfileEditFailure()),
      contains('Check your connection'),
    );
    expect(
      profileEditFailureMessage(l10n, const UnexpectedProfileEditFailure()),
      contains('Something went wrong'),
    );
  });
}
