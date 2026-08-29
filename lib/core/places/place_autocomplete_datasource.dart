import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../environment/environment.dart';
import '../result/result.dart';
import 'place_autocomplete_failure.dart';
import 'place_suggestion.dart';

const placesRegionCode = 'br';

List<PlaceSuggestion> parsePlaceSuggestions(Map<String, Object?> body) {
  final raw = body['suggestions'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map<String, Object?>>()
      .map((entry) => entry['placePrediction'])
      .whereType<Map<String, Object?>>()
      .map(toPlaceSuggestion)
      .whereType<PlaceSuggestion>()
      .toList();
}

PlaceSuggestion? toPlaceSuggestion(Map<String, Object?> prediction) {
  final placeId = prediction['placeId'];
  if (placeId is! String || placeId.isEmpty) return null;
  final structured = prediction['structuredFormat'];
  final primary = structured is Map<String, Object?>
      ? readNestedText(structured['mainText'])
      : null;
  final secondary = structured is Map<String, Object?>
      ? readNestedText(structured['secondaryText'])
      : null;
  return PlaceSuggestion(
    placeId: placeId,
    primaryText: primary ?? readNestedText(prediction['text']) ?? placeId,
    secondaryText: secondary ?? '',
  );
}

String? readNestedText(Object? node) {
  if (node is! Map<String, Object?>) return null;
  final text = node['text'];
  return text is String ? text : null;
}

class PlaceAutocompleteDataSource {
  PlaceAutocompleteDataSource({
    required this.dio,
    required this.environment,
    required this.platform,
  });

  final Dio dio;
  final Environment environment;
  final TargetPlatform platform;

  Future<Result<PlaceAutocompleteFailure, List<PlaceSuggestion>>> findSuggestions(
    String input,
    String sessionToken,
  ) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        environment.placesAutocompleteEndpoint,
        data: {
          'input': input,
          'sessionToken': sessionToken,
          'includedRegionCodes': [placesRegionCode],
        },
        options: Options(
          headers: {'X-Goog-Api-Key': environment.placesApiKeyFor(platform)},
        ),
      );
      final body = response.data;
      if (body == null) return const Ok([]);
      return Ok(parsePlaceSuggestions(Map<String, Object?>.from(body)));
    } on DioException catch (exception) {
      return Err(failureFromStatus(exception));
    } on StateError {
      return const Err(PlaceAutocompleteFailure.rejectedKey);
    }
  }
}

PlaceAutocompleteFailure failureFromStatus(DioException exception) {
  final status = exception.response?.statusCode;
  if (status == 403 || status == 401) {
    return PlaceAutocompleteFailure.rejectedKey;
  }
  if (status == null) return PlaceAutocompleteFailure.network;
  return PlaceAutocompleteFailure.unexpected;
}
