import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_section.dart';

Widget sectionHost(VanepSection section) {
  return MaterialApp(home: Scaffold(body: section));
}

void main() {
  testWidgets('renders only the child when there is no title', (tester) async {
    await tester.pumpWidget(
      sectionHost(const VanepSection(child: Text('card'))),
    );

    expect(find.byType(Text), findsOneWidget);
    expect(find.text('card'), findsOneWidget);
  });

  testWidgets('renders the title above the child', (tester) async {
    await tester.pumpWidget(
      sectionHost(const VanepSection(title: 'Semana', child: Text('card'))),
    );

    final title = tester.widget<Text>(find.text('Semana'));
    expect(title.style?.fontSize, VanepTypography.sectionTitle.fontSize);
    expect(title.style?.fontWeight, VanepTypography.sectionTitle.fontWeight);
    final titleBottom = tester.getBottomLeft(find.text('Semana')).dy;
    final childTop = tester.getTopLeft(find.text('card')).dy;
    expect(childTop, greaterThan(titleBottom));
  });

  testWidgets('renders the note to the right of the title', (tester) async {
    await tester.pumpWidget(
      sectionHost(
        const VanepSection(
          title: 'Semana',
          note: '5 dias',
          child: Text('card'),
        ),
      ),
    );

    final titleRight = tester.getTopRight(find.text('Semana')).dx;
    final noteLeft = tester.getTopLeft(find.text('5 dias')).dx;
    expect(noteLeft, greaterThanOrEqualTo(titleRight));
    expect(
      tester.getTopRight(find.text('5 dias')).dx,
      tester.getTopRight(find.byType(VanepSectionHeader)).dx,
    );
  });

  testWidgets('the action calls back', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      sectionHost(
        VanepSection(
          title: 'Horários',
          actionLabel: 'Editar',
          onAction: () => taps++,
          child: const Text('card'),
        ),
      ),
    );

    await tester.tap(find.text('Editar'));

    expect(taps, 1);
  });

  testWidgets('hides the action when it has no callback', (tester) async {
    await tester.pumpWidget(
      sectionHost(
        const VanepSection(
          title: 'Horários',
          actionLabel: 'Editar',
          child: Text('card'),
        ),
      ),
    );

    expect(find.text('Editar'), findsNothing);
  });
}
