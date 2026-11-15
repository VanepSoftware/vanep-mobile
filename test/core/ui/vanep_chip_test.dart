import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_chip.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';

void main() {
  testWidgets('shows the label in its colors, with the icon when given', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VanepChip(
              label: 'Expira em 31/10',
              icon: Icons.schedule,
              background: VanepPalette.light.avatarGraySurface,
              foreground: VanepPalette.light.avatarGrayText,
            ),
          ),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('Expira em 31/10'));
    expect(label.style!.color, VanepPalette.light.avatarGrayText);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.schedule)).color,
      VanepPalette.light.avatarGrayText,
    );
    final box = tester.widget<Container>(find.byType(Container));
    expect(
      (box.decoration! as BoxDecoration).color,
      VanepPalette.light.avatarGraySurface,
    );
  });
}
