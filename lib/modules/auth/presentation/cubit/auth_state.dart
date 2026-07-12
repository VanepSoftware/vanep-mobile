import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/value_objects/authorization_request.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthAuthenticating extends AuthState {
  const AuthAuthenticating(this.request);

  final AuthorizationRequest request;

  @override
  List<Object?> get props => [request];
}

class AuthExchanging extends AuthState {
  const AuthExchanging();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

class AuthFailureState extends AuthState {
  const AuthFailureState(this.failure);

  final AuthFailure failure;

  @override
  List<Object?> get props => [failure];
}
