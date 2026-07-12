import '../../domain/value_objects/authorization_request.dart';

bool isOAuthRedirect(String url, String redirectUri) =>
    url.startsWith(redirectUri);

String? extractAuthorizationCode(String url, AuthorizationRequest request) {
  final params = Uri.parse(url).queryParameters;
  if (params['error'] != null) return null;
  final code = params['code'];
  final state = params['state'];
  if (code == null || state != request.state) return null;
  return code;
}
