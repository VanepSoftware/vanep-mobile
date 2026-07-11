import 'package:equatable/equatable.dart';

/// Domain-level error for the authentication flow (used as the `E` in
/// `Result<AuthFailure, T>`). Presentation maps each variant to a localized
/// message — the failures themselves carry no user-facing copy (R10).
sealed class AuthFailure extends Equatable {
  const AuthFailure();

  @override
  List<Object?> get props => [];
}

/// The user closed the WebView / denied access before finishing login.
class CancelledAuthFailure extends AuthFailure {
  const CancelledAuthFailure();
}

/// The `state` returned on the redirect did not match the one we sent.
class InvalidStateAuthFailure extends AuthFailure {
  const InvalidStateAuthFailure();
}

/// Network or backend error while exchanging the code / refreshing / revoking.
class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}

/// Anything else that should not normally happen.
class UnexpectedAuthFailure extends AuthFailure {
  const UnexpectedAuthFailure([this.detail]);

  final String? detail;

  @override
  List<Object?> get props => [detail];
}
