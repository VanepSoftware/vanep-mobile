import 'package:equatable/equatable.dart';

/// Everything needed to run one authorization-code + PKCE login attempt.
///
/// Built once by the repository (which owns PKCE generation) and carried
/// through the WebView step so [codeVerifier] and [state] survive until the
/// code is exchanged.
class AuthorizationRequest extends Equatable {
  const AuthorizationRequest({
    required this.authorizationUrl,
    required this.redirectUri,
    required this.state,
    required this.codeVerifier,
  });

  /// Full `/oauth2/authorize` URL to load in the WebView.
  final String authorizationUrl;

  /// Custom-scheme URI whose navigation signals the end of the flow.
  final String redirectUri;

  /// Opaque anti-CSRF value; must match the `state` returned on the redirect.
  final String state;

  /// PKCE verifier whose S256 challenge was sent in [authorizationUrl].
  final String codeVerifier;

  @override
  List<Object?> get props => [
        authorizationUrl,
        redirectUri,
        state,
        codeVerifier,
      ];
}
