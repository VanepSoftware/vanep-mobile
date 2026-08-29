import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  const Environment({
    required this.authBaseUrl,
    required this.oauthClientId,
    required this.oauthRedirectUri,
    required this.oauthScopes,
    this.placesApiKeyAndroid = '',
    this.placesApiKeyIos = '',
  });

  factory Environment.fromDotEnv(DotEnv env) {
    return Environment(
      authBaseUrl: _require(env, 'AUTH_URL'),
      oauthClientId: _require(env, 'OAUTH_CLIENT_ID'),
      oauthRedirectUri: _require(env, 'OAUTH_REDIRECT_URI'),
      oauthScopes: _require(env, 'OAUTH_SCOPES'),
      placesApiKeyAndroid: env.maybeGet('GOOGLE_PLACES_API_KEY_ANDROID') ?? '',
      placesApiKeyIos: env.maybeGet('GOOGLE_PLACES_API_KEY_IOS') ?? '',
    );
  }

  final String authBaseUrl;

  final String oauthClientId;

  final String oauthRedirectUri;

  final String oauthScopes;

  final String placesApiKeyAndroid;

  final String placesApiKeyIos;

  String get authorizationEndpoint => '$authBaseUrl/oauth2/authorize';

  String get tokenEndpoint => '$authBaseUrl/oauth2/token';

  String get revocationEndpoint => '$authBaseUrl/oauth2/revoke';

  String get userProfileEndpoint => '$authBaseUrl/api/user/me';

  String get userProfileEmailChangeEndpoint =>
      '$authBaseUrl/api/user/me/email-change';

  String get driversEndpoint => '$authBaseUrl/api/drivers';

  String get clientsMeEndpoint => '$authBaseUrl/api/clients/me';

  String get driversMeEndpoint => '$authBaseUrl/api/drivers/me';

  String get assistantsMeEndpoint => '$authBaseUrl/api/assistants/me';

  String get placesAutocompleteEndpoint =>
      'https://places.googleapis.com/v1/places:autocomplete';

  String placesApiKeyFor(TargetPlatform platform) {
    final key = switch (platform) {
      TargetPlatform.android => placesApiKeyAndroid,
      TargetPlatform.iOS => placesApiKeyIos,
      _ => '',
    };
    if (key.isEmpty) {
      throw StateError(
        'Missing Google Places key for $platform. '
        'Fill GOOGLE_PLACES_API_KEY_ANDROID / GOOGLE_PLACES_API_KEY_IOS in .env.',
      );
    }
    return key;
  }

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
