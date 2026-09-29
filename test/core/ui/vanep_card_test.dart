import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';

Widget cardHarness({bool highlighted = false, VoidCallback? onTap}) {
  return MaterialApp(
    home: Scaffold(
      body: VanepCard(
        highlighted: highlighted,
        onTap: onTap,
        child: const Text('conteudo'),
      ),
    ),
  );
}

Material cardMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find
        .ancestor(of: find.text('conteudo'), matching: find.byType(Material))
        .first,
  );
}

RoundedRectangleBorder cardShape(WidgetTester tester) {
  return cardMaterial(tester).shape! as RoundedRectangleBorder;
}

void main() {
  testWidgets('paints a flat outlined surface without elevation', (
    tester,
  ) async {
    await tester.pumpWidget(cardHarness());

    final material = cardMaterial(tester);
    expect(material.color, VanepColors.card);
    expect(material.elevation, 0);
    expect(cardShape(tester).side.color, VanepColors.cardBorder);
  });

  testWidgets('switches to the action outline when highlighted', (
    tester,
  ) async {
    await tester.pumpWidget(cardHarness(highlighted: true));

    expect(cardMaterial(tester).color, VanepColors.actionSurface);
    expect(cardShape(tester).side.color, VanepColors.action);
  });

  testWidgets('reports taps when a callback is given', (tester) async {
    var taps = 0;
    await tester.pumpWidget(cardHarness(onTap: () => taps++));

    await tester.tap(find.text('conteudo'));

    expect(taps, 1);
  });
}
