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
