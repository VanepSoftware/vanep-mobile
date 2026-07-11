import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Central access point for runtime configuration (constitution R09).
///
/// Values come from the `.env` file loaded by `flutter_dotenv` at startup
/// (see `main.dart`). Keep every environment-dependent constant here so the
/// rest of the app never reads `dotenv` directly.
class Environment {
  const Environment({
    required this.authBaseUrl,
    required this.oauthClientId,
    required this.oauthRedirectUri,
    required this.oauthScopes,
  });

  /// Builds the environment from the already-loaded [DotEnv] instance.
  ///
  /// Throws [ArgumentError] when a required key is missing so misconfiguration
  /// fails fast at boot instead of surfacing as an obscure network error later.
  factory Environment.fromDotEnv(DotEnv env) {
    return Environment(
      authBaseUrl: _require(env, 'AUTH_URL'),
      oauthClientId: _require(env, 'OAUTH_CLIENT_ID'),
      oauthRedirectUri: _require(env, 'OAUTH_REDIRECT_URI'),
      oauthScopes: _require(env, 'OAUTH_SCOPES'),
    );
  }

  /// Base URL of the Spring Authorization Server (no `/api` suffix).
  final String authBaseUrl;

  /// Public OAuth client id registered in the backend for the mobile app.
  final String oauthClientId;

  /// Custom-scheme redirect URI intercepted inside the login WebView.
  final String oauthRedirectUri;

  /// Space-separated OAuth scopes requested at the authorize endpoint.
  final String oauthScopes;

  /// `${authBaseUrl}/oauth2/authorize`.
  String get authorizationEndpoint => '$authBaseUrl/oauth2/authorize';

  /// `${authBaseUrl}/oauth2/token`.
  String get tokenEndpoint => '$authBaseUrl/oauth2/token';

  /// `${authBaseUrl}/oauth2/revoke`.
  String get revocationEndpoint => '$authBaseUrl/oauth2/revoke';

  /// `${authBaseUrl}/api/user/profile`.
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
