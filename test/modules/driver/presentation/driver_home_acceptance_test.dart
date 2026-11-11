import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_shortcuts.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_main_card.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/slide_stop_confirmation.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';

import '../driver_home_fixture.dart';
import 'driver_home_tab_test.dart' show harness;

const titles = {
  HomePhase.blocked: 'Regularização necessária',
  HomePhase.incomplete: 'Complete seu cadastro',
  HomePhase.underReview: 'Cadastro em análise',
  HomePhase.rejected: 'Cadastro rejeitado',
  HomePhase.inProgress: 'Em rota',
  HomePhase.beforeDeparture: 'Antes de sair',
  HomePhase.shiftCompleted: 'Turno concluído',
  HomePhase.buildingRoute: 'Vamos montar sua rota',
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
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.byType(VanepCard)),
        findsOneWidget,
      );
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
    await tester.ensureVisible(find.text('Iniciar rota'));
    await tester.tap(find.text('Iniciar rota'));
    await tester.pumpAndSettle();
    expect(repository.starts, 1);
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
}
