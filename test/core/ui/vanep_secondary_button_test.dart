import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
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

  testWidgets('a destructive button uses the danger colors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VanepSecondaryButton(
            label: 'Recusar proposta',
            onPressed: () {},
            isDestructive: true,
          ),
        ),
      ),
    );

    final style = tester
        .widget<OutlinedButton>(find.byType(OutlinedButton))
        .style!;
    expect(style.backgroundColor!.resolve({}), VanepColors.dangerSurface);
    expect(style.foregroundColor!.resolve({}), VanepColors.dangerText);
    expect(style.side!.resolve({})!.color, VanepColors.dangerBorder);
  });

  testWidgets('a compact button is shorter and only as wide as its label', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: VanepSecondaryButton(
              label: 'Convidar',
              compact: true,
              icon: Icons.share_outlined,
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(VanepSecondaryButton));
    expect(size.height, 40);
    expect(size.width, lessThan(200));
  });
}
