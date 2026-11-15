import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_current_dot.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';

void main() {
  Future<void> pumpDot(WidgetTester tester, VanepCurrentDot dot) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: dot)),
      ),
    );
  }

  BoxDecoration decorationOf(WidgetTester tester) {
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(VanepCurrentDot),
        matching: find.byType(Container),
      ),
    );
    return box.decoration! as BoxDecoration;
  }

  testWidgets('the current dot is blue with a halo and reads its label', (
    tester,
  ) async {
    await pumpDot(
      tester,
      const VanepCurrentDot(isCurrent: true, semanticLabel: 'Versão atual'),
    );

    final decoration = decorationOf(tester);
    expect(decoration.color, VanepPalette.light.action);
    expect(decoration.border, isNotNull);
    expect(find.bySemanticsLabel('Versão atual'), findsOneWidget);
  });

  testWidgets('a past dot is muted and says nothing', (tester) async {
    await pumpDot(
      tester,
      const VanepCurrentDot(isCurrent: false, semanticLabel: 'Versão atual'),
    );

    final decoration = decorationOf(tester);
    expect(decoration.color, VanepPalette.light.textMuted);
    expect(decoration.border, isNull);
    expect(find.bySemanticsLabel('Versão atual'), findsNothing);
  });
}
