import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_failure.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';

import 'places_fixtures.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio dio;
  late PlaceAutocompleteDataSource datasource;

  setUpAll(() => registerFallbackValue(Options()));

  setUp(() {
    dio = MockDio();
    datasource = PlaceAutocompleteDataSource(
      dio: dio,
      environment: testEnvironment,
      platform: TargetPlatform.android,
    );
  });

  void stubResponse(Map<String, dynamic> body) {
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response<Map<String, dynamic>>(
        data: body,
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );
  }

  void stubFailure(int? statusCode) {
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(),
        response: statusCode == null
            ? null
            : Response<void>(
                statusCode: statusCode,
                requestOptions: RequestOptions(),
              ),
        type: statusCode == null
            ? DioExceptionType.connectionTimeout
            : DioExceptionType.badResponse,
      ),
    );
  }

  test('maps suggestions from a real response shape', () async {
    stubResponse(autocompleteResponseFixture);

    final result = await datasource.findSuggestions('qnl 5', 'session-1');

    expect(
      result.valueOrNull,
      const [
        PlaceSuggestion(
          placeId: 'place-qnl5',
          primaryText: 'Setor L Norte QNL 5',
          secondaryText: 'Taguatinga, Brasília - DF, Brazil',
        ),
      ],
    );
  });

  test('an empty list is an empty state, not a failure', () async {
    stubResponse(const {'suggestions': <Object?>[]});

    final result = await datasource.findSuggestions('zzzz', 'session-1');

    expect(result.isOk, isTrue);
    expect(result.valueOrNull, isEmpty);
  });

  test('sends the session token and restricts the region to Brazil', () async {
    stubResponse(autocompleteResponseFixture);

    await datasource.findSuggestions('qnl 5', 'session-abc');

    final captured = verify(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: captureAny(named: 'data'),
        options: any(named: 'options'),
      ),
    ).captured.single as Map<String, Object?>;

    expect(captured['sessionToken'], 'session-abc');
    expect(captured['includedRegionCodes'], ['br']);
    expect(captured['input'], 'qnl 5');
    expect(captured.containsKey('includedPrimaryTypes'), isFalse);
  });

  test('restricts the place types only when asked to', () async {
    stubResponse(autocompleteResponseFixture);

    await datasource.findSuggestions(
      'escola classe',
      'session-abc',
      includedPrimaryTypes: const ['school', 'primary_school'],
    );

    final captured = verify(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: captureAny(named: 'data'),
        options: any(named: 'options'),
      ),
    ).captured.single as Map<String, Object?>;

    expect(captured['includedPrimaryTypes'], ['school', 'primary_school']);
  });

  test(
    'biases toward the search center and measures distance from it',
    () async {
      stubResponse(autocompleteResponseFixture);

      await datasource.findSuggestions(
        'colégio',
        'session-abc',
        searchCenter: brasiliaSearchCenter,
      );

      final captured =
          verify(
                () => dio.post<Map<String, dynamic>>(
                  any(),
                  data: captureAny(named: 'data'),
                  options: any(named: 'options'),
                ),
              ).captured.single
              as Map<String, Object?>;

      const center = {'latitude': -15.7843, 'longitude': -47.9081};
      expect(captured['locationBias'], {
        'circle': {'center': center, 'radius': 50000.0},
      });
      expect(captured['origin'], center);
      expect(captured.containsKey('locationRestriction'), isFalse);
      expect(captured['includedRegionCodes'], ['br']);
    },
  );

  test('sends neither bias nor origin without a search center', () async {
    stubResponse(autocompleteResponseFixture);

    await datasource.findSuggestions('qnl 5', 'session-abc');

    final captured =
        verify(
              () => dio.post<Map<String, dynamic>>(
                any(),
                data: captureAny(named: 'data'),
                options: any(named: 'options'),
              ),
            ).captured.single
            as Map<String, Object?>;

    expect(captured.containsKey('locationBias'), isFalse);
    expect(captured.containsKey('origin'), isFalse);
  });

  test('reads the distance of each suggestion', () async {
    stubResponse(schoolResponseWithDistanceFixture);

    final result = await datasource.findSuggestions(
      'colégio',
      'session-1',
      searchCenter: brasiliaSearchCenter,
    );

    expect(result.valueOrNull?.single.distanceMeters, 2400);
  });

  test('a suggestion without distance has a null distance', () async {
    stubResponse(autocompleteResponseFixture);

    final result = await datasource.findSuggestions('qnl 5', 'session-1');

    expect(result.valueOrNull?.single.distanceMeters, isNull);
  });

  test('sends the platform key in the header', () async {
    stubResponse(autocompleteResponseFixture);

    await datasource.findSuggestions('qnl 5', 'session-1');

    final options = verify(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: captureAny(named: 'options'),
      ),
    ).captured.single as Options;

    expect(options.headers?['X-Goog-Api-Key'], 'android-key');
  });

  test('identifies the Android app to Google', () async {
    stubResponse(autocompleteResponseFixture);

    await datasource.findSuggestions('qnl 5', 'session-1');

    final options = verify(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: captureAny(named: 'options'),
      ),
    ).captured.single as Options;

    expect(options.headers?['X-Android-Package'], 'com.vanep.vanep_mobile');
    expect(options.headers?['X-Android-Cert'], 'ABCDEF12');
  });

  test('identifies the iOS app to Google', () async {
    final iosDatasource = PlaceAutocompleteDataSource(
      dio: dio,
      environment: testEnvironment,
      platform: TargetPlatform.iOS,
    );
    stubResponse(autocompleteResponseFixture);

    await iosDatasource.findSuggestions('qnl 5', 'session-1');

    final options = verify(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: captureAny(named: 'options'),
      ),
    ).captured.single as Options;

    expect(
      options.headers?['X-Ios-Bundle-Identifier'],
      'com.vanep.vanepMobile',
    );
    expect(options.headers?['X-Android-Package'], isNull);
  });

  test('a rejected key is distinct from a network failure', () async {
    stubFailure(403);

    final result = await datasource.findSuggestions('qnl 5', 'session-1');

    expect(result.errorOrNull, PlaceAutocompleteFailure.rejectedKey);
  });

  test('a timeout is a network failure', () async {
    stubFailure(null);

    final result = await datasource.findSuggestions('qnl 5', 'session-1');

    expect(result.errorOrNull, PlaceAutocompleteFailure.network);
  });

  test('an unexpected status is neither network nor rejected key', () async {
    stubFailure(500);

    final result = await datasource.findSuggestions('qnl 5', 'session-1');

    expect(result.errorOrNull, PlaceAutocompleteFailure.unexpected);
  });

  test('a missing platform key surfaces as a rejected key', () async {
    final withoutKey = PlaceAutocompleteDataSource(
      dio: dio,
      environment: testEnvironmentWithoutPlacesKeys,
      platform: TargetPlatform.android,
    );

    final result = await withoutKey.findSuggestions('qnl 5', 'session-1');

    expect(result.errorOrNull, PlaceAutocompleteFailure.rejectedKey);
  });
}
