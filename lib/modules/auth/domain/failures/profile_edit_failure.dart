import 'package:equatable/equatable.dart';

enum ProfileErrorCode {
  cooldown,
  emailDuplicate,
  fieldNull,
  phoneBlank,
  emailSame,
  emailInvalid,
  emailRequired;

  static ProfileErrorCode? fromApi(Object? raw) {
    if (raw is! String) return null;
    final normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    return switch (normalized) {
      'cooldown' => ProfileErrorCode.cooldown,
      'email_duplicate' => ProfileErrorCode.emailDuplicate,
      'field_null' => ProfileErrorCode.fieldNull,
      'phone_blank' => ProfileErrorCode.phoneBlank,
      'email_same' => ProfileErrorCode.emailSame,
      'email_invalid' => ProfileErrorCode.emailInvalid,
      'email_required' => ProfileErrorCode.emailRequired,
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
    this.serverMessage,
  });

  final ProfileErrorCode code;
  final String? field;
  final DateTime? retryAfter;
  final String? serverMessage;

  @override
  List<Object?> get props => [code, field, retryAfter, serverMessage];
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
