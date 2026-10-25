import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';

void main() {
  test('the initial is the first letter of the name, in upper case', () {
    expect(vanepInitialOf('  ana Souza'), 'A');
    expect(vanepInitialOf('Élio'), 'É');
    expect(vanepInitialOf(''), '');
  });

  test('the same seed always gets the same colors', () {
    expect(
      vanepInitialAvatarColors('dep-ana'),
      vanepInitialAvatarColors('dep-ana'),
    );
    expect(
      vanepInitialAvatarPalette,
      contains(vanepInitialAvatarColors('dep-pedro')),
    );
  });

  testWidgets('shows the initial and stays out of the screen reader', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VanepInitialAvatar(name: 'Pedro', seed: 'dep-pedro'),
        ),
      ),
    );

    expect(find.text('P'), findsOneWidget);
    expect(find.bySemanticsLabel('P'), findsNothing);
    semantics.dispose();
  });
}
