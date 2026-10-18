import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/assistant/domain/entities/assistant_van.dart';
import 'package:vanep_mobile/modules/assistant/presentation/widgets/assistant_van_selector_sheet.dart';

const tVan1 = AssistantVan(
  token: 'van-1',
  driverToken: 'driver-1',
  driverName: 'Carlos Silva',
  plate: 'ABC-1234',
  model: 'Renault Master',
  shift: 'MORNING',
);

const tVan2 = AssistantVan(
  token: 'van-2',
  driverToken: 'driver-2',
  driverName: 'Maria Santos',
  plate: 'XYZ-5678',
  model: 'Mercedes Sprinter',
  shift: 'AFTERNOON',
);

Widget buildTestableWidget({
  required List<AssistantVan> vans,
  AssistantVan? selectedVan,
  required ValueChanged<AssistantVan> onSelectVan,
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
      body: AssistantVanSelectorSheet(
        vans: vans,
        selectedVan: selectedVan,
        onSelectVan: onSelectVan,
      ),
    ),
  );
}

void main() {
  group('AssistantVanSelectorSheet', () {
    testWidgets('renders empty state when no vans are provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          vans: const [],
          onSelectVan: (_) {},
        ),
      );

      expect(find.text('Selecione a van'), findsOneWidget);
      expect(
        find.text('Escolha qual van você vai acompanhar hoje'),
        findsOneWidget,
      );
      expect(
        find.text('Nenhuma van vinculada no momento.'),
        findsOneWidget,
      );
    });

    testWidgets('renders list of vans with driver and shift details', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableWidget(
          vans: const [tVan1, tVan2],
          selectedVan: tVan1,
          onSelectVan: (_) {},
        ),
      );

      expect(find.text('Renault Master (ABC-1234)'), findsOneWidget);
      expect(find.text('Carlos Silva • Manhã'), findsOneWidget);
      expect(find.text('Mercedes Sprinter (XYZ-5678)'), findsOneWidget);
      expect(find.text('Maria Santos • Tarde'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('triggers onSelectVan when tapping a van tile', (tester) async {
      AssistantVan? selected;
      await tester.pumpWidget(
        buildTestableWidget(
          vans: const [tVan1, tVan2],
          selectedVan: tVan1,
          onSelectVan: (van) => selected = van,
        ),
      );

      await tester.tap(find.text('Mercedes Sprinter (XYZ-5678)'));
      await tester.pump();

      expect(selected, equals(tVan2));
    });

    testWidgets('showAssistantVanSelectorSheet displays bottom sheet and selects van', (
      tester,
    ) async {
      AssistantVan? selected;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAssistantVanSelectorSheet(
                  context,
                  vans: const [tVan1, tVan2],
                  selectedVan: tVan1,
                  onSelectVan: (van) => selected = van,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(AssistantVanSelectorSheet), findsOneWidget);
      expect(find.text('Renault Master (ABC-1234)'), findsOneWidget);

      await tester.tap(find.text('Mercedes Sprinter (XYZ-5678)'));
      await tester.pumpAndSettle();

      expect(find.byType(AssistantVanSelectorSheet), findsNothing);
      expect(selected, equals(tVan2));
    });
  });

  group('assistantShiftLabel', () {
    testWidgets('translates morning, afternoon, night and fallback correctly', (
      tester,
    ) async {
      late AppLocalizations l10n;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(assistantShiftLabel(l10n, 'MORNING'), equals('Manhã'));
      expect(assistantShiftLabel(l10n, 'AFTERNOON'), equals('Tarde'));
      expect(assistantShiftLabel(l10n, 'NIGHT'), equals('Noite'));
      expect(assistantShiftLabel(l10n, 'CUSTOM'), equals('CUSTOM'));
      expect(assistantShiftLabel(l10n, null), equals(''));
    });
  });
}
