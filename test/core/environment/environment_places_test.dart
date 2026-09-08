import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/environment/environment.dart';

Environment environmentWith({String android = 'android-key', String ios = 'ios-key'}) {
  return Environment(
    authBaseUrl: 'http://localhost:8080',
    oauthClientId: 'vanep-mobile',
    oauthRedirectUri: 'com.vanep.vanepmobile://oauth2redirect',
    oauthScopes: 'read write',
    placesApiKeyAndroid: android,
    placesApiKeyIos: ios,
  );
}

void main() {
  test('uses the Android key on Android', () {
    final environment = environmentWith();

    expect(
      environment.placesApiKeyFor(TargetPlatform.android),
      'android-key',
    );
  });

  test('uses the iOS key on iOS', () {
    final environment = environmentWith();

    expect(environment.placesApiKeyFor(TargetPlatform.iOS), 'ios-key');
  });

  test('fails loudly when the key for the current platform is missing', () {
    final environment = environmentWith(android: '');

    expect(
      () => environment.placesApiKeyFor(TargetPlatform.android),
      throwsA(isA<StateError>()),
    );
  });

  test('fails loudly on a platform without a Places key', () {
    final environment = environmentWith();

    expect(
      () => environment.placesApiKeyFor(TargetPlatform.macOS),
      throwsA(isA<StateError>()),
    );
  });

  test('exposes the Places autocomplete endpoint', () {
    expect(
      environmentWith().placesAutocompleteEndpoint,
      'https://places.googleapis.com/v1/places:autocomplete',
    );
  });
}
