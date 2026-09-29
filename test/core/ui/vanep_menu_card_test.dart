import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_menu_card.dart';

Widget menuHarness(List<VanepMenuItem> items) {
  return MaterialApp(
    home: Scaffold(body: VanepMenuCard(items: items)),
  );
}

void main() {
  testWidgets('renders each item with a divider between them', (tester) async {
    await tester.pumpWidget(
      menuHarness(const [
        VanepMenuItem(label: 'Primeiro', icon: Icons.person_outline),
        VanepMenuItem(label: 'Segundo', icon: Icons.map_outlined),
      ]),
    );

    expect(find.text('Primeiro'), findsOneWidget);
    expect(find.text('Segundo'), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
  });

  testWidgets('an enabled item calls onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      menuHarness([
        VanepMenuItem(
          label: 'Ativo',
          icon: Icons.map_outlined,
          onTap: () => taps++,
        ),
      ]),
    );

    await tester.tap(find.text('Ativo'));

    expect(taps, 1);
  });

  testWidgets('a disabled item ignores taps and is faded', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      menuHarness([
        VanepMenuItem(
          label: 'Inativo',
          icon: Icons.map_outlined,
          enabled: false,
          onTap: () => taps++,
        ),
      ]),
    );

    await tester.tap(find.text('Inativo'));

    expect(taps, 0);
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Inativo'), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, lessThan(1));
  });

  testWidgets('a destructive item uses the danger color without chevron', (
    tester,
  ) async {
    await tester.pumpWidget(
      menuHarness(const [
        VanepMenuItem(label: 'Sair', icon: Icons.logout, isDestructive: true),
      ]),
    );

    final label = tester.widget<Text>(find.text('Sair'));
    expect(label.style?.color, VanepColors.danger);
    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });

  testWidgets('a warning subtitle is shown under the label', (tester) async {
    await tester.pumpWidget(
      menuHarness(const [
        VanepMenuItem(
          label: 'Dados',
          icon: Icons.person_outline,
          warningSubtitle: 'Confirme',
        ),
      ]),
    );

    expect(find.text('Confirme'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
