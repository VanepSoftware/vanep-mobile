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
