import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/usecases/driver_home_rules.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_companion_sections.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_main_card.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_shortcuts.dart';

import '../driver_home_fixture.dart';

class FakeDriverHomeNavigation implements DriverHomeNavigation {
  final List<Shortcut> shortcutsOpened = [];
  int regularizations = 0;
  int resubmissions = 0;
  final List<String> checklists = [];
  final List<String> calls = [];

  @override
  void openShortcut(Shortcut shortcut) => shortcutsOpened.add(shortcut);

  @override
  void openRegularization() => regularizations++;

  @override
  void correctAndResubmit() => resubmissions++;

  @override
  void openChecklist(String tripId) => checklists.add(tripId);

  @override
  void callContact(String tripId) => calls.add(tripId);
}

const phaseTitles = {
  HomePhase.blocked: 'Novas propostas estão pausadas',
  HomePhase.incomplete: 'Complete seu cadastro para aparecer na busca',
  HomePhase.underReview: 'A Vanep está conferindo seus documentos',
  HomePhase.rejected: 'Cadastro rejeitado',
  HomePhase.inProgress: 'de 14 a bordo',
  HomePhase.beforeDeparture: 'Saída 6h20',
  HomePhase.shiftCompleted: '13 alunos entregues',
  HomePhase.buildingRoute: 'Traga os alunos que você já tem',
  HomePhase.noRouteToday: 'Próxima rota: segunda, 6h20',
};

void main() {
  for (final phase in HomePhase.values) {
    testWidgets('DriverHomeMainCard renders $phase and companion sections', (
      tester,
    ) async {
      final data = driverHomeFixture(phase);
      final navigation = FakeDriverHomeNavigation();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: ListView(
              children: [
                DriverHomeMainCard(
                  data: data,
                  phase: phase,
                  navigation: navigation,
                  enabled: true,
                  onStartRoute: () {},
                  onConfirmStop: (_) async {},
                ),
                DriverHomeCompanionSections(
                  phase: phase,
                  data: data,
                  rules: const DriverHomeRules(),
                  navigation: navigation,
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text(phaseTitles[phase]!), findsWidgets);
      final card = tester.widget<VanepCard>(find.byType(VanepCard));
      expect(card.isError, phase == HomePhase.rejected);
    });
  }

  testWidgets(
    'incomplete state keeps six shortcuts with only Documents enabled',
    (tester) async {
      final opened = <Shortcut>[];
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: DriverHomeShortcuts(
              data: const DriverHomeData(
                registration: RegistrationStatus.incomplete,
              ),
              rules: const DriverHomeRules(),
              onOpen: opened.add,
            ),
          ),
        ),
      );
      final buttons = tester
          .widgetList<OutlinedButton>(find.byType(OutlinedButton))
          .toList();
      expect(buttons.length, 6);
      expect(
        buttons.take(5).every((button) => button.onPressed == null),
        isTrue,
      );
      expect(buttons.last.onPressed, isNotNull);
      await tester.tap(find.text('Documentos'));
      await tester.pumpAndSettle();
      expect(opened, [Shortcut.documents]);
    },
  );
}
