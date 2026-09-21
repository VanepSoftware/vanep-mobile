import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_cep_address_card.dart';

import 'localized_host.dart';

Widget card({String neighborhood = '', String city = 'Brasília'}) {
  return localizedHost(
    VanepCepAddressCard(neighborhood: neighborhood, city: city, uf: 'DF'),
  );
}

void main() {
  testWidgets('shows the city with its UF on a single line', (tester) async {
    await tester.pumpWidget(card());

    expect(find.text('Brasília – DF'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('separates the neighborhood from the city with a comma', (
    tester,
  ) async {
    await tester.pumpWidget(card(neighborhood: 'Taguatinga'));

    expect(find.text('Taguatinga, Brasília – DF'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('has no title', (tester) async {
    await tester.pumpWidget(card(neighborhood: 'Taguatinga'));

    expect(find.text('Endereço do CEP'), findsNothing);
  });

  testWidgets('has an address icon before the text', (tester) async {
    await tester.pumpWidget(card());

    final icon = find.byIcon(Icons.location_on_outlined);
    expect(icon, findsOneWidget);
    expect(
      tester.getTopLeft(icon).dx,
      lessThan(tester.getTopLeft(find.text('Brasília – DF')).dx),
    );
  });

  testWidgets('the icon is decorative, not announced apart from the text', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(card());

    expect(find.bySemanticsLabel('Brasília – DF'), findsOneWidget);
    expect(
      tester
          .widget<Icon>(find.byIcon(Icons.location_on_outlined))
          .semanticLabel,
      isNull,
    );
    handle.dispose();
  });

  testWidgets('a long line wraps instead of overflowing', (tester) async {
    await tester.pumpWidget(
      card(
        neighborhood: 'Setor Habitacional Sol Nascente Trecho 2',
        city: 'Águas Lindas de Goiás',
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('is read-only: nothing to tap or type into', (tester) async {
    await tester.pumpWidget(card(neighborhood: 'Taguatinga'));

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(InkWell), findsNothing);
  });
}
