import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_primary_button.dart';

Widget harness(VanepPrimaryButton button) {
  return MaterialApp(home: Scaffold(body: button));
}

void main() {
  testWidgets('renders the label and reports taps', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      harness(VanepPrimaryButton(label: 'Aceitar', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Aceitar'));

    expect(taps, 1);
    expect(tester.getSize(find.byType(FilledButton)).height, 52);
  });

  testWidgets('the compact variant is shorter with a smaller label', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        VanepPrimaryButton(label: 'Aceitar', compact: true, onPressed: () {}),
      ),
    );

    expect(tester.getSize(find.byType(FilledButton)).height, 44);
    expect(tester.widget<Text>(find.text('Aceitar')).style?.fontSize, 14);
  });
}
