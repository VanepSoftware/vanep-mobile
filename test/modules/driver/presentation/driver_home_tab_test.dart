import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/usecases/driver_home_rules.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/pages/driver_home_tab.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_shortcuts.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/slide_stop_confirmation.dart';

import 'driver_home_cubit_test.dart' show HomeRepository;

Widget harness(DriverHomeCubit cubit, {String locale = 'pt'}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: Locale(locale),
  home: Scaffold(
    body: BlocProvider.value(
      value: cubit,
      child: DriverHomeTab(
        displayName: 'Carlos Souza',
        onMenuTapped: () {},
        onNotificationsTapped: () {},
      ),
    ),
  ),
);

void main() {
  testWidgets('English home uses localized labels and errors', (tester) async {
    final cubit = DriverHomeCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(harness(cubit, locale: 'en'));
    await tester.pumpAndSettle();
    expect(find.text('Home data is not available yet.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('loads repository data and starts the pending trip', (
    tester,
  ) async {
    final repository = HomeRepository();
    final cubit = DriverHomeCubit(repository: repository)
      ..seedToday(shiftStartTime: '6h00');
    addTearDown(cubit.close);
    await tester.pumpWidget(harness(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Carlos!'), findsOneWidget);
    expect(find.text('Seu expediente começa às 6h00'), findsOneWidget);
    expect(find.text('Antes de sair'), findsOneWidget);
    await tester.ensureVisible(find.text('Deslize para iniciar a rota'));
    await tester.tap(find.text('Deslize para iniciar a rota'));
    await tester.pumpAndSettle();
    expect(repository.starts, 1);
    expect(find.text('EM ROTA · MANHÃ'), findsOneWidget);
    // The API did not send nextConfirmation, so no invented next stop is shown.
    expect(find.text('PRÓXIMA PARADA'), findsNothing);
  });

  testWidgets(
    'incomplete state keeps six shortcuts with only Documents enabled',
    (tester) async {
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
              onOpen: (_) {},
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
      expect(find.text('Documentos'), findsOneWidget);
    },
  );

  testWidgets('rejected registration shows reason and resubmission action', (
    tester,
  ) async {
    final repository = HomeRepository()
      ..data = const DriverHomeData(
        registration: RegistrationStatus.rejected,
        rejectionReason: 'CNH ilegível',
      );
    final cubit = DriverHomeCubit(repository: repository);
    addTearDown(cubit.close);
    await tester.pumpWidget(harness(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Cadastro rejeitado'), findsWidgets);
    expect(find.text('CNH ilegível'), findsOneWidget);
    expect(find.text('Corrigir e reenviar'), findsOneWidget);
    final card = tester.widget<VanepCard>(find.byType(VanepCard));
    expect(card.isError, isTrue);
    final context = tester.element(find.byType(VanepCard));
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byType(VanepCard),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(material.color, Theme.of(context).colorScheme.errorContainer);
  });

  testWidgets(
    'blocked active trip keeps operational card and a warning banner',
    (tester) async {
      final repository = HomeRepository()
        ..data = const DriverHomeData(
          registration: RegistrationStatus.approved,
          expiredDocument: true,
          todayTrip: Trip(
            id: 'trip',
            status: TripStatus.inProgress,
            label: 'Manhã',
          ),
        );
      final cubit = DriverHomeCubit(repository: repository);
      addTearDown(cubit.close);
      await tester.pumpWidget(harness(cubit));
      await tester.pumpAndSettle();
      expect(find.text('Em rota'), findsOneWidget);
      expect(find.text('Atualize os documentos vencidos.'), findsOneWidget);
      expect(find.text('Checklist'), findsOneWidget);
      expect(find.text('Novas propostas estão pausadas'), findsNothing);
    },
  );

  testWidgets(
    'shiftCompleted shows the real next shift and opens the trip report',
    (tester) async {
      final repository = HomeRepository()
        ..data = const DriverHomeData(
          registration: RegistrationStatus.approved,
          todayTrip: Trip(
            id: 'trip',
            status: TripStatus.completed,
            label: 'MORNING',
          ),
          laterShiftLabel: 'AFTERNOON',
        );
      final cubit = DriverHomeCubit(repository: repository);
      addTearDown(cubit.close);
      await tester.pumpWidget(harness(cubit));
      await tester.pumpAndSettle();
      expect(find.text('Próximo turno: Tarde'), findsOneWidget);
      expect(find.text('Renovação para 2027'), findsNothing);
      await tester.ensureVisible(find.text('Ver relatório da viagem'));
      await tester.tap(find.text('Ver relatório da viagem'));
      await tester.pumpAndSettle();
      expect(find.text('Em breve'), findsOneWidget);
    },
  );

  group('greeting derives date and shift from real data', () {
    Future<void> pumpGreeting(
      WidgetTester tester,
      HomePhase phase, {
      String? shift,
    }) => tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: DriverHomeGreetingSection(
            displayName: 'Carlos Souza',
            shiftStartTime: '',
            phase: phase,
            shift: shift,
            today: DateTime(2026, 11, 24),
          ),
        ),
      ),
    );

    for (final phase in [
      HomePhase.beforeDeparture,
      HomePhase.noRouteToday,
      HomePhase.blocked,
    ]) {
      testWidgets('$phase shows the injected date', (tester) async {
        await pumpGreeting(tester, phase);
        expect(find.text('Terça-feira, 24 de novembro'), findsOneWidget);
      });
    }

    testWidgets('inProgress shows the trip shift', (tester) async {
      await pumpGreeting(tester, HomePhase.inProgress, shift: 'NIGHT');
      expect(find.text('Em rota'), findsOneWidget);
      expect(find.text('Noite'), findsOneWidget);
    });

    testWidgets('shiftCompleted combines date and first name', (tester) async {
      await pumpGreeting(tester, HomePhase.shiftCompleted);
      expect(find.text('Turno concluído'), findsOneWidget);
      expect(
        find.text('Terça-feira, 24 de novembro · bom trabalho, Carlos'),
        findsOneWidget,
      );
    });
  });

  for (final action in StopAction.values) {
    testWidgets(
      '$action requires full drag; tap and partial drag do not confirm',
      (tester) async {
        var confirmations = 0;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            home: Scaffold(
              body: SizedBox(
                width: 320,
                child: SlideStopConfirmation(
                  confirmation: StopConfirmation(
                    tripId: 't',
                    stopId: 'stop',
                    studentId: 's',
                    studentName: 'Ana',
                    action: action,
                  ),
                  enabled: true,
                  onConfirmed: () async {
                    confirmations++;
                  },
                ),
              ),
            ),
          ),
        );
        final handle = find.byType(GestureDetector);
        await tester.tap(handle);
        await tester.pumpAndSettle();
        expect(confirmations, 0);
        await tester.drag(handle, const Offset(50, 0));
        await tester.pumpAndSettle();
        expect(confirmations, 0);
        await tester.drag(handle, const Offset(320, 0));
        await tester.pumpAndSettle();
        expect(confirmations, 1);
      },
    );
  }
}
