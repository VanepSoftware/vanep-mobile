import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  const Environment({
    required this.authBaseUrl,
    required this.oauthClientId,
    required this.oauthRedirectUri,
    required this.oauthScopes,
  });

  factory Environment.fromDotEnv(DotEnv env) {
    return Environment(
      authBaseUrl: _require(env, 'AUTH_URL'),
      oauthClientId: _require(env, 'OAUTH_CLIENT_ID'),
      oauthRedirectUri: _require(env, 'OAUTH_REDIRECT_URI'),
      oauthScopes: _require(env, 'OAUTH_SCOPES'),
    );
  }

  final String authBaseUrl;

  final String oauthClientId;

  final String oauthRedirectUri;

  final String oauthScopes;

  String get authorizationEndpoint => '$authBaseUrl/oauth2/authorize';

  String get tokenEndpoint => '$authBaseUrl/oauth2/token';

  String get revocationEndpoint => '$authBaseUrl/oauth2/revoke';

  String get userProfileEndpoint => '$authBaseUrl/api/user/profile';

  static String _require(DotEnv env, String key) {
    final value = env.maybeGet(key);
    if (value == null || value.isEmpty) {
      throw ArgumentError(
        'Missing required env "$key". Copy .env.example to .env and fill it in.',
      );
    }
    return value;
  }
}
