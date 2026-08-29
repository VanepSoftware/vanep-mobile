import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_colors.dart';
import 'package:vanep_mobile/core/ui/vanep_bottom_nav.dart';

const testNavItems = [
  VanepNavItem(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Início',
  ),
  VanepNavItem(
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: 'Perfil',
  ),
];

Widget navHarness({
  required int currentIndex,
  ValueChanged<int>? onDestinationSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      bottomNavigationBar: VanepBottomNav(
        items: testNavItems,
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected ?? (_) {},
      ),
    ),
  );
}

BoxDecoration navButtonDecoration(WidgetTester tester, IconData icon) {
  final container = tester.widget<AnimatedContainer>(
    find.ancestor(
      of: find.byIcon(icon),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('renders icons without any visible label text', (tester) async {
    await tester.pumpWidget(navHarness(currentIndex: 0));

    expect(find.text('Início'), findsNothing);
    expect(find.text('Perfil'), findsNothing);
    expect(find.byType(Icon), findsNWidgets(testNavItems.length));
  });

  testWidgets('keeps every label reachable by screen readers', (tester) async {
    await tester.pumpWidget(navHarness(currentIndex: 0));

    expect(find.bySemanticsLabel('Início'), findsOneWidget);
    expect(find.bySemanticsLabel('Perfil'), findsOneWidget);
  });

  testWidgets('uses the selected icon only for the current index', (
    tester,
  ) async {
    await tester.pumpWidget(navHarness(currentIndex: 0));

    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsNothing);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.person), findsNothing);
  });

  testWidgets('paints the selection surface behind the current item only', (
    tester,
  ) async {
    await tester.pumpWidget(navHarness(currentIndex: 1));

    expect(
      navButtonDecoration(tester, Icons.person).color,
      VanepColors.navSelectedSurface,
    );
    expect(
      navButtonDecoration(tester, Icons.home_outlined).color,
      Colors.transparent,
    );
  });

  testWidgets('reports the tapped index', (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(
      navHarness(currentIndex: 0, onDestinationSelected: tapped.add),
    );

    await tester.tap(find.bySemanticsLabel('Perfil'));

    expect(tapped, [1]);
  });

  testWidgets('marks the current item as selected for accessibility', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(navHarness(currentIndex: 1));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Perfil')),
      matchesSemantics(
        label: 'Perfil',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );

    handle.dispose();
  });
}
