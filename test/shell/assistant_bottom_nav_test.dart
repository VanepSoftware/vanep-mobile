import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_bottom_nav.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/shell/assistant_bottom_nav.dart';

Widget buildTestableWidget({
  required int currentIndex,
  required ValueChanged<int> onDestinationSelected,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Scaffold(
      bottomNavigationBar: AssistantBottomNav(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
      ),
    ),
  );
}

void main() {
  group('AssistantBottomNav', () {
    testWidgets('renders exactly 3 navigation destinations for assistant', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(currentIndex: 0, onDestinationSelected: (_) {}),
      );

      final nav = tester.widget<VanepBottomNav>(find.byType(VanepBottomNav));
      final labels = [for (final item in nav.items) item.label];

      expect(labels, equals(['Início', 'Vans', 'Alunos']));
      expect(labels.contains('Meu perfil'), isFalse);
      expect(labels.contains('Propostas'), isFalse);
      expect(labels.contains('Rota'), isFalse);
    });

    testWidgets('calls onDestinationSelected when an item is tapped', (
      tester,
    ) async {
      int? tappedIndex;

      await tester.pumpWidget(
        buildTestableWidget(
          currentIndex: 0,
          onDestinationSelected: (index) => tappedIndex = index,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Alunos'));
      await tester.pump();

      expect(tappedIndex, equals(2));

      await tester.tap(find.bySemanticsLabel('Vans'));
      await tester.pump();

      expect(tappedIndex, equals(1));
    });

    testWidgets('provides semantic labels for accessibility', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(currentIndex: 0, onDestinationSelected: (_) {}),
      );

      expect(find.bySemanticsLabel('Início'), findsOneWidget);
      expect(find.bySemanticsLabel('Alunos'), findsOneWidget);
      expect(find.bySemanticsLabel('Vans'), findsOneWidget);
    });
  });
}
