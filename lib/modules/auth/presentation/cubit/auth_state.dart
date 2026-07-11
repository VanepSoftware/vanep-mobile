import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/value_objects/authorization_request.dart';

/// UI state of the authentication flow.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Startup state while the persisted session is being resolved.
class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// No authenticated user; the welcome screen is shown.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// A login attempt has started; [request] must be opened in the WebView.
class AuthAuthenticating extends AuthState {
  const AuthAuthenticating(this.request);

  final AuthorizationRequest request;

  @override
  List<Object?> get props => [request];
}

/// The authorization code was captured and is being exchanged for tokens.
class AuthExchanging extends AuthState {
  const AuthExchanging();
}

/// The user is authenticated.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

/// A transient failure to surface to the user (followed by a return to
/// [AuthUnauthenticated]).
class AuthFailureState extends AuthState {
  const AuthFailureState(this.failure);

  final AuthFailure failure;

  @override
  List<Object?> get props => [failure];
}
