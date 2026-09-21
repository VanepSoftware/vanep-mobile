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

Align labelReveal(WidgetTester tester, String label) {
  return tester.widget<Align>(
    find.ancestor(of: find.text(label), matching: find.byType(Align)).first,
  );
}

Material itemSurface(WidgetTester tester, IconData icon) {
  return tester.widget<Material>(
    find.ancestor(of: find.byIcon(icon), matching: find.byType(Material)).first,
  );
}

void main() {
  testWidgets('labels only the selected destination', (tester) async {
    await tester.pumpWidget(navHarness(currentIndex: 0));
    await tester.pumpAndSettle();

    // Both labels are built; the unselected one is collapsed to zero width by
    // the reveal animation rather than removed from the tree.
    expect(labelReveal(tester, 'Início').widthFactor, 1);
    expect(labelReveal(tester, 'Perfil').widthFactor, 0);
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

  testWidgets('paints a stadium selection pill behind the current item only', (
    tester,
  ) async {
    await tester.pumpWidget(navHarness(currentIndex: 1));
    await tester.pumpAndSettle();

    final selected = itemSurface(tester, Icons.person);
    final unselected = itemSurface(tester, Icons.home_outlined);

    // Rounded end to end — a smaller radius is what read as a box before.
    expect(selected.shape, isA<StadiumBorder>());
    expect(selected.color, VanepColors.actionSurface);
    expect(unselected.color!.a, 0);
  });

  testWidgets('draws no divider line above the bar', (tester) async {
    await tester.pumpWidget(navHarness(currentIndex: 0));

    final bordered = find.descendant(
      of: find.byType(VanepBottomNav),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).border != null,
      ),
    );

    expect(bordered, findsNothing);
  });

  testWidgets('insets the outer destinations away from the screen edges', (
    tester,
  ) async {
    await tester.pumpWidget(navHarness(currentIndex: 0));
    await tester.pumpAndSettle();

    final bar = tester.getRect(find.byType(VanepBottomNav));
    final first = tester.getRect(find.byIcon(Icons.home));
    final last = tester.getRect(find.byIcon(Icons.person_outline));

    expect(first.left - bar.left, greaterThanOrEqualTo(24));
    expect(bar.right - last.right, greaterThanOrEqualTo(24));
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
      isSemantics(label: 'Perfil', isSelected: true, hasSelectedState: true),
    );

    handle.dispose();
  });
}
