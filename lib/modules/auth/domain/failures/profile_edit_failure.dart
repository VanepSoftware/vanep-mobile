import 'package:equatable/equatable.dart';
import 'package:vanep_mobile/core/network/api_error_codes.dart';

enum ProfileErrorCode {
  cooldown,
  emailDuplicate,
  fieldNull,
  phoneBlank,
  emailSame,
  emailInvalid,
  emailRequired,
  nameTooLong,
  phoneTooLong,
  emailTooLong;

  static ProfileErrorCode? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    return switch (normalized) {
      ApiErrorCodes.userProfileNameCooldown ||
      ApiErrorCodes.userProfilePhoneCooldown ||
      ApiErrorCodes.userProfileEmailCooldown ||
      ApiErrorCodes.userProfileEmailResendCooldown => ProfileErrorCode.cooldown,
      ApiErrorCodes.authSignupEmailDuplicate => ProfileErrorCode.emailDuplicate,
      ApiErrorCodes.userProfileFieldNull => ProfileErrorCode.fieldNull,
      ApiErrorCodes.userProfilePhoneBlank => ProfileErrorCode.phoneBlank,
      ApiErrorCodes.userProfileEmailSame => ProfileErrorCode.emailSame,
      ApiErrorCodes.userProfileEmailInvalid => ProfileErrorCode.emailInvalid,
      ApiErrorCodes.userProfileEmailRequired => ProfileErrorCode.emailRequired,
      ApiErrorCodes.userProfileNameTooLong => ProfileErrorCode.nameTooLong,
      ApiErrorCodes.userProfilePhoneTooLong => ProfileErrorCode.phoneTooLong,
      ApiErrorCodes.userProfileEmailTooLong => ProfileErrorCode.emailTooLong,
      _ => null,
    };
  }
}

sealed class ProfileEditFailure extends Equatable {
  const ProfileEditFailure();

  @override
  List<Object?> get props => [];
}

class StructuredProfileEditFailure extends ProfileEditFailure {
  const StructuredProfileEditFailure({
    required this.code,
    this.field,
    this.retryAfter,
  });

  final ProfileErrorCode code;
  final String? field;
  final DateTime? retryAfter;

  @override
  List<Object?> get props => [code, field, retryAfter];
}

class NetworkProfileEditFailure extends ProfileEditFailure {
  const NetworkProfileEditFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}

class UnexpectedProfileEditFailure extends ProfileEditFailure {
  const UnexpectedProfileEditFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}
