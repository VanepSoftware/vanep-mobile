import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/domain/usecases/driver_home_rules.dart';
import 'package:vanep_mobile/modules/driver/presentation/cubit/driver_home_cubit.dart';
import 'package:vanep_mobile/modules/driver/presentation/pages/driver_home_tab.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_shortcuts.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/slide_stop_confirmation.dart';

import 'driver_home_cubit_test.dart' show HomeRepository;

Widget harness(DriverHomeCubit cubit) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('pt'),
  home: Scaffold(body: BlocProvider.value(value: cubit, child: DriverHomeTab(
    displayName: 'Carlos Souza', onMenuTapped: () {}, onNotificationsTapped: () {}))));

void main() {
  testWidgets('loads repository data and starts the pending trip', (tester) async {
    final repository = HomeRepository();
    final cubit = DriverHomeCubit(repository: repository)..seedToday(shiftStartTime: '6h00');
    addTearDown(cubit.close);
    await tester.pumpWidget(harness(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Carlos!'), findsOneWidget);
    expect(find.text('Seu expediente começa às 6h00'), findsOneWidget);
    await tester.ensureVisible(find.text('Iniciar rota'));
    await tester.tap(find.text('Iniciar rota'));
    await tester.pumpAndSettle();
    expect(repository.starts, 1);
    expect(find.text('Em rota'), findsOneWidget);
  });
  testWidgets('incomplete state keeps six shortcuts with only Documents enabled', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: DriverHomeShortcuts(
      data: const DriverHomeData(registration: RegistrationStatus.incomplete),
      rules: const DriverHomeRules(), onOpen: (_) {}))));
    final buttons = tester.widgetList<OutlinedButton>(find.byType(OutlinedButton)).toList();
    expect(buttons.length, 6);
    expect(buttons.take(5).every((button) => button.onPressed == null), isTrue);
    expect(buttons.last.onPressed, isNotNull);
    expect(find.text('Documentos'), findsOneWidget);
  });
  testWidgets('rejected registration shows reason and resubmission action', (tester) async {
    final repository = HomeRepository()..data = const DriverHomeData(
      registration: RegistrationStatus.rejected, rejectionReason: 'CNH ilegível');
    final cubit = DriverHomeCubit(repository: repository);
    addTearDown(cubit.close);
    await tester.pumpWidget(harness(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Cadastro rejeitado'), findsOneWidget);
    expect(find.text('CNH ilegível'), findsOneWidget);
    expect(find.text('Corrigir e reenviar'), findsOneWidget);
    final card = tester.widget<Card>(find.byType(Card));
    final context = tester.element(find.byType(Card));
    expect(card.color, Theme.of(context).colorScheme.errorContainer);
  });
  testWidgets('blocked active trip keeps operational card and a warning banner', (tester) async {
    final repository = HomeRepository()..data = const DriverHomeData(
      registration: RegistrationStatus.approved, expiredDocument: true,
      todayTrip: Trip(id: 'trip', status: TripStatus.inProgress, label: 'Manhã'));
    final cubit = DriverHomeCubit(repository: repository);
    addTearDown(cubit.close);
    await tester.pumpWidget(harness(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Em rota'), findsOneWidget);
    expect(find.text('Atualize os documentos vencidos.'), findsOneWidget);
    expect(find.text('Checklist'), findsOneWidget);
    expect(find.text('Regularização necessária'), findsNothing);
  });
  for (final action in StopAction.values) {
    testWidgets('$action requires full drag; tap and partial drag do not confirm', (tester) async {
      var confirmations = 0;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SizedBox(width: 320,
        child: SlideStopConfirmation(confirmation: StopConfirmation(tripId: 't',
          stopId: 'stop', studentId: 's', studentName: 'Ana', action: action),
          enabled: true, onConfirmed: () async { confirmations++; })))));
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
    });
  }
}
