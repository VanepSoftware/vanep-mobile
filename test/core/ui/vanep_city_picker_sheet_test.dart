import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_city_picker_sheet.dart';

import 'localized_host.dart';

const brasilia = VanepCityOption(token: 'city-brasilia', name: 'Brasília');
const gama = VanepCityOption(token: 'city-gama', name: 'Gama');

Widget sheet({
  List<VanepCityOption> options = const [brasilia, gama],
  String? selectedToken,
  String? errorText,
  ValueChanged<String>? onSearchChanged,
  ValueChanged<VanepCityOption>? onSelected,
}) {
  return localizedHost(
    VanepCityPickerSheet(
      options: options,
      selectedToken: selectedToken,
      errorText: errorText,
      onSearchChanged: onSearchChanged ?? (_) {},
      onSelected: onSelected ?? (_) {},
    ),
  );
}

void main() {
  testWidgets('shows the title, a search field and the cities', (tester) async {
    await tester.pumpWidget(sheet());

    expect(find.text('Selecionar cidade'), findsOneWidget);
    expect(find.text('Buscar município'), findsOneWidget);
    expect(find.text('Brasília'), findsOneWidget);
    expect(find.text('Gama'), findsOneWidget);
  });

  testWidgets('marks the chosen city', (tester) async {
    await tester.pumpWidget(sheet(selectedToken: 'city-gama'));

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('choosing a city reports it', (tester) async {
    VanepCityOption? chosen;
    await tester.pumpWidget(sheet(onSelected: (city) => chosen = city));

    await tester.tap(find.text('Gama'));

    expect(chosen, gama);
  });

  testWidgets('one letter does not search', (tester) async {
    final searches = <String>[];
    await tester.pumpWidget(sheet(onSearchChanged: searches.add));

    await tester.enterText(find.byType(TextField), 'b');

    expect(searches, isEmpty);
  });

  testWidgets('two letters search with the trimmed text', (tester) async {
    final searches = <String>[];
    await tester.pumpWidget(sheet(onSearchChanged: searches.add));

    await tester.enterText(find.byType(TextField), ' br ');

    expect(searches, ['br']);
  });

  testWidgets('clearing the search asks for the first page again', (
    tester,
  ) async {
    final searches = <String>[];
    await tester.pumpWidget(sheet(onSearchChanged: searches.add));

    await tester.enterText(find.byType(TextField), 'bra');
    await tester.enterText(find.byType(TextField), '');

    expect(searches, ['bra', '']);
  });

  testWidgets('no cities shows the empty message', (tester) async {
    await tester.pumpWidget(sheet(options: const []));

    expect(find.text('Nenhuma cidade encontrada.'), findsOneWidget);
  });

  testWidgets('an error replaces the list', (tester) async {
    await tester.pumpWidget(sheet(errorText: 'UF não encontrada.'));

    expect(find.text('UF não encontrada.'), findsOneWidget);
    expect(find.text('Brasília'), findsNothing);
  });

  testWidgets('the helper opens the sheet as a modal', (tester) async {
    await tester.pumpWidget(
      localizedHost(
        Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showVanepCityPickerSheet(context, builder: (_) => sheet()),
            child: const Text('abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Selecionar cidade'), findsWidgets);
  });
}
