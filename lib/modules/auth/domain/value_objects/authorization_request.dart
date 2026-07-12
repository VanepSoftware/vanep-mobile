import 'package:equatable/equatable.dart';

class AuthorizationRequest extends Equatable {
  const AuthorizationRequest({
    required this.authorizationUrl,
    required this.redirectUri,
    required this.state,
    required this.codeVerifier,
  });

  final String authorizationUrl;

  final String redirectUri;

  final String state;

  final String codeVerifier;

  @override
  List<Object?> get props => [
    authorizationUrl,
    redirectUri,
    state,
    codeVerifier,
  ];
}
