import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_secondary_button.dart';

void main() {
  testWidgets('renders the label and reports taps', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepSecondaryButton(label: 'Google', onPressed: () => taps++),
        ),
      ),
    );
    await tester.tap(find.text('Google'));

    expect(taps, 1);
  });

  testWidgets('shows progress instead of the label while loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepSecondaryButton(
            label: 'Google',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.text('Google'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.onPressed, isNull);
  });
}
