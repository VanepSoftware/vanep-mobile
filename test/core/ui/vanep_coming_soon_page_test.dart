import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_coming_soon_page.dart';

import 'localized_harness.dart';

void main() {
  testWidgets('pushes a coming soon page that can be closed with back', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedHarness(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => openComingSoonPage(
                context,
                title: 'Notificações',
                message: 'Em breve',
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.byType(VanepComingSoonPage), findsOneWidget);
    expect(find.text('Notificações'), findsOneWidget);
    expect(find.text('Em breve'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(VanepComingSoonPage), findsNothing);
    expect(find.text('abrir'), findsOneWidget);
  });
}
