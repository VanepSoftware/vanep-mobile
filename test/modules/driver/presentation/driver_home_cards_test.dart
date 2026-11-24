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
  HomePhase.inProgress: 'EM ROTA · MANHÃ',
  HomePhase.beforeDeparture: 'Antes de sair',
  HomePhase.shiftCompleted: 'Turno concluído',
  HomePhase.buildingRoute: 'Traga os alunos que você já tem',
  HomePhase.noRouteToday: 'Sem rota hoje',
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

  Future<void> pumpHome(
    WidgetTester tester,
    HomePhase phase,
    DriverHomeData data,
  ) => tester.pumpWidget(
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
              navigation: FakeDriverHomeNavigation(),
              enabled: true,
              onStartRoute: () {},
              onConfirmStop: (_) async {},
            ),
            DriverHomeCompanionSections(
              phase: phase,
              data: data,
              rules: const DriverHomeRules(),
              navigation: FakeDriverHomeNavigation(),
            ),
          ],
        ),
      ),
    ),
  );

  for (final count in [0, 7, 23]) {
    testWidgets('before departure shows the real student count ($count)', (
      tester,
    ) async {
      const trip = Trip(
        id: 'trip',
        status: TripStatus.notStarted,
        label: 'AFTERNOON',
      );
      await pumpHome(
        tester,
        HomePhase.beforeDeparture,
        DriverHomeData(
          registration: RegistrationStatus.approved,
          todayTrip: trip,
          studentCount: count,
        ),
      );
      expect(find.text('$count'), findsOneWidget);
      expect(find.text('ROTA · TARDE'), findsOneWidget);
      for (final invented in ['14', '10', '2', 'Saída 6h20', 'Marcos na van']) {
        if (invented == '$count') continue;
        expect(find.text(invented), findsNothing);
      }
    });
  }

  testWidgets('in progress renders the next stop only when the API sends it', (
    tester,
  ) async {
    const trip = Trip(
      id: 'trip',
      status: TripStatus.inProgress,
      label: 'MORNING',
    );
    await pumpHome(
      tester,
      HomePhase.inProgress,
      const DriverHomeData(
        registration: RegistrationStatus.approved,
        todayTrip: trip,
      ),
    );
    expect(find.text('PRÓXIMA PARADA'), findsNothing);
    expect(find.text('Beatriz e Gabriel'), findsNothing);
    expect(find.textContaining('a bordo'), findsNothing);

    await pumpHome(
      tester,
      HomePhase.inProgress,
      const DriverHomeData(
        registration: RegistrationStatus.approved,
        todayTrip: trip,
        nextConfirmation: StopConfirmation(
          tripId: 'trip',
          stopId: 'stop-9',
          studentId: 'student-9',
          studentName: 'Joana Prado',
          action: StopAction.disembarking,
        ),
      ),
    );
    expect(find.text('PRÓXIMA PARADA'), findsOneWidget);
    expect(find.text('Joana Prado'), findsOneWidget);
    expect(find.text('Deslize para confirmar desembarque'), findsOneWidget);
  });

  testWidgets(
    'shift completed shows the real next shift and no invented KPIs',
    (tester) async {
      await pumpHome(
        tester,
        HomePhase.shiftCompleted,
        const DriverHomeData(
          registration: RegistrationStatus.approved,
          todayTrip: Trip(
            id: 'trip',
            status: TripStatus.completed,
            label: 'AFTERNOON',
          ),
          laterShiftLabel: 'NIGHT',
        ),
      );
      expect(find.text('TARDE'), findsOneWidget);
      expect(find.text('Próximo turno: Noite'), findsOneWidget);
      expect(find.text('1h03'), findsNothing);
      expect(find.text('13 alunos entregues'), findsNothing);
    },
  );

  testWidgets('blocked card follows the block reason from the API', (
    tester,
  ) async {
    await pumpHome(
      tester,
      HomePhase.blocked,
      const DriverHomeData(
        registration: RegistrationStatus.approved,
        expiredDocument: true,
      ),
    );
    expect(find.text('Atualize os documentos vencidos.'), findsOneWidget);
    expect(find.text('Documento vencido'), findsOneWidget);
    expect(find.text('Ver fatura'), findsNothing);
    expect(find.textContaining(r'R$'), findsNothing);

    await pumpHome(
      tester,
      HomePhase.blocked,
      const DriverHomeData(
        registration: RegistrationStatus.approved,
        subscriptionBlocked: true,
      ),
    );
    expect(find.text('Regularize sua assinatura Vanep.'), findsOneWidget);
    expect(find.text('Ver fatura'), findsOneWidget);
    expect(find.text('Documento vencido'), findsNothing);
  });

  testWidgets('no route today hides the family counter when it is unknown', (
    tester,
  ) async {
    await pumpHome(
      tester,
      HomePhase.noRouteToday,
      const DriverHomeData(
        registration: RegistrationStatus.approved,
        studentCount: 5,
      ),
    );
    expect(find.text('Sem rota hoje'), findsOneWidget);
    expect(find.textContaining('com família no app'), findsNothing);

    await pumpHome(
      tester,
      HomePhase.noRouteToday,
      const DriverHomeData(
        registration: RegistrationStatus.approved,
        studentCount: 5,
        familiesInApp: 2,
      ),
    );
    expect(find.text('2 de 5 com família no app'), findsOneWidget);
  });
}
