import 'package:vanep_mobile/core/environment/environment.dart';
import 'package:vanep_mobile/core/places/place_search_center.dart';

const testEnvironment = Environment(
  authBaseUrl: 'http://localhost:8080',
  oauthClientId: 'vanep-mobile',
  placesApiKeyAndroid: 'android-key',
  placesApiKeyIos: 'ios-key',
  placesAndroidPackage: 'com.vanep.vanep_mobile',
  placesAndroidCertSha1: 'ab:cd:ef:12',
  placesIosBundleId: 'com.vanep.vanepMobile',
);

const testEnvironmentWithoutPlacesKeys = Environment(
  authBaseUrl: 'http://localhost:8080',
  oauthClientId: 'vanep-mobile',
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

const brasiliaSearchCenter = PlaceSearchCenter(
  latitude: -15.7843,
  longitude: -47.9081,
);

const schoolResponseWithDistanceFixture = <String, dynamic>{
  'suggestions': [
    {
      'placePrediction': {
        'placeId': 'place-marista',
        'distanceMeters': 2400,
        'structuredFormat': {
          'mainText': {'text': 'Colégio Marista'},
          'secondaryText': {'text': 'Taguatinga, Brasília - DF, Brazil'},
        },
      },
    },
  ],
};
