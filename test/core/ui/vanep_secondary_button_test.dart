import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/google_logo.dart';
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

  testWidgets('shows a leading widget before the label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepSecondaryButton(
            label: 'Google',
            onPressed: () {},
            leading: const GoogleLogo(),
          ),
        ),
      ),
    );

    expect(find.byType(GoogleLogo), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
    expect(
      tester.getCenter(find.byType(GoogleLogo)).dx,
      lessThan(tester.getTopLeft(find.text('Google')).dx),
    );
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

  testWidgets('the compact variant is shorter with a smaller label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepSecondaryButton(
            label: 'Ver proposta',
            compact: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(OutlinedButton)).height, 44);
    expect(tester.widget<Text>(find.text('Ver proposta')).style?.fontSize, 14);
  });
}
