import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_main_card.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_shortcuts.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/slide_stop_confirmation.dart';

import '../driver_home_fixture.dart';
import 'driver_home_tab_test.dart' show harness;

const titles = {
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

const shortcuts = [
  'Alunos',
  'Rota e paradas',
  'Ausências e ajustes',
  'Financeiro',
  'Auxiliares',
  'Documentos',
];

void main() {
  for (final phase in HomePhase.values) {
    testWidgets('$phase changes the card and preserves six ordered shortcuts', (
      tester,
    ) async {
      final cubit = DriverHomeCubit(
        repository: DriverHomeFixtureRepository(driverHomeFixture(phase)),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(harness(cubit));
      await tester.pumpAndSettle();
      final card = find.byType(DriverHomeMainCard);
      expect(
        find.descendant(of: card, matching: find.text(titles[phase]!)),
        findsWidgets,
      );
      expect(
        find.descendant(of: card, matching: find.byType(VanepCard)),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.byType(DriverHomeShortcuts),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final buttons = tester
          .widgetList<OutlinedButton>(
            find.descendant(
              of: find.byType(DriverHomeShortcuts),
              matching: find.byType(OutlinedButton),
            ),
          )
          .toList();
      expect(buttons, hasLength(6));
      for (var index = 0; index < shortcuts.length; index++) {
        expect(
          find.descendant(
            of: find.byWidget(buttons[index]),
            matching: find.text(shortcuts[index]),
          ),
          findsOneWidget,
        );
        expect(
          buttons[index].onPressed != null,
          phase != HomePhase.incomplete || index == 5,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('D12 shows 100 percent and omits an unknown family count', (
    tester,
  ) async {
    final repository = DriverHomeFixtureRepository(
      driverHomeFixture(HomePhase.noRouteToday),
    );
    final cubit = DriverHomeCubit(repository: repository);
    addTearDown(cubit.close);
    await tester.pumpWidget(harness(cubit));
    await tester.pumpAndSettle();
    expect(find.text('3 de 3 com família no app'), findsOneWidget);
    repository.data = driverHomeFixture(
      HomePhase.noRouteToday,
      familiesInApp: null,
    );
    await cubit.refresh();
    await tester.pumpAndSettle();
    expect(find.text('3 de 3 com família no app'), findsNothing);
  });

  testWidgets('outside hours warns and still allows route start', (
    tester,
  ) async {
    final repository = DriverHomeFixtureRepository(
      driverHomeFixture(HomePhase.beforeDeparture, outsideWorkingHours: true),
    );
    final cubit = DriverHomeCubit(repository: repository);
    addTearDown(cubit.close);
    await tester.pumpWidget(harness(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Você está fora do expediente.'), findsOneWidget);
    await tester.ensureVisible(find.text('Deslize para iniciar a rota'));
    await tester.tap(find.text('Deslize para iniciar a rota'));
    await tester.pumpAndSettle();
    expect(repository.starts, 1);
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.text('Em rota'), findsOneWidget);
  });

  testWidgets('blocked active trip keeps contact and slide inside the card', (
    tester,
  ) async {
    final repository = DriverHomeFixtureRepository(
      driverHomeFixture(HomePhase.inProgress, blockedInProgress: true),
    );
    final cubit = DriverHomeCubit(repository: repository);
    addTearDown(cubit.close);
    await tester.pumpWidget(harness(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Regularize sua assinatura Vanep.'), findsOneWidget);
    final card = find.byType(DriverHomeMainCard);
    expect(
      find.descendant(of: card, matching: find.text('Checklist')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: card,
        matching: find.text('Ligar: Responsável da Ana'),
      ),
      findsOneWidget,
    );
    final slider = find.descendant(
      of: card,
      matching: find.byType(SlideStopConfirmation),
    );
    expect(slider, findsOneWidget);
    await tester.ensureVisible(slider);
    await tester.drag(
      find.descendant(of: slider, matching: find.byType(GestureDetector)),
      const Offset(800, 0),
    );
    await tester.pumpAndSettle();
    expect(repository.confirmations, 1);
  });

  group('cards reflect the repository data instead of fixed values', () {
    Future<DriverHomeFixtureRepository> pumpData(
      WidgetTester tester,
      DriverHomeData data,
    ) async {
      final repository = DriverHomeFixtureRepository(data);
      final cubit = DriverHomeCubit(repository: repository);
      addTearDown(cubit.close);
      await tester.pumpWidget(harness(cubit));
      await tester.pumpAndSettle();
      return repository;
    }

    Finder inCard(String text) => find.descendant(
      of: find.byType(DriverHomeMainCard),
      matching: find.text(text),
    );

    for (final (count, shift, shiftLabel) in [
      (0, 'MORNING', 'MANHÃ'),
      (9, 'AFTERNOON', 'TARDE'),
      (27, 'NIGHT', 'NOITE'),
    ]) {
      testWidgets('before departure: $count students on $shift', (
        tester,
      ) async {
        await pumpData(
          tester,
          DriverHomeData(
            registration: RegistrationStatus.approved,
            todayTrip: Trip(
              id: 'trip-$count',
              status: TripStatus.notStarted,
              label: shift,
            ),
            studentCount: count,
          ),
        );
        expect(inCard('$count'), findsOneWidget);
        expect(inCard('ROTA · $shiftLabel'), findsOneWidget);
        expect(inCard('14'), findsNothing);
      });
    }

    for (final (name, action, actionLabel) in [
      ('Joana Prado', StopAction.boarding, 'embarque'),
      ('Rafael Lima', StopAction.disembarking, 'desembarque'),
    ]) {
      testWidgets('in progress: next stop for $name', (tester) async {
        final repository = await pumpData(
          tester,
          DriverHomeData(
            registration: RegistrationStatus.approved,
            todayTrip: const Trip(
              id: 'trip',
              status: TripStatus.inProgress,
              label: 'AFTERNOON',
            ),
            nextConfirmation: StopConfirmation(
              tripId: 'trip',
              stopId: 'stop-$name',
              studentId: 'student-$name',
              studentName: name,
              action: action,
            ),
            contactLabel: 'Responsável de $name',
          ),
        );
        expect(inCard('EM ROTA · TARDE'), findsOneWidget);
        expect(inCard(name), findsOneWidget);
        expect(inCard('Deslize para confirmar $actionLabel'), findsOneWidget);
        expect(inCard('Ligar: Responsável de $name'), findsOneWidget);
        final slider = find.descendant(
          of: find.byType(DriverHomeMainCard),
          matching: find.byType(SlideStopConfirmation),
        );
        await tester.ensureVisible(slider);
        await tester.drag(
          find.descendant(of: slider, matching: find.byType(GestureDetector)),
          const Offset(800, 0),
        );
        await tester.pumpAndSettle();
        expect(repository.confirmations, 1);
      });
    }

    testWidgets('in progress without nextConfirmation shows no stop', (
      tester,
    ) async {
      await pumpData(
        tester,
        const DriverHomeData(
          registration: RegistrationStatus.approved,
          todayTrip: Trip(
            id: 'trip',
            status: TripStatus.inProgress,
            label: 'MORNING',
          ),
        ),
      );
      expect(find.byType(SlideStopConfirmation), findsNothing);
      expect(inCard('PRÓXIMA PARADA'), findsNothing);
    });

    for (final (later, label) in [('AFTERNOON', 'Tarde'), ('NIGHT', 'Noite')]) {
      testWidgets('shift completed: next shift $later', (tester) async {
        await pumpData(
          tester,
          DriverHomeData(
            registration: RegistrationStatus.approved,
            todayTrip: const Trip(
              id: 'trip',
              status: TripStatus.completed,
              label: 'MORNING',
            ),
            laterShiftLabel: later,
          ),
        );
        expect(inCard('Próximo turno: $label'), findsOneWidget);
      });
    }

    for (final (families, total) in [(0, 4), (2, 4), (4, 4)]) {
      testWidgets('no route today: $families of $total families', (
        tester,
      ) async {
        await pumpData(
          tester,
          DriverHomeData(
            registration: RegistrationStatus.approved,
            studentCount: total,
            familiesInApp: families,
          ),
        );
        expect(
          find.text('$families de $total com família no app'),
          findsOneWidget,
        );
      });
    }
  });
}
