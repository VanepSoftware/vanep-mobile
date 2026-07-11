import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/di/service_locator.dart';
import 'package:vanep_mobile/core/environment/environment.dart';

const _env = Environment(
  authBaseUrl: 'http://10.0.2.2:8080',
  oauthClientId: 'vanep-mobile',
  oauthRedirectUri: 'com.vanep.vanepmobile://oauth2redirect',
  oauthScopes: 'read write',
);

void main() {
  tearDown(getIt.reset);

  test('configureCoreDependencies registers the Environment singleton', () {
    configureCoreDependencies(_env);

    expect(getIt<Environment>(), same(_env));
  });

  test('is idempotent — a second call keeps the first registration', () {
    configureCoreDependencies(_env);
    configureCoreDependencies(
      const Environment(
        authBaseUrl: 'other',
        oauthClientId: 'other',
        oauthRedirectUri: 'other',
        oauthScopes: 'other',
      ),
    );

    expect(getIt<Environment>(), same(_env));
  });
}
