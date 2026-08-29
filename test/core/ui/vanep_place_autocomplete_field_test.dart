import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_controller.dart';
import 'package:vanep_mobile/core/places/place_autocomplete_datasource.dart';
import 'package:vanep_mobile/core/places/place_suggestion.dart';
import 'package:vanep_mobile/core/result/result.dart';
import 'package:vanep_mobile/core/ui/vanep_place_autocomplete_field.dart';

class MockPlaceAutocompleteDataSource extends Mock
    implements PlaceAutocompleteDataSource {}

const qnl5 = PlaceSuggestion(
  placeId: 'place-qnl5',
  primaryText: 'Setor L Norte QNL 5',
  secondaryText: 'Taguatinga, Brasília - DF',
);

void main() {
  late MockPlaceAutocompleteDataSource datasource;
  late PlaceAutocompleteController controller;
  late List<PlaceSelection> selections;

  setUp(() {
    datasource = MockPlaceAutocompleteDataSource();
    when(() => datasource.findSuggestions(any(), any()))
        .thenAnswer((_) async => const Ok([qnl5]));
    controller = PlaceAutocompleteController(
      datasource: datasource,
      debounce: const Duration(milliseconds: 10),
    );
    selections = [];
  });

  tearDown(() => controller.dispose());

  Widget harness({required bool clearOnSelect}) {
    return MaterialApp(
      home: Scaffold(
        body: VanepPlaceAutocompleteField(
          controller: controller,
          clearOnSelect: clearOnSelect,
          hint: 'Endereço ou escola',
          emptyLabel: 'Nada encontrado',
          networkErrorLabel: 'Sem conexão',
          keyErrorLabel: 'Indisponível',
          retryLabel: 'Tentar novamente',
          onSelected: selections.add,
        ),
      ),
    );
  }

  Future<void> typeAndPick(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), 'qnl 5');
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump();
    await tester.tap(find.text('Setor L Norte QNL 5'));
    await tester.pump();
  }

  /// Numa busca, apagar o que a pessoa escolheu esconde o que ela pesquisou e
  /// faz a tela parecer quebrada.
  testWidgets('keeps the chosen place in the field when asked to', (
    tester,
  ) async {
    await tester.pumpWidget(harness(clearOnSelect: false));

    await typeAndPick(tester);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, 'Setor L Norte QNL 5');
  });

  /// Na tela de áreas o campo é reaproveitado para a próxima região.
  testWidgets('clears the field when asked to', (tester) async {
    await tester.pumpWidget(harness(clearOnSelect: true));

    await typeAndPick(tester);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, isEmpty);
  });

  testWidgets('hands the place and the session token to the caller', (
    tester,
  ) async {
    await tester.pumpWidget(harness(clearOnSelect: false));

    await typeAndPick(tester);

    expect(selections.single.suggestion, qnl5);
    expect(selections.single.sessionToken, isNotEmpty);
  });

  testWidgets('hides the suggestion list after choosing', (tester) async {
    await tester.pumpWidget(harness(clearOnSelect: false));

    await typeAndPick(tester);

    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('searching again after a selection still works', (tester) async {
    await tester.pumpWidget(harness(clearOnSelect: false));
    await typeAndPick(tester);

    await tester.enterText(find.byType(TextField), 'aguas claras');
    await tester.pump(const Duration(milliseconds: 40));
    await tester.pump();

    expect(find.byType(ListTile), findsOneWidget);
  });
}
