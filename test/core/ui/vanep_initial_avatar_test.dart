import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_palette.dart';
import 'package:vanep_mobile/core/ui/vanep_initial_avatar.dart';

void main() {
  test('the initial is the first letter of the name, in upper case', () {
    expect(vanepInitialOf('  ana Souza'), 'A');
    expect(vanepInitialOf('Élio'), 'É');
    expect(vanepInitialOf(''), '');
  });

  test('the same seed always gets the same colors', () {
    expect(
      vanepInitialAvatarColors(VanepPalette.light, 'dep-ana'),
      vanepInitialAvatarColors(VanepPalette.light, 'dep-ana'),
    );
    expect(
      vanepInitialAvatarTones(VanepPalette.light),
      contains(vanepInitialAvatarColors(VanepPalette.light, 'dep-pedro')),
    );
  });

  test('avatar tones follow the palette', () {
    expect(
      vanepInitialAvatarTones(VanepPalette.dark).first.surface,
      VanepPalette.dark.avatarAmberSurface,
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
