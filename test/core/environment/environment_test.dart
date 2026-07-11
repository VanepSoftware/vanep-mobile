import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/environment/environment.dart';

DotEnv _dotEnvWith(Map<String, String> values) {
  final env = DotEnv();
  env.loadFromString(mergeWith: values, isOptional: true);
  return env;
}

const _validEnv = {
  'AUTH_URL': 'http://10.0.2.2:8080',
  'OAUTH_CLIENT_ID': 'vanep-mobile',
  'OAUTH_REDIRECT_URI': 'com.vanep.vanepmobile://oauth2redirect',
  'OAUTH_SCOPES': 'read write',
};

void main() {
  group('Environment', () {
    test('reads all values from dotenv', () {
      final env = Environment.fromDotEnv(_dotEnvWith(_validEnv));

      expect(env.authBaseUrl, 'http://10.0.2.2:8080');
      expect(env.oauthClientId, 'vanep-mobile');
      expect(env.oauthRedirectUri, 'com.vanep.vanepmobile://oauth2redirect');
      expect(env.oauthScopes, 'read write');
    });

    test('derives OAuth endpoints from the base URL', () {
      final env = Environment.fromDotEnv(_dotEnvWith(_validEnv));

      expect(env.authorizationEndpoint, 'http://10.0.2.2:8080/oauth2/authorize');
      expect(env.tokenEndpoint, 'http://10.0.2.2:8080/oauth2/token');
      expect(env.revocationEndpoint, 'http://10.0.2.2:8080/oauth2/revoke');
      expect(env.userProfileEndpoint, 'http://10.0.2.2:8080/api/user/profile');
    });

    test('throws when a required key is missing', () {
      final incomplete = Map<String, String>.from(_validEnv)
        ..remove('OAUTH_CLIENT_ID');

      expect(
        () => Environment.fromDotEnv(_dotEnvWith(incomplete)),
        throwsArgumentError,
      );
    });
  });
}
