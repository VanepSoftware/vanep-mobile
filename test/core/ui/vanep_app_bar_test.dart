import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/design_system/vanep_typography.dart';
import 'package:vanep_mobile/core/ui/vanep_page_chrome.dart';

Widget appBarHost(VanepAppBar appBar) {
  return MaterialApp(home: Scaffold(appBar: appBar));
}

void main() {
  testWidgets('renders no title when none is given', (tester) async {
    await tester.pumpWidget(appBarHost(const VanepAppBar()));

    expect(find.byType(Text), findsNothing);
  });

  testWidgets('renders only the title when there is no caption', (
    tester,
  ) async {
    await tester.pumpWidget(appBarHost(const VanepAppBar(title: 'Escola')));

    final title = tester.widget<Text>(find.text('Escola'));
    expect(title.style, VanepTypography.cardTitle);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('renders the caption under the title', (tester) async {
    await tester.pumpWidget(
      appBarHost(const VanepAppBar(title: 'Escola', caption: 'Davi')),
    );

    final titleBottom = tester.getBottomLeft(find.text('Escola')).dy;
    final captionTop = tester.getTopLeft(find.text('Davi')).dy;
    expect(captionTop, greaterThanOrEqualTo(titleBottom));
  });

  testWidgets('renders the actions', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      appBarHost(
        VanepAppBar(
          title: 'Ana',
          caption: 'Dependente',
          actions: [
            IconButton(
              tooltip: 'Mais opções',
              icon: const Icon(Icons.more_vert),
              onPressed: () => taps++,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert));

    expect(taps, 1);
  });
}
