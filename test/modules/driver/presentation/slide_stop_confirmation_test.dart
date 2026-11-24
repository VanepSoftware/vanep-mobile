import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanep_mobile/core/ui/vanep_card.dart';
import 'package:vanep_mobile/l10n/app_localizations.dart';
import 'package:vanep_mobile/modules/driver/domain/entities/driver_home_data.dart';
import 'package:vanep_mobile/modules/driver/presentation/driver_home_localizations.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/driver_home_primitives.dart';
import 'package:vanep_mobile/modules/driver/presentation/widgets/slide_stop_confirmation.dart';

import '../driver_home_fixture.dart';

void main() {
  testWidgets('VanepCard error state uses errorContainer and error border', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: VanepCard(isError: true, child: Text('Rejected'))),
      ),
    );
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

  testWidgets('localizes DriverHomeMessage and driver shifts in PT and EN', (
    tester,
  ) async {
    late AppLocalizations pt;
    late AppLocalizations en;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Builder(
          builder: (context) {
            pt = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (context) {
            en = AppLocalizations.of(context)!;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(
      DriverHomeMessage.unavailable.localize(pt),
      'Os dados do início ainda não estão disponíveis.',
    );
    expect(
      DriverHomeMessage.unavailable.localize(en),
      'Home data is not available yet.',
    );
    expect(localizeDriverShift(pt, 'MORNING'), 'Manhã');
    expect(localizeDriverShift(en, 'AFTERNOON'), 'Afternoon');
    expect(driverHomeFixture(HomePhase.inProgress).nextConfirmation, isNotNull);
  });

  testWidgets('DriverListRow triggers onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DriverListCard(
            children: [
              DriverListRow(
                leading: const DriverIconBubble(
                  icon: Icons.autorenew_outlined,
                  backgroundColor: DriverHomeTokens.actionSoft,
                  iconColor: DriverHomeTokens.action,
                ),
                title: 'Renovação para 2027',
                subtitle: 'Envie proposta de renovação aos pais atuais.',
                onTap: () => tapped = true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Renovação para 2027'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
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
        final actionLabel = action == StopAction.boarding
            ? 'embarque'
            : 'desembarque';
        expect(
          find.text('Deslize para confirmar $actionLabel'),
          findsOneWidget,
        );
        expect(find.textContaining('('), findsNothing);
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
