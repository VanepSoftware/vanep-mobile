import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_map_placeholder.dart';

import 'localized_host.dart';

void main() {
  testWidgets('shows the pin and the label', (tester) async {
    await tester.pumpWidget(
      localizedHost(
        const VanepMapPlaceholder(
          pinIcon: Icons.school,
          label: 'Escola Classe 10',
        ),
      ),
    );

    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.text('Escola Classe 10'), findsOneWidget);
  });

  testWidgets('shows neither label nor chip when none is given', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedHost(const VanepMapPlaceholder(pinIcon: Icons.location_on)),
    );

    expect(find.byType(Text), findsNothing);
    expect(find.text('Ajustar no mapa'), findsNothing);
  });

  testWidgets('has a fixed height of 168', (tester) async {
    await tester.pumpWidget(
      localizedHost(const VanepMapPlaceholder(pinIcon: Icons.location_on)),
    );

    expect(tester.getSize(find.byType(VanepMapPlaceholder)).height, 168);
  });

  testWidgets('tapping the adjust chip changes nothing', (tester) async {
    await tester.pumpWidget(
      localizedHost(
        const VanepMapPlaceholder(
          pinIcon: Icons.location_on,
          actionLabel: 'Ajustar no mapa',
        ),
      ),
    );

    await tester.tap(find.text('Ajustar no mapa'));
    await tester.pump();

    expect(find.text('Ajustar no mapa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('screen readers hear an illustrative map, not its label', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      localizedHost(
        const VanepMapPlaceholder(
          pinIcon: Icons.school,
          label: 'Escola Classe 10',
        ),
      ),
    );

    expect(find.bySemanticsLabel('Mapa ilustrativo'), findsOneWidget);
    expect(find.bySemanticsLabel('Escola Classe 10'), findsNothing);
    semantics.dispose();
  });
}
