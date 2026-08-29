import 'package:vanep_mobile/core/environment/environment.dart';

const testEnvironment = Environment(
  authBaseUrl: 'http://localhost:8080',
  oauthClientId: 'vanep-mobile',
  oauthRedirectUri: 'com.vanep.vanepmobile://oauth2redirect',
  oauthScopes: 'read write',
  placesApiKeyAndroid: 'android-key',
  placesApiKeyIos: 'ios-key',
);

const testEnvironmentWithoutPlacesKeys = Environment(
  authBaseUrl: 'http://localhost:8080',
  oauthClientId: 'vanep-mobile',
  oauthRedirectUri: 'com.vanep.vanepmobile://oauth2redirect',
  oauthScopes: 'read write',
);

const autocompleteResponseFixture = <String, dynamic>{
  'suggestions': [
    {
      'placePrediction': {
        'placeId': 'place-qnl5',
        'text': {
          'text': 'Setor L Norte QNL 5 - Taguatinga, Brasília - DF, Brazil',
        },
        'structuredFormat': {
          'mainText': {'text': 'Setor L Norte QNL 5'},
          'secondaryText': {'text': 'Taguatinga, Brasília - DF, Brazil'},
        },
      },
    },
  ],
};
