import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String normalizeCertFingerprint(String sha1) {
  return sha1.replaceAll(':', '').replaceAll(' ', '').toUpperCase();
}

class Environment {
  const Environment({
    required this.authBaseUrl,
    required this.oauthClientId,
    required this.oauthRedirectUri,
    required this.oauthScopes,
    this.googleServerClientId = '',
    this.placesApiKeyAndroid = '',
    this.placesApiKeyIos = '',
    this.placesAndroidPackage = '',
    this.placesAndroidCertSha1 = '',
    this.placesIosBundleId = '',
  });

  factory Environment.fromDotEnv(DotEnv env) {
    return Environment(
      authBaseUrl: _require(env, 'AUTH_URL'),
      oauthClientId: _require(env, 'OAUTH_CLIENT_ID'),
      oauthRedirectUri: _require(env, 'OAUTH_REDIRECT_URI'),
      oauthScopes: _require(env, 'OAUTH_SCOPES'),
      googleServerClientId: env.maybeGet('GOOGLE_SERVER_CLIENT_ID') ?? '',
      placesApiKeyAndroid: env.maybeGet('GOOGLE_PLACES_API_KEY_ANDROID') ?? '',
      placesApiKeyIos: env.maybeGet('GOOGLE_PLACES_API_KEY_IOS') ?? '',
      placesAndroidPackage: env.maybeGet('GOOGLE_PLACES_ANDROID_PACKAGE') ?? '',
      placesAndroidCertSha1:
          env.maybeGet('GOOGLE_PLACES_ANDROID_CERT_SHA1') ?? '',
      placesIosBundleId: env.maybeGet('GOOGLE_PLACES_IOS_BUNDLE_ID') ?? '',
    );
  }

  final String authBaseUrl;

  final String oauthClientId;

  final String oauthRedirectUri;

  final String oauthScopes;

  final String googleServerClientId;

  final String placesApiKeyAndroid;

  final String placesApiKeyIos;

  final String placesAndroidPackage;

  final String placesAndroidCertSha1;

  final String placesIosBundleId;

  String get authorizationEndpoint => '$authBaseUrl/oauth2/authorize';

  String get tokenEndpoint => '$authBaseUrl/oauth2/token';

  String get revocationEndpoint => '$authBaseUrl/oauth2/revoke';

  String get signupClientEndpoint => '$authBaseUrl/api/auth/signup/client';

  String get signupDriverEndpoint => '$authBaseUrl/api/auth/signup/driver';

  String get signupAssistantEndpoint =>
      '$authBaseUrl/api/auth/signup/assistant';

  String get signupCompleteEndpoint => '$authBaseUrl/api/auth/signup/complete';

  String get emailVerifyEndpoint => '$authBaseUrl/api/auth/email/verify';

  String get emailVerifyResendEndpoint =>
      '$authBaseUrl/api/auth/email/verify/resend';

  String get passwordForgotEndpoint => '$authBaseUrl/api/auth/password/forgot';

  String get passwordResetEndpoint => '$authBaseUrl/api/auth/password/reset';

  String get userProfileEndpoint => '$authBaseUrl/api/user/me';

  String get userProfileEmailChangeEndpoint =>
      '$authBaseUrl/api/user/me/email-change';

  String get driversEndpoint => '$authBaseUrl/api/drivers';

  String get clientsMeEndpoint => '$authBaseUrl/api/clients/me';

  String get dependentsEndpoint => '$authBaseUrl/api/dependent';

  String get driversMeEndpoint => '$authBaseUrl/api/drivers/me';

  String get assistantsMeEndpoint => '$authBaseUrl/api/assistants/me';

  String get placesAutocompleteEndpoint =>
      'https://places.googleapis.com/v1/places:autocomplete';

  Map<String, String> placesAppHeadersFor(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.android => {
        'X-Android-Package': placesAndroidPackage,
        'X-Android-Cert': normalizeCertFingerprint(placesAndroidCertSha1),
      },
      TargetPlatform.iOS => {'X-Ios-Bundle-Identifier': placesIosBundleId},
      _ => const {},
    };
  }

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
