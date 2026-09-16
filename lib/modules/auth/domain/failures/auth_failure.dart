import 'package:equatable/equatable.dart';

import '../value_objects/google_signup_ticket.dart';

sealed class AuthFailure extends Equatable {
  const AuthFailure();

  @override
  List<Object?> get props => [];
}

class CancelledAuthFailure extends AuthFailure {
  const CancelledAuthFailure();
}

class InvalidCredentialsAuthFailure extends AuthFailure {
  const InvalidCredentialsAuthFailure();
}

class EmailNotVerifiedAuthFailure extends AuthFailure {
  const EmailNotVerifiedAuthFailure();
}

class AccountLockedAuthFailure extends AuthFailure {
  const AccountLockedAuthFailure();
}

class AccountDisabledAuthFailure extends AuthFailure {
  const AccountDisabledAuthFailure();
}

class TooManyRequestsAuthFailure extends AuthFailure {
  const TooManyRequestsAuthFailure();
}

class GoogleSignInAuthFailure extends AuthFailure {
  const GoogleSignInAuthFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}

class RegistrationRequiredAuthFailure extends AuthFailure {
  const RegistrationRequiredAuthFailure(this.ticket);

  final GoogleSignupTicket ticket;

  @override
  List<Object?> get props => [ticket];
}

class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}

class UnexpectedAuthFailure extends AuthFailure {
  const UnexpectedAuthFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}
