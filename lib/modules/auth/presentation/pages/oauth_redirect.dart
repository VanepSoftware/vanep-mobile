import '../../domain/value_objects/authorization_request.dart';

/// Whether [url] is the OAuth redirect (custom-scheme) we are waiting for.
bool isOAuthRedirect(String url, String redirectUri) =>
    url.startsWith(redirectUri);

/// Extracts the authorization code from a redirect [url], or `null` when the
/// redirect carried an `error` or a `state` that does not match [request].
String? extractAuthorizationCode(String url, AuthorizationRequest request) {
  final params = Uri.parse(url).queryParameters;
  if (params['error'] != null) return null;
  final code = params['code'];
  final state = params['state'];
  if (code == null || state != request.state) return null;
  return code;
}
