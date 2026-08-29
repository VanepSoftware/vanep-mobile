import 'dart:async';

import '../result/result.dart';
import 'place_autocomplete_datasource.dart';
import 'place_autocomplete_failure.dart';
import 'place_search_session.dart';
import 'place_suggestion.dart';

const placeAutocompleteMinimumCharacters = 3;
const placeAutocompleteDebounce = Duration(milliseconds: 350);

class PlaceAutocompleteController {
  PlaceAutocompleteController({
    required this.datasource,
    PlaceSearchSession? session,
    this.debounce = placeAutocompleteDebounce,
    this.minimumCharacters = placeAutocompleteMinimumCharacters,
  }) : session = session ?? PlaceSearchSession();

  final PlaceAutocompleteDataSource datasource;
  final PlaceSearchSession session;
  final Duration debounce;
  final int minimumCharacters;

  Timer? _pending;
  int _requestSequence = 0;

  void search(
    String input,
    void Function(Result<PlaceAutocompleteFailure, List<PlaceSuggestion>>) onResult,
  ) {
    _pending?.cancel();
    if (input.trim().length < minimumCharacters) {
      onResult(const Ok(<PlaceSuggestion>[]));
      return;
    }
    _pending = Timer(debounce, () => _dispatch(input.trim(), onResult));
  }

  Future<void> _dispatch(
    String input,
    void Function(Result<PlaceAutocompleteFailure, List<PlaceSuggestion>>) onResult,
  ) async {
    final sequence = ++_requestSequence;
    final result = await datasource.findSuggestions(input, session.currentToken());
    if (sequence != _requestSequence) return;
    onResult(result);
  }

  String handOverSelection() {
    final token = session.currentToken();
    session.completeAfterHandover();
    return token;
  }

  void dispose() => _pending?.cancel();
}
