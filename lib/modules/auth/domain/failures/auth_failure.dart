import 'package:equatable/equatable.dart';

sealed class AuthFailure extends Equatable {
  const AuthFailure();

  @override
  List<Object?> get props => [];
}

class CancelledAuthFailure extends AuthFailure {
  const CancelledAuthFailure();
}

class InvalidStateAuthFailure extends AuthFailure {
  const InvalidStateAuthFailure();
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
