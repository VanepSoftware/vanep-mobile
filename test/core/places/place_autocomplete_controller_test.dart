import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_failure.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

const suggestion = PlaceSuggestion(
  placeId: 'place-qnl5',
  primaryText: 'QNL 5',
  secondaryText: 'Taguatinga',
);

const otherSuggestion = PlaceSuggestion(
  placeId: 'place-aguas',
  primaryText: 'Águas Claras',
  secondaryText: 'Brasília',
);

void main() {
  late MockPlaceAutocompleteDataSource datasource;
  late PlaceAutocompleteController controller;

  setUp(() {
    datasource = MockPlaceAutocompleteDataSource();
    controller = PlaceAutocompleteController(
      datasource: datasource,
      debounce: const Duration(milliseconds: 10),
    );
  });

  tearDown(() => controller.dispose());

  test('does not call Google below the minimum character count', () async {
    final results = <Object?>[];

    controller.search('qn', results.add);
    await Future<void>.delayed(const Duration(milliseconds: 40));

    verifyNever(() => datasource.findSuggestions(any(), any()));
    expect(results, hasLength(1));
  });

  test('a burst of typing produces a single request', () async {
    when(() => datasource.findSuggestions(any(), any()))
        .thenAnswer((_) async => const Ok([suggestion]));

    controller
      ..search('qnl', (_) {})
      ..search('qnl 5', (_) {})
      ..search('qnl 5 c', (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 40));

    verify(() => datasource.findSuggestions('qnl 5 c', any())).called(1);
    verifyNever(() => datasource.findSuggestions('qnl', any()));
  });

  test('keeps the newest response and discards a slower older one', () async {
    when(() => datasource.findSuggestions('primeira', any())).thenAnswer(
      (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 60));
        return const Ok([suggestion]);
      },
    );
    when(() => datasource.findSuggestions('segunda', any()))
        .thenAnswer((_) async => const Ok([otherSuggestion]));

    final received = <List<PlaceSuggestion>>[];
    void collect(Result<PlaceAutocompleteFailure, List<PlaceSuggestion>> result) {
      final value = result.valueOrNull;
      if (value != null) received.add(value);
    }

    controller.search('primeira', collect);
    await Future<void>.delayed(const Duration(milliseconds: 15));
    controller.search('segunda', collect);
    await Future<void>.delayed(const Duration(milliseconds: 120));

    expect(received, [
      const [otherSuggestion],
    ]);
  });

  test('uses the same session token across a search', () async {
    when(() => datasource.findSuggestions(any(), any()))
        .thenAnswer((_) async => const Ok([suggestion]));

    controller.search('qnl 5', (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 40));
    controller.search('qnl 5 conj', (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 40));

    final tokens = verify(
      () => datasource.findSuggestions(any(), captureAny()),
    ).captured.cast<String>().toSet();

    expect(tokens, hasLength(1));
  });

  test('starts a new session token after the selection is handed over', () async {
    when(() => datasource.findSuggestions(any(), any()))
        .thenAnswer((_) async => const Ok([suggestion]));

    controller.search('qnl 5', (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final handedOver = controller.handOverSelection();

    controller.search('aguas claras', (_) {});
    await Future<void>.delayed(const Duration(milliseconds: 40));

    final tokens = verify(
      () => datasource.findSuggestions(any(), captureAny()),
    ).captured.cast<String>();

    expect(tokens.first, handedOver);
    expect(tokens.last, isNot(handedOver));
  });

  test('surfaces the failure returned by the datasource', () async {
    when(() => datasource.findSuggestions(any(), any()))
        .thenAnswer((_) async => const Err(PlaceAutocompleteFailure.rejectedKey));

    PlaceAutocompleteFailure? failure;
    controller.search('qnl 5', (result) => failure = result.errorOrNull);
    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(failure, PlaceAutocompleteFailure.rejectedKey);
  });
}
