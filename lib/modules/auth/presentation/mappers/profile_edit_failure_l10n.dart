import '../../../../l10n/app_localizations.dart';
import '../../domain/failures/profile_edit_failure.dart';
import '../../domain/value_objects/profile_field_limits.dart';

String profileEditFailureMessage(
  AppLocalizations l10n,
  ProfileEditFailure failure, {
  String? formattedRetryAfter,
}) {
  return switch (failure) {
    StructuredProfileEditFailure(:final code, :final retryAfter) =>
      profileErrorCodeMessage(
        l10n,
        code,
        formattedRetryAfter:
            formattedRetryAfter ?? retryAfter?.toIso8601String(),
      ),
    NetworkProfileEditFailure() => l10n.profileEditErrorNetwork,
    UnexpectedProfileEditFailure() => l10n.profileEditErrorUnexpected,
  };
}

String? profileFieldErrorMessage(
  AppLocalizations l10n,
  ProfileErrorCode? code, {
  String? formattedRetryAfter,
}) {
  if (code == null) return null;
  return profileErrorCodeMessage(
    l10n,
    code,
    formattedRetryAfter: formattedRetryAfter,
  );
}

String profileErrorCodeMessage(
  AppLocalizations l10n,
  ProfileErrorCode code, {
  String? formattedRetryAfter,
}) {
  return switch (code) {
    ProfileErrorCode.cooldown => l10n.profileEditErrorCooldown(
      formattedRetryAfter ?? l10n.profileFieldEmpty,
    ),
    ProfileErrorCode.emailDuplicate => l10n.profileEditErrorEmailDuplicate,
    ProfileErrorCode.fieldNull => l10n.profileEditErrorFieldNull,
    ProfileErrorCode.phoneBlank => l10n.profileEditErrorPhoneBlank,
    ProfileErrorCode.emailSame => l10n.profileEditErrorEmailSame,
    ProfileErrorCode.emailInvalid => l10n.profileEditErrorEmailInvalid,
    ProfileErrorCode.emailRequired => l10n.profileEditErrorEmailRequired,
    ProfileErrorCode.nameTooLong => l10n.profileEditErrorNameTooLong(
      ProfileFieldLimits.nameMaxLength,
    ),
    ProfileErrorCode.phoneTooLong => l10n.profileEditErrorPhoneTooLong(
      ProfileFieldLimits.phoneMaxLength,
    ),
    ProfileErrorCode.emailTooLong => l10n.profileEditErrorEmailTooLong(
      ProfileFieldLimits.emailMaxLength,
    ),
  };
}
