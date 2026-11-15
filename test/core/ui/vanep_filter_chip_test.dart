import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_filter_chip.dart';

void main() {
  testWidgets('reports taps and exposes the toggled state', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepFilterChip(
            label: 'Manhã',
            isSelected: true,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Manhã'));

    expect(taps, 1);
    expect(
      tester.getSemantics(find.text('Manhã')),
      matchesSemantics(
        label: 'Manhã',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );
  });
}
